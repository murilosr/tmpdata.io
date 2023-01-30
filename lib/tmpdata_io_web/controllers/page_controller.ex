defmodule TmpDataIOWeb.PageController do
  use TmpDataIOWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
