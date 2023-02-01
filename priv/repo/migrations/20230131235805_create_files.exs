defmodule TmpDataIO.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :page_id, :string, [references(:text_data)]
      add :name, :string
      add :size, :integer
      add :ttl, :integer

      timestamps()
    end

    create table(:file_contents, primary_key: false) do
      add :file_id, :uuid, [references(:files), primary_key: true]
      add :chunk_order, :integer, primary_key: true
      add :payload, :binary
    end
  end
end
