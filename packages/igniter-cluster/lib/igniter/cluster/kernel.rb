# frozen_string_literal: true

module Igniter
  module Cluster
    class Kernel
      include KernelSeams

      attr_reader :application_kernel, :cluster_packs, :transport_seam, :router_seam,
                  :admission_seam, :placement_seam, :peer_registry_seam

      def initialize(application_kernel: Igniter::Application.build_kernel)
        @application_kernel = application_kernel
        @cluster_packs = []
        initialize_defaults
      end

      def install_pack(pack)
        if pack.respond_to?(:install_into_cluster_kernel)
          pack.install_into_cluster_kernel(self)
          @cluster_packs |= [pack]
        else
          install_dependent_pack(pack)
        end

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
          names: profile_names,
          seams: profile_seams,
          policies: profile_policies
        )
      end

      private

      def install_dependent_pack(pack)
        if pack.respond_to?(:install_into_application_kernel) || pack.respond_to?(:install_into)
          application_kernel.install_pack(pack)
          return
        end

        raise ArgumentError,
              "cluster pack #{pack.inspect} must implement " \
              "install_into_cluster_kernel, install_into_application_kernel, " \
              "or install_into"
      end
    end
  end
end
