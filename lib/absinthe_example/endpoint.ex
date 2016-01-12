defmodule AbsintheExample.Endpoint do
  use Phoenix.Endpoint, otp_app: :absinthe_example

  socket "/socket", AbsintheExample.UserSocket

  plug Plug.Static,
    at: "/", from: :absinthe_example, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug AbsintheExample.Router
end
