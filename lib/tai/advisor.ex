defmodule Tai.Advisor do
  @moduledoc """
  A behavior for implementing a server that receives order book changes.

  It can be used to monitor multiple quote streams and create, update or cancel orders.
  """

  @enforce_keys [:group_id, :advisor_id, :order_books, :inside_quotes, :store]
  defstruct group_id: nil, advisor_id: nil, order_books: %{}, inside_quotes: %{}, store: %{}

  @typedoc """
  State of the running advisor
  """
  @type t :: %Tai.Advisor{
          group_id: atom,
          advisor_id: atom,
          order_books: map,
          inside_quotes: map,
          store: map
        }

  @doc """
  Callback during initilization. Allows the store to be updated before it 
  starts responding to events
  """
  @callback init_store(state :: t) :: {:ok, map}

  @doc """
  Callback when order book has bid or ask changes
  """
  @callback handle_order_book_changes(
              order_book_feed_id :: atom,
              symbol :: atom,
              changes :: term,
              state :: Tai.Advisor.t()
            ) :: :ok

  @doc """
  Callback when the highest bid or lowest ask changes price or size
  """
  @callback handle_inside_quote(
              order_book_feed_id :: atom,
              symbol :: atom,
              inside_quote :: Tai.Markets.Quote.t(),
              changes :: map | list,
              state :: Tai.Advisor.t()
            ) :: :ok | {:ok, store :: map}

  defmacro __using__(_) do
    quote location: :keep do
      use GenServer

      require Logger
      require Tai.TimeFrame

      @behaviour Tai.Advisor

      def start_link(
            group_id: group_id,
            advisor_id: advisor_id,
            order_books: order_books,
            store: store
          ) do
        GenServer.start_link(
          __MODULE__,
          %Tai.Advisor{
            group_id: group_id,
            advisor_id: advisor_id,
            order_books: order_books,
            inside_quotes: %{},
            store: Map.merge(%{}, store)
          },
          name: :"advisor_#{group_id}_#{advisor_id}"
        )
      end

      def start_link(
            advisor_id: advisor_id,
            order_books: order_books,
            store: %{} = store
          ) do
        GenServer.start_link(
          __MODULE__,
          %Tai.Advisor{
            group_id: :no_group,
            advisor_id: advisor_id,
            order_books: order_books,
            inside_quotes: %{},
            store: Map.merge(%{}, store)
          },
          name: :"advisor_#{advisor_id}"
        )
      end

      @doc false
      def init(%Tai.Advisor{order_books: order_books} = state) do
        Tai.MetaLogger.init_tid()
        subscribe_to_order_book_channels(order_books)
        new_store = init_store_callback(state)
        new_state = Map.put(state, :store, new_store)

        {:ok, new_state}
      end

      defp init_store_callback(state) do
        state
        |> init_store
        |> case do
          {:ok, new_store} ->
            new_store

          return_error ->
            Logger.error(
              "init_store must return {:ok, store} but it returned '#{inspect(return_error)}'"
            )

            state.store
        end
      end

      @doc false
      def handle_info({:order_book_snapshot, feed_id, symbol, snapshot}, state) do
        new_state =
          state
          |> cache_inside_quote(feed_id, symbol)
          |> execute_handle_inside_quote(feed_id, symbol, snapshot)

        {:noreply, new_state}
      end

      @doc false
      def handle_info({:order_book_changes, feed_id, symbol, changes}, state) do
        new_state =
          Tai.TimeFrame.debug "handle_info({:order_book_changes...})" do
            handle_order_book_changes(feed_id, symbol, changes, state)

            previous_inside_quote = state |> cached_inside_quote(feed_id, symbol)

            if inside_quote_is_stale?(previous_inside_quote, changes) do
              state
              |> cache_inside_quote(feed_id, symbol)
              |> execute_handle_inside_quote(
                feed_id,
                symbol,
                changes,
                previous_inside_quote
              )
            else
              state
            end
          end

        {:noreply, new_state}
      end

      @doc """
      Returns the current state of the order book up to the given depth

      ## Examples

        iex> Tai.Advisor.quotes(feed_id: :test_feed_a, symbol: :btc_usd, depth: 1)
        {:ok, %Tai.Markets.OrderBook{bids: [], asks: []}
      """
      def quotes(feed_id: feed_id, symbol: symbol, depth: depth) do
        [feed_id: feed_id, symbol: symbol]
        |> Tai.Markets.OrderBook.to_name()
        |> Tai.Markets.OrderBook.quotes(depth)
      end

      @doc """
      Returns the inside quote stored before the last 'handle_inside_quote' callback

      ## Examples

        iex> Tai.Advisor.cached_inside_quote(state, :test_feed_a, :btc_usd)
        %Tai.Markets.Quote{
          bid: %Tai.Markets.PriceLevel{price: 101.1, size: 1.1, processed_at: nil, server_changed_at: nil},
          ask: %Tai.Markets.PriceLevel{price: 101.2, size: 0.1, processed_at: nil, server_changed_at: nil}
        }
      """
      def cached_inside_quote(%{inside_quotes: inside_quotes}, order_book_feed_id, symbol) do
        inside_quotes
        |> Map.get(
          [feed_id: order_book_feed_id, symbol: symbol]
          |> Tai.Markets.OrderBook.to_name()
        )
      end

      @doc false
      def init_store(%Tai.Advisor{store: store}), do: {:ok, store}
      @doc false
      def handle_order_book_changes(order_book_feed_id, symbol, changes, state), do: :ok
      @doc false
      def handle_inside_quote(order_book_feed_id, symbol, inside_quote, changes, state), do: :ok

      defp subscribe_to_order_book_channels(order_books) do
        order_books
        |> Enum.each(fn {order_book_feed_id, symbols} ->
          symbols
          |> Enum.each(fn symbol ->
            Tai.PubSub.subscribe([
              {:order_book_snapshot, order_book_feed_id, symbol},
              {:order_book_changes, order_book_feed_id, symbol}
            ])
          end)
        end)
      end

      defp cache_inside_quote(state, feed_id, symbol) do
        with {:ok, current_inside_quote} <- Tai.Markets.OrderBook.inside_quote(feed_id, symbol),
             feed_and_symbol <- [feed_id: feed_id, symbol: symbol],
             key <- Tai.Markets.OrderBook.to_name(feed_and_symbol),
             old <- state.inside_quotes,
             updated <- Map.put(old, key, current_inside_quote) do
          Map.put(state, :inside_quotes, updated)
        end
      end

      defp inside_quote_is_stale?(
             previous_inside_quote,
             %Tai.Markets.OrderBook{bids: bids, asks: asks} = changes
           ) do
        (bids |> Enum.any?() && bids |> inside_bid_is_stale?(previous_inside_quote)) ||
          (asks |> Enum.any?() && asks |> inside_ask_is_stale?(previous_inside_quote))
      end

      defp inside_bid_is_stale?(_bids, nil), do: false

      defp inside_bid_is_stale?(bids, %Tai.Markets.Quote{} = prev_quote) do
        bids
        |> Enum.any?(fn {price, {size, _processed_at, _server_changed_at}} ->
          price >= prev_quote.bid.price ||
            (price == prev_quote.bid.price && size != prev_quote.bid.size)
        end)
      end

      defp inside_ask_is_stale?(asks, nil), do: false

      defp inside_ask_is_stale?(asks, %Tai.Markets.Quote{} = prev_quote) do
        asks
        |> Enum.any?(fn {price, {size, _processed_at, _server_changed_at}} ->
          price <= prev_quote.ask.price ||
            (price == prev_quote.ask.price && size != prev_quote.ask.size)
        end)
      end

      defp execute_handle_inside_quote(
             state,
             order_book_feed_id,
             symbol,
             changes,
             previous_inside_quote \\ nil
           ) do
        current_inside_quote = cached_inside_quote(state, order_book_feed_id, symbol)

        if current_inside_quote == previous_inside_quote do
          state
        else
          try do
            order_book_feed_id
            |> handle_inside_quote(symbol, current_inside_quote, changes, state)
            |> case do
              {:ok, new_store} ->
                Map.put(state, :store, new_store)

              :ok ->
                state

              unhandled ->
                Logger.warn(
                  "handle_inside_quote returned an invalid value: '#{inspect(unhandled)}'"
                )
            end
          rescue
            e ->
              Logger.warn(
                "handle_inside_quote raised an error: '#{inspect(e)}', stacktrace: #{
                  inspect(__STACKTRACE__)
                }"
              )
          end
        end
      end

      defoverridable init_store: 1,
                     handle_order_book_changes: 4,
                     handle_inside_quote: 5
    end
  end
end
