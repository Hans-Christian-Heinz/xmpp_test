defmodule XmppTestClient do
  @moduledoc ~S"""
  Documentation for XmppTestClient.

  ## Functions
  + connect/3
  """

  @doc """
  Connect to an XmppTestServer 'server' on port 'port' and start a communication-loop.
  """
  def connect(server, port, packet \\ 2) do
    opts = [:binary, packet: packet, active: false]
    {:ok, socket} = :gen_tcp.connect(server, port, opts)
    dialog(socket)
  end

  defp dialog(socket) do
    # problem: two packets without response
    # {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    # for some reason I get a compile-error when trying to use default args
    {:ok, data} = receive(socket, 1000, "")
    input = IO.gets(data)
    :gen_tcp.send(socket, input)
    dialog(socket)
  end

  defp receive(socket, timeout \\ 1000, data \\ "") do
    case :gen_tcp.recv(socket, 0, timeout) do
      {:ok, more_data} -> receive(socket, 50, data <> more_data)
      {:error, _} -> {:ok, data}
    end
  end
end
