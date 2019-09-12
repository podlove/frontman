defmodule FrontmanWeb.PageControllerTest do
  use FrontmanWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Frontman"
  end
end
