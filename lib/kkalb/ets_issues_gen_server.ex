defmodule Kkalb.EtsIssuesGenServer do
  @moduledoc false
  use GenServer

  @name __MODULE__

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def insert(data) do
    GenServer.call(@name, {:insert, data}, 15_000)
  end

  def get(id) do
    GenServer.call(@name, {:get, id})
  end

  def list do
    GenServer.call(@name, {:list}, 15_000)
  end

  def count do
    GenServer.call(@name, {:count}, 15_000)
  end

  def init(_) do
    :ets.new(@name, [:set, :protected, :named_table])
    %{} |> Kkalb.Workers.GithubFetcherWorker.new() |> Oban.insert()
    {:ok, :ets_created}
  end

  def handle_call({:insert, data}, _ref, state) do
    issues = :ets.insert_new(@name, data)
    {:reply, issues, state}
  end

  def handle_call({:get, id}, _ref, state) do
    issue = :ets.lookup(@name, id)

    {:reply, issue, state}
  end

  def handle_call({:list}, _ref, state) do
    issues = :ets.tab2list(@name)
    {:reply, issues, state}
  end

  def handle_call({:count}, _ref, state) do
    count_issues = @name |> :ets.tab2list() |> Enum.count()
    {:reply, count_issues, state}
  end
end
