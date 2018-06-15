defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug BlogWeb.Context
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: BlogWeb.Schema,
      socket: BlogWeb.UserSocket

    forward "/", Absinthe.Plug,
      schema: BlogWeb.Schema,
      socket: BlogWeb.UserSocket
  end

end
