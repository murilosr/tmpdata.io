defmodule TmpDataIOWeb.TextDataChannel do
  alias TmpDataIO.Repo
  alias TmpDataIO.TextData
  import Ecto.Query
  use TmpDataIOWeb, :channel

  def join(_topic, _payload, socket) do
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
end
