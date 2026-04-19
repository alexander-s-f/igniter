# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/provenance"

class ReviewQueueAdapter
  def call(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
    {
      status: :pending,
      payload: {
        queue: :review,
        requested_name: inputs.fetch(:name)
      },
      agent_trace: {
        adapter: :queue,
        mode: :call,
        via: node.agent_name,
        message: node.message_name,
        outcome: :deferred,
        reason: :awaiting_review
      }
    }
  end

  def cast(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
    {
      status: :succeeded,
      output: nil,
      agent_trace: {
        adapter: :queue,
        mode: :cast,
        via: node.agent_name,
        message: node.message_name,
        outcome: :sent
      }
    }
  end
end

class AgentOrchestrationContract < Igniter::Contract
  runner :inline, agent_adapter: ReviewQueueAdapter.new

  define do
    input :name, type: :string

    agent :approval,
          via: :reviewer,
          message: :review,
          inputs: { name: :name }

    agent :notify,
          via: :reviewer,
          message: :remember,
          mode: :cast,
          inputs: { name: :name }

    output :approval
    output :notify
  end
end

contract = AgentOrchestrationContract.new(name: "Alice")
approval = contract.result.approval
plan = contract.orchestration_plan
report = contract.diagnostics.to_h
trace = contract.lineage(:approval).trace.value

puts "contract_status=#{report[:status]}"
puts "approval_pending=#{trace[:pending]}"
puts "approval_token=#{approval.token}"
puts "notify=#{contract.result.notify.inspect}"
puts "attention_nodes=#{plan[:attention_nodes].inspect}"
puts "actions=#{plan[:by_action].inspect}"
puts "agents=#{report[:agents].slice(:total, :pending, :succeeded, :failed).inspect}"
puts "lineage_reason=#{trace.dig(:agent_trace, :reason)}"
