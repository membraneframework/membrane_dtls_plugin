defmodule Membrane.DTLS.Handshake do
  @moduledoc """
  Module responsible for performing DTLS and DTLS-SRTP handshake.

  As `handshake_opts` in Sink/Source there should be passed keyword list containing following
  fields:
  * client_mode :: boolean()
  * dtls_srtp :: boolean()

  Please refer to `ExDTLS` library documentation for meaning of these fields.
  """
  @behaviour Membrane.ICE.Handshake

  alias Membrane.ICE.Handshake

  require Membrane.Logger

  @impl Handshake
  def init(opts) do
    {:ok, dtls} =
      ExDTLS.start_link(
        client_mode: opts[:client_mode],
        dtls_srtp: opts[:dtls_srtp]
      )

    {:ok, %{:dtls => dtls}}
  end

  @impl Handshake
  def connection_ready(%{dtls: dtls}) do
    ExDTLS.do_handshake(dtls)
  end

  @impl Handshake
  def recv_from_peer(%{dtls: dtls}, data) do
    ExDTLS.do_handshake(dtls, data)
  end
end
