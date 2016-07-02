defmodule Blog.Router do
  use Phoenix.Router

  pipeline :graphql do
    plug Blog.Context
  end

  scope "/" do
    pipe_through :graphql

    get "/graphiql", Absinthe.Plug.GraphiQL, schema: Blog.Schema
    post "/graphiql", Absinthe.Plug.GraphiQL, schema: Blog.Schema
    forward "/graphql", Absinthe.Plug, schema: Blog.Schema
  end
end
