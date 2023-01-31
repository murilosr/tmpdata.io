defmodule TmpDataIO.TextData do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:page, :string, autogenerate: false}
  schema "text_data" do
    field :content, :string
    field :ttl, :integer, default: 3600

    timestamps()
  end

  @doc false
  def changeset(text_data, attrs \\ %{}) do
    text_data
    |> cast(attrs, [:page, :content, :ttl], empty_values: ["", [:content]])
    |> validate_required([:page, :ttl])
    |> unique_constraint(:page)
  end
end
