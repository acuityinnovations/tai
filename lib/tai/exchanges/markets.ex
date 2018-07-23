defmodule Tai.Exchanges.Markets do
  use GenServer

  def start_link(configs) do
    GenServer.start_link(__MODULE__, configs, name: __MODULE__)
  end

  def init(configs) do
    Enum.each(configs, &Tai.Boot.subscribe_products(&1.id))
    {:ok, configs}
  end

  def handle_info({:fetched_products, :ok, exchange_id}, configs) do
    with %Tai.Exchanges.Config{} = config <- Enum.find(configs, &(&1.id == exchange_id)),
         order_book_feed_adapter <- config.supervisor.order_book_feed() do
      Tai.Exchanges.OrderBookFeedsSupervisor.add(order_book_feed_adapter, exchange_id)
    end

    {:noreply, configs}
  end
end
