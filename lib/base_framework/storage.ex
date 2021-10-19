defmodule BaseFramework.Storage do

  def has_content_dir(path) do
    case File.exists?(path) do
      true -> :ok
      false -> File.mkdir_p!(path)
    end
  end

end
