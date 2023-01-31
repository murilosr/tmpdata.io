defmodule TmpDataIO.Repo.Migrations.CreateTextData do
  use Ecto.Migration

  def change do
    create table(:text_data, primary_key: false) do
      add :page, :string, primary_key: true
      add :content, :text
      add :ttl, :integer

      timestamps()
    end
  end
end
