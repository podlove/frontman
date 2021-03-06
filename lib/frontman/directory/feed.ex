defmodule Frontman.Directory.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field :alias, :string
    field :origin_url, :string

    belongs_to :user, Frontman.UserManager.User

    timestamps()
  end

  # todo: normalise alias
  #   - strip leading and trailing slashes
  #   - only url safe characters
  #   - do something with whitespace?
  #   - make unique

  # todo: rename "alias" because it's a reserved word in Elixir

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:origin_url, :alias])
    |> validate_required([:origin_url, :alias])
  end
end
