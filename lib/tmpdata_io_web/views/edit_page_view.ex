defmodule TmpDataIOWeb.EditPageView do
  use TmpDataIOWeb, :view

  alias TmpDataIOWeb.UI.FileList

  def time_diff(text_data) do
    if text_data.updated_at == nil,
      do: 0,
      else: NaiveDateTime.diff(DateTime.utc_now(), text_data.updated_at, :second)
  end

  def last_update(assigns) do
    ~H"""
    <div class={if assigns.text_data.updated_at == nil, do: "hidden", else: ""}>
      <label for="last_update_timediff" class="font-bold">Last update: </label>
      <span id="last_update_timediff"><%= time_diff(assigns.text_data) %> seconds ago</span>
    </div>
    """
  end
end
