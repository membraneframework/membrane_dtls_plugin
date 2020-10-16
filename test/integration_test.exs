defmodule Membrane.DTLS.IntegrationTest do
  use ExUnit.Case, async: true

  import Membrane.Testing.Assertions

  alias Membrane.Testing

  test "ice trickle with DTLS-SRTP handshake" do
    tx_pipeline_custom_args = [
      handshake_module: Membrane.DTLS.Handshake,
      handshake_opts: [client_mode: true, dtls_srtp: true]
    ]

    rx_pipeline_custom_args = [
      handshake_module: Membrane.DTLS.Handshake,
      handshake_opts: [client_mode: false, dtls_srtp: true]
    ]

    {:ok, tx_pid} =
      Testing.Pipeline.start_link(%Testing.Pipeline.Options{
        module: Membrane.ICE.Support.TestSender,
        custom_args: tx_pipeline_custom_args
      })

    {:ok, rx_pid} =
      Testing.Pipeline.start_link(%Testing.Pipeline.Options{
        module: Membrane.ICE.Support.TestReceiver,
        custom_args: rx_pipeline_custom_args
      })

    # setup sink
    Testing.Pipeline.message_child(tx_pid, :sink, :get_local_credentials)
    assert_pipeline_notified(tx_pid, :sink, {:local_credentials, tx_credentials})

    # setup source
    Testing.Pipeline.message_child(rx_pid, :source, :get_local_credentials)
    assert_pipeline_notified(rx_pid, :source, {:local_credentials, rx_credentials})

    # set credentials
    cred_msg = {:set_remote_credentials, rx_credentials}
    Testing.Pipeline.message_child(tx_pid, :sink, cred_msg)

    cred_msg = {:set_remote_credentials, tx_credentials}
    Testing.Pipeline.message_child(rx_pid, :source, cred_msg)

    # start connectivity checks and perform handshake
    Testing.Pipeline.message_child(tx_pid, :sink, :gather_candidates)
    Testing.Pipeline.message_child(rx_pid, :source, :gather_candidates)
    {tx_handshake_data, rx_handshake_data} = set_remote_candidates(tx_pid, rx_pid)
    assert tx_handshake_data == rx_handshake_data
  end

  defp set_remote_candidates(
         tx_pid,
         rx_pid,
         tx_handshake_data \\ nil,
         rx_handshake_data \\ nil,
         tx_ready \\ false,
         rx_ready \\ false
       )

  defp set_remote_candidates(_tx_pid, _rx_pid, tx_handshake_data, rx_handshake_data, true, true) do
    {tx_handshake_data, rx_handshake_data}
  end

  defp set_remote_candidates(
         tx_pid,
         rx_pid,
         tx_handshake_data,
         rx_handshake_data,
         tx_ready,
         rx_ready
       ) do
    # same both in tx_stream and rx_stream
    component_id = 1

    receive do
      {_tx_mod, ^tx_pid, {:handle_notification, {{:new_candidate_full, tx_cand}, :sink}}} ->
        msg = {:set_remote_candidate, tx_cand, component_id}
        Testing.Pipeline.message_child(rx_pid, :source, msg)

        set_remote_candidates(
          tx_pid,
          rx_pid,
          tx_handshake_data,
          rx_handshake_data,
          tx_ready,
          rx_ready
        )

      {_rx_mod, ^rx_pid,
       {:handle_notification, {{:component_state_ready, _component_id, handshake_data}, :source}}} ->
        set_remote_candidates(tx_pid, rx_pid, tx_handshake_data, handshake_data, tx_ready, true)

      {_rx_mod, ^rx_pid, {:handle_notification, {{:new_candidate_full, rx_cand}, :source}}} ->
        msg = {:set_remote_candidate, rx_cand, component_id}
        Testing.Pipeline.message_child(tx_pid, :sink, msg)

        set_remote_candidates(
          tx_pid,
          rx_pid,
          tx_handshake_data,
          rx_handshake_data,
          tx_ready,
          rx_ready
        )

      {_tx_mod, ^tx_pid,
       {:handle_notification, {{:component_state_ready, _component_id, handshake_data}, :sink}}} ->
        set_remote_candidates(tx_pid, rx_pid, handshake_data, rx_handshake_data, true, rx_ready)

      _other ->
        set_remote_candidates(
          tx_pid,
          rx_pid,
          tx_handshake_data,
          rx_handshake_data,
          tx_ready,
          rx_ready
        )
    after
      2000 -> assert false
    end
  end
end
