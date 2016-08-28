defmodule InterfacedServerTest do
  use ExUnit.Case

  test "trigger single task" do
    {:ok, server} = GenServer.start_link(InterfacedServer, [])
    :ok = InterfacedServer.trigger_task(server, "a")
    :ok = InterfacedServer.trigger_task(server, ["b", "c"])
    stats = InterfacedServer.stats(server)
    assert stats == [length: 3, last: "c"]
  end

  test "internal messages" do
    InterfacedServer.trigger_task(self, "a")
    InterfacedServer.trigger_task(self, ["b", "c"])
    assert_received {:"$gen_cast", {:task, "a"}}
    assert_received {:"$gen_cast", {:task, "b"}}
    assert_received {:"$gen_cast", {:task, "c"}}
  end

end
