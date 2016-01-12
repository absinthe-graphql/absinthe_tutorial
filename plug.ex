defmodule Absinthe.Plug do
  @behaviour Plug

  def init(opts) do
    adapter = Keyword.get(opts, :adapter, Absinthe.Adapter.Passthrough)
    context = Keyword.get(opts, :context, %{})

    json_codec = case Keyword.get(opts, :json_codec, Poison) do
      module when is_atom(module) -> %{module: module, opts: []}
      other -> other
    end

    schema = opts
    |> Keyword.fetch!(:schema)
    |> Absinthe.Schema.verify
    |> case do
      {:ok, schema} -> schema
      {:error, errors} -> raise ArgumentError, errors |> Enum.join("\n")
    end

    %{schema: schema, adapter: adapter, context: context, json_codec: json_codec}
  end

  def call(conn, config) do
    {input, variables, operation_name} = case get_req_header(conn, "content-type") do
      "application/json" ->
        # if it doesn't have query it should do an http error 400 "Must provide query string."
        # TODO: make variables and operationName optional
        %{"query" => input, "variables" => variables, "operationName" => operation_name} = conn.params
        {input, variables, operation_name}
      "application/x-www-form-urlencoded" ->
        %{"query" => input, "variables" => variables, "operationName" => operation_name} = conn.params
        {input, variables, operation_name}
      "application/graphql" ->
        input = conn.body
        %{"variables" => variables, "operationName" => operation_name} = conn.params
        variables
        {input, variables, operation_name}
    end

    context = Map.merge(context, conn.private.blah)

    do_call(conn, input, variables, context, config)
  end

  def do_call(conn, input, variables, context, %{schema: schema, adapter: adapter, json_codec: json_codec}}) do
    with {:ok, doc} <- Absinthe.parse(input),
      :ok <- validate_single_operation(doc),
      :ok <- validate_http_method(conn, doc),
      :ok <- Absinthe.validate(doc, schema),
      {:ok, result} <- Absinthe.execute(doc, schema, variables: variables, adapter: adapter, context: context) do

      {:ok, result}
    end
    |> case do
      {:ok, result} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, json_codec.module.encode!(result, json_codec.opts))

      {:http_error, text} ->
        conn
        |> put_status(405)
        |> text(text)

      {:error, %{message: message, locations: locations}} ->
        conn
        |> put_status(400)
        |> json(%{errors: [%{message: message, locations: locations}]})
    end
  end

  # This is a temporarily limitation
  defp validate_single_operation(%{definitions: [_]}), do: :ok
  defp validate_single_operation(_), do: {:http_error, "Can only accept one operation per query (temporary)"}

  defp validate_http_method(%{method: "GET"}, %{definitions: [%{operation: operation}]})
    when operation in ~w(mutation subscription)a do

    {:http_error, "Can only perform a #{operation} from a POST request"}
  end
  defp validate_http_method(_, _), do: :ok
end
