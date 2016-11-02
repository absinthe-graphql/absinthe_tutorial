defmodule Blog.Resolver.User do

  alias Blog.User
  alias Blog.Repo

  def find(_parent, %{id: id}, _info) do
    case Blog.Repo.get(User, id) do
      nil  -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end

  def all(_parent, _args, _info) do
    {:ok, Repo.all(User) }
  end

  def create(_parent, attributes, _info) do
    IO.inspect attributes
    changeset = User.changeset(%User{}, attributes)
    case Repo.insert(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset.errors}
    end
  end
end
