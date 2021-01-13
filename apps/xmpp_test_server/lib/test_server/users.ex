defmodule XmppTestServer.Users do
  @moduledoc ~S"""
  Module to retrieve user information.

  ## Methods
  + start_link/1
  + register/3
  + delete/3
  + login/3
  + logout/2
  + is_registered?/2
  """

  use GenServer

  # Client

  @doc """
  On startup: create the users-table, if it does not already exist.
  """
  def start_link(opts) do
    {:ok, name} = Keyword.fetch(opts, :name)
    GenServer.start_link(__MODULE__, name, opts)
  end

  @doc """
  Register a new user with username 'username' and password 'pwd'.
  """
  def register(pid, username, pwd) do
    GenServer.call(pid, {:register, username: username, pwd: pwd})
  end

  @doc """
  Delete a given user with username 'username' and password 'pwd'.
  """
  def delete(pid, username, pwd) do
    GenServer.call(pid, {:delete, username: username, pwd: pwd})
  end

  @doc """
  Login as a given user with username 'username' and password 'pwd' on the socket 'socket'.
  'socket' can be nil, because the variable is only used to associate it to the process and user in the registry.
  """
  def login(pid, username, pwd, socket \\ nil) do
    GenServer.call(pid, {:login, username: username, pwd: pwd, socket: socket})
  end

  @doc """
  Logout the given user with username 'username'.
  """
  def logout(pid, username) do
    GenServer.call(pid, {:logout, username: username})
  end

  @doc """
  Check if a user with username 'username' is registered in the database.
  """
  def is_registered?(pid, username) do
    {username, GenServer.call(pid, {:is_registered?, username: username})}
  end

  @doc """
  Check if a user with the username 'username' is already logged in.
  """
  def is_logged_in?(pid, username) do
    GenServer.call(pid, {:is_logged_in?, username: username})
  end

  # Callbacks

  @impl true
  def init(state) do
    # on startup: create the users-table, if it does not exist.
    {:ok, _} = MyXQL.query(:myxql, "CREATE TABLE IF NOT EXISTS users(
      id BIGINT PRIMARY KEY AUTO_INCREMENT,
      username VARCHAR(255) NOT NULL UNIQUE,
      pwd VARCHAR(255) NOT NULL
    )")

    {:ok, state}
  end

  @impl true
  def handle_call({:register, username: username, pwd: pwd}, _from, state) do
    query = "INSERT INTO users (username, pwd) VALUES('#{username}', '#{hash_pwd(pwd)}');"
    case MyXQL.query(:myxql, query) do
      {:ok, _} -> {:reply, :ok, state}
      # perhaps {:error, e} as reply?
      {:error, %MyXQL.Error{} = e} -> {:reply, {:error, e.message}, state}
      # {:error, e} -> {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call({:delete, username: username, pwd: pwd}, _from, state) do
    case check_pwd(username, pwd) do
      true ->
        query = "DELETE FROM users WHERE username='#{username}';"
        case MyXQL.query(:myxql, query) do
          {:ok, _} -> {:reply, :ok, state}
          {:error, %MyXQL.Error{} = e} -> {:reply, {:error, e.message}, state}
          # {:error, e} -> {:reply, {:error, e}, state}
        end
      {:error, e} ->
        {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call({:login, username: username, pwd: pwd, socket: socket}, _from, state) do
    case check_pwd(username, pwd) do
      true ->
        case Registry.register(Users.Registry, username, socket) do
          {:ok, _} -> {:reply, :ok, state}
          {:error, e} -> {:reply, {:error, e}, state}
        end
      {:error, e} ->
        {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call({:logout, username: username}, _from, state) do
    if (logged_in?(username)) do
      :ok = Registry.unregister(Users.Registry, username)
      {:reply, :ok, state}
    else
      {:reply, {:error, :not_logged_in}, state}
    end
  end

  @impl true
  def handle_call({:is_registered?, username: username}, _from, state) do
    query = "SELECT id FROM users WHERE username='#{username}';"
    case MyXQL.query(:myxql, query) do
      {:ok, res} -> {:reply, res.rows != [], state}
      {:error, e} -> {:reply, {:error, e}, state}
    end
  end

  @impl true
  def handle_call({:is_logged_in?, username: username}, _from, state) do
    if(logged_in?(username)) do
      {:reply, {:is_logged_in?, username, true}, state}
    else
      {:reply, {:is_logged_in?, username, false}, state}
    end
  end

  defp logged_in?(username) do
    Registry.lookup(Users.Registry, username) != []
  end

  defp check_pwd(username, pwd) do
    query = "SELECT pwd FROM users WHERE username='#{username}';"
    {:ok, res} = MyXQL.query(:myxql, query)
    # valid result: exactly one value (one row and one column)
    case res.rows do
      [[val]] ->
        if(Bcrypt.verify_pass(pwd, val)) do
        # if(val == hash_pwd(pwd)) do
          true
        else
          {:error, :invalid_pwd}
        end
      _ ->
        {:error, :invalid_username}
    end
  end

  defp hash_pwd(pwd) do
    Bcrypt.add_hash(pwd).password_hash
  end
end
