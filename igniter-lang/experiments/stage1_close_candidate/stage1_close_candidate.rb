#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "pathname"

module Stage1CloseCandidate
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/stage1_close_candidate"
  SUMMARY_PATH = OUT_DIR / "stage1_close_candidate.json"

  STAGES = [
    {
      "id" => "classifier",
      "label" => "Classifier proof",
      "command" => ["ruby", "igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb", "--check-golden"]
    },
    {
      "id" => "typechecker",
      "label" => "TypeChecker boundary proof",
      "command" => ["ruby", "igniter-lang/experiments/typechecker_proof/typechecker_proof.rb", "--check-golden"]
    },
    {
      "id" => "semanticir",
      "label" => "SemanticIR fixture proof",
      "command" => ["ruby", "igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb", "--check-golden"]
    },
    {
      "id" => "stdlib_kernel",
      "label" => "Stdlib execution kernel proof",
      "command" => ["ruby", "igniter-lang/experiments/stdlib_execution_kernel_stage1/stdlib_execution_kernel_stage1.rb"]
    },
    {
      "id" => "igapp_assembler",
      "label" => ".igapp assembler and direct runtime loader proof",
      "command" => ["ruby", "igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb"]
    }
  ].freeze

  module_function

  def run
    results = STAGES.map { |stage| run_stage(stage) }
    summary = build_summary(results)
    write_summary(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_stage(stage)
    stdout, stderr, status = Open3.capture3(*stage.fetch("command"), chdir: ROOT.to_s)
    output = stdout.lines.map(&:chomp)
    error_output = stderr.lines.map(&:chomp)
    checks = output.filter_map do |line|
      next unless (match = line.match(/\A(?<name>[^:]+): (?<status>ok|FAIL)\z/))

      {
        "name" => match[:name],
        "status" => match[:status] == "ok" ? "PASS" : "FAIL"
      }
    end

    stage.merge(
      "status" => status.success? ? "PASS" : "FAIL",
      "exit_status" => status.exitstatus,
      "checks" => checks,
      "stdout" => output,
      "stderr" => error_output
    )
  end

  def build_summary(results)
    {
      "kind" => "stage1_close_candidate",
      "format_version" => "0.1.0",
      "track" => "stage1-close-candidate-proof-v0",
      "status" => results.all? { |stage| stage.fetch("status") == "PASS" } ? "PASS" : "FAIL",
      "stage_order" => STAGES.map { |stage| stage.fetch("id") },
      "stages" => results,
      "remaining_known_gaps" => remaining_known_gaps,
      "closed_candidate_signals" => closed_candidate_signals
    }
  end

  def remaining_known_gaps
    [
      {
        "id" => "parser_oof_rejection_gap",
        "status" => "open",
        "summary" => "Parser OOF rejection is not fully hardened; OOF is currently caught by classifier/typechecker proofs."
      },
      {
        "id" => "production_compiler_assembly",
        "status" => "open",
        "summary" => "Assembler and RuntimeMachine loading are proof-local experiments, not a production compiler package."
      }
    ]
  end

  def closed_candidate_signals
    [
      {
        "id" => "direct_prop0191_runtime_loader",
        "status" => "closed_in_proof",
        "summary" => "igapp_assembler_proof reports runtime.load_direct_prop0191: ok and no legacy semantic_ir.json output."
      },
      {
        "id" => "typechecker_self_contained_boundary",
        "status" => "closed_in_proof",
        "summary" => "typechecker_proof reads its own ClassifiedProgram fixture directory by default."
      },
      {
        "id" => "stdlib_stage1_kernel",
        "status" => "closed_in_proof",
        "summary" => "Stage 1 stdlib kernel proof covers monomorphic add plus bounded collection/option operators."
      },
      {
        "id" => "runtime_eval_surface",
        "status" => "closed_in_proof",
        "summary" => "igapp_assembler_proof evaluates assembled Add, ClaimEvidenceBundle, and EvidenceLinkedAlertGate with trusted CompatibilityReports."
      }
    ]
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} stage1_close_candidate"
    summary.fetch("stages").each do |stage|
      puts "#{stage.fetch("id")}: #{stage.fetch("status")}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = Stage1CloseCandidate.run
exit(success ? 0 : 1)
