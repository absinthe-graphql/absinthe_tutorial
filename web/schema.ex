defmodule AbsintheExample.Schema do
  use Absinthe.Schema
  alias Absinthe.Type

  def query do
    %Type.Object{
      name: "RootQuery",
      fields: fields([]
      )
    }
  end

end
