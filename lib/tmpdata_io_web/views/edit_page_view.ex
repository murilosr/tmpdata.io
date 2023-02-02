defmodule TmpDataIOWeb.EditPageView do
  use TmpDataIOWeb, :view

  def last_update_value(last_update) do
    "#{NaiveDateTime.diff(DateTime.utc_now(), last_update, :second)} seconds ago"
  end

  def last_update(assigns) do
    case assigns.text_data.updated_at do
      nil ->
        ~H""

      updated_at ->
        ~H"""
        <span><strong>Last update: </strong><%= last_update_value(updated_at) %></span>
        """
    end
  end
end
