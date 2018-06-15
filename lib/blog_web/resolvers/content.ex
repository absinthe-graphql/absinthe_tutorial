defmodule BlogWeb.Resolvers.Content do

  def list_posts(%Blog.Accounts.User{} = author, args, _resolution) do
    {:ok, Blog.Content.list_posts(author, args)}
  end
  def list_posts(_parent, _args, _resolution) do
    {:ok, Blog.Content.list_posts()}
  end

  def create_post(_parent, args, %{context: %{current_user: user}}) do
    # Blog.Content.create_post(user, args)
    case Blog.Content.create_post(user, args) do
      {:ok, post} ->
        Absinthe.Subscription.publish(BlogWeb.Endpoint, post,
        new_post: "*"
        )

        {:ok, post}
      {:error, changeset} ->
        {:ok, "error"}
      end
  end
  def create_post(_parent, _args, _resolution) do
    {:error, "Access denied"}
  end
end
