# import Config
use Mix.Config

config :xmpp_test_server,
#  XMPP_PORT: "5222",
  MYSQL_HOST: "127.0.0.1",
  MYSQL_DB: "xmpp_test_testing",
  MYSQL_USER: "xmpp",
  MYSQL_PWD: "Test1234",
  XMPP_PACKET: 2,
  XMPP_SERVER: '127.0.0.1'

config :xmpp_test_client,
  XMPP_SERVER: '127.0.0.1',
  XMPP_PORT: 5222,
  XMPP_PACKET: 2

config :logger,
  level: :error
