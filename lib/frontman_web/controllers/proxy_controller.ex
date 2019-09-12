defmodule FrontmanWeb.ProxyController do
  use FrontmanWeb, :controller

  alias Frontman.Directory

  alias Frontman.Directory.{
    Feed,
    FeedFetcher
  }

  def show(conn, %{"alias_segments" => segments}) do
    feed_alias =
      segments
      |> Enum.join("/")

    Directory.get_feed_by_alias(feed_alias)
    |> case do
      feed = %Feed{} ->
        fetch_feed(feed.origin_url)
        |> case do
          {:ok,
           %{
             xml: xml,
             etag: etag,
             last_modified: last_modified
           }} ->
            case get_req_header(conn, "if-none-match") do
              [request_etag] when request_etag == etag ->
                send_resp(conn, 304, "")

              _ ->
                conn
                |> put_status(200)
                |> put_resp_header("cache-control", "max-age=300, public, must-revalidate")
                |> put_resp_header("etag", etag)
                |> put_resp_header("last-modified", last_modified)
                |> Plug.Conn.put_resp_content_type("application/xml", "utf-8")
                |> html(xml)
            end

          {:error, other} ->
            html(conn, "found #{inspect(other)}")
        end

      _ ->
        send_resp(conn, 404, "Not found")
    end
  end

  def fetch_feed(url) do
    ConCache.get(:feeds, url)
    |> case do
      nil ->
        FeedFetcher.fetch(url)
        |> case do
          {:ok, data} ->
            ConCache.put(:feeds, url, data)
            {:ok, data}

          {:error, reason} ->
            {:error, reason}
        end

      data ->
        {:ok, data}
    end
  end
end
