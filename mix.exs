defmodule BaseFramework.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      name: "PROJECT_DOMAIN",
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases()
    ]
  end

  defp releases do
    [
      base_framework: [
        applications: [base_framework: :permanent, frontend: :permanent, frontend_web: :permanent],
        steps: [:assemble, :tar]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      # required to run "mix format" on ~H/.heex files from the umbrella root
      {:phoenix, ">= 1.7.0-rc.0", override: true},
      {:phoenix_live_view, ">= 0.0.0"},
      {:ex_todo, ">= 0.1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.21.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"]
    ]
  end
end
