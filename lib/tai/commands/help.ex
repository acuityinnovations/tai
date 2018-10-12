defmodule Tai.Commands.Help do
  @moduledoc """
  Display the available commands and their usage
  """

  def help do
    # * enable_advisor_groups
    # * enable_advisor_group :id
    # * enable_advisor :group_id, :id
    # * disable_advisor_groups
    # * disable_advisor_group :id
    # * disable_advisor :group_id, :id
    IO.puts("""
    * balance
    * products
    * fees
    * markets
    * orders
    * advisors
    * settings
    * enable_advisor_groups
    * enable_send_orders
    * disable_advisor_groups
    * disable_send_orders
    """)
  end
end
