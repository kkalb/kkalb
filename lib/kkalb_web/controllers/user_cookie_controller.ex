defmodule KkalbWeb.UserCookieController do
  use KkalbWeb, :controller

  # sets user_id as cookie (client) and in the session (server)
  def set(conn, %{"user_id" => bike_user_id}) do
    conn
    |> put_resp_cookie("bike_user_id", bike_user_id, sign: true, max_age: 60 * 60 * 24 * 30)
    |> put_session("bike_user_id", bike_user_id)
    |> redirect(to: ~p"/bike")
  end

  # deletes user_id as cookie (client) and from the session (server)
  def delete(conn, %{}) do
    conn
    |> delete_resp_cookie("bike_user_id", sign: true, max_age: 60 * 60 * 24 * 30)
    |> delete_session("bike_user_id")
    |> redirect(to: ~p"/bike")
  end
end
