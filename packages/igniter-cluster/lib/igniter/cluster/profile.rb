# frozen_string_literal: true

module Igniter
  module Cluster
    class Profile
      NAME_KEYS = %i[transport router admission placement peer_registry].freeze
      SEAM_KEYS = NAME_KEYS.dup.freeze

      attr_reader :application_profile, :cluster_packs, :transport_name, :router_name,
                  :admission_name, :placement_name, :peer_registry_name,
                  :transport_seam, :router_seam, :admission_seam, :placement_seam,
                  :peer_registry_seam, :route_policy, :admission_policy, :placement_policy,
                  :capability_catalog

      def initialize(application_profile:, cluster_packs:, names:, seams:, policies:, capability_catalog:)
        @application_profile = application_profile
        @cluster_packs = cluster_packs.dup.freeze
        @capability_catalog = capability_catalog
        assign_names!(names)
        assign_seams!(seams)
        assign_policies!(policies)
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
          route_policy: route_policy&.to_h,
          admission: admission_name,
          admission_policy: admission_policy&.to_h,
          placement: placement_name,
          placement_policy: placement_policy&.to_h,
          peer_registry: peer_registry_name,
          capability_catalog: capability_catalog.to_h,
          peers: peers.map(&:to_h)
        }
      end

      private

      def assign_names!(names)
        NAME_KEYS.each do |name_key|
          instance_variable_set("@#{name_key}_name", names.fetch(name_key).to_sym)
        end
      end

      def assign_seams!(seams)
        SEAM_KEYS.each do |seam_key|
          instance_variable_set("@#{seam_key}_seam", seams.fetch(seam_key))
        end
      end

      def assign_policies!(policies)
        @route_policy = policies[:route]
        @admission_policy = policies[:admission]
        @placement_policy = policies[:placement]
      end
    end
  end
end
