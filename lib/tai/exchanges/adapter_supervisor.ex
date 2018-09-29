defmodule Tai.Exchanges.AdapterSupervisor do
  @callback hydrate_products() :: atom
  @callback hydrate_fees() :: atom
  @callback account() :: atom

  defmacro __using__(_) do
    quote location: :keep do
      use DynamicSupervisor

      @behaviour Tai.Exchanges.AdapterSupervisor
      @type exchange_config :: Tai.Exchanges.Config.t()

      @spec start_link(config :: exchange_config) :: Supervisor.on_start()
      def start_link(%Tai.Exchanges.Config{} = config) do
        name = Tai.Exchanges.AdapterSupervisor.name(config.id)
        DynamicSupervisor.start_link(__MODULE__, config, name: name)
      end

      @impl true
      def init(config) do
        # children = [
        #   {Tai.Exchanges.AccountsSupervisor,
        #    [adapter: account(), exchange_id: config.id, accounts: config.accounts]}
        #   {hydrate_products(), [exchange_id: config.id, whitelist_query: config.products]},
        #   {hydrate_fees(), [exchange_id: config.id, accounts: config.accounts]},
        #   {Tai.Exchanges.HydrateAssetBalances,
        #    [exchange_id: config.id, accounts: config.accounts]}
        # ]

        # Supervisor.init(children, strategy: :one_for_one)

        # spec = {MyWorker, foo: foo, bar: bar, baz: baz}
        # DynamicSupervisor.start_child(__MODULE__, spec)
        # name = :"#{__MODULE__}_#{config.id}"

        # Enum.each(
        #   children,
        #   &DynamicSupervisor.start_child(name, &1)
        # )

        # spec = {Foo, [id: config.id]}
        # DynamicSupervisor.start_child(name, spec)

        DynamicSupervisor.init(strategy: :one_for_one)
      end
    end
  end

  @spec hydrate(exchange_id :: atom) :: :ok
  def hydrate(exchange_id) do
    name = Tai.Exchanges.AdapterSupervisor.name(exchange_id)

    # children = [
    #   {Tai.Exchanges.AccountsSupervisor,
    #    [adapter: account(), exchange_id: config.id, accounts: config.accounts]}
    #   # {hydrate_products(), [exchange_id: config.id, whitelist_query: config.products]},
    #   # {hydrate_fees(), [exchange_id: config.id, accounts: config.accounts]},
    #   # {Tai.Exchanges.HydrateAssetBalances,
    #   #  [exchange_id: config.id, accounts: config.accounts]}
    # ]

    # Enum.each(
    #   children,
    #   fn spec ->
    #     {:ok, pid} = DynamicSupervisor.start_child(name, spec)
    #   end
    # )

    r = DynamicSupervisor.start_child(name, {Tai.Foo, exchange_id})
    IO.puts("=== in hydrate agent start_child result: #{inspect(r)}")

    :ok
  end

  @spec name(exchange_id :: atom) :: atom
  def name(exchange_id), do: :"#{__MODULE__}_#{exchange_id}"
end
