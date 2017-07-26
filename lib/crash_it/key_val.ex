defmodule CrashIt.KeyVal do
  @behaviour CrashIt.Extractor

  @impl CrashIt.Extractor
  def run(table, body) do
    save(table, parse(body))
  end

  @impl CrashIt.Extractor
  def save(table, result) do
    CrashIt.EtsCache.put(table, :key_val, result)
    Process.exit(self(), :normal)
  end

  @impl CrashIt.Extractor
  def parse(body) do
    body
    |> String.split("\n")
    |> Enum.filter(fn item -> String.length(item) >=3 end)
    |> Enum.map(fn line -> line |> String.split("=") end)
    |> Enum.map(fn [key, value] -> {key, value} end)
    |> Enum.into(%{})
  end

end