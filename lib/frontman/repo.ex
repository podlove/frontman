defmodule Frontman.Repo do
  use Ecto.Repo,
    otp_app: :frontman,
    adapter: Ecto.Adapters.Postgres
end
