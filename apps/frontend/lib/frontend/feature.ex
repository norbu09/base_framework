defmodule Frontend.Feature do
  require Logger
  alias Frontend.Repo.RolesEnum

  @moduledoc """
  Feature flags are an easy way to enable and disable features based on
  configuration, user role and environment. They can be either called with only
  a feature or with a feature and a user. if called with a user as well we can
  check for roles.

  typically we can invoke feature flags in templates like this:


      ...
      defdelegate has?(feature, user), to: Frontend.Feature
      ...
      <%= if has?(:admin, @current_user) do %>
        <p>i am admin</p>
      <% end %>

  or in backend code based on a feature flag:

      ...
      defdelegate has?(feature), to: Frontend.Feature
      ...
      if has?(:notify_discord) do
        notify_discord(msg)
      end

  The above snipped needs a config like this in `config/config.yml`

      config :base_framework,
        feature: [
          notify_discord: false
        ]

  In future we may want to implement the `defdelegate` call deeper in the
  frontend so it is available in all frontend facing code.

  """

  @flags Application.compile_env(:base_framework, :feature)

  @spec has?(atom, Frontend.Accounts.User) :: true | false
  def has?(role_or_flag, user \\ nil) do
    case role_or_flag in RolesEnum.types() do
      true ->
        Logger.debug("Only show feature if user has #{role_or_flag} role")

        case user do
          nil ->
            false

          _ ->
            if user.role == role_or_flag do
              true
            else
              false
            end
        end

      false ->
        Logger.debug("Only show feature if feature flag #{role_or_flag} is set")

        case @flags[role_or_flag] do
          nil -> false
          false -> false
          _ -> true
        end
    end
  end
end
