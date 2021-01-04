defmodule XmppTestServer do
  @moduledoc """
  Module for an Xmpp-Server: accept-function is called on starting the application.
  Server accepts TCP-connections on a port (Env-variable, default: 5222) and handles them.
  """

  require Logger

  @doc """
  Listens for TCP-connections on the 'port'
  """
  def accept(port) do
    # The options below mean:
    #
    # 1. ':binary' - receives data as binaries (instead of lists)
    # 2. 'packet: 4' - data received as packet with 4 byte header,
    #                  that specifies the number of bytes in the packet (max: 2Gb)
    # 3. 'active: false' - blocks on ':gen_tcp.recv/2' until data is available
    # 4. 'reuseaddr: true' - allows to reuse the address if the listener crashes
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: 2, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # pass a connection to a new supervised task
    # Task: process meant to execute one action many times
    {:ok, pid} = Task.Supervisor.start_child(XmppTestServer.TaskSupervisor, fn -> serve(client) end)
    # assign a new controlling process pid to client
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    # TODO implement XmppParser and use it here
    # second argument: number of bytes to be returned; 0 means read all
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        IO.puts data
        serve socket
      {:error, _} -> :gen_tcp.close(socket)
    end
  end
end
