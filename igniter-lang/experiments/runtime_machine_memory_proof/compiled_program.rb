#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"

# Load the existing memory proof experiment
require_relative "../runtime_machine_memory_proof/runtime_machine_memory_proof"

# Slice 2: direct-require SemanticIRExpressionEvaluator for proof RuntimeMachine if_expr consumer.
# Authorization: S3-R201-C1-A
# Boundary: direct-require-only; root require lib/igniter_lang.rb remains unchanged.
require_relative "../../lib/igniter_lang/semanticir_expression_evaluator"

# =============================================================================
# CompiledProgram: loads a hand-authored .igapp/ artifact
# Implements the PROP-012 RuntimeMachine.load contract
# =============================================================================

module RuntimeMachineMemoryProof
  module CanonicalStdlibRegistry
    PRE_RESOLUTION_OPERATORS = ["stdlib.numeric.add"].freeze
    EXECUTABLE_OPERATORS = [
      "stdlib.integer.add",
      "stdlib.float.add",
      "stdlib.decimal.add",
      "stdlib.integer.gt",
      "stdlib.bool.and",
      "fold",
      "map",
      "filter",
      "count",
      "or_else"
    ].freeze

    module_function

    def registry_operator?(operator)
      EXECUTABLE_OPERATORS.include?(operator) ||
        PRE_RESOLUTION_OPERATORS.include?(operator) ||
        operator.start_with?("stdlib.")
    end

    def call(operator, operands)
      reject_pre_resolution_operator!(operator)

      case operator
      when "stdlib.integer.add"
        require_all!(operator, operands, Integer)
        operands.reduce(0, :+)
      when "stdlib.float.add"
        require_all!(operator, operands, Float)
        operands.reduce(0.0, :+)
      when "stdlib.decimal.add"
        operands.reduce(:+)
      when "stdlib.integer.gt"
        raise ArgumentError, "stdlib.integer.gt expects 2 operands" unless operands.length == 2

        operands.fetch(0) > operands.fetch(1)
      when "stdlib.bool.and"
        operands.all? { |operand| operand == true }
      when "fold"
        collection, initial, reducer = operands
        Array(collection).reduce(initial) { |acc, item| call(reducer, [acc, item]) }
      when "map"
        collection, spec = operands
        Array(collection).map { |item| call(spec.fetch("operator"), [item, spec.fetch("arg")]) }
      when "filter"
        collection, spec = operands
        Array(collection).select { |item| matches_filter?(item, spec) }
      when "count"
        Array(operands.fetch(0)).length
      when "or_else"
        value, fallback = operands
        value.nil? ? fallback : value
      else
        raise ArgumentError, "Unknown stdlib operator: #{operator}"
      end
    end

    def reject_pre_resolution_operator!(operator)
      return unless PRE_RESOLUTION_OPERATORS.include?(operator)

      raise ArgumentError, "#{operator} is pre-resolution only; runtime requires a monomorphic stdlib operator"
    end

    def require_all!(operator, operands, klass)
      return if operands.all? { |operand| operand.is_a?(klass) }

      raise TypeError, "#{operator} expected #{klass}"
    end

    def matches_filter?(item, spec)
      case spec.fetch("predicate")
      when "truthy"
        !!item
      when "field_equals"
        item.fetch(spec.fetch("field")) == spec.fetch("value")
      else
        raise ArgumentError, "Unknown filter predicate: #{spec.fetch("predicate")}"
      end
    end
  end

  class CompiledProgram
    attr_reader :program_id, :artifact_hash, :language_version, :format
    attr_reader :manifest, :compilation_report, :semantic_ir_program, :specialization_manifest
    attr_reader :contracts, :semantic_ir, :classified_ast
    attr_reader :requirements, :diagnostics, :schema_descriptor

    def self.load_igapp(path)
      dir = Pathname.new(path)
      raise ArgumentError, "Not a directory: #{path}" unless dir.directory?

      manifest        = load_json(dir / "manifest.json")
      compilation_report = load_json_if_present(dir / "compilation_report.json")
      semantic_ir_program = load_json_if_present(dir / "semantic_ir_program.json")
      semantic_ir     = semantic_ir_program ? nil : load_json(dir / "semantic_ir.json")
      classified_ast  = load_json(dir / "classified_ast.json")
      requirements    = load_json(dir / "requirements.json")
      diagnostics     = load_json(dir / "diagnostics.json")
      specialization_manifest = if manifest.key?("specialization_manifest_ref")
                                  load_json(dir / manifest.fetch("specialization_manifest_ref"))
                                end

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
        compilation_report: compilation_report,
        semantic_ir_program: semantic_ir_program,
        semantic_ir:    semantic_ir,
        classified_ast: classified_ast,
        requirements:   requirements,
        diagnostics:    diagnostics,
        specialization_manifest: specialization_manifest,
        contracts:      contracts
      )
    end

    def self.load_json(path)
      JSON.parse(File.read(path))
    rescue => e
      raise ArgumentError, "Failed to load #{path}: #{e.message}"
    end

    def self.load_json_if_present(path)
      return nil unless path.exist?

      load_json(path)
    end

    def initialize(manifest:, semantic_ir:, classified_ast:, requirements:, diagnostics:, contracts:,
                   compilation_report: nil, semantic_ir_program: nil,
                   specialization_manifest: nil)
      @manifest         = manifest
      @program_id       = manifest.fetch("program_id")
      @artifact_hash    = manifest.fetch("artifact_hash")
      @language_version = manifest.fetch("language_version")
      @format           = manifest.fetch("format")
      @compilation_report = compilation_report
      @semantic_ir_program = semantic_ir_program
      @specialization_manifest = specialization_manifest
      @classified_ast   = classified_ast
      @requirements     = requirements
      @diagnostics      = diagnostics
      @contracts        = contracts
      @semantic_ir      = semantic_ir || build_semantic_ir_summary(semantic_ir_program, contracts)

      # PROP-017: schema descriptor — built from manifest + contracts
      @schema_descriptor = build_schema_descriptor(manifest)
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
      validate_prop0191_artifacts(errors)
      validate_manifest_contracts(errors)
      validate_specialization_manifest(errors)
      validate_metadata_only_templates(errors)
      raise ValidationError, errors.join("; ") unless errors.empty?
    end

    # PROP-017: schema_version from manifest ("0.0.0" if absent)
    def schema_version
      @schema_descriptor.fetch("schema_version")
    end

    # PROP-017: schema_fingerprint over observable surface only
    # Covers: input_ports, output_ports, type_env, trait_bounds (sorted)
    def schema_fingerprint
      @schema_descriptor.fetch("schema_fingerprint")
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

    def build_semantic_ir_summary(program, contracts)
      return nil unless program

      {
        "program_id" => program.fetch("program_id"),
        "axiom_version" => "1.0.0",
        "grammar_version" => program.fetch("grammar_version"),
        "source_hash" => program.fetch("source_hash"),
        "semantic_ir_ref" => program.fetch("program_id"),
        "compilation_report_ref" => program.fetch("compilation_report_ref"),
        "contracts" => contracts.values.map do |contract|
          {
            "contract_id" => contract.fetch("contract_id"),
            "name" => contract.fetch("name"),
            "fragment_class" => contract.fetch("fragment_class"),
            "escape_set" => contract.fetch("escape_set", []),
            "input_ports" => contract.fetch("input_ports", []).map { |port| "#{port.fetch("name")}:#{port.fetch("type_tag")}" },
            "output_ports" => contract.fetch("output_ports", []).map { |port| "#{port.fetch("name")}:#{port.fetch("type_tag")}" },
            "compute_nodes" => contract.fetch("compute_nodes", []).map { |node| node.fetch("node_id") },
            "lifecycle" => contract.fetch("lifecycle")
          }
        end.sort_by { |contract| contract.fetch("contract_id") },
        "dependency_graph" => dependency_graph_from_contracts(contracts),
        "evaluation_targets" => contracts.values.flat_map do |contract|
          contract.fetch("output_ports", []).map do |port|
            {
              "name" => port.fetch("name"),
              "contract_id" => contract.fetch("contract_id"),
              "output_ports" => [port.fetch("name")],
              "as_projection" => nil
            }
          end
        end,
        "temporal_requirements" => requirements.fetch("temporal", {}),
        "lifecycle_requirements" => requirements.fetch("lifecycle", {}),
        "capability_requirements" => requirements.fetch("capabilities", {}),
        "effect_declarations" => requirements.fetch("effects", []),
        "ffi_requirements" => requirements.fetch("ffi", []),
        "projection_descriptors" => [],
        "boundary_descriptors" => []
      }
    end

    def dependency_graph_from_contracts(contracts)
      nodes = []
      edges = []
      contracts.values.each do |contract|
        contract.fetch("input_ports", []).each { |port| nodes << "input:#{port.fetch("name")}" }
        contract.fetch("compute_nodes", []).each do |node|
          nodes << node.fetch("node_id")
          node.fetch("dependencies", []).each do |dep|
            edges << { "from" => dep, "to" => node.fetch("node_id"), "kind" => "data" }
          end
        end
        contract.fetch("output_ports", []).each do |port|
          nodes << "output:#{port.fetch("name")}"
          edges << { "from" => "node_#{port.fetch("name")}", "to" => "output:#{port.fetch("name")}", "kind" => "data" }
        end
      end
      { "nodes" => nodes.uniq.sort, "edges" => edges.sort_by { |edge| [edge.fetch("from"), edge.fetch("to")] } }
    end

    # PROP-017: Build schema descriptor from manifest + loaded contracts.
    # schema_fingerprint covers ONLY the observable surface (ports + type_env + trait_bounds).
    # It is NOT the artifact_hash (which covers full implementation).
    def build_schema_descriptor(manifest)
      schema_version = manifest.fetch("schema_version", "0.0.0")

      # Build stable surface from all contracts' input/output ports
      port_surface = @contracts.values.flat_map do |c|
        inputs  = c.fetch("input_ports",  []).map { |p| { "dir" => "in",  "name" => p["name"], "type_tag" => p["type_tag"], "lifecycle" => p["lifecycle"] } }
        outputs = c.fetch("output_ports", []).map { |p| { "dir" => "out", "name" => p["name"], "type_tag" => p["type_tag"], "lifecycle" => p["lifecycle"] } }
        inputs + outputs
      end.sort_by { |p| "#{p["dir"]}:#{p["name"]}" }

      # Type environment: all referenced type names (sorted)
      type_env = @contracts.values.flat_map do |c|
        ports = c.fetch("input_ports", []) + c.fetch("output_ports", [])
        ports.map { |p| p["type_tag"] }
      end.uniq.sort

      # Trait bounds: from schema_descriptor in manifest if present
      trait_bounds = manifest.fetch("schema_descriptor", {}).fetch("trait_bounds", [])

      fingerprint_payload = {
        "schema_version" => schema_version,
        "port_surface"   => port_surface,
        "type_env"       => type_env,
        "trait_bounds"   => trait_bounds
      }
      fingerprint = "sha256:#{Digest::SHA256.hexdigest(JSON.generate(fingerprint_payload))}"

      {
        "schema_version"     => schema_version,
        "schema_fingerprint" => fingerprint,
        "port_surface"       => port_surface,
        "type_env"           => type_env,
        "trait_bounds"       => trait_bounds,
        "migrations"         => manifest.fetch("schema_descriptor", {}).fetch("migrations", [])
      }
    end

    def eval_node(node, values, backend:, as_of:)
      expr = node.fetch("expression")
      eval_expr(expr, values, backend: backend, as_of: as_of)
    end

    def eval_expr(expr, values, backend:, as_of:)
      case expr.fetch("kind")
      when "if_expr"
        # Slice 2 adapter: delegate if_expr lazy selection to SemanticIRExpressionEvaluator.
        # The external_evaluator callback routes selected branches of unsupported kinds
        # (apply, field_access, tbackend_read) back to this method, keeping ownership here.
        # - apply, field_access, tbackend_read remain proof RuntimeMachine-local.
        # - external_evaluator is never called for the non-selected branch (evaluator guarantee).
        # - external_evaluator exceptions propagate unchanged (not wrapped).
        # Authorization: S3-R201-C1-A
        ext_ev = ->(sub_expr, sub_vals) { eval_expr(sub_expr, sub_vals, backend: backend, as_of: as_of) }
        if_expr_evaluator.evaluate(expr, values, external_evaluator: ext_ev)
      when "apply"
        operands = expr.fetch("operands").map { |op| eval_expr(op, values, backend: backend, as_of: as_of) }
        apply_operator(expr.fetch("operator"), operands)
      when "field_access"
        object = eval_expr(expr.fetch("object"), values, backend: backend, as_of: as_of)
        field = expr.fetch("field")
        unless object.respond_to?(:fetch)
          raise ArgumentError, "field_access requires object value for #{field}"
        end
        object.fetch(field) { object.fetch(field.to_sym) }
      when "literal"
        expr.fetch("value")
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

    # Lazy-initialized SemanticIRExpressionEvaluator instance for if_expr delegation.
    # Slice 2 adapter — stateless evaluator instance shared across evaluate_contract calls.
    def if_expr_evaluator
      @if_expr_evaluator ||= IgniterLang::SemanticIRExpressionEvaluator.new
    end

    def build_subject(template, values)
      template.gsub(/\{(\w+)\}/) { values[$1] || values[$1.to_sym] }
    end

    def apply_operator(op, operands)
      return CanonicalStdlibRegistry.call(op, operands) if CanonicalStdlibRegistry.registry_operator?(op)

      case op
      when "add"            then raise ArgumentError, "Legacy operator add is not executable; use a monomorphic stdlib operator"
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

    def validate_manifest_contracts(errors)
      manifest_contracts = manifest.fetch("contracts", @contracts.keys)
      contract_ids = @contracts.keys.sort
      errors << "manifest.contracts does not match contract files" unless manifest_contracts.sort == contract_ids

      semantic_contract_ids = semantic_ir.fetch("contracts", []).map do |contract|
        contract.fetch("contract_id")
      end.sort
      return if semantic_contract_ids.empty? || semantic_contract_ids == contract_ids

      errors << "semantic_ir.contracts does not match contract files"
    end

    def validate_prop0191_artifacts(errors)
      return unless semantic_ir_program

      errors << "compilation_report.json missing for PROP-019.1 artifact" unless compilation_report
      errors << "semantic_ir_program.kind is not semantic_ir_program" unless semantic_ir_program.fetch("kind", nil) == "semantic_ir_program"
      errors << "manifest.semantic_ir_ref does not match semantic_ir_program.program_id" unless manifest.fetch("semantic_ir_ref", nil) == semantic_ir_program.fetch("program_id")
      errors << "manifest.compilation_report_ref does not match semantic_ir_program.compilation_report_ref" unless manifest.fetch("compilation_report_ref", nil) == semantic_ir_program.fetch("compilation_report_ref")

      if compilation_report
        errors << "compilation_report.pass_result is not ok" unless compilation_report.fetch("pass_result", nil) == "ok"
        errors << "compilation_report.semantic_ir_ref does not match semantic_ir_program.program_id" unless compilation_report.fetch("semantic_ir_ref", nil) == semantic_ir_program.fetch("program_id")
        errors << "semantic_ir_program.compilation_report_ref does not match compilation_report.program_id" unless semantic_ir_program.fetch("compilation_report_ref") == compilation_report.fetch("program_id")
      end

      semantic_contract_ids = semantic_ir_program.fetch("contracts", []).map { |contract| contract.fetch("contract_name") }.sort
      contract_ids = contracts.keys.sort
      errors << "semantic_ir_program.contracts does not match contract files" unless semantic_contract_ids == contract_ids

      if semantic_ir_program.fetch("contracts", []).any? { |contract| contract.fetch("fragment_class", nil) == "oof" }
        errors << "semantic_ir_program contains OOF contract"
      end
    end

    def validate_specialization_manifest(errors)
      return unless manifest.key?("specialization_manifest_ref")

      unless specialization_manifest
        errors << "specialization_manifest_ref is present but manifest was not loaded"
        return
      end

      emitted_contract_ids = specialization_manifest.fetch("specializations", []).map do |item|
        item.fetch("emitted_contract_id")
      end.sort
      contract_ids = @contracts.keys.sort
      errors << "specialization_manifest emitted_contract_id set does not match loadable contracts" unless emitted_contract_ids == contract_ids
    end

    def validate_metadata_only_templates(errors)
      metadata_only_templates = manifest.fetch("metadata_only_templates", [])
      loaded_metadata_templates = metadata_only_templates.select { |contract_id| @contracts.key?(contract_id) }
      errors << "metadata_only_templates are loadable: #{loaded_metadata_templates.join(", ")}" unless loaded_metadata_templates.empty?

      generic_templates = classified_ast.fetch("generic_templates", [])
      loadable_templates = generic_templates.select { |template| template.fetch("loadable", true) }
      errors << "generic_templates must be metadata-only" unless loadable_templates.empty?

      loadable_contracts = classified_ast.fetch("loadable_contracts", nil)
      return unless loadable_contracts

      return if loadable_contracts.sort == @contracts.keys.sort

      errors << "classified_ast.loadable_contracts does not match contract files"
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

      begin
        program.validate! if program.respond_to?(:validate!)
      rescue => e
        return failure(
          "runtime.load_validation_failed",
          "load artifact validation failed",
          context: { error: "#{e.class}: #{e.message}" }
        )
      end

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

      @loaded_schema_descriptor = Canonical.normalize(program.schema_descriptor)
      migration_descriptor_refs_by_id = emit_migration_descriptors(@loaded_schema_descriptor.fetch("migrations", []))
      migration_descriptor_refs = if migration_descriptor_refs_by_id.respond_to?(:values)
                                    migration_descriptor_refs_by_id.values
                                  else
                                    Array(migration_descriptor_refs_by_id)
                                  end

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
          descriptors:      descriptor_refs.values + migration_descriptor_refs,
          migration_descriptor_refs: migration_descriptor_refs,
          migration_descriptor_refs_by_id: migration_descriptor_refs_by_id
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
        fragment_class:           program.fragment_class,
        schema_version:           @loaded_schema_descriptor.fetch("schema_version"),
        schema_fingerprint:       @loaded_schema_descriptor.fetch("schema_fingerprint"),
        migration_descriptor_refs:       migration_descriptor_refs,
        migration_descriptor_refs_by_id: migration_descriptor_refs_by_id
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
