alias Kkalb.Issues

start_date = Date.new!(2024, 5, 1)
end_date = Date.new!(2024, 6, 1)
range = Date.range(start_date, end_date, 7)

for {date, idx} <- Enum.with_index(range, 1) do
  datetime = NaiveDateTime.new!(date, Time.new!(12, 0, 0)) |> DateTime.from_naive!("Etc/UTC")

  # issues get closed after 7 days in seeds
  closed_at =
    if Date.diff(end_date, DateTime.to_date(datetime)) > 6 do
      datetime |> DateTime.add(7, :day) |> DateTime.to_iso8601()
    else
      nil
    end

  {:ok, _issue} =
    Issues.upsert_issue(%{
      id: idx,
      number: idx + 1000,
      gh_created_at: DateTime.to_iso8601(datetime),
      gh_updated_at: datetime |> DateTime.add(60, :minute) |> DateTime.to_iso8601(),
      gh_closed_at: closed_at
    })
end
