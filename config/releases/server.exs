import Config

config :xmpp_test_server,
#  MYSQL_HOST: IO.gets("mysql-host (default: 127.0.0.1): ") |> String.trim,
#  MYSQL_DB: IO.gets("database-name (default: xmpp_test): ") |> String.trim,
#  MYSQL_USER: IO.gets("mysql-user (default: xmpp): ") |> String.trim,
#  MYSQL_PWD: IO.gets("mysql-password (Test1234): ") |> String.trim,
#  XMPP_PORT: IO.gets("xmpp-port (default: 5222):") |> String.trim
  MYSQL_HOST: System.fetch_env!("MYSQL_HOST"),
  MYSQL_DB: System.fetch_env!("MYSQL_DB"),
  MYSQL_USER: System.fetch_env!("MYSQL_USER"),
  MYSQL_PWD: System.fetch_env!("MYSQL_PWD"),
  XMPP_PORT: System.fetch_env!("XMPP_PORT")
