defmodule KkalbWeb.UserCookieControllerTest do
  use KkalbWeb.ConnCase, async: true

  alias KkalbWeb.UserCookieController

  test "set/2 cookie and redirect set", %{conn: conn} do
    assert %{
             resp_body: "<html><body>You are being <a href=\"/bike\">redirected</a>.</body></html>",
             resp_cookies: %{
               "bike_user_id" => %{
                 value: value,
                 max_age: 2_592_000
               }
             },
             resp_headers: resp_headers
           } = UserCookieController.set(conn, %{"user_id" => "1"})

    assert [
             {"set-cookie", set_cookie},
             {"content-type", "text/html; charset=utf-8"},
             {"cache-control", "max-age=0, private, must-revalidate"},
             {"location", "/bike"}
           ] = resp_headers

    [bike_user_id, _, _, _, _] = String.split(set_cookie, ";")

    assert "bike_user_id=" <> value == bike_user_id
  end

  test "delete/2 cookie and redirect set", %{conn: conn} do
    assert %{
             resp_body: "<html><body>You are being <a href=\"/bike\">redirected</a>.</body></html>",
             resp_cookies: %{"bike_user_id" => %{max_age: 0, sign: true, universal_time: {{1970, 1, 1}, {0, 0, 0}}}},
             resp_headers: resp_headers
           } = UserCookieController.delete(conn, %{})

    assert [
             {"set-cookie", "bike_user_id=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; max-age=0; HttpOnly"},
             {"content-type", "text/html; charset=utf-8"},
             {"cache-control", "max-age=0, private, must-revalidate"},
             {"location", "/bike"}
           ] == resp_headers
  end
end
