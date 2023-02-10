defmodule TmpDataIOWeb.EditPageView do
  use TmpDataIOWeb, :view

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

  def get_file_size_text(file_size) do
    mb = Float.round(file_size / 1.0e6, 2)
    kb = Float.round(file_size / 1.0e3, 2)

    cond do
      kb < 0.1 -> "#{file_size} B"
      mb < 1.0 -> "#{kb} KB"
      true -> "#{mb} MB"
    end
  end
end
