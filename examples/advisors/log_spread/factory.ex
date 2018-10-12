defmodule Examples.Advisors.LogSpread.Factory do
  def advisor_specs(%Tai.AdvisorGroup{} = group, products_by_exchange)
      when is_map(products_by_exchange) do
    products_by_exchange
    |> Enum.reduce(
      [],
      fn {exchange_id, product_symbols}, acc ->
        product_symbols
        |> Enum.reduce(
          acc,
          fn symbol, acc ->
            spec = {
              Examples.Advisors.LogSpread.Advisor,
              [
                group_id: group.id,
                advisor_id: :"#{exchange_id}_#{symbol}",
                order_books: Map.put(%{}, exchange_id, [symbol]),
                store: %{}
              ]
            }

            [spec | acc]
          end
        )
      end
    )
    |> Enum.reverse()
  end
end
