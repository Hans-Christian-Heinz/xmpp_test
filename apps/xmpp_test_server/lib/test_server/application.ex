defmodule XmppTestServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Port 5222: XMPP standard port
    port = String.to_integer(System.get_env("PORT") || "5222")

    # Child processes to supervise
    children = [
      {Task.Supervisor, name: XmppTestServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> XmppTestServer.accept(port) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XmppTestServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
