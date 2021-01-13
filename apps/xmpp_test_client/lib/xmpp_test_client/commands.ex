defmodule XmppTestClient.Commands do
  @moduledoc ~S"""
  Module for generating xmpp-stanzas from commands (see. XmppTestClient.ui/1)

  ## Functions
  + generate_stanza/1
  """

  @doc ~S"""
  Generates an xmpp-stanza to send to the server from a user-command.
  Valid commands:
  + available users
  + send message
  + logout

  ## Examples
    iex> XmppTestClient.Commands.generate_stanza("available users")
    {:ok, "<iq type=\"get\"><query/></iq>"}

    iex> XmppTestClient.Commands.generate_stanza("logout")
    {:ok, "<presence type=\"unavailable\"/>"}

    iex> XmppTestClient.Commands.generate_stanza("invalid command")
    {:error, :invalid_command}
  """
  def generate_stanza(command) when command == "available users" do
    # TODO specify which query (so far only one is used)
    {:ok, ~s|<iq type="get"><query/></iq>|}
  end

  def generate_stanza(command) when command == "send message" do
    to = IO.gets("Send message to whom? ") |> String.trim
    body = IO.gets("\nMessage content:\n") |> String.trim
    msg = ~s|<message to="#{to}"><body>#{body}</body></message>|
    # TODO: check length of msg, cut off from the body if necessary
    {:ok, msg}
  end

  def generate_stanza(command) when command == "logout" do
    {:ok, ~s|<presence type="unavailable"/>|}
  end

  def generate_stanza(_command) do
    {:error, :invalid_command}
  end
end
