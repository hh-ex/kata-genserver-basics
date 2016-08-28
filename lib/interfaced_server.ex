defmodule InterfacedServer do
  @moduledoc """
  A GenServer with public functions that hide internal messages.
  Messages will be transformed before returning them.
  """

  use GenServer

  def init(_) do
    raise "TODO: Implement me!"
  end

  def trigger_task(server, tasks) when is_list(tasks) do
    raise "TODO: Implement me!"
  end

  def trigger_task(server, task) when is_binary(task) do
    raise "TODO: Implement me!"
  end

  def stats(server) do
    raise "TODO: Implement me!"
  end

  # --- Internal Message Passing stuff ---

  def handle_cast(_, _) do
    raise "TODO: Implement me!"
  end

  def handle_call(_, _, _) do
    raise "TODO: Implement me!"
  end

end