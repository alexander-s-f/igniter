# frozen_string_literal: true

module Igniter
  module Store
    module Protocol
      module Handlers
        class ProjectionHandler
          REQUIRED = %i[name source].freeze

          def initialize(store) = @store = store

          def call(descriptor)
            missing = REQUIRED.select { |f| descriptor[f].nil? }
            return Receipt.rejection("Missing required fields: #{missing.join(", ")}", kind: :projection) if missing.any?

            name    = descriptor[:name].to_sym
            source  = descriptor[:source]
            reads   = source.is_a?(Array) ? source.map(&:to_sym) : [source.to_sym]
            mode    = descriptor.fetch(:mode, :on_demand)

            @store.register_projection(
              ProjectionPath.new(
                name:          name,
                reads:         reads,
                relations:     [],
                consumer_hint: :protocol_client,
                reactive:      mode == :materialized
              )
            )

            Receipt.accepted(kind: :projection, name: name)
          end
        end
      end
    end
  end
end
