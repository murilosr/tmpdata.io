defmodule TmpDataIO.FileContent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "file_contents" do
    field :file_id, Ecto.UUID, primary_key: true
    field :chunk_order, :integer, primary_key: true
    field :payload, :binary
  end

  @doc false
  def changeset(file_content, attrs) do
    file_content
    |> cast(attrs, [:file_id, :chunk_order, :payload])
    |> validate_required([:file_id, :chunk_order, :payload])
  end
end
