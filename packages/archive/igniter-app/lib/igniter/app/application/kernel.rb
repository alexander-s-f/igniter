# frozen_string_literal: true

module Igniter
  class App
    class Kernel
      PATH_GROUPS = %i[executors contracts tools agents skills].freeze

      attr_reader :contracts_kernel, :contracts_packs, :app_packs, :services, :registrations,
                  :scheduled_jobs, :code_paths, :app_config

      def initialize(contracts_kernel: Igniter::Contracts.build_kernel)
        @contracts_kernel = contracts_kernel
        @contracts_packs = []
        @app_packs = []
        @services = {}
        @registrations = {}
        @scheduled_jobs = []
        @code_paths = {}
        @app_config = AppConfig.new
        @host_name = :app
        @loader_name = :filesystem
        @scheduler_name = :threaded
      end

      def install_pack(pack)
        if pack.respond_to?(:install_into_app_kernel)
          pack.install_into_app_kernel(self)
          @app_packs |= [pack]
        elsif pack.respond_to?(:install_into)
          contracts_kernel.install(pack)
          @contracts_packs |= [pack]
        else
          raise ArgumentError, "app pack #{pack.inspect} must implement install_into_app_kernel or install_into"
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

      def host(name = nil)
        return @host_name if name.nil?

        HostRegistry.fetch(name)
        @host_name = name.to_sym
        self
      rescue KeyError
        raise ArgumentError, "unknown app host #{name.inspect}; expected one of: #{HostRegistry.names.join(', ')}"
      end

      def loader(name = nil)
        return @loader_name if name.nil?

        LoaderRegistry.fetch(name)
        @loader_name = name.to_sym
        self
      rescue KeyError
        raise ArgumentError, "unknown app loader #{name.inspect}; expected one of: #{LoaderRegistry.names.join(', ')}"
      end

      def scheduler(name = nil)
        return @scheduler_name if name.nil?

        SchedulerRegistry.fetch(name)
        @scheduler_name = name.to_sym
        self
      rescue KeyError
        raise ArgumentError, "unknown app scheduler #{name.inspect}; expected one of: #{SchedulerRegistry.names.join(', ')}"
      end

      def provide(name, callable = nil, &block)
        resolved = callable || block
        raise ArgumentError, "provide requires a callable, object, or block" if resolved.nil?
        raise ArgumentError, "provide cannot use both a callable and a block" if callable && block

        @services[name.to_sym] = resolved
        self
      end

      def register(name, contract_class)
        @registrations[name.to_s] = contract_class
        self
      end

      def configure(&block)
        raise ArgumentError, "configure requires a block" unless block

        block.call(app_config)
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

      def executors_path(*paths)
        add_path(:executors, *paths)
      end

      def contracts_path(*paths)
        add_path(:contracts, *paths)
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
          app_packs: app_packs,
          host_name: host,
          loader_name: loader,
          scheduler_name: scheduler,
          services: services,
          registrations: registrations,
          scheduled_jobs: scheduled_jobs,
          code_paths: code_paths,
          host_config: build_host_config
        )
      end

      private

      def normalize_group(group)
        normalized = group.to_sym
        return normalized if PATH_GROUPS.include?(normalized)

        raise ArgumentError, "unknown path group #{group.inspect}; expected one of: #{PATH_GROUPS.join(', ')}"
      end

      def build_host_config
        host_config = app_config.to_host_config
        registrations.each do |name, contract_class|
          host_config.register(name, contract_class)
        end
        host_config
      end
    end
  end
end
