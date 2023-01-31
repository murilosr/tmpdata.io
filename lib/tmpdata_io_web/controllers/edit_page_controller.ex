defmodule TmpDataIOWeb.EditPageController do
  alias TmpDataIO.Repo
  alias TmpDataIO.TextData

  import Ecto.Query

  use TmpDataIOWeb, :controller

  def index(conn, %{"page_id" => "login"}) do
    render(conn, "index.html", page_id: "Special page")
  end

  def index(conn, %{"page_id" => page_id}) do
    text_data =
      case Repo.one(from td in TextData, where: td.page == ^page_id) do
        nil -> %TextData{page: page_id}
        row -> row
      end

    render(conn, "index.html", page_id: page_id, text_data: text_data, files: conn)
  end

  def upload_file(conn, params) do
    IO.inspect(params)
    File.cp(params["name"].path, "/tmp/" <> params["name"].filename)
    redirect(conn, to: "/murilo")
  end
end
