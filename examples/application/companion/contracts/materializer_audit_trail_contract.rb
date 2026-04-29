# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerAuditTrailContract, outputs: %i[attempt_count blocked_count executed_count blocked_capabilities last_attempt summary] do
      input :attempts

      compute :ordered_attempts, depends_on: [:attempts] do |attempts:|
        Array(attempts).sort_by { |attempt| attempt.fetch(:index).to_i }
      end

      compute :attempt_count, depends_on: [:ordered_attempts] do |ordered_attempts:|
        ordered_attempts.length
      end

      compute :blocked_count, depends_on: [:ordered_attempts] do |ordered_attempts:|
        ordered_attempts.count { |attempt| attempt.fetch(:status).to_sym == :blocked }
      end

      compute :executed_count, depends_on: [:ordered_attempts] do |ordered_attempts:|
        ordered_attempts.count { |attempt| attempt.fetch(:executed) }
      end

      compute :blocked_capabilities, depends_on: [:ordered_attempts] do |ordered_attempts:|
        ordered_attempts
          .flat_map { |attempt| Array(attempt.fetch(:blocked_capabilities, [])) }
          .map(&:to_sym)
          .uniq
          .sort
      end

      compute :last_attempt, depends_on: [:ordered_attempts] do |ordered_attempts:|
        ordered_attempts.last&.dup
      end

      compute :summary, depends_on: %i[attempt_count blocked_count executed_count blocked_capabilities] do |attempt_count:, blocked_count:, executed_count:, blocked_capabilities:|
        "#{attempt_count} materializer attempts, #{blocked_count} blocked, #{executed_count} executed, capabilities=#{blocked_capabilities.join(",")}."
      end

      output :attempt_count
      output :blocked_count
      output :executed_count
      output :blocked_capabilities
      output :last_attempt
      output :summary
    end
  end
end
