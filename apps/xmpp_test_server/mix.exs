defmodule XmppTestServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :xmpp_test_server,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      # elixir: "~> 1.11",
      elixir: "~> 1.7.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :myxql],
      env: [
        # MYSQL_HOST: "192.168.178.79",
        # MYSQL_DB: "xmpp_test",
        # MYSQL_USER: "xmpp",
        # MYSQL_PWD: "Test1234"
      ],
      mod: {XmppTestServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
      {:xmpp_test_parser, in_umbrella: true},
      {:myxql, "~> 0.4.0"},
      {:bcrypt_elixir, "~> 2.3.0"}
    ]
  end

  defp aliases do
    [
#      test: "test --no-start"
    ]
  end
end
