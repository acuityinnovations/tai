defmodule Tai.Exchanges.AdaptersSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    exchanges = Tai.Exchanges.Config.all()
    specs = adapter_specs(exchanges)
    {:ok, tuple} = Supervisor.init(specs, strategy: :one_for_one)
    hydrate(exchanges)

    {:ok, tuple}
  end

  defp adapter_specs(exchanges) do
    Enum.map(
      exchanges,
      &Supervisor.child_spec({&1.supervisor, &1}, id: &1.id)
    )
  end

  defp hydrate(exchanges) do
    Enum.each(
      exchanges,
      fn exchange ->
        nil
        # IO.puts("---- SHOULD hydrate exchange adapter: #{inspect(exchange.id)}")
        # IO.puts("---- Process.get_keys #{inspect(Process.get_keys())}")
        # IO.puts("---- whereis exchange adapter: #{inspect(Process.whereis(name))}")
        # :ok = Tai.Exchanges.AdapterSupervisor.hydrate(exchange.id)
      end
    )
  end
end
