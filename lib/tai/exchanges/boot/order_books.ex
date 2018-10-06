defmodule Tai.Exchanges.Boot.OrderBooks do
  def start(adapter, products) do
    Tai.Exchanges.OrderBookFeedsSupervisor.start_feed(adapter, products)
    :ok
  end
end
