defmodule XmppTestServer.ProcessStanzas do
  alias XmppTestParser.Structs.Presence, as: Presence
  alias XmppTestParser.Structs.Message, as: Message
  alias XmppTestParser.Structs.IQ, as: IQ
  alias XmppTestParser.Structs.Query, as: Query
  alias XmppTestParser.Structs.Item, as: Item

  @moduledoc ~S"""
  Module to process xmpp-stanzas received from a client.

  ## Functions:
  + process/2
  """

  @doc """
  Process a stanza and send it or it's responses th their targets.
  """
  def process(state, %Presence{} = presence) do
    if(presence.type == 'unavailable' || presence.type == "unavailable") do
      username = state.username
      :ok = XmppTestServer.Users.logout(:users, username)
      # {:ok, "</stream:stream>"}
      send_responses([{state.socket, "</stream:stream>"}])
    end
  end

  def process(state, %IQ{} = _iq) do
    # so far only the query that asks for all available users
    # username = state.username
    # Registry.keys/2 returns the keys, under which one process is registered.
    # Registry.select/2 returns a result, that depends on the second parameter. (see. https://hexdocs.pm/elixir/Registry.html#select/2)
    # Registry.keys(Users.Registry, Process.whereis(:users))
    users = Registry.select(Users.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}]) |> Enum.sort |> Enum.map(&(%Item{name: &1}))
    # users = Registry.keys(Users.Registry, Process.whereis(:users)) |> Enum.sort |> Enum.map(&(%Item{name: &1}))
    iq = %IQ{type: "result", query: %Query{items: users}}
    # XmppTestParser.to_xml(iq)
    send_responses([{state.socket, XmppTestParser.to_xml!(iq)}])
  end

  # def process_old(state, %Message{} = msg) do
  #   users =  Registry.select(Users.Registry, [{{:"$1", :_, :_}, [], [:"$1"]}])
  #   # users = Registry.keys(Users.Registry, Process.whereis(:users))
  #   msg = %{msg | from: state.username}
  #   case Enum.find_index(users, fn u -> u == to_string(msg.to) end) do
  #     nil ->
  #       %Message{from: "server", body: "The user #{msg.to} is not available. Your message was not sent."} |> XmppTestParser.to_xml
  #     # TODO
  #     _ ->
  #       [{_pid, socket}] = Registry.lookup(Users.Registry, to_string(msg.to))
  #       msg |> XmppTestParser.to_xml! |> sendMsg(socket)
  #       %Message{from: "server", body: "Message sent."} |> XmppTestParser.to_xml
  #   end
  # end

  def process(state, %Message{} = msg) do
    case Registry.select(Users.Registry, [{{:"$1", :_, :"$2"}, [{:==, :"$1", to_string(msg.to)}], [:"$2"]}]) do
      [] ->
        send_responses([{state.socket, %Message{from: "server", body: "The user #{msg.to} is not available. Your message was not sent."} |> XmppTestParser.to_xml!}])
      [socket] ->
        {:ok, msg1} = %Message{from: "server", body: "Message sent."} |> XmppTestParser.to_xml
        {:ok, msg2} = %{msg | from: state.username} |> XmppTestParser.to_xml
        send_responses([{state.socket, msg1}, {socket, msg2}])
#        %{msg | from: state.username} |> XmppTestParser.to_xml! |> sendMsg(socket)
#        %Message{from: "server", body: "Message sent."} |> XmppTestParser.to_xml
      _ ->
        {:error, :invalid_target}
    end
  end

  def process(_state, _) do
    {:error, :invalid_stanza}
  end

  # defp sendMsg(msg, socket) do
  #   :gen_tcp.send(socket, msg)
  # end

  defp send_responses(responses) when is_list(responses) do
    (for resp <- responses, do: :gen_tcp.send(elem(resp,0), elem(resp, 1)))
      |> Enum.all?(&(&1 === :ok))
      |> if(do: :ok, else: :error)
  end
end
