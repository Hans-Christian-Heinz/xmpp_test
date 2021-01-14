import Config

config :xmpp_test_client,
  # XMPP_SERVER: IO.gets("xmpp-server (default: 127.0.0.1): ") |> String.trim,
  # XMPP_PORT: IO.gets("xmpp-port (default: 5222): ") |> String.trim
  XMPP_SERVER: System.fetch_env!("XMPP_SERVER"),
  XMPP_PORT: System.fetch_env!("XMPP_PORT")
