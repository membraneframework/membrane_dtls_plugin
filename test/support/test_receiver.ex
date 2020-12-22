defmodule Membrane.ICE.Support.TestReceiver do
  @moduledoc false

  use Membrane.Pipeline

  @impl true
  def handle_init(opts) do
    children = %{
      ice: %Membrane.ICE.Bin{
        stun_servers: ["64.233.161.127:19302"],
        controlling_mode: false,
        handshake_module: opts[:handshake_module],
        handshake_opts: opts[:handshake_opts]
      },
      sink: Membrane.Testing.Sink
    }

    pad = Pad.ref(:output, 1)
    links = [link(:ice) |> via_out(pad) |> to(:sink)]

    spec = %ParentSpec{
      children: children,
      links: links
    }

    {{:ok, spec: spec}, %{}}
  end
end
