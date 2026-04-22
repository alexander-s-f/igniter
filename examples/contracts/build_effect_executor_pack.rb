#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/contracts"

# This file is intentionally self-contained. It shows the smallest useful shape
# of a custom operational pack:
# 1. declare effect/executor contracts in the manifest
# 2. register an effect adapter
# 3. register an executor
# 4. route executor work back through invocation.runtime
module AuditTrailPack
  class << self
    def manifest
      Igniter::Contracts::PackManifest.new(
        name: :example_audit_trail,
        registry_contracts: [
          Igniter::Contracts::PackManifest.effect(:audit_trail),
          Igniter::Contracts::PackManifest.executor(:audited_inline)
        ]
      )
    end

    def install_into(kernel)
      kernel.effects.register(:audit_trail, method(:apply_audit_trail))
      kernel.executors.register(:audited_inline, method(:execute_audited_inline))
      kernel
    end

    def journal
      @journal ||= {
        effects: [],
        executions: [],
        results: []
      }
    end

    def reset_journal!
      journal.each_value(&:clear)
    end

    def apply_audit_trail(invocation:)
      journal[:effects] << invocation.to_h
      invocation.payload
    end

    def execute_audited_inline(invocation:)
      journal[:executions] << invocation.to_h
      result = invocation.runtime.execute(
        invocation.compiled_graph,
        inputs: invocation.inputs,
        profile: invocation.profile
      )
      journal[:results] << result.to_h
      result
    end
  end
end

AuditTrailPack.reset_journal!
environment = Igniter::Contracts.with(AuditTrailPack)

compiled = environment.compile do
  input :amount
  output :amount
end

effect_result = environment.apply_effect(
  :audit_trail,
  payload: { amount: 10, event: "quoted" },
  context: { source: :example }
)

execution_result = environment.execute_with(
  :audited_inline,
  compiled,
  inputs: { amount: 15 }
)

puts "custom_effect_payload=#{effect_result.inspect}"
puts "custom_executor_output=#{execution_result.output(:amount)}"
puts "custom_effect_entries=#{AuditTrailPack.journal[:effects].length}"
puts "custom_execution_entries=#{AuditTrailPack.journal[:executions].length}"
puts "custom_result_entries=#{AuditTrailPack.journal[:results].length}"
