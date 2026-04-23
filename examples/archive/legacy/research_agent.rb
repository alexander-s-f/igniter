# frozen_string_literal: true

# Example: LLM-powered research agent using Igniter + Ollama
#
# Prerequisites:
#   1. Install Ollama: https://ollama.com
#   2. Pull a model: ollama pull llama3.2
#   3. Run: ruby examples/llm/research_agent.rb
#
# This example shows:
#   - LLM executor as a compute node
#   - Sequential reasoning (plan → search → synthesize)
#   - Awaiting external tool results (web search)
#   - Multi-contract composition

$LOAD_PATH.unshift File.join(__dir__, "../../lib")
require "igniter"
require "igniter/ai"
require "json"
require "net/http"
require "uri"

OLLAMA_URL = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
PREFERRED_OLLAMA_MODEL = ENV.fetch("OLLAMA_MODEL", "llama3.2")

def detect_ollama_model(base_url:, preferred:)
  uri = URI.join("#{base_url.chomp("/")}/", "api/tags")
  response = Net::HTTP.get_response(uri)
  return preferred unless response.is_a?(Net::HTTPSuccess)

  payload = JSON.parse(response.body)
  models = Array(payload["models"]).filter_map do |entry|
    name = entry["name"].to_s.strip
    name = entry["model"].to_s.strip if name.empty?
    name unless name.empty?
  end
  return preferred if models.empty?
  return preferred if models.include?(preferred)

  models.first
rescue StandardError
  preferred
end

OLLAMA_MODEL = detect_ollama_model(base_url: OLLAMA_URL, preferred: PREFERRED_OLLAMA_MODEL)

# Configure LLM
Igniter::AI.configure do |config|
  config.default_provider = :ollama
  config.ollama.default_model = OLLAMA_MODEL
  config.ollama.base_url = OLLAMA_URL
end

# ─── Executors ───────────────────────────────────────────────────────────────

class QuestionAnalyzer < Igniter::AI::Executor
  model OLLAMA_MODEL
  system_prompt <<~SYSTEM
    You are a research planner. Given a question, extract:
    1. The core topic
    2. 2-3 specific search queries needed to answer it
    Return JSON only: { "topic": "...", "queries": ["q1", "q2"] }
  SYSTEM

  def call(question:)
    raw = complete("Question: #{question}")
    # Parse JSON from LLM output
    start = raw.index("{")
    finish = raw.rindex("}")
    return({ "topic" => question, "queries" => [question] }) unless start && finish

    JSON.parse(raw[start..finish])
  rescue JSON::ParserError
    { "topic" => question, "queries" => [question] }
  end
end

class AnswerSynthesizer < Igniter::AI::Executor
  model OLLAMA_MODEL
  system_prompt "You are a research assistant. Synthesize information into clear, accurate answers."

  def call(question:, search_results:)
    context_text = Array(search_results).map.with_index(1) do |r, i|
      "Source #{i}: #{r}"
    end.join("\n\n")

    complete(<<~PROMPT)
      Question: #{question}

      Research findings:
      #{context_text}

      Provide a comprehensive, well-structured answer based on the research.
    PROMPT
  end
end

# ─── Simple single-turn contract (no external tools) ─────────────────────────

class DirectAnswerContract < Igniter::Contract
  define do
    input :question

    compute :analysis, depends_on: :question, call: QuestionAnalyzer

    compute :answer, depends_on: %i[question analysis] do |question:, analysis:|
      # In a real scenario, QuestionAnalyzer gives us queries.
      # Here we simulate with a fixed result.
      synthesizer = AnswerSynthesizer.new
      synthesizer.call(
        question: question,
        search_results: ["#{analysis["topic"]} is an important topic with many facets."]
      )
    end

    output :answer
  end
end

# ─── Multi-step contract with await (tool use via external search) ────────────

class ResearchWithToolsContract < Igniter::Contract
  correlate_by :session_id

  define do
    input :session_id
    input :question

    compute :plan, depends_on: :question, call: QuestionAnalyzer

    # External search tool — application calls deliver_event when results arrive
    await :search_results, event: :search_completed

    compute :final_answer, depends_on: %i[question search_results], call: AnswerSynthesizer

    output :final_answer
  end
end

# ─── Run examples ─────────────────────────────────────────────────────────────

puts "=" * 60
puts "Igniter LLM Integration — Research Agent Example"
puts "=" * 60

# Check if Ollama is running
begin
  provider = Igniter::AI.provider_instance(:ollama)
  models = provider.models
  puts "\nOllama models available: #{models.first(3).join(", ")}"
  puts "Using Ollama model: #{OLLAMA_MODEL}"
rescue => e
  puts "\nOllama not available (#{e.class}: #{e.message.slice(0, 60)})"
  puts "Running with mock answers instead...\n"

  # Mock the provider for demo without Ollama
  module Igniter::AI::Providers
    class Ollama
      def chat(messages:, model:, **_opts)
        prompt = messages.map { |m| m["content"] || m[:content] }.last.to_s
        record_usage(prompt_tokens: 50, completion_tokens: 100)
        if prompt.include?("JSON only")
          { role: :assistant, content: '{"topic":"Ruby programming","queries":["Ruby language features","Ruby gems ecosystem"]}', tool_calls: [] }
        else
          { role: :assistant, content: "Ruby is a dynamic, object-oriented programming language known for its elegant syntax and the Rails web framework.", tool_calls: [] }
        end
      end

      def models
        ["llama3.2 (mock)"]
      end
    end
  end
  puts "Using mock Ollama provider."
end

# Example 1: Direct question answering
puts "\n── Example 1: Direct Answer ──"
contract = DirectAnswerContract.new(question: "What makes Ruby a good language for web development?")
contract.resolve_all

if contract.success?
  puts "Answer:\n#{contract.result.answer}"
else
  puts "Failed: #{contract.result.errors}"
end

# Example 2: Multi-step with external tool (await pattern)
puts "\n── Example 2: Multi-step with Tool Await ──"
store = Igniter::Runtime::Stores::MemoryStore.new

execution = ResearchWithToolsContract.start(
  { session_id: "sess-001", question: "How does Igniter handle distributed workflows?" },
  store: store
)
puts "Started. Pending: #{execution.pending?}"

# Simulate external search completing
ResearchWithToolsContract.deliver_event(
  :search_completed,
  correlation: { session_id: "sess-001" },
  payload: [
    "Igniter uses a graph-based execution model with await nodes for external events.",
    "Distributed workflows in Igniter use correlation keys for execution lookup.",
    "The store-backed runner persists execution state for resume across processes."
  ],
  store: store
)

# Reload final result
execution_id = store.find_by_correlation(
  graph: "ResearchWithToolsContract",
  correlation: { session_id: "sess-001" }
)
final = ResearchWithToolsContract.restore_from_store(execution_id, store: store)
puts "\nFinal answer:\n#{final.result.final_answer}" if final.success?

puts "\n✓ Done!"
