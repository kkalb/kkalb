defmodule KkalbWeb.DownloadController do
  @moduledoc false
  use KkalbWeb, :controller

  def download_portfolio(conn, _) do
    file = "priv/static/Kevin_Kalb_CV_2024_10.pdf"
    send_download(conn, {:file, file})
  end
end
