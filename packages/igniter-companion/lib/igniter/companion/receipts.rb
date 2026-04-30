# frozen_string_literal: true

module Igniter
  module Companion
    # Normalized return from Store#write.
    # Carries mutation metadata alongside the typed record object.
    # Delegates unknown methods to `record` so callers can use it transparently.
    #
    #   receipt = store.write(Reminder, key: "r1", title: "Buy milk")
    #   receipt.mutation_intent  # => :record_write
    #   receipt.fact_id          # => "550e8400-..."
    #   receipt.value_hash       # => "a3b1c2..."
    #   receipt.causation        # => nil (first write) or previous value_hash
    #   receipt.title            # => "Buy milk"  (delegated to record)
    #   receipt.record           # => #<Reminder ...>
    class WriteReceipt
      attr_reader :mutation_intent, :fact_id, :value_hash, :causation, :key, :record

      def initialize(mutation_intent:, fact_id:, value_hash:, causation:, key:, record:)
        @mutation_intent = mutation_intent
        @fact_id         = fact_id
        @value_hash      = value_hash
        @causation       = causation
        @key             = key
        @record          = record
      end

      def success? = true

      def method_missing(method, *args, &block)
        return @record.public_send(method, *args, &block) if @record.respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        @record.respond_to?(method, include_private) || super
      end

      def inspect
        "#<WriteReceipt intent=#{@mutation_intent} fact_id=#{@fact_id&.slice(0, 8)} key=#{@key.inspect}>"
      end
    end

    # Normalized return from Store#append.
    # Carries mutation metadata alongside the typed event object.
    #
    #   receipt = store.append(TrackerLog, tracker_id: "sleep", value: 8.5)
    #   receipt.mutation_intent  # => :history_append
    #   receipt.fact_id          # => "550e8400-..."
    #   receipt.timestamp        # => 1714483200.123
    #   receipt.event            # => #<TrackerLog ...>
    #   receipt.value            # => 8.5  (delegated to event)
    class AppendReceipt
      attr_reader :mutation_intent, :fact_id, :value_hash, :timestamp, :event

      def initialize(mutation_intent:, fact_id:, value_hash:, timestamp:, event:)
        @mutation_intent = mutation_intent
        @fact_id         = fact_id
        @value_hash      = value_hash
        @timestamp       = timestamp
        @event           = event
      end

      def success? = true

      def method_missing(method, *args, &block)
        return @event.public_send(method, *args, &block) if @event.respond_to?(method)
        super
      end

      def respond_to_missing?(method, include_private = false)
        @event.respond_to?(method, include_private) || super
      end

      def inspect
        "#<AppendReceipt intent=#{@mutation_intent} fact_id=#{@fact_id&.slice(0, 8)}>"
      end
    end
  end
end
