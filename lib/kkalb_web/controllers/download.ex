defmodule KkalbWeb.DownloadController do
  @moduledoc false
  use KkalbWeb, :controller

  def download_portfolio(conn, _) do
    # filename = "priv/static/Kevin_Kalb_CV_2024_10.pdf"
    # file = Application.app_dir(:kkalb, filename)
    file = :kkalb |> :code.priv_dir() |> Path.join("static/images/Kevin_Kalb_CV_2024_10.pdf")
    IO.inspect(file)
    send_download(conn, {:file, file})
  end
end
