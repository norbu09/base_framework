defmodule Frontend.Contact do
  alias Frontend.Emails.ContactMessage, as: Message
  alias Frontend.Emails.Templates

  @spec change_message() :: Ecto.Changeset.t()
  def change_message() do
    %Message{}
    |> Message.changeset(%{})
  end

  @spec send_message(map) :: {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  def send_message(fields) when is_map(fields) do
    %Message{}
    |> Message.changeset(fields)
    |> Ecto.Changeset.apply_action(:insert)
    |> Templates.contact()
    |> Frontend.Mailer.deliver()
  end
end
