defmodule CrashIt do
  @moduledoc """
  Documentation for CrashIt.
  """
  @table_ttl 15_000

  def run(body) do
    table = CrashIt.EtsCache.start_table()
    _fin = finalizer(table, self())
    keyval = spawn_and_monitor(:key_val, fn -> CrashIt.KeyVal.run(table, body) end)
    json = spawn_and_monitor(:json, fn -> CrashIt.Json.run(table, body) end)
    zips = spawn_and_monitor(:zipcode, fn -> CrashIt.Zipcode.run(table, body) end)
    # watch_and_wait([keyval], table)
    watch_and_wait([keyval, json, zips], table)
  end

  def report_back(table, pid) do
    send pid, {:report, report_and_cleanup(table)}
  end

  defp report_and_cleanup(table) do
    report = CrashIt.EtsCache.report(table)
    CrashIt.EtsCache.remove_table(table)
    report
  end

  defp watch_and_wait([], table) do
    report_and_cleanup(table)
  end
  defp watch_and_wait(named_processes, table) do
    IO.puts("named_proc #{inspect named_processes}")
    receive do
      {:DOWN, ref, _, _pid, reason} ->
        IO.puts("got down #{inspect ref}")
        named_processes
        |> remove_named_ref(ref, reason)
        |> watch_and_wait(table)
      {:report, report} ->
        {:ok, report}
      thing ->
        IO.puts("thing #{inspect thing}")
      after 1000 ->
        CrashIt.EtsCache.remove_table(table)
        raise "CrashIt.finalizer went poof"
    end
  end

  defp spawn_and_monitor(name, func) do
    # {pid, ref} = spawn_monitor(func)
    pid = spawn(func)
    ref = Process.monitor(pid)
    {name, pid, ref}
  end

  defp finalizer(table, pid) do
    spawn(fn ->
      receive do
        :report ->
          report_back(table, pid)
        after @table_ttl ->
          report_back(table, pid)
      end
    end)
  end

  defp remove_named_ref(named_processes, ref, reason) do
    named_processes
    |> Enum.filter(fn
      {name, _, ^ref} ->
        IO.puts("#{inspect name} finished => #{inspect reason}")
        # this returns :ok
        false
      _ ->
        true
    end)
  end

end
