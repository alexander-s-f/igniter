# frozen_string_literal: true

module Igniter
  module DurableModel
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

    # App-safe receipt for explicit command activity audit persistence.
    # It intentionally does not expose fact ids, value hashes, or causation.
    class CommandActivityReceipt
      attr_reader :schema_version, :kind, :status, :history, :owner, :command,
                  :subject_key, :activity_status, :store_fact_exposed,
                  :value_hash_exposed, :execution_allowed

      def initialize(history:, owner:, command:, subject_key:, activity_status:,
                     status: :recorded, schema_version: 1,
                     kind: :command_activity_receipt,
                     store_fact_exposed: false, value_hash_exposed: false,
                     execution_allowed: false)
        @schema_version = schema_version
        @kind = token(kind)
        @status = token(status)
        @history = token(history)
        @owner = token(owner)
        @command = token(command)
        @subject_key = subject_key
        @activity_status = token(activity_status)
        @store_fact_exposed = !!store_fact_exposed
        @value_hash_exposed = !!value_hash_exposed
        @execution_allowed = !!execution_allowed
        freeze
      end

      def [](key)
        to_h[key.to_sym]
      end

      def to_h
        {
          schema_version: schema_version,
          kind: kind,
          status: status,
          history: history,
          owner: owner,
          command: command,
          subject_key: subject_key,
          activity_status: activity_status,
          store_fact_exposed: store_fact_exposed,
          value_hash_exposed: value_hash_exposed,
          execution_allowed: execution_allowed
        }
      end

      private

      def token(value)
        value.is_a?(String) ? value.to_sym : value
      end
    end
  end
end
