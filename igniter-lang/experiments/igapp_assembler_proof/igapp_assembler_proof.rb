#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../runtime_machine_memory_proof/compiled_program"

module IgappAssemblerProof
  ROOT = Pathname.new(File.expand_path("../..", __dir__))
  GOLDEN_DIR = ROOT / "experiments/source_to_semanticir_fixture/golden"
  OUT_DIR = ROOT / "experiments/igapp_assembler_proof/out"
  PROOF_AS_OF = RuntimeMachineMemoryProof::PROOF_AS_OF
  POSITIVE_CASES = %w[add claim_evidence evidence_linked_alert].freeze
  NEGATIVE_CASES = %w[negative_unresolved_symbol negative_evidence_less_alert negative_confidence_bool].freeze

  class AssemblyRefused < StandardError; end

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) do |key, out|
          out[key.to_s] = normalize(value[key])
        end
      when Array
        value.map { |item| normalize(item) }
      when Symbol
        value.to_s
      else
        value
      end
    end

    def json(value)
      JSON.pretty_generate(normalize(value)) + "\n"
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(JSON.generate(normalize(value)))}"
    end

    def short_hash(value)
      hash(value).split(":").last[0, 16]
    end
  end

  class Assembler
    def initialize(golden_dir: GOLDEN_DIR, out_dir: OUT_DIR)
      @golden_dir = Pathname.new(golden_dir)
      @out_dir = Pathname.new(out_dir)
    end

    def assemble_case(case_name)
      report = read_json(@golden_dir / "#{case_name}.compilation_report.json")
      refuse!(case_name, "pass_result=#{report.fetch("pass_result")}") unless report.fetch("pass_result") == "ok"
      refuse!(case_name, "semantic_ir_ref missing") unless report.fetch("semantic_ir_ref").is_a?(String)

      semantic_ir = read_json(@golden_dir / "#{case_name}.semantic_ir.json")
      validate_refs!(case_name, report, semantic_ir)
      validate_semantic_ir!(case_name, semantic_ir)

      artifact = build_artifact(case_name, report, semantic_ir)
      write_artifact(case_name, artifact)
      artifact_summary(case_name, artifact)
    end

    def refuse_case(case_name)
      report = read_json(@golden_dir / "#{case_name}.compilation_report.json")
      assemble_case(case_name)
      raise "expected #{case_name} to refuse, but it assembled"
    rescue AssemblyRefused => e
      target = @out_dir / "#{case_name}.igapp"
      {
        "case" => case_name,
        "status" => "refused",
        "pass_result" => report.fetch("pass_result"),
        "reason" => e.message,
        "wrote_igapp" => target.exist?
      }
    end

    private

    def read_json(path)
      JSON.parse(File.read(path))
    end

    def refuse!(case_name, reason)
      raise AssemblyRefused, "#{case_name}: #{reason}"
    end

    def validate_refs!(case_name, report, semantic_ir)
      refuse!(case_name, "SemanticIR kind=#{semantic_ir.fetch("kind", nil)}") unless semantic_ir.fetch("kind") == "semantic_ir_program"
      refuse!(case_name, "semantic_ir_ref mismatch") unless report.fetch("semantic_ir_ref") == semantic_ir.fetch("program_id")
      return if semantic_ir.fetch("compilation_report_ref") == report.fetch("program_id")

      refuse!(case_name, "compilation_report_ref mismatch")
    end

    def validate_semantic_ir!(case_name, semantic_ir)
      semantic_ir.fetch("contracts").each do |contract|
        refuse!(case_name, "OOF contract emitted: #{contract.fetch("contract_name")}") if contract.fetch("fragment_class") == "oof"
      end

      return unless JSON.generate(semantic_ir).include?("stdlib.numeric.")

      refuse!(case_name, "unresolved stdlib.numeric operator in SemanticIR")
    end

    def build_artifact(case_name, report, semantic_ir)
      contracts = semantic_ir.fetch("contracts").map { |contract| contract_file(contract) }
      contract_ids = contracts.map { |contract| contract.fetch("contract_id") }.sort
      fragment_class = contracts.map { |contract| contract.fetch("fragment_class") }.uniq == ["core"] ? "core" : "mixed"
      compatibility_semantic_ir = compatibility_semantic_ir(report, semantic_ir, contracts)
      requirements = requirements_for(compatibility_semantic_ir)
      classified_ast = classified_ast_for(report, semantic_ir, contract_ids, fragment_class)
      diagnostics = { "diagnostics" => report.fetch("diagnostics") }
      compatibility_metadata = compatibility_metadata_for(report, semantic_ir)

      artifact_material = {
        "semantic_ir_program" => semantic_ir,
        "compatibility_semantic_ir" => compatibility_semantic_ir,
        "contracts" => contracts,
        "compilation_report" => report,
        "requirements" => requirements,
        "diagnostics" => diagnostics,
        "classified_ast" => classified_ast,
        "compatibility_metadata" => compatibility_metadata
      }
      artifact_hash = Canonical.hash(artifact_material)
      contracts = contracts.map { |contract| contract.merge("artifact_hash" => artifact_hash) }
      compatibility_semantic_ir = compatibility_semantic_ir.merge("artifact_hash" => artifact_hash)

      manifest = {
        "kind" => "igapp_manifest",
        "format_version" => "0.1.0",
        "format" => "igapp_dir",
        "program_id" => semantic_ir.fetch("program_id"),
        "artifact_hash" => artifact_hash,
        "language_version" => semantic_ir.fetch("format_version"),
        "grammar_version" => semantic_ir.fetch("grammar_version"),
        "schema_version" => "0.1.0",
        "compiled_at" => "2026-05-06T00:00:00Z",
        "assembler" => "igapp-assembler-proof-stage1-v0",
        "semantic_ir_ref" => report.fetch("semantic_ir_ref"),
        "compilation_report_ref" => semantic_ir.fetch("compilation_report_ref"),
        "source_hash" => semantic_ir.fetch("source_hash"),
        "source_path" => semantic_ir.fetch("source_path"),
        "contracts" => contract_ids,
        "contract_refs" => semantic_ir.fetch("contracts").to_h do |contract|
          [contract.fetch("contract_name"), contract.fetch("contract_ref")]
        end,
        "fragment_class" => fragment_class,
        "schema_descriptor" => { "trait_bounds" => [], "migrations" => [] },
        "warnings" => [],
        "diagnostics" => report.fetch("diagnostics")
      }

      {
        "case" => case_name,
        "manifest" => manifest,
        "semantic_ir_program" => semantic_ir,
        "semantic_ir" => compatibility_semantic_ir,
        "contracts" => contracts,
        "compilation_report" => report,
        "requirements" => requirements,
        "diagnostics" => diagnostics,
        "classified_ast" => classified_ast,
        "projections" => { "projections" => [] },
        "compatibility_metadata" => compatibility_metadata
      }
    end

    def compatibility_semantic_ir(report, semantic_ir, contracts)
      contract_summaries = contracts.map do |contract|
        {
          "contract_id" => contract.fetch("contract_id"),
          "name" => contract.fetch("name"),
          "fragment_class" => contract.fetch("fragment_class"),
          "escape_set" => contract.fetch("escape_set"),
          "input_ports" => contract.fetch("input_ports").map { |port| "#{port.fetch("name")}:#{port.fetch("type_tag")}" },
          "output_ports" => contract.fetch("output_ports").map { |port| "#{port.fetch("name")}:#{port.fetch("type_tag")}" },
          "compute_nodes" => contract.fetch("compute_nodes").map { |node| node.fetch("node_id") },
          "lifecycle" => contract.fetch("lifecycle")
        }
      end

      {
        "program_id" => semantic_ir.fetch("program_id"),
        "axiom_version" => "1.0.0",
        "grammar_version" => semantic_ir.fetch("grammar_version"),
        "source_hash" => semantic_ir.fetch("source_hash"),
        "semantic_ir_ref" => report.fetch("semantic_ir_ref"),
        "compilation_report_ref" => semantic_ir.fetch("compilation_report_ref"),
        "contracts" => contract_summaries,
        "dependency_graph" => dependency_graph(contracts),
        "evaluation_targets" => contracts.flat_map do |contract|
          contract.fetch("output_ports").map do |port|
            {
              "name" => port.fetch("name"),
              "contract_id" => contract.fetch("contract_id"),
              "output_ports" => [port.fetch("name")],
              "as_projection" => nil
            }
          end
        end,
        "temporal_requirements" => {
          "requires_as_of" => true,
          "requires_replay" => false,
          "requires_snapshot" => false,
          "min_consistency" => "strong",
          "windows" => [],
          "slices" => []
        },
        "lifecycle_requirements" => {
          "min_lifecycle" => "local",
          "has_audit" => false,
          "has_window" => false
        },
        "capability_requirements" => {
          "required_caps" => [],
          "effect_kinds" => []
        },
        "effect_declarations" => [],
        "ffi_requirements" => [],
        "projection_descriptors" => [],
        "boundary_descriptors" => []
      }
    end

    def contract_file(contract_ir)
      contract_id = contract_ir.fetch("contract_name")
      input_ports = ports(contract_ir.fetch("inputs"))
      output_ports = ports(contract_ir.fetch("outputs"))
      compute_nodes = contract_ir.fetch("nodes").map do |node|
        {
          "node_id" => "node_#{node.fetch("name")}",
          "name" => node.fetch("name"),
          "kind" => node.fetch("kind"),
          "fragment_class" => node.fetch("fragment"),
          "type_tag" => type_name(node.fetch("type")),
          "lifecycle" => "session",
          "obs_kind" => "value_observation",
          "dependencies" => node.fetch("deps").map { |dep| "input:#{dep}" },
          "expression" => compat_expr(node.fetch("expr"))
        }
      end

      {
        "contract_id" => contract_id,
        "source_contract_ref" => contract_ir.fetch("contract_ref"),
        "name" => contract_id,
        "fragment_class" => contract_ir.fetch("fragment_class"),
        "escape_set" => contract_ir.fetch("escape_boundaries"),
        "lifecycle" => "session",
        "input_ports" => input_ports,
        "output_ports" => output_ports,
        "compute_nodes" => compute_nodes,
        "type_signature" => {
          "inputs" => input_ports.to_h { |port| [port.fetch("name"), port.fetch("type_tag")] },
          "outputs" => output_ports.to_h { |port| [port.fetch("name"), port.fetch("type_tag")] }
        }
      }
    end

    def ports(port_irs)
      port_irs.map do |port|
        {
          "name" => port.fetch("name"),
          "type_tag" => type_name(port.fetch("type")),
          "lifecycle" => port.fetch("lifecycle"),
          "required" => true
        }
      end
    end

    def compat_expr(expr)
      case expr.fetch("kind")
      when "call"
        {
          "kind" => "apply",
          "operator" => expr.fetch("fn"),
          "operands" => expr.fetch("args").map { |arg| compat_expr(arg) }
        }
      when "ref"
        { "kind" => "ref", "name" => expr.fetch("name") }
      when "literal"
        { "kind" => "literal", "value" => expr.fetch("value"), "type_tag" => type_name(expr.fetch("resolved_type")) }
      when "field_access"
        {
          "kind" => "field_access",
          "object" => compat_expr(expr.fetch("object")),
          "field" => expr.fetch("field"),
          "type_tag" => type_name(expr.fetch("resolved_type"))
        }
      else
        expr
      end
    end

    def type_name(type)
      return type if type.is_a?(String)

      params = type.fetch("params", [])
      return type.fetch("name") if params.empty?

      "#{type.fetch("name")}[#{params.map { |param| type_name(param) }.join(",")}]"
    end

    def dependency_graph(contracts)
      nodes = []
      edges = []
      contracts.each do |contract|
        contract.fetch("input_ports").each { |port| nodes << "input:#{port.fetch("name")}" }
        contract.fetch("compute_nodes").each do |node|
          nodes << node.fetch("node_id")
          node.fetch("dependencies").each do |dep|
            edges << { "from" => dep, "to" => node.fetch("node_id"), "kind" => "data" }
          end
        end
        contract.fetch("output_ports").each do |port|
          nodes << "output:#{port.fetch("name")}"
          edges << { "from" => "node_#{port.fetch("name")}", "to" => "output:#{port.fetch("name")}", "kind" => "data" }
        end
      end
      { "nodes" => nodes.uniq.sort, "edges" => edges.sort_by { |edge| [edge.fetch("from"), edge.fetch("to")] } }
    end

    def requirements_for(semantic_ir)
      {
        "temporal" => semantic_ir.fetch("temporal_requirements"),
        "lifecycle" => semantic_ir.fetch("lifecycle_requirements"),
        "capabilities" => semantic_ir.fetch("capability_requirements"),
        "effects" => [],
        "ffi" => [],
        "required_tbackend_caps" => {
          "read_as_of" => true,
          "append_atomic" => true,
          "replay_enabled" => false,
          "snapshot_enabled" => false,
          "compact_enabled" => false,
          "subscribe_enabled" => false,
          "consistency" => "strong"
        }
      }
    end

    def classified_ast_for(report, semantic_ir, contract_ids, fragment_class)
      {
        "kind" => "classified_program",
        "format_version" => "0.1.0",
        "program_id" => semantic_ir.fetch("program_id"),
        "source_hash" => semantic_ir.fetch("source_hash"),
        "source_path" => semantic_ir.fetch("source_path"),
        "pass_result" => report.fetch("pass_result"),
        "semantic_ir_ref" => report.fetch("semantic_ir_ref"),
        "compilation_report_ref" => semantic_ir.fetch("compilation_report_ref"),
        "fragment_class" => fragment_class,
        "oof_count" => 0,
        "contracts" => contract_ids,
        "loadable_contracts" => contract_ids
      }
    end

    def compatibility_metadata_for(report, semantic_ir)
      {
        "kind" => "igapp_compatibility_metadata",
        "format_version" => "0.1.0",
        "canonical_semantic_ir_ref" => semantic_ir.fetch("program_id"),
        "compilation_report_ref" => report.fetch("program_id"),
        "loader_shape" => "runtime_machine_memory_proof.compat_v0",
        "canonical_artifact" => "semantic_ir_program.json",
        "runtime_compatibility_artifact" => "semantic_ir.json",
        "notes" => [
          "semantic_ir_program.json preserves PROP-019.1 envelope",
          "semantic_ir.json is a compatibility view for the existing proof RuntimeMachine loader"
        ]
      }
    end

    def write_artifact(case_name, artifact)
      target = @out_dir / "#{case_name}.igapp"
      FileUtils.rm_rf(target)
      FileUtils.mkdir_p(target / "contracts")

      write_json(target / "manifest.json", artifact.fetch("manifest"))
      write_json(target / "semantic_ir_program.json", artifact.fetch("semantic_ir_program"))
      write_json(target / "semantic_ir.json", artifact.fetch("semantic_ir"))
      write_json(target / "compilation_report.json", artifact.fetch("compilation_report"))
      write_json(target / "requirements.json", artifact.fetch("requirements"))
      write_json(target / "diagnostics.json", artifact.fetch("diagnostics"))
      write_json(target / "classified_ast.json", artifact.fetch("classified_ast"))
      write_json(target / "projections.json", artifact.fetch("projections"))
      write_json(target / "compatibility_metadata.json", artifact.fetch("compatibility_metadata"))
      artifact.fetch("contracts").each do |contract|
        write_json(target / "contracts/#{snake_case(contract.fetch("contract_id"))}.json", contract)
      end
    end

    def write_json(path, value)
      File.write(path, Canonical.json(value))
    end

    def snake_case(value)
      value.gsub(/([a-z])([A-Z])/, "\\1_\\2").downcase
    end

    def artifact_summary(case_name, artifact)
      {
        "case" => case_name,
        "status" => "assembled",
        "igapp_dir" => "experiments/igapp_assembler_proof/out/#{case_name}.igapp",
        "program_id" => artifact.fetch("manifest").fetch("program_id"),
        "artifact_hash" => artifact.fetch("manifest").fetch("artifact_hash"),
        "semantic_ir_ref" => artifact.fetch("manifest").fetch("semantic_ir_ref"),
        "compilation_report_ref" => artifact.fetch("manifest").fetch("compilation_report_ref"),
        "contracts" => artifact.fetch("manifest").fetch("contracts"),
        "files" => artifact_files(case_name)
      }
    end

    def artifact_files(case_name)
      target = @out_dir / "#{case_name}.igapp"
      target.find.select(&:file?).map { |path| path.relative_path_from(target).to_s }.sort
    end
  end

  module RuntimeProof
    module_function

    def load_and_resume_add(path)
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
      program.validate!
      backend = RuntimeMachineMemoryProof::MemoryTBackend.new
      machine = RuntimeMachineMemoryProof::RuntimeMachine.new(
        machine_id: "runtime-machine/igapp-assembler-proof",
        session_id: "session/igapp-assembler-proof",
        backend: backend
      )
      machine.boot
      load = machine.load_program(program)
      eval = machine.evaluate_program("Add", { "a" => 19, "b" => 23 }, as_of: PROOF_AS_OF)
      checkpoint = machine.checkpoint(horizon: { as_of: PROOF_AS_OF, rule_version: "igapp-assembler-proof-stage1-v0" })
      resume = machine.resume(image: checkpoint.fetch(:semantic_image), requested_as_of: PROOF_AS_OF)
      schema_check = resume.fetch(:report).fetch("checks").find { |check| check.fetch("dimension") == "schema" }

      {
        "load_status" => load.fetch(:status),
        "evaluate_status" => eval.fetch(:status),
        "sum" => eval.fetch(:outputs).fetch("sum"),
        "checkpoint_status" => checkpoint.fetch(:status),
        "compatibility_report_status" => resume.fetch(:status),
        "schema_decision" => schema_check.fetch("decision")
      }
    rescue => e
      {
        "load_status" => "blocked",
        "error" => "#{e.class}: #{e.message}"
      }
    end
  end

  module CLI
    module_function

    def run(_argv)
      assembler = Assembler.new
      FileUtils.mkdir_p(OUT_DIR)

      positive = POSITIVE_CASES.map { |case_name| assembler.assemble_case(case_name) }
      negative = NEGATIVE_CASES.map { |case_name| assembler.refuse_case(case_name) }
      deterministic = deterministic?(assembler)
      runtime = RuntimeProof.load_and_resume_add(OUT_DIR / "add.igapp")
      checks = checks(positive, negative, deterministic, runtime)
      summary = {
        "proof" => "igapp-assembler-proof-stage1-v0",
        "status" => checks.all? { |check| check.fetch("ok") } ? "PASS" : "FAIL",
        "positive" => positive,
        "negative" => negative,
        "runtime" => runtime,
        "deterministic_output" => deterministic,
        "checks" => checks
      }
      File.write(OUT_DIR / "result_summary.json", Canonical.json(summary))
      print_summary(summary)
      summary.fetch("status") == "PASS"
    end

    def deterministic?(assembler)
      before = directory_hashes(OUT_DIR)
      POSITIVE_CASES.each { |case_name| assembler.assemble_case(case_name) }
      after = directory_hashes(OUT_DIR)
      before == after
    end

    def directory_hashes(dir)
      return {} unless dir.exist?

      dir.find.select(&:file?).reject { |path| path.basename.to_s == "result_summary.json" }.to_h do |path|
        [path.relative_path_from(dir).to_s, Digest::SHA256.hexdigest(File.read(path))]
      end
    end

    def checks(positive, negative, deterministic, runtime)
      [
        check("assembler.positive.add", positive.any? { |item| item.fetch("case") == "add" && item.fetch("status") == "assembled" }),
        check("assembler.positive.claim_evidence", positive.any? { |item| item.fetch("case") == "claim_evidence" && item.fetch("status") == "assembled" }),
        check("assembler.positive.evidence_linked_alert", positive.any? { |item| item.fetch("case") == "evidence_linked_alert" && item.fetch("status") == "assembled" }),
        check("assembler.negative.unresolved_symbol_refused", refused?(negative, "negative_unresolved_symbol")),
        check("assembler.negative.evidence_less_alert_refused", refused?(negative, "negative_evidence_less_alert")),
        check("assembler.negative.confidence_bool_refused", refused?(negative, "negative_confidence_bool")),
        check("assembler.deterministic_output", deterministic),
        check("runtime.load_assembled_add", runtime.fetch("load_status") == "loaded"),
        check("runtime.evaluate_assembled_add", runtime.fetch("sum", nil) == 42),
        check("runtime.compatibility_report_trusted", runtime.fetch("compatibility_report_status", nil) == "trusted")
      ]
    end

    def refused?(negative, case_name)
      negative.any? do |item|
        item.fetch("case") == case_name &&
          item.fetch("status") == "refused" &&
          item.fetch("wrote_igapp") == false
      end
    end

    def check(name, ok)
      { "name" => name, "ok" => ok }
    end

    def print_summary(summary)
      puts "#{summary.fetch("status")} igapp_assembler_proof"
      summary.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "FAIL"}"
      end
      puts "runtime.load_status: #{summary.dig("runtime", "load_status")}"
      puts "runtime.compatibility_report_status: #{summary.dig("runtime", "compatibility_report_status") || "not_available"}"
      puts "out: #{OUT_DIR.relative_path_from(ROOT)}"
    end
  end
end

success = IgappAssemblerProof::CLI.run(ARGV)
exit(success ? 0 : 1)
