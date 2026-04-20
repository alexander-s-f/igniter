# frozen_string_literal: true

module Igniter
  module Runtime
    class AgentSessionQuery
      include Enumerable

      ORDERABLE_DIMENSIONS = %i[
        node_name agent_name message_name mode reply_mode waiting_on source_node
        turn phase tool_loop_status interaction attention_required reason resumable
        ownership lifecycle_state
      ].freeze
      FACETABLE_DIMENSIONS = %i[
        node_name agent_name message_name mode reply_mode waiting_on source_node
        phase tool_loop_status interaction attention_required reason resumable
        ownership lifecycle_state interactive terminal continuable routed
      ].freeze

      def initialize(sessions, execution: nil)
        @sessions = Array(sessions).freeze
        @execution = execution
        @filters = [].freeze
        @orderings = [].freeze
        @limit_count = nil
        freeze
      end

      def with_agent(*names)
        normalized = names.map(&:to_sym)
        add_filter { |session| normalized.include?(session.agent_name) }
      end

      def for_node(*names)
        normalized = names.map(&:to_sym)
        add_filter { |session| normalized.include?(session.node_name) }
      end

      def message(*names)
        normalized = names.map(&:to_sym)
        add_filter { |session| normalized.include?(session.message_name) }
      end

      def mode(*modes)
        normalized = modes.map(&:to_sym)
        add_filter { |session| normalized.include?(session.mode) }
      end

      def reply_mode(*modes)
        normalized = modes.map(&:to_sym)
        add_filter { |session| normalized.include?(session.reply_mode) }
      end

      def phase(*phases)
        normalized = phases.map(&:to_sym)
        add_filter { |session| normalized.include?(session.phase) }
      end

      def waiting_on(*nodes)
        normalized = nodes.map(&:to_sym)
        add_filter { |session| normalized.include?(session.waiting_on) }
      end

      def source_node(*nodes)
        normalized = nodes.map(&:to_sym)
        add_filter { |session| normalized.include?(session.source_node) }
      end

      def graph(*graphs)
        normalized = graphs.map(&:to_s)
        add_filter { |session| normalized.include?(session.graph.to_s) }
      end

      def execution_id(*ids)
        normalized = ids.map(&:to_s)
        add_filter { |session| normalized.include?(session.execution_id.to_s) }
      end

      def tool_loop_status(*statuses)
        normalized = statuses.map(&:to_sym)
        add_filter { |session| normalized.include?(session.tool_loop_status) }
      end

      def ownership(*values)
        normalized = values.map(&:to_sym)
        add_filter { |session| normalized.include?(session.ownership) }
      end

      def lifecycle_state(*states)
        normalized = states.map(&:to_sym)
        add_filter { |session| normalized.include?(session.lifecycle_state) }
      end

      def interactive(value = true)
        expected = !!value
        add_filter { |session| session.interactive? == expected }
      end

      def terminal(value = true)
        expected = !!value
        add_filter { |session| session.terminal? == expected }
      end

      def continuable(value = true)
        expected = !!value
        add_filter { |session| session.continuable? == expected }
      end

      def routed(value = true)
        expected = !!value
        add_filter { |session| session.routed? == expected }
      end

      def interaction(*interactions)
        normalized = interactions.map(&:to_sym)
        add_filter do |session|
          normalized.include?(orchestration_metadata_for(session)[:interaction])
        end
      end

      def reason(*reasons)
        normalized = reasons.map(&:to_sym)
        add_filter do |session|
          normalized.include?(orchestration_metadata_for(session)[:reason])
        end
      end

      def attention_required(value = true)
        expected = !!value
        add_filter do |session|
          orchestration_metadata_for(session)[:attention_required] == expected
        end
      end

      def resumable(value = true)
        expected = !!value
        add_filter do |session|
          orchestration_metadata_for(session)[:resumable] == expected
        end
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
        result = @sessions.select { |session| match?(session) }
        result = apply_orderings(result) unless @orderings.empty?
        @limit_count ? result.first(@limit_count) : result
      end

      def each(&block)
        to_a.each(&block)
      end

      def count
        @sessions.count { |session| match?(session) }
      end

      def empty?
        !@sessions.any? { |session| match?(session) }
      end

      def first(count = nil)
        count ? to_a.first(count) : to_a.first
      end

      def facet(dimension, include_nil: false)
        validate_facet_dimension!(dimension)

        to_a.each_with_object(Hash.new(0)) do |session, memo|
          value = dimension_value(session, dimension)
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
          by_agent: facet(:agent_name),
          by_node: facet(:node_name),
          by_message: facet(:message_name),
          by_mode: facet(:mode),
          by_reply_mode: facet(:reply_mode),
          by_phase: facet(:phase),
          by_ownership: facet(:ownership),
          by_lifecycle_state: facet(:lifecycle_state),
          by_tool_loop_status: facet(:tool_loop_status),
          by_interaction: facet(:interaction),
          by_reason: facet(:reason),
          interactive: interactive.count,
          terminal: terminal.count,
          continuable: continuable.count,
          routed: routed.count,
          attention_required: attention_required.count,
          resumable: resumable.count
        }.freeze
      end

      def explain
        lines = ["AgentSessionQuery(#{@sessions.size} candidates)"]
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
        query.instance_variable_set(:@sessions, @sessions)
        query.instance_variable_set(:@execution, @execution)
        query.instance_variable_set(:@filters, @filters.dup.freeze)
        query.instance_variable_set(:@orderings, @orderings.dup.freeze)
        query.instance_variable_set(:@limit_count, @limit_count)
        yield query
        query.freeze
        query
      end

      def match?(session)
        @filters.all? { |filter| filter.call(session) }
      end

      def apply_orderings(sessions)
        sessions.sort do |left, right|
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

      def dimension_value(session, dimension)
        return dimension.call(session) if dimension.respond_to?(:call)

        metadata = orchestration_metadata_for(session)

        case dimension
        when :node_name then session.node_name
        when :agent_name then session.agent_name
        when :message_name then session.message_name
        when :mode then session.mode
        when :reply_mode then session.reply_mode
        when :waiting_on then session.waiting_on
        when :source_node then session.source_node
        when :turn then session.turn
        when :phase then session.phase
        when :tool_loop_status then session.tool_loop_status
        when :ownership then session.ownership
        when :lifecycle_state then session.lifecycle_state
        when :interactive then session.interactive?
        when :terminal then session.terminal?
        when :continuable then session.continuable?
        when :routed then session.routed?
        when :interaction then metadata[:interaction]
        when :attention_required then metadata[:attention_required]
        when :reason then metadata[:reason]
        when :resumable then metadata[:resumable]
        else
          nil
        end
      end

      def orchestration_metadata_for(session)
        orchestration_metadata.fetch(session.node_name.to_sym, EMPTY_ORCHESTRATION_METADATA)
      end

      EMPTY_ORCHESTRATION_METADATA = {
        interaction: nil,
        reason: nil,
        attention_required: false,
        resumable: false
      }.freeze

      def orchestration_metadata
        return {} unless @execution

        Array(@execution.orchestration_plan[:actions]).each_with_object({}) do |entry, memo|
          memo[entry[:node].to_sym] = {
            interaction: entry[:interaction]&.to_sym,
            reason: entry[:reason]&.to_sym,
            attention_required: !!entry[:attention_required],
            resumable: !!entry[:resumable]
          }.freeze
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
