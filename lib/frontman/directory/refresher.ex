defmodule Frontman.Directory.Refresher do
  alias Frontman.Directory
  alias Frontman.Directory.Feed
  alias Frontman.Directory.FeedFetcher

  require Logger

  def refresh() do
    start = System.monotonic_time(:millisecond)

    # todo: use async tasks to parallelize
    Directory.list_feeds()
    |> Enum.each(&refresh_feed/1)

    time_spent = trunc((System.monotonic_time(:millisecond) - start) / 1000)
    IO.puts("Refreshed all feeds in #{time_spent}s")
  end

  def refresh_feed(feed = %Feed{}) do
    FeedFetcher.fetch(feed.origin_url)
    |> case do
      {:ok, data} -> ConCache.put(:feeds, feed.origin_url, data)
      other -> Logger.warn("Unable to refresh feed #{feed.origin_url}: #{inspect(other)}")
    end
  end
end
