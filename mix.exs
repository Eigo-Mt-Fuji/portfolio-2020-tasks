defmodule PortfolioTasks.MixProject do
  use Mix.Project

  def project do
    [
      app: :portfolio_tasks,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:chroxy, "~> 0.6.3"},
      {:crawly, "~> 0.8.0"},
      {:cowboy, "~> 2.6.3"},
      {:plug, "~> 1.8.0"},
      {:plug_cowboy, "~> 2.0.2"},
      {:chroxy_client, "~> 0.3.0"},
      {:chrome_remote_interface, "~> 0.3.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
