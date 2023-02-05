defmodule TmpDataIOWeb.ChannelSocket do
  alias TmpDataIOWeb.TextDataChannel
  use Phoenix.Socket

  channel "text_data:*", TextDataChannel

  def connect(_param, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket) do
    to_string(Ecto.UUID.generate())
  end

end
