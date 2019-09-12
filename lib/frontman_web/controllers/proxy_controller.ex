defmodule FrontmanWeb.ProxyController do
  use FrontmanWeb, :controller

  alias Frontman.Directory
  alias Frontman.Directory.Feed

  def show(conn, %{"alias_segments" => segments}) do
    feed_alias =
      segments
      |> Enum.join("/")

    Directory.get_feed_by_alias(feed_alias)
    |> case do
      feed = %Feed{} ->
        fetch_feed(feed.origin_url)
        |> case do
          {:ok, xml} ->
            conn
            |> put_status(200)
            |> put_resp_header("cache-control", "max-age=300, public, must-revalidate")
            |> Plug.Conn.put_resp_content_type("application/xml", "utf-8")
            |> html(xml)

          {:error, other} ->
            html(conn, "found #{inspect(other)}")
        end

      _ ->
        send_resp(conn, 404, "Not found")
    end
  end

  def fetch_feed(url) do
    headers = [
      # pretend to be feedvalidator to get unredirected feeds from Publisher
      {"User-Agent", "Podlove Frontman, feedvalidator"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, other} ->
        IO.inspect(other)
        {:error, :ok_but_unexpected}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
