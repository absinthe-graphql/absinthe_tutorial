defmodule Blog.Accounts do

  alias Blog.{Accounts, Repo}

  def find_user(id) do
    Repo.get(Accounts.User, id)
  end

  def create_user(attrs) do
    {contact_attrs, user_attrs} = Map.pop(attrs, :contact)

    Repo.transaction fn ->
      with {:ok, contact} <- create_contact(contact_attrs),
           {:ok, user} <- do_create_user(user_attrs, contact) do
        %{user | contacts: [contact]}
      else
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end

  end

  def create_contact(attrs) do
    attrs
    |> Accounts.Contact.changeset
    |> Repo.insert
  end

  defp do_create_user(attrs, contact) do
    attrs
    |> Map.put(:contact_id, contact.id)
    |> Accounts.User.changeset
    |> Repo.insert
  end

end
