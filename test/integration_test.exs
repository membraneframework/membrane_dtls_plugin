defmodule Membrane.DTLS.IntegrationTest do
  use ExUnit.Case, async: true

  import Membrane.Testing.Assertions

  alias Membrane.Testing

  test "ice trickle with DTLS-SRTP handshake" do
    {:ok, tx_pid} =
      Testing.Pipeline.start_link(%Testing.Pipeline.Options{
        module: Membrane.ICE.Support.TestSender,
        custom_args: [
          handshake_module: Membrane.DTLS.Handshake,
          handshake_opts: [client_mode: true, dtls_srtp: true]
        ]
      })

    {:ok, rx_pid} =
      Testing.Pipeline.start_link(%Testing.Pipeline.Options{
        module: Membrane.ICE.Support.TestReceiver,
        custom_args: [
          handshake_module: Membrane.DTLS.Handshake,
          handshake_opts: [client_mode: false, dtls_srtp: true]
        ]
      })

    Testing.Pipeline.play(tx_pid)
    Testing.Pipeline.play(rx_pid)

    # set credentials
    assert_pipeline_notified(rx_pid, :ice, {:local_credentials, rx_credentials})
    cred_msg = {:set_remote_credentials, rx_credentials}
    Testing.Pipeline.message_child(tx_pid, :ice, cred_msg)

    assert_pipeline_notified(tx_pid, :ice, {:local_credentials, tx_credentials})
    cred_msg = {:set_remote_credentials, tx_credentials}
    Testing.Pipeline.message_child(rx_pid, :ice, cred_msg)

    # start connectivity checks and perform handshake
    {tx_handshake_data, rx_handshake_data} = set_remote_candidates(tx_pid, rx_pid)
    {tx_local_km, tx_remote_km, tx_protection_profile} = tx_handshake_data
    {rx_local_km, rx_remote_km, rx_protection_profile} = rx_handshake_data
    assert tx_local_km == rx_remote_km
    assert tx_remote_km == rx_local_km
    assert tx_protection_profile == rx_protection_profile

    {client_master_key, server_master_key, crypto_profile} = tx_handshake_data
    assert byte_size(client_master_key) > 0
    assert byte_size(client_master_key) == byte_size(server_master_key)
  end

  defp set_remote_candidates(
         tx_pid,
         rx_pid,
         tx_handshake_data \\ nil,
         rx_handshake_data \\ nil
       )

  defp set_remote_candidates(_tx_pid, _rx_pid, tx_handshake_data, rx_handshake_data)
       when tx_handshake_data != nil and rx_handshake_data != nil do
    {tx_handshake_data, rx_handshake_data}
  end

  defp set_remote_candidates(tx_pid, rx_pid, tx_handshake_data, rx_handshake_data) do
    # same both in tx_stream and rx_stream
    component_id = 1

    receive do
      {_tx_mod, ^tx_pid, {:handle_notification, {{:new_candidate_full, tx_cand}, :ice}}} ->
        msg = {:set_remote_candidate, tx_cand, component_id}
        Testing.Pipeline.message_child(rx_pid, :ice, msg)
        set_remote_candidates(tx_pid, rx_pid, tx_handshake_data, rx_handshake_data)

      {_tx_mod, ^tx_pid,
       {:handle_notification, {{:event, %{handshake_data: handshake_data}}, :source}}} ->
        set_remote_candidates(tx_pid, rx_pid, handshake_data, rx_handshake_data)

      {_rx_mod, ^rx_pid, {:handle_notification, {{:new_candidate_full, rx_cand}, :ice}}} ->
        msg = {:set_remote_candidate, rx_cand, component_id}
        Testing.Pipeline.message_child(tx_pid, :ice, msg)
        set_remote_candidates(tx_pid, rx_pid, tx_handshake_data, rx_handshake_data)

      {_rx_mod, ^rx_pid,
       {:handle_notification, {{:event, %{handshake_data: handshake_data}}, :sink}}} ->
        set_remote_candidates(tx_pid, rx_pid, tx_handshake_data, handshake_data)

      _other ->
        set_remote_candidates(tx_pid, rx_pid, tx_handshake_data, rx_handshake_data)
    after
      2000 -> assert false
    end
  end
end
