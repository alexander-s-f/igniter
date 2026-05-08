#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

require_relative "../../lib/igniter_lang/assembler"

module TemporalRequirementsFromEscapeBoundariesProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/temporal_requirements_from_escape_boundaries"
  SUMMARY_PATH = OUT_DIR / "summary.json"

  CASES = [
    {
      "id" => "core_add",
      "path" => ROOT / "igniter-lang/experiments/source_to_semanticir_fixture/golden/add.semantic_ir.json",
      "expected_caps" => [],
      "expected_fragment" => "core",
      "expected_read_as_of" => false,
      "expected_replay" => false,
      "expected_window" => false
    },
    {
      "id" => "history_valid",
      "path" => ROOT / "igniter-lang/experiments/temporal_semanticir_access_node/golden/history_valid.semantic_ir.json",
      "expected_caps" => ["history_read"],
      "expected_fragment" => "temporal",
      "expected_read_as_of" => true,
      "expected_replay" => false,
      "expected_window" => false
    },
    {
      "id" => "bihistory_valid",
      "path" => ROOT / "igniter-lang/experiments/temporal_semanticir_access_node/golden/bihistory_valid.semantic_ir.json",
      "expected_caps" => ["bihistory_read"],
      "expected_fragment" => "temporal",
      "expected_read_as_of" => true,
      "expected_replay" => true,
      "expected_window" => false
    },
    {
      "id" => "stream_window",
      "path" => ROOT / "igniter-lang/experiments/stream_t_proof/golden/semantic_ir_program.json",
      "expected_caps" => ["stream_input"],
      "expected_fragment" => "escape",
      "expected_read_as_of" => false,
      "expected_replay" => false,
      "expected_window" => true
    }
  ].freeze

  module_function

  def run
    assembler = IgniterLang::Assembler.new
    cases = CASES.to_h do |config|
      semantic_ir = read_json(config.fetch("path"))
      requirements = assembler.send(:requirements_for, semantic_ir)
      [config.fetch("id"), case_summary(config, semantic_ir, requirements)]
    end
    checks = checks(cases)
    summary = {
      "kind" => "temporal_requirements_from_escape_boundaries_proof",
      "format_version" => "0.1.0",
      "track" => "temporal-requirements-from-escape-boundaries-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "cases" => cases,
      "checks" => checks,
      "compatibility" => compatibility_notes
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def case_summary(config, semantic_ir, requirements)
    {
      "semantic_ir_path" => config.fetch("path").relative_path_from(ROOT).to_s,
      "fragments" => requirements.fetch("fragments"),
      "escape_boundaries" => semantic_ir.fetch("contracts").flat_map { |contract| contract.fetch("escape_boundaries", []) },
      "expected_caps" => config.fetch("expected_caps"),
      "requirements" => requirements
    }
  end

  def checks(cases)
    case_checks = CASES.each_with_object({}) do |config, out|
      id = config.fetch("id")
      requirements = cases.fetch(id).fetch("requirements")
      caps = requirements.dig("capabilities", "required_caps")
      boundaries = cases.fetch(id).fetch("escape_boundaries")
      boundary_caps = boundaries.flat_map { |boundary| boundary.fetch("required_caps", []) }.uniq.sort
      out["#{id}.caps_from_escape_boundaries"] = caps == boundary_caps
      out["#{id}.expected_caps"] = caps == config.fetch("expected_caps")
      out["#{id}.expected_fragment"] = requirements.fetch("fragments") == [config.fetch("expected_fragment")]
      out["#{id}.read_as_of"] = requirements.dig("required_tbackend_caps", "read_as_of") == config.fetch("expected_read_as_of")
      out["#{id}.replay_enabled"] = requirements.dig("required_tbackend_caps", "replay_enabled") == config.fetch("expected_replay")
      out["#{id}.has_window"] = requirements.dig("lifecycle", "has_window") == config.fetch("expected_window")
    end

    core = cases.fetch("core_add").fetch("requirements")
    history = cases.fetch("history_valid").fetch("requirements")
    bihistory = cases.fetch("bihistory_valid").fetch("requirements")
    stream = cases.fetch("stream_window").fetch("requirements")
    case_checks.merge(
      "core_vs_history_requirements_differ" => core != history,
      "core_vs_bihistory_requirements_differ" => core != bihistory,
      "core_vs_stream_requirements_differ" => core != stream,
      "history_requires_valid_time_only" => history.dig("temporal", "requires_valid_time") &&
        !history.dig("temporal", "requires_transaction_time"),
      "bihistory_requires_valid_and_transaction_time" => bihistory.dig("temporal", "requires_valid_time") &&
        bihistory.dig("temporal", "requires_transaction_time"),
      "stream_does_not_require_temporal_tbackend" => !stream.dig("required_tbackend_caps", "read_as_of") &&
        !stream.dig("required_tbackend_caps", "replay_enabled")
    )
  end

  def compatibility_notes
    {
      "c1_temporal_semanticir_access_node" => "Consumes SemanticIR escape_boundaries emitted beside temporal_access_node without changing node shape.",
      "c2_runtime_temporal_cache_contract" => "Records temporal capabilities only; no cache key, memoization, Ledger call, or live runtime enforcement is added.",
      "compatibility_report_descriptor" => "Provides descriptor-readable required_caps while remaining report-only."
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_requirements_from_escape_boundaries"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = TemporalRequirementsFromEscapeBoundariesProof.run
exit(success ? 0 : 1)
