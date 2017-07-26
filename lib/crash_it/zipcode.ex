defmodule CrashIt.Zipcode do
  @behaviour CrashIt.Extractor
  @zipcode_regex ~r/\d{5}/

  @impl CrashIt.Extractor
  def run(table, body) do
    save(table, parse(body))
  end

  @impl CrashIt.Extractor
  def save(table, result) do
    CrashIt.EtsCache.put(table, :zipcode, result)
    Process.exit(self(), :normal)
  end

  @impl CrashIt.Extractor
  def parse(body) do
    Regex.scan(@zipcode_regex, body)
    |> List.flatten
  end


end