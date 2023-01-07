defmodule FrontendWeb.Router do
  use FrontendWeb, :router
  alias FrontendWeb.EnsureRolePlug

  import FrontendWeb.UserAuth

  import FrontendWeb.Plugs.ApiAuth,
    only: [
      require_authenticated: 2
    ]

  pipeline :web do
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FrontendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :user do
    plug EnsureRolePlug, [:user, :beta, :admin]
  end

  pipeline :beta do
    plug EnsureRolePlug, [:beta, :admin]
  end

  pipeline :admin do
    plug EnsureRolePlug, :admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected_api do
    plug(:accepts, ["json"])
    plug(:require_authenticated)
  end

  scope "/", FrontendWeb do
    pipe_through [:browser, :web]

    # static pages
    get "/", PageController, :home
    get "/terms", PageController, :terms
    get "/privacy", PageController, :privacy
    # blog routes
    live "/blog", CMS.ArticlesLive
    live "/blog/:id/:slug", CMS.ArticleLive

    # user routes
    delete "/users/log_out", UserSessionController, :delete
    live "/users/confirm/:token", UserConfirmationLive, :edit
    live "/users/confirm", UserConfirmationInstructionsLive, :new

    # CMS fallback route - make this a dynamic route generator so the dynamic
    # route validator works live "/*slug", CMS.PageLive
  end

  ## Authentication routes

  scope "/", FrontendWeb do
    pipe_through [:browser, :web, :require_authenticated_user, :user]

    live "/users/settings", UserSettingsLive, :edit
    live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

    live "/dashboard", DashboardLive.Index

    # oauth & openid
    get "/oauth/authorize", Oauth.AuthorizeController, :authorize
    get "/openid/authorize", Openid.AuthorizeController, :authorize
  end

  # beta routes go here
  scope "/", FrontendWeb do
    pipe_through [:browser, :web, :require_authenticated_user, :beta]
  end

  # admin routes go here
  scope "/admin", FrontendWeb do
    import Phoenix.LiveDashboard.Router

    pipe_through [:browser, :web, :require_authenticated_user, :admin]

    live "/", Admin.DashboardLive.Index, :index

    live "/users", Admin.UserLive.Index, :index
    live "/users/new", Admin.UserLive.Index, :new
    live "/users/:id/edit", Admin.UserLive.Index, :edit
    live "/users/:id", Admin.UserLive.Show, :show
    live "/users/:id/show/edit", Admin.UserLive.Show, :edit

    live "/clients", Admin.ClientsLive.Index, :index
    live "/client/new", Admin.ClientsLive.Index, :new
    live "/client/:id/edit", Admin.ClientsLive.Index, :edit
    live "/client/:id", Admin.ClientsLive.Show, :show
    live "/client/:id/show/edit", Admin.ClientsLive.Show, :edit

    live_dashboard "/phoenix", metrics: FrontendWeb.Telemetry, ecto_repos: [Frontend.Repo]
  end

  # user authentication routes go here
  scope "/", FrontendWeb do
    pipe_through [:browser, :web, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{FrontendWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  # API routes
  scope "/oauth", FrontendWeb.Oauth do
    pipe_through [:api]

    post "/revoke", RevokeController, :revoke
    post "/token", TokenController, :token
    post "/introspect", IntrospectController, :introspect
  end

  scope "/openid", FrontendWeb.Openid do
    pipe_through [:api]

    get "/userinfo", UserinfoController, :userinfo
    post "/userinfo", UserinfoController, :userinfo
    get "/jwks", JwksController, :jwks_index
  end

  scope "/api", FrontendWeb do
    pipe_through :protected_api
  end

  # development only routes
  if Application.compile_env(:frontend, :dev_routes) do
    scope "/dev" do
      pipe_through [:browser, :web]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
