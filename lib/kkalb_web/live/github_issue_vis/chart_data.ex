defmodule KkalbWeb.Live.GithubIssueVis.ChartData do
  @moduledoc false
  defstruct chart_headings: %{headings: ["Pulling data..."]},
            chart_labels: %{labels: [""]},
            chart_values: %{values: []},
            chart_title: %{title: "Pulling data..."}

  @type t :: %__MODULE__{
          chart_headings: map(),
          chart_labels: map(),
          chart_values: map(),
          chart_title: map()
        }
end
