defmodule TmpDataIOWeb.Api.FileApi do
  use TmpDataIOWeb, :controller

  alias TmpDataIO.TextData
  alias TmpDataIO.FileContent
  alias TmpDataIO.FileCatalog
  alias Ecto.Multi
  alias TmpDataIO.Repo


  import Ecto.Query

  def upload(conn, %{"page" => page_id, "upload_file" => upload_file}) do
    file_stats = File.stat!(upload_file.path)

    file_catalog =
      FileCatalog.changeset(%FileCatalog{page: TextData.get_lazy_reference(page_id)}, %{
        name: upload_file.filename,
        size: file_stats.size,
        ttl: 3600
      })

    file_catalog = Repo.insert!(file_catalog)

    File.stream!(upload_file.path, [], 8*1024*1024)
    |> Stream.with_index()
    |> Stream.each(fn {file_chunk, idx} ->
      IO.inspect(file_chunk)
      IO.puts(idx)

      FileContent.changeset(%FileContent{}, %{
        file_id: file_catalog.id,
        chunk_order: idx,
        payload: file_chunk
      })
      |> Repo.insert!()
    end)
    |> Stream.run()

    json(conn, %{status: "ok"})
  end

  def delete(conn, %{"id" => id}) do
    Repo.transaction(
      Multi.new()
      |> Multi.delete_all(:delete_all_file_content, from(f in FileContent, where: f.file_id == ^id))
      |> Multi.delete_all(:delete_all_file_catalog, from(f in FileCatalog, where: f.id == ^id))
    )
    json(conn, %{status: "ok"})
  end

end
