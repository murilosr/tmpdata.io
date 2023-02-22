defmodule TmpDataIOWeb.Api.FileApi do
  use TmpDataIOWeb, :controller

  alias TmpDataIOWeb.Endpoint
  alias TmpDataIOWeb.TextDataChannel
  alias TmpDataIOWeb.PublicFileDAO
  alias TmpDataIO.TextData
  alias TmpDataIO.FileContent
  alias TmpDataIO.FileCatalog
  alias Ecto.Multi
  alias TmpDataIO.Repo

  import Ecto.Query

  defp get_file_size(file_path) do
    File.stat!(file_path).size
  end

  defp save_file_catalog(file_path, file_name, page_id) do
    file_size = get_file_size(file_path)

    file_catalog =
      FileCatalog.changeset(%FileCatalog{page: TextData.get_lazy_reference(page_id)}, %{
        name: file_name,
        size: file_size,
        ttl: 3600
      })

    Repo.insert!(file_catalog)
  end

  defp chunk_and_save_file_content(file_catalog, file_path) do
    File.stream!(file_path, [], 8*1024*1024)
    |> Stream.with_index()
    |> Stream.each(fn {file_chunk, idx} ->
      FileContent.changeset(%FileContent{}, %{
        file_id: file_catalog.id,
        chunk_order: idx,
        payload: file_chunk
      })
      |> Repo.insert!()
    end)
    |> Stream.run()
  end

  def upload(conn, %{"page" => page_id, "upload_file" => recv_file}) do
    %{path: file_path, filename: file_name} = recv_file

    save_file_catalog(file_path, file_name, page_id)
    |> chunk_and_save_file_content(file_path)

    TextDataChannel.broadcast_update_file_list_event(page_id)

    json(conn, %{status: "ok"})
  end

  def delete(conn, %{"id" => id}) do
    page_id = PublicFileDAO.get_file_by_id(id).page_id

    Repo.transaction(
      Multi.new()
      |> Multi.delete_all(:delete_all_file_content, from(f in FileContent, where: f.file_id == ^id))
      |> Multi.delete_all(:delete_all_file_catalog, from(f in FileCatalog, where: f.id == ^id))
    )

    TextDataChannel.broadcast_update_file_list_event(page_id)

    json(conn, %{status: "ok"})
  end

  def download_file(conn, %{"file_id" => file_id}) do
    %FileCatalog{name: orig_filename, size: file_size} = PublicFileDAO.get_file_by_id(file_id)

    conn = conn
    |> Plug.Conn.put_resp_header("content-disposition", "attachment; filename=\"#{orig_filename}\"")
    |> Plug.Conn.put_resp_header("cache-control", "no-cache")
    |> Plug.Conn.put_resp_header("content-length", "#{file_size}")
    |> Plug.Conn.send_chunked(:ok)

    chunk_count = PublicFileDAO.count_file_content_by_file_id(file_id)

    Enum.reduce_while(0..chunk_count-1, conn, fn (idx, conn) ->
      file_content_chunk = PublicFileDAO.get_file_content_by_file_id_and_chunk_order(file_id, idx)
      case Plug.Conn.chunk(conn, file_content_chunk) do
        {:ok, conn} ->
          {:cont, conn}
        {:error, :closed} ->
          {:halt, conn}
      end
    end)
  end

end
