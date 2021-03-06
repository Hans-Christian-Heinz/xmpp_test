defmodule XmppTest.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: [
        server: [
          version: "0.0.1",
          applications: [xmpp_test_server: :permanent],
          runtime_config_path: "config/releases/server.exs",
          rel_templates_path: "rel/server",
          steps: [:assemble, :tar],
        ],
        client: [
          version: "0.0.1",
          applications: [xmpp_test_client: :permanent],
          runtime_config_path: "config/releases/client.exs",
          rel_templates_path: "rel/client",
          steps: [:assemble, :tar],
        ]
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
      # Cowboy ist ein Erlang HTTP-Server, ich versuche XMPP
      # {:plug_cowboy, "~> 2.4"}
      # {:sqlite, "~> 1.1"},
      # {:sqlite_ecto2, "~> 2.4"}
      # {:myxql, "~> 0.4.0"},
      # {:mariaex, "~> 0.9.1"}
      # {:bcrypt_elixir, "~> 2.3.0"}
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
