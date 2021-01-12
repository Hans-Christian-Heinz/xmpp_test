defmodule XmppTestClient.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    server = Application.get_env(:xmpp_test_client, :XMPP_SERVER, "127.0.0.1")
    port = Application.get_env(:xmpp_test_client, :XMPP_PORT, "5222")
    packet = Application.get_env(:xmpp_test_client, :XMPP_PACKET, 2)

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: XmppTestClient.Worker.start_link(arg)
      # {XmppTestClient.Worker, arg},
      Supervisor.child_spec({Task, fn -> XmppTestClient.connect(server, port, packet) end}, restart: :permanent),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XmppTestClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
