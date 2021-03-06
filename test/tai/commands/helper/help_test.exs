defmodule Tai.Commands.Helper.HelpTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  test "show command usage" do
    assert capture_io(&Tai.Commands.Helper.help/0) == """
           * balance
           * products
           * fees
           * markets
           * orders
           * settings
           * enable_send_orders
           * disable_send_orders\n
           """
  end
end
