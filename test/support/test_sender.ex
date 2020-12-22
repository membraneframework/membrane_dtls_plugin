defmodule Membrane.ICE.Support.TestSender do
  @moduledoc false

  use Membrane.Pipeline

  @impl true
  def handle_init(opts) do
    children = %{
      source: Membrane.ICE.Support.TestSource,
      ice: %Membrane.ICE.Bin{
        stun_servers: ["64.233.161.127:19302"],
        controlling_mode: true,
        handshake_module: opts[:handshake_module],
        handshake_opts: opts[:handshake_opts]
      }
    }

    pad = Pad.ref(:input, 1)
    links = [link(:source) |> via_out(:output) |> via_in(pad) |> to(:ice)]

    spec = %ParentSpec{children: children, links: links}
    {{:ok, spec: spec}, %{}}
  end
end
