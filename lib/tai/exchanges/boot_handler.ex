defmodule Tai.Exchanges.BootHandler do
  require Logger

  def parse_response({:ok, adapter}) do
    Logger.info("exchange boot success #{inspect(adapter.id)}")
  end

  def parse_response({:error, {adapter, reasons}}) do
    Logger.info("exchange boot error #{inspect(adapter.id)}, reasons: #{inspect(reasons)}")
  end
end
