defmodule FrontmanWeb.FeedController do
  use FrontmanWeb, :controller

  alias Frontman.Directory
  alias Frontman.Directory.Feed

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    feeds = Directory.list_feeds(user)

    render(conn, "index.html", feeds: feeds)
  end

  def new(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    feed = Ecto.build_assoc(user, :feeds) |> Feed.changeset(%{})

    render(conn, "new.html", feed: feed)
  end

  def create(conn, %{"feed" => feed_params}) do
    user = Guardian.Plug.current_resource(conn)

    case Directory.create_feed(user, feed_params) do
      {:ok, _feed} ->
        conn
        |> put_flash(:info, "feed created.")
        |> redirect(to: Routes.feed_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", feed: changeset)
    end
  end
end
