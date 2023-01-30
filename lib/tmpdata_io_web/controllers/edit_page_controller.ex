defmodule TmpDataIOWeb.EditPageController do
  use TmpDataIOWeb, :controller

  def index(conn, %{"page_id" => "login"}) do
    render(conn, "index.html", page_id: "Special page")
  end

  def index(conn, %{"page_id" => page_id}) do
    render(conn, "index.html", page_id: page_id)
  end
end
