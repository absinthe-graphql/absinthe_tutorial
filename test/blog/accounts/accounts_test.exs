defmodule Blog.AccountsTest do
  use Blog.DataCase

  alias Blog.Accounts

  test "create_user/1 returns {:error, changeset} and rolles back transaction on error" do
    attrs = %{
      contact: %{type: "phone", value: "+1 000 000 0000"},
      name: "",
      password: "password"
    }

    contact_count = Repo.aggregate(Accounts.Contact, :count, :id)

    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(attrs)
    assert ^contact_count = Repo.aggregate(Accounts.Contact, :count, :id)
  end
end
