# frozen_string_literal: true

require "igniter/contracts"
require "igniter/extensions/contracts"

require_relative "application/config"
require_relative "application/config_builder"
require_relative "application/application_layout"
require_relative "application/application_manifest"
require_relative "application/application_structure_entry"
require_relative "application/application_structure_plan"
require_relative "application/capsule_export"
require_relative "application/capsule_import"
require_relative "application/feature_slice"
require_relative "application/feature_slice_report"
require_relative "application/application_blueprint"
require_relative "application/flow_event"
require_relative "application/pending_input"
require_relative "application/pending_action"
require_relative "application/artifact_reference"
require_relative "application/flow_declaration"
require_relative "application/application_capsule_report"
require_relative "application/capsule_builder"
require_relative "application/application_composition_report"
require_relative "application/flow_session_snapshot"
require_relative "application/application_load_path"
require_relative "application/application_load_report"
require_relative "application/provider"
require_relative "application/provider_registration"
require_relative "application/provider_lifecycle_result"
require_relative "application/provider_lifecycle_report"
require_relative "application/service_definition"
require_relative "application/interface"
require_relative "application/service_registry"
require_relative "application/contract_registry"
require_relative "application/mount_registration"
require_relative "application/transport_request"
require_relative "application/transport_response"
require_relative "application/compose_transport_adapter"
require_relative "application/collection_transport_adapter"
require_relative "application/compose_invoker"
require_relative "application/collection_invoker"
require_relative "application/session_entry"
require_relative "application/memory_session_store"
require_relative "application/boot_phase"
require_relative "application/seam_lifecycle_result"
require_relative "application/lifecycle_plan_step"
require_relative "application/plan_executor"
require_relative "application/embedded_host"
require_relative "application/manual_loader"
require_relative "application/manual_scheduler"
require_relative "application/kernel"
require_relative "application/profile"
require_relative "application/snapshot"
require_relative "application/boot_plan"
require_relative "application/boot_report"
require_relative "application/shutdown_plan"
require_relative "application/shutdown_report"
require_relative "application/environment"

module Igniter
  module Application
    class << self
      def build_kernel(*packs)
        kernel = Kernel.new
        packs.flatten.compact.each { |pack| kernel.install_pack(pack) }
        kernel
      end

      def build_profile(*packs)
        build_kernel(*packs).finalize
      end

      def with(*packs)
        Environment.new(profile: build_profile(*packs))
      end

      def blueprint(...)
        ApplicationBlueprint.new(...)
      end

      def capsule(name, root:, env: :development, &block)
        CapsuleBuilder.build(name, root: root, env: env, &block)
      end

      def compose_capsules(*capsules, host_exports: [], host_capabilities: [], metadata: {})
        ApplicationCompositionReport.inspect(
          capsules: capsules.flatten,
          host_exports: host_exports,
          host_capabilities: host_capabilities,
          metadata: metadata
        )
      end
    end
  end
end
