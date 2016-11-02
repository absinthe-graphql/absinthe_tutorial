defmodule Blog.Repo.Migrations.CreatePe do
  use Ecto.Migration

  def change do
    create table(:pets) do
      add :name, :string
      add :species, :string
      add :owner_id, references(:customers, on_delete: :nothing)

      timestamps()
    end
    create index(:pets, [:owner_id])

  end
end
