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
        do_fetch_feed(url)
        |> case do
          {:ok, xml} ->
            data = %{
              xml: xml,
              etag: etag(xml),
              last_modified: last_modified(xml)
            }

            ConCache.put(:feeds, url, data)

            {:ok, data}

          {:error, reason} ->
            {:error, reason}
        end

      data ->
        {:ok, data}
    end
  end

  defp do_fetch_feed(url) do
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

  defp etag(xml), do: "W/" <> Base.encode16(:crypto.hash(:md5, xml), case: :lower)

  defp last_modified(_), do: DateTime.utc_now() |> to_rfc7232()

  def to_rfc7232(datetime) do
    date = DateTime.to_date(datetime)

    day_name =
      case Date.day_of_week(date) do
        1 -> "Mon"
        2 -> "Tue"
        3 -> "Wed"
        4 -> "Thu"
        5 -> "Fri"
        6 -> "Sat"
        7 -> "Sun"
      end

    month_name =
      case date.month do
        1 -> "Jan"
        2 -> "Feb"
        3 -> "Mar"
        4 -> "Apr"
        5 -> "May"
        6 -> "Jun"
        7 -> "Jul"
        8 -> "Aug"
        9 -> "Sep"
        10 -> "Oct"
        11 -> "Nov"
        12 -> "Dec"
      end

    time = datetime |> DateTime.to_time() |> Time.truncate(:second) |> Time.to_iso8601()

    "#{day_name}, #{date.day |> Integer.to_string() |> String.pad_leading(2, "0")} #{month_name} #{
      date.year
    } #{time} GMT"
  end
end
