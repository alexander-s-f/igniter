# frozen_string_literal: true

module Igniter
  module Cluster
    module Replication
    # Analyses network topology + episodic memory to produce an ExpansionPlan.
    #
    # Two modes of operation:
    # * **Rule-based** (default) — applies fixed heuristics, no LLM required.
    # * **LLM-assisted** — delegates to an LLM executor for intent-rich reasoning.
    #
    # Rule-based heuristics (applied in order):
    # 1. Retire nodes marked unhealthy in the topology.
    # 2. Spawn a new node for each required capability query absent from the topology.
    # 3. Annotate the rationale when recent replication failures exceed the threshold.
    # 4. Honour :scale_signal episodes (content: "scale_out:<capability>[+<capability>]").
    #
    # LLM mode receives topology snapshot + recent episodes and expects the
    # executor to return { actions: [...], rationale: "..." }.
    #
    # @example Rule-based
    #   topology = NetworkTopology.new
    #   topology.register(node_id: "x", host: "10.0.0.1", capabilities: [:local_llm])
    #
    #   planner = ExpansionPlanner.new(
    #     topology:              topology,
    #     required_capabilities: [[:local_llm], %i[container_runtime local_llm]],
    #     host_pool:             ["10.0.0.2"]
    #   )
    #   plan = planner.plan
    #   # plan.actions => [{ action: :replicate_capabilities, query: { all_of: [:container_runtime, :local_llm] }, host: "10.0.0.2" }]
    class ExpansionPlanner
      DEFAULT_FAILURE_THRESHOLD = 3

      # @param topology          [NetworkTopology]     current node topology
      # @param memory            [AgentMemory, nil]    episodic memory (optional)
      # @param required_capabilities [Array<CapabilityQuery, Array<Symbol>, Hash, Symbol>]
      #   capability slices that must always be present
      # @param failure_threshold [Integer]             replication failures before warning
      # @param host_pool         [Array<String>]       candidate hosts for new nodes
      # @param llm               [#call, nil]          optional LLM executor
      def initialize(topology:, memory: nil, required_capabilities: [],
                     failure_threshold: DEFAULT_FAILURE_THRESHOLD,
                     host_pool: [], llm: nil)
        @topology              = topology
        @memory                = memory
        @required_capabilities = Array(required_capabilities).map { |query| CapabilityQuery.normalize(query) }
        @failure_threshold     = failure_threshold
        @host_pool             = host_pool.dup
        @llm                   = llm
      end

      # Produce an ExpansionPlan.
      #
      # @return [ExpansionPlan]
      def plan
        @llm ? smart_plan : rule_based_plan
      end

      private

      def rule_based_plan
        actions   = []
        rationale = []

        retire_unhealthy(actions, rationale)
        ensure_required_capabilities(actions, rationale)
        check_failure_signal(rationale)
        apply_scale_signals(actions, rationale)

        actions << { action: :no_op } if actions.empty?
        ExpansionPlan.new(actions: actions, rationale: rationale.join("; "))
      end

      def retire_unhealthy(actions, rationale)
        @topology.nodes.reject(&:healthy).each do |node|
          actions   << { action: :retire_node, node_id: node.node_id, host: node.host }
          rationale << "node #{node.node_id} (#{node.host}) is unhealthy"
        end
      end

      def ensure_required_capabilities(actions, rationale)
        @required_capabilities.each do |query|
          next unless @topology.needs_capability_query?(query)

          host = next_available_host
          if host
            actions   << { action: :replicate_capabilities, query: query.to_h, host: host }
            rationale << "capability query #{query.label.inspect} absent; targeting #{host}"
          else
            rationale << "capability query #{query.label.inspect} absent but no available host in pool"
          end
        end
      end

      def check_failure_signal(rationale)
        return unless @memory

        failures = @memory.recent(last: 20, type: :replication_event)
                          .count { |e| e.outcome == "failure" }
        if failures >= @failure_threshold
          rationale << "#{failures} recent replication failures — check SSH credentials"
        end
      end

      def apply_scale_signals(actions, rationale)
        return unless @memory

        @memory.recent(last: 10, type: :scale_signal).each do |ep|
          m = ep.content.to_s.match(/\Ascale_out:([@\w+,-]+)\z/)
          next unless m

          query = parse_scale_query(m[1])
          host = next_available_host
          if host
            actions   << { action: :replicate_capabilities, query: query.to_h, host: host }
            rationale << "scale_signal requests #{query.label.inspect} at #{host}"
          end
        end
      end

      def smart_plan
        episodes = @memory&.recent(last: 50) || []
        result   = @llm.call(
          topology:       @topology.nodes.map { |n|
                            { node_id: n.node_id, host: n.host,
                              capabilities: n.capabilities, tags: n.tags, healthy: n.healthy }
                          },
          episodes:       episodes.map { |e|
                            { type: e.type, content: e.content, outcome: e.outcome }
                          },
          required_capabilities: @required_capabilities.map(&:to_h),
          host_pool:      @host_pool
        )
        ExpansionPlan.new(actions: Array(result[:actions]), rationale: result[:rationale])
      end

      def next_available_host
        used = @topology.nodes.map(&:host).to_set
        @host_pool.find { |h| !used.include?(h) }
      end

      def parse_scale_query(signature)
        body, tag_part = signature.split("@", 2)

        CapabilityQuery.new(
          all_of: body.to_s.split("+").reject(&:empty?),
          tags:   tag_part.to_s.split("+").reject(&:empty?)
        )
      end
    end
    end
  end
end
