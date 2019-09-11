defmodule Frontman.DirectoryTest do
  use Frontman.DataCase

  alias Frontman.Directory

  describe "feeds" do
    alias Frontman.Directory.Feed

    @valid_attrs %{alias: "some alias", origin_url: "some origin_url"}
    @update_attrs %{alias: "some updated alias", origin_url: "some updated origin_url"}
    @invalid_attrs %{alias: nil, origin_url: nil}

    def feed_fixture(attrs \\ %{}) do
      {:ok, feed} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Directory.create_feed()

      feed
    end

    test "list_feeds/0 returns all feeds" do
      feed = feed_fixture()
      assert Directory.list_feeds() == [feed]
    end

    test "get_feed!/1 returns the feed with given id" do
      feed = feed_fixture()
      assert Directory.get_feed!(feed.id) == feed
    end

    test "create_feed/1 with valid data creates a feed" do
      assert {:ok, %Feed{} = feed} = Directory.create_feed(@valid_attrs)
      assert feed.alias == "some alias"
      assert feed.origin_url == "some origin_url"
    end

    test "create_feed/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Directory.create_feed(@invalid_attrs)
    end

    test "update_feed/2 with valid data updates the feed" do
      feed = feed_fixture()
      assert {:ok, %Feed{} = feed} = Directory.update_feed(feed, @update_attrs)
      assert feed.alias == "some updated alias"
      assert feed.origin_url == "some updated origin_url"
    end

    test "update_feed/2 with invalid data returns error changeset" do
      feed = feed_fixture()
      assert {:error, %Ecto.Changeset{}} = Directory.update_feed(feed, @invalid_attrs)
      assert feed == Directory.get_feed!(feed.id)
    end

    test "delete_feed/1 deletes the feed" do
      feed = feed_fixture()
      assert {:ok, %Feed{}} = Directory.delete_feed(feed)
      assert_raise Ecto.NoResultsError, fn -> Directory.get_feed!(feed.id) end
    end

    test "change_feed/1 returns a feed changeset" do
      feed = feed_fixture()
      assert %Ecto.Changeset{} = Directory.change_feed(feed)
    end
  end
end
