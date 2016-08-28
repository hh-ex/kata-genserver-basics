defmodule DisableAbleServerTest do
  use ExUnit.Case

  test "start enabled server" do
    {:ok, server} = GenServer.start_link(DisableAbleServer, enabled: true)
    assert is_pid(server)
  end

  test "start disabled server" do
    assert :ignore == GenServer.start_link(DisableAbleServer, enabled: false)
  end

  test "start timeouting server" do
    assert {:error, :timeout} == GenServer.start_link(DisableAbleServer, [timeout: true], [timeout: 90])
  end

end
