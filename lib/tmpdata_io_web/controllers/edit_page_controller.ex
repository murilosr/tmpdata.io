defmodule TmpDataIOWeb.EditPageController do
  alias TmpDataIO.FileContent
  alias TmpDataIO.FileCatalog
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

  def upload_file(conn, %{"page" => page_id, "upload_file" => upload_file}) do
    file_stats = File.stat!(upload_file.path)

    file_catalog =
      FileCatalog.changeset(%FileCatalog{page: TextData.get_lazy_reference(page_id)}, %{
        name: upload_file.filename,
        size: file_stats.size,
        ttl: 3600
      })

    file_catalog = Repo.insert!(file_catalog)

    File.stream!(upload_file.path, [], 2*1024*1024)
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

    File.cp(upload_file.path, "/tmp/" <> upload_file.filename)
    redirect(conn, to: "/murilo")
  end
end
