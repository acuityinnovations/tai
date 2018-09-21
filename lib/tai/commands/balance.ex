defmodule Tai.Commands.Balance do
  @moduledoc """
  Display symbols on each exchange with a non-zero balance
  """

  alias TableRex.Table

  @spec balance :: no_return
  def balance do
    fetch_balances()
    |> format_rows()
    |> exclude_empty_balances()
    |> render!()
  end

  defp fetch_balances do
    Tai.Exchanges.AssetBalances.all()
    |> Enum.reverse()
    |> Enum.reduce(
      [],
      fn {{exchange_id, account_id, symbol}, balance}, acc ->
        total = Tai.Exchanges.AssetBalance.total(balance)
        [{exchange_id, account_id, symbol, balance.free, balance.locked, total} | acc]
      end
    )
  end

  defp exclude_empty_balances(balances) do
    balances
    |> Enum.reject(fn [_, _, _, _, _, total] -> Tai.Markets.Asset.zero?(total) end)
  end

  defp format_rows(balances) do
    balances
    |> Enum.map(fn {exchange_id, account_id, symbol, free, locked, total} ->
      formatted_free = Tai.Markets.Asset.new(free, symbol)
      formatted_locked = Tai.Markets.Asset.new(locked, symbol)
      formatted_total = Tai.Markets.Asset.new(total, symbol)
      [exchange_id, account_id, symbol, formatted_free, formatted_locked, formatted_total]
    end)
  end

  @header ["Exchange", "Account", "Symbol", "Free", "Locked", "Balance"]
  @spec render!(list) :: no_return
  defp render!(rows) do
    rows
    |> Table.new(@header)
    |> Table.put_column_meta(:all, align: :right)
    |> Table.render!()
    |> IO.puts()
  end
end
