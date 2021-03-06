defmodule Tai.Trading.OrderPipeline.Send do
  alias Tai.Trading.{OrderResponse, Order}

  def execute_step(%Order{status: :enqueued} = o) do
    if Tai.Settings.send_orders?() do
      o
      |> send_request
      |> parse_response(o)
      |> execute_callback
    else
      o.client_id
      |> skip!
      |> execute_callback
    end
  end

  defp send_request(%Order{side: :buy, type: :limit} = o) do
    o |> Tai.Exchanges.Account.buy_limit()
  end

  defp send_request(%Order{side: :sell, type: :limit} = o) do
    o |> Tai.Exchanges.Account.sell_limit()
  end

  defp parse_response({:ok, %OrderResponse{status: :filled} = r}, %Order{} = o) do
    fill!(o.client_id, r.executed_size)
  end

  defp parse_response({:ok, %OrderResponse{status: :expired}}, %Order{client_id: cid}) do
    expire!(cid)
  end

  defp parse_response({:ok, %OrderResponse{status: :pending, id: sid}}, %Order{client_id: cid}) do
    pend!(cid, sid)
  end

  defp parse_response({:error, reason}, %Order{client_id: cid}) do
    error!(cid, reason)
  end

  defp fill!(cid, executed_size) do
    cid
    |> find_by_and_update(
      status: Tai.Trading.OrderStatus.filled(),
      executed_size: Decimal.new(executed_size)
    )
  end

  defp expire!(cid) do
    cid
    |> find_by_and_update(status: Tai.Trading.OrderStatus.expired())
  end

  defp pend!(cid, server_id) do
    cid
    |> find_by_and_update(
      status: Tai.Trading.OrderStatus.pending(),
      server_id: server_id
    )
  end

  defp error!(cid, reason) do
    cid
    |> find_by_and_update(
      status: Tai.Trading.OrderStatus.error(),
      error_reason: reason
    )
  end

  defp skip!(cid) do
    cid
    |> find_by_and_update(status: Tai.Trading.OrderStatus.skip())
  end

  defp find_by_and_update(client_id, attrs) do
    {:ok, [old_order, updated_order]} =
      Tai.Trading.OrderStore.find_by_and_update(
        [client_id: client_id],
        attrs
      )

    Tai.Trading.OrderPipeline.Logger.info(updated_order)

    {old_order, updated_order}
  end

  defp execute_callback({old_order, updated_order}) do
    Tai.Trading.Order.execute_update_callback(old_order, updated_order)
  end
end
