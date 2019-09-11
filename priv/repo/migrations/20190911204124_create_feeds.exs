defmodule Frontman.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :origin_url, :text
      add :alias, :text

      add :user_id, references("users", on_delete: :delete_all)

      timestamps()
    end
  end
end
