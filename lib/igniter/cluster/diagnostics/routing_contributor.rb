# frozen_string_literal: true

module Igniter
  module Cluster
    module Diagnostics
      module RoutingContributor
        class << self
          def augment(report:, execution:)
            routing = summarize_routing(execution)
            report[:routing] = routing
            augment_outputs(report: report, execution: execution, routing: routing)
            augment_errors(report: report, routing: routing)
            report
          end

          def append_text(report:, lines:)
            routing = report[:routing] || empty_routing
            return if routing[:entries].empty?

            summaries = routing[:entries].map do |entry|
              summary = "#{entry[:node_name]}(#{entry[:status]} #{entry[:routing_trace_summary]})"
              summary += " token=#{entry[:token]}" if entry[:token]
              summary += " hints=#{entry[:remediation].map { |hint| hint[:code] }.join('+')}" if entry[:remediation]&.any?
              summary
            end

            lines << "Routing: #{routing_overview(routing)} #{summaries.join(', ')}"
          end

          def append_markdown_summary(report:, lines:)
            routing = report[:routing] || empty_routing
            return if routing[:entries].empty?

            lines << "- Routing: #{routing_overview(routing)}"
          end

          def append_markdown_sections(report:, lines:)
            routing = report[:routing] || empty_routing
            return if routing[:entries].empty?

            lines << ""
            lines << "## Routing"
            routing[:entries].each do |entry|
              line = "- `#{entry[:node_name]}` `#{entry[:status]}`: `#{entry[:routing_trace_summary]}`"
              line += " token=`#{entry[:token]}`" if entry[:token]
              line += " error=`#{entry[:error][:message]}`" if entry[:error]
              line += " hints=`#{entry[:remediation].map { |hint| hint[:code] }.join('+')}`" if entry[:remediation]&.any?
              lines << line
            end
          end

          private

          def augment_outputs(report:, execution:, routing:)
            routing_by_node = routing[:entries].each_with_object({}) do |entry, memo|
              memo[entry[:node_name].to_sym] = entry
            end

            execution.compiled_graph.outputs.each do |output_node|
              entry = routing_by_node[output_node.source_root.to_sym]
              value = report[:outputs][output_node.name]
              next unless entry && value.is_a?(Hash)

              report[:outputs][output_node.name] = value.merge(
                routing_trace: entry[:routing_trace],
                routing_trace_summary: entry[:routing_trace_summary],
                classification: entry[:classification],
                remediation: entry[:remediation]
              )
            end
          end

          def augment_errors(report:, routing:)
            routing_by_node = routing[:entries].each_with_object({}) do |entry, memo|
              memo[entry[:node_name].to_sym] = entry
            end

            report[:errors].map! do |error|
              entry = routing_by_node[error[:node_name].to_sym]
              next error unless entry

              error.merge(
                routing_trace: entry[:routing_trace],
                routing_trace_summary: entry[:routing_trace_summary],
                classification: entry[:classification],
                remediation: entry[:remediation]
              )
            end
          end

          def summarize_routing(execution)
            entries = execution.cache.values.filter_map do |state|
              routing_entry_for(state, execution)
            end

            {
              total: entries.size,
              pending: entries.count { |entry| entry[:status] == :pending },
              failed: entries.count { |entry| entry[:status] == :failed },
              facets: summarize_routing_facets(entries),
              plans: summarize_routing_plans(entries),
              entries: entries
            }
          end

          def routing_entry_for(state, execution)
            if state.pending? && state.value.is_a?(Igniter::Runtime::DeferredResult) && state.value.routing_trace
              events = summarize_node_events(execution, state.node.name)
              classification = classify_routing_trace(:pending, state.value.routing_trace, events)
              remediation = remediation_hints(classification, state.value.routing_trace)

              return {
                node_name: state.node.name,
                path: state.node.path,
                status: :pending,
                token: state.value.token,
                waiting_on: state.value.waiting_on,
                source_node: state.value.source_node,
                events: events,
                routing_trace: state.value.routing_trace,
                routing_trace_summary: summarize_routing_trace(state.value.routing_trace),
                classification: classification,
                remediation: remediation
              }
            end

            return unless state.failed?

            context = state.error.respond_to?(:context) ? state.error.context : {}
            routing_trace = extract_routing_trace(context)
            return unless routing_trace

            events = summarize_node_events(execution, state.node.name)
            classification = classify_routing_trace(:failed, routing_trace, events)
            remediation = remediation_hints(classification, routing_trace)

            {
              node_name: state.node.name,
              path: state.node.path,
              status: :failed,
              events: events,
              error: {
                type: state.error.class.name,
                message: state.error.message
              },
              routing_trace: routing_trace,
              routing_trace_summary: summarize_routing_trace(routing_trace),
              classification: classification,
              remediation: remediation
            }
          end

          def summarize_routing_facets(entries)
            {
              by_status: count_by(entries) { |entry| entry[:status] },
              by_mode: count_by(entries) { |entry| entry.dig(:classification, :routing_mode) },
              by_reason: count_many(entries) { |entry| entry.dig(:classification, :reasons) },
              by_mismatch_dimension: count_many(entries) { |entry| entry.dig(:classification, :mismatch_dimensions) },
              by_trust_key: count_many(entries) { |entry| entry.dig(:classification, :trust_keys) },
              by_decision_mode: count_by(entries) { |entry| entry.dig(:classification, :decision_mode) },
              by_policy_key: count_many(entries) { |entry| entry.dig(:classification, :policy_keys) },
              by_latest_event: count_by(entries) { |entry| entry.dig(:classification, :latest_event_type) },
              by_incident: count_by(entries) { |entry| entry.dig(:classification, :incident) },
              by_remediation_code: count_many(entries) { |entry| entry[:remediation].map { |hint| hint[:code] } },
              by_plan_action: count_many(entries) { |entry| entry[:remediation].map { |hint| hint.dig(:plan, :action) } }
            }
          end

          def summarize_routing_plans(entries)
            plans = {}

            entries.each do |entry|
              entry[:remediation].each do |hint|
                plan = hint[:plan]
                next unless plan

                key = [plan[:action], plan[:scope], plan[:automated], plan[:requires_approval], plan[:params]].hash
                plans[key] ||= plan.merge(sources: [])
                plans[key][:sources] << {
                  node_name: entry[:node_name],
                  status: entry[:status],
                  incident: entry.dig(:classification, :incident),
                  hint_code: hint[:code]
                }
              end
            end

            plans.values.each { |plan| plan[:sources] = plan[:sources].uniq.freeze }
            plans.values.freeze
          end

          def classify_routing_trace(status, trace, events = {})
            query = normalized_trace_query(trace)
            trust = hash_value(query, :trust)
            policy = hash_value(query, :policy)
            decision = hash_value(query, :decision)
            reasons = routing_reasons(trace)
            mismatch_dimensions = trace_mismatch_dimensions(trace)
            latest_event_type = hash_value(events, :latest_type)

            {
              status: status,
              routing_mode: hash_value(trace, :routing_mode) || (hash_value(trace, :peer_name) ? :pinned : :capability),
              reasons: reasons,
              mismatch_dimensions: mismatch_dimensions,
              trust_keys: normalized_hash_keys(trust),
              decision_mode: hash_value(decision || {}, :mode),
              decision_actions: Array(hash_value(decision || {}, :actions)).compact,
              risky_actions: Array(hash_value(decision || {}, :risky)).compact,
              policy_keys: normalized_hash_keys(policy),
              latest_event_type: latest_event_type,
              incident: classify_routing_incident(status, trace, reasons, mismatch_dimensions)
            }
          end

          def classify_routing_incident(status, trace, reasons, mismatch_dimensions)
            return :unknown_peer if reasons.include?(:unknown_peer)
            return :peer_unreachable if reasons.include?(:unreachable)
            return :trust_gate if mismatch_dimensions.include?(:trust)
            return :policy_gate if mismatch_dimensions.include?(:policy) || mismatch_dimensions.include?(:decision)
            return :capacity_shortage if mismatch_dimensions.include?(:capabilities) || mismatch_dimensions.include?(:tags) || mismatch_dimensions.include?(:metadata)
            return :capacity_shortage if status == :pending && hash_value(trace, :peer_count).to_i.zero?
            return :routing_pending if status == :pending
            return :routing_failed if status == :failed

            :routing_observed
          end

          def remediation_hints(classification, trace)
            incident = classification[:incident]
            query = normalized_trace_query(trace)

            case incident
            when :unknown_peer
              [build_hint(
                :register_peer,
                "Register the pinned peer or update the pinned route name.",
                { peer_name: hash_value(trace, :peer_name) },
                plan: build_plan(
                  :register_peer,
                  scope: :mesh_topology,
                  automated: false,
                  requires_approval: true,
                  params: { peer_name: hash_value(trace, :peer_name) }
                )
              )]
            when :peer_unreachable
              [build_hint(
                :restore_peer_connectivity,
                "Restore connectivity or health for the selected peer before retrying.",
                {
                  peer_name: hash_value(trace, :peer_name) || hash_value(trace, :selected_peer),
                  selected_url: hash_value(trace, :selected_url)
                },
                plan: build_plan(
                  :refresh_peer_health,
                  scope: :mesh_health,
                  automated: true,
                  requires_approval: false,
                  params: {
                    peer_name: hash_value(trace, :peer_name) || hash_value(trace, :selected_peer),
                    selected_url: hash_value(trace, :selected_url)
                  }
                )
              )]
            when :trust_gate
              trust_gate_hints(classification)
            when :policy_gate
              policy_gate_hints(classification)
            when :capacity_shortage
              capacity_hints(classification, trace, query)
            else
              [build_hint(
                :retry_routing,
                "Retry routing after topology and health information refreshes.",
                plan: build_plan(
                  :retry_routing,
                  scope: :routing_execution,
                  automated: true,
                  requires_approval: false
                )
              )]
            end
          end

          def policy_gate_hints(classification)
            hints = []
            actions = classification[:decision_actions]
            policy_keys = classification[:policy_keys]

            if classification[:decision_mode] == :auto_only && actions.any?
              hints << build_hint(
                :request_approval_path,
                "Allow approval-based execution for the requested action set.",
                { decision_mode: classification[:decision_mode], actions: actions },
                plan: build_plan(
                  :retry_with_approval,
                  scope: :routing_decision,
                  automated: false,
                  requires_approval: true,
                  params: { mode: :approval_ok, actions: actions }
                )
              )
            end

            if policy_keys.any?
              hints << build_hint(
                :adjust_policy_requirements,
                "Route to peers whose policy satisfies the requested policy constraints.",
                { policy_keys: policy_keys },
                plan: build_plan(
                  :find_policy_compatible_peer,
                  scope: :routing_policy,
                  automated: true,
                  requires_approval: false,
                  params: { policy_keys: policy_keys }
                )
              )
            end

            hints.empty? ? [build_hint(:review_policy_gate, "Review policy and decision constraints for this route.")] : hints
          end

          def trust_gate_hints(classification)
            trust_keys = classification[:trust_keys]

            [
              build_hint(
                :admit_trusted_peer,
                "Admit or bootstrap a peer whose identity and attestation satisfy the requested trust constraints.",
                { trust_keys: trust_keys },
                plan: build_plan(
                  :admit_trusted_peer,
                  scope: :routing_trust,
                  automated: false,
                  requires_approval: true,
                  params: { trust_keys: trust_keys }
                )
              ),
              build_hint(
                :relax_trust_requirements,
                "Relax route trust requirements if unknown peers are acceptable for this operation.",
                { trust_keys: trust_keys },
                plan: build_plan(
                  :relax_trust_requirements,
                  scope: :routing_trust,
                  automated: false,
                  requires_approval: true,
                  params: { trust_keys: trust_keys }
                )
              )
            ]
          end

          def capacity_hints(classification, trace, query)
            hints = []

            if classification[:mismatch_dimensions].include?(:capabilities)
              hints << build_hint(
                :add_capability_peer,
                "Add or discover a peer that satisfies the required capabilities.",
                {
                  all_of: Array(hash_value(query, :all_of)),
                  any_of: Array(hash_value(query, :any_of))
                },
                plan: build_plan(
                  :discover_capability_peers,
                  scope: :mesh_capacity,
                  automated: true,
                  requires_approval: false,
                  params: {
                    all_of: Array(hash_value(query, :all_of)),
                    any_of: Array(hash_value(query, :any_of))
                  }
                )
              )
            end

            if classification[:mismatch_dimensions].include?(:tags)
              hints << build_hint(
                :relax_tag_constraints,
                "Relax the routing tags or provision peers with the required tags.",
                { tags: Array(hash_value(query, :tags)) },
                plan: build_plan(
                  :relax_route_tags,
                  scope: :routing_query,
                  automated: false,
                  requires_approval: true,
                  params: { tags: Array(hash_value(query, :tags)) }
                )
              )
            end

            if classification[:mismatch_dimensions].include?(:metadata)
              hints << build_hint(
                :relax_metadata_constraints,
                "Relax metadata thresholds or provision peers that satisfy them.",
                { metadata_keys: normalized_hash_keys(hash_value(query, :metadata)) },
                plan: build_plan(
                  :relax_route_metadata,
                  scope: :routing_query,
                  automated: false,
                  requires_approval: true,
                  params: { metadata_keys: normalized_hash_keys(hash_value(query, :metadata)) }
                )
              )
            end

            if hints.empty?
              hints << build_hint(
                :wait_for_peer_discovery,
                "Wait for peer discovery or register additional peers before retrying.",
                { peer_count: hash_value(trace, :peer_count) },
                plan: build_plan(
                  :retry_after_discovery,
                  scope: :mesh_discovery,
                  automated: true,
                  requires_approval: false,
                  params: { peer_count: hash_value(trace, :peer_count) }
                )
              )
            end

            hints
          end

          def summarize_routing_trace(trace)
            return nil unless trace.is_a?(Hash)

            parts = []
            routing_mode = hash_value(trace, :routing_mode)
            query = hash_value(trace, :query)
            capability = hash_value(trace, :capability)
            peer_name = hash_value(trace, :peer_name)
            eligible_count = hash_value(trace, :eligible_count)
            selected_url = hash_value(trace, :selected_url)
            reachable = hash_value(trace, :reachable)
            reasons = routing_reasons(trace)

            parts << "mode=#{routing_mode}" if routing_mode
            parts << "query=#{query.inspect}" if query
            parts << "capability=#{capability.inspect}" if capability
            parts << "peer=#{peer_name}" if peer_name
            parts << "eligible=#{eligible_count}" unless eligible_count.nil?
            parts << "selected=#{selected_url || 'none'}" if trace.key?(:selected_url) || trace.key?("selected_url")
            parts << "reachable=#{reachable}" unless reachable.nil?
            parts << "reasons=#{reasons.join('+')}" unless reasons.empty?
            parts.empty? ? nil : parts.join(" ")
          end

          def summarize_node_events(execution, node_name)
            events = execution.events.events.select { |event| event.node_name == node_name.to_sym }

            {
              total: events.size,
              latest_type: events.last&.type,
              types: events.map(&:type).uniq
            }
          end

          def trace_mismatch_dimensions(trace)
            peers = hash_value(trace, :peers)
            return [] unless peers.is_a?(Array)

            peers.each_with_object([]) do |peer, memo|
              reasons = Array(hash_value(peer, :reasons)).map(&:to_sym)
              next unless reasons.include?(:query_mismatch)

              details = hash_value(peer, :match_details)
              memo.concat(Array(hash_value(details || {}, :failed_dimensions)).map(&:to_sym))
            end.uniq.sort
          end

          def routing_overview(routing)
            facets = routing[:facets] || {}
            parts = [
              "total=#{routing[:total]}",
              "pending=#{routing[:pending]}",
              "failed=#{routing[:failed]}"
            ]
            parts << "modes=#{inline_counts(facets[:by_mode])}" unless facets[:by_mode].nil? || facets[:by_mode].empty?
            parts << "reasons=#{inline_counts(facets[:by_reason])}" unless facets[:by_reason].nil? || facets[:by_reason].empty?
            parts << "incidents=#{inline_counts(facets[:by_incident])}" unless facets[:by_incident].nil? || facets[:by_incident].empty?
            parts << "hints=#{inline_counts(facets[:by_remediation_code])}" unless facets[:by_remediation_code].nil? || facets[:by_remediation_code].empty?
            parts << "plans=#{inline_counts(facets[:by_plan_action])}" unless facets[:by_plan_action].nil? || facets[:by_plan_action].empty?
            parts.join(", ")
          end

          def build_hint(code, message, details = {}, plan: nil)
            {
              code: code,
              message: message,
              plan: plan,
              details: details.compact
            }
          end

          def build_plan(action, scope:, automated:, requires_approval:, params: {})
            {
              action: action,
              scope: scope,
              automated: automated,
              requires_approval: requires_approval,
              params: params.compact
            }
          end

          def normalized_trace_query(trace)
            query = hash_value(trace, :query)
            query = query.to_h if query.respond_to?(:to_h) && !query.is_a?(Hash)
            query || {}
          end

          def extract_routing_trace(context)
            return nil unless context.is_a?(Hash)

            hash_value(context, :routing_trace)
          end

          def routing_reasons(trace)
            reasons = Array(hash_value(trace, :reasons)).compact
            return reasons unless reasons.empty?

            peers = hash_value(trace, :peers)
            return [] unless peers.is_a?(Array)

            peers.flat_map { |peer| Array(hash_value(peer, :reasons)) }.compact.uniq
          end

          def count_by(entries)
            entries.each_with_object(Hash.new(0)) do |entry, memo|
              key = yield(entry)
              next if key.nil?

              memo[key] += 1
            end
          end

          def count_many(entries)
            entries.each_with_object(Hash.new(0)) do |entry, memo|
              Array(yield(entry)).each do |key|
                next if key.nil?

                memo[key] += 1
              end
            end
          end

          def inline_counts(counts)
            counts.map { |key, value| "#{key}=#{value}" }.join("/")
          end

          def normalized_hash_keys(value)
            return [] unless value.is_a?(Hash)

            value.keys.map(&:to_sym).sort
          end

          def hash_value(hash, key)
            return nil unless hash.is_a?(Hash)
            return hash[key] if hash.key?(key)
            return hash[key.to_s] if hash.key?(key.to_s)

            nil
          end

          def empty_routing
            { entries: [], facets: {}, plans: [], total: 0, pending: 0, failed: 0 }
          end
        end
      end
    end
  end
end
