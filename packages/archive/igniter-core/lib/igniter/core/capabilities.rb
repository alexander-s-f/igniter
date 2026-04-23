# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/capabilities")
module Igniter
  # Capability-based security for Igniter executors.
  #
  # Executors declare what they are allowed to do via the `capabilities` DSL.
  # A Policy can deny or audit specific capabilities at execution time.
  #
  # == Usage
  #
  #   require "igniter/extensions/capabilities"
  #
  #   class PaymentExecutor < Igniter::Executor
  #     capabilities :network, :external_api
  #   end
  #
  #   class TaxCalculator < Igniter::Executor
  #     pure   # shorthand for capabilities :pure
  #   end
  #
  #   # Inspect a contract's required capabilities:
  #   MyContract.compiled_graph.required_capabilities
  #   # => { payment: [:network, :external_api], tax: [:pure] }
  #
  #   # Enforce a policy:
  #   Igniter::Capabilities.policy = Igniter::Capabilities::Policy.new(
  #     denied: %i[network external_api]
  #   )
  module Capabilities
    KNOWN = %i[pure network database filesystem external_api messaging queue cache].freeze

    class CapabilityViolationError < Igniter::Error
      def initialize(message, node_name: nil)
        super(message, context: { node_name: node_name }.compact)
      end
    end

    # Enforce capability rules at execution time.
    #
    # Options:
    #   denied:  Array of capabilities that must NOT be used.
    #   on_unknown: :warn | :ignore (default :ignore) — what to do with undeclared capabilities.
    class Policy
      attr_reader :denied, :on_unknown

      def initialize(denied: [], on_unknown: :ignore)
        @denied     = Array(denied).map(&:to_sym).freeze
        @on_unknown = on_unknown
      end

      # Raise CapabilityViolationError if the executor uses a denied capability.
      def check!(node_name, executor_class)
        caps       = executor_class.declared_capabilities
        violations = caps & denied
        return if violations.empty?

        raise CapabilityViolationError.new(
          "Node '#{node_name}' executor #{executor_class.name} " \
          "uses denied capabilities: #{violations.join(", ")}",
          node_name: node_name
        )
      end
    end

    class << self
      # Global capability policy. nil = no enforcement (default).
      attr_accessor :policy
    end
  end
end
