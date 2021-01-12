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
  Process a stanza.
  """
  def process(state, %Presence{} = presence) do
    if(presence.type == 'unavailable' || presence.type == "unavailable") do
      username = state.username
      IO.puts username
      XmppTestServer.Users.logout(:users, username)
    end
  end

  def process(_state, %IQ{} = _iq) do
    # so far only the query that asks for all available users
    # username = state.username
    users = Registry.keys(Users.Registry, Process.whereis(:users)) |> Enum.sort |> Enum.map(&(%Item{name: &1}))
    iq = %IQ{type: "result", query: %Query{items: users}}
    XmppTestParser.to_xml(iq)
  end

  def process(state, %Message{} = msg) do
    users = Registry.keys(Users.Registry, Process.whereis(:users))
    msg = %{msg | from: state.username}
    case Enum.find_index(users, fn u -> u == to_string(msg.to) end) do
      nil ->
        %Message{from: "server", body: "The user #{msg.to} is not available. Your message was not sent."} |> XmppTestParser.to_xml
      # TODO
      _ ->
        [{_pid, socket}] = Registry.lookup(Users.Registry, to_string(msg.to))
        msg |> XmppTestParser.to_xml! |> sendMsg(socket)
        %Message{from: "server", body: "Message sent."} |> XmppTestParser.to_xml
    end
  end

  def process(_state, _) do
    {:error, :invalid_stanza}
  end

  defp sendMsg(msg, socket) do
    :gen_tcp.send(socket, msg)
  end
end
