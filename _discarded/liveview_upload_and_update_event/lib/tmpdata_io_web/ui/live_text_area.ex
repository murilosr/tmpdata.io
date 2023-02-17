defmodule TmpDataIOWeb.Ui.LiveTextArea do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <textarea id={assigns.id}><%= assigns.data.content %></textarea>
    """
  end
end
