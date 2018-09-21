defmodule Tai.ExchangeAdapters.Binance.AccountTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Tai.ExchangeAdapters.Binance.Account

  setup_all do
    HTTPoison.start()

    start_supervised!(
      {Tai.ExchangeAdapters.Binance.Account,
       [exchange_id: :my_binance_exchange, account_id: :test, credentials: %{}]}
    )

    :ok
  end

  describe "#all_balances" do
    test "returns an error tuple when the secret is invalid" do
      use_cassette "exchange_adapters/binance/account/all_balances_error_invalid_secret" do
        assert Tai.Exchanges.Account.all_balances(:my_binance_exchange, :test) == {
                 :error,
                 %Tai.CredentialError{
                   reason: "API-key format invalid."
                 }
               }
      end
    end

    test "returns an error tuple when the api key is invalid" do
      use_cassette "exchange_adapters/binance/account/all_balances_error_invalid_api_key" do
        assert Tai.Exchanges.Account.all_balances(:my_binance_exchange, :test) == {
                 :error,
                 %Tai.CredentialError{
                   reason: "API-key format invalid."
                 }
               }
      end
    end

    test "returns an error tuple when rate limited" do
      use_cassette "exchange_adapters/binance/account/all_balances_error_invalid_api_key" do
        assert Tai.Exchanges.Account.all_balances(:my_binance_exchange, :test) == {
                 :error,
                 %Tai.RateLimitError{
                   reason:
                     "Too many requests; current limit is 1200 requests per minute. Please use the websocket for live updates to avoid polling the API."
                 }
               }
      end
    end
  end
end
