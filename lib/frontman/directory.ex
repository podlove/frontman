defmodule Frontman.Directory do
  @moduledoc """
  The Directory context.
  """

  import Ecto.Query, warn: false
  alias Frontman.Repo

  alias Frontman.Directory.Feed
  alias Frontman.UserManager.User

  def list_feeds(user = %User{}) do
    Repo.all(Feed)
  end

  def get_feed!(id), do: Repo.get!(Feed, id)

  def create_feed(user = %User{}, attrs \\ %{}) do
    Ecto.build_assoc(user, :feeds)
    |> Feed.changeset(attrs)
    |> Repo.insert()
  end

  def update_feed(%Feed{} = feed, attrs) do
    feed
    |> Feed.changeset(attrs)
    |> Repo.update()
  end

  def delete_feed(%Feed{} = feed) do
    Repo.delete(feed)
  end

  def change_feed(%Feed{} = feed) do
    Feed.changeset(feed, %{})
  end
end
