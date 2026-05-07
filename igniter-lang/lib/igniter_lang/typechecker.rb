# frozen_string_literal: true

require "digest"

module IgniterLang
  class TypeChecker
    DEFAULT_VERSION = "typed-pass-executable-proof-v0"

    def initialize(typechecker_version: DEFAULT_VERSION)
      @typechecker_version = typechecker_version
    end

    def typecheck(classified_program)
      @type_shapes = type_shapes(classified_program)
      typed_contracts = classified_program.fetch("contracts").map do |contract|
        typecheck_contract(contract)
      end

      {
        "kind" => "typed_program",
        "typechecker_version" => @typechecker_version,
        "program_id" => program_id(classified_program),
        "classified_program_id" => classified_program.fetch("program_id"),
        "source_path" => classified_program.fetch("source_path"),
        "source_hash" => classified_program.fetch("source_hash"),
        "grammar_version" => classified_program.fetch("grammar_version"),
        "module" => classified_program.fetch("module"),
        "type_env" => @type_shapes,
        "contracts" => typed_contracts,
        "type_errors" => typed_contracts.flat_map { |contract| contract.fetch("type_errors") },
        "semantic_ir_ref" => nil
      }
    end

    private

    def program_id(classified_program)
      seed = [
        classified_program.fetch("program_id"),
        classified_program.fetch("source_hash"),
        @typechecker_version
      ].join("|")
      "typed_pass/#{Digest::SHA256.hexdigest(seed)[0, 16]}"
    end

    def type_shapes(classified_program)
      classified_program.fetch("type_declarations").each_with_object({}) do |type, shapes|
        shapes[type.fetch("name")] = type.fetch("fields", []).each_with_object({}) do |field, fields|
          fields[field.fetch("name")] = type_ir(normalize_type(field.fetch("type_annotation")))
        end
      end
    end

    def typecheck_contract(classified_contract)
      declared_oofs = classified_contract.fetch("oof_log")
      type_errors = declared_oofs.dup
      symbol_types = {}
      typed_decls = []

      classified_contract.fetch("declarations").each do |decl|
        case decl.fetch("kind")
        when "input"
          type = type_ir(decl.fetch("type_annotation"))
          symbol_types[decl.fetch("name")] = type
          typed_decls << typed_decl(decl, type, nil, [])
        when "read"
          type = type_ir(decl.fetch("type_annotation"))
          symbol_types[decl.fetch("name")] = type
          typed_decls << typed_decl(decl, type, nil, [])
        when "compute"
          typed_expr = infer_expr(decl.fetch("expr"), symbol_types, type_errors, decl.fetch("name"))
          symbol_types[decl.fetch("name")] = typed_expr.fetch("resolved_type")
          typed_decls << typed_decl(decl, typed_expr.fetch("resolved_type"), typed_expr, typed_expr.fetch("deps"))
        when "output"
          expected = type_ir(decl.fetch("type_annotation"))
          actual = symbol_types.fetch(decl.fetch("name"), type_ir("Unknown"))
          if type_name(actual) != type_name(expected) && !blocking_rule_present?(type_errors)
            type_errors << type_mismatch(expected, actual, decl.fetch("name"))
          end
          typed_decls << typed_decl(decl, expected, nil, decl.fetch("deps"))
        end
      end

      status = type_errors.empty? ? "accepted" : "blocked"
      {
        "kind" => "typed_contract",
        "contract_id" => classified_contract.fetch("contract_id"),
        "name" => classified_contract.fetch("name"),
        "status" => status,
        "fragment_class" => classified_contract.fetch("fragment_class"),
        "symbols" => symbol_types.keys.sort.map do |name|
          { "name" => name, "type" => symbol_types.fetch(name), "resolved" => type_name(symbol_types.fetch(name)) != "Unknown" }
        end,
        "declarations" => typed_decls,
        "type_errors" => dedupe_errors(type_errors)
      }
    end

    def typed_decl(decl, type, expr, deps)
      result = {
        "decl_id" => decl.fetch("decl_id"),
        "kind" => decl.fetch("kind"),
        "name" => decl.fetch("name"),
        "fragment_class" => decl.fetch("fragment_class"),
        "type" => type,
        "deps" => deps
      }
      result["expr"] = expr if expr
      result
    end

    def infer_expr(expr, symbol_types, type_errors, node_name)
      case expr.fetch("kind")
      when "literal"
        type = type_ir(expr.fetch("type_tag"))
        typed_expr("literal", type, [], "value" => expr.fetch("value"), "literal_type" => literal_type(type_name(type)))
      when "ref"
        name = expr.fetch("name")
        type = symbol_types.fetch(name, type_ir("Unknown"))
        type_errors << oof("OOF-P1", "Unresolved symbol: #{name}", node_name) if type_name(type) == "Unknown" && !rule_present?(type_errors, "OOF-P1")
        typed_expr("ref", type, [name], "name" => name)
      when "field_access"
        object = infer_expr(expr.fetch("object"), symbol_types, type_errors, node_name)
        object_type = type_name(object.fetch("resolved_type"))
        field_type = @type_shapes.fetch(object_type, {})[expr.fetch("field")] || type_ir("Unknown")
        if type_name(field_type) == "Unknown"
          type_errors << oof("OOF-P1", "Unresolved field: #{object_type}.#{expr.fetch("field")}", node_name)
        end
        typed_expr(
          "field_access",
          field_type,
          object.fetch("deps"),
          "object" => object,
          "field" => expr.fetch("field")
        )
      when "binary_op"
        infer_binary(expr, symbol_types, type_errors, node_name)
      when "call"
        infer_call(expr, symbol_types, type_errors, node_name)
      else
        type_errors << oof("OOF-TY0", "Unsupported expression kind: #{expr.fetch("kind")}", node_name)
        typed_expr("unsupported", type_ir("Unknown"), [], "source_kind" => expr.fetch("kind"))
      end
    end

    def infer_call(expr, symbol_types, type_errors, node_name)
      fn = expr.fetch("fn")
      args = expr.fetch("args")
      case fn
      when "history_at"
        infer_history_at(fn, args, symbol_types, type_errors, node_name)
      when "bihistory_at"
        infer_bihistory_at(fn, args, symbol_types, type_errors, node_name)
      else
        type_errors << oof("OOF-TY0", "Unknown function: #{fn}", node_name)
        typed_expr("call", type_ir("Unknown"), [], "fn" => fn, "args" => [])
      end
    end

    def infer_history_at(fn, args, symbol_types, type_errors, node_name)
      if args.length < 2
        type_errors << oof("OOF-H1", "history_at requires as_of argument", node_name)
        return typed_expr("call", type_ir("Unknown"), [], "fn" => fn, "args" => [])
      end

      history_ref = infer_expr(args[0], symbol_types, type_errors, node_name)
      as_of_ref = infer_expr(args[1], symbol_types, type_errors, node_name)
      unless type_name(as_of_ref.fetch("resolved_type")) == "DateTime" ||
             type_name(as_of_ref.fetch("resolved_type")) == "Unknown"
        type_errors << oof("OOF-BT1", "history_at: as_of must be DateTime, got #{type_name(as_of_ref.fetch("resolved_type"))}", node_name)
      end
      result_type = option_type_from(history_ref.fetch("resolved_type"))
      typed_expr(
        "call",
        result_type,
        history_ref.fetch("deps") + as_of_ref.fetch("deps"),
        "fn" => fn,
        "args" => [history_ref, as_of_ref]
      )
    end

    def infer_bihistory_at(fn, args, symbol_types, type_errors, node_name)
      if args.length < 2
        type_errors << oof("OOF-BT2", "bihistory_at requires valid_time (vt) argument", node_name)
        return typed_expr("call", type_ir("Unknown"), [], "fn" => fn, "args" => [])
      end
      if args.length < 3
        type_errors << oof("OOF-BT3", "bihistory_at requires transaction_time (tt) argument", node_name)
        return typed_expr("call", type_ir("Unknown"), [], "fn" => fn, "args" => [])
      end

      history_ref = infer_expr(args[0], symbol_types, type_errors, node_name)
      vt_ref = infer_expr(args[1], symbol_types, type_errors, node_name)
      tt_ref = infer_expr(args[2], symbol_types, type_errors, node_name)
      [vt_ref, tt_ref].each_with_index do |axis_ref, idx|
        axis_name = idx.zero? ? "valid_time" : "transaction_time"
        unless type_name(axis_ref.fetch("resolved_type")) == "DateTime" ||
               type_name(axis_ref.fetch("resolved_type")) == "Unknown"
          type_errors << oof("OOF-BT4", "bihistory_at: #{axis_name} must be DateTime, got #{type_name(axis_ref.fetch("resolved_type"))}", node_name)
        end
      end
      result_type = option_type_from(history_ref.fetch("resolved_type"))
      typed_expr(
        "call",
        result_type,
        history_ref.fetch("deps") + vt_ref.fetch("deps") + tt_ref.fetch("deps"),
        "fn" => fn,
        "args" => [history_ref, vt_ref, tt_ref]
      )
    end

    def option_type_from(history_type)
      inner = history_type.fetch("params", []).first
      inner_name = inner.is_a?(Hash) ? inner.fetch("name", "Unknown") : (inner || "Unknown")
      { "name" => "Option", "params" => [{ "name" => inner_name, "params" => [] }] }
    end

    def infer_binary(expr, symbol_types, type_errors, node_name)
      left = infer_expr(expr.fetch("left"), symbol_types, type_errors, node_name)
      right = infer_expr(expr.fetch("right"), symbol_types, type_errors, node_name)
      operator, result_type = operator_type(expr.fetch("op"), left.fetch("resolved_type"), right.fetch("resolved_type"), type_errors, node_name)
      typed_expr(
        "call",
        result_type,
        left.fetch("deps") + right.fetch("deps"),
        "fn" => operator,
        "args" => [left, right]
      )
    end

    def operator_type(op, left, right, type_errors, node_name)
      left_name = type_name(left)
      right_name = type_name(right)
      case op
      when "+"
        type_errors << type_mismatch(type_ir("Integer"), type_ir("#{left_name}+#{right_name}"), node_name) unless unknown?(left, right) || left_name == "Integer" && right_name == "Integer"
        ["stdlib.integer.add", type_ir("Integer")]
      when ">"
        type_errors << type_mismatch(type_ir("Integer"), type_ir("#{left_name}+#{right_name}"), node_name) unless unknown?(left, right) || left_name == "Integer" && right_name == "Integer"
        ["stdlib.integer.gt", type_ir("Bool")]
      when "&&"
        type_errors << type_mismatch(type_ir("Bool"), type_ir("#{left_name}+#{right_name}"), node_name) unless unknown?(left, right) || left_name == "Bool" && right_name == "Bool"
        ["stdlib.bool.and", type_ir("Bool")]
      else
        type_errors << oof("OOF-TY0", "Unsupported operator: #{op}", node_name)
        ["stdlib.unsupported.#{op}", type_ir("Unknown")]
      end
    end

    def typed_expr(kind, type, deps, extra)
      { "kind" => kind }.merge(extra).merge("resolved_type" => type, "deps" => deps.uniq)
    end

    def type_ir(annotation)
      return annotation.dup if annotation.is_a?(Hash) && annotation.key?("name")

      name = annotation.is_a?(Hash) ? annotation.fetch("name", "Unknown") : annotation.to_s
      params = annotation.is_a?(Hash) ? annotation.fetch("params", []).map { |p| type_ir(p) } : []
      { "name" => name, "params" => params }
    end

    def type_name(type)
      type.fetch("name")
    end

    def normalize_type(type)
      type.is_a?(Hash) ? type.fetch("name") : type.to_s
    end

    def literal_type(name)
      {
        "Integer" => "int",
        "Float" => "float",
        "String" => "string",
        "Bool" => "bool",
        "Nil" => "nil"
      }.fetch(name, name.downcase)
    end

    def unknown?(*types)
      types.any? { |type| type_name(type) == "Unknown" }
    end

    def type_mismatch(expected, actual, node)
      oof("OOF-TY0", "Type mismatch: expected #{type_name(expected)}, got #{type_name(actual)}", node)
    end

    def oof(rule, message, node_name)
      { "rule" => rule, "message" => message, "node" => node_name, "line" => nil }
    end

    def rule_present?(errors, rule)
      errors.any? { |entry| entry.fetch("rule") == rule }
    end

    def blocking_rule_present?(errors)
      %w[OOF-P1 OOF-CE4 OOF-OS2 OOF-H1 OOF-BT2 OOF-BT3 OOF-BT4].any? { |rule| rule_present?(errors, rule) }
    end

    def dedupe_errors(errors)
      errors.uniq { |entry| [entry.fetch("rule"), entry.fetch("message"), entry.fetch("node"), entry.fetch("line")] }
    end
  end

  Typechecker = TypeChecker
end
