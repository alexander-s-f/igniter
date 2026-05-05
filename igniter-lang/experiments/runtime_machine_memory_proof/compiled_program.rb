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

    def has_window?
      requirements.dig("lifecycle", "has_window") || false
    end

    def temporal_windows
      (requirements.dig("temporal", "windows") || [])
    end

    def boundary_descriptors
      semantic_ir.fetch("boundary_descriptors", [])
    end

    def dependency_graph
      semantic_ir.fetch("dependency_graph", {})
    end

    def validate!
      errors = []
      errors << "diagnostics is non-empty: #{diagnostics["diagnostics"]}" unless diagnostics.fetch("diagnostics", []).empty?
      errors << "oof_count > 0" if oof_count > 0
      raise ValidationError, errors.join("; ") unless errors.empty?
    end

    # Evaluate a contract — supports both pure compute and window read nodes
    # backend: MemoryTBackend for tbackend_read nodes
    # inputs must be a Hash with symbol or string keys
    def evaluate_contract(contract_id, inputs, backend: nil, as_of: nil)
      contract = @contracts.fetch(contract_id) do
        raise ArgumentError, "Unknown contract: #{contract_id}"
      end

      values = {}
      contract.fetch("input_ports", []).each do |port|
        name = port.fetch("name")
        values[name] = inputs.fetch(name.to_sym) { inputs.fetch(name) }
      end

      contract.fetch("compute_nodes", []).each do |node|
        values[node.fetch("name")] = eval_node(node, values, backend: backend, as_of: as_of)
      end

      outputs = {}
      contract.fetch("output_ports", []).each do |port|
        name = port.fetch("name")
        outputs[name] = values[name]
      end
      outputs
    end

    # Temporal window for a contract (first one)
    def contract_window(contract_id)
      contract = @contracts[contract_id]
      return nil unless contract
      contract.fetch("temporal_window", nil)
    end

    private

    def eval_node(node, values, backend:, as_of:)
      expr = node.fetch("expression")
      eval_expr(expr, values, backend: backend, as_of: as_of)
    end

    def eval_expr(expr, values, backend:, as_of:)
      case expr.fetch("kind")
      when "apply"
        operands = expr.fetch("operands").map { |op| eval_expr(op, values, backend: backend, as_of: as_of) }
        apply_operator(expr.fetch("operator"), operands)
      when "ref"
        values.fetch(expr.fetch("name"))
      when "tbackend_read"
        raise ArgumentError, "tbackend_read requires a backend" unless backend
        raise ArgumentError, "tbackend_read requires as_of" unless as_of
        subject = build_subject(expr.fetch("subject_template"), values)
        backend.read(subject: subject, as_of: as_of)&.payload
      else
        raise ArgumentError, "Unknown expression kind: #{expr["kind"]}"
      end
    end

    def build_subject(template, values)
      template.gsub(/\{(\w+)\}/) { values[$1] || values[$1.to_sym] }
    end

    def apply_operator(op, operands)
      case op
      when "add"            then operands.reduce(:+)
      when "sub"            then operands.reduce(:-)
      when "mul"            then operands.reduce(:*)
      when "div"            then operands.reduce(:/)
      when "compute_slots"  then compute_slots(*operands)
      when "build_snapshot" then build_snapshot(*operands)
      else raise ArgumentError, "Unknown operator: #{op}"
      end
    end

    # Computes available time slots from geo_signals and schedule
    # geo_signals: Array of { "hour" => 0..23, "signal" => "available"|"busy" }
    # schedule:    { "working_hours" => [start_h, end_h], "day_off" => bool }
    def compute_slots(geo_signals, schedule)
      return [] if schedule.nil? || schedule.fetch("day_off", false)

      working = schedule.fetch("working_hours", [8, 17])
      start_h, end_h = working[0], working[1]

      signals_by_hour = {}
      Array(geo_signals).each do |sig|
        signals_by_hour[sig.fetch("hour")] = sig.fetch("signal")
      end

      (start_h...end_h).map do |hour|
        status = signals_by_hour.fetch(hour, "available")
        { "hour" => hour, "status" => status }
      end
    end

    # Build an AvailabilitySnapshot from computed slots
    def build_snapshot(slots, technician_id, date)
      available_count = Array(slots).count { |s| s.fetch("status") == "available" }
      {
        "technician_id"   => technician_id,
        "date"            => date,
        "available_slots" => slots,
        "available_count" => available_count,
        "snapshot_at"     => date
      }
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
      # Pass backend and as_of for tbackend_read nodes
      outputs = @loaded_program.evaluate_contract(contract_id, inputs, backend: @backend, as_of: as_of)

      lifecycle = @loaded_program.has_window? ? "window" : "session"

      outputs.each do |name, value|
        next if value.nil?
        lc = name == "snapshot" ? "durable" : lifecycle
        value_packet = packet(
          kind:    "value_observation",
          subject: "contract://#{contract_id}/#{name}",
          payload: value,
          temporal: { as_of: as_of, lifecycle: lc },
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
          status:         "ok",
          contract_id:    contract_id,
          output_obs_ids: @backend.entries.last(outputs.compact.size).map { |e| e.fetch(:packet).id },
          temporal_ctx:   { as_of: as_of }
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

    # Emit a BoundaryReceipt for a window close (PROP-010 DR-2)
    # window_name: String
    # period:      { from: TimeRef, to: TimeRef }
    # summary_ref: ObsId of the snapshot observation
    # detail_obs_ids: Array[ObsId] of raw window observations
    def emit_boundary_receipt(window_name:, period:, summary_obs_id:, detail_obs_ids:, as_of:)
      detail_hash = Canonical.hash(detail_obs_ids.sort)
      receipt = packet(
        kind:    "receipt_observation",
        subject: "boundary://#{window_name}",
        payload: {
          window_name:   window_name,
          boundary_key:  nil,
          period:        period,
          summary_ref:   summary_obs_id,
          detail_count:  detail_obs_ids.size,
          detail_hash:   detail_hash
        },
        temporal: { as_of: as_of, lifecycle: "audit" },
        links:    evidence_links + [link("materializes", summary_obs_id, required: true)]
      )
      @backend.append(receipt)
      receipt
    end

    # Emit a window snapshot — stores the snapshot payload and returns the obs
    def emit_window_snapshot(window_name:, snapshot_payload:, as_of:)
      snap = packet(
        kind:    "fact_observation",
        subject: "snapshot://#{window_name}",
        payload: snapshot_payload,
        temporal: { as_of: as_of, lifecycle: "durable" },
        links:   evidence_links
      )
      @backend.append(snap)
      snap
    end

    attr_reader :loaded_program
  end
end
