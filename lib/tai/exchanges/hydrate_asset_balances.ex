defmodule Tai.Exchanges.HydrateAssetBalances do
  use GenServer

  def start_link([exchange_id: exchange_id, accounts: _] = state) do
    name = :"#{__MODULE__}_#{exchange_id}"
    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state) do
    {:ok, state, {:continue, :fetch}}
  end

  def handle_continue(:fetch, [exchange_id: exchange_id, accounts: accounts] = state) do
    accounts
    |> Enum.each(fn {account_id, _} ->
      with {:ok, balances} <- Tai.Exchanges.Account.all_balances(exchange_id, account_id) do
        Enum.map(
          balances,
          fn {_, balance} -> Tai.Exchanges.AssetBalances.upsert(balance) end
        )
      end
    end)

    {:noreply, state}
  end
end
