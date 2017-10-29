defmodule BlogWeb.Resolvers.Accounts do

  def find_user(_parent, %{id: id}, _resolution) do
    case Blog.Accounts.find_user(id) do
      nil ->
        {:error, "User ID #{id} not found"}
      user ->
        {:ok, user}
    end
  end

  def create_user(_parent, args, %{context: %{current_user: %{admin: true}}}) do
    Blog.Accounts.create_user(args)
  end
  def create_user(_parent, _args, _resolution) do
    {:error, "Access denied"}
  end

end
