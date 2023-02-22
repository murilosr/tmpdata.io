defmodule TmpDataIOWeb.PublicTextDAO do
  alias TmpDataIO.Repo
  alias TmpDataIO.TextData

  import Ecto.Query

  def get_text_by_page_id(page_id, lazy \\ true) do
    text_data = Repo.one(from td in TextData, where: td.page == ^page_id)
    case lazy do
      false -> text_data |> Repo.preload([:files])
      true -> text_data
    end
  end

end
