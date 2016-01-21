defmodule AbsintheExample.Schema.Types do
  use Absinthe.Type.Definitions
  alias Absinthe.Type

  @absinthe :type
  def user do
    %Type.Object{
      fields: fields(
        id: [type: :id],
        name: [type: :string],
        email: [type: :string]
        posts: [type: list_of(:posts)]
      )
    }
  end

  @absinthe :type
  def post do
    %Type.Object{
      fields: fields(
        id: [type: :id],
        title: [type: :string],
        body: [type: :string],
        posted_at: [type: :string],
        author: [type: :user]
      )
    }
  end
end
