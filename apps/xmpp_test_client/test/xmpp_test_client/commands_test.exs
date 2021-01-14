defmodule XmppTestClient.CommandsTest do
  use ExUnit.Case, async: false
  import Mock
  alias XmppTestClient.Commands, as: Commands

  test "available users" do
    assert Commands.generate_stanza("available users") == {:ok, ~s|<iq type="get"><query/></iq>|}
  end

  test "logout" do
    assert Commands.generate_stanza("logout") == {:ok, ~s|<presence type="unavailable"/>|}
  end

  test "invalid command" do
    assert Commands.generate_stanza("invalid") == {:error, :invalid_command}
  end

  test_with_mock "message", IO, [gets: &mock_gets/1] do
    assert Commands.generate_stanza("send message") ==
      {:ok, ~s|<message to="m.mustermann"><body>test message</body></message>|}
  end

  defp mock_gets(message) do
    case message do
      "Send message to whom? " -> "m.mustermann\n"
      "\nMessage content:\n" -> "     test message   \n"
    end
  end
end
