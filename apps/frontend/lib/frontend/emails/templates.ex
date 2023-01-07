defmodule Frontend.Emails.Templates do
  import Swoosh.Email

  def contact({:ok, msg}) do
    new()
    |> to({"contact form", "hello@PROJECT_DOMAIN"})
    |> cc({msg.name, msg.email})
    |> from({"PROJECT_DOMAIN", "hello@PROJECT_DOMAIN"})
    |> subject("contact form:  #{msg.subject}")
    |> html_body("<p>Contact form: #{msg.body}</p>")
    |> text_body("#{msg.body}\n")
  end
end
