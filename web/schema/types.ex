defmodule Blog.Schema.Types do
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
    field :posts, list_of(:post)
  end

  object :post do
    field :id, :id
    field :title, :string
    field :body, :string
    field :posted_at, :time
    field :author, :user
  end

  scalar :time do
    description "ISOz time",
    parse &Timex.DateFormat.parse(&1, "{ISOz}")
    serialize &Timex.DateFormat.format!(&1, "{ISOz}")
  end
end
