defmodule Membrane.ICE.Support.TestSource do
  @moduledoc false

  use Membrane.Source

  def_output_pad :output,
    availability: :always,
    caps: :any,
    mode: :push

  @impl true
  def handle_init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_event(_pad, event, _context, state) do
    {{:ok, notify: {:event, event}}, state}
  end
end
