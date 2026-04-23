# frozen_string_literal: true

module Igniter
  module Cluster
    class PeerProfile
      attr_reader :name, :capabilities, :roles, :labels, :region, :zone, :metadata, :capability_catalog

      def initialize(name:, capabilities:, roles: [], labels: {}, region: nil, zone: nil, metadata: {},
                     capability_catalog: nil)
        @name = name.to_sym
        @capabilities = normalize_names(capabilities)
        @roles = normalize_names(roles)
        @labels = normalize_labels(labels)
        @region = region&.to_s
        @zone = zone&.to_s
        @metadata = metadata.dup.freeze
        @capability_catalog = capability_catalog
        freeze
      end

      def supports_capabilities?(required_capabilities)
        Array(required_capabilities).all? { |capability| capabilities.include?(capability.to_sym) }
      end

      def supports_traits?(required_traits)
        Array(required_traits).all? { |trait| capability_traits.include?(trait.to_sym) }
      end

      def label(name)
        labels[name.to_sym]
      end

      def tagged?(name, value = nil)
        return labels.key?(name.to_sym) if value.nil?

        label(name) == value
      end

      def capability_definitions
        return [] if capability_catalog.nil?

        capability_catalog.resolve(capabilities)
      end

      def capability_traits
        capability_definitions.flat_map(&:traits).uniq.sort
      end

      def matches_labels?(required_labels)
        required_labels.all? do |key, value|
          tagged?(key, value)
        end
      end

      def matches_region?(preferred_region)
        return true if preferred_region.nil?

        region == preferred_region.to_s
      end

      def matches_zone?(preferred_zone)
        return true if preferred_zone.nil?

        zone == preferred_zone.to_s
      end

      def satisfies_query?(query, require_capabilities: true)
        return false unless matches_labels?(query.required_labels)
        return false unless matches_region?(query.preferred_region)
        return false unless matches_zone?(query.preferred_zone)
        return true unless require_capabilities

        supports_capabilities?(query.required_capabilities) && supports_traits?(query.required_traits)
      end

      def to_h
        {
          name: name,
          capabilities: capabilities.dup,
          capability_definitions: capability_definitions.map(&:to_h),
          capability_traits: capability_traits,
          roles: roles.dup,
          labels: labels.dup,
          region: region,
          zone: zone,
          metadata: metadata.dup
        }
      end

      private

      def normalize_names(values)
        Array(values).map(&:to_sym).uniq.sort.freeze
      end

      def normalize_labels(labels)
        labels.each_with_object({}) do |(key, value), memo|
          memo[key.to_sym] = value
        end.freeze
      end
    end
  end
end
