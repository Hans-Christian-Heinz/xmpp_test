defmodule XmppTestServer.UserConnectionTest do
  use ExUnit.Case, async: true

  setup do
    host = Application.get_env(:xmpp_test_server, :MYSQL_HOST, "127.0.0.1")
    db_name = Application.get_env(:xmpp_test_server, :MYSQL_DB, "xmpp_test")
    db_username = Application.get_env(:xmpp_test_server, :MYSQL_USER, "xmpp")
    db_pwd = Application.get_env(:xmpp_test_server, :MYSQL_PWD, "Test1234")
    {:ok, myxql} = start_supervised({
      MyXQL,
      hostname: host,
      username: db_username,
      password: db_pwd,
      database: db_name
    })
    # the table is created newly for every test
    {:ok, _} = MyXQL.query(myxql, "DROP TABLE IF EXISTS users;")
    :ok
  end

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
    prompt_answer(socket, "Login or register:\nUsername: ", "m.mustermann")
    prompt_answer(socket, "The username m.mustermann does not exist in the database. Do you want to register a new account under that name?(yes/no)", "n")
    prompt_answer(socket, "Login or register:\nUsername: ", "m.mustermann")
    prompt_answer(socket, "The username m.mustermann does not exist in the database. Do you want to register a new account under that name?(yes/no)", "y")
    prompt_answer(socket, "Password: ", "Test1234")
    prompt_answer(socket, "The password must contain a symbol.\n\n", "")
    prompt_answer(socket, "Login or register:\nUsername: ", "m.mustermann")
    prompt_answer(socket, "The username m.mustermann does not exist in the database. Do you want to register a new account under that name?(yes/no)", "y")
    prompt_answer(socket, "Password: ", "Test1234!")
    prompt_answer(socket, "Password: ", "Test1234$")
    prompt_answer(socket, "Password repetition failed. Please try again.\n\n", "")
    prompt_answer(socket, "Login or register:\nUsername: ", "m.mustermann")
    prompt_answer(socket, "The username m.mustermann does not exist in the database. Do you want to register a new account under that name?(yes/no)", "y")
    prompt_answer(socket, "Password: ", "Test1234!")
    prompt_answer(socket, "Password: ", "Test1234!")
    prompt_answer(socket, "Hello m.mustermann.", "")
  end

  defp prompt_answer(socket, prompt, answer) do
    assert{:ok, prompt} == :gen_tcp.recv(socket, 0, 1000)
    if(answer |> String.trim |> String.length > 0, do: :gen_tcp.send(socket, answer))
  end
end
