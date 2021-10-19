defmodule BaseFrameworkWeb.Content do

  def content_reloaded do
    Application.ensure_all_started(:base_framework) # Recommended
    BaseFrameworkWeb.Endpoint.broadcast!("pardall_markdown_web", "content_reloaded", :all)
  end

end
