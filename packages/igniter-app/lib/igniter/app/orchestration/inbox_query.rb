# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class InboxQuery
        include Enumerable

        ORDERABLE_DIMENSIONS = %i[
          id action node status interaction reason resumable attention_required
          created_at acknowledged_at resolved_at dismissed_at handed_off_at
          assignee queue channel handoff_count
        ].freeze
        FACETABLE_DIMENSIONS = %i[
          status action node interaction reason attention_required resumable
          assignee queue channel handoff_count policy lane
        ].freeze

        def initialize(items)
          @items = Array(items).map(&:dup).freeze
          @filters = [].freeze
          @orderings = [].freeze
          @limit_count = nil
          freeze
        end

        def status(*statuses)
          normalized = statuses.map(&:to_sym)
          add_filter { |item| normalized.include?(item[:status]) }
        end

        def actionable
          add_filter { |item| !Inbox::RESOLVED_STATUSES.include?(item[:status]) }
        end

        def resolved
          status(:resolved)
        end

        def dismissed
          status(:dismissed)
        end

        def open
          status(:open)
        end

        def acknowledged
          status(:acknowledged)
        end

        def action(*actions)
          normalized = actions.map(&:to_sym)
          add_filter { |item| normalized.include?(item[:action]) }
        end

        def policy(*names)
          normalized = names.map(&:to_sym)
          add_filter { |item| normalized.include?(item.dig(:policy, :name)) }
        end

        def lane(*names)
          normalized = names.map(&:to_sym)
          add_filter { |item| normalized.include?(item.dig(:lane, :name)) }
        end

        def queue(*queues)
          normalized = queues.map(&:to_s)
          add_filter { |item| normalized.include?(item[:queue].to_s) }
        end

        def channel(*channels)
          normalized = channels.map(&:to_s)
          add_filter { |item| normalized.include?(item[:channel].to_s) }
        end

        def assignee(*assignees)
          normalized = assignees.map(&:to_s)
          add_filter { |item| normalized.include?(item[:assignee].to_s) }
        end

        def node(*nodes)
          normalized = nodes.map(&:to_sym)
          add_filter { |item| normalized.include?(item[:node]) }
        end

        def interaction(*interactions)
          normalized = interactions.map(&:to_sym)
          add_filter { |item| normalized.include?(item[:interaction]) }
        end

        def reason(*reasons)
          normalized = reasons.map(&:to_sym)
          add_filter { |item| normalized.include?(item[:reason]) }
        end

        def attention_required(value = true)
          expected = !!value
          add_filter { |item| item[:attention_required] == expected }
        end

        def resumable(value = true)
          expected = !!value
          add_filter { |item| item[:resumable] == expected }
        end

        def graph(*graphs)
          normalized = graphs.map(&:to_s)
          add_filter { |item| normalized.include?(item[:graph].to_s) }
        end

        def execution_id(*ids)
          normalized = ids.map(&:to_s)
          add_filter { |item| normalized.include?(item[:execution_id].to_s) }
        end

        def with_token
          add_filter { |item| !item[:token].nil? }
        end

        def handed_off
          add_filter { |item| item.fetch(:handoff_count, 0).positive? }
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

        def to_a
          result = @items.select { |item| match?(item) }
          result = apply_orderings(result) unless @orderings.empty?
          @limit_count ? result.first(@limit_count) : result
        end

        def each(&block)
          to_a.each(&block)
        end

        def count
          @items.count { |item| match?(item) }
        end

        def empty?
          !@items.any? { |item| match?(item) }
        end

        def first(count = nil)
          count ? to_a.first(count) : to_a.first
        end

        def facet(dimension, include_nil: false)
          validate_facet_dimension!(dimension)

          to_a.each_with_object(Hash.new(0)) do |item, memo|
            value = facet_value(item, dimension)
            next if value.nil? && !include_nil

            memo[value] += 1
          end
        end

        def facets(*dimensions, include_nil: false)
          dims = dimensions.flatten
          dims = FACETABLE_DIMENSIONS if dims.empty?

          dims.each_with_object({}) do |dimension, memo|
            memo[dimension] = facet(dimension, include_nil: include_nil)
          end.freeze
        end

        def summary
          {
            total: count,
            actionable: actionable.count,
            open: open.count,
            acknowledged: acknowledged.count,
            resolved: resolved.count,
            dismissed: dismissed.count,
            handed_off: handed_off.count,
            by_status: facet(:status),
            by_action: facet(:action),
            by_policy: facet(:policy),
            by_lane: facet(:lane),
            by_queue: facet(:queue),
            by_channel: facet(:channel),
            by_assignee: facet(:assignee),
            by_interaction: facet(:interaction),
            by_reason: facet(:reason),
            attention_required: attention_required.count,
            resumable: resumable.count
          }.freeze
        end

        def explain
          lines = ["InboxQuery(#{@items.size} candidates)"]
          lines << "  filters: #{@filters.size}"
          unless @orderings.empty?
            order_desc = @orderings.map { |entry| "#{entry[:dimension]} #{entry[:direction]}" }.join(", ")
            lines << "  order_by: #{order_desc}"
          end
          lines << "  limit: #{@limit_count}" if @limit_count
          lines.join("\n")
        end

        private

        def add_filter(&block)
          clone_query do |query|
            query.instance_variable_set(:@filters, (@filters + [block]).freeze)
          end
        end

        def validate_facet_dimension!(dimension)
          return if FACETABLE_DIMENSIONS.include?(dimension)

          raise ArgumentError, "Unknown facet dimension: #{dimension.inspect}. Use one of #{FACETABLE_DIMENSIONS.inspect}."
        end

        def clone_query
          query = self.class.allocate
          query.instance_variable_set(:@items, @items)
          query.instance_variable_set(:@filters, @filters.dup.freeze)
          query.instance_variable_set(:@orderings, @orderings.dup.freeze)
          query.instance_variable_set(:@limit_count, @limit_count)
          yield query
          query.freeze
          query
        end

        def match?(item)
          @filters.all? { |filter| filter.call(item) }
        end

        def apply_orderings(items)
          items.sort do |left, right|
            comparison = 0
            @orderings.each do |ordering|
              left_value = dimension_value(left, ordering[:dimension])
              right_value = dimension_value(right, ordering[:dimension])
              comparison = compare_values(left_value, right_value, ordering[:direction])
              break unless comparison.zero?
            end
            comparison
          end
        end

        def dimension_value(item, dimension)
          return dimension.call(item) if dimension.respond_to?(:call)

          item[dimension]
        end

        def facet_value(item, dimension)
          case dimension
          when :policy then item.dig(:policy, :name)
          when :lane then item.dig(:lane, :name)
          else item[dimension]
          end
        end

        def compare_values(left, right, direction)
          if left.nil? && right.nil?
            0
          elsif left.nil?
            1
          elsif right.nil?
            -1
          else
            result = left <=> right
            direction == :desc ? -result : result
          end
        end
      end
    end
  end
end
