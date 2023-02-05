defmodule TmpDataIOWeb.EditPageView do
  use TmpDataIOWeb, :view

  def time_diff(text_data) do
    NaiveDateTime.diff(DateTime.utc_now(), text_data.updated_at, :second)
  end

  def last_update(assigns) do
    case assigns.text_data.updated_at do
      nil ->
        ~H""

      _ ->
        ~H"""
        <div>
          <label for="last_update_timediff" class="font-bold">Last update: </label>
          <span id="last_update_timediff"><%= time_diff(assigns.text_data) %> seconds ago</span>
        </div>
        """
    end
  end
end
