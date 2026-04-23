# frozen_string_literal: true

module Igniter
  module Application
    class Profile
      attr_reader :contracts_profile, :contracts_packs, :application_packs,
                  :host_name, :loader_name, :scheduler_name,
                  :host_seam, :loader_seam, :scheduler_seam,
                  :config, :providers, :service_registry, :contract_registry,
                  :scheduled_jobs, :code_paths

      def initialize(contracts_profile:, contracts_packs:, application_packs:,
                     host_name:, loader_name:, scheduler_name:,
                     host_seam:, loader_seam:, scheduler_seam:,
                     config:, providers:, services:, service_definitions:, interfaces:,
                     registrations:, scheduled_jobs:, code_paths:)
        @contracts_profile = contracts_profile
        @contracts_packs = contracts_packs.dup.freeze
        @application_packs = application_packs.dup.freeze
        @host_name = host_name.to_sym
        @loader_name = loader_name.to_sym
        @scheduler_name = scheduler_name.to_sym
        @host_seam = host_seam
        @loader_seam = loader_seam
        @scheduler_seam = scheduler_seam
        @config = config
        @providers = providers.dup.freeze
        @service_registry = ServiceRegistry.new(
          services: services,
          service_definitions: service_definitions,
          interfaces: interfaces
        )
        @contract_registry = ContractRegistry.new(registrations)
        @scheduled_jobs = scheduled_jobs.map(&:dup).freeze
        @code_paths = code_paths.each_with_object({}) do |(group, paths), memo|
          memo[group.to_sym] = Array(paths).map(&:dup).freeze
        end.freeze
        freeze
      end

      def service(name)
        service_registry.fetch(name)
      end

      def service_definition(name)
        service_registry.service_definition(name)
      end

      def interface_definition(name)
        service_registry.interface_definition(name)
      end

      def contract(name)
        contract_registry.fetch(name)
      end

      def supports_service?(name)
        service_registry.service?(name)
      end

      def supports_contract?(name)
        contract_registry.key?(name)
      end

      def path_groups
        code_paths.keys.sort
      end

      def contracts_pack_names
        contracts_packs.map { |pack| pack_name_for(pack) }
      end

      def application_pack_names
        application_packs.map { |pack| pack_name_for(pack) }
      end

      def service_names
        service_registry.service_names
      end

      def interface_names
        service_registry.interface_names
      end

      def provider_names
        providers.map(&:name).sort
      end

      def contract_names
        contract_registry.names
      end

      def scheduled_job_names
        scheduled_jobs.map { |job| job[:name] }.sort
      end

      def to_h
        {
          contracts_profile_fingerprint: contracts_profile.fingerprint,
          contracts_packs: contracts_pack_names,
          application_packs: application_pack_names,
          host: host_name,
          loader: loader_name,
          scheduler: scheduler_name,
          config: config.to_h,
          providers: providers.map(&:to_h),
          services: service_registry.service_names,
          interfaces: service_registry.interface_names,
          contracts: contract_names,
          scheduled_jobs: scheduled_jobs.map do |job|
            {
              name: job[:name],
              every: job[:every],
              at: job[:at]
            }
          end,
          code_paths: code_paths.transform_values(&:dup)
        }
      end

      private

      def pack_name_for(pack)
        resolved = pack.respond_to?(:name) ? pack.name : nil
        return resolved.to_s unless resolved.nil? || resolved.to_s.empty?

        pack.inspect
      end
    end
  end
end
