defmodule DisableAbleServer do
  @moduledoc """
  A very GenServer that will abort to start, if a given config value is given.
  See the tests to find out the values.
  """

  use GenServer

  def init(_) do
    raise "TODO: Implement me!"
  end

end