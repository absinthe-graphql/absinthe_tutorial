defmodule Blog.Content do
  import Ecto.Query

  alias Blog.{Repo, Content}

  def list_posts(author, %{date: date}) do
    from(t in Content.Post,
      where: t.author_id == ^author.id,
      where: fragment("date_trunc('day', ?)", t.published_at) == type(^date, :date))
    |> Repo.all
  end
  def list_posts(author, _) do
    from(t in Content.Post, where: t.author_id == ^author.id)
    |> Repo.all
  end

  def list_posts do
    Repo.all(Content.Post)
  end

  def create_post(user, attrs) do
    user
    |> Ecto.build_assoc(:posts, attrs)
    |> Repo.insert
  end

end
