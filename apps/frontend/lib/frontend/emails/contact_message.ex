defmodule Frontend.Emails.ContactMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          name: String.t(),
          email: String.t(),
          subject: String.t(),
          body: String.t()
        }

  embedded_schema do
    field(:name, :string)
    field(:email, :string)
    field(:subject, :string)
    field(:body, :string)
  end

  @spec changeset(t(), map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = message, fields) when is_map(fields) do
    message
    |> cast(fields, [:name, :email, :subject, :body])
    |> validate_required([:name, :email, :subject, :body])
    |> validate_format(:email, ~r([^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+))
  end
end
