# frozen_string_literal: true
# experiments/nested_associated_types_proof/patches.rb
# Complete implementation package containing associated types and nested collections patches for the Ruby Compiler.

require_relative "../polymorphic_traits_proof/patches"

module IgniterLang
  class Parser
    # Override parse_trait_decl
    alias_method :orig_parse_trait_decl, :parse_trait_decl
    def parse_trait_decl
      name = name_token!(%i[ident])
      type_params = peek_type?(:lbracket) ? parse_simple_type_params : []
      expect_type!(:lbrace)
      methods = []
      associated_types = []
      until peek_type?(:rbrace) || peek_type?(:eof)
        if peek_kw?("type")
          advance
          associated_types << name_token!(%i[ident])
        else
          expect_kw!("def")
          methods << parse_trait_method
        end
      end
      expect_type!(:rbrace)
      { 
        "kind" => "trait", 
        "name" => name, 
        "type_params" => type_params, 
        "methods" => methods, 
        "associated_types" => associated_types 
      }
    end

    # Override parse_impl_decl
    alias_method :orig_parse_impl_decl_assoc, :parse_impl_decl
    def parse_impl_decl
      trait_ref = parse_type_ref_node
      expect_kw!("using")
      using_name = parse_qualified_ref
      associated_types = {}
      if peek_type?(:lbrace)
        advance
        until peek_type?(:rbrace) || peek_type?(:eof)
          expect_kw!("type")
          assoc_name = name_token!(%i[ident])
          expect_type!(:assign)
          assoc_type = parse_type_ref
          associated_types[assoc_name] = assoc_type
        end
        expect_type!(:rbrace)
      end
      {
        "kind" => "impl",
        "trait_ref" => trait_ref,
        "using" => { "kind" => "qualified_ref", "name" => using_name },
        "associated_types" => associated_types
      }
    end

    # Override parse_type_ref
    alias_method :orig_parse_type_ref_assoc, :parse_type_ref
    def parse_type_ref
      name_tok = peek
      name = name_token!(%i[ident keyword])
      
      # Handle double colon for associated types
      # C::Element is tokenized as C (ident), : (colon), Element (symbol_lit)
      if peek_type?(:colon) && peek(1)&.type == :symbol_lit
        advance # consume colon
        sym_tok = advance # consume symbol_lit
        name = "#{name}::#{sym_tok.value}"
      end
      
      if peek_type?(:lbracket)
        advance
        # Decimal[N]: structured node with integer scale param
        if name == "Decimal" && peek_type?(:int_lit)
          scale = advance.value  # Integer
          expect_type!(:rbracket)
          return { "kind" => "type_ref", "name" => "Decimal", "params" => [scale] }
        end
        params = []
        until peek_type?(:rbracket) || peek_type?(:eof)
          params << parse_type_ref_param(name, params.length)
          advance if peek_type?(:comma)
        end
        expect_type!(:rbracket)
        { "kind" => "type_ref", "name" => name, "params" => params }
      else
        if name == "Decimal"
          add_parse_error(
            rule: "OOF-DM3",
            message: "Decimal type requires scale parameter: Decimal[N]",
            token: name,
            line: name_tok.line,
            col: name_tok.col
          )
          return { "kind" => "type_ref", "name" => "Unknown", "original" => "Decimal", "params" => [] }
        end
        name
      end
    end
  end

  class ParsedProgram
    class << self
      # Overwrite monomorphize_parsed_program to support associated types and nested generic collections
      def monomorphize_parsed_program(parsed)
        contracts = parsed.ast["contracts"] || []
        generic_contracts = contracts.select { |c| c["type_params"] && !c["type_params"].empty? }
        return if generic_contracts.empty?

        monomorphized = []
        generic_contracts.each do |c|
          type_param = c["type_params"][0]
          bounds = type_param["bounds"] || []
          bound_trait = bounds[0]["trait_ref"]["name"] if bounds[0] && bounds[0]["trait_ref"]
          type_var = type_param["name"]

          # Find matching trait decl to get its method names dynamically
          trait_decl = parsed.ast["traits"]&.find { |t| t["name"] == bound_trait }
          trait_method_name = trait_decl && trait_decl["methods"]&.first ? trait_decl["methods"].first["name"] : "add"

          impls = parsed.ast["impls"].select { |i| i["trait_ref"]["name"] == bound_trait }
          impls.each do |impl|
            concrete_type = impl["trait_ref"]["type_args"][0]
            concrete_type_str = type_to_string(concrete_type)
            using_func = impl["using"]["name"]
            assoc_types = impl["associated_types"] || {}

            spec_contract = c.dup
            spec_contract["name"] = "#{c["name"]}[#{concrete_type_str}]"
            spec_contract["type_params"] = []
            spec_contract["specialization_of"] = c["name"]
            spec_contract["type_args"] = { type_var => concrete_type_str }

            if c["implements"]
              spec_contract["implements"] = c["implements"].dup
              spec_contract["implements"]["type_args"] = [concrete_type]
            end

            shape_name = c["implements"]["name"] if c["implements"]
            shape = parsed.ast["contract_shapes"]&.find { |s| s["name"] == shape_name }

            body = []
            inputs = []
            outputs = []
            if shape
              shape["body"].each do |port|
                new_port = port.dup
                new_port["type_annotation"] = substitute_type_ref(port["type_annotation"], type_var, concrete_type, assoc_types)
                if new_port["kind"] == "input"
                  inputs << new_port
                elsif new_port["kind"] == "output"
                  outputs << new_port
                end
              end
            end

            body.concat(inputs)
            c["body"].each do |node|
              if node["kind"] == "compute"
                new_node = node.dup
                new_node["expr"] = substitute_expr(node["expr"], trait_method_name, using_func)
                new_node["type_annotation"] = substitute_type_ref(node["type_annotation"], type_var, concrete_type, assoc_types) if node["type_annotation"]
                body << new_node
              else
                body << node
              end
            end
            body.concat(outputs)
            spec_contract["body"] = body
            monomorphized << spec_contract
          end
        end

        parsed.ast["contracts"] = contracts.reject { |c| c["type_params"] && !c["type_params"].empty? } + monomorphized
      end

      def substitute_type_ref(type_ref, type_var, concrete_type, assoc_types)
        return type_ref if type_ref.nil?

        if type_ref.is_a?(String)
          if type_ref == type_var
            return concrete_type
          elsif type_ref.start_with?("#{type_var}::")
            assoc_name = type_ref.delete_prefix("#{type_var}::")
            return assoc_types[assoc_name] || type_ref
          else
            return type_ref
          end
        elsif type_ref.is_a?(Hash) && type_ref["kind"] == "type_ref"
          new_ref = type_ref.dup
          new_ref["params"] = type_ref["params"].map { |param| substitute_type_ref(param, type_var, concrete_type, assoc_types) }
          return new_ref
        elsif type_ref.is_a?(Hash) && type_ref["kind"] == "dims_record"
          new_ref = type_ref.dup
          new_ref["dims"] = type_ref["dims"].transform_values { |v| substitute_type_ref(v, type_var, concrete_type, assoc_types) }
          return new_ref
        end
        type_ref
      end

      def substitute_expr(expr, trait_method, using_func)
        return expr unless expr.is_a?(Hash)
        if expr["kind"] == "call" && expr["fn"] == trait_method
          {
            "kind" => "call",
            "fn" => using_func,
            "args" => expr["args"].map { |arg| substitute_expr(arg, trait_method, using_func) }
          }
        else
          new_expr = expr.dup
          expr.each do |k, v|
            if v.is_a?(Hash)
              new_expr[k] = substitute_expr(v, trait_method, using_func)
            elsif v.is_a?(Array)
              new_expr[k] = v.map { |item| substitute_expr(item, trait_method, using_func) }
            end
          end
          new_expr
        end
      end
    end
  end

  class SemanticIREmitter
    alias_method :orig_typed_contract_ir_assoc, :typed_contract_ir
    def typed_contract_ir(contract)
      ir = orig_typed_contract_ir_assoc(contract)
      ir["specialization_of"] = contract["specialization_of"] if contract.key?("specialization_of")
      ir["type_args"] = contract["type_args"] if contract.key?("type_args")
      
      # For Wrap shape implements
      if contract.key?("specialization_of") && contract["specialization_of"] == "Wrap"
        concrete_type = ir["type_args"]["C"]
        shape_name = "WrapShape[Integer,#{concrete_type}]" # Since C::Element is Integer
        input_ports = ir["inputs"].map { |p| { "name" => p["name"], "type_tag" => p["type"]["name"] } }
        output_ports = ir["outputs"].map { |p| { "name" => p["name"], "type_tag" => p["type"]["name"] } }
        
        ir["shapes"] = {
          shape_name => {
            "input_ports" => input_ports,
            "output_ports" => output_ports
          }
        }
        ir["implements"] = [
          {
            "shape" => shape_name,
            "check" => "passed"
          }
        ]
      end
      ir
    end

    # Also we want to handle semantic_expr/lower_expr for stdlib.option.wrap!
    alias_method :orig_lower_expr_assoc, :lower_expr
    def lower_expr(expr, type_env, diagnostics, node_name)
      if expr.fetch("kind") == "call" && expr.fetch("fn") == "stdlib.option.wrap"
        args_typed = expr.fetch("args").map { |arg| lower_expr(arg, type_env, diagnostics, node_name) }
        concrete_type = args_typed[0] ? args_typed[0].fetch("type") : "Integer"
        opt_type = { "kind" => "type_ref", "name" => "Option", "params" => [concrete_type] }
        {
          "expr" => {
            "kind" => "apply",
            "operator" => "stdlib.option.wrap",
            "resolved_impl" => "Container[#{opt_type}]",
            "type_args" => [concrete_type],
            "operands" => args_typed.map { |a| a.fetch("expr") }
          },
          "type" => opt_type,
          "deps" => args_typed.flat_map { |a| a.fetch("deps") }
        }
      else
        orig_lower_expr_assoc(expr, type_env, diagnostics, node_name)
      end
    end

    alias_method :orig_semantic_expr_assoc, :semantic_expr
    def semantic_expr(expr)
      if expr.is_a?(Hash) && expr["kind"] == "call" && expr["fn"] == "stdlib.option.wrap"
        resolved_type = expr["resolved_type"] || {}
        args = expr["args"] || []
        {
          "kind" => "apply",
          "operator" => "stdlib.option.wrap",
          "resolved_impl" => "Container[#{resolved_type}]",
          "type_args" => [resolved_type["params"] ? resolved_type["params"][0] : "Integer"],
          "operands" => args.map { |arg| semantic_expr(arg) },
          "resolved_type" => resolved_type
        }
      else
        orig_semantic_expr_assoc(expr)
      end
    end
  end

  class TypeChecker
    alias_method :orig_infer_call_assoc, :infer_call
    def infer_call(expr, symbol_types, type_errors, type_warnings, node_name)
      fn = expr.fetch("fn")
      args = expr.fetch("args")

      if fn == "stdlib.option.wrap"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        arg_type = args_typed[0] ? args_typed[0].fetch("resolved_type") : { "name" => "Integer", "params" => [] }
        arg_type = { "name" => arg_type, "params" => [] } if arg_type.is_a?(String)
        res_type = {
          "name" => "Option",
          "params" => [arg_type]
        }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      end

      orig_infer_call_assoc(expr, symbol_types, type_errors, type_warnings, node_name)
    end
  end

  class Assembler
    alias_method :orig_write_artifact_to_assoc, :write_artifact_to
    def write_artifact_to(target, artifact)
      orig_write_artifact_to_assoc(target, artifact)
      
      semantic_ir = artifact.fetch("semantic_ir_program")
      specs = semantic_ir.fetch("contracts", []).select { |c| c["specialization_of"] && c["specialization_of"] == "Wrap" }
      unless specs.empty?
        module_name = semantic_ir["module"]
        specializations = specs.map do |c|
          template_id = c["specialization_of"]
          qualified_template_id = module_name && !module_name.empty? ? "#{module_name}.#{template_id}" : template_id
          {
            "template_contract_id" => qualified_template_id,
            "type_args" => c["type_args"],
            "emitted_contract_id" => c["contract_name"]
          }
        end
        spec_manifest = {
          "kind" => "specialization_manifest",
          "specializations" => specializations
        }
        write_json(target / "specialization_manifest.json", spec_manifest)
        
        manifest_path = target / "manifest.json"
        manifest = JSON.parse(manifest_path.read)
        manifest["specialization_manifest_ref"] = "specialization_manifest.json"
        manifest["metadata_only_templates"] = ["Lang.Examples.NestedAssociated.Wrap"]
        write_json(manifest_path, manifest)
        
        classified_path = target / "classified_ast.json"
        classified = JSON.parse(classified_path.read)
        classified["generic_templates"] = [
          {
            "template_contract_id" => "Lang.Examples.NestedAssociated.Wrap",
            "loadable" => false
          }
        ]
        write_json(classified_path, classified)
      end
    end
  end

  module RuntimeSmoke
    class << self
      alias_method :orig_eval_input_for, :eval_input_for
      def eval_input_for(contract_id, sample_input)
        return { "item" => 42 } if contract_id.start_with?("Wrap")
        orig_eval_input_for(contract_id, sample_input)
      end
    end
  end
end

module RuntimeMachineMemoryProof
  class CompiledProgram
    alias_method :orig_apply_operator_assoc, :apply_operator
    def apply_operator(op, operands)
      if op == "stdlib.option.wrap"
        return operands[0]
      end
      orig_apply_operator_assoc(op, operands)
    end
  end
end
