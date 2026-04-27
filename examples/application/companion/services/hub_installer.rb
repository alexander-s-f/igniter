# frozen_string_literal: true

require "igniter-hub"

module Companion
  module Services
    class HubInstaller
      InstallResult = Struct.new(:status, :entry, :receipt, :readiness, :installed_entry, keyword_init: true) do
        def success?
          status == :installed
        end
      end

      class Null
        def entries
          []
        end

        def installed?(_name)
          false
        end

        def install(*)
          InstallResult.new(status: :blocked, entry: nil, receipt: nil, readiness: nil, installed_entry: nil).freeze
        end
      end

      attr_reader :catalog_path, :install_root, :registry

      def initialize(catalog_path:, install_root:, registry: nil)
        @catalog_path = catalog_path.to_s
        @install_root = install_root.to_s
        @registry = registry || Igniter::Application.file_backed_installed_capsule_registry(root: install_root)
      end

      def catalog
        @catalog ||= Igniter::Hub.local_catalog(catalog_path)
      end

      def entries
        catalog.entries
      end

      def installed?(name)
        registry.installed?(name)
      end

      def install(name, commit: true)
        entry = catalog.fetch(name)
        verification = Igniter::Application.verify_transfer_bundle(entry.bundle_path)
        intake = Igniter::Application.transfer_intake_plan(verification, destination_root: install_root)
        apply_plan = Igniter::Application.transfer_apply_plan(intake)
        result = Igniter::Application.apply_transfer_plan(apply_plan, commit: commit)
        applied = Igniter::Application.verify_applied_transfer(result, apply_plan: apply_plan)
        receipt = Igniter::Application.transfer_receipt(applied, apply_result: result, apply_plan: apply_plan)
        installed_entry = record_install(entry, receipt, commit: commit)

        InstallResult.new(
          status: receipt.complete? ? :installed : :blocked,
          entry: entry,
          receipt: receipt,
          readiness: intake,
          installed_entry: installed_entry
        ).freeze
      end

      private

      def record_install(entry, receipt, commit:)
        return nil unless commit

        Igniter::Application.record_installed_capsule(
          entry.name,
          receipt: receipt,
          registry: registry,
          source: catalog_path,
          version: entry.version,
          metadata: { hub: :local, capabilities: entry.capabilities }
        )
      end
    end
  end
end
