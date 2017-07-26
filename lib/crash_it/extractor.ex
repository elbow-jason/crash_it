defmodule CrashIt.Extractor do
  @type table :: any
  @callback run(integer, String.t) :: :ok
  @callback save(integer, any) :: :ok
  @callback parse(String.t) :: any
end