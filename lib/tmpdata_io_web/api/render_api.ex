defmodule TmpDataIOWeb.Api.RenderApi do
  alias TmpDataIOWeb.PublicFileDAO
  use TmpDataIOWeb, :controller

  def get_payload(page_id) do
    files = PublicFileDAO.find_files_by_page_id(page_id)
    %{html: TmpDataIOWeb.UI.FileList.render(%{files: files}) |> Phoenix.LiveViewTest.rendered_to_string()}
  end

  def render_file_list(conn, %{"page_id" => page_id}) do
    json(conn, get_payload(page_id))
  end

end
