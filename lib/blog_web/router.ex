defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug BlogWeb.Context
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: BlogWeb.Schema

    forward "/", Absinthe.Plug,
      schema: BlogWeb.Schema,
      json_codec: BlogWeb.JSON,
      pipeline: {__MODULE__, :absinthe_pipeline}
  end

  def absinthe_pipeline(config, pipeline_opts) do
    pipeline_opts = Keyword.put(pipeline_opts, :result_phase, BlogWeb.OrdGraphQLResult)
    config.schema_mod
    |> Absinthe.Pipeline.for_document(pipeline_opts)
    |> Absinthe.Pipeline.replace(Absinthe.Phase.Document.Result, BlogWeb.OrdGraphQLResult)
  end

end
