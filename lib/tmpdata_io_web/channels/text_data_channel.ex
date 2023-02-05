defmodule TmpDataIOWeb.TextDataChannel do
  alias TmpDataIO.Presence
  alias TmpDataIO.Repo
  alias TmpDataIO.TextData

  import Ecto.Query
  use TmpDataIOWeb, :channel

  def join("text_data:" <> page_id, _payload, socket) do
    send(self(), {:track_join, page_id})
    {:ok, socket}
  end

  def handle_in("change", %{"value" => text_value}, socket) do
    Phoenix.Channel.broadcast_from(socket, "update", %{value: text_value})

    "text_data:" <> page = socket.topic

    case Repo.one(from td in TextData, where: td.page == ^page) do
      nil -> %TextData{page: page}
      row -> row
    end
    |> TextData.changeset(%{content: text_value, ttl: 3600})
    |> TmpDataIO.Repo.insert_or_update()

    {:noreply, socket}
  end

  intercept ["presence_diff"]
  def handle_out("presence_diff", _payload, socket) do
    with "text_data:"<>page_id <- socket.topic do
      push(socket, "number_online", %{number_online: Enum.count(Map.get(Presence.list(socket), page_id, %{metas: []}).metas)})
    end
    {:noreply, socket}
  end

  def handle_info({:track_join, page_id}, socket) do
    {:ok, _} =
      Presence.track(socket, page_id, %{
        test: Time.utc_now(),
        page: page_id,
        socket_id: socket.id
      })

    {:noreply, socket}
  end
end
