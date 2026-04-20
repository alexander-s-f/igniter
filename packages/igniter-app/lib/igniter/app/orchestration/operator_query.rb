# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class OperatorQuery
        include Enumerable

        ORDERABLE_DIMENSIONS = %i[
          id action node status interaction reason attention_required resumable
          assignee queue channel phase reply_mode mode tool_loop_status
          latest_action_actor latest_action_origin latest_action_source
          handoff_count combined_state
        ].freeze
        FACETABLE_DIMENSIONS = %i[
          id status action node interaction reason attention_required resumable
          assignee queue channel phase reply_mode mode tool_loop_status
          policy lane combined_state latest_action_actor latest_action_origin
          latest_action_source
        ].freeze

        def initialize(records)
          @records = Array(records).map(&:dup).freeze
          @filters = [].freeze
          @orderings = [].freeze
          @limit_count = nil
          freeze
        end

        def status(*statuses)
          normalized = statuses.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:status]) }
        end

        def actionable
          add_filter do |record|
            next true unless record[:has_inbox_item]

            !Inbox::RESOLVED_STATUSES.include?(record[:status])
          end
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
          add_filter { |record| normalized.include?(record[:action]) }
        end

        def id(*ids)
          normalized = ids.map(&:to_s)
          add_filter { |record| normalized.include?(record[:id].to_s) }
        end

        def policy(*names)
          normalized = names.map(&:to_sym)
          add_filter { |record| normalized.include?(record.dig(:policy, :name)) }
        end

        def lane(*names)
          normalized = names.map(&:to_sym)
          add_filter { |record| normalized.include?(record.dig(:lane, :name)) }
        end

        def queue(*queues)
          normalized = queues.map(&:to_s)
          add_filter { |record| normalized.include?(record[:queue].to_s) }
        end

        def channel(*channels)
          normalized = channels.map(&:to_s)
          add_filter { |record| normalized.include?(record[:channel].to_s) }
        end

        def assignee(*assignees)
          normalized = assignees.map(&:to_s)
          add_filter { |record| normalized.include?(record[:assignee].to_s) }
        end

        def latest_action_actor(*actors)
          normalized = actors.map(&:to_s)
          add_filter { |record| normalized.include?(record[:latest_action_actor].to_s) }
        end

        def latest_action_origin(*origins)
          normalized = origins.map(&:to_s)
          add_filter { |record| normalized.include?(record[:latest_action_origin].to_s) }
        end

        def latest_action_source(*sources)
          normalized = sources.map(&:to_s)
          add_filter { |record| normalized.include?(record[:latest_action_source].to_s) }
        end

        def node(*nodes)
          normalized = nodes.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:node]) }
        end

        def combined_state(*states)
          normalized = states.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:combined_state]) }
        end

        def interaction(*interactions)
          normalized = interactions.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:interaction]) }
        end

        def reason(*reasons)
          normalized = reasons.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:reason]) }
        end

        def attention_required(value = true)
          expected = !!value
          add_filter { |record| record[:attention_required] == expected }
        end

        def resumable(value = true)
          expected = !!value
          add_filter { |record| record[:resumable] == expected }
        end

        def graph(*graphs)
          normalized = graphs.map(&:to_s)
          add_filter { |record| normalized.include?(record[:graph].to_s) }
        end

        def execution_id(*ids)
          normalized = ids.map(&:to_s)
          add_filter { |record| normalized.include?(record[:execution_id].to_s) }
        end

        def phase(*phases)
          normalized = phases.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:phase]) }
        end

        def reply_mode(*modes)
          normalized = modes.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:reply_mode]) }
        end

        def mode(*modes)
          normalized = modes.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:mode]) }
        end

        def tool_loop_status(*statuses)
          normalized = statuses.map(&:to_sym)
          add_filter { |record| normalized.include?(record[:tool_loop_status]) }
        end

        def with_session(value = true)
          expected = !!value
          add_filter { |record| record[:has_session] == expected }
        end

        def with_inbox_item(value = true)
          expected = !!value
          add_filter { |record| record[:has_inbox_item] == expected }
        end

        def joined
          add_filter { |record| record[:combined_state] == :joined }
        end

        def ignition
          add_filter { |record| record[:combined_state] == :ignition }
        end

        def session_only
          add_filter { |record| record[:combined_state] == :session_only }
        end

        def inbox_only
          add_filter { |record| record[:combined_state] == :inbox_only }
        end

        def handed_off
          add_filter { |record| record.fetch(:handoff_count, 0).positive? }
        end

        def with_token
          add_filter { |record| !record[:token].nil? }
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
          result = @records.select { |record| match?(record) }
          result = apply_orderings(result) unless @orderings.empty?
          @limit_count ? result.first(@limit_count) : result
        end

        def each(&block)
          to_a.each(&block)
        end

        def count
          @records.count { |record| match?(record) }
        end

        def empty?
          !@records.any? { |record| match?(record) }
        end

        def first(count = nil)
          count ? to_a.first(count) : to_a.first
        end

        def facet(dimension, include_nil: false)
          validate_facet_dimension!(dimension)

          to_a.each_with_object(Hash.new(0)) do |record, memo|
            value = facet_value(record, dimension)
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
            live_sessions: with_session.count,
            inbox_items: with_inbox_item.count,
            joined_records: joined.count,
            ignition_records: ignition.count,
            session_only: session_only.count,
            inbox_only: inbox_only.count,
            handed_off: handed_off.count,
            by_status: facet(:status),
            by_action: facet(:action),
            by_policy: facet(:policy),
            by_lane: facet(:lane),
            by_queue: facet(:queue),
            by_channel: facet(:channel),
            by_assignee: facet(:assignee),
            by_latest_action_actor: facet(:latest_action_actor),
            by_latest_action_origin: facet(:latest_action_origin),
            by_latest_action_source: facet(:latest_action_source),
            by_interaction: facet(:interaction),
            by_reason: facet(:reason),
            by_phase: facet(:phase),
            by_reply_mode: facet(:reply_mode),
            by_tool_loop_status: facet(:tool_loop_status),
            by_combined_state: facet(:combined_state),
            attention_required: attention_required.count,
            resumable: resumable.count
          }.freeze
        end

        def explain
          lines = ["OperatorQuery(#{@records.size} candidates)"]
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
          query.instance_variable_set(:@records, @records)
          query.instance_variable_set(:@filters, @filters.dup.freeze)
          query.instance_variable_set(:@orderings, @orderings.dup.freeze)
          query.instance_variable_set(:@limit_count, @limit_count)
          yield query
          query.freeze
          query
        end

        def match?(record)
          @filters.all? { |filter| filter.call(record) }
        end

        def apply_orderings(records)
          records.sort do |left, right|
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

        def dimension_value(record, dimension)
          return dimension.call(record) if dimension.respond_to?(:call)

          case dimension
          when :policy then record.dig(:policy, :name)
          when :lane then record.dig(:lane, :name)
          else record[dimension]
          end
        end

        def facet_value(record, dimension)
          dimension_value(record, dimension)
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
