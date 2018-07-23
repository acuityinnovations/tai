defmodule Tai.Exchanges.OrderBookFeedSupervisor do
  use Supervisor

  def start_link([adapter: _, exchange_id: exchange_id] = state) do
    Supervisor.start_link(
      __MODULE__,
      state,
      name: :"#{__MODULE__}_#{exchange_id}"
    )
  end

  def init(adapter: adapter, exchange_id: exchange_id) do
    exchange_id
    |> to_children(adapter)
    |> Supervisor.init(strategy: :one_for_all)

    # []
    # |> Supervisor.init(strategy: :one_for_all)
  end

  defp to_children(exchange_id, adapter) do
    # order_book_child_specs(exchange_id) ++ feed_child_spec(adapter, exchange_id)
    []
  end

  defp order_book_child_specs(exchange_id) do
    exchange_id
    |> Tai.Exchanges.Config.order_book_feed_symbols()
    |> Enum.map(
      &Supervisor.child_spec(
        {Tai.Markets.OrderBook, feed_id: exchange_id, symbol: &1},
        id: "#{Tai.Markets.OrderBook}_#{exchange_id}_#{&1}"
      )
    )
  end

  defp feed_child_spec(adapter, exchange_id) do
    %{
      id: exchange_id |> Tai.Exchanges.OrderBookFeed.to_name(),
      start: {
        adapter,
        :start_link,
        [
          [
            feed_id: exchange_id,
            symbols: exchange_id |> Tai.Exchanges.Config.order_book_feed_symbols()
          ]
        ]
      },
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end
end
