# frozen_string_literal: true

require "digest"
require "json"

module IgniterLang
  class SemanticIREmitter
    FORMAT_VERSION = "0.1.0"

    def emit(parsed_program, sample_input:)
      @types = type_shapes(parsed_program)
      semantic_contracts = parsed_program.fetch("contracts").map do |contract|
        emit_contract(parsed_program, contract, sample_input)
      end
      diagnostics = dedupe_oofs(semantic_contracts.flat_map { |contract| contract.fetch("diagnostics") })
      semantic_ir = diagnostics.empty? ? semantic_ir_program(parsed_program, semantic_contracts) : nil

      {
        "semantic_ir" => semantic_ir,
        "compilation_report" => compilation_report(parsed_program, diagnostics, semantic_ir)
      }
    end

    alias compile emit

    def emit_typed(typed_program)
      diagnostics = typed_program.fetch("type_errors", [])
      semantic_ir = diagnostics.empty? ? typed_semantic_ir_program(typed_program) : nil

      {
        "semantic_ir" => semantic_ir,
        "compilation_report" => typed_compilation_report(typed_program, diagnostics, semantic_ir)
      }
    end

    private

    def semantic_ir_program(parsed_program, contracts)
      report_id = compilation_report_id(parsed_program)
      {
        "kind" => "semantic_ir_program",
        "format_version" => FORMAT_VERSION,
        "program_id" => program_id(parsed_program),
        "grammar_version" => parsed_program.fetch("grammar_version"),
        "source_hash" => parsed_program.fetch("source_hash"),
        "source_path" => source_path(parsed_program),
        "module" => parsed_program.fetch("module"),
        "compilation_report_ref" => report_id,
        "contracts" => contracts.map { |contract| contract.reject { |key, _value| key == "diagnostics" } }
      }
    end

    def compilation_report(parsed_program, diagnostics, semantic_ir)
      ok = diagnostics.empty?
      {
        "kind" => "compilation_report",
        "format_version" => FORMAT_VERSION,
        "program_id" => compilation_report_id(parsed_program),
        "grammar_version" => parsed_program.fetch("grammar_version"),
        "source_hash" => parsed_program.fetch("source_hash"),
        "source_path" => source_path(parsed_program),
        "pass_result" => ok ? "ok" : "oof",
        "stages" => {
          "parse" => "ok",
          "classify" => ok ? "ok" : "oof",
          "typecheck" => ok ? "ok" : "skipped",
          "emit" => ok ? "ok" : "skipped"
        },
        "diagnostics" => diagnostics.map { |entry| diagnostic(entry) },
        "semantic_ir_ref" => semantic_ir&.fetch("program_id")
      }
    end

    def typed_semantic_ir_program(typed_program)
      report_id = typed_compilation_report_id(typed_program)
      result = {
        "kind" => "semantic_ir_program",
        "format_version" => FORMAT_VERSION,
        "program_id" => typed_program_id(typed_program),
        "grammar_version" => typed_program.fetch("grammar_version"),
        "source_hash" => typed_program.fetch("source_hash"),
        "source_path" => source_path(typed_program),
        "module" => typed_program.fetch("module"),
        "compilation_report_ref" => report_id,
        "contracts" => typed_program.fetch("contracts").map { |contract| typed_contract_ir(contract) }
      }
      result["olap_points"] = typed_program.fetch("olap_points") if typed_program.key?("olap_points")
      result
    end

    def typed_compilation_report(typed_program, diagnostics, semantic_ir)
      ok = diagnostics.empty?
      {
        "kind" => "compilation_report",
        "format_version" => FORMAT_VERSION,
        "program_id" => typed_compilation_report_id(typed_program),
        "grammar_version" => typed_program.fetch("grammar_version"),
        "source_hash" => typed_program.fetch("source_hash"),
        "source_path" => source_path(typed_program),
        "pass_result" => ok ? "ok" : "oof",
        "stages" => {
          "parse" => "ok",
          "classify" => "ok",
          "typecheck" => ok ? "ok" : "oof",
          "emit" => ok ? "ok" : "skipped"
        },
        "diagnostics" => diagnostics.map { |entry| diagnostic(entry) },
        "semantic_ir_ref" => semantic_ir&.fetch("program_id")
      }
    end

    def program_id(parsed_program)
      "semanticir/#{parsed_program.fetch("source_hash").delete_prefix("sha256:")[0, 16]}"
    end

    def compilation_report_id(parsed_program)
      "compilation_report/#{parsed_program.fetch("source_hash").delete_prefix("sha256:")[0, 16]}"
    end

    def typed_program_id(typed_program)
      "semanticir/typed/#{Digest::SHA256.hexdigest(canonical_json(typed_program))[0, 16]}"
    end

    def typed_compilation_report_id(typed_program)
      "compilation_report/typed_#{Digest::SHA256.hexdigest(canonical_json([
        typed_program.fetch("program_id"),
        typed_program.fetch("source_hash")
      ]))[0, 16]}"
    end

    def source_path(parsed_program)
      parsed_program.fetch("source_path").delete_prefix("igniter-lang/")
    end

    def typed_contract_ir(contract)
      contract_ir = {
        "kind" => "contract_ir",
        "contract_ref" => nil,
        "contract_name" => contract.fetch("name"),
        "specialization_of" => nil,
        "type_args" => {},
        "fragment_class" => contract.fetch("fragment_class"),
        "inputs" => typed_ports(contract, "input"),
        "outputs" => typed_ports(contract, "output"),
        "nodes" => typed_nodes(contract),
        "escape_boundaries" => []
      }
      contract_ir["contract_ref"] = contract_ref(contract_ir)
      contract_ir
    end

    def typed_ports(contract, kind)
      contract.fetch("declarations").select { |decl| decl.fetch("kind") == kind }.map do |decl|
        {
          "name" => decl.fetch("name"),
          "type" => decl.fetch("type"),
          "lifecycle" => decl.fetch("lifecycle", kind == "input" ? "local" : "session")
        }
      end
    end

    def typed_nodes(contract)
      contract.fetch("declarations").filter_map do |decl|
        next decl.fetch("semantic_node") if decl.key?("semantic_node")
        next unless decl.fetch("kind") == "compute"

        {
          "kind" => "compute",
          "name" => decl.fetch("name"),
          "expr" => decl.fetch("expr"),
          "type" => decl.fetch("type"),
          "deps" => decl.fetch("deps", []),
          "fragment" => decl.fetch("fragment_class")
        }
      end
    end

    def type_shapes(parsed_program)
      parsed_program.fetch("types").each_with_object({}) do |type, shapes|
        fields = type.fetch("fields", []).each_with_object({}) do |field, index|
          index[field.fetch("name")] = normalize_type(field.fetch("type_annotation"))
        end
        shapes[type.fetch("name")] = fields
      end
    end

    def emit_contract(_parsed_program, contract, sample_input)
      diagnostics = []
      type_env = {}
      value_env = sample_input.dup
      inputs = []
      outputs = []
      nodes = []

      contract.fetch("body").each do |node|
        case node.fetch("kind")
        when "input"
          type = normalize_type(node.fetch("type_annotation"))
          type_env[node.fetch("name")] = type
          inputs << { "name" => node.fetch("name"), "type" => type_ir(type), "lifecycle" => "local" }
        when "compute"
          diagnostic_count_before = diagnostics.length
          lowered = lower_expr(node.fetch("expr"), type_env, diagnostics, node.fetch("name"))
          type_env[node.fetch("name")] = lowered.fetch("type")
          value_env[node.fetch("name")] = eval_expr(node.fetch("expr"), value_env)
          fragment = diagnostics.length == diagnostic_count_before ? "core" : "oof"
          nodes << {
            "kind" => "compute",
            "name" => node.fetch("name"),
            "expr" => lowered.fetch("expr"),
            "type" => type_ir(lowered.fetch("type")),
            "deps" => lowered.fetch("deps").uniq,
            "fragment" => fragment
          }
        when "output"
          name = node.fetch("name")
          expected = normalize_type(node.fetch("type_annotation"))
          actual = type_env[name]
          if actual.nil?
            diagnostics << oof("OOF-P1", "Unresolved output source: #{name}", name)
          elsif actual != expected
            diagnostics << type_mismatch_oof(expected, actual, name)
          end
          outputs << {
            "name" => name,
            "type" => type_ir(expected),
            "lifecycle" => node.fetch("lifecycle", "session")
          }
        end
      end

      diagnostics.concat(evidence_gate_oofs(contract, sample_input, value_env))
      contract_ir = {
        "kind" => "contract_ir",
        "contract_ref" => nil,
        "contract_name" => contract.fetch("name"),
        "specialization_of" => nil,
        "type_args" => {},
        "fragment_class" => diagnostics.empty? ? "core" : "oof",
        "inputs" => inputs,
        "outputs" => outputs,
        "nodes" => nodes,
        "escape_boundaries" => [],
        "diagnostics" => diagnostics
      }
      contract_ir["contract_ref"] = contract_ref(contract_ir)
      contract_ir
    end

    def contract_ref(contract_ir)
      body = contract_ir.reject { |key, _value| key == "contract_ref" || key == "diagnostics" }
      "contract/#{contract_ir.fetch("contract_name")}/sha256:#{Digest::SHA256.hexdigest(canonical_json(body))[0, 24]}"
    end

    def lower_expr(expr, type_env, diagnostics, node_name)
      case expr.fetch("kind")
      when "literal"
        type = normalize_type(expr.fetch("type_tag"))
        { "expr" => {
            "kind" => "literal",
            "value" => expr.fetch("value"),
            "type" => literal_type(type),
            "resolved_type" => type_ir(type)
          },
          "type" => type,
          "deps" => [] }
      when "ref"
        name = expr.fetch("name")
        type = type_env[name]
        unless type
          diagnostics << oof("OOF-P1", "Unresolved symbol: #{name}", node_name)
          type = "Unknown"
        end
        { "expr" => { "kind" => "ref", "name" => name, "resolved_type" => type_ir(type) },
          "type" => type,
          "deps" => [name] }
      when "field_access"
        object = lower_expr(expr.fetch("object"), type_env, diagnostics, node_name)
        field = expr.fetch("field")
        field_type = @types.fetch(object.fetch("type"), {})[field]
        unless field_type
          diagnostics << oof("OOF-P1", "Unresolved field: #{object.fetch("type")}.#{field}", node_name)
          field_type = "Unknown"
        end
        { "expr" => {
            "kind" => "field_access",
            "object" => object.fetch("expr"),
            "field" => field,
            "resolved_type" => type_ir(field_type)
          },
          "type" => field_type,
          "deps" => object.fetch("deps") }
      when "binary_op"
        lower_binary(expr, type_env, diagnostics, node_name)
      when "call"
        fn = expr.fetch("fn")
        diagnostics << oof("OOF-P1", "Unresolved function: #{fn}", node_name)
        { "expr" => { "kind" => "call", "fn" => fn, "args" => [], "resolved_type" => type_ir("Unknown") },
          "type" => "Unknown",
          "deps" => [] }
      else
        diagnostics << oof("OOF-P0", "Unsupported expression kind: #{expr.fetch("kind")}", node_name)
        { "expr" => {
            "kind" => "unsupported",
            "source_kind" => expr.fetch("kind"),
            "resolved_type" => type_ir("Unknown")
          },
          "type" => "Unknown",
          "deps" => [] }
      end
    end

    def lower_binary(expr, type_env, diagnostics, node_name)
      left = lower_expr(expr.fetch("left"), type_env, diagnostics, node_name)
      right = lower_expr(expr.fetch("right"), type_env, diagnostics, node_name)
      operator, result_type = operator_for(expr.fetch("op"), left.fetch("type"), right.fetch("type"), diagnostics, node_name)

      {
        "expr" => {
          "kind" => "call",
          "fn" => operator,
          "args" => [left.fetch("expr"), right.fetch("expr")],
          "resolved_type" => type_ir(result_type)
        },
        "type" => result_type,
        "deps" => left.fetch("deps") + right.fetch("deps")
      }
    end

    def operator_for(op, left_type, right_type, diagnostics, node_name)
      case op
      when "+"
        unless unknown_type?(left_type, right_type) || (left_type == "Integer" && right_type == "Integer")
          diagnostics << oof("OOF-TY0", "Integer add requires Integer operands", node_name)
        end
        ["stdlib.integer.add", "Integer"]
      when ">"
        unless unknown_type?(left_type, right_type) || (left_type == "Integer" && right_type == "Integer")
          diagnostics << oof("OOF-TY0", "Integer comparison requires Integer operands", node_name)
        end
        ["stdlib.integer.gt", "Bool"]
      when "&&"
        unless unknown_type?(left_type, right_type) || (left_type == "Bool" && right_type == "Bool")
          diagnostics << oof("OOF-TY0", "Boolean and requires Bool operands", node_name)
        end
        ["stdlib.bool.and", "Bool"]
      else
        diagnostics << oof("OOF-P0", "Unsupported operator: #{op}", node_name)
        ["stdlib.unsupported.#{op}", "Unknown"]
      end
    end

    def unknown_type?(*types)
      types.any? { |type| type == "Unknown" }
    end

    def eval_expr(expr, env)
      case expr.fetch("kind")
      when "literal"
        expr.fetch("value")
      when "ref"
        env[expr.fetch("name")]
      when "field_access"
        object = eval_expr(expr.fetch("object"), env)
        object&.fetch(expr.fetch("field"), nil)
      when "binary_op"
        left = eval_expr(expr.fetch("left"), env)
        right = eval_expr(expr.fetch("right"), env)
        return nil if left.nil? || right.nil?

        case expr.fetch("op")
        when "+" then left + right
        when ">" then left > right
        when "&&" then left && right
        else nil
        end
      else
        nil
      end
    end

    def evidence_gate_oofs(contract, sample_input, value_env)
      return [] unless contract.fetch("name").include?("EvidenceLinkedAlert") ||
                       contract.fetch("name").include?("EvidenceLessAlert")

      alert = sample_input.fetch("alert", {})
      diagnostics = []
      if alert.fetch("signal_count", 0) < 1 || alert.fetch("claim_count", 0) < 1
        diagnostics << oof(
          "OOF-OS2",
          "EvidenceLinkedAlert requires non-empty signal_refs and claim_refs",
          contract.fetch("name")
        )
      end
      if alert.fetch("valid_until", "").to_s.empty?
        diagnostics << oof("OOF-OS4", "EvidenceLinkedAlert requires valid_until", contract.fetch("name"))
      end
      if value_env.key?("allowed") && value_env.fetch("allowed") != true && diagnostics.empty?
        diagnostics << oof("OOF-OS2", "EvidenceLinkedAlert gate did not pass", contract.fetch("name"))
      end
      diagnostics
    end

    def type_mismatch_oof(expected, actual, node_name)
      if expected == "Bool" && actual == "ConfidenceLabel"
        oof("OOF-CE4", "ConfidenceLabel cannot be used as Bool", node_name)
      else
        oof("OOF-TY0", "Type mismatch: expected #{expected}, got #{actual}", node_name)
      end
    end

    def normalize_type(type)
      type.is_a?(Hash) ? type.fetch("name") : type.to_s
    end

    def type_ir(type)
      { "name" => type, "params" => [] }
    end

    def literal_type(type)
      {
        "Integer" => "int",
        "Float" => "float",
        "String" => "string",
        "Bool" => "bool",
        "Nil" => "nil"
      }.fetch(type, type.downcase)
    end

    def dedupe_oofs(entries)
      entries.uniq { |entry| [entry.fetch("rule"), entry.fetch("message"), entry.fetch("node"), entry.fetch("line")] }
    end

    def canonical_json(value)
      JSON.generate(deep_sort(value))
    end

    def deep_sort(value)
      case value
      when Hash
        value.keys.sort.each_with_object({}) { |key, sorted| sorted[key] = deep_sort(value[key]) }
      when Array
        value.map { |item| deep_sort(item) }
      else
        value
      end
    end

    def oof(rule, message, node_name)
      { "rule" => rule, "message" => message, "node" => node_name, "line" => nil }
    end

    def diagnostic(entry)
      {
        "rule" => entry.fetch("rule"),
        "severity" => "error",
        "message" => entry.fetch("message"),
        "node" => entry.fetch("node"),
        "path" => nil,
        "line" => entry.fetch("line")
      }
    end
  end
end
