defmodule Tai.Commands.Helper.AdvisorGroupsTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO
  import Tai.TestSupport.Mock

  setup do
    on_exit(fn ->
      Tai.TestSupport.Helpers.restart_application()
    end)
  end

  test ".enable_advisor_groups starts each advisor in each group" do
    mock_product(%{
      exchange_id: :exchange_a,
      symbol: :btc_usdt
    })

    mock_product(%{
      exchange_id: :exchange_b,
      symbol: :eth_usdt
    })

    assert capture_io(&Tai.Commands.Helper.enable_advisor_groups/0) == """
           Started 2 advisors
           """
  end
end
