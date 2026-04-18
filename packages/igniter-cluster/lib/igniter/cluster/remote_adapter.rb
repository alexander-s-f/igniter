# frozen_string_literal: true

module Igniter
  module Cluster
    # Cluster-aware remote adapter.
    #
    # Builds on top of the plain server transport and adds capability/pinned
    # peer resolution via mesh routing.
    class RemoteAdapter < Igniter::Server::RemoteAdapter
      def call(node:, inputs:, execution: nil)
        super
      rescue Igniter::Cluster::Mesh::DeferredCapabilityError => e
        publish_pending_routing_trace(node, e, execution)
        raise
      rescue Igniter::Cluster::Mesh::IncidentError => e
        publish_failed_routing_trace(node, e, execution)
        raise
      end

      private

      def resolve_url(node)
        case node.routing_mode
        when :capability
          resolve_capability_url(node)
        when :pinned
          resolve_pinned_url(node)
        else
          super
        end
      end

      def resolve_capability_url(node)
        query = node.capability_query || { all_of: [node.capability] }
        deferred = Igniter::Runtime::DeferredResult.build(
          payload: { capability: node.capability, query: query },
          source_node: node.name,
          waiting_on: node.name
        )
        if node.capability_query
          Igniter::Cluster::Mesh.router.find_peer_for_query(node.capability_query, deferred)
        else
          Igniter::Cluster::Mesh.router.find_peer_for(node.capability, deferred)
        end
      end

      def resolve_pinned_url(node)
        Igniter::Cluster::Mesh.router.resolve_pinned(node.pinned_to)
      end

      def publish_pending_routing_trace(node, error, execution)
        report = Igniter::Cluster::Diagnostics::RoutingContributor.report_for_trace(
          node_name: node.name,
          path: node.path,
          status: :pending,
          routing_trace: error.explanation,
          token: error.deferred_result.token,
          waiting_on: error.deferred_result.waiting_on || node.name,
          source_node: error.deferred_result.source_node || node.name,
          latest_event_type: :node_pending
        )

        enrich_and_record_report!(report, execution)
      end

      def publish_failed_routing_trace(node, error, execution)
        routing_trace = error.context[:routing_trace]
        return unless routing_trace

        report = Igniter::Cluster::Diagnostics::RoutingContributor.report_for_trace(
          node_name: node.name,
          path: node.path,
          status: :failed,
          routing_trace: routing_trace,
          error: {
            type: error.class.name,
            message: error.message
          },
          latest_event_type: :node_failed
        )

        enrich_and_record_report!(report, execution)
      end

      def enrich_and_record_report!(report, execution)
        return unless report.is_a?(Hash)

        if execution
          report = report.merge(
            graph: execution.compiled_graph.name,
            execution_id: execution.events.execution_id
          )
        end

        Igniter::Cluster::Mesh.config.record_routing_report!(report)
      rescue StandardError
        nil
      end
    end
  end
end
