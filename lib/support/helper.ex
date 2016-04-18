defmodule Dispatch.Helper do
  import ExUnit.Assertions
  alias Dispatch.{HashRingSupervisor, Registry}

  @rtype "TestDispatchType"

  def setup_registry() do
    registry_server = Application.get_env(:dispatch, :registry, Registry)
    {:ok, registry_pid} = Registry.start_link()
    if _old_pid = Process.whereis(registry_server) do
      Process.unregister(registry_server)
    end
    Process.register(registry_pid, registry_server)
    {:ok, registry_pid}
  end

  def clear_type(type) do
    if pid = Process.whereis(Module.concat(Dispatch.HashRing, type)) do
      HashRingSupervisor.stop_hash_ring(Dispatch.HashRing, pid)
    end
  end

  def wait_dispatch_ready(node \\ nil) do
    if node do
      assert_receive {:join, _, %{node: ^node, state: :online}}, 5_000
    else
      assert_receive {:join, _, %{node: _, state: :online}}, 5_000
    end
  end

  def get_online_services(type \\ @rtype) do
    registry_server = Application.get_env(:dispatch, :registry, Registry)
    Registry.get_services(registry_server, type)
  end

end
