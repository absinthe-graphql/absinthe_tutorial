defmodule BlogWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation
  alias BlogWeb.Resolvers

  @desc "A blog post"
  object :post do
    field :id, :id
    field :title, :string
    field :body, :string
    field :author, :user do
      resolve &Resolvers.Accounts.find_user/3
    end
    field :published_at, :naive_datetime
  end

end
