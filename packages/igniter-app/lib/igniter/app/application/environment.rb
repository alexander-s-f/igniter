# frozen_string_literal: true

module Igniter
  class App
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
        profile.service(name)
      end

      def contract(name)
        profile.contract(name)
      end

      def host_adapter
        @host_adapter ||= resolve_adapter(HostRegistry, profile.host_name)
      end

      def loader_adapter
        @loader_adapter ||= resolve_adapter(LoaderRegistry, profile.loader_name)
      end

      def scheduler_adapter
        @scheduler_adapter ||= resolve_adapter(SchedulerRegistry, profile.scheduler_name)
      end

      def host_config
        profile.host_config
      end

      def runtime_config
        @runtime_config ||= host_adapter.build_config(host_config)
      end

      def load_code!(base_dir:)
        loader_adapter.load!(base_dir: base_dir, paths: profile.code_paths)
        @loaded_base_dir = base_dir.to_s
        self
      end

      def start_scheduler
        scheduler_adapter.start(config: runtime_config, jobs: profile.scheduled_jobs)
        @scheduler_running = true
        self
      end

      def stop_scheduler
        scheduler_adapter.stop if scheduler_adapter.respond_to?(:stop)
        @scheduler_running = false
        self
      end

      def activate_transport!
        host_adapter.activate_transport!
        @transport_activated = true
        self
      end

      def boot(base_dir: Dir.pwd, load_code: true, start_scheduler: true, activate_transport: false)
        actions = []

        if load_code
          load_code!(base_dir: base_dir)
          actions << :code_loaded
        end

        if start_scheduler
          start_scheduler()
          actions << :scheduler_started
        end

        if activate_transport
          activate_transport!
          actions << :transport_activated
        end

        @booted = true
        BootReport.new(base_dir: base_dir.to_s, actions: actions, snapshot: snapshot)
      end

      def booted?
        @booted == true
      end

      def snapshot
        Snapshot.new(profile: profile, runtime_state: runtime_state)
      end

      def start_host
        host_adapter.start(config: runtime_config)
      end

      def rack_app
        activate_transport!
        host_adapter.rack_app(config: runtime_config)
      end

      private

      def resolve_adapter(registry_class, name)
        builder = registry_class.fetch(name)
        return builder.call if builder.respond_to?(:call)
        return builder.new if builder.is_a?(Class)

        raise ArgumentError, "cannot instantiate app adapter #{name.inspect} from #{builder.inspect}"
      end

      def runtime_state
        {
          booted: booted?,
          code_loaded: !@loaded_base_dir.nil?,
          loaded_base_dir: @loaded_base_dir,
          scheduler_running: @scheduler_running == true,
          transport_activated: @transport_activated == true,
          runtime_config_built: instance_variable_defined?(:@runtime_config)
        }
      end
    end
  end
end
