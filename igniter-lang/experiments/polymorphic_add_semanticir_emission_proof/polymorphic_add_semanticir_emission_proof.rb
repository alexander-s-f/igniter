#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

require_relative "../polymorphic_add_classifier_proof/polymorphic_add_classifier_proof"

module PolymorphicAddSemanticIREmissionProof
  ROOT = File.expand_path("../..", __dir__)
  EXPECTED_SEMANTIC_IR = File.join(__dir__, "polymorphic_add.semantic_ir.expected.json")
  ADD_IGAPP_SEMANTIC_IR = File.join(ROOT, "fixtures/add.igapp/semantic_ir.json")

  module_function

  def call
    classifier_result = PolymorphicAddClassifierProof.call
    typed_program = classifier_result.fetch(:typed_program)
    negative_program = classifier_result.fetch(:negative_program)
    semantic_ir = emit_semantic_ir(typed_program)
    expected_ir = File.exist?(EXPECTED_SEMANTIC_IR) ? JSON.parse(File.read(EXPECTED_SEMANTIC_IR)) : nil
    add_igapp = JSON.parse(File.read(ADD_IGAPP_SEMANTIC_IR))

    checks = [
      check("prerequisite.classifier_proof", classifier_result.fetch(:checks).all? { |item| item.fetch(:ok) }),
      check("semantic_ir.add_integer", contract_ok?(semantic_ir, "Add[Integer]", "Integer")),
      check("semantic_ir.add_float", contract_ok?(semantic_ir, "Add[Float]", "Float")),
      check("invariant.no_type_variables", no_type_variables?(semantic_ir)),
      check("invariant.no_unresolved_trait_calls", no_unresolved_trait_calls?(semantic_ir)),
      check("invariant.no_generic_contractir", no_generic_contract_ir?(semantic_ir)),
      check("invariant.stdlib_operator", stdlib_operator_only?(semantic_ir)),
      check("negative.add_string_absent", add_string_absent?(semantic_ir, negative_program)),
      check("compare.add_integer_matches_add_igapp", add_integer_matches_add_igapp?(semantic_ir, add_igapp)),
      check("fixture.semantic_ir_expected", expected_ir.nil? || semantic_ir == expected_ir)
    ]

    {
      checks: checks,
      semantic_ir: semantic_ir
    }
  end

  def emit_semantic_ir(typed_program)
    contracts = typed_program.fetch("specializations").map { |contract| emit_contract_ir(typed_program, contract) }

    {
      "kind" => "semantic_ir",
      "program_id" => "prog_polymorphic_add_semanticir_proof",
      "axiom_version" => "1.0.0",
      "grammar_version" => "polymorphic-v0",
      "source_hash" => typed_program.fetch("source_hash"),
      "contracts" => contracts,
      "shape_descriptors" => contracts.each_with_object({}) do |contract, out|
        contract.fetch("implements").each do |impl|
          out[impl.fetch("shape")] = contract.fetch("shapes").fetch(impl.fetch("shape"))
        end
      end,
      "lowering_invariants" => [
        "SIR-1:no_type_variables",
        "SIR-2:no_unresolved_trait_method_calls",
        "SIR-3:no_generic_contractir",
        "SIR-4:concrete_resolved_impl"
      ]
    }
  end

  def emit_contract_ir(typed_program, typed_contract)
    concrete_type = typed_contract.fetch("type_args").fetch("T")
    contract_name = typed_contract.fetch("name")
    module_name = typed_program.fetch("module")
    shape_name = "AddShape[#{concrete_type}]"

    {
      "contract_id" => "#{module_name}.#{contract_name}",
      "name" => contract_name,
      "specialization_of" => "#{module_name}.#{typed_contract.fetch("specialization_of")}",
      "type_args" => typed_contract.fetch("type_args"),
      "fragment_class" => typed_contract.fetch("fragment_class"),
      "escape_set" => [],
      "input_ports" => typed_contract.fetch("input_ports"),
      "compute_nodes" => typed_contract.fetch("compute_nodes").map { |node| emit_compute_node(node) },
      "output_ports" => typed_contract.fetch("output_ports"),
      "dependency_graph" => dependency_graph,
      "evaluation_targets" => [
        {
          "name" => "sum",
          "contract_id" => "#{module_name}.#{contract_name}",
          "output_ports" => ["sum"],
          "as_projection" => nil
        }
      ],
      "temporal_requirements" => temporal_requirements,
      "lifecycle_requirements" => lifecycle_requirements,
      "capability_requirements" => capability_requirements,
      "effect_declarations" => [],
      "ffi_requirements" => [],
      "projection_descriptors" => [],
      "boundary_descriptors" => [],
      "shapes" => {
        shape_name => {
          "input_ports" => typed_contract.fetch("input_ports").map { |port| shape_port(port) },
          "output_ports" => typed_contract.fetch("output_ports").map { |port| shape_port(port) }
        }
      },
      "implements" => typed_contract.fetch("implements_check").map do |item|
        { "shape" => item.fetch("shape"), "check" => item.fetch("result") == "pass" ? "passed" : "failed" }
      end
    }
  end

  def emit_compute_node(node)
    {
      "node_id" => "node_sum",
      "name" => node.fetch("name"),
      "type_tag" => node.fetch("type_tag"),
      "lifecycle" => node.fetch("lifecycle"),
      "expression" => node.fetch("expression")
    }
  end

  def shape_port(port)
    {
      "name" => port.fetch("name"),
      "type_tag" => port.fetch("type_tag")
    }
  end

  def dependency_graph
    {
      "nodes" => ["input:a", "input:b", "node_sum", "output:sum"],
      "edges" => [
        { "from" => "input:a", "to" => "node_sum", "kind" => "data" },
        { "from" => "input:b", "to" => "node_sum", "kind" => "data" },
        { "from" => "node_sum", "to" => "output:sum", "kind" => "data" }
      ]
    }
  end

  def temporal_requirements
    {
      "requires_as_of" => true,
      "requires_replay" => false,
      "requires_snapshot" => false,
      "min_consistency" => "strong",
      "windows" => [],
      "slices" => []
    }
  end

  def lifecycle_requirements
    {
      "min_lifecycle" => "local",
      "has_audit" => false,
      "has_window" => false
    }
  end

  def capability_requirements
    {
      "required_caps" => [],
      "effect_kinds" => []
    }
  end

  def contract_ok?(semantic_ir, name, concrete_type)
    contract = find_contract(semantic_ir, name)
    return false unless contract

    contract.fetch("type_args") == { "T" => concrete_type } &&
      port_strings(contract.fetch("input_ports")) == ["a:#{concrete_type}", "b:#{concrete_type}"] &&
      port_strings(contract.fetch("output_ports")) == ["sum:#{concrete_type}"] &&
      contract.fetch("compute_nodes").fetch(0).fetch("expression").fetch("operator") == "stdlib.numeric.add" &&
      contract.fetch("compute_nodes").fetch(0).fetch("expression").fetch("resolved_impl") == "Additive[#{concrete_type}]" &&
      contract.fetch("implements").fetch(0).fetch("check") == "passed"
  end

  def no_type_variables?(value)
    !walk(value).any? do |item|
      item.is_a?(String) && (item == "T" || item.include?("[T]") || item.end_with?(":T"))
    end
  end

  def no_unresolved_trait_calls?(value)
    !walk(value).any? do |item|
      item.is_a?(Hash) &&
        (item["kind"] == "trait_method_call" ||
         (item["kind"] == "call" && item["fn"] == "add") ||
         item["operator"] == "add")
    end
  end

  def no_generic_contract_ir?(semantic_ir)
    semantic_ir.fetch("contracts").none? do |contract|
      contract.fetch("name") == "Add" ||
        contract.fetch("contract_id").end_with?(".Add") ||
        contract.fetch("type_args").values.any? { |value| value == "T" }
    end
  end

  def stdlib_operator_only?(semantic_ir)
    semantic_ir.fetch("contracts").all? do |contract|
      contract.fetch("compute_nodes").all? do |node|
        node.fetch("expression").fetch("operator") == "stdlib.numeric.add"
      end
    end
  end

  def add_string_absent?(semantic_ir, negative_program)
    negative_program.fetch("type_errors").any? { |error| error.fetch("code") == "OOF-TY1" } &&
      !JSON.generate(semantic_ir).include?("String") &&
      semantic_ir.fetch("contracts").none? { |contract| contract.fetch("name") == "Add[String]" }
  end

  def add_integer_matches_add_igapp?(semantic_ir, add_igapp)
    contract = find_contract(semantic_ir, "Add[Integer]")
    existing = add_igapp.fetch("contracts").fetch(0)
    return false unless contract

    contract.fetch("fragment_class") == existing.fetch("fragment_class") &&
      port_strings(contract.fetch("input_ports")) == existing.fetch("input_ports") &&
      port_strings(contract.fetch("output_ports")) == existing.fetch("output_ports") &&
      contract.fetch("dependency_graph") == add_igapp.fetch("dependency_graph") &&
      contract.fetch("temporal_requirements") == add_igapp.fetch("temporal_requirements") &&
      contract.fetch("lifecycle_requirements") == add_igapp.fetch("lifecycle_requirements") &&
      contract.fetch("capability_requirements") == add_igapp.fetch("capability_requirements")
  end

  def find_contract(semantic_ir, name)
    semantic_ir.fetch("contracts").find { |contract| contract.fetch("name") == name }
  end

  def port_strings(ports)
    ports.map { |port| "#{port.fetch("name")}:#{port.fetch("type_tag")}" }
  end

  def walk(value, out = [])
    out << value
    case value
    when Hash
      value.each_value { |child| walk(child, out) }
    when Array
      value.each { |child| walk(child, out) }
    end
    out
  end

  def check(name, ok)
    { name: name, ok: ok }
  end

  module CLI
    module_function

    def run(argv)
      result = PolymorphicAddSemanticIREmissionProof.call
      if argv.delete("--dump")
        puts JSON.pretty_generate(result.fetch(:semantic_ir))
        return true
      end

      print_result(result)
      result.fetch(:checks).all? { |check| check.fetch(:ok) }
    end

    def print_result(result)
      ok = result.fetch(:checks).all? { |check| check.fetch(:ok) }
      puts "#{ok ? "PASS" : "FAIL"} polymorphic_add_semanticir_emission_proof"
      result.fetch(:checks).each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
      names = result.fetch(:semantic_ir).fetch("contracts").map { |contract| contract.fetch("name") }
      puts "semantic_ir.contracts: #{names.join(", ")}"
      puts "semantic_ir.fixture: #{EXPECTED_SEMANTIC_IR}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = PolymorphicAddSemanticIREmissionProof::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
