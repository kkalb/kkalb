defmodule KkalbWeb.Live.TransformerTest do
  use Kkalb.RepoCase, async: false

  alias Kkalb.Issues
  alias KkalbWeb.Live.GithubIssueVis.Transformer
  alias KkalbWeb.Live.GithubIssueVis.ChartData

  test "transformer transforms properly" do
    chart_data = Issues.list_issues() |> Transformer.transform()

    assert %ChartData{
             chart_headings: %{headings: ["# of Elixir issues on Github"]},
             chart_labels: %{
               labels: [
                 ~D[2024-05-10],
                 ~D[2024-05-11],
                 ~D[2024-05-12],
                 ~D[2024-05-13],
                 ~D[2024-05-14],
                 ~D[2024-05-15],
                 ~D[2024-05-16],
                 ~D[2024-05-17],
                 ~D[2024-05-18],
                 ~D[2024-05-19],
                 ~D[2024-05-20],
                 ~D[2024-05-21],
                 ~D[2024-05-22],
                 ~D[2024-05-23],
                 ~D[2024-05-24],
                 ~D[2024-05-25],
                 ~D[2024-05-26],
                 ~D[2024-05-27],
                 ~D[2024-05-28],
                 ~D[2024-05-29]
               ]
             },
             chart_values: %{
               values: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
             },
             chart_title: %{title: "Number of Elixir issues on Github over time"}
           } = chart_data
  end
end
