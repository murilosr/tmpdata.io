defmodule TmpDataIOWeb.TextDataChannel do
  use TmpDataIOWeb, :channel

  def join(_topic, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("change", %{"value" => text_value}, socket) do
    Phoenix.Channel.broadcast_from(socket, "update", %{value: text_value})
    {:noreply, socket}
  end
end
