defmodule XmppTestParser.Structs.Message do
  @enforce_keys [:from, :to]
  defstruct [:from, :to, :id, :type, :body]
end
