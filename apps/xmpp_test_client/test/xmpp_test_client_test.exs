defmodule XmppTestClientTest do
  use ExUnit.Case, async: true
  import Mock

  # TODO: figure out what to test in this module and how to test it.
  #       perhaps make some of the private functions public or put them in another module?
  # setup do
  #   Application.stop :xmpp_test_server
  #   Application.start :xmpp_test_server
  # end
  #
  # setup do
  #   server = Application.get_env(:xmpp_test_client, :XMPP_SERVER, "127.0.0.1")
  #   port = Application.get_env(:xmpp_test_client, :XMPP_PORT, "5222")
  #   %{server: server, port: port, packet: 2}
  # end
  #
  # # I don't really know how to test this on the client side
  # # Should have connection with server and logic in different methods
  # test "connect", %{server: server, port: port, packet: packet} do
  #   with_mock IO, [puts: &mock_puts/1, gets: &mock_gets/1] do
  #     XmppTestClient.connect(server, port, packet)
  #     assert called IO.puts "Hello m.mustermann.\n"
  #   end
  # end
  #
  # defp mock_puts(_) do
  #   nil
  # end
  #
  # defp mock_gets(msg) do
  #   case msg do
  #     "Login or register:\nUsername: " -> "m.mustermann"
  #     "Password: " -> "Test1234!"
  #     _ -> "y"
  #   end
  # end
end
