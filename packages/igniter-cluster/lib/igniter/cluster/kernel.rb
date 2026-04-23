# frozen_string_literal: true

module Igniter
  module Cluster
    class Kernel
      attr_reader :application_kernel, :cluster_packs, :transport_seam, :router_seam,
                  :admission_seam, :placement_seam, :peer_registry_seam

      def initialize(application_kernel: Igniter::Application.build_kernel)
        @application_kernel = application_kernel
        @cluster_packs = []
        @transport_name = :direct
        @router_name = :capability
        @admission_name = :permissive
        @placement_name = :direct
        @peer_registry_name = :memory
        @transport_seam = TransportAdapter.new
        @router_seam = CapabilityRouter.new
        @admission_seam = PermissiveAdmission.new
        @placement_seam = DirectPlacement.new
        @peer_registry_seam = MemoryPeerRegistry.new
      end

      def install_pack(pack)
        if pack.respond_to?(:install_into_cluster_kernel)
          pack.install_into_cluster_kernel(self)
          @cluster_packs |= [pack]
        elsif pack.respond_to?(:install_into_application_kernel) || pack.respond_to?(:install_into)
          application_kernel.install_pack(pack)
        else
          raise ArgumentError, "cluster pack #{pack.inspect} must implement install_into_cluster_kernel, install_into_application_kernel, or install_into"
        end

        self
      end

      def transport(name = nil, seam: nil, &block)
        return @transport_name if name.nil? && seam.nil? && !block

        @transport_name = name.to_sym unless name.nil?
        @transport_seam = resolve_seam(seam, block, current: @transport_seam, required_methods: %i[call], label: "transport")
        self
      end

      def router(name = nil, seam: nil, &block)
        return @router_name if name.nil? && seam.nil? && !block

        @router_name = name.to_sym unless name.nil?
        @router_seam = resolve_seam(seam, block, current: @router_seam, required_methods: %i[route], label: "router")
        self
      end

      def admission(name = nil, seam: nil, &block)
        return @admission_name if name.nil? && seam.nil? && !block

        @admission_name = name.to_sym unless name.nil?
        @admission_seam = resolve_seam(seam, block, current: @admission_seam, required_methods: %i[admit], label: "admission")
        self
      end

      def placement(name = nil, seam: nil, &block)
        return @placement_name if name.nil? && seam.nil? && !block

        @placement_name = name.to_sym unless name.nil?
        @placement_seam = resolve_seam(seam, block, current: @placement_seam, required_methods: %i[place], label: "placement")
        self
      end

      def peer_registry(name = nil, seam: nil, &block)
        return @peer_registry_name if name.nil? && seam.nil? && !block

        @peer_registry_name = name.to_sym unless name.nil?
        @peer_registry_seam = resolve_seam(
          seam,
          block,
          current: @peer_registry_seam,
          required_methods: %i[register fetch peers],
          label: "peer registry"
        )
        self
      end

      def register_peer(name, capabilities:, transport:, metadata: {})
        peer_registry_seam.register(
          Peer.new(name: name, capabilities: capabilities, transport: transport, metadata: metadata)
        )
        self
      end

      def finalize
        Profile.new(
          application_profile: application_kernel.finalize,
          cluster_packs: cluster_packs,
          transport_name: transport,
          router_name: router,
          admission_name: admission,
          placement_name: placement,
          peer_registry_name: peer_registry,
          transport_seam: transport_seam,
          router_seam: router_seam,
          admission_seam: admission_seam,
          placement_seam: placement_seam,
          peer_registry_seam: peer_registry_seam
        )
      end

      private

      def resolve_seam(explicit_seam, block, current:, required_methods:, label:)
        resolved = explicit_seam || block || current
        missing = required_methods.reject { |method_name| resolved.respond_to?(method_name) }
        return resolved if missing.empty?

        raise ArgumentError, "#{label} seam #{resolved.inspect} must respond to: #{required_methods.join(', ')}"
      end
    end
  end
end
