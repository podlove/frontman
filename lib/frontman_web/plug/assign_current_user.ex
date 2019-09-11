defmodule FrontmanWeb.Plug.AssignCurrentUser do
  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    load_current_user(conn)
  end

  def load_current_user(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil -> conn
      user -> Plug.Conn.assign(conn, :current_user, user)
    end
  end
end
