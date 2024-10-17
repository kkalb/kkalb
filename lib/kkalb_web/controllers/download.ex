defmodule KkalbWeb.DownloadController do
  @moduledoc false
  use KkalbWeb, :controller

  def download_portfolio(conn, _) do
    file = :kkalb |> :code.priv_dir() |> Path.join("static/images/Kevin_Kalb_CV_2024_10.pdf")
    send_download(conn, {:file, file})
  end
end
