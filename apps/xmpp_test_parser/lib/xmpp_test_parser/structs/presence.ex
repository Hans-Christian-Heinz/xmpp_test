defmodule XmppTestParser.Structs.Presence do
  @enforce_keys [:from, :to]
  defstruct [:from, :to, :type, :id, :show, :status]
end
