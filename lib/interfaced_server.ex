defmodule InterfacedServer do
  @moduledoc """
  A GenServer with public functions that hide internal messages.
  Messages will be transformed before returning them.
  """

  use GenServer

  def init(_) do
    # Using a list to collect tasks.
    {:ok, []}
  end

  def trigger_task(server, tasks) when is_list(tasks) do
    # Using primitive function.
    Enum.each(tasks, fn task ->
      trigger_task(server, task)
    end)
  end

  def trigger_task(server, task) when is_binary(task) do
    GenServer.cast(server, {:task, task})
  end

  def stats(server) do
    {length, last} = GenServer.call(server, :stats)
    # Returning a keyword list to provide extendable public interface.
    [length: length, last: last]
  end

  # --- Internal Message Passing stuff ---

  def handle_cast({:task, task}, tasks) do
    {:noreply, [task|tasks]}
  end

  def handle_call(:stats, _from, [h|_] = tasks) do
    # Using a tuple here as internal implementation.
    {:reply, {length(tasks), h}, tasks}
  end

end