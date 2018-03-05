defmodule Blog.Accounts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Accounts

  schema "contacts" do
    field :type, :string
    field :value, :string

    belongs_to :user, Accounts.User

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  @doc false
  def changeset(%Accounts.Contact{} = contact, attrs) do
    contact
    |> cast(attrs, [:type, :value])
    |> validate_required([:type, :value])
    |> unique_constraint(:value, name: :contacts_type_value_index)
  end

end
