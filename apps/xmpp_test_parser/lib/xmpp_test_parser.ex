defmodule XmppTestParser do
  @moduledoc """
  Documentation for `XmppTestParser`.
  Module receives binaries and returns xmpp-structs.
  """

  @doc """
  Parse the 'string_to_parse' and return a corresponding struct (message, iq, presence)
  """
  def parse(string_to_parse) do
    # TODO parse the string
    # pattern matching? (iq, message, presence)
    :not_implemented
  end
end
