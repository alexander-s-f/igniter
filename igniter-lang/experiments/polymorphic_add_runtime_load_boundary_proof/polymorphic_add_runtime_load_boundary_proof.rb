#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

require_relative "../runtime_machine_memory_proof/compiled_program"

module PolymorphicAddRuntimeLoadBoundaryProof
  ROOT = File.expand_path("../..", __dir__)
  DEFAULT_IGAPP = File.join(ROOT, "fixtures/polymorphic_add.igapp")
  PROOF_AS_OF = RuntimeMachineMemoryProof::PROOF_AS_OF
  LOADABLE_CONTRACTS = [
    "Lang.Examples.PolymorphicAdd.Add[Integer]",
    "Lang.Examples.PolymorphicAdd.Add[Float]"
  ].freeze
  GENERIC_TEMPLATE = "Lang.Examples.PolymorphicAdd.Add"

  module_function

  def call(path = DEFAULT_IGAPP)
    manifest = read_json(File.join(path, "manifest.json"))
    specialization_manifest = read_json(File.join(path, "specialization_manifest.json"))
    classified_ast = read_json(File.join(path, "classified_ast.json"))
    semantic_ir = read_json(File.join(path, "semantic_ir.json"))
    program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
    validation_error = validate_program(program)
    runtime_load = try_runtime_load(program)
    direct_eval = try_direct_eval(program)

    checks = [
      check("compiled_program.load_igapp", !program.nil?),
      check("compiled_program.validate", validation_error.nil?),
      check("fixture.loadable_contracts_monomorphic", loadable_contracts_monomorphic?(manifest, program, semantic_ir)),
      check("fixture.generic_add_metadata_only", generic_add_metadata_only?(manifest, classified_ast, program)),
      check("fixture.specialization_manifest_present", specialization_manifest_ok?(manifest, specialization_manifest)),
      check("runtime.load_program.current_boundary_blocked", runtime_load.fetch(:status) == "blocked"),
      check("runtime.load_program.blocker_descriptor_refs_shape", runtime_load.fetch(:error).include?("no implicit conversion of Hash into Array")),
      check("runtime.evaluate_program.next_blocker_stdlib_operator", direct_eval.fetch(:error).include?("Unknown operator: stdlib.numeric.add"))
    ]

    {
      checks: checks,
      load_result: runtime_load,
      direct_eval_result: direct_eval,
      program_contracts: program.contracts.keys.sort
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def validate_program(program)
    program.validate!
    nil
  rescue => e
    "#{e.class}: #{e.message}"
  end

  def try_runtime_load(program)
    backend = RuntimeMachineMemoryProof::MemoryTBackend.new
    machine = RuntimeMachineMemoryProof::RuntimeMachine.new(
      machine_id: "runtime-machine/polymorphic-add-load-boundary",
      session_id: "session/polymorphic-add-load-boundary",
      backend: backend
    )
    machine.boot
    load = machine.load_program(program)
    { status: load.fetch(:status), error: nil, descriptor_refs: load.fetch(:descriptor_refs).keys.sort }
  rescue => e
    { status: "blocked", error: "#{e.class}: #{e.message}", descriptor_refs: [] }
  end

  def try_direct_eval(program)
    outputs = program.evaluate_contract(
      "Lang.Examples.PolymorphicAdd.Add[Integer]",
      { "a" => 1, "b" => 2 },
      backend: nil,
      as_of: PROOF_AS_OF
    )
    { status: "ok", error: nil, outputs: outputs }
  rescue => e
    { status: "blocked", error: "#{e.class}: #{e.message}", outputs: {} }
  end

  def loadable_contracts_monomorphic?(manifest, program, semantic_ir)
    manifest.fetch("contracts").sort == LOADABLE_CONTRACTS.sort &&
      program.contracts.keys.sort == LOADABLE_CONTRACTS.sort &&
      semantic_ir.fetch("contracts").map { |contract| contract.fetch("contract_id") }.sort == LOADABLE_CONTRACTS.sort &&
      !program.contracts.key?(GENERIC_TEMPLATE) &&
      !JSON.generate(semantic_ir.fetch("contracts")).include?("Add[String]")
  end

  def generic_add_metadata_only?(manifest, classified_ast, program)
    manifest.fetch("metadata_only_templates") == [GENERIC_TEMPLATE] &&
      classified_ast.fetch("generic_templates").all? { |template| template.fetch("loadable") == false } &&
      classified_ast.fetch("loadable_contracts").sort == LOADABLE_CONTRACTS.sort &&
      !program.contracts.key?(GENERIC_TEMPLATE)
  end

  def specialization_manifest_ok?(manifest, specialization_manifest)
    emitted = specialization_manifest.fetch("specializations").map { |item| item.fetch("emitted_contract_id") }
    manifest.fetch("specialization_manifest_ref") == "specialization_manifest.json" &&
      emitted.sort == LOADABLE_CONTRACTS.sort
  end

  def check(name, ok)
    { name: name, ok: ok }
  end

  module CLI
    module_function

    def run(argv)
      result = PolymorphicAddRuntimeLoadBoundaryProof.call(argv.shift || DEFAULT_IGAPP)
      print_result(result)
      result.fetch(:checks).all? { |check| check.fetch(:ok) }
    end

    def print_result(result)
      ok = result.fetch(:checks).all? { |check| check.fetch(:ok) }
      puts "#{ok ? "BLOCKED" : "FAIL"} polymorphic_add_runtime_load_boundary_proof"
      result.fetch(:checks).each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
      puts "program.contracts: #{result.fetch(:program_contracts).join(", ")}"
      puts "runtime.load_program.error: #{result.fetch(:load_result).fetch(:error)}"
      puts "runtime.evaluate_program.error: #{result.fetch(:direct_eval_result).fetch(:error)}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = PolymorphicAddRuntimeLoadBoundaryProof::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
