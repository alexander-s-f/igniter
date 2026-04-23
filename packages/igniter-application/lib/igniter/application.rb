# frozen_string_literal: true

require "igniter/contracts"

require_relative "application/config"
require_relative "application/config_builder"
require_relative "application/provider"
require_relative "application/provider_registration"
require_relative "application/service_definition"
require_relative "application/interface"
require_relative "application/boot_phase"
require_relative "application/embedded_host"
require_relative "application/manual_loader"
require_relative "application/manual_scheduler"
require_relative "application/kernel"
require_relative "application/profile"
require_relative "application/snapshot"
require_relative "application/boot_report"
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
    end
  end
end
