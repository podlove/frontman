defmodule Frontman.Directory.FeedFetcher do
  def fetch(url) do
    headers = [
      # pretend to be feedvalidator to get unredirected feeds from Publisher
      {"User-Agent", "Podlove Frontman, feedvalidator"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok,
         %{
           xml: body,
           etag: etag(body),
           last_modified: last_modified(body)
         }}

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
