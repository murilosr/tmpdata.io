defmodule TmpDataIOWeb.HomepageController do
  use TmpDataIOWeb, :controller

  def index(conn, _params) do
    conn
    |> put_root_layout({TmpDataIOWeb.LayoutView, "homepage.html"})
    |> put_layout({TmpDataIOWeb.LayoutView, "bypass.html"})
    |> render("index.html")
  end
end
