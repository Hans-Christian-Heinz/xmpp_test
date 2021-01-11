defmodule XmppTestServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Port 5222: XMPP standard port
    port = String.to_integer(Application.get_env(:xmpp_test_server, :XMPP_PORT, "5222"))
    host = Application.get_env(:xmpp_test_server, :MYSQL_HOST, "127.0.0.1")
    db_name = Application.get_env(:xmpp_test_server, :MYSQL_DB, "xmpp_test")
    db_username = Application.get_env(:xmpp_test_server, :MYSQL_USER, "xmpp")
    db_pwd = Application.get_env(:xmpp_test_server, :MYSQL_PWD, "Test1234")

    # Child processes to supervise
    children = [
      {Task.Supervisor, name: XmppTestServer.TaskSupervisor},
#      {DynamicSupervisor, name: Users.Supervisor, strategy: :one_for_one},
      Supervisor.child_spec({Task, fn -> XmppTestServer.accept(port) end}, restart: :permanent),
      {MyXQL, name: :myxql, hostname: host, database: db_name, username: db_username, password: db_pwd},
      {XmppTestServer.Users, name: :users},
      {Registry, keys: :unique, name: Users.Registry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XmppTestServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
