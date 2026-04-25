#!/usr/bin/env ruby
# frozen_string_literal: true

# Semantic Gateway Demo — Human↔Agent interaction pre-processing
#
# Usage:
#   ruby examples/semantic_gateway/demo.rb            # run all test cases
#   ruby examples/semantic_gateway/demo.rb live       # interactive mode
#   ruby examples/semantic_gateway/demo.rb compare    # side-by-side comparison

$LOAD_PATH.unshift File.join(__dir__, "lib")

require "gateway"

include SemanticGateway

DIVIDER = ("─" * 70).freeze

# =============================================================================
# Test cases — real human requests, varied style and clarity
# =============================================================================

TEST_CASES = [
  {
    label: "A — Clear request, single domain",
    text: "I want to add a login page to my app but keep it simple, " \
          "nothing fancy, just email and password, no OAuth or third party stuff"
  },
  {
    label: "B — Vague but urgent",
    text: "the orders query is super slow, it's blocking our release, " \
          "can you fix it asap?"
  },
  {
    label: "C — Multi-domain, technical",
    text: "Review the authentication middleware and make sure it follows " \
          "existing patterns, no breaking changes please, we go live Thursday"
  },
  {
    label: "D — Ambiguous / minimal",
    text: "can you check the api?"
  },
  {
    label: "E — Documentation request",
    text: "write docs for the new webhook endpoint, follow the same style " \
          "as the other endpoints in the api docs"
  },
  {
    label: "F — AI-layer, complex",
    text: "I need to set up an agent that monitors incoming signals and " \
          "routes them to the right handler, keep it lightweight, no heavy deps"
  },
].freeze

# =============================================================================
# Rendering
# =============================================================================

def print_header
  puts "\n#{"═" * 70}"
  puts "  SEMANTIC GATEWAY — Human↔Agent Pre-processor"
  puts "  Local SAE-inspired intent extraction before expensive LLM calls"
  puts "#{"═" * 70}"
  puts "  ollama status: #{LocalLLMExtractor.available? ? "✓ available (Stage 2 active)" : "✗ not running (Stage 1 only)"}"
  puts "#{"═" * 70}\n"
end

def run_case(tc)
  puts "\n╔══ #{tc[:label]} #{"═" * [0, 62 - tc[:label].length].max}╗"
  puts "│"
  puts "│  INPUT: #{tc[:text][0..80]}#{tc[:text].length > 80 ? "..." : ""}"
  puts "│  (#{(tc[:text].length / 4.0).ceil} tokens)\n│"

  result = Gateway.process(tc[:text])
  puts result.to_report
end

def run_comparison
  puts "\n#{"═" * 70}"
  puts "  COMPRESSION COMPARISON"
  puts "#{"═" * 70}"
  printf "  %-30s %8s %8s %8s %6s\n", "Case", "Original", "Packet", "Ratio", "Conf."
  puts "  " + "─" * 66

  TEST_CASES.each do |tc|
    result = Gateway.process(tc[:text])
    p = result.packet
    label = tc[:label][0..28]
    printf "  %-30s %8s %8s %8s %6s\n",
           label,
           "#{p.source_tokens}t",
           "#{p.token_count}t",
           "#{p.compression_ratio}x",
           "#{(p.confidence * 100).round}%"
  end

  results      = TEST_CASES.map { |tc| Gateway.process(tc[:text]) }
  avg_orig     = results.sum { |r| r.packet.source_tokens }.to_f / results.length
  avg_packed   = results.sum { |r| r.packet.token_count }.to_f / results.length

  # The real economic model:
  # Without gateway: user text + ~80tok clarification overhead per misunderstood request
  # With gateway: compact packet + 50tok shared vocabulary (once per session) + no clarification
  misunderstanding_rate = 0.35  # 35% of raw requests need clarification
  clarification_cost    = 80    # avg tokens for back-and-forth
  vocab_cost_once       = 50    # shared intent vocabulary, loaded once

  n = 100
  raw_total    = (avg_orig * n) + (avg_orig * n * misunderstanding_rate * clarification_cost / avg_orig)
  packed_total = vocab_cost_once + (avg_packed * n)
  saving       = raw_total - packed_total

  puts "\n  Session economics (#{n} messages, 35% clarification rate without gateway):"
  puts "  Without gateway: #{avg_orig.round(1)}t/msg × #{n} + clarifications = #{raw_total.round(0).to_i}t"
  puts "  With gateway:    #{avg_packed.round(1)}t/msg × #{n} + 50t vocab   = #{packed_total.round(0).to_i}t"
  puts "  Net saving:      #{saving.round(0).to_i} tokens/session"
  puts "  At $15/1M (Sonnet input): $#{(saving * 15.0 / 1_000_000).round(4)}/session"
  puts "\n  Note: compact packet token count is packet overhead only."
  puts "  Real gain = routing precision + eliminated clarification + no disambiguation preamble."
end

def run_interactive
  puts "\n  Semantic Gateway — Interactive Mode"
  puts "  Type your request. The gateway extracts intent before it hits the API."
  puts "  Press Ctrl+C to exit.\n\n"

  loop do
    print "  You: "
    text = $stdin.gets&.chomp
    break if text.nil? || text.strip.empty?

    result = Gateway.process(text)
    puts "\n" + result.to_report
    puts "\n  Compact form for agent:\n  #{result.packet.to_compact}\n\n"
    puts "  " + "─" * 66
  end
end

# =============================================================================
# Main
# =============================================================================

print_header

case ARGV[0]
when "compare"
  TEST_CASES.each { |tc| run_case(tc) }
  run_comparison
when "live", "interactive"
  run_interactive
else
  TEST_CASES.each { |tc| run_case(tc) }
  run_comparison
end
