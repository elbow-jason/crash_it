defmodule CrashIt.Json do
  @behaviour CrashIt.Extractor
  
  @impl CrashIt.Extractor
  def run(table, body) do
    save(table, parse(body))
  end

  @impl CrashIt.Extractor
  def save(table, result) do
    CrashIt.EtsCache.put(table, :json, result)
    Process.exit(self(), :normal)
  end

  @impl CrashIt.Extractor
  def parse(body) do
    body
    |> Poison.decode!
  end

   
end