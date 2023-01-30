defmodule TmpDataIO.Repo do
  use Ecto.Repo,
    otp_app: :tmpdata_io,
    adapter: Ecto.Adapters.Postgres
end
