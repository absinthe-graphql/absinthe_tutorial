defmodule Blog.Schema do
  use Absinthe.Schema

  import_types Blog.Schema.Types

  query do
    field :posts, list_of(:post) do
      resolve &Resolver.Post.all/2
    end
    field :user, :user do
      arg :id, non_null(:id)

      resolve &Resolver.User.find/2
    end
  end

  mutation do
    field :post, :post do
      arg :title, non_null(:string)
      arg :body, non_null(:string)
      arg :posted_at, non_null(:time)

      resolve &Resolver.Post.create/2
    end
  end
end
