defmodule Frontman.Directory.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field :alias, :string
    field :origin_url, :string

    belongs_to :user, Frontman.UserManager.User

    timestamps()
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:origin_url, :alias])
    |> validate_required([:origin_url, :alias])
  end
end
