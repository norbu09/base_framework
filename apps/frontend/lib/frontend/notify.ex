defmodule Frontend.Notify do
  alias Frontend.Accounts.User
  require Logger

  @discrod_url Application.compile_env(:frontend, :discord_url)
  defdelegate has?(feature), to: Frontend.Feature

  def new_user(user, "registered") do
    user
    |> via(:discord)
  end

  def new_user(user, action) do
    thing =
      case action do
        "" -> "login"
        "password_updated" -> "password update"
        _ -> action
      end

    Logger.info("User: #{user.email} did a #{thing}")
  end

  defp via(%User{} = user, :discord) do
    message =
      %{content: "Yay, we got a new user: #{user.email} on PROJECT_DOMAIN :tada:"}
      |> Jason.encode!()

    if has?(:notify_discord) do
      res =
        Finch.build(:post, @discrod_url, [{"Content-Type", "application/json"}], message)
        |> Finch.request(FrontendFinch)

      Logger.debug("Finch answer: #{inspect(res)}")
    end

    Logger.debug(message)
    user
  end
end
