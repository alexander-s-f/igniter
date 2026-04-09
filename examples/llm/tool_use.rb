# frozen_string_literal: true

# LLM Multi-Step Pipeline with Tool Declarations
#
# Shows:
#   - Chained LLM compute nodes (classify → assess priority → draft response)
#   - Tool declaration with the class-level `tools` method
#   - Conversation context with Igniter::LLM::Context
#   - Mock provider so the example runs offline without an API key
#
# To use real Anthropic Claude, set ANTHROPIC_API_KEY and remove the mock block.
#
# Run: ruby examples/llm/tool_use.rb

$LOAD_PATH.unshift File.join(__dir__, "../../lib")
require "igniter"
require "igniter/integrations/llm"

Igniter::LLM.configure do |c|
  c.default_provider = :anthropic
  c.anthropic.api_key = ENV.fetch("ANTHROPIC_API_KEY", "demo")
end

# ── Mock provider (remove to use real Anthropic) ──────────────────────────────

module Igniter
  module LLM
    module Providers
      class Anthropic
        def chat(messages:, **_opts) # rubocop:disable Metrics/MethodLength
          record_usage(prompt_tokens: 80, completion_tokens: 40)
          content_parts = messages.filter_map { |m| m["content"] || m[:content] }
          last = content_parts.last.to_s

          content = case last
                    when /classify/i
                      "category: bug_report"
                    when /draft a response/i
                      "We have logged this issue and will address it in the next release."
                    when /category:/i
                      "priority: high"
                    else
                      "We have logged this issue and will address it in the next release."
                    end
          { role: :assistant, content: content, tool_calls: [] }
        end
      end
    end
  end
end

# ── Tool definition (used by ClassifyExecutor) ────────────────────────────────

CLASSIFY_TOOL = {
  name: "set_category",
  description: "Record the detected feedback category",
  input_schema: {
    type: "object",
    properties: {
      category: { type: "string", enum: %w[bug_report feature_request question] },
      confidence: { type: "number", description: "0.0–1.0 confidence score" }
    },
    required: %w[category]
  }
}.freeze

# ── Executors ─────────────────────────────────────────────────────────────────

class ClassifyExecutor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Classify the feedback. Reply with 'category: <type>' " \
                "where type is one of: bug_report, feature_request, question."

  # Declare tools — used when calling complete_with_tools
  tools CLASSIFY_TOOL

  def call(feedback:)
    # complete() for standard response; complete_with_tools() to invoke structured tool calls
    complete("Classify: #{feedback}")
  end
end

class PriorityAssessor < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "Assess ticket priority (low/medium/high). Reply with 'priority: <level>'."

  def call(feedback:, category:)
    # Use Context to build a multi-turn conversation
    ctx = Igniter::LLM::Context
          .empty(system: self.class.system_prompt)
          .append_user("Feedback: #{feedback}")
          .append_user("Category: #{category}")
    chat(context: ctx)
  end
end

class ResponseDrafter < Igniter::LLM::Executor
  provider :anthropic
  model    "claude-haiku-4-5-20251001"
  system_prompt "You are a customer success agent. Write one professional support response."

  def call(feedback:, category:, priority:)
    complete("Feedback: #{feedback}\nCategory: #{category}\nPriority: #{priority}\nDraft a response:")
  end
end

# ── Contract ──────────────────────────────────────────────────────────────────

class FeedbackTriageContract < Igniter::Contract
  define do
    input :feedback

    compute :category, depends_on: :feedback,                       call: ClassifyExecutor
    compute :priority, depends_on: %i[feedback category],           call: PriorityAssessor
    compute :response, depends_on: %i[feedback category priority],  call: ResponseDrafter

    output :category
    output :priority
    output :response
  end
end

# ── Run ───────────────────────────────────────────────────────────────────────

puts "=== Feedback Triage Pipeline ==="

contract = FeedbackTriageContract.new(
  feedback: "The export button crashes when I select more than 100 rows"
)
contract.resolve_all

puts "category=#{contract.result.category}"
puts "priority=#{contract.result.priority}"
puts "response=#{contract.result.response}"

puts "\n--- Diagnostics ---"
puts contract.diagnostics_text
