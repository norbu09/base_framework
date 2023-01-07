defmodule FrontendWeb.Layouts do
  use FrontendWeb, :html

  @tracking Application.compile_env(:frontend_web, __MODULE__)[:tracking]

  attr :domain, :string, default: "PROJECT_DOMAIN"

  def analytics(assigns) do
    case @tracking do
      true ->
        ~H"""
        <script defer data-api="/api/event" data-domain={@domain} src="/js/script.js">
        </script>
        """

      false ->
        ~H"""
        <!-- no analytics -->
        """
    end
  end

  embed_templates "layouts/*"
end
