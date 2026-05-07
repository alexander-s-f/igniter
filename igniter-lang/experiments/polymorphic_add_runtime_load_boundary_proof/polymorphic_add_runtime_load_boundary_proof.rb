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
    runtime_eval = try_runtime_eval(program)

    checks = [
      check("compiled_program.load_igapp", !program.nil?),
      check("compiled_program.validate", validation_error.nil?),
      check("fixture.loadable_contracts_monomorphic", loadable_contracts_monomorphic?(manifest, program, semantic_ir)),
      check("fixture.generic_add_metadata_only", generic_add_metadata_only?(manifest, classified_ast, program)),
      check("fixture.specialization_manifest_present", specialization_manifest_ok?(manifest, specialization_manifest)),
      check("runtime.load_program", runtime_load.fetch(:status) == "loaded"),
      check("runtime.load_program.contracts_loaded", runtime_load.fetch(:descriptor_refs) == LOADABLE_CONTRACTS.sort),
      check("runtime.evaluate_add_integer", runtime_eval.dig(:add_integer, :outputs, "sum") == 3),
      check("runtime.evaluate_add_float", runtime_eval.dig(:add_float, :outputs, "sum") == 3.75),
      check("runtime.reject_generic_add", runtime_eval.dig(:generic_add, :status) == "rejected"),
      check("runtime.reject_add_string", runtime_eval.dig(:add_string, :status) == "rejected"),
      check(
        "runtime.operator_canonical_monomorphic_add",
        runtime_eval.dig(:add_integer, :error).nil? && runtime_eval.dig(:add_float, :error).nil?
      )
    ]

    {
      checks: checks,
      load_result: runtime_load,
      runtime_eval_result: runtime_eval,
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

  def try_runtime_eval(program)
    {
      add_integer: eval_contract(
        program,
        "Lang.Examples.PolymorphicAdd.Add[Integer]",
        { "a" => 1, "b" => 2 }
      ),
      add_float: eval_contract(
        program,
        "Lang.Examples.PolymorphicAdd.Add[Float]",
        { "a" => 1.5, "b" => 2.25 }
      ),
      generic_add: eval_contract(program, GENERIC_TEMPLATE, { "a" => 1, "b" => 2 }),
      add_string: eval_contract(
        program,
        "Lang.Examples.PolymorphicAdd.Add[String]",
        { "a" => "a", "b" => "b" }
      )
    }
  rescue => e
    {
      add_integer: { status: "blocked", error: "#{e.class}: #{e.message}", outputs: {} },
      add_float: { status: "blocked", error: "#{e.class}: #{e.message}", outputs: {} },
      generic_add: { status: "blocked", error: "#{e.class}: #{e.message}", outputs: {} },
      add_string: { status: "blocked", error: "#{e.class}: #{e.message}", outputs: {} }
    }
  end

  def eval_contract(program, contract_id, inputs)
    backend = RuntimeMachineMemoryProof::MemoryTBackend.new
    machine = RuntimeMachineMemoryProof::RuntimeMachine.new(
      machine_id: "runtime-machine/polymorphic-add-loader-normalization",
      session_id: "session/polymorphic-add-loader-normalization",
      backend: backend
    )
    machine.boot
    machine.load_program(program)
    result = machine.evaluate_program(contract_id, inputs, as_of: PROOF_AS_OF)
    { status: result.fetch(:status), error: nil, outputs: result.fetch(:outputs) }
  rescue => e
    { status: "rejected", error: "#{e.class}: #{e.message}", outputs: {} }
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
      puts "#{ok ? "PASS" : "FAIL"} polymorphic_add_runtime_loader_normalization_proof"
      result.fetch(:checks).each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
      puts "program.contracts: #{result.fetch(:program_contracts).join(", ")}"
      puts "runtime.load_program.status: #{result.fetch(:load_result).fetch(:status)}"
      puts "runtime.evaluate_add_integer.sum: #{result.dig(:runtime_eval_result, :add_integer, :outputs, "sum")}"
      puts "runtime.evaluate_add_float.sum: #{result.dig(:runtime_eval_result, :add_float, :outputs, "sum")}"
      puts "runtime.reject_generic_add.error: #{result.dig(:runtime_eval_result, :generic_add, :error)}"
      puts "runtime.reject_add_string.error: #{result.dig(:runtime_eval_result, :add_string, :error)}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = PolymorphicAddRuntimeLoadBoundaryProof::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
