defmodule FrontendWeb.OpenidView do
  use FrontendWeb, :html

  def render("jwks.json", %{jwk_keys: jwk_keys}) do
    %{keys: jwk_keys}
  end

  def render("userinfo.json", %{userinfo: userinfo}) do
    userinfo
  end
end
