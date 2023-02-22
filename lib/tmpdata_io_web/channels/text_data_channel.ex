defmodule TmpDataIOWeb.TextDataChannel do
  alias TmpDataIOWeb.Endpoint
  alias TmpDataIOWeb.Api.RenderApi
  alias TmpDataIO.Presence
  alias TmpDataIO.Repo
  alias TmpDataIO.TextData

  import Ecto.Query
  use TmpDataIOWeb, :channel

  @impl true
  def join("text_data:" <> page_id, _payload, socket) do
    send(self(), {:track_join, page_id})
    {:ok, socket}
  end

  @impl true
  def handle_in("change", %{"value" => text_value}, socket) do
    "text_data:" <> page = socket.topic

    Phoenix.Channel.broadcast_from(socket, "update", %{value: text_value})

    case Repo.one(from td in TextData, where: td.page == ^page) do
      nil -> %TextData{page: page}
      row -> row
    end
    |> TextData.changeset(%{content: text_value, ttl: 3600})
    |> TmpDataIO.Repo.insert_or_update()

    {:noreply, socket}
  end


  @impl true
  intercept ["presence_diff"]
  def handle_out("presence_diff", _payload, socket) do
    with "text_data:"<>page_id <- socket.topic do
      push(socket, "number_online", %{number_online: Enum.count(Map.get(Presence.list(socket), page_id, %{metas: []}).metas)})
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({:track_join, page_id}, socket) do
    {:ok, _} =
      Presence.track(socket, page_id, %{
        test: Time.utc_now(),
        page: page_id,
        socket_id: socket.id
      })

    {:noreply, socket}
  end

  def broadcast_update_file_list_event(page_id) do
    Endpoint.broadcast("text_data:" <> page_id, "update_file_list", RenderApi.get_payload(page_id))
  end
end
