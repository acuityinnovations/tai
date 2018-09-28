defmodule Tai.ExchangeAdapters.Binance.Supervisor do
  @moduledoc """
  Supervisor for the Binance exchange adapter
  """

  use Tai.Exchanges.AdapterSupervisor

  def hydrate_products do
    Tai.ExchangeAdapters.Binance.HydrateProducts
  end

  def hydrate_fees do
    Tai.ExchangeAdapters.Binance.HydrateFees
  end

  def account do
    Tai.ExchangeAdapters.Binance.Account
  end

  def order_book_feed do
    Tai.ExchangeAdapters.Binance.OrderBookFeed
  end
end
