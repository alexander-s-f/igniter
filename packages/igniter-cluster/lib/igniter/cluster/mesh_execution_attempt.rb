# frozen_string_literal: true

module Igniter
  module Cluster
    class MeshExecutionAttempt
      attr_reader :peer_name, :status, :request, :response_metadata, :explanation

      def initialize(peer_name:, status:, request:, response_metadata: {}, explanation: nil)
        @peer_name = peer_name.to_sym
        @status = status.to_sym
        @request = request
        @response_metadata = response_metadata.dup.freeze
        @explanation = DecisionExplanation.normalize(
          explanation,
          default_code: @status,
          metadata: @response_metadata
        )
        freeze
      end

      def completed?
        status == :completed
      end

      def failed?
        status == :failed
      end

      def skipped?
        status == :skipped
      end

      def to_h
        {
          peer: peer_name,
          status: status,
          request: request.to_h,
          response_metadata: response_metadata.dup,
          explanation: explanation&.to_h
        }
      end
    end
  end
end
