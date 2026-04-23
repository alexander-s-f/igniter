# frozen_string_literal: true

module Igniter
  module Cluster
    class Profile
      attr_reader :application_profile, :cluster_packs, :transport_name, :router_name,
                  :admission_name, :placement_name, :peer_registry_name,
                  :transport_seam, :router_seam, :admission_seam, :placement_seam,
                  :peer_registry_seam

      def initialize(application_profile:, cluster_packs:, transport_name:, router_name:,
                     admission_name:, placement_name:, peer_registry_name:,
                     transport_seam:, router_seam:, admission_seam:, placement_seam:,
                     peer_registry_seam:)
        @application_profile = application_profile
        @cluster_packs = cluster_packs.dup.freeze
        @transport_name = transport_name.to_sym
        @router_name = router_name.to_sym
        @admission_name = admission_name.to_sym
        @placement_name = placement_name.to_sym
        @peer_registry_name = peer_registry_name.to_sym
        @transport_seam = transport_seam
        @router_seam = router_seam
        @admission_seam = admission_seam
        @placement_seam = placement_seam
        @peer_registry_seam = peer_registry_seam
        freeze
      end

      def cluster_pack_names
        cluster_packs.map { |pack| pack.respond_to?(:name) ? pack.name.to_s : pack.inspect }
      end

      def peers
        peer_registry_seam.peers
      end

      def to_h
        {
          application_profile: application_profile.to_h,
          cluster_packs: cluster_pack_names,
          transport: transport_name,
          router: router_name,
          admission: admission_name,
          placement: placement_name,
          peer_registry: peer_registry_name,
          peers: peers.map(&:to_h)
        }
      end
    end
  end
end
