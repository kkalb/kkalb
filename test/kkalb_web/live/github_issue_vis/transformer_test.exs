defmodule KkalbWeb.Live.TransformerTest do
  use Kkalb.RepoCase, async: false

  alias Kkalb.Issues
  alias KkalbWeb.Live.GithubIssueVis.Transformer
  alias KkalbWeb.Live.GithubIssueVis.ChartData

  test "transformer transforms properly" do
    nv_start_time = ~N[2024-05-01 00:00:00.000000]
    chart_data = Issues.list_issues(nv_start_time) |> Transformer.convert(nv_start_time)

    assert %ChartData{
             chart_headings: %{headings: ["# of Elixir issues on Github"]},
             chart_labels: %{
               labels: [
                 ~D[2024-05-01],
                 ~D[2024-05-08],
                 ~D[2024-05-15],
                 ~D[2024-05-22],
                 ~D[2024-05-29]
               ]
             },
             chart_values: %{
               values: [2, 2, 2, 2, 2]
             },
             chart_title: %{title: "Number of Elixir issues on Github over time"}
           } == chart_data
  end
end
