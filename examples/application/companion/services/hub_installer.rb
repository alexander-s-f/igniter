# frozen_string_literal: true

require "igniter-hub"

module Companion
  module Services
    class HubInstaller
      InstallResult = Struct.new(:status, :entry, :receipt, :readiness, keyword_init: true) do
        def success?
          status == :installed
        end
      end

      class Null
        def entries
          []
        end

        def install(_name, commit: true)
          InstallResult.new(status: :blocked, entry: nil, receipt: nil, readiness: nil).freeze
        end
      end

      attr_reader :catalog_path, :install_root

      def initialize(catalog_path:, install_root:)
        @catalog_path = catalog_path.to_s
        @install_root = install_root.to_s
      end

      def catalog
        @catalog ||= Igniter::Hub.local_catalog(catalog_path)
      end

      def entries
        catalog.entries
      end

      def install(name, commit: true)
        entry = catalog.fetch(name)
        verification = Igniter::Application.verify_transfer_bundle(entry.bundle_path)
        intake = Igniter::Application.transfer_intake_plan(verification, destination_root: install_root)
        apply_plan = Igniter::Application.transfer_apply_plan(intake)
        result = Igniter::Application.apply_transfer_plan(apply_plan, commit: commit)
        applied = Igniter::Application.verify_applied_transfer(result, apply_plan: apply_plan)
        receipt = Igniter::Application.transfer_receipt(applied, apply_result: result, apply_plan: apply_plan)

        InstallResult.new(
          status: receipt.complete? ? :installed : :blocked,
          entry: entry,
          receipt: receipt,
          readiness: intake
        ).freeze
      end
    end
  end
end
