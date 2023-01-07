# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Frontend.Repo.insert!(%Frontend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

id = SecureRandom.uuid()
secret = SecureRandom.hex(64)

Boruta.Ecto.Admin.create_client(%{
  # OAuth client_id
  id: id,
  # OAuth client_secret
  secret: secret,
  # Display name
  name: "A client",
  # one day
  access_token_ttl: 60 * 60 * 24,
  # one minute
  authorization_code_ttl: 60,
  # one month
  refresh_token_ttl: 60 * 60 * 24 * 30,
  # one day
  id_token_ttl: 60 * 60 * 24,
  # ID token signature algorithm, defaults to "RS512"
  id_token_signature_alg: "RS256",
  # OAuth client redirect_uris
  redirect_uris: ["http://redirect.uri"],
  # take following authorized_scopes into account (skip public scopes)
  authorize_scope: true,
  # scopes that are authorized using this client
  authorized_scopes: [%{name: "a:scope"}],
  # client supported grant types
  supported_grant_types: [
    "client_credentials",
    "password",
    "authorization_code",
    "refresh_token",
    "implicit",
    "revoke",
    "introspect"
  ],
  # PKCE enabled
  pkce: false,
  # do not require client_secret for refreshing tokens
  public_refresh_token: false,
  # do not require client_secret for revoking tokens
  public_revoke: false
})
|> IO.inspect()
