defmodule AbsintheExample.Router do
  use Phoenix.Router

  pipeline :graphql do
    plug AbsintheExample.Context
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", AbsinthePlug, schema: AbsintheExample.Web.Schema
  end
end
