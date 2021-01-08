defmodule XmppTestServer.UserConnection do
  @moduledoc ~S"""
  Module for a connection associated to a user.
  """

  # :temporary: supervisor won't restart process on crash
  use GenServer, restart: :temporary

  # Client

  @doc """
  Starts a new process (connnection on the 'socket').
  """
  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  @doc """
  Print a message to the client depending on the state of the UserConnection.
  """
  def serve(pid) do
    GenServer.call(pid, {:serve}, :infinity)
  end

  # Server-API

  @impl true
  def init(socket) do
    {:ok, %{socket: socket}}
  end

  @impl true
  def handle_call({:serve}, _from, state) do
    do_serve(state)
  end

  defp do_serve(state) do
    socket = state.socket
    case Map.get(state, :username) do
      nil ->
        {:ok, state} = login_prompt(socket, state)
        do_serve(state)
      _username -> :not_implemented
    end
  end

  defp login_prompt(socket, state) do
    :ok = :gen_tcp.send(socket, "Login or register:\nUsername: ")
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        # TODO validate username
        if (XmppTestServer.Users.is_registered?(:users, data)) do
          pwd = pwd_prompt(socket)
          :ok = XmppTestServer.Users.login(:users, data, pwd)
          {:ok, Map.put(state, :username, data)}
        else
          register_prompt(socket, data, state)
        end
      {:error, _} ->
        :ok = :gen_tcp.close(socket)
        GenServer.stop(self(), :socket_closed)
    end
  end

  defp pwd_prompt(socket) do
    :ok = :gen_tcp.send(socket, "Password: ")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    # TODO validate pwd
    data
  end

  defp register_prompt(socket, username, state) do
    :ok = :gen_tcp.send(
      socket,
      "The username #{username} does not exist in the database. Do you want "<>
        "to register a new account under that name?(yes/no)"
    )
    {:ok, data} = :gen_tcp.recv(socket, 0)
    if(data == "yes") do
      pwd = pwd_prompt(socket)
      if(pwd == pwd_prompt(socket)) do
        :ok = XmppTestServer.Users.register(:users, username, pwd)
        :ok = XmppTestServer.Users.login(:users, username, pwd)
        {:ok, Map.put(state, :username, username)}
      else
        :ok = :gen_tcp.send(socket, "Password repetition failed. Pease try again.")
        login_prompt(socket, state)
      end
    else
      login_prompt(socket, state)
    end
  end
end
