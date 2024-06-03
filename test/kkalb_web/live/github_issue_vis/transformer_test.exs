defmodule KkalbWeb.Live.TransformerTest do
  use ExUnit.Case, async: true

  alias KkalbWeb.Live.GithubIssueVis.Transformer

  @root File.cwd!()
  @path [
    @root,
    "lib",
    "kkalb_web",
    "live",
    "github_issue_vis",
    "data",
    "example.json"
  ]
  # #replace with mock later
  @query_result @path
                |> Path.join()
                |> File.read!()
                |> Jason.decode!()

  test "working" do
    assert Map.get(@query_result, "total_count") == 5336

    @query_result
    |> Map.get("items")
    |> tap(fn items -> assert length(items) == 20 end)
    |> Enum.each(fn %{
                      "closed_at" => _closed_at,
                      "created_at" => created_at
                    } ->
      assert {:ok, _date, 0} = DateTime.from_iso8601(created_at)
    end)
  end

  test "transformer transforms properly" do
    %KkalbWeb.Live.GithubIssueVis.ChartData{
      chart_headings: %{headings: [heading]},
      chart_labels: %{labels: labels},
      chart_values: %{values: values},
      chart_title: chart_title
    } = Transformer.transform(@query_result)

    assert heading == "# of Elixir issues on Github"

    assert chart_title == ""

    assert values == [
             5340,
             5340,
             5340,
             5339,
             5340,
             5338,
             5338,
             5338,
             5338,
             5338,
             5339,
             5338,
             5336,
             5336
           ]

    assert labels == [
             ~D[2024-05-20],
             ~D[2024-05-21],
             ~D[2024-05-22],
             ~D[2024-05-23],
             ~D[2024-05-24],
             ~D[2024-05-25],
             ~D[2024-05-26],
             ~D[2024-05-27],
             ~D[2024-05-28],
             ~D[2024-05-29],
             ~D[2024-05-30],
             ~D[2024-05-31],
             ~D[2024-06-01]
           ]
  end
end
