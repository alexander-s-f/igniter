# frozen_string_literal: true

require "igniter/errors"
require "igniter/application"

require_relative "cluster/errors"
require_relative "cluster/peer"
require_relative "cluster/memory_peer_registry"
require_relative "cluster/route_request"
require_relative "cluster/placement_decision"
require_relative "cluster/direct_placement"
require_relative "cluster/route"
require_relative "cluster/capability_router"
require_relative "cluster/admission_result"
require_relative "cluster/permissive_admission"
require_relative "cluster/transport_adapter"
require_relative "cluster/kernel"
require_relative "cluster/profile"
require_relative "cluster/environment"

module Igniter
  module Cluster
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
