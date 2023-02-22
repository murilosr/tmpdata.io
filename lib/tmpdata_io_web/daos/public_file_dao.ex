defmodule TmpDataIOWeb.PublicFileDAO do
  alias TmpDataIO.Repo
  alias TmpDataIO.FileCatalog
  alias TmpDataIO.FileContent

  import Ecto.Query

  def get_file_by_id(id) do
    Repo.one(from f in FileCatalog, where: f.id == ^id)
  end

  def find_files_by_page_id(page_id) do
    Repo.all(from fc in FileCatalog, where: fc.page_id == ^page_id)
  end

  def query_file_content_by_file_id(file_id) do
    from fc in FileContent, where: fc.file_id == ^file_id
  end

  def count_file_content_by_file_id(file_id) do
    query_file_content_by_file_id(file_id)
    |> select([fc], count(fc.file_id))
    |> Repo.one()
  end

  def get_file_content_by_file_id_and_chunk_order(file_id, chunk_order) do
    [file_content_chunk] = query_file_content_by_file_id(file_id)
      |> where([fc], [chunk_order: ^chunk_order])
      |> select([fc], [fc.payload])
      |> Repo.one()
    file_content_chunk
  end

end
