defmodule TmpDataIOWeb.EditPageController do
  alias TmpDataIOWeb.PublicTextDAO
  alias TmpDataIOWeb.PublicFileDAO
  alias TmpDataIO.FileContent
  alias TmpDataIO.FileCatalog
  alias TmpDataIO.TextData
  alias TmpDataIO.Repo

  use TmpDataIOWeb, :controller

  def index(conn, %{"page_id" => page_id}) do
    text_data =
      case PublicTextDAO.get_text_by_page_id(page_id, false) do
        nil -> %TextData{page: page_id, content: ""}
        row -> row
      end

    render(conn, "index.html", page_id: page_id, text_data: text_data, conn: conn, page_title: page_id)
  end

end
