defmodule SimpleServerTest do
  use ExUnit.Case

  test "start server with value and fetch that value" do
    value = :rand.uniform(9999)
    {:ok, server} = SimpleServer.start_link(value)
    fetched_value = SimpleServer.get(server)
    SimpleServer.stop(server)
    assert value == fetched_value
  end

  test "giving the server a name" do
    value = :rand.uniform(9999)
    name = "server_#{value}" |> String.to_atom
    {:ok, _} = SimpleServer.start_link(value, name: name)
    fetched_value = SimpleServer.get(name)
    SimpleServer.stop(name)
    assert value == fetched_value
  end

  test "server should use __MODULE__ as default name." do
    value = :rand.uniform(9999)
    {:ok, _} = SimpleServer.start_link(value)
    fetched_value = SimpleServer.get()
    SimpleServer.stop()
    assert value == fetched_value
  end

end
