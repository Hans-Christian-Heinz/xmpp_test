defmodule XmppTestServer.UserConnectionTest do
  use ExUnit.Case, async: true

  setup do
    Application.stop(:xmpp_test_server)
    Application.start(:xmpp_test_server)
  end

  setup do
    opts = [:binary, packet: 2, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 5222, opts)
    %{socket: socket}
  end

  test "user connection", %{socket: socket} do
#    assert {:ok, "Login or register:\nUsername: "} == :gen_tcp.recv(socket, 0, 1000)
#    :gen_tcp.send(socket, "m.mustermann")
#    assert {:ok, "The username m.mustermann does not exist in the database. Do you want to register a new account under that name?(yes/no)"}
#      == :gen_tcp.recv(socket, 0, 2000)
#    :gen_tcp.send(socket, "n")
#    assert {:ok, "Login or register:\nUsername: "} == :gen_tcp.recv(socket, 0, 1000)
#    :gen_tcp.send, "m.mustermann"
    prompt_answer(socket, "Login or register:\nUsername: ", "m.mustermann")
  end

  defp prompt_answer(socket, prompt, answer) do
    assert{:ok, prompt} == :gen_tcp.recv(socket, 0, 1000)
    :gen_tcp.send(socket, answer)
  end
end
