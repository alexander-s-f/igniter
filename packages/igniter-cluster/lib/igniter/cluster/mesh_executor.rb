# frozen_string_literal: true

module Igniter
  module Cluster
    class MeshExecutor
      attr_reader :environment, :metadata, :discovery, :retry_policy, :admission, :membership_source

      def initialize(environment:, metadata: {}, id_generator: nil, discovery: nil, retry_policy: nil,
                     admission: nil, trust_policy: nil, membership_source: nil)
        @environment = environment
        @metadata = metadata.dup.freeze
        @id_generator = id_generator || method(:default_trace_id)
        @discovery = discovery || PeerDiscovery.new
        @retry_policy = retry_policy || MeshRetryPolicy.new(name: :best_effort)
        @admission = admission || MeshAdmission.new(policy: trust_policy || MeshTrustPolicy.permissive)
        @membership_source = membership_source || RegistryMembershipSource.new
        @sequence = 0
      end

      def call(plan:, plan_kind:, action:, environment: self.environment)
        membership = membership_source.call(
          environment: environment,
          allow_degraded: retry_policy.allow_degraded,
          metadata: metadata.merge(retry_policy: retry_policy.to_h)
        )
        discovered_peers = retry_policy.candidate_peers(
          discovery.peers_for(plan_kind: plan_kind, plan: plan, action: action, membership: membership)
        )
        candidate_peers, admission_results = admit_candidates(
          discovered_peers: discovered_peers,
          plan_kind: plan_kind,
          action: action,
          membership: membership
        )
        return no_candidate_result(plan_kind: plan_kind, plan: plan, action: action, membership: membership) if candidate_peers.empty?

        attempts, trace_id, response = execute_attempts(
          candidate_peers: candidate_peers,
          plan_kind: plan_kind,
          action: action
        )
        trace = build_trace(
          trace_id: trace_id,
          plan_kind: plan_kind,
          attempts: attempts,
          candidate_peers: candidate_peers,
          membership: membership,
          admission_results: admission_results
        )

        PlanActionResult.new(
          action_type: action_type_for(plan_kind),
          status: final_status(attempts),
          subject: subject_for(plan_kind, action),
          metadata: {
            simulated: false,
            mesh: trace.to_h,
            action: action.to_h
          }.merge(response.metadata),
          explanation: DecisionExplanation.new(
            code: :"mesh_#{plan_kind}_action",
            message: mesh_message(plan_kind, attempts.last.peer_name, final_status(attempts)),
            metadata: {
              peer: attempts.last.peer_name,
              trace_id: trace_id
            }
          )
        )
      rescue StandardError => e
        PlanActionResult.new(
          action_type: action_type_for(plan_kind),
          status: :failed,
          subject: subject_for(plan_kind, action),
          metadata: {
            simulated: false,
            error: {
              class: e.class.name,
              message: e.message
            }
          },
          explanation: DecisionExplanation.new(
            code: :"mesh_#{plan_kind}_failed",
            message: "mesh execution failed for #{plan_kind}",
            metadata: {
              error_class: e.class.name
            }
          )
        )
      end

      private

      def admit_candidates(discovered_peers:, plan_kind:, action:, membership:)
        results = []
        candidates = []

        Array(discovered_peers).each do |peer|
          result = admission.admit(peer: peer, plan_kind: plan_kind, action: action, membership: membership)
          results << result
          candidates << peer if result.allowed?
        end

        [candidates.freeze, results.freeze]
      end

      def execute_attempts(candidate_peers:, plan_kind:, action:)
        attempts = []
        trace_id = nil
        last_response = MeshExecutionResponse.new(status: :skipped, metadata: {})

        candidate_peers.each do |peer|
          trace_id ||= next_trace_id(plan_kind: plan_kind, peer_name: peer.name)
          request = build_request(
            trace_id: trace_id,
            plan_kind: plan_kind,
            action: action,
            peer: peer
          )
          response = normalize_response(peer.transport.call(request: request))
          attempts << MeshExecutionAttempt.new(
            peer_name: peer.name,
            status: response.status,
            request: request,
            response_metadata: response.metadata,
            explanation: response.explanation || DecisionExplanation.new(
              code: :"mesh_#{response.status}",
              message: "#{response.status} mesh execution on #{peer.name}",
              metadata: response.metadata
            )
          )
          last_response = response
          break unless retry_policy.retryable_status?(response.status)
        end

        [attempts.freeze, trace_id, last_response]
      end

      def normalize_response(raw_response)
        return raw_response if raw_response.is_a?(MeshExecutionResponse)

        metadata =
          case raw_response
          when Hash
            raw_response
          when nil
            {}
          else
            { handler_result: raw_response }
          end

        MeshExecutionResponse.new(
          status: :completed,
          metadata: metadata,
          explanation: DecisionExplanation.new(
            code: :mesh_completed,
            message: "mesh peer accepted action",
            metadata: metadata
          )
        )
      end

      def build_request(trace_id:, plan_kind:, action:, peer:)
        MeshExecutionRequest.new(
          trace_id: trace_id,
          plan_kind: plan_kind,
          action_type: action_type_for(plan_kind),
          subject: subject_for(plan_kind, action),
          action: action.to_h,
          metadata: metadata.merge(
            peer: peer.to_h,
            retry_policy: retry_policy.to_h,
            discovery: discovery.to_h,
            admission: admission.to_h
          )
        )
      end

      def build_trace(trace_id:, plan_kind:, attempts:, candidate_peers:, membership:, admission_results:)
        MeshExecutionTrace.new(
          trace_id: trace_id,
          plan_kind: plan_kind,
          attempts: attempts,
          metadata: {
            candidate_peers: candidate_peers.map(&:to_h),
            membership: membership.to_h,
            admission_results: admission_results.map(&:to_h),
            mesh_executor: metadata.dup,
            retry_policy: retry_policy.to_h,
            discovery: discovery.to_h,
            admission: admission.to_h
          },
          explanation: DecisionExplanation.new(
            code: :"mesh_#{plan_kind}_execution",
            message: mesh_message(plan_kind, attempts.last.peer_name, final_status(attempts)),
            metadata: {
              peer: attempts.last.peer_name,
              status: final_status(attempts),
              attempt_count: attempts.length
            }
          )
        )
      end

      def no_candidate_result(plan_kind:, plan:, action:, membership:)
        PlanActionResult.new(
          action_type: action_type_for(plan_kind),
          status: :failed,
          subject: subject_for(plan_kind, action),
          metadata: {
            simulated: false,
            mesh: {
              plan_kind: plan_kind,
              candidate_peers: [],
              membership: membership.to_h,
              plan: plan.to_h,
              admission: admission.to_h
            }
          },
          explanation: DecisionExplanation.new(
            code: :"mesh_#{plan_kind}_unavailable",
            message: "no mesh candidate peer available for #{plan_kind}",
            metadata: {
              membership: membership.to_h
            }
          )
        )
      end

      def action_type_for(plan_kind)
        :"#{plan_kind}_action"
      end

      def final_status(attempts)
        return :failed if attempts.empty?
        return :completed if attempts.any?(&:completed?)
        return :skipped if attempts.all?(&:skipped?)

        :failed
      end

      def subject_for(plan_kind, action)
        case plan_kind.to_sym
        when :rebalance
          {
            source: action.source.name,
            destination: action.destination.name
          }
        when :ownership, :lease
          {
            target: action.target,
            owner: action.owner.name
          }
        when :failover
          {
            target: action.target,
            source: action.source.name,
            destination: action.destination.name
          }
        else
          action.to_h
        end
      end

      def mesh_message(plan_kind, peer_name, status)
        "#{status} #{plan_kind} mesh action via #{peer_name}"
      end

      def next_trace_id(plan_kind:, peer_name:)
        @sequence += 1
        @id_generator.call(plan_kind: plan_kind, peer_name: peer_name, sequence: @sequence)
      end

      def default_trace_id(plan_kind:, peer_name:, sequence:)
        "mesh/#{plan_kind}/#{peer_name}/#{sequence}"
      end
    end
  end
end
