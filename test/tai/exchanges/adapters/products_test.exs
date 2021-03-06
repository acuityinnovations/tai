defmodule Tai.Exchanges.Adapters.ProductStoreTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @exchanges [
    %Tai.Exchanges.Config{
      id: :binance,
      supervisor: Tai.ExchangeAdapters.Binance.Supervisor
    },
    %Tai.Exchanges.Config{
      id: :poloniex,
      supervisor: Tai.ExchangeAdapters.Poloniex.Supervisor
    },
    %Tai.Exchanges.Config{
      id: :gdax,
      supervisor: Tai.ExchangeAdapters.Gdax.Supervisor
    }
  ]

  setup_all do
    on_exit(fn ->
      Tai.Exchanges.ProductStore.clear()
    end)

    HTTPoison.start()
    Process.register(self(), :test)
    :ok
  end

  @exchanges
  |> Enum.map(fn config ->
    @config config

    test "#{config.id} retrieves the product information for the exchange" do
      exchange_id = @config.id
      symbol = :ltc_btc
      Tai.Boot.subscribe_products(@config.id)
      key = {@config.id, symbol}

      assert {:error, :not_found} = Tai.Exchanges.ProductStore.find(key)

      use_cassette "exchange_adapters/shared/products/#{exchange_id}/init_success" do
        start_supervised!({@config.supervisor, @config})

        assert_receive {:fetched_products, :ok, ^exchange_id}, 1_000
      end

      assert {:ok, %Tai.Exchanges.Product{} = product} = Tai.Exchanges.ProductStore.find(key)
      assert ^exchange_id = product.exchange_id
      assert ^symbol = product.symbol
      assert product.exchange_symbol =~ "LTC"
      assert product.exchange_symbol =~ "BTC"
      assert Decimal.cmp(product.min_notional, Decimal.new(0)) == :gt
      assert Decimal.cmp(product.min_size, Decimal.new(0)) == :gt
      assert Decimal.cmp(product.min_price, Decimal.new(0)) == :gt
      assert Decimal.cmp(product.size_increment, Decimal.new(0)) == :gt
      assert product.status == :trading

      Tai.Boot.unsubscribe_products(exchange_id)
    end
  end)
end
