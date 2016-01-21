defmodule AbsintheExample.Schema do
  use Absinthe.Schema, type_modules: [AbsintheExample.Schema.Types]
  alias Absinthe.Type

  def query do
    %Type.Object{
      fields: fields(
        posts: [
          type: list_of(:post),
          resolve: &Resolver.Post.all/3
        ]
        user: [
          type: :user,
          args: args(
            id: [type: non_null(:id)]
          )
          resolve: &Resolver.User.find/3
        ]
      )
    }
  end

  def mutation do
    %Type.Object{
      fields: fields(
        create_post: [
          type: :post,
          args: args(
            title: [type: :string],
            body: [type: :string],
            posted_at: [type: :string],
          ),
          resolve: &Resolver.Post.create/3,
        ]
      )
    }
  end
end
