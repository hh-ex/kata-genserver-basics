defmodule SimpleServer do
  @moduledoc """
  A very simple GenServer.
  It can hold a value and can be registered using a given name or defaulting to __MODULE__.

  """

  use GenServer
  # Will define defaults for:
  # * init(args)
  # * handle_call(msg, from, state)
  # * handle_info(msg, state)
  # * handle_cast(msg, state)
  # * terminate(reason, state)
  # * code_change(old, state, extra)
  # See: http://elixir-lang.org/docs/stable/elixir/GenServer.html

  # Constructor for this server.
  def start_link(given_value, opts \\ []) do
    # Put module name under :name in case it is not set yet.
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, given_value, opts)
  end

  def init(given_value) do
    {:ok, given_value}
  end

  def get(server \\ __MODULE__) do
    GenServer.call(server, :get)
  end

  def stop(server \\ __MODULE__) do
    GenServer.stop(server)
  end

  # --- Internal Message Passing stuff ---

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

end