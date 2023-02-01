defmodule TmpDataIO.FileCatalog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "files" do
    field :size, :integer
    field :ttl, :integer
    field :name, :string

    belongs_to :page, TmpDataIO.TextData, references: :page, type: :string

    has_many :file_contents, TmpDataIO.FileContent,
      foreign_key: :file_id,
      on_delete: :delete_all,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(file_content, attrs) do
    file_content
    |> cast(attrs, [:id, :size, :ttl, :name])
    |> cast_assoc(:file_contents, with: &TmpDataIO.FileContent.changeset/2)
    |> cast_assoc(:page, with: &TmpDataIO.TextData.changeset/2)
    |> validate_required([:size, :ttl, :page, :name])
  end
end
