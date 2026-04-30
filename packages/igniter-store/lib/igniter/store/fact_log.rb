# frozen_string_literal: true

require "monitor"

module Igniter
  module Store
    class FactLog
      include MonitorMixin

      def initialize(backend: nil)
        super()
        @log = []
        @by_id = {}
        @by_key = Hash.new { |hash, key| hash[key] = [] }
        @backend = backend
      end

      def append(fact)
        synchronize do
          @log << fact
          @by_id[fact.id] = fact
          @by_key[[fact.store, fact.key]] << fact
          @backend&.write_fact(fact)
        end
        fact
      end

      def replay(fact)
        synchronize do
          @log << fact
          @by_id[fact.id] = fact
          @by_key[[fact.store, fact.key]] << fact
        end
      end

      def latest_for(store:, key:, as_of: nil)
        facts = synchronize { @by_key[[store, key]].dup }
        facts = facts.select { |fact| fact.timestamp <= as_of } if as_of
        facts.last
      end

      def facts_for(store:, key: nil, since: nil, as_of: nil)
        synchronize do
          facts = key ? @by_key[[store, key]].dup : @log.select { |fact| fact.store == store }
          facts = facts.select { |fact| fact.timestamp >= since } if since
          facts = facts.select { |fact| fact.timestamp <= as_of } if as_of
          facts
        end
      end

      def size
        synchronize { @log.size }
      end
    end
  end
end
