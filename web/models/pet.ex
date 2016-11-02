defmodule Blog.Pet do
  use Blog.Web, :model

  schema "pets" do
    field :name, :string
    field :species, :string
    belongs_to :owner, Blog.Customer, foreign_key: :owner_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :species])
    |> validate_required([:name, :species])
  end
end
