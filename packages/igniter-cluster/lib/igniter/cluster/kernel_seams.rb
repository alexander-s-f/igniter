# frozen_string_literal: true

module Igniter
  module Cluster
    module KernelSeams
      def transport(name = nil, seam: nil, &block)
        return @transport_name if seam_query?(name, seam, block)

        configure_named_seam(:transport, name, seam, block, %i[call])
        self
      end

      def router(name = nil, seam: nil, &block)
        return @router_name if seam_query?(name, seam, block)

        configure_named_seam(:router, name, seam, block, %i[route])
        self
      end

      def admission(name = nil, seam: nil, &block)
        return @admission_name if seam_query?(name, seam, block)

        configure_named_seam(:admission, name, seam, block, %i[admit])
        self
      end

      def placement(name = nil, seam: nil, &block)
        return @placement_name if seam_query?(name, seam, block)

        configure_named_seam(:placement, name, seam, block, %i[place])
        self
      end

      def peer_registry(name = nil, seam: nil, &block)
        return @peer_registry_name if seam_query?(name, seam, block)

        configure_named_seam(:peer_registry, name, seam, block, %i[register fetch peers])
        self
      end

      def initialize_defaults
        configure_default_seam(:transport, :direct, TransportAdapter.new)
        configure_default_seam(:router, :capability, CapabilityRouter.new)
        configure_default_seam(:admission, :permissive, PermissiveAdmission.new)
        configure_default_seam(:placement, :direct, DirectPlacement.new)
        configure_default_seam(:peer_registry, :memory, MemoryPeerRegistry.new)
      end

      def profile_names
        {
          transport: transport,
          router: router,
          admission: admission,
          placement: placement,
          peer_registry: peer_registry
        }
      end

      def profile_seams
        {
          transport: transport_seam,
          router: router_seam,
          admission: admission_seam,
          placement: placement_seam,
          peer_registry: peer_registry_seam
        }
      end

      private

      def seam_query?(name, seam, block)
        name.nil? && seam.nil? && !block
      end

      def configure_default_seam(type, name, seam)
        instance_variable_set(seam_name_ivar(type), name)
        instance_variable_set(seam_object_ivar(type), seam)
      end

      def configure_named_seam(type, next_name, explicit_seam, block, required_methods)
        current_seam = instance_variable_get(seam_object_ivar(type))
        instance_variable_set(seam_name_ivar(type), normalize_seam_name(type, next_name))
        instance_variable_set(
          seam_object_ivar(type),
          resolved_seam(type, explicit_seam, block, current_seam, required_methods)
        )
      end

      def normalize_seam_name(type, next_name)
        current_name = instance_variable_get(seam_name_ivar(type))
        next_name.nil? ? current_name : next_name.to_sym
      end

      def seam_name_ivar(type)
        "@#{type}_name"
      end

      def seam_object_ivar(type)
        "@#{type}_seam"
      end

      def seam_label(type)
        type.to_s.tr("_", " ")
      end

      def resolved_seam(type, explicit_seam, block, current_seam, required_methods)
        resolve_seam(
          explicit_seam,
          block,
          current: current_seam,
          required_methods: required_methods,
          label: seam_label(type)
        )
      end

      def resolve_seam(explicit_seam, block, current:, required_methods:, label:)
        resolved = explicit_seam || block || current
        missing = required_methods.reject { |method_name| resolved.respond_to?(method_name) }
        return resolved if missing.empty?

        raise ArgumentError, "#{label} seam #{resolved.inspect} must respond to: #{required_methods.join(", ")}"
      end
    end
  end
end
