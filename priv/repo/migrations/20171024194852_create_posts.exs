defmodule Blog.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string, null: false
      add :body, :string, null: false
      add :published_at, :naive_datetime
      add :author_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:posts, [:author_id])
  end
end
