defmodule TmpDataIOWeb.UI.FileList do
  use Phoenix.Component

  def get_file_size_text(file_size) do
    mb = Float.round(file_size / 1.0e6, 2)
    kb = Float.round(file_size / 1.0e3, 2)

    cond do
      kb < 0.1 -> "#{file_size} B"
      mb < 1.0 -> "#{kb} KB"
      true -> "#{mb} MB"
    end
  end

  def render(assigns) do
    ~H"""
    <%= if Enum.empty? @files do %>
        <ul class="border rounded-lg">
            <li class="text-center p-4">
                No files uploaded
            </li>
        </ul>
    <% else %>
        <div class="flex justify-end"><%= length(@files) %> Files - <%= get_file_size_text(Enum.sum(Enum.map(@files, fn file -> file.size end))) %></div>
        <ul class="border rounded-lg">
        <%= Enum.map(@files, fn file -> %>
            <li class="downloadFile flex items-center border-b last:border-b-0 hover:bg-slate-200 first:hover:rounded-t-lg last:hover:rounded-b-lg break-all"
                file-id={"#{file.id}"} file-name={"#{file.name}"}
            >
                <span class="flex-1 hover:cursor-pointer p-4"><%= "#{file.name}" %></span>
                <span class="hover:cursor-pointer p-4"><%= get_file_size_text(file.size) %></span>
                <button class="deleteFile flex justify-center items-center mx-2 rounded-full hover:bg-slate-100 w-10 h-10">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="text-red-700 w-5 h-5">
                        <path fill-rule="evenodd" d="M16.5 4.478v.227a48.816 48.816 0 013.878.512.75.75 0 11-.256 1.478l-.209-.035-1.005 13.07a3 3 0 01-2.991 2.77H8.084a3 3 0 01-2.991-2.77L4.087 6.66l-.209.035a.75.75 0 01-.256-1.478A48.567 48.567 0 017.5 4.705v-.227c0-1.564 1.213-2.9 2.816-2.951a52.662 52.662 0 013.369 0c1.603.051 2.815 1.387 2.815 2.951zm-6.136-1.452a51.196 51.196 0 013.273 0C14.39 3.05 15 3.684 15 4.478v.113a49.488 49.488 0 00-6 0v-.113c0-.794.609-1.428 1.364-1.452zm-.355 5.945a.75.75 0 10-1.5.058l.347 9a.75.75 0 101.499-.058l-.346-9zm5.48.058a.75.75 0 10-1.498-.058l-.347 9a.75.75 0 001.5.058l.345-9z" clip-rule="evenodd" />
                    </svg>
                </button>
            </li>
        <% end) %>
        </ul>
    <% end %>
    """
  end
end
