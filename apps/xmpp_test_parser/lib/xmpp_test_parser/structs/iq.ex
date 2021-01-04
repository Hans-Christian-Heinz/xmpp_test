defmodule XmppTestParser.Structs.IQ do
  defstruct [:from, :to, :type, :id, :query, :items]
end
