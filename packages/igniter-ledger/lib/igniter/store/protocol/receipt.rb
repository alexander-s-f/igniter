# frozen_string_literal: true

module Igniter
  module Store
    module Protocol
      Receipt = Struct.new(
        :schema_version,
        :kind,
        :status,      # :accepted | :rejected | :deduplicated
        :name,        # descriptor name (descriptor receipts)
        :store,       # store name (write receipts)
        :key,         # record key (write receipts)
        :fact_id,     # fact UUID (write receipts)
        :value_hash,  # SHA256 of value (write receipts)
        :warnings,
        :errors,
        :derived,
        keyword_init: true
      ) do
        def accepted?     = status == :accepted
        def rejected?     = status == :rejected
        def deduplicated? = status == :deduplicated

        def self.accepted(kind:, name:, warnings: [], derived: [])
          new(schema_version: 1, kind: kind, status: :accepted,
              name: name, warnings: warnings, errors: [], derived: derived)
        end

        def self.rejection(message, kind: nil, name: nil)
          new(schema_version: 1, kind: kind, status: :rejected,
              name: name, warnings: [], errors: [message], derived: [])
        end

        def self.deduplicated(kind:, name:)
          new(schema_version: 1, kind: kind, status: :deduplicated,
              name: name, warnings: ["descriptor already registered"], errors: [], derived: [])
        end

        def self.write_accepted(store:, key:, fact:)
          new(
            schema_version: 1,
            kind:       :receipt,
            status:     :accepted,
            store:      store,
            key:        key,
            fact_id:    fact.id,
            value_hash: fact.value_hash,
            warnings:   [],
            errors:     [],
            derived:    []
          )
        end
      end
    end
  end
end
