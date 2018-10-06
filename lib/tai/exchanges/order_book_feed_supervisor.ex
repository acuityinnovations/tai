defmodule Tai.Exchanges.OrderBookFeedSupervisor do
  use Supervisor

  def start_link([adapter: adapter, trading_products: _] = state) do
    Supervisor.start_link(__MODULE__, state, name: adapter.id |> to_name)
  end

  def init(
        adapter: %Tai.Exchanges.Adapter{id: exchange_id, adapter: adapter},
        trading_products: trading_products
      ) do
    order_book_specs =
      trading_products
      |> Enum.map(
        &Supervisor.child_spec(
          {Tai.Markets.OrderBook, feed_id: exchange_id, symbol: &1.symbol},
          id: "#{exchange_id}_#{&1.symbol}"
        )
      )

    symbols = Enum.map(trading_products, & &1.symbol)

    feed_spec =
      Supervisor.child_spec(
        {adapter.order_book_feed, feed_id: exchange_id, symbols: symbols},
        id: Tai.Exchanges.OrderBookFeed.to_name(exchange_id)
      )

    children = order_book_specs ++ [feed_spec]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def to_name(exchange_id), do: :"#{__MODULE__}_#{exchange_id}"
end
