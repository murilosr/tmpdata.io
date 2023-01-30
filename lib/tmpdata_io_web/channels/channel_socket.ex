defmodule TmpDataIOWeb.ChannelSocket do
  alias TmpDataIOWeb.TextDataChannel
  use Phoenix.Socket

  channel "text_data:*", TextDataChannel

  def connect(socket) do
    {:ok, socket}
  end

  def connect(_param, socket, _connect_info) do
    IO.inspect(socket)
    {:ok, socket}
  end

  def id(_socket) do
    uid = Ecto.UUID.generate()
    IO.inspect(uid)
    "channel_socket:#{uid}"
  end
end
