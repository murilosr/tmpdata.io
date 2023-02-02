defmodule TmpDataIOWeb.Api.FileApi do
  use TmpDataIOWeb, :controller

  alias TmpDataIO.FileContent
  alias TmpDataIO.FileCatalog
  alias Ecto.Multi
  alias TmpDataIO.Repo

  import Ecto.Query

  def delete(conn, %{"id" => id}) do
    Repo.transaction(
      Multi.new()
      |> Multi.delete_all(:delete_all_file_content, from(f in FileContent, where: f.file_id == ^id))
      |> Multi.delete_all(:delete_all_file_catalog, from(f in FileCatalog, where: f.id == ^id))
    )
    json(conn, %{status: "ok"})
  end

end
