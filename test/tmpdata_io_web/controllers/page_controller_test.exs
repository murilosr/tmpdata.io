defmodule TmpDataIOWeb.PageControllerTest do
  use TmpDataIOWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "any page"
  end
end
