defmodule Blog.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.{Accounts, Content}

  schema "posts" do
    field :body, :string
    field :published_at, :naive_datetime
    field :title, :string

    belongs_to :author, Accounts.User

    timestamps()
  end

  @doc false
  def changeset(%Content.Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :body, :published_at])
    |> validate_required([:title, :body])
  end
end
