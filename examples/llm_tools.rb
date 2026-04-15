# frozen_string_literal: true

# examples/llm_tools.rb
#
# Demonstrates Igniter::Tool — AI-callable tools with:
#   - Declarative metadata (description, param schema, required capabilities)
#   - JSON schema generation for Anthropic / OpenAI APIs
#   - Capability-based access guards (enforced before tool.call)
#   - Automatic tool-use loop inside AI::Executor#complete
#   - AI::ToolRegistry for global discovery and schema export
#   - Tool reuse as regular Igniter::Contract compute nodes
#
# Requires: ANTHROPIC_API_KEY (skips live calls if absent)
#
# Run: bundle exec ruby examples/llm_tools.rb

require "igniter"
require "igniter/core/tool"
require "igniter/sdk/ai"

puts "=" * 62
puts "  Igniter::Tool Demo"
puts "=" * 62

# ─────────────────────────────────────────────────────────────────────────────
# [1] Define tools
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[1] Defining tools"

class Calculator < Igniter::Tool
  description "Evaluate a mathematical expression and return the result"
  param :expression, type: :string, required: true, desc: "A Ruby-evaluable math expression"

  def call(expression:)
    result = eval(expression) # rubocop:disable Security/Eval
    { expression: expression, result: result }
  end
end

class TimeNow < Igniter::Tool
  description "Return the current UTC time"
  # no params, no required capabilities

  def call
    { utc: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") }
  end
end

class DatabaseLookup < Igniter::Tool
  description "Look up a record in the (simulated) product database by SKU"
  param :sku, type: :string, required: true, desc: "Product SKU identifier"

  requires_capability :database_read   # agent must declare this capability

  PRODUCTS = {
    "SKU-001" => { name: "Widget Pro", price: 29.99, stock: 150 },
    "SKU-002" => { name: "Gadget Plus", price: 49.99, stock: 42 },
    "SKU-003" => { name: "Doohickey Max", price: 99.00, stock: 7 },
  }.freeze

  def call(sku:)
    product = PRODUCTS[sku.upcase]
    product ? product.merge(sku: sku.upcase) : { error: "SKU #{sku} not found" }
  end
end

puts "  Defined: Calculator, TimeNow, DatabaseLookup"

# ─────────────────────────────────────────────────────────────────────────────
# [2] Schema generation
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[2] Schema generation"

puts "  Calculator.tool_name:     #{Calculator.tool_name}"
puts "  DatabaseLookup.tool_name: #{DatabaseLookup.tool_name}"
puts "  DatabaseLookup.required_capabilities: #{DatabaseLookup.required_capabilities.inspect}"

schema = Calculator.to_schema
puts "\n  Intermediate schema (normalized by provider):"
puts "    name:       #{schema[:name]}"
puts "    parameters: #{schema[:parameters].inspect}"

puts "\n  Anthropic schema:"
require "json"
puts JSON.pretty_generate(Calculator.to_schema(:anthropic)).split("\n").map { |l| "    #{l}" }.join("\n")

# ─────────────────────────────────────────────────────────────────────────────
# [3] AI::ToolRegistry
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[3] AI::ToolRegistry"

Igniter::AI::ToolRegistry.register(Calculator, TimeNow, DatabaseLookup)
puts "  Registered #{Igniter::AI::ToolRegistry.size} tools: #{Igniter::AI::ToolRegistry.all.map(&:tool_name).join(", ")}"

# Capability filtering
public_tools = Igniter::AI::ToolRegistry.tools_for(capabilities: [])
puts "  Tools with no caps required: #{public_tools.map(&:tool_name).join(", ")}"

db_tools = Igniter::AI::ToolRegistry.tools_for(capabilities: %i[database_read])
puts "  Tools available with :database_read: #{db_tools.map(&:tool_name).join(", ")}"

# ─────────────────────────────────────────────────────────────────────────────
# [4] Capability guard
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[4] Capability guard"

puts "  Calling Calculator (no caps required)..."
result = Calculator.new.call_with_capability_check!(allowed_capabilities: [], expression: "6 * 7")
puts "    6 * 7 = #{result[:result]}"

puts "  Calling DatabaseLookup without :database_read capability..."
begin
  DatabaseLookup.new.call_with_capability_check!(allowed_capabilities: [], sku: "SKU-001")
  puts "    BUG: should have raised"
rescue Igniter::Tool::CapabilityError => e
  puts "    CapabilityError: #{e.message}"
end

puts "  Calling DatabaseLookup WITH :database_read capability..."
product = DatabaseLookup.new.call_with_capability_check!(
  allowed_capabilities: [:database_read], sku: "SKU-001"
)
puts "    Found: #{product[:name]} — $#{product[:price]}"

# ─────────────────────────────────────────────────────────────────────────────
# [5] Tool as a regular Igniter::Contract compute node
#     Tool IS an Executor — full Contract compatibility
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[5] Tool as Contract compute node"

class PriceChecker < Igniter::Contract
  define do
    input :sku

    compute :product, with: :sku, call: DatabaseLookup
    compute :discount, with: :product, call: Class.new(Igniter::Executor) {
      def call(product:)
        return { rate: 0.2, reason: "low stock" } if product[:stock] < 10
        { rate: 0.05, reason: "standard" }
      end
    }

    output :product
    output :discount
  end
end

checker = PriceChecker.new(sku: "SKU-003")
checker.resolve_all
puts "  SKU-003: #{checker.result.product[:name]}"
puts "  Stock:   #{checker.result.product[:stock]}  →  discount: #{(checker.result.discount[:rate] * 100).to_i}% (#{checker.result.discount[:reason]})"

# ─────────────────────────────────────────────────────────────────────────────
# [6] AI::Executor with automatic tool-use loop
#     (live call requires ANTHROPIC_API_KEY)
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[6] AI::Executor with automatic tool-use loop"

if ENV["ANTHROPIC_API_KEY"].to_s.empty?
  puts "  ANTHROPIC_API_KEY not set — skipping live call"
  puts "  (showing executor definition only)"

  class ProductAgent < Igniter::AI::Executor
    provider :anthropic
    model "claude-haiku-4-5-20251001"
    system_prompt "You are a helpful product assistant. Use tools to answer questions."

    tools Calculator, TimeNow, DatabaseLookup

    # This agent may use the database — declare the capability
    capabilities :database_read

    max_tool_iterations 5

    def call(question:)
      complete(question)
      # complete() detects Tool classes in tools DSL and auto-loops:
      #   1. Sends tool schemas to Anthropic API
      #   2. LLM responds with tool_use blocks
      #   3. Capability guard checks agent.declared_capabilities
      #   4. Tool#call executes, result appended to conversation
      #   5. Loop until LLM returns plain text
    end
  end

  puts "  ProductAgent defined with:"
  puts "    tools:        #{ProductAgent.tools.map(&:tool_name).join(", ")}"
  puts "    capabilities: #{ProductAgent.declared_capabilities.inspect}"
  puts "    max_iters:    #{ProductAgent.max_tool_iterations}"
else
  class ProductAgent < Igniter::AI::Executor
    provider :anthropic
    model "claude-haiku-4-5-20251001"
    system_prompt "You are a helpful product assistant. Use tools to answer questions."

    tools Calculator, TimeNow, DatabaseLookup
    capabilities :database_read
    max_tool_iterations 5

    def call(question:)
      complete(question)
    end
  end

  puts "  Asking: 'What is the price of SKU-001 and what is 15% of that price?'"
  begin
    answer = ProductAgent.new.call(question: "What is the price of SKU-001 and what is 15% of that price?")
    puts "  Agent: #{answer}"
  rescue Igniter::AI::Error => e
    puts "  LLM error: #{e.message}"
  end
end

# ─────────────────────────────────────────────────────────────────────────────
# [7] Agent without database_read — CapabilityError before tool executes
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[7] Agent with restricted capabilities"

class RestrictedAgent < Igniter::AI::Executor
  provider :anthropic
  model "claude-haiku-4-5-20251001"
  system_prompt "You are a limited assistant."

  tools Calculator, TimeNow, DatabaseLookup
  # no capabilities declared — cannot call DatabaseLookup
  max_tool_iterations 3

  def call(question:)
    complete(question)
  end
end

puts "  RestrictedAgent.declared_capabilities: #{RestrictedAgent.declared_capabilities.inspect}"
puts "  Tools it may safely call: #{Igniter::AI::ToolRegistry.tools_for(capabilities: RestrictedAgent.declared_capabilities).map(&:tool_name).join(", ")}"

puts "\nDone."
