#!/usr/bin/env ruby
# frozen_string_literal: true

# Line-Up Approximation — live demo
#
# Packs real Igniter handoff messages into compact Line-Up form.
# Shows compression ratio, semantic preservation score, and net token value.
#
# Usage:
#   ruby examples/lineup/demo.rb            # run all cases
#   ruby examples/lineup/demo.rb compact    # compact format only
#   ruby examples/lineup/demo.rb prose      # prose format only
#   ruby examples/lineup/demo.rb session    # session economics only
#   ruby examples/lineup/demo.rb pack FILE  # pack a file from stdin/path

$LOAD_PATH.unshift File.join(__dir__, "lib")

require "line_up"
require "vocabulary"
require "packer"
require "scorer"

# =============================================================================
# Test corpus — real Igniter handoffs
# =============================================================================

CASES = [
  {
    label: "Case A — Compact micro-format (Agent Application, landed)",
    format: :compact,
    text: <<~TEXT
      [Agent Application / Codex]
      track: docs/dev/application-web-poc-feedback-track.md
      status: landed
      delta:
        + examples/application/interactive_operator/app.rb: query-string feedback, blank-title refusal
        + examples/application/interactive_operator/README.md: feedback params documented
      verify: code-narrow(smoke 74/0, rubocop 0 offenses, diff-check ok)
      ready: [Agent Web / Codex] can render feedback; [Architect Supervisor / Codex] can review boundary
      block: none
    TEXT
  },
  {
    label: "Case B — Prose format (Supervisor scope assignment)",
    format: :prose,
    text: <<~TEXT
      [Architect Supervisor / Codex] Accepted as a docs-only next research track.

      The Interaction Kernel synthesis identifies a useful conceptual vocabulary for
      read-only interaction state: subject, participants, affordances, pending state,
      surface context, session context, policy context, evidence, and outcomes.

      This track is explicitly documentation-only. No shared interaction package,
      runtime object, browser transport, workflow engine, agent execution, cluster
      placement, or AI provider integration is accepted.

      Track: docs/dev/interaction-doctrine-track.md
      Status: open
      Needs:
      - [Research Horizon / Codex] drafts docs-only Interaction Doctrine
    TEXT
  },
  {
    label: "Case C — Prose format (Research Horizon completion handoff)",
    format: :prose,
    text: <<~TEXT
      [Research Horizon / Codex]
      Track: docs/dev/interaction-doctrine-track.md
      Status: landed.
      Changed:
      - Added docs/dev/interaction-doctrine.md.
      - Linked it from docs/dev/README.md.
      - Added a short docs/dev/README.md reference without changing package
        implementation handoffs.
      Accepted:
      - The doctrine defines subject, participant, affordance, pending state,
        surface context, session context, policy context, evidence, and outcome.
      - It maps application flow sessions, web surface metadata, operator/
        orchestration surfaces, and capsule/activation review artifacts without
        merging ownership.
      - It explains the distinction from Handoff Doctrine.
      Verification:
      - git diff --check passed.
      Needs:
      - [Architect Supervisor / Codex] review for docs-only doctrine acceptance.
    TEXT
  },
  {
    label: "Case D — Compact format (blocked track)",
    format: :compact,
    text: <<~TEXT
      [Agent Cluster / Codex]
      track: docs/dev/cluster-target-plan.md
      status: blocked
      delta: none
      verify: n/a
      ready: none
      block: waiting for capsule host activation to stabilize — dependency: application-capsule-host-activation-commit-readiness-track
    TEXT
  }
].freeze

# =============================================================================
# Rendering helpers
# =============================================================================

DIVIDER = ("─" * 70).freeze

def separator(label = nil)
  if label
    pad = [0, 68 - label.length].max
    puts "\n╔══ #{label} #{("═" * pad)}╗"
  else
    puts "\n#{DIVIDER}"
  end
end

def run_case(kase)
  separator(kase[:label])

  original = kase[:text]
  lineup   = LineUp::Packer.call(original, format: kase[:format])
  score    = LineUp::Scorer.score(lineup, original)

  puts "\n── Original (#{score.original_tokens} tokens) ──"
  puts original.strip

  puts "\n── Line-Up (#{score.lineup_tokens} tokens) ──"
  puts lineup.to_lineup

  puts "\n"
  puts score.to_report

  { lineup: lineup, score: score }
end

def run_session_economics(results)
  separator("Session Economics")

  avg_orig   = results.sum { |r| r[:score].original_tokens } / results.length.to_f
  avg_lineup = results.sum { |r| r[:score].lineup_tokens   } / results.length.to_f

  [10, 25, 50, 100].each do |n|
    econ = LineUp::Scorer.session_economics(
      avg_original_tokens: avg_orig.round,
      avg_lineup_tokens:   avg_lineup.round,
      grammar_cost:        200,
      n_messages:          n
    )

    status = econ[:saving] > 0 ? "✓" : "✗"
    puts format(
      "  %s  %3d messages | prose: %5d tok | lineup: %5d tok | saving: %+5d tok (%s%%) | break-even: %d",
      status,
      econ[:n_messages],
      econ[:prose_total],
      econ[:compressed_total],
      econ[:saving],
      econ[:saving_pct],
      econ[:break_even]
    )
  end
end

def run_aggregate(results)
  separator("Aggregate Results")

  scores = results.map { |r| r[:score] }
  avg_ratio   = scores.sum(&:compression_ratio) / scores.length.to_f
  avg_semantic = scores.sum(&:semantic_score).to_f / scores.length
  total_saved = scores.sum(&:net_value)

  puts "  Cases:             #{scores.length}"
  puts format("  Avg ratio:         %.2fx", avg_ratio)
  puts format("  Avg semantic:      %.1f/#{LineUp::Scorer::REQUIRED_FIELDS.length}", avg_semantic)
  puts "  Total net saving:  #{total_saved > 0 ? "+#{total_saved}" : total_saved} tokens across all cases"
  puts "  Verdict:           #{scores.all? { |s| s.net_value > 0 } ? "✓ compression worthwhile across all cases" : "~ mixed results"}"
end

def run_interactive
  separator("Interactive Mode")
  puts "Paste a handoff message (compact or prose format)."
  puts "End input with Ctrl+D (or type END on a new line).\n\n"

  lines = []
  while (line = $stdin.gets)
    break if line.chomp == "END"

    lines << line
  end

  text = lines.join
  return puts "No input received." if text.strip.empty?

  lineup = LineUp::Packer.call(text)
  score  = LineUp::Scorer.score(lineup, text)

  puts "\n── Line-Up ──"
  puts lineup.to_lineup
  puts "\n"
  puts score.to_report
end

def pack_file(path)
  text = path == "-" ? $stdin.read : File.read(path)
  lineup = LineUp::Packer.call(text)
  score  = LineUp::Scorer.score(lineup, text)

  puts lineup.to_lineup
  puts "\n"
  puts score.to_report
rescue Errno::ENOENT
  puts "File not found: #{path}"
  exit 1
end

# =============================================================================
# Entry point
# =============================================================================

mode = ARGV[0]

case mode
when "compact"
  results = CASES.select { |c| c[:format] == :compact }.map { |c| run_case(c) }
  run_aggregate(results)
when "prose"
  results = CASES.select { |c| c[:format] == :prose }.map { |c| run_case(c) }
  run_aggregate(results)
when "session"
  results = CASES.map { |c| { score: LineUp::Scorer.score(LineUp::Packer.call(c[:text], format: c[:format]), c[:text]) } }
  run_session_economics(results)
when "interactive"
  run_interactive
when "pack"
  path = ARGV[1] || "-"
  pack_file(path)
else
  # Run all cases
  results = CASES.map { |c| run_case(c) }
  puts
  run_aggregate(results)
  run_session_economics(results)
end

puts "\n"
