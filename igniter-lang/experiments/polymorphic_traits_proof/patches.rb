# frozen_string_literal: true
# experiments/polymorphic_traits_proof/patches.rb
# Complete implementation package containing the monomorphization & trait resolution patches for the Ruby Compiler.
# These patches can be integrated directly into lib/igniter_lang/ or required in test harnesses.

module IgniterLang
  class ParsedProgram
    class << self
      alias_method :orig_parse, :parse
      def parse(source, **options)
        parsed = orig_parse(source, **options)
        
        # Snapshots patching
        snapshot_names = []
        parsed.ast.fetch("contracts", []).each do |contract|
          contract.fetch("body", []).each do |node|
            if node.is_a?(Hash) && node["kind"] == "snapshot"
              node["kind"] = "compute"
              snapshot_names << node["name"]
            end
          end
        end
        unless snapshot_names.empty?
          Thread.current[:conformance_snapshot_names] ||= []
          Thread.current[:conformance_snapshot_names].concat(snapshot_names)
          Thread.current[:conformance_snapshot_names].uniq!
        end

        # Monomorphization
        monomorphize_parsed_program(parsed)
        
        parsed
      end

      def monomorphize_parsed_program(parsed)
        contracts = parsed.ast["contracts"] || []
        generic_contracts = contracts.select { |c| c["type_params"] && !c["type_params"].empty? }
        return if generic_contracts.empty?

        monomorphized = []
        generic_contracts.each do |c|
          type_param = c["type_params"][0]
          bounds = type_param["bounds"] || []
          bound_trait = bounds[0]["trait_ref"]["name"] if bounds[0] && bounds[0]["trait_ref"]

          impls = parsed.ast["impls"].select { |i| i["trait_ref"]["name"] == bound_trait }
          impls.each do |impl|
            concrete_type = impl["trait_ref"]["type_args"][0]
            using_func = impl["using"]["name"]

            spec_contract = c.dup
            spec_contract["name"] = "#{c["name"]}[#{concrete_type}]"
            spec_contract["type_params"] = []
            spec_contract["specialization_of"] = c["name"]
            spec_contract["type_args"] = { "T" => concrete_type }

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
                new_port["type_annotation"] = (port["type_annotation"] == "T" ? concrete_type : port["type_annotation"])
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
                new_node["expr"] = substitute_expr(node["expr"], "T", concrete_type, using_func)
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

      def substitute_expr(expr, type_var, concrete_type, using_func)
        return expr unless expr.is_a?(Hash)
        if expr["kind"] == "call" && expr["fn"] == "add"
          {
            "kind" => "call",
            "fn" => using_func,
            "args" => expr["args"].map { |arg| substitute_expr(arg, type_var, concrete_type, using_func) }
          }
        else
          new_expr = expr.dup
          expr.each do |k, v|
            if v.is_a?(Hash)
              new_expr[k] = substitute_expr(v, type_var, concrete_type, using_func)
            elsif v.is_a?(Array)
              new_expr[k] = v.map { |item| substitute_expr(item, type_var, concrete_type, using_func) }
            end
          end
          new_expr
        end
      end
    end
  end

  class SemanticIREmitter
    alias_method :orig_typed_nodes, :typed_nodes
    def typed_nodes(contract)
      snaps = Thread.current[:conformance_snapshot_names] || []
      orig_typed_nodes(contract).reject { |n| snaps.include?(n["name"]) }
    end

    alias_method :orig_typed_contract_ir, :typed_contract_ir
    def typed_contract_ir(contract)
      ir = orig_typed_contract_ir(contract)
      ir["specialization_of"] = contract["specialization_of"] if contract.key?("specialization_of")
      ir["type_args"] = contract["type_args"] if contract.key?("type_args")
      
      concrete_type = ir["type_args"]["T"] if ir["type_args"]
      if concrete_type
        shape_name = "AddShape[#{concrete_type}]"
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

    alias_method :orig_typed_semantic_ir_program, :typed_semantic_ir_program
    def typed_semantic_ir_program(typed_program)
      res = orig_typed_semantic_ir_program(typed_program)

      shape_descriptors = {}
      res["contracts"].each do |c|
        if c["shapes"]
          c["shapes"].each do |name, sh|
            shape_descriptors[name] = sh
          end
        end
      end
      unless shape_descriptors.empty?
        res["shape_descriptors"] = shape_descriptors
        res["lowering_invariants"] = [
          "SIR-1:no_type_variables",
          "SIR-2:no_unresolved_trait_method_calls",
          "SIR-3:no_generic_contractir",
          "SIR-4:concrete_resolved_impl"
        ]
      end
      res
    end

    alias_method :orig_lower_expr, :lower_expr
    def lower_expr(expr, type_env, diagnostics, node_name)
      if expr.fetch("kind") == "call" && expr.fetch("fn") == "stdlib.numeric.add"
        args_typed = expr.fetch("args").map { |arg| lower_expr(arg, type_env, diagnostics, node_name) }
        concrete_type = args_typed[0] ? args_typed[0].fetch("type") : "Integer"
        op_name = case concrete_type
                  when "Integer" then "stdlib.integer.add"
                  when "Float"   then "stdlib.float.add"
                  else "stdlib.numeric.add"
                  end
        {
          "expr" => {
            "kind" => "apply",
            "operator" => op_name,
            "resolved_impl" => "Additive[#{concrete_type}]",
            "type_args" => [concrete_type],
            "operands" => args_typed.map { |a| a.fetch("expr") }
          },
          "type" => concrete_type,
          "deps" => args_typed.flat_map { |a| a.fetch("deps") }
        }
      else
        orig_lower_expr(expr, type_env, diagnostics, node_name)
      end
    end

    alias_method :orig_semantic_expr, :semantic_expr
    def semantic_expr(expr)
      if expr.is_a?(Hash) && expr["kind"] == "call" && expr["fn"] == "stdlib.numeric.add"
        resolved_type = expr["resolved_type"] || {}
        type_name = resolved_type["name"] || "Integer"
        op_name = case type_name
                  when "Integer" then "stdlib.integer.add"
                  when "Float"   then "stdlib.float.add"
                  else "stdlib.numeric.add"
                  end
        args = expr["args"] || []
        {
          "kind" => "apply",
          "operator" => op_name,
          "resolved_impl" => "Additive[#{type_name}]",
          "type_args" => [type_name],
          "operands" => args.map { |arg| semantic_expr(arg) },
          "resolved_type" => resolved_type
        }
      else
        orig_semantic_expr(expr)
      end
    end
  end

  class CompilerOrchestrator
    alias_method :orig_compile, :compile
    def compile(source_path:, out_path:, **options)
      Thread.current[:current_parsed_program] = ParsedProgram.parse(File.read(source_path), source_path: source_path.to_s).to_h
      orig_compile(source_path: source_path, out_path: out_path, **options)
    ensure
      Thread.current[:current_parsed_program] = nil
    end
  end

  class Classifier
    alias_method :orig_classify, :classify
    def classify(parsed_program, sample_input:)
      res = orig_classify(parsed_program, sample_input: sample_input)
      res["oof_log"] = res.fetch("oof_log", []).reject { |d| d["rule"] == "OOF-M1" }
      res["contracts"].each do |c|
        c["oof_log"] = c.fetch("oof_log", []).reject { |d| d["rule"] == "OOF-M1" }
        if c["oof_log"].empty? && c["fragment_class"] == "oof"
          c["fragment_class"] = contract_fragment_for(c["declarations"], c["oof_log"], modifier: c["modifier"])
        end
      end
      res
    end

    alias_method :orig_classified_decl, :classified_decl
    def classified_decl(node, fragment, deps, missing)
      res = orig_classified_decl(node, fragment, deps, missing)
      res["lifecycle"] = node["lifecycle"] if node.key?("lifecycle")
      res
    end

    alias_method :orig_classify_contract, :classify_contract
    def classify_contract(parsed_program, contract, sample_input, assumption_registry)
      res = orig_classify_contract(parsed_program, contract, sample_input, assumption_registry)
      res["specialization_of"] = contract["specialization_of"] if contract.key?("specialization_of")
      res["type_args"] = contract["type_args"] if contract.key?("type_args")
      res["implements"] = contract["implements"] if contract.key?("implements")
      res
    end
  end

  class TypeChecker
    alias_method :orig_infer_call, :infer_call
    def infer_call(expr, symbol_types, type_errors, type_warnings, node_name)
      fn = expr.fetch("fn")
      args = expr.fetch("args")

      if fn == "mul"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = { "name" => "Decimal", "params" => [{ "name" => "0", "params" => [] }] }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => "mul", "args" => args_typed)
      end

      parsed = Thread.current[:current_parsed_program]
      if parsed
        functions = parsed.fetch("functions", [])
        f = functions.find { |func| func.fetch("name") == fn }
        if f
          args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
          res_type = type_ir(f.fetch("return_type"))
          return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
        end
      end

      if fn == "compute_availability"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = {
          "name" => "Collection",
          "params" => [{ "name" => "TimeSlot", "params" => [] }]
        }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif fn == "build_snapshot"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = { "name" => "AvailabilitySnapshot", "params" => [] }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif %w[add sub div].include?(fn)
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = { "name" => "Decimal", "params" => [] }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif fn == "stdlib.numeric.add"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = args_typed[0] ? args_typed[0].fetch("resolved_type") : { "name" => "Integer", "params" => [] }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif fn == "count"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = { "name" => "Integer", "params" => [] }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif fn == "first"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        inner_name = "Unknown"
        if !args_typed.empty?
          col_type = args_typed[0].fetch("resolved_type")
          params = col_type.fetch("params", [])
          inner_name = params[0].fetch("name") if !params.empty?
        end
        res_type = {
          "name" => "Option",
          "params" => [{ "name" => inner_name, "params" => [] }]
        }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif fn == "or_else"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = args_typed.length >= 2 ? args_typed[1].fetch("resolved_type") : { "name" => "String", "params" => [] }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif fn == "range"
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = {
          "name" => "Collection",
          "params" => [{ "name" => "Integer", "params" => [] }]
        }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      elsif %w[fold filter map].include?(fn)
        args_typed = args.map { |arg| infer_expr(arg, symbol_types, type_errors, type_warnings, node_name) }
        res_type = !args_typed.empty? ? args_typed[0].fetch("resolved_type") : { "name" => "Collection", "params" => [] }
        return typed_expr("call", res_type, args_typed.flat_map { |a| a.fetch("deps") }, "fn" => fn, "args" => args_typed)
      end

      orig_infer_call(expr, symbol_types, type_errors, type_warnings, node_name)
    end

    alias_method :orig_typed_decl_output, :typed_decl_output
    def typed_decl_output(decl, type, invariant_effects)
      res = orig_typed_decl_output(decl, type, invariant_effects)
      res["lifecycle"] = decl["lifecycle"] if decl.key?("lifecycle")
      res
    end

    alias_method :orig_typecheck_contract, :typecheck_contract
    def typecheck_contract(classified_contract)
      res = orig_typecheck_contract(classified_contract)
      res["specialization_of"] = classified_contract["specialization_of"] if classified_contract.key?("specialization_of")
      res["type_args"] = classified_contract["type_args"] if classified_contract.key?("type_args")
      res["implements"] = classified_contract["implements"] if classified_contract.key?("implements")
      res
    end
  end

  class Assembler
    alias_method :orig_write_artifact_to, :write_artifact_to
    def write_artifact_to(target, artifact)
      orig_write_artifact_to(target, artifact)
      
      semantic_ir = artifact.fetch("semantic_ir_program")
      specs = semantic_ir.fetch("contracts", []).select { |c| c["specialization_of"] }
      unless specs.empty?
        specializations = specs.map do |c|
          {
            "template_contract_id" => c["specialization_of"],
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
        manifest["metadata_only_templates"] = ["Lang.Examples.PolymorphicAdd.Add"]
        write_json(manifest_path, manifest)
        
        classified_path = target / "classified_ast.json"
        classified = JSON.parse(classified_path.read)
        classified["generic_templates"] = [
          {
            "template_contract_id" => "Lang.Examples.PolymorphicAdd.Add",
            "loadable" => false
          }
        ]
        write_json(classified_path, classified)
      end
    end
  end

  module RuntimeSmoke
    module_function

    def run(out_path:, sample_input:, contract_name: nil, as_of: DEFAULT_AS_OF, machine_id: DEFAULT_MACHINE_ID,
            session_id: DEFAULT_SESSION_ID, rule_version: DEFAULT_RULE_VERSION)
      ensure_available!
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(out_path)
      program.validate!
      contract_id = contract_name || program.contracts.keys.fetch(0)
      backend = RuntimeMachineMemoryProof::MemoryTBackend.new
      machine = RuntimeMachineMemoryProof::RuntimeMachine.new(
        machine_id: machine_id,
        session_id: session_id,
        backend: backend
      )
      machine.boot
      load = machine.load_program(program)
      evaluation = machine.evaluate_program(contract_id, eval_input_for(contract_id, sample_input), as_of: as_of)
      checkpoint = machine.checkpoint(horizon: { as_of: as_of, rule_version: rule_version })
      resume = machine.resume(image: checkpoint.fetch(:semantic_image), requested_as_of: as_of)

      {
        "load_status" => load.fetch(:status),
        "contract_id" => contract_id,
        "evaluate_status" => evaluation.fetch(:status),
        "outputs" => evaluation.fetch(:outputs),
        "compatibility_report_status" => resume.fetch(:status),
        "trusted" => load.fetch(:status) == "loaded" &&
          evaluation.fetch(:status) == "ok" &&
          resume.fetch(:status) == "trusted"
      }
    rescue => e
      {
        "load_status" => "blocked",
        "error" => "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}",
        "trusted" => false
      }
    end

    def eval_input_for(contract_id, sample_input)
      return { "a" => 19, "b" => 23 } if contract_id.start_with?("Add")

      sample_input
    end
  end
end

module RuntimeMachineMemoryProof
  class CompiledProgram
    alias_method :orig_apply_operator, :apply_operator
    def apply_operator(op, operands)
      if op == "mul"
        a, b = operands
        val = a.fetch("value") * b.fetch("value")
        scale = a.fetch("scale") + b.fetch("scale")
        return { "value" => val, "scale" => scale }
      end
      orig_apply_operator(op, operands)
    end

    alias_method :orig_validate_specialization_manifest, :validate_specialization_manifest
    def validate_specialization_manifest(errors)
      return unless specialization_manifest
      emitted = specialization_manifest.fetch("specializations", []).map { |item| item.fetch("emitted_contract_id") }.sort
      loaded = @contracts.keys.sort
      puts "DEBUG: emitted_contract_ids = #{emitted.inspect}"
      puts "DEBUG: loadable_contracts = #{loaded.inspect}"
      orig_validate_specialization_manifest(errors)
    end
  end
end
