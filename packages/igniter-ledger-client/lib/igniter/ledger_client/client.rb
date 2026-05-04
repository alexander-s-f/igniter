# frozen_string_literal: true
require_relative "envelope"
require_relative "error"

module Igniter
  module LedgerClient
    class Client
      attr_reader :transport

      def initialize(transport:)
        @transport = transport
      end

      def register_descriptor(descriptor = nil, **fields)
        dispatch(:register_descriptor, (descriptor || {}).merge(fields))
      end

      def write(store:, key:, value:, **metadata)
        dispatch(:write, metadata.merge(store: store, key: key, value: value))
      end

      def append(history:, event:, key: nil, partition_key: nil, **metadata)
        packet = metadata.merge(history: history, event: event)
        packet[:key] = key if key
        packet[:partition_key] = partition_key if partition_key
        dispatch(:append, packet)
      end

      def read(store:, key:, as_of: nil)
        packet = { store: store, key: key }
        packet[:as_of] = as_of if as_of
        dispatch(:read, packet)
      end

      def query(store:, where:, limit: nil, as_of: nil, order: nil)
        packet = { store: store, where: where }
        packet[:limit] = limit if limit
        packet[:as_of] = as_of if as_of
        packet[:order] = order if order
        dispatch(:query, packet)
      end

      def replay(store: nil, from: nil, to: nil, filter: nil)
        packet = {}
        packet[:from] = from if from
        packet[:to] = to if to
        packet[:filter] = filter if filter
        packet[:filter] = { store: store } if store && !filter
        dispatch(:replay, packet)
      end

      def resolve(relation:, from:, as_of: nil)
        packet = { relation: relation, from: from }
        packet[:as_of] = as_of if as_of
        dispatch(:resolve, packet)
      end

      def metadata_snapshot = dispatch(:metadata_snapshot)

      def descriptor_snapshot = dispatch(:descriptor_snapshot)

      def observability_snapshot = dispatch(:observability_snapshot)

      def compaction_activity(store: nil, kind: nil, since: nil, limit: nil)
        packet = {}
        packet[:store] = store if store
        packet[:kind] = kind if kind
        packet[:since] = since if since
        packet[:limit] = limit if limit
        dispatch(:compaction_activity, packet)
      end

      def dispatch(operation, packet = {}, request_id: nil)
        request = Envelope.request(operation: operation, packet: packet, request_id: request_id)
        Envelope.result_or_raise(transport.dispatch(request))
      rescue Error
        raise
      rescue StandardError => e
        raise TransportError.new(e.message, request_id: request&.fetch(:request_id, nil))
      end

      def close
        transport.close if transport.respond_to?(:close)
      end
    end
  end
end
