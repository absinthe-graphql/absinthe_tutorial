defmodule Blog.PeTest do
  use Blog.ModelCase

  alias Blog.Pe

  @valid_attrs %{name: "some content", species: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Pe.changeset(%Pe{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Pe.changeset(%Pe{}, @invalid_attrs)
    refute changeset.valid?
  end
end
