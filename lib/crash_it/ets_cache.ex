defmodule CrashIt.EtsCache do

  # https://elixirschool.com/en/lessons/specifics/ets/
  def start_table() do
    table = :ets.new(__MODULE__, [:set, :public])
    IO.puts("CrashIt.EtsCache.start_table/0 => #{inspect table}")
    table
  end

  def put(table, key, value) do
    IO.puts("CrashIt.EtsCache.put(#{inspect table}, #{inspect key}, #{inspect value})")
    :ets.insert(table, {key, value})
  end


  def get(table, key) do
    case :ets.lookup(table, key) do
      [{^key, value}] ->
        {:ok, value}
      [] ->
        {:error, :not_found}
    end
  end

  def report(table) do
    :ets.foldl(fn {key, values}, acc -> acc |> Map.put(key, values) end, %{}, table)
  end

  def remove_table(table) do
    case :ets.delete(table) do
      true -> :ok
      _ -> :error
    end
  end

end