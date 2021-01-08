defmodule XmppTestServer.UsersTest do
  use ExUnit.Case
  alias XmppTestServer.Users, as: Users

  setup context do
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
    {:ok, _} = start_supervised({Users, name: context.test})

    %{myxql: myxql, users: context.test}
  end

  test "register users", %{myxql: myxql, users: users} do
    {:ok, res} = MyXQL.query(myxql, "SELECT id FROM users WHERE username='mustermann';")
    assert res.rows == []
    assert Users.register(users, "mustermann", "Test1234") == :ok
    {:ok, res} = MyXQL.query(myxql, "SELECT id FROM users WHERE username='mustermann';")
    assert [[_val]] = res.rows
    assert {:error, _msg} = Users.register(users, "mustermann", "Test1234")
  end

  test "delete users", %{myxql: myxql, users: users} do
    assert {:error, :invalid_username} == Users.delete(users, "mustermann", "Test1234")
    Users.register(users, "mustermann", "Test1234")
    assert {:error, :invalid_pwd} == Users.delete(users, "mustermann", "Test12345")
    assert :ok == Users.delete(users, "mustermann", "Test1234")
    {:ok, res} = MyXQL.query(myxql, "SELECT id FROM users WHERE username='mustermann';")
    assert res.rows == []
  end

  test "login users", %{users: users} do
    assert {:error, :invalid_username} == Users.login(users, "mustermann", "Test1234")
    Users.register(users, "mustermann", "Test1234")
    assert {:error, :invalid_pwd} == Users.login(users, "mustermann", "Test12345")
    assert :ok = Users.login(users, "mustermann", "Test1234")
    assert {:error, {:already_registered, _}} = Users.login(users, "mustermann", "Test1234")
  end

  test "logout users", %{users: users} do
    assert {:error, :not_logged_in} == Users.logout(users, "mustermann")
    Users.register(users, "mustermann", "Test1234")
    Users.login(users, "mustermann", "Test1234")
    assert :ok == Users.logout(users, "mustermann")
    assert {:error, :not_logged_in} == Users.logout(users, "mustermann")
  end

  test "is_registered", %{users: users} do
    assert false == Users.is_registered?(users, "mustermann")
    Users.register(users, "mustermann", "Test1234")
    assert true == Users.is_registered?(users, "mustermann")
    Users.delete(users, "mustermann", "Test1234")
    assert false == Users.is_registered?(users, "mustermann")
  end
end
