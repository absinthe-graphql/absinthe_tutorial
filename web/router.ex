defmodule Blog.Router do
  use Phoenix.Router

  pipeline :graphql do
    plug Blog.Context
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: Blog.Schema
  end
end
