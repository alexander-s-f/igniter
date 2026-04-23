# frozen_string_literal: true

module Igniter
  module Application
    class Kernel
      PATH_GROUPS = %i[contracts executors tools agents skills].freeze

      attr_reader :contracts_kernel, :contracts_packs, :application_packs, :providers,
                  :services, :service_definitions, :interfaces, :registrations,
                  :scheduled_jobs, :code_paths, :host_seam, :loader_seam, :scheduler_seam,
                  :session_store_seam, :config_builder

      def initialize(contracts_kernel: Igniter::Contracts.build_kernel)
        @contracts_kernel = contracts_kernel
        @contracts_packs = []
        @application_packs = []
        @providers = []
        @services = {}
        @service_definitions = {}
        @interfaces = {}
        @registrations = {}
        @scheduled_jobs = []
        @code_paths = {}
        @config_builder = ConfigBuilder.new
        @host_name = :embedded
        @loader_name = :manual
        @scheduler_name = :manual
        @host_seam = EmbeddedHost.new
        @loader_seam = ManualLoader.new
        @scheduler_seam = ManualScheduler.new
        @session_store_name = :memory
        @session_store_seam = MemorySessionStore.new
      end

      def install_pack(pack)
        if pack.respond_to?(:install_into_application_kernel)
          pack.install_into_application_kernel(self)
          @application_packs |= [pack]
        elsif pack.respond_to?(:install_into)
          contracts_kernel.install(pack)
          @contracts_packs |= [pack]
        else
          raise ArgumentError, "application pack #{pack.inspect} must implement install_into_application_kernel or install_into"
        end

        self
      end

      def install_contracts(*packs)
        packs.flatten.compact.each do |pack|
          contracts_kernel.install(pack)
          @contracts_packs |= [pack]
        end
        self
      end

      def host(name = nil, seam: nil, &block)
        return @host_name if name.nil? && seam.nil? && !block

        @host_name = name.to_sym unless name.nil?
        @host_seam = resolve_seam(seam, block, current: @host_seam, required_methods: %i[activate! start rack_app], label: "host")
        self
      end

      def loader(name = nil, seam: nil, &block)
        return @loader_name if name.nil? && seam.nil? && !block

        @loader_name = name.to_sym unless name.nil?
        @loader_seam = resolve_seam(seam, block, current: @loader_seam, required_methods: %i[load!], label: "loader")
        self
      end

      def scheduler(name = nil, seam: nil, &block)
        return @scheduler_name if name.nil? && seam.nil? && !block

        @scheduler_name = name.to_sym unless name.nil?
        @scheduler_seam = resolve_seam(seam, block, current: @scheduler_seam, required_methods: %i[start], label: "scheduler")
        self
      end

      def session_store(name = nil, seam: nil, &block)
        return @session_store_name if name.nil? && seam.nil? && !block

        @session_store_name = name.to_sym unless name.nil?
        @session_store_seam = resolve_seam(
          seam,
          block,
          current: @session_store_seam,
          required_methods: %i[write fetch entries],
          label: "session store"
        )
        self
      end

      def provide(name, callable = nil, metadata: {}, &block)
        resolved = callable || block
        raise ArgumentError, "provide requires a callable, object, or block" if resolved.nil?
        raise ArgumentError, "provide cannot use both a callable and a block" if callable && block

        definition = ServiceDefinition.new(name: name, callable: resolved, metadata: metadata, source: :application)
        @services[definition.name] = resolved
        @service_definitions[definition.name] = definition
        self
      end

      def expose(name, callable = nil, metadata: {}, &block)
        resolved = callable || block
        raise ArgumentError, "expose requires a callable, object, or block" if resolved.nil?
        raise ArgumentError, "expose cannot use both a callable and a block" if callable && block

        interface = Interface.new(name: name, callable: resolved, metadata: metadata, source: :application)
        @services[interface.name] = resolved unless @services.key?(interface.name)
        @service_definitions[interface.name] ||= ServiceDefinition.new(
          name: interface.name,
          callable: resolved,
          metadata: metadata,
          source: :application
        )
        @interfaces[interface.name] = interface
        self
      end

      def register(name, contract_class)
        @registrations[name.to_s] = contract_class
        self
      end

      def register_provider(name, provider = nil)
        raise ArgumentError, "register_provider requires a provider object" if provider.nil?
        raise ArgumentError, "provider #{provider.inspect} must respond to services(environment:)" unless provider.respond_to?(:services)

        @providers.reject! { |entry| entry.name == name.to_sym }
        @providers << ProviderRegistration.new(name: name, provider: provider)
        self
      end

      def configure(values = nil)
        config_builder.merge!(values) if values
        config_builder.configure { |builder| yield builder } if block_given?
        self
      end

      def set(*path, value:)
        config_builder.set(*path, value: value)
        self
      end

      def schedule(name, every:, at: nil, &block)
        raise ArgumentError, "schedule requires a block" unless block

        @scheduled_jobs << {
          name: name.to_sym,
          every: every,
          at: at,
          block: block
        }
        self
      end

      def add_path(group, *paths)
        normalized_group = normalize_group(group)
        @code_paths[normalized_group] ||= []
        @code_paths[normalized_group] |= paths.flatten.compact.map(&:to_s)
        self
      end

      def contracts_path(*paths)
        add_path(:contracts, *paths)
      end

      def executors_path(*paths)
        add_path(:executors, *paths)
      end

      def tools_path(*paths)
        add_path(:tools, *paths)
      end

      def agents_path(*paths)
        add_path(:agents, *paths)
      end

      def skills_path(*paths)
        add_path(:skills, *paths)
      end

      def finalize
        Profile.new(
          contracts_profile: contracts_kernel.finalize,
          contracts_packs: contracts_packs,
          application_packs: application_packs,
          host_name: host,
          loader_name: loader,
          scheduler_name: scheduler,
          session_store_name: session_store,
          host_seam: host_seam,
          loader_seam: loader_seam,
          scheduler_seam: scheduler_seam,
          session_store_seam: session_store_seam,
          config: config_builder.to_config,
          providers: providers,
          services: services,
          service_definitions: service_definitions,
          interfaces: interfaces,
          registrations: registrations,
          scheduled_jobs: scheduled_jobs,
          code_paths: code_paths
        )
      end

      private

      def normalize_group(group)
        normalized = group.to_sym
        return normalized if PATH_GROUPS.include?(normalized)

        raise ArgumentError, "unknown path group #{group.inspect}; expected one of: #{PATH_GROUPS.join(', ')}"
      end

      def resolve_seam(explicit_seam, block, current:, required_methods:, label:)
        resolved = explicit_seam || block || current
        missing = required_methods.reject { |method_name| resolved.respond_to?(method_name) }
        return resolved if missing.empty?

        raise ArgumentError, "#{label} seam #{resolved.inspect} must respond to: #{required_methods.join(', ')}"
      end
    end
  end
end
