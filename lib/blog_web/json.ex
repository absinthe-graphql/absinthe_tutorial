defmodule BlogWeb.JSON do
  def encode!(data, _) do
    :jiffy.encode(data)
  end
  def decode(string) do
    {:ok, :jiffy.decode(string, [:return_maps])}
  end
end
