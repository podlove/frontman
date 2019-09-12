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
        html(conn, "found #{inspect(feed)}")

      _ ->
        send_resp(conn, 404, "Not found")
    end
  end
end
