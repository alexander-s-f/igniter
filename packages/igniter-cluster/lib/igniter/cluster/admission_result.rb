# frozen_string_literal: true

module Igniter
  module Cluster
    class AdmissionResult
      attr_reader :code, :metadata, :explanation

      def initialize(allowed:, code:, metadata: {}, explanation: nil)
        @allowed = allowed == true
        @code = code.to_sym
        @metadata = metadata.dup.freeze
        @explanation = explanation
        freeze
      end

      def self.allowed(code: :allowed, metadata: {}, explanation: nil)
        new(allowed: true, code: code, metadata: metadata, explanation: explanation)
      end

      def self.denied(code: :denied, metadata: {}, explanation: nil)
        new(allowed: false, code: code, metadata: metadata, explanation: explanation)
      end

      def allowed?
        @allowed
      end

      def to_h
        {
          allowed: allowed?,
          code: code,
          metadata: metadata.dup,
          explanation: explanation
        }
      end
    end
  end
end
