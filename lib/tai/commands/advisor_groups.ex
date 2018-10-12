defmodule Tai.Commands.AdvisorGroups do
  require Logger

  @spec enable :: no_return
  def enable do
    children =
      Tai.AdvisorGroups.specs()
      |> Enum.map(&Tai.AdvisorsSupervisor.start_advisor/1)

    count = Enum.count(children)

    IO.puts("Started #{count} advisors")
  end

  @spec disable :: no_return
  def disable do
  end
end
