defmodule Tai.Commands.Helper do
  @moduledoc """
  Commands for using `tai` in IEx
  """

  @spec help :: no_return
  defdelegate help, to: Tai.Commands.Info

  @spec help :: no_return
  defdelegate dashboard, to: Tai.Commands.Dashboard

  @spec balance :: no_return
  defdelegate balance, to: Tai.Commands.Balance

  @spec products :: no_return
  defdelegate products, to: Tai.Commands.Products

  @spec markets :: no_return
  defdelegate markets, to: Tai.Commands.Markets

  @spec orders :: no_return
  defdelegate orders, to: Tai.Commands.Orders

  @spec buy_limit(atom, atom, float, float, atom) :: no_return
  defdelegate buy_limit(account_id, symbol, price, size, time_in_force), to: Tai.Commands.Trading

  @spec sell_limit(atom, atom, float, float, atom) :: no_return
  defdelegate sell_limit(account_id, symbol, price, size, time_in_force), to: Tai.Commands.Trading

  @spec order_status(atom, String.t()) :: no_return
  defdelegate order_status(account_id, order_id), to: Tai.Commands.Trading

  @spec cancel_order(atom, String.t()) :: no_return
  defdelegate cancel_order(account_id, order_id), to: Tai.Commands.Trading
end
