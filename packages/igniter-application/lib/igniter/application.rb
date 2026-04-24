# frozen_string_literal: true

require "igniter/contracts"
require "igniter/extensions/contracts"

require_relative "application/config"
require_relative "application/config_builder"
require_relative "application/application_layout"
require_relative "application/application_manifest"
require_relative "application/application_blueprint"
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
    end
  end
end
