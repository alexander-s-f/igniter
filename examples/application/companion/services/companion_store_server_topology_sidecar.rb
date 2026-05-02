# frozen_string_literal: true

begin
  require "igniter/companion"
rescue LoadError
  root = File.expand_path("../../../..", __dir__)
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-store/lib"))
  $LOAD_PATH.unshift(File.join(root, "packages/igniter-companion/lib"))
  require "igniter/companion"
end

module Companion
  module Services
    class CompanionStoreServerTopologySidecar
      def self.packet
        proof = new.proof
        Contracts::CompanionStoreServerTopologySidecarContract.evaluate(proof: proof)
      end

      def proof
        native = Igniter::Store::NATIVE
        network_ready = !native &&
                        Igniter::Store.const_defined?(:NetworkBackend) &&
                        Igniter::Store.const_defined?(:StoreServer)

        {
          main_state_mutated: false,
          network_executed: false,
          wire_protocol_known: Igniter::Store.const_defined?(:WireProtocol),
          server_config_known: Igniter::Store.const_defined?(:ServerConfig),
          server_logger_known: Igniter::Store.const_defined?(:ServerLogger),
          subscription_registry_known: Igniter::Store.const_defined?(:SubscriptionRegistry),
          topology: topology,
          backend_matrix: backend_matrix(native: native, network_ready: network_ready),
          package_gap: package_gap(native: native, network_ready: network_ready),
          pressure: pressure_report
        }
      end

      private

      def topology
        {
          app_process: {
            owns: %i[contract_computation typed_facade command_boundary],
            does_not_own: %i[durable_wal store_server_replay]
          },
          store_server: {
            owns: %i[durable_facts wal replay snapshot],
            observes: %i[stats active_connections subscriptions],
            does_not_own: %i[contract_node_execution app_business_logic]
          },
          client_rebuilds: %i[scope_index partition_index read_cache],
          transport: {
            protocol: :crc32_framed_json,
            shape: :request_response_plus_push,
            operation_surface: %i[write_fact replay write_snapshot stats subscribe],
            request_response: %i[write_fact replay write_snapshot stats ping close],
            push_surface: %i[subscribe fact_written]
          },
          operational_lifecycle: {
            config: :server_config,
            logger: :server_logger,
            executable: :"igniter-store-server",
            phases: %i[configure bind ready accept drain stop],
            readiness: :wait_until_ready,
            shutdown: :graceful_drain
          },
          subscription_boundary: {
            registry: :subscription_registry,
            record: :subscription_record,
            server_event: :fact_written,
            client_handle: :subscription_handle,
            filters: :stores,
            app_contract_logic: :not_in_callback
          }
        }
      end

      def backend_matrix(native:, network_ready:)
        [
          {
            backend: :memory,
            runtime_ready: true,
            role: :embedded_hot_store
          },
          {
            backend: :file,
            runtime_ready: true,
            role: :embedded_durable_wal
          },
          {
            backend: :network,
            runtime_ready: network_ready,
            role: :remote_durable_projection_host,
            phase: native ? :native_wire_deserialization_pending : :ruby_phase_1_ready
          }
        ]
      end

      def package_gap(native:, network_ready:)
        {
          status: network_ready ? :closed : :open,
          name: :native_wire_deserialization,
          current_runtime_native: native,
          network_backend_constant: Igniter::Store.const_defined?(:NetworkBackend),
          store_server_constant: Igniter::Store.const_defined?(:StoreServer),
          blocker: network_ready ? nil : :fact_deserialize_from_wire_hash,
          package_surface: :"igniter-store"
        }
      end

      def pressure_report
        {
          next_question: :companion_typed_resolve,
          resolved: %i[
            network_backend_native_parity
            reactive_derivation
            scatter_derivation
            relation_rule_dsl
          ],
          acceptance: %i[
            native_fact_deserialize_from_wire_hash
            network_backend_available_under_native
            store_server_available_under_native
            lifecycle_support_constants_loaded_under_native
            subscription_registry_loaded_under_native
            no_contract_logic_rpc
          ],
          non_goals: %i[
            companion_backend_migration
            public_api_promise
            distributed_consensus
            event_bus_delivery
          ]
        }
      end
    end
  end
end
