defmodule KkalbWeb.UserCookieController do
  use KkalbWeb, :controller

  def set(conn, %{"user_id" => bike_user_id}) do
    conn
    |> put_resp_cookie("bike_user_id", bike_user_id, sign: true, max_age: 60 * 60 * 24 * 30)
    |> put_session("bike_user_id", bike_user_id)
    |> redirect(to: ~p"/bike")
  end
end
