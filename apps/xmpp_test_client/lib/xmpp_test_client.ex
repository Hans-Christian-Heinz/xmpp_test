defmodule XmppTestClient do
  alias XmppTestParser.Structs.Presence, as: Presence
  alias XmppTestParser.Structs.Message, as: Message
  alias XmppTestParser.Structs.IQ, as: IQ
  alias XmppTestParser.Structs.Query, as: Query
  alias XmppTestParser.Structs.Item, as: Item

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

  # Dialog between client and server.
  defp dialog(socket) do
    # for some reason I get a compile-error when trying to use default args
    case receive(socket, 1000, "") do
      {:ok, data} ->
        input = IO.gets(data)
        :gen_tcp.send(socket, input)
        dialog(socket)
      {:complete, data} ->
        IO.puts(data <> "\n")
        # start a new task to listen for messages
        {:ok, pid} = Task.Supervisor.start_child(XmppTestClient.TaskSupervisor, fn -> print_response(socket) end)
        ui(socket)
    end
  end

  # Receive available data-packets from the server
  defp receive(socket, timeout \\ 1000, data \\ "") do
    case :gen_tcp.recv(socket, 0, timeout) do
      {:ok, "auth_complete"} -> {:complete, data}
      {:ok, more_data} -> receive(socket, 50, data <> more_data)
      {:error, _} -> {:ok, data}
    end
  end

  # Show a UI on the command line
  defp ui(socket) do
    IO.puts "\nAvailable commands:"
    IO.puts "  - available users"
    IO.puts "    list all available users"
    IO.puts "  - send message"
    IO.puts "    send a message to another user"
    IO.puts "  - logout"
    IO.puts "    logout of the application\n"
    case IO.gets("") |> String.trim |> XmppTestClient.Commands.generate_stanza do
      {:ok, stanza} ->
        :gen_tcp.send(socket, stanza)
        ui(socket)
      {:error, :invalid_command} ->
        IO.puts "Invalid command. Please try again."
        ui(socket)
    end
  end

  defp print_response(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    {:ok, stanza} = XmppTestParser.parse(data)
    print_help(stanza)
    print_response(socket)
  end

  defp print_help(%IQ{} = iq) do
    # TODO differentiate between different types of query
    # proble: name is charlist not string
    iq.query.items |> Enum.map(fn i -> IO.puts(to_string(i.name) <> "\n") end)
  end

  defp print_help(%Message{} = msg) do
    IO.puts "Incoming message from #{to_string(msg.from)}:"
    IO.puts to_string(msg.body) <> "\n"
  end

  defp print_help(_) do
    :not_implemented
  end
end
