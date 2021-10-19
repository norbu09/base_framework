defmodule BaseFramework.Storage.S3 do
  require Logger

  def update(bucket, local) do
    case ExAws.S3.list_objects_v2(bucket) |> ExAws.request() do
      {:ok, %{body: %{contents: files}}} ->
        get_new(files, local, bucket)
      err -> 
        Logger.warn("Could not update: #{inspect err}")
        {:ok, :no_files}
    end
  end

  defp get_new(files, local, bucket) do
    updated = case File.exists?(local) do
      true -> check_last_updated(local)
      false -> File.mkdir_p!(local)
    end
    files
    |> Enum.map(fn x -> needs_update?(x, updated) end)
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.map(fn x -> save_local(x, local, bucket) end)
    |> mark_update(local)
  end

  defp needs_update?(%{last_modified: date} = file, updated) do
    Logger.debug("Last updated: #{date}")
    case DateTime.from_iso8601(date) > updated do
      true -> file
      false -> 
        Logger.debug("#{file.key} needs no update")
        nil
    end
  end

  defp save_local(%{key: file} = object, local, bucket) do
    Logger.debug("Updateing local copy of #{file}")
    Logger.debug("raw object: #{inspect object}")
    case ExAws.S3.get_object(bucket, file) |> ExAws.request() do
      {:ok, %{body: body}} ->
        path = Path.join(local, file) 
        case File.mkdir_p(Path.dirname(path)) do
          :ok -> 
            case File.write(path, body) do
              :ok ->
                Logger.info("Updated #{path}")
                file
              err ->
                Logger.warn("Had problems updating #{path}: #{inspect err}")
                :error
            end
          err -> 
            Logger.warn("Had problems creating #{Path.dirname(path)}: #{inspect err}")
            :error
        end
      err -> 
        Logger.warn("Could not fetch #{file}: #{inspect err}")
        :error
    end
  end

  defp check_last_updated(local) do
    case File.exists?(last_updated_path(local)) do
      true ->  case File.read(last_updated_path(local)) do
        {:ok, date} -> 
          {:ok, datetime, _} = DateTime.from_iso8601(date) # may want to match to 0 for offset to make sure we compare UTC times
          datetime
        _ -> nil
      end
      false -> nil
    end
  end

  defp mark_update(updated, local) do
    Logger.debug("Updated: #{inspect updated}")
    case Enum.member?(updated, :error) do
      true -> Logger.info("No update timestamp writter due to errors")
      false ->
        date = DateTime.now!("Etc/UTC") |> DateTime.to_iso8601
        File.write(last_updated_path(local), date)
    end
  end

  defp last_updated_path(local) do
    Path.join([local, "../", ".s3_last_updated"])
  end
end
