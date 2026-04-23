# frozen_string_literal: true

module Igniter
  module Cluster
    module Governance
      # Orchestrates the full peer admission lifecycle:
      #
      #   1. Accept an AdmissionRequest
      #   2. Evaluate it against AdmissionPolicy + TrustStore
      #   3. Record the outcome in the Governance Trail
      #   4. Update the TrustStore on admission
      #   5. Auto-register the peer in PeerRegistry when url is present
      #   6. Return a typed AdmissionDecision
      #
      # Outcomes recorded in the governance trail:
      #   :admission_requested     — every inbound request
      #   :admission_admitted      — auto-admitted by policy (known key or open policy)
      #   :admission_pending       — enqueued, awaiting operator approval
      #   :admission_approved      — operator approved a pending request
      #   :admission_rejected      — rejected by policy or operator
      #   :admission_expired       — pending request timed out
      #
      # Usage:
      #   workflow = AdmissionWorkflow.new(config: Igniter::Cluster::Mesh.config)
      #   decision = workflow.request_admission(peer_name: "node-b", node_id: "b", public_key: pem)
      #   decision.pending_approval?  # => true
      #   workflow.approve_pending!(decision.request.request_id)  # => AdmissionDecision(:admitted)
      class AdmissionWorkflow
        def initialize(config:)
          @config = config
        end

        # Submit a new admission request and return the immediate decision.
        #
        # @param peer_name    [String]
        # @param node_id      [String]
        # @param public_key   [String]  PEM-encoded public key
        # @param capabilities [Array<Symbol>]
        # @param justification [String, nil]
        # @return [AdmissionDecision]
        def request_admission(peer_name:, node_id:, public_key:, url: nil, capabilities: [], justification: nil)
          request = AdmissionRequest.build(
            peer_name:     peer_name,
            node_id:       node_id,
            public_key:    public_key,
            url:           url,
            capabilities:  capabilities,
            justification: justification
          )

          trail_record(:admission_requested, request: request)

          outcome = policy.evaluate(request, trust_store)
          decision = AdmissionDecision.build(request: request, outcome: outcome,
                                             rationale: rationale_for(outcome, request))

          case outcome
          when :admitted
            admit_to_trust_store!(request)
            register_in_peer_registry!(request)
            trail_record(:admission_admitted, request: request)
          when :pending_approval
            queue.enqueue(request)
            trail_record(:admission_pending, request: request)
          when :rejected
            trail_record(:admission_rejected, request: request,
                         extra: { reason: :forbidden_capability })
          when :already_trusted
            # no trail entry — idempotent
          end

          decision
        end

        # Approve a pending request by its request_id.
        #
        # @param request_id [String]
        # @return [AdmissionDecision]  :admitted or :not_found
        def approve_pending!(request_id)
          request = queue.dequeue(request_id.to_s)
          unless request
            return AdmissionDecision.build(
              request:   stub_request(request_id),
              outcome:   :rejected,
              rationale: "request not found in pending queue"
            )
          end

          admit_to_trust_store!(request)
          register_in_peer_registry!(request)
          trail_record(:admission_approved, request: request)
          AdmissionDecision.build(request: request, outcome: :admitted,
                                  rationale: "approved by operator")
        end

        # Reject a pending request by its request_id.
        #
        # @param request_id [String]
        # @param reason     [String, nil]
        # @return [AdmissionDecision]
        def reject_pending!(request_id, reason: nil)
          request = queue.dequeue(request_id.to_s)
          unless request
            return AdmissionDecision.build(
              request:   stub_request(request_id),
              outcome:   :rejected,
              rationale: "request not found in pending queue"
            )
          end

          trail_record(:admission_rejected, request: request,
                       extra: { reason: reason || :operator_rejected })
          AdmissionDecision.build(request: request, outcome: :rejected,
                                  rationale: reason || "rejected by operator")
        end

        # Approve all currently pending requests.
        #
        # @return [Array<AdmissionDecision>]
        def approve_all_pending!
          queue.pending.map { |req| approve_pending!(req.request_id) }
        end

        # Expire pending requests older than the policy TTL.
        #
        # @param now [Time]
        # @return [Array<AdmissionDecision>]
        def expire_stale!(now: Time.now.utc)
          expired = queue.expire_stale!(policy.max_pending_ttl, now: now)
          expired.map do |req|
            trail_record(:admission_expired, request: req)
            AdmissionDecision.build(request: req, outcome: :rejected,
                                    rationale: "pending request expired (ttl=#{policy.max_pending_ttl}s)")
          end
        end

        # All currently pending requests.
        #
        # @return [Array<AdmissionRequest>]
        def pending_requests
          queue.pending
        end

        private

        def policy
          @config.admission_policy ||= AdmissionPolicy.new
        end

        def queue
          @config.admission_queue ||= AdmissionQueue.new
        end

        def trust_store
          @config.trust_store
        end

        def admit_to_trust_store!(request)
          trust_store.add(
            request.node_id,
            public_key: request.public_key,
            label:      request.peer_name
          )
        end

        def register_in_peer_registry!(request)
          return unless request.routable?

          peer = Igniter::Cluster::Mesh::Peer.new(
            name:         request.peer_name,
            url:          request.url,
            capabilities: request.capabilities,
            tags:         [],
            metadata:     {
              mesh_trust:    { status: "trusted", trusted: true },
              mesh_identity: { node_id: request.node_id, fingerprint: request.fingerprint }
            }
          )
          @config.peer_registry.register(peer)
        end

        def trail_record(type, request:, extra: {})
          @config.governance_trail&.record(
            type,
            source:  :admission_workflow,
            payload: {
              request_id:  request.request_id,
              peer_name:   request.peer_name,
              node_id:     request.node_id,
              fingerprint: request.fingerprint,
              capabilities: request.capabilities
            }.merge(extra).compact
          )
        end

        def rationale_for(outcome, request)
          case outcome
          when :admitted        then "auto-admitted by policy (known key)"
          when :pending_approval then "no matching known key — queued for approval"
          when :rejected        then "request contains forbidden capability"
          when :already_trusted then "node_id already in trust store"
          end
        end

        def stub_request(request_id)
          AdmissionRequest.new(
            request_id: request_id.to_s, peer_name: "unknown", node_id: "unknown",
            public_key: "", url: "", capabilities: [], justification: nil, requested_at: Time.now.utc.iso8601
          )
        end
      end
    end
  end
end
