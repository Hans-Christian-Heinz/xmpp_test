defmodule XmppTestClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :xmpp_test_client,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      # elixir: "~> 1.7",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {XmppTestClient.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
      {:xmpp_test_parser, in_umbrella: true},
      {:xmpp_test_server, in_umbrella: true, only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
