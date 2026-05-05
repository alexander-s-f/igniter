#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"

# Load the existing memory proof experiment
require_relative "../runtime_machine_memory_proof/runtime_machine_memory_proof"

# =============================================================================
# CompiledProgram: loads a hand-authored .igapp/ artifact
# Implements the PROP-012 RuntimeMachine.load contract
# =============================================================================

module RuntimeMachineMemoryProof
  class CompiledProgram
    attr_reader :program_id, :artifact_hash, :language_version, :format
    attr_reader :contracts, :semantic_ir, :classified_ast
    attr_reader :requirements, :diagnostics

    def self.load_igapp(path)
      dir = Pathname.new(path)
      raise ArgumentError, "Not a directory: #{path}" unless dir.directory?

      manifest        = load_json(dir / "manifest.json")
      semantic_ir     = load_json(dir / "semantic_ir.json")
      classified_ast  = load_json(dir / "classified_ast.json")
      requirements    = load_json(dir / "requirements.json")
      diagnostics     = load_json(dir / "diagnostics.json")

      contracts = {}
      contracts_dir = dir / "contracts"
      if contracts_dir.exist?
        contracts_dir.glob("*.json").sort.each do |f|
          c = load_json(f)
          contracts[c.fetch("contract_id")] = c
        end
      end

      new(
        manifest:       manifest,
        semantic_ir:    semantic_ir,
        classified_ast: classified_ast,
        requirements:   requirements,
        diagnostics:    diagnostics,
        contracts:      contracts
      )
    end

    def self.load_json(path)
      JSON.parse(File.read(path))
    rescue => e
      raise ArgumentError, "Failed to load #{path}: #{e.message}"
    end

    def initialize(manifest:, semantic_ir:, classified_ast:, requirements:, diagnostics:, contracts:)
      @program_id      = manifest.fetch("program_id")
      @artifact_hash   = manifest.fetch("artifact_hash")
      @language_version = manifest.fetch("language_version")
      @format          = manifest.fetch("format")
      @semantic_ir     = semantic_ir
      @classified_ast  = classified_ast
      @requirements    = requirements
      @diagnostics     = diagnostics
      @contracts       = contracts
    end

    def fragment_class
      classified_ast.fetch("fragment_class")
    end

    def oof_count
      classified_ast.fetch("oof_count", 0)
    end

    def required_tbackend_caps
      requirements.fetch("required_tbackend_caps", {})
    end

    def required_caps
      requirements.dig("capabilities", "required_caps") || []
    end

    def effect_kinds
      requirements.dig("capabilities", "effect_kinds") || []
    end

    def dependency_graph
      semantic_ir.fetch("dependency_graph", {})
    end

    def validate!
      errors = []
      errors << "diagnostics is non-empty: #{diagnostics["diagnostics"]}" unless diagnostics.fetch("diagnostics", []).empty?
      errors << "oof_count > 0" if oof_count > 0
      errors << "fragment_class != core for strict load" if fragment_class != "core"
      raise ValidationError, errors.join("; ") unless errors.empty?
    end

    # Evaluate a simple compute contract in-memory (no full evaluator needed for Add)
    def evaluate_contract(contract_id, inputs)
      contract = @contracts.fetch(contract_id) do
        raise ArgumentError, "Unknown contract: #{contract_id}"
      end

      # Walk compute nodes in dependency order
      values = {}
      contract.fetch("input_ports", []).each do |port|
        name = port.fetch("name")
        values[name] = inputs.fetch(name.to_sym) { inputs.fetch(name) }
      end

      contract.fetch("compute_nodes", []).each do |node|
        values[node.fetch("name")] = eval_node(node, values)
      end

      # Return output ports
      outputs = {}
      contract.fetch("output_ports", []).each do |port|
        name = port.fetch("name")
        outputs[name] = values.fetch(name)
      end
      outputs
    end

    private

    def eval_node(node, values)
      expr = node.fetch("expression")
      eval_expr(expr, values)
    end

    def eval_expr(expr, values)
      case expr.fetch("kind")
      when "apply"
        operands = expr.fetch("operands").map { |op| eval_expr(op, values) }
        apply_operator(expr.fetch("operator"), operands)
      when "ref"
        values.fetch(expr.fetch("name"))
      else
        raise ArgumentError, "Unknown expression kind: #{expr["kind"]}"
      end
    end

    def apply_operator(op, operands)
      case op
      when "add" then operands.reduce(:+)
      when "sub" then operands.reduce(:-)
      when "mul" then operands.reduce(:*)
      when "div" then operands.reduce(:/)
      else raise ArgumentError, "Unknown operator: #{op}"
      end
    end
  end

  class ValidationError < StandardError; end

  # =============================================================================
  # Extended RuntimeMachine to support CompiledProgram.load_igapp
  # Adds load_program(compiled_program) method
  # =============================================================================

  class RuntimeMachine
    def load_program(program)
      return failure("runtime.invalid_transition", "load requires booted machine") unless %w[booted loaded].include?(@state)

      # Validate requirements against backend
      caps = @backend.describe.fetch(:capabilities)
      req  = program.required_tbackend_caps
      if req.fetch("read_as_of", false) && !caps.fetch(:read_as_of)
        return failure("constraint.load_requirement_unmet", "TBackend does not support read_as_of")
      end

      # Emit descriptor_observation per contract
      descriptor_refs = {}
      program.contracts.each do |_id, contract_ir|
        desc = packet(
          kind:    "descriptor_observation",
          subject: "contract://#{contract_ir.fetch("contract_id")}",
          payload: {
            contract_id:    contract_ir.fetch("contract_id"),
            name:           contract_ir.fetch("name"),
            fragment_class: contract_ir.fetch("fragment_class"),
            escape_set:     contract_ir.fetch("escape_set", []),
            lifecycle:      contract_ir.fetch("lifecycle"),
            type_signature: contract_ir.fetch("type_signature"),
            artifact_hash:  program.artifact_hash
          },
          temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
          links:    evidence_links
        )
        @backend.append(desc, idempotency_key: desc.id)
        descriptor_refs[contract_ir.fetch("contract_id")] = desc.id
      end

      # Emit ClassifiedAST
      ast_packet = packet(
        kind:    "platform_observation",
        subject: "classified://#{@session_id}/load-1",
        payload: {
          program_id:     program.program_id,
          artifact_hash:  program.artifact_hash,
          fragment_class: program.fragment_class,
          contracts:      program.contracts.values.map { |c| c.fetch("name") },
          oof_count:      program.oof_count
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links:    evidence_links
      )
      @backend.append(ast_packet, idempotency_key: ast_packet.id)

      # Emit LoadReceipt
      load_receipt = packet(
        kind:    "platform_observation",
        subject: "load://#{@session_id}/1",
        payload: {
          program_id:       program.program_id,
          artifact_hash:    program.artifact_hash,
          contracts_loaded: program.contracts.size,
          status:           program.oof_count > 0 ? "partial" : "loaded",
          fragment_report:  ast_packet.id,
          descriptors:      descriptor_refs.values
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links:    evidence_links
      )
      @backend.append(load_receipt)

      @loaded_program = program
      # Use contract_descriptor_ref (singular) for compat with existing checkpoint method
      first_ref = descriptor_refs.values.first
      @loaded_unit = {
        unit_id:                  "loaded-unit/#{program.program_id}",
        program_id:               program.program_id,
        artifact_hash:            program.artifact_hash,
        contract_descriptor_ref:  first_ref,
        contract_descriptor_refs: descriptor_refs,
        compiled_graph_hash:      program.artifact_hash,
        fragment_class:           program.fragment_class
      }

      @state = "loaded"
      {
        status:         load_receipt.payload.fetch("status"),
        program_id:     program.program_id,
        descriptor_refs: descriptor_refs,
        ast_packet:     ast_packet,
        load_receipt:   load_receipt
      }
    end

    # Evaluate using the CompiledProgram's built-in evaluator
    def evaluate_program(contract_id, inputs, as_of:)
      return failure("temporal.as_of_missing", "evaluate requires explicit as_of") unless as_of
      return failure("runtime.invalid_transition", "evaluate requires loaded machine") unless @state == "loaded"
      return failure("runtime.no_program", "no program loaded via load_program") unless @loaded_program

      @state = "evaluating"
      outputs = @loaded_program.evaluate_contract(contract_id, inputs)

      outputs.each do |name, value|
        value_packet = packet(
          kind:    "value_observation",
          subject: "contract://#{contract_id}/#{name}",
          payload: value,
          temporal: { as_of: as_of },
          links:   evidence_links + [link("executed_by", @runtime_contract_ref)]
        )
        @backend.append(value_packet)
        @last_value_packet = value_packet
        @last_result_hash  = value_packet.payload_hash
      end

      eval_receipt = packet(
        kind:    "platform_observation",
        subject: "eval://#{@session_id}/1",
        payload: {
          status:          "ok",
          contract_id:     contract_id,
          output_obs_ids:  @backend.entries.last(outputs.size).map { |e| e.fetch(:packet).id },
          temporal_ctx:    { as_of: as_of }
        },
        temporal: { as_of: as_of },
        links:    evidence_links
      )
      @backend.append(eval_receipt)

      @state = "loaded"
      {
        status:       "ok",
        outputs:      outputs,
        eval_receipt: eval_receipt
      }
    end

    attr_reader :loaded_program
  end
end
