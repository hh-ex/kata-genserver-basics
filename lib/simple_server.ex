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
    raise "TODO: Implement me!"
  end

  def init(_) do
    raise "TODO: Implement me!"
  end

  def get(_) do
    raise "TODO: Implement me!"
  end

  def stop(_) do
    raise "TODO: Implement me!"
  end

  # --- Internal Message Passing stuff ---

  def handle_call(_, _, _) do
    raise "TODO: Implement me!"
  end

end