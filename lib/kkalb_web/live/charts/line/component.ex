defmodule KkalbWeb.Live.Chart.Line.Component do
  @moduledoc """
  Renders the line chart canvas.
  """
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <canvas
      id="line_chart"
      name="line_chart"
      phx-update="ignore"
      phx-hook="LineChart"
      data-chart-values={Jason.encode!(@chart_values)}
      data-chart-labels={Jason.encode!(@chart_labels)}
      data-chart-headings={Jason.encode!(@chart_headings)}
      data-chart-title={Jason.encode!(@chart_title)}
    >
    </canvas>
    """
  end
end
