defmodule AbsintheExample.Resolver.User do
  def find(_, %{id: id}, _) do
    case AbsintheExample.Repo.get(User, id) do
      nil  -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end
end
