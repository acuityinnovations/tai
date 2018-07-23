# defmodule Tai.Exchanges.OrderBookFeedsSupervisor do
#   use DynamicSupervisor

#   def start_link(_) do
#     DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
#   end

#   def init(:ok) do
#     DynamicSupervisor.init(strategy: :one_for_one)
#   end

#   def add(adapter, exchange_id) do
#     DynamicSupervisor.start_child(
#       __MODULE__,
#       {Tai.Exchanges.OrderBookFeedSupervisor, adapter: adapter, exchange_id: exchange_id}
#     )
#   end
# end
