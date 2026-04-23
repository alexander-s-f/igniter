# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class RuntimeEventQuery
        include Enumerable

        FILTERABLE_DIMENSIONS = %i[
          node event event_class source status terminal actor origin
          requested_operation lifecycle_operation execution_operation
        ].freeze
        ORDERABLE_DIMENSIONS = %i[
          node event event_class source status timestamp actor origin
          requested_operation lifecycle_operation execution_operation
        ].freeze

        def initialize(events)
          @events = Array(events).map(&:dup).freeze
          @filters = [].freeze
          @orderings = [].freeze
          @limit_count = nil
          freeze
        end

        def node(*nodes)
          normalized = nodes.map(&:to_sym)
          add_filter { |event| normalized.include?(event[:node]) }
        end

        def event(*events)
          normalized = events.map(&:to_sym)
          add_filter { |entry| normalized.include?(entry[:event]) }
        end

        def event_class(*classes)
          normalized = classes.map(&:to_sym)
          add_filter { |entry| normalized.include?(entry[:event_class]) }
        end

        def source(*sources)
          normalized = sources.map(&:to_sym)
          add_filter { |entry| normalized.include?(entry[:source]) }
        end

        def status(*statuses)
          normalized = statuses.map(&:to_sym)
          add_filter { |entry| normalized.include?(entry[:status]) }
        end

        def terminal(value = true)
          expected = !!value
          add_filter { |entry| entry[:terminal] == expected }
        end

        def actor(*actors)
          normalized = actors.map(&:to_s)
          add_filter { |entry| normalized.include?(entry[:actor].to_s) }
        end

        def origin(*origins)
          normalized = origins.map(&:to_s)
          add_filter { |entry| normalized.include?(entry[:origin].to_s) }
        end

        def requested_operation(*operations)
          normalized = operations.map(&:to_sym)
          add_filter { |entry| normalized.include?(entry[:requested_operation]) }
        end

        def lifecycle_operation(*operations)
          normalized = operations.map(&:to_sym)
          add_filter { |entry| normalized.include?(entry[:lifecycle_operation]) }
        end

        def execution_operation(*operations)
          normalized = operations.map(&:to_sym)
          add_filter { |entry| normalized.include?(entry[:execution_operation]) }
        end

        def where(&block)
          raise ArgumentError, "where requires a block" unless block

          add_filter(&block)
        end

        def order_by(dimension, direction: :asc)
          raise ArgumentError, "direction must be :asc or :desc" unless %i[asc desc].include?(direction)
          unless ORDERABLE_DIMENSIONS.include?(dimension) || dimension.respond_to?(:call)
            raise ArgumentError, "Unknown ordering dimension: #{dimension.inspect}. Use one of #{ORDERABLE_DIMENSIONS.inspect} or a Proc."
          end

          clone_query do |query|
            query.instance_variable_set(:@orderings, (@orderings + [{ dimension: dimension, direction: direction }]).freeze)
          end
        end

        def limit(count)
          clone_query { |query| query.instance_variable_set(:@limit_count, count) }
        end

        def facet(dimension)
          raise ArgumentError, "Unknown facet dimension: #{dimension.inspect}. Use one of #{FILTERABLE_DIMENSIONS.inspect}" unless FILTERABLE_DIMENSIONS.include?(dimension)

          to_a.each_with_object(Hash.new(0)) do |entry, memo|
            value = entry[dimension]
            next if value.nil?

            memo[value] += 1
          end.freeze
        end

        def summary
          entries = to_a

          {
            total: entries.size,
            terminal: entries.count { |entry| entry[:terminal] },
            runtime_events: entries.count { |entry| entry[:event_class] == :runtime },
            operator_events: entries.count { |entry| entry[:event_class] == :operator },
            by_node: facet(:node),
            by_event: facet(:event),
            by_event_class: facet(:event_class),
            by_source: facet(:source),
            by_status: facet(:status),
            by_lifecycle_operation: facet(:lifecycle_operation),
            by_execution_operation: facet(:execution_operation),
            latest_event: entries.last&.dup,
            latest_per_node: latest_per_node(entries)
          }.freeze
        end

        def to_h(limit: 20)
          {
            summary: summary,
            events: order_by(:timestamp).limit(limit).to_a,
            recent_events: order_by(:timestamp).to_a.last(limit)
          }.freeze
        end

        def each(&block)
          to_a.each(&block)
        end

        def to_a
          entries = @events.select do |entry|
            @filters.all? { |filter| filter.call(entry) }
          end

          ordered = apply_orderings(entries)
          @limit_count ? ordered.first(@limit_count) : ordered
        end

        private

        def add_filter(&block)
          clone_query do |query|
            query.instance_variable_set(:@filters, (@filters + [block]).freeze)
          end
        end

        def clone_query
          self.class.allocate.tap do |query|
            query.instance_variable_set(:@events, @events)
            query.instance_variable_set(:@filters, @filters)
            query.instance_variable_set(:@orderings, @orderings)
            query.instance_variable_set(:@limit_count, @limit_count)
            yield(query)
            query.freeze
          end
        end

        def apply_orderings(entries)
          return entries if @orderings.empty?

          @orderings.reverse_each.reduce(entries) do |ordered, ordering|
            dimension = ordering.fetch(:dimension)
            direction = ordering.fetch(:direction)

            sorted = ordered.sort_by do |entry|
              value = dimension.respond_to?(:call) ? dimension.call(entry) : entry[dimension]
              value.nil? ? [1, nil] : [0, normalize_order_value(value)]
            end
            direction == :desc ? sorted.reverse : sorted
          end
        end

        def latest_per_node(entries)
          entries.each_with_object({}) do |entry, memo|
            memo[entry[:node]] = entry.dup if entry[:node]
          end.freeze
        end

        def normalize_order_value(value)
          case value
          when Time
            value.utc.iso8601(6)
          else
            value.to_s
          end
        end
      end
    end
  end
end
