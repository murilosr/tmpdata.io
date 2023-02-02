defmodule TmpDataIO.TextData do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:page, :string, autogenerate: false}
  schema "text_data" do
    field :content, :string
    field :ttl, :integer, default: 3600

    has_many :files, TmpDataIO.FileCatalog, foreign_key: :page_id, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(text_data, attrs \\ %{}) do
    text_data
    |> cast(attrs, [:page, :content, :ttl], empty_values: ["", [:content]])
    |> validate_required([:page, :ttl])
    |> unique_constraint(:page)
  end

  def get_lazy_reference(page_id) do
    %TmpDataIO.TextData{page: page_id}
    |> Ecto.put_meta(state: :loaded)
  end

end
