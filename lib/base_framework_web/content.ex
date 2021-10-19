defmodule BaseFrameworkWeb.Content do
  require Logger

  @bucket Application.compile_env!(:base_framework, [PardallMarkdown.Content, :s3_bucket])
  @local_cache Application.compile_env!(:pardall_markdown, [PardallMarkdown.Content, :root_path])

  def content_reloaded do
    Application.ensure_all_started(:base_framework) # Recommended
    BaseFrameworkWeb.Endpoint.broadcast!("pardall_markdown_web", "content_reloaded", :all)
  end

  def force_content_reload do
    Logger.info("Forcing content reload")
    PardallMarkdown.FileParser.load_all!
  end

  def update do
    Task.start(BaseFramework.Storage.S3, :update, [@bucket, @local_cache])
  end

end
