defmodule Blog.Schema.Types do
  use Absinthe.Schema.Notation

  @desc """
  A user of the blog
  """
  object :user do
    field :id, :id
    field :name, :string
    field :contact, :contact
    field :posts, list_of(:post)
  end

  object :post do
    field :id, :id
    field :title, :string
    field :body, :string
    field :posted_at, :time
    field :author, :user
  end

  object :contact do
    field :type, :contact_type
    field :value, :string
  end

  scalar :time do
    description "ISOz time",
    parse &Timex.DateFormat.parse(&1, "{ISOz}")
    serialize &Timex.DateFormat.format!(&1, "{ISOz}")
  end

  input_object :contact_input do
    field :type, non_null(:contact_type)
    field :value, non_null(:string)
  end

  enum :contact_type do
    values ~w(phone email)a
  end
end
