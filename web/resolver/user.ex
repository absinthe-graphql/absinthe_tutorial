defmodule Blog.Resolver.User do

  alias Blog.User
  alias Blog.Repo

  def find(%{id: id}, _) do
    case Blog.Repo.get(User, id) do
      nil  -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end

  def all(_, _) do
    {:ok, Repo.all(User) }
  end

  def create(attributes, _) do
    IO.inspect attributes
    changeset = User.changeset(%User{}, attributes)
    case Repo.insert(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset.errors}
    end
  end
end
