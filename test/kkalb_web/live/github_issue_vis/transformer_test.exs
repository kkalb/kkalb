defmodule KkalbWeb.Live.TransformerTest do
  use Kkalb.RepoCase, async: false

  alias Kkalb.Issues
  alias KkalbWeb.Live.GithubIssueVis.Transformer

  @issue_storage Kkalb.Issues

  test "transformer transforms properly" do
    nv_start_time = ~N[2024-05-01 00:00:00.000000]
    chart_data = nv_start_time |> Issues.list_issues() |> Transformer.convert(nv_start_time, @issue_storage)

    expected_labels = [
      ~D[2024-05-01],
      ~D[2024-05-08],
      ~D[2024-05-15],
      ~D[2024-05-22],
      ~D[2024-05-29],
      ~D[2024-06-01]
    ]

    expected_values = [2, 2, 2, 2, 2, 1]

    assert chart_data.chart_labels.labels == expected_labels
    assert chart_data.chart_values.values == expected_values
  end
end
