defmodule BlogWebTest do
  use BlogWeb.ConnCase

  @query """
  {
    posts {
      id, title
    }
  }
  """
  test "ordered result" do
    conn = build_conn()
    conn = get conn, "/api", query: @query
    assert conn.resp_body == ~s({"data":{"posts":[{"id":"1","title":"Test Post"}]}})
  end

  @query """
  {
    posts {
      title, id
    }
  }
  """
  test "ordered result works in reverse" do
    conn = build_conn()
    conn = get conn, "/api", query: @query
    assert conn.resp_body == ~s({"data":{"posts":[{"title":"Test Post","id":"1"}]}})
  end
end
