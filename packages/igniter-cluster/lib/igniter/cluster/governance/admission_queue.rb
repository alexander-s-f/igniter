# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Governance
      # Thread-safe in-memory queue of admission requests awaiting operator approval.
      #
      # Requests stay in the queue until:
      #   - explicitly approved via approve!(request_id)
      #   - explicitly rejected via reject!(request_id)
      #   - expired by expire_stale! when their age exceeds max_ttl
      class AdmissionQueue
        def initialize
          @pending = {}
          @mutex   = Mutex.new
        end

        # Enqueue a request. Re-enqueuing the same request_id is idempotent.
        #
        # @param request [AdmissionRequest]
        # @return [AdmissionRequest]
        def enqueue(request)
          @mutex.synchronize { @pending[request.request_id] = request }
          request
        end

        # All currently pending requests (snapshot).
        #
        # @return [Array<AdmissionRequest>]
        def pending
          @mutex.synchronize { @pending.values.dup }
        end

        # Retrieve a specific pending request by id, or nil.
        #
        # @param request_id [String]
        # @return [AdmissionRequest, nil]
        def find(request_id)
          @mutex.synchronize { @pending[request_id.to_s] }
        end

        # Remove and return the request with the given id (approve or reject path).
        #
        # @param request_id [String]
        # @return [AdmissionRequest, nil]
        def dequeue(request_id)
          @mutex.synchronize { @pending.delete(request_id.to_s) }
        end

        # Remove all requests older than ttl_seconds from now.
        #
        # @param ttl_seconds [Integer]
        # @param now         [Time]
        # @return [Array<AdmissionRequest>]  the expired requests
        def expire_stale!(ttl_seconds, now: Time.now.utc)
          cutoff = now - ttl_seconds
          expired = []
          @mutex.synchronize do
            @pending.reject! do |_id, req|
              ts = Time.parse(req.requested_at) rescue nil
              next false unless ts
              next false if ts >= cutoff

              expired << req
              true
            end
          end
          expired
        end

        def size
          @mutex.synchronize { @pending.size }
        end

        def empty?
          size.zero?
        end

        def clear!
          @mutex.synchronize { @pending.clear }
          self
        end
      end
    end
  end
end
