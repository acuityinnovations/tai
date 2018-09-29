defmodule Tai.Foo do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(state) do
    IO.puts("!!!!!!!!!!!! In Foo Server - arg: #{inspect(state)}")
    {:ok, state}
  end
end
