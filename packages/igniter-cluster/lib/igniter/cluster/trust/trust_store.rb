# frozen_string_literal: true

module Igniter
  module Cluster
    module Trust
      class TrustStore
        Entry = Struct.new(:node_id, :public_key, :label, keyword_init: true)

        def initialize(entries = {})
          @entries = {}
          source_entries = entries.is_a?(Hash) ? entries.each_value : Array(entries)
          source_entries.each do |entry|
            add(entry[:node_id], public_key: entry[:public_key], label: entry[:label])
          end
        end

        def add(node_id, public_key:, label: nil)
          @entries[node_id.to_s] = Entry.new(node_id: node_id.to_s, public_key: public_key.to_s, label: label&.to_s)
          self
        end

        def entry_for(node_id)
          @entries[node_id.to_s]
        end

        def known?(node_id)
          !entry_for(node_id).nil?
        end

        def size
          @entries.size
        end

        def all
          @entries.values.dup
        end

        def to_h
          {
            size: size,
            entries: all.map do |entry|
              {
                node_id: entry.node_id,
                label: entry.label,
                fingerprint: Igniter::Cluster::Trust::Verifier.fingerprint_for(entry.public_key)
              }
            end
          }
        end
      end
    end
  end
end
