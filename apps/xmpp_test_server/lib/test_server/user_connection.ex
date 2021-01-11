defmodule XmppTestServer.UserConnection do
  @moduledoc ~S"""
  Module for a connection associated to a user.
  """

  @doc """
  Print a message to the client depending on the 'state' of the UserConnection.
  State mostly refers to the question, whether a username is associated with this
  connection. (Whether a user is logged in.)
  """
  def serve(state) do
    socket = state.socket
    case Map.get(state, :username) do
      nil ->
        {:ok, state} = login_prompt(socket, state)
        serve(state)
      username ->
        :gen_tcp.send(socket, "Hello #{username}.")
    end
  end

  # login_prompt: useris prompted to login or register.
  defp login_prompt(socket, state) do
    # :ok = :gen_tcp.send(socket, "Login or register:\nUsername: ")
    :gen_tcp.send(socket, "Login or register:\nUsername: ")

    with {:ok, data} <- :gen_tcp.recv(socket, 0),
         {:ok, username} <- XmppTestServer.InputValidator.validate(data, [type: :username]),
         {_, true} <- XmppTestServer.Users.is_registered?(:users, username),
         {:ok, pwd} <- pwd_prompt(socket),
         :ok <- XmppTestServer.Users.login(:users, username, pwd)
    do
      {:ok, Map.put(state, :username, username)}
    else
      {username, false} ->
        register_prompt(socket, username, state)
      {:error, msg} when is_binary(msg) ->
        :gen_tcp.send(socket, msg <> "\n\n")
        {:ok, state}
      {:error, :invalid_pwd} ->
        :gen_tcp.send(socket, "The entered password is incorrect.\n\n")
        {:ok, state}
      {:error, :invalid_username} ->
        :gen_tcp.send(socket, "The entered username is incorrect.\n\n")
        {:ok, state}
      _ ->
        :gen_tcp.close(socket)
        Process.exit(self(), :socket_closed)
    end


#    case :gen_tcp.recv(socket, 0) do
#      {:ok, data} ->
#        {:ok, usernamme} = XmppTestServer.Inputvalidator.validate(data, [type: :username])
#        if (XmppTestServer.Users.is_registered?(:users, username)) do
#          pwd = pwd_prompt(socket)
#          :ok = XmppTestServer.Users.login(:users, data, pwd)
#          {:ok, Map.put(state, :username, data)}
#        else
#          register_prompt(socket, data, state)
#        end
#        {:ok, state}
#      {:error, e} ->
#        IO.puts("error")
#        IO.inspect e
#        :ok = :gen_tcp.close(socket)
#        GenServer.stop(self(), :socket_closed)
#    end
  end

  defp pwd_prompt(socket) do
    :gen_tcp.send(socket, "Password: ")
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data |> String.trim |> XmppTestServer.InputValidator.validate([type: :pwd])
      {:error, e} -> {:error, e}
    end
  end

  defp register_prompt(socket, username, state) do
    :ok = :gen_tcp.send(
      socket,
      "The username #{username} does not exist in the database. Do you want "<>
        "to register a new account under that name?(yes/no)"
    )

    {:ok, data} = :gen_tcp.recv(socket, 0)
    if(String.trim(data) =~ ~r"yes|y") do

      with {:ok, pwd} <- pwd_prompt(socket),
           {:ok, pwd_rep} <- pwd_prompt(socket),
           :ok <- if(pwd == pwd_rep, do: :ok, else: {:error, "Password  repetition failed. Please try again."}),
           :ok <- XmppTestServer.Users.register(:users, username, pwd),
           :ok <- XmppTestServer.Users.login(:users, username, pwd)
      do
        {:ok, Map.put(state, :username, username)}
      else
        {:error, msg} when is_binary(msg) ->
          :gen_tcp.send(socket, msg <> "\n\n")
          {:ok, state}
        false ->
          :ok = :gen_tcp.send(socket, "Password repetition failed. Pease try again.")
          {:ok, state}
        _ ->
          :gen_tcp.close(socket)
          Process.exit(self(), :socket_closed)
      end


#      {:ok, pwd} = pwd_prompt(socket)
#      if(pwd == pwd_prompt(socket)) do
#        :ok = XmppTestServer.Users.register(:users, username, pwd)
#        :ok = XmppTestServer.Users.login(:users, username, pwd)
#        {:ok, Map.put(state, :username, username)}
#      else
#        :ok = :gen_tcp.send(socket, "Password repetition failed. Pease try again.")
#        {:ok, state}
#      end
    else
      {:ok, state}
    end
  end
end
