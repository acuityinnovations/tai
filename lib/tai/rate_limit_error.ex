defmodule Tai.RateLimitError do
  @moduledoc """
  API request limit has been exceeded
  """

  @type t :: Tai.RateLimitError

  @enforce_keys [:reason]
  defstruct [:reason]
end
