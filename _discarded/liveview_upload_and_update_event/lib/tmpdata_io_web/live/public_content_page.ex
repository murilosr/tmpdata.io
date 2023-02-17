defmodule TmpDataIOWeb.PublicContentPage do
  use TmpDataIOWeb, :live_view
  alias TmpDataIO.TextData
  alias TmpDataIO.Repo
  import Ecto.Query
  alias TmpDataIOWeb.Ui.LiveTextArea

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

  @impl Phoenix.LiveView
  def mount(%{"page_id" => page_id}, _session, socket) do
    text_data =
      case Repo.one(from td in TextData, where: td.page == ^page_id) do
        nil -> %TextData{page: page_id, content: ""}
        row -> row
      end

    text_data = Repo.preload(text_data, [:files])

    socket =
      assign(socket,
        page_id: page_id,
        text_data: text_data,
        conn: socket,
        page_title: page_id,
        upload_entry: %{}
      )

    socket =
      allow_upload(socket, :files,
        accept: :any,
        max_entries: 3,
        max_file_size: trunc(512 * 1024 * 1024),
        progress: &handle_progress/3,
        chunk_size: 1024 * 1024,
        auto_upload: true
      )

    TmpDataIOWeb.Endpoint.subscribe("text_data:#{page_id}")
    IO.puts("Subscribed text_data:#{page_id}")

    {:ok, socket, temporary_assigns: [upload_entry: %{}]}
  end

  @impl true
  def handle_info(%{event: "update_textarea", payload: text_data}, socket) do
    IO.puts("Evento update_textarea #{inspect(text_data)}")
    Phoenix.LiveView.send_update(self(), __MODULE__, id: "my_text_area", text_data: text_data)

    socket = assign(socket,text_data: text_data)

    {:noreply, socket}
  end

  def handle_event("text_data_change", %{"value" => text_value}, socket) do
    page_id = socket.assigns.page_id

    text_data =
      case Repo.one(from td in TextData, where: td.page == ^page_id) do
        nil -> %TextData{page: page_id}
        row -> row
      end
      |> TextData.changeset(%{content: text_value, ttl: 3600})
      |> Repo.insert_or_update!()
      |> Repo.preload([:files])

    IO.puts("Broadcast text_data:#{page_id}")

    TmpDataIOWeb.Endpoint.broadcast(
      # self(),
      "text_data:#{page_id}",
      "update_textarea",
      text_data
    )

    {:noreply, socket}
  end

  def handle_progress(:files, entry, socket) do
    # IO.puts("Progress event")
    # IO.inspect(entry)

    if entry.done? do
      IO.puts("done :)")

      consume_uploaded_entry(socket, entry, fn %{path: path} ->
        IO.puts("Uploaded entry: #{path}")
        {:ok, ""}
      end)

      socket =
        assign(socket, :upload_entry, %{id: entry.uuid, name: entry.client_name, progress: 100})

      {:noreply, socket}
    else
      if Integer.mod(entry.progress, 5) == 0 do
        socket =
          assign(socket, :upload_entry, %{
            id: entry.uuid,
            name: entry.client_name,
            progress: entry.progress
          })

        {:noreply, socket}
      else
        {:noreply, socket}
      end
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate", params, socket) do
    # IO.puts("validate event")
    # IO.inspect(params)
    # IO.inspect(socket.assigns.uploads)
    {:noreply, socket}
  end

  # def handle_event("save", _params, socket) do
  #   IO.puts("save event")
  #   IO.inspect(socket.assigns.uploads)

  #   IO.inspect(uploaded_entries(socket, :files))

  #   case uploaded_entries(socket, :files) do
  #     {[_ | _] = completed, []} ->
  #       # all entries are completed
  #       IO.puts("Completed")
  #       IO.inspect(completed)
  #       consume_uploaded_entries(socket, :files, fn %{path: path}, _entry ->
  #         IO.puts("Uploaded entry: #{path}")
  #       end)

  #     {[], [_ | _] = in_progress} ->
  #       IO.puts("In progess")
  #       IO.inspect(in_progress)
  #       # all entries are still in progress

  #     { [], [] = no_file_uploaded } ->
  #       IO.puts("No file uploaded")
  #       IO.inspect(no_file_uploaded)
  #   end

  #   {:noreply, socket}
  # end
end
