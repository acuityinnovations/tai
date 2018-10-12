defmodule Tai.Commands.Helper.AdvisorsTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO
  import Tai.TestSupport.Mock

  setup do
    on_exit(fn ->
      Tai.Exchanges.ProductStore.clear()
    end)
  end

  test "shows all advisors and their run status" do
    mock_product(%{
      exchange_id: :exchange_a,
      symbol: :btc_usdt
    })

    mock_product(%{
      exchange_id: :exchange_b,
      symbol: :eth_usdt
    })

    assert capture_io(&Tai.Commands.Helper.advisors/0) == """
           +------------+---------------------+-------------+-----+
           |   Group ID |          Advisor ID |      Status | PID |
           +------------+---------------------+-------------+-----+
           | log_spread | exchange_a_btc_usdt | not_running |   - |
           | log_spread | exchange_b_eth_usdt | not_running |   - |
           +------------+---------------------+-------------+-----+\n
           """
  end

  test "shows an empty table when there are no advisors" do
    assert capture_io(&Tai.Commands.Helper.advisors/0) == """
           +----------+------------+--------+-----+
           | Group ID | Advisor ID | Status | PID |
           +----------+------------+--------+-----+
           |        - |          - |      - |   - |
           +----------+------------+--------+-----+\n
           """
  end
end
