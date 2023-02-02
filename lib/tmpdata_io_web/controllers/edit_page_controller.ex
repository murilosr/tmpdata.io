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
        nil -> %TextData{page: page_id, content: ""}
        row -> row
      end

      text_data = Repo.preload(text_data, [:files])
      IO.inspect(text_data.files)

    render(conn, "index.html", page_id: page_id, text_data: text_data, conn: conn, page_title: page_id)
  end

  def download_file(conn, %{"file_id" => file_id}) do
    %FileCatalog{name: orig_filename, size: file_size} = Repo.one(from f in FileCatalog, where: f.id == ^file_id, select: [:name, :size])

    query = from fc in FileContent, where: fc.file_id == ^file_id

    chunk_number = Repo.one(query |> select([fc], count(fc.file_id)))

    conn = conn
    |> Plug.Conn.put_resp_header("content-disposition", "attachment; filename=\"#{orig_filename}\"")
    |> Plug.Conn.put_resp_header("cache-control", "no-cache")
    |> Plug.Conn.put_resp_header("content-length", "#{file_size}")
    |> Plug.Conn.send_chunked(:ok)

    Enum.reduce_while(0..chunk_number-1, conn, fn (idx, conn) ->
      [file_content_chunk] = Repo.one(
        query |> where([fc], [chunk_order: ^idx]) |> select([fc], [fc.payload])
      )

      case Plug.Conn.chunk(conn, file_content_chunk) do
        {:ok, conn} ->
          {:cont, conn}
        {:error, :closed} ->
          {:halt, conn}
      end
    end)
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

    redirect(conn, to: "/#{page_id}")
  end
end
