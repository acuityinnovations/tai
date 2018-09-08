defmodule Tai.Exchanges.AccountsSupervisor do
  use Supervisor

  def start_link([adapter: _, exchange_id: exchange_id, accounts: _] = state) do
    name = :"#{__MODULE__}_#{exchange_id}"
    Supervisor.start_link(__MODULE__, state, name: name)
  end

  def init(adapter: adapter, exchange_id: exchange_id, accounts: accounts) do
    accounts
    |> Enum.map(fn {account_id, opts} ->
      {adapter, [exchange_id: exchange_id, account_id: account_id, opts: opts]}
    end)
    |> Supervisor.init(strategy: :one_for_one)
  end
end
