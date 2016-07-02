defmodule Blog.Resolver.User do

  alias Blog.User
  
  def find(%{id: id}, _) do
    case Blog.Repo.get(User, id) do
      nil  -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end
end
