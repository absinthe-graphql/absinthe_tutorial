defmodule BlogWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation

  alias BlogWeb.Resolvers
  alias Blog.Content
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  @desc "A user of the blog"
  object :user do
    field :id, :id
    field :name, :string
    field :contacts, list_of(:contact)
    field :posts, list_of(:post) do
      arg :date, :date
      resolve dataloader(Content)
    end
  end

  @desc "A user contact"
  object :contact do
    field :type, non_null(:contact_type)
    field :value, non_null(:string)
  end


  @desc "User contact types"
  enum :contact_type do
    value :phone, as: "phone"
    value :email, as: "email"
  end

  @desc "A user contact for input"
  input_object :contact_input do
    field :type, non_null(:contact_type)
    field :value, non_null(:string)
  end


end
