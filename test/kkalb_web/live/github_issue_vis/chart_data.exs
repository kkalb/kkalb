defmodule KkalbWeb.GithubIssueVis.ChartDataTest do
  use ExUnit.Case, async: true

  alias KkalbWeb.Live.GithubIssueVis.ChartData

  test "builds default chart data properly" do
    assert %ChartData{
             chart_headings: %{headings: ["Pulling data..."]},
             chart_labels: %{labels: [""]},
             chart_values: %{values: []},
             chart_title: %{title: "Pulling data..."}
           } = %ChartData{}
  end

  test "sets chart data properly" do
    chart_data = %ChartData{
      chart_headings: %{headings: ["Some data heading"]},
      chart_labels: %{labels: ["first", "second"]},
      chart_values: %{values: [42, 1337]},
      chart_title: %{title: "Some chart title"}
    }

    assert ["Some data heading"] == chart_data.chart_headings.headings
    assert ["first", "second"] == chart_data.chart_labels.labels
    assert [42, 1337] == chart_data.chart_values.values
    assert "Some chart title" == chart_data.chart_title.title
  end
end
