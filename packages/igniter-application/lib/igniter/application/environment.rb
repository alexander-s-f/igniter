# frozen_string_literal: true

module Igniter
  module Application
    class Environment
      attr_reader :profile

      def initialize(profile:)
        @profile = profile
      end

      def contracts
        @contracts ||= Igniter::Contracts::Environment.new(profile: profile.contracts_profile)
      end

      def compile(&block)
        contracts.compile(&block)
      end

      def validation_report(&block)
        contracts.validation_report(&block)
      end

      def compilation_report(&block)
        contracts.compilation_report(&block)
      end

      def execute(compiled_graph, inputs:)
        contracts.execute(compiled_graph, inputs: inputs)
      end

      def execute_with(executor_name, compiled_graph, inputs:, runtime: Igniter::Contracts::Execution::Runtime)
        contracts.execute_with(executor_name, compiled_graph, inputs: inputs, runtime: runtime)
      end

      def run(inputs:, &block)
        contracts.run(inputs: inputs, &block)
      end

      def diagnose(result)
        contracts.diagnose(result)
      end

      def apply_effect(effect_name, payload:, context: {})
        contracts.apply_effect(effect_name, payload: payload, context: context)
      end

      def service(name)
        return profile.service(name) if profile.supports_service?(name)

        resolved_provider_services.fetch(name.to_sym)
      end

      def service_definition(name)
        return profile.service_definition(name) if profile.service_registry.service?(name)

        resolved_provider_service_definitions.fetch(name.to_sym)
      end

      def interface(name)
        return profile.interface_definition(name).callable if profile.service_registry.interface?(name)

        resolved_provider_interfaces.fetch(name.to_sym)
      end

      def interface_definition(name)
        return profile.interface_definition(name) if profile.service_registry.interface?(name)

        resolved_provider_interface_definitions.fetch(name.to_sym)
      end

      def contract(name)
        profile.contract(name)
      end

      def config
        profile.config
      end

      def providers
        profile.providers
      end

      def provider(name)
        providers.find { |entry| entry.name == name.to_sym }&.provider || raise(KeyError, "unknown provider #{name.inspect}")
      end

      def host_seam
        profile.host_seam
      end

      def loader_seam
        profile.loader_seam
      end

      def scheduler_seam
        profile.scheduler_seam
      end

      def session_store
        profile.session_store_seam
      end

      def compose_invoker(invoker: Igniter::Extensions::Contracts::ComposePack::LocalInvoker, namespace: :compose, metadata: {}, id_generator: nil)
        ComposeInvoker.new(
          environment: self,
          invoker: invoker,
          namespace: namespace,
          metadata: metadata,
          id_generator: id_generator
        )
      end

      def remote_compose_invoker(transport:, namespace: :remote_compose, metadata: {}, id_generator: nil)
        compose_invoker(
          namespace: namespace,
          metadata: metadata.merge(remote: true),
          id_generator: id_generator,
          invoker: ComposeTransportAdapter.new(
            transport: transport,
            metadata: metadata.merge(remote: true, namespace: namespace.to_s)
          )
        )
      end

      def collection_invoker(invoker: Igniter::Extensions::Contracts::CollectionPack::LocalInvoker, namespace: :collection, metadata: {}, id_generator: nil)
        CollectionInvoker.new(
          environment: self,
          invoker: invoker,
          namespace: namespace,
          metadata: metadata,
          id_generator: id_generator
        )
      end

      def remote_collection_invoker(transport:, namespace: :remote_collection, metadata: {}, id_generator: nil)
        collection_invoker(
          namespace: namespace,
          metadata: metadata.merge(remote: true),
          id_generator: id_generator,
          invoker: CollectionTransportAdapter.new(
            transport: transport,
            metadata: metadata.merge(remote: true, namespace: namespace.to_s)
          )
        )
      end

      def load_code!(base_dir:)
        loader_seam.load!(base_dir: base_dir, paths: profile.code_paths, environment: self)
        @loaded_base_dir = base_dir.to_s
        self
      end

      def start_scheduler
        scheduler_seam.start(environment: self)
        @scheduler_running = true
        self
      end

      def stop_scheduler
        scheduler_seam.stop(environment: self) if scheduler_seam.respond_to?(:stop)
        @scheduler_running = false
        self
      end

      def activate_transport!
        host_seam.activate!(environment: self)
        @transport_activated = true
        self
      end

      def boot(base_dir: Dir.pwd, load_code: true, start_scheduler: true, activate_transport: false)
        phases = []

        if load_code
          load_code!(base_dir: base_dir)
          phases << BootPhase.new(name: :load_code, status: :completed)
        else
          phases << BootPhase.new(name: :load_code, status: :skipped)
        end

        resolve_providers!
        phases << BootPhase.new(name: :resolve_providers, status: :completed)

        if start_scheduler
          start_scheduler()
          phases << BootPhase.new(name: :start_scheduler, status: :completed)
        else
          phases << BootPhase.new(name: :start_scheduler, status: :skipped)
        end

        if activate_transport
          activate_transport!
          phases << BootPhase.new(name: :activate_transport, status: :completed)
        else
          phases << BootPhase.new(name: :activate_transport, status: :skipped)
        end

        @booted = true
        BootReport.new(base_dir: base_dir.to_s, phases: phases, snapshot: snapshot)
      end

      def booted?
        @booted == true
      end

      def snapshot
        Snapshot.new(profile: profile, runtime_state: runtime_state)
      end

      def fetch_session(id)
        session_store.fetch(id)
      end

      def sessions
        session_store.entries
      end

      def run_compose_session(session_id:, compiled_graph:, inputs:, invoker: Igniter::Extensions::Contracts::ComposePack::LocalInvoker, operation_name: nil, metadata: {})
        session_metadata = metadata.merge(
          operation_name: (operation_name || session_id).to_sym,
          profile_fingerprint: profile.contracts_profile.fingerprint
        )
        running_entry = SessionEntry.new(
          id: session_id,
          kind: :compose,
          status: :running,
          metadata: session_metadata,
          payload: { inputs: inputs }
        )
        session_store.write(running_entry)

        operation = Igniter::Contracts::Operation.new(kind: :compose, name: operation_name || session_id, attributes: {})
        invocation = Igniter::Extensions::Contracts::ComposePack::Invocation.new(
          operation: operation,
          compiled_graph: compiled_graph,
          inputs: inputs,
          profile: profile.contracts_profile
        )
        raw_result = invoker.call(invocation: invocation)
        result, transport_metadata = normalize_compose_session_result(raw_result)
        unless result.is_a?(Igniter::Contracts::ExecutionResult)
          raise Igniter::Contracts::Error,
                "compose session invoker for #{session_id} must return an ExecutionResult"
        end

        session_store.write(
          running_entry.with_update(
            status: :completed,
            payload: {
              inputs: inputs,
              outputs: result.outputs.to_h,
              output_names: result.outputs.keys,
              transport: transport_metadata
            }
          )
        )
        result
      rescue StandardError => error
        session_store.write(
          running_entry.with_update(
            status: :failed,
            payload: {
              inputs: inputs,
              error: {
                class: error.class.name,
                message: error.message
              }
            }
          )
        )
        raise
      end

      def run_collection_session(session_id:, items:, compiled_graph:, key:, inputs: {}, invoker: Igniter::Extensions::Contracts::CollectionPack::LocalInvoker, window: nil, operation_name: nil, metadata: {})
        session_metadata = metadata.merge(
          operation_name: (operation_name || session_id).to_sym,
          key: key.to_sym,
          profile_fingerprint: profile.contracts_profile.fingerprint
        )
        running_entry = SessionEntry.new(
          id: session_id,
          kind: :collection,
          status: :running,
          metadata: session_metadata,
          payload: {
            inputs: inputs,
            item_count: Array(items).size
          }
        )
        session_store.write(running_entry)

        operation = Igniter::Contracts::Operation.new(kind: :collection, name: operation_name || session_id, attributes: {})
        invocation = Igniter::Extensions::Contracts::CollectionPack::Invocation.new(
          operation: operation,
          items: items,
          inputs: inputs,
          compiled_graph: compiled_graph,
          profile: profile.contracts_profile,
          key_name: key,
          window: window
        )
        raw_result = invoker.call(invocation: invocation)
        result, transport_metadata = normalize_collection_session_result(raw_result)
        unless result.is_a?(Igniter::Extensions::Contracts::Dataflow::CollectionResult)
          raise Igniter::Contracts::Error,
                "collection session invoker for #{session_id} must return a CollectionResult"
        end

        session_store.write(
          running_entry.with_update(
            status: :completed,
            payload: {
              inputs: inputs,
              item_count: Array(items).size,
              keys: result.keys,
              summary: result.summary,
              transport: transport_metadata
            }
          )
        )
        result
      rescue StandardError => error
        session_store.write(
          running_entry.with_update(
            status: :failed,
            payload: {
              inputs: inputs,
              item_count: Array(items).size,
              error: {
                class: error.class.name,
                message: error.message
              }
            }
          )
        )
        raise
      end

      def start_host
        activate_transport!
        host_seam.start(environment: self)
      end

      def rack_app
        activate_transport!
        host_seam.rack_app(environment: self)
      end

      private

      def resolve_providers!
        @resolved_provider_services = {}
        @resolved_provider_service_definitions = {}
        @resolved_provider_interfaces = {}
        @resolved_provider_interface_definitions = {}

        providers.each do |registration|
          services = registration.provider.services(environment: self)
          interfaces = registration.provider.interfaces(environment: self)

          normalize_provider_entries(
            services,
            registration: registration,
            definition_class: ServiceDefinition,
            values_map: @resolved_provider_services,
            definitions_map: @resolved_provider_service_definitions
          )
          normalize_provider_entries(
            interfaces,
            registration: registration,
            definition_class: Interface,
            values_map: @resolved_provider_interfaces,
            definitions_map: @resolved_provider_interface_definitions
          )

          @resolved_provider_interfaces.each do |name, callable|
            @resolved_provider_services[name] ||= callable
            @resolved_provider_service_definitions[name] ||= ServiceDefinition.new(
              name: name,
              callable: callable,
              metadata: @resolved_provider_interface_definitions.fetch(name).metadata,
              source: registration.name
            )
          end
          registration.provider.boot(environment: self) if registration.provider.respond_to?(:boot)
        end

        @resolved_provider_services.freeze
        @resolved_provider_service_definitions.freeze
        @resolved_provider_interfaces.freeze
        @resolved_provider_interface_definitions.freeze
        @providers_resolved = true
        self
      end

      def resolved_provider_services
        return @resolved_provider_services if defined?(@resolved_provider_services)

        resolve_providers!
        @resolved_provider_services
      end

      def resolved_provider_service_definitions
        return @resolved_provider_service_definitions if defined?(@resolved_provider_service_definitions)

        resolve_providers!
        @resolved_provider_service_definitions
      end

      def resolved_provider_interfaces
        return @resolved_provider_interfaces if defined?(@resolved_provider_interfaces)

        resolve_providers!
        @resolved_provider_interfaces
      end

      def resolved_provider_interface_definitions
        return @resolved_provider_interface_definitions if defined?(@resolved_provider_interface_definitions)

        resolve_providers!
        @resolved_provider_interface_definitions
      end

      def normalize_provider_entries(entries, registration:, definition_class:, values_map:, definitions_map:)
        return if entries.nil?

        entries.each do |name, value|
          definition =
            if value.is_a?(definition_class)
              value
            elsif value.is_a?(ServiceDefinition) && definition_class == ServiceDefinition
              value
            else
              definition_class.new(name: name, callable: value, source: registration.name)
            end

          values_map[definition.name] = definition.callable
          definitions_map[definition.name] = definition
        end
      end

      def runtime_state
        {
          booted: booted?,
          code_loaded: !@loaded_base_dir.nil?,
          loaded_base_dir: @loaded_base_dir,
          providers_resolved: @providers_resolved == true,
          scheduler_running: @scheduler_running == true,
          transport_activated: @transport_activated == true,
          session_count: session_store.entries.size
        }
      end

      def normalize_compose_session_result(raw_result)
        if raw_result.is_a?(TransportResponse)
          [raw_result.result, raw_result.metadata]
        else
          [raw_result, {}]
        end
      end

      def normalize_collection_session_result(raw_result)
        if raw_result.is_a?(TransportResponse)
          [raw_result.result, raw_result.metadata]
        else
          [raw_result, {}]
        end
      end
    end
  end
end
