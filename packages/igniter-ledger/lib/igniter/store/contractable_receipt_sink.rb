# frozen_string_literal: true

module Igniter
  module Store
    # Durable sink for contractable observation/event receipts emitted by
    # igniter-embed's contractable runner.
    #
    # Implements the record_observation / record_event store adapter protocol
    # so it can be passed directly as the `store:` option to any contractable.
    #
    # Idempotency policy:
    #   record_observation — keyed by observation_id; same id overwrites the
    #     current fact and creates a causation chain entry. Safe to retry.
    #   record_event — append-only history; retries produce duplicate entries.
    #     Callers should deduplicate at the source if needed.
    class ContractableReceiptSink
      REQUIRED_OBSERVATION_FIELDS = %i[observation_id receipt_kind].freeze
      REQUIRED_EVENT_FIELDS = %i[event_id receipt_kind observation_id].freeze

      attr_reader :store, :observations_store, :events_store, :producer

      def initialize(
        store:,
        observations_store: :contractable_observations,
        events_store: :contractable_events,
        producer: { type: :embed, name: :contractable_receipt_sink }
      )
        @store = store
        @observations_store = observations_store.to_sym
        @events_store = events_store.to_sym
        @producer = producer
        register_descriptors
      end

      def record_observation(receipt)
        validate_receipt!(receipt, REQUIRED_OBSERVATION_FIELDS, :contractable_observation)
        store.write(
          store:    observations_store,
          key:      receipt[:observation_id].to_s,
          value:    receipt,
          producer: producer
        )
      end

      def record_event(receipt)
        validate_receipt!(receipt, REQUIRED_EVENT_FIELDS, :contractable_event)
        store.append(
          history:       events_store,
          event:         receipt,
          partition_key: :observation_id
        )
      end

      def observation(observation_id)
        store.read(store: observations_store, key: observation_id.to_s)
      end

      def events_for(observation_id)
        store.history_partition(
          store:           events_store,
          partition_key:   :observation_id,
          partition_value: observation_id.to_s
        ).map(&:value)
      end

      def observations(status: nil, limit: nil)
        all_facts = store.history(store: observations_store)
        by_key = {}
        all_facts.each { |f| by_key[f.key] = f }
        results = by_key.values.sort_by(&:transaction_time).map(&:value)
        results = results.select { |r| r[:status] == status } if status
        limit ? results.take(limit) : results
      end

      def error_events(limit: nil)
        results = store.history(store: events_store).map(&:value).select { |r| r[:severity] == :error }
        limit ? results.take(limit) : results
      end

      private

      def validate_receipt!(receipt, required_fields, expected_kind)
        missing = required_fields.select { |f| receipt[f].nil? }
        raise ArgumentError, "contractable receipt missing required fields: #{missing.join(", ")}" if missing.any?

        actual_kind = receipt[:receipt_kind]
        return if actual_kind == expected_kind

        raise ArgumentError, "expected receipt_kind #{expected_kind.inspect}, got #{actual_kind.inspect}"
      end

      def register_descriptors
        store.register_descriptor(
          kind:     :store,
          name:     observations_store,
          key:      :observation_id,
          fields:   %i[observation_id name role stage status sampled async started_at finished_at duration_ms redaction],
          producer: { system: :igniter_embed }
        )
        store.register_descriptor(
          kind:          :history,
          name:          events_store,
          key:           :event_id,
          partition_key: :observation_id,
          fields:        %i[event_id observation_id event severity summary occurred_at]
        )
      end
    end
  end
end
