defmodule Tai.Exchanges.ConfigTest do
  use ExUnit.Case, async: true
  doctest Tai.Exchanges.Config

  describe "#all" do
    test "products can be provided" do
      exchanges = %{
        a: [supervisor: Tai.ExchangeAdapters.Mock.Supervisor, products: "btc_usdt"]
      }

      assert [%Tai.Exchanges.Config{} = config] = Tai.Exchanges.Config.all(exchanges)
      assert config.products == "btc_usdt"
    end

    test "products returns '*' when not provided" do
      exchanges = %{a: [supervisor: Tai.ExchangeAdapters.Mock.Supervisor]}

      assert [%Tai.Exchanges.Config{} = config] = Tai.Exchanges.Config.all(exchanges)
      assert config.products == "*"
    end

    test "order_books can be provided" do
      exchanges = %{
        a: [supervisor: Tai.ExchangeAdapters.Test.Supervisor, order_books: "btc_usdt"]
      }

      assert [%Tai.Exchanges.Config{} = config] = Tai.Exchanges.Config.all(exchanges)
      assert config.order_books == "btc_usdt"
    end

    test "order_books returns '*' when not provided" do
      exchanges = %{a: [supervisor: Tai.ExchangeAdapters.Test.Supervisor]}

      assert [%Tai.Exchanges.Config{} = config] = Tai.Exchanges.Config.all(exchanges)
      assert config.order_books == "*"
    end

    test "accounts can be provided" do
      exchanges = %{
        a: [supervisor: Tai.ExchangeAdapters.Mock.Supervisor, accounts: %{test: %{}}]
      }

      assert [%Tai.Exchanges.Config{} = config] = Tai.Exchanges.Config.all(exchanges)
      assert config.accounts == %{test: %{}}
    end

    test "accounts returns an empty map when not provided" do
      exchanges = %{a: [supervisor: Tai.ExchangeAdapters.Mock.Supervisor]}

      assert [%Tai.Exchanges.Config{} = config] = Tai.Exchanges.Config.all(exchanges)
      assert config.accounts == %{}
    end
  end
end
