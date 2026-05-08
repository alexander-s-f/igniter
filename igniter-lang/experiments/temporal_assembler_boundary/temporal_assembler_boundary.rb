#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

require_relative "../../lib/igniter_lang/assembler"
require_relative "../runtime_machine_memory_proof/compiled_program"

module TemporalAssemblerBoundaryProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  GOLDEN_DIR = ROOT / "igniter-lang/experiments/temporal_semanticir_access_node/golden"
  OUT_DIR = ROOT / "igniter-lang/experiments/temporal_assembler_boundary/out"
  SUMMARY_PATH = OUT_DIR / "temporal_assembler_boundary_summary.json"

  CASES = [
    {
      "id" => "history_valid",
      "contract_id" => "HistoryAxesTest",
      "contract_file" => "history_axes_test.json",
      "capability" => "history_read",
      "axis" => "valid_time",
      "coordinate_refs" => { "as_of" => "as_of" }
    },
    {
      "id" => "bihistory_valid",
      "contract_id" => "BiHistoryAxesTest",
      "contract_file" => "bi_history_axes_test.json",
      "capability" => "bihistory_read",
      "axis" => "bitemporal",
      "coordinate_refs" => {
        "valid_time" => "valid_time",
        "transaction_time" => "transaction_time"
      }
    }
  ].freeze

  module_function

  def run
    assembler = IgniterLang::Assembler.new(golden_dir: GOLDEN_DIR, out_dir: OUT_DIR)
    assembled = CASES.to_h do |config|
      [config.fetch("id"), assemble_and_inspect(assembler, config)]
    end
    checks = build_checks(assembled)
    summary = {
      "kind" => "temporal_assembler_boundary_proof",
      "format_version" => "0.1.0",
      "track" => "temporal-assembler-boundary-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "artifact_placement" => {
        "contract_file" => "temporal_input_node and temporal_access_node are preserved under contracts/*.json temporal_nodes",
        "requirements" => "required temporal capabilities, axes, and coordinate refs are copied into requirements.json",
        "runtime_execution" => "unsupported in this proof; compatibility_metadata.json carries an explicit guard"
      },
      "cases" => assembled,
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def assemble_and_inspect(assembler, config)
    summary = assembler.assemble_case(config.fetch("id"))
    igapp_dir = OUT_DIR / "#{config.fetch("id")}.igapp"
    program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(igapp_dir)
    validation_error = validate_program(program)
    contract = read_json(igapp_dir / "contracts/#{config.fetch("contract_file")}")
    requirements = read_json(igapp_dir / "requirements.json")
    manifest = read_json(igapp_dir / "manifest.json")
    compatibility_metadata = read_json(igapp_dir / "compatibility_metadata.json")

    {
      "id" => config.fetch("id"),
      "assembly" => summary,
      "manifest_fragment_class" => manifest.fetch("fragment_class"),
      "compiled_program_valid" => validation_error.nil?,
      "compiled_program_validation_error" => validation_error,
      "contract" => contract,
      "requirements" => requirements,
      "compatibility_metadata" => compatibility_metadata
    }
  end

  def validate_program(program)
    program.validate!
    nil
  rescue => e
    "#{e.class}: #{e.message}"
  end

  def build_checks(assembled)
    CASES.each_with_object({}) do |config, checks|
      result = assembled.fetch(config.fetch("id"))
      contract = result.fetch("contract")
      requirements = result.fetch("requirements")
      metadata = result.fetch("compatibility_metadata")
      temporal_nodes = contract.fetch("temporal_nodes", [])
      input_node = temporal_nodes.find { |node| node.fetch("kind") == "temporal_input_node" }
      access_node = temporal_nodes.find { |node| node.fetch("kind") == "temporal_access_node" }
      prefix = config.fetch("id")

      checks["#{prefix}.assembled"] = result.fetch("assembly").fetch("status") == "assembled"
      checks["#{prefix}.compiled_program_validates"] = result.fetch("compiled_program_valid") == true
      checks["#{prefix}.manifest_fragment_temporal"] = result.fetch("manifest_fragment_class") == "temporal"
      checks["#{prefix}.compute_nodes_empty"] = contract.fetch("compute_nodes").empty?
      checks["#{prefix}.temporal_nodes_in_contract_file"] = temporal_nodes.length == 2 &&
        !input_node.nil? &&
        !access_node.nil?
      checks["#{prefix}.temporal_node_metadata_preserved"] = temporal_node_metadata_preserved?(
        input_node: input_node,
        access_node: access_node,
        config: config
      )
      checks["#{prefix}.requirements_preserve_temporal_boundary"] =
        requirements.dig("capabilities", "required_caps").include?(config.fetch("capability")) &&
        requirements.dig("temporal", "axes").include?(config.fetch("axis")) &&
        requirements.dig("temporal", "coordinate_refs").any? do |entry|
          entry.fetch("axis") == config.fetch("axis") &&
            entry.fetch("coordinates") == config.fetch("coordinate_refs")
        end
      checks["#{prefix}.runtime_execution_guard"] =
        metadata.dig("runtime_execution", "status") == "unsupported" &&
        metadata.dig("runtime_execution", "reason").include?("out of scope")
    end
  end

  def temporal_node_metadata_preserved?(input_node:, access_node:, config:)
    [input_node, access_node].all? do |node|
      node.fetch("node_fragment_class") == "temporal" &&
        node.fetch("value_fragment_class") == "core" &&
        node.fetch("required_capability") == config.fetch("capability") &&
        node.fetch("required_caps").include?(config.fetch("capability")) &&
        node.fetch("axis") == config.fetch("axis")
    end &&
      access_node.fetch("coordinate_refs") == config.fetch("coordinate_refs")
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    path.dirname.mkpath
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_assembler_boundary"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = TemporalAssemblerBoundaryProof.run
exit(success ? 0 : 1)
