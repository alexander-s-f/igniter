# frozen_string_literal: true

module Igniter
  module Runtime
    class OrchestrationTransitionQuery
      include Enumerable

      FILTERABLE_DIMENSIONS = %i[
        id node action interaction state state_class event status terminal
        phase waiting_on source_status
      ].freeze
      ORDERABLE_DIMENSIONS = %i[
        id node action interaction state state_class event status terminal
        phase waiting_on source_status timestamp turn
      ].freeze

      def initialize(transitions)
        @transitions = Array(transitions).map(&:dup).freeze
        @filters = [].freeze
        @orderings = [].freeze
        @limit_count = nil
        freeze
      end

      def id(*ids)
        normalized = ids.map(&:to_s)
        add_filter { |entry| normalized.include?(entry[:id].to_s) }
      end

      def node(*nodes)
        normalized = nodes.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:node]) }
      end

      def action(*actions)
        normalized = actions.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:action]) }
      end

      def interaction(*interactions)
        normalized = interactions.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:interaction]) }
      end

      def state(*states)
        normalized = states.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:state]) }
      end

      def state_class(*classes)
        normalized = classes.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:state_class]) }
      end

      def event(*events)
        normalized = events.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:event]) }
      end

      def status(*statuses)
        normalized = statuses.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:status]) }
      end

      def phase(*phases)
        normalized = phases.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:phase]) }
      end

      def waiting_on(*nodes)
        normalized = nodes.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:waiting_on]) }
      end

      def source_status(*statuses)
        normalized = statuses.map(&:to_sym)
        add_filter { |entry| normalized.include?(entry[:source_status]) }
      end

      def terminal(value = true)
        expected = !!value
        add_filter { |entry| entry[:terminal] == expected }
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
        unless FILTERABLE_DIMENSIONS.include?(dimension)
          raise ArgumentError, "Unknown facet dimension: #{dimension.inspect}. Use one of #{FILTERABLE_DIMENSIONS.inspect}"
        end

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
          by_node: facet(:node),
          by_action: facet(:action),
          by_interaction: facet(:interaction),
          by_state: facet(:state),
          by_state_class: facet(:state_class),
          by_event: facet(:event),
          by_status: facet(:status),
          latest_transition: entries.last&.dup,
          latest_per_node: latest_per_node(entries)
        }.freeze
      end

      def to_h(limit: 20)
        {
          summary: summary,
          transitions: order_by(:timestamp).limit(limit).to_a,
          recent_transitions: order_by(:timestamp).to_a.last(limit)
        }.freeze
      end

      def each(&block)
        to_a.each(&block)
      end

      def to_a
        entries = @transitions.select do |entry|
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
          query.instance_variable_set(:@transitions, @transitions)
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
