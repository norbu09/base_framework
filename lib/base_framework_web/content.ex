defmodule BaseFrameworkWeb.Content do

  @bucket Application.compile_env!(:base_framework, [PardallMarkdown.Content, :s3_bucket])
  @local_cache Application.compile_env!(:pardall_markdown, [PardallMarkdown.Content, :root_path])

  def content_reloaded do
    Application.ensure_all_started(:focus) # Recommended
    BaseFramework.Storage.S3.update(@bucket, @local_cache)
    BaseFrameworkWeb.Endpoint.broadcast!("pardall_markdown_web", "content_reloaded", :all)
  end

end
