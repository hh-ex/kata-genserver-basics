defmodule DisableAbleServer do
  @moduledoc """
  A very GenServer that will abort to start, if a given config value is given.
  See the tests to find out the values.
  """

  use GenServer

  def init([enabled: true]) do
    {:ok, nil}
  end

  def init([enabled: false]) do
    :ignore
  end

  def init([timeout: true]) do
    :timer.sleep(100)
  end

end