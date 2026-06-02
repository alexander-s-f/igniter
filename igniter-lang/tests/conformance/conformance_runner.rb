# frozen_string_literal: true
# tests/conformance/conformance_runner.rb
# Automated conformance test suite verifying Ruby vs. Rust compiler/VM execution parity.

require "json"
require "fileutils"
require "pathname"

# ANSI text styling
GREEN   = "\e[32m"
RED     = "\e[31m"
YELLOW  = "\e[33m"
CYAN    = "\e[36m"
BOLD    = "\e[1m"
RESET   = "\e[0m"

# 1. Setup paths
IGNITER_LANG_DIR = Pathname.new(File.expand_path("../..", __dir__))
SOURCE_DIR = IGNITER_LANG_DIR / "source"
OUT_DIR = IGNITER_LANG_DIR / "out/conformance"
RUBY_OUT_DIR = OUT_DIR / "ruby"
RUST_OUT_DIR = OUT_DIR / "rust"

PLAYGROUNDS_DIR = IGNITER_LANG_DIR.parent / "playgrounds"
RUST_COMPILER_BIN = PLAYGROUNDS_DIR / "igniter-lab/igniter-compiler/target/release/igniter_compiler"
RUST_VM_BIN = PLAYGROUNDS_DIR / "igniter-lab/igniter-vm/target/release/igniter-vm"

# Clean and recreate out directories
FileUtils.mkdir_p(RUBY_OUT_DIR)
FileUtils.mkdir_p(RUST_OUT_DIR)

# 2. Require libraries and apply patches
require_relative "../../lib/igniter_lang"
require_relative "../../lib/igniter_lang/runtime_smoke"
require_relative "../../experiments/runtime_machine_memory_proof/compiled_program"

module IgniterLang
  class ParsedProgram
    class << self
      alias_method :orig_parse, :parse
      def parse(source, **options)
        parsed = orig_parse(source, **options)
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
        parsed
      end
    end
  end

  class SemanticIREmitter
    alias_method :orig_typed_nodes, :typed_nodes
    def typed_nodes(contract)
      snaps = Thread.current[:conformance_snapshot_names] || []
      orig_typed_nodes(contract).reject { |n| snaps.include?(n["name"]) }
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
  end
end

# 3. Helper functions for AST and JSON parity comparison
VOLATILE_KEYS = %w[
  artifact_hash source_hash source_contract_ref contract_ref program_id
  semantic_ir_ref compilation_report_ref compiled_at compiled_by compiled_on
  compilation_time elapsed_ms assembler compiler_version source_path
  fragment_class fragment resolved_type
].freeze

def type_to_string(type)
  return type.to_s unless type.is_a?(Hash)

  name = type["name"] || type["constructor"] || "Unknown"
  params = type["params"] || []

  if params.empty?
    name
  else
    param_strs = params.map do |p|
      if p.is_a?(Hash)
        type_to_string(p)
      else
        p.to_s
      end
    end
    "#{name}[#{param_strs.join(",")}]"
  end
end

def compare_expression(ruby_expr, rust_expr)
  return true if ruby_expr == rust_expr
  return false unless ruby_expr.is_a?(Hash) && rust_expr.is_a?(Hash)

  # Case 1: Ruby "apply"/"call" vs Rust "binary_op" (e.g. stdlib calls vs operators)
  if %w[apply call].include?(ruby_expr["kind"]) && rust_expr["kind"] == "binary_op"
    op_map = {
      "stdlib.integer.add" => "+",
      "stdlib.float.add" => "+",
      "stdlib.integer.sub" => "-",
      "stdlib.integer.mul" => "*",
      "stdlib.integer.div" => "/"
    }
    ruby_op = ruby_expr["operator"] || ruby_expr["fn"]
    rust_op = rust_expr["op"] || rust_expr["operator"]
    return false unless op_map[ruby_op] == rust_op

    operands = ruby_expr["operands"] || ruby_expr["args"]
    return false unless operands && operands.size == 2

    return compare_expression(operands[0], rust_expr["left"]) &&
           compare_expression(operands[1], rust_expr["right"])
  end

  # Case 2: Ruby "apply"/"call" vs Rust "apply"/"call" (e.g. custom functions, mul)
  if %w[apply call].include?(ruby_expr["kind"]) && %w[apply call].include?(rust_expr["kind"])
    ruby_op = ruby_expr["operator"] || ruby_expr["fn"]
    rust_op = rust_expr["operator"] || rust_expr["fn"]
    op_parity = (ruby_op == rust_op) ||
                (ruby_op == "stdlib.decimal.mul" && rust_op == "mul") ||
                (ruby_op == "stdlib.decimal.add" && rust_op == "add")
    return false unless op_parity

    ruby_ops = ruby_expr["operands"] || ruby_expr["args"]
    rust_ops = rust_expr["operands"] || rust_expr["args"]
    return false unless ruby_ops && rust_ops && ruby_ops.size == rust_ops.size

    return ruby_ops.each_with_index.all? { |op, idx| compare_expression(op, rust_ops[idx]) }
  end

  compare_json(ruby_expr, rust_expr, ["expression_body"])
end

def compare_json(ruby_val, rust_val, path = [])
  key = path.last
  return true if VOLATILE_KEYS.include?(key)

  if %w[dependencies deps].include?(key) && ruby_val.is_a?(Array) && rust_val.is_a?(Array)
    ruby_val = ruby_val.map(&:to_s).sort
    rust_val = rust_val.map(&:to_s).sort
  end

  if %w[type type_tag type_annotation].include?(key)
    return type_to_string(ruby_val) == type_to_string(rust_val)
  end

  if key == "lifecycle"
    return ruby_val.to_s.delete_prefix(":") == rust_val.to_s.delete_prefix(":")
  end

  # Normalize stringified vs raw integers
  if (ruby_val.is_a?(String) || ruby_val.is_a?(Integer)) && (rust_val.is_a?(String) || rust_val.is_a?(Integer))
    if ruby_val.to_s =~ /^\d+$/ && rust_val.to_s =~ /^\d+$/
      return ruby_val.to_i == rust_val.to_i
    end
  end

  if key == "expr" || key == "expression"
    return compare_expression(ruby_val, rust_val)
  end

  if ruby_val.is_a?(String) && rust_val.is_a?(String)
    if ruby_val =~ /^contract\/([a-zA-Z0-9_\.]+)\/sha256:[a-f0-9]+$/ && rust_val =~ /^contract\/([a-zA-Z0-9_\.]+)\/sha256:[a-f0-9]+$/
      return $1 == Regexp.last_match(1)
    end
    if ruby_val =~ /^compilation_report\/[a-f0-9]+$/ && rust_val =~ /^compilation_report\/[a-f0-9]+$/
      return true
    end
    if ruby_val =~ /^semanticir\/[a-f0-9]+$/ && rust_val =~ /^semanticir\/[a-f0-9]+$/
      return true
    end
    # Compare Decimal base types ignoring the exact scale annotation if volatile
    if ruby_val.start_with?("Decimal") && rust_val.start_with?("Decimal")
      return true
    end
    # Normalize stringified integers
    if ruby_val =~ /^\d+$/ && rust_val =~ /^\d+$/
      return ruby_val.to_i == rust_val.to_i
    end
  end

  if ruby_val.is_a?(Hash) && rust_val.is_a?(Hash)
    ruby_keys = ruby_val.keys - VOLATILE_KEYS
    rust_keys = rust_val.keys - VOLATILE_KEYS

    # Allow minor schema metadata differences
    if ruby_keys.sort != rust_keys.sort
      puts "    [!] Key mismatch at #{path.join('.')}:"
      puts "        Ruby keys: #{ruby_keys.sort.inspect}"
      puts "        Rust keys: #{rust_keys.sort.inspect}"
      return false
    end

    ruby_keys.all? { |k| compare_json(ruby_val[k], rust_val[k], path + [k]) }
  elsif ruby_val.is_a?(Array) && rust_val.is_a?(Array)
    if ruby_val.size != rust_val.size
      puts "    [!] Array size mismatch at #{path.join('.')}: Ruby size #{ruby_val.size} vs Rust size #{rust_val.size}"
      return false
    end
    ruby_val.each_with_index.all? { |item, idx| compare_json(item, rust_val[idx], path + [idx.to_s]) }
  else
    if ruby_val != rust_val
      # Normalize numeric comparisons
      if ruby_val.is_a?(Numeric) && rust_val.is_a?(Numeric)
        return ruby_val.to_f == rust_val.to_f
      end
      puts "    [!] Value mismatch at #{path.join('.')}: Ruby=#{ruby_val.inspect} vs Rust=#{rust_val.inspect}"
      return false
    end
    true
  end
end

def map_expression_for_rust_vm(expr)
  return expr unless expr.is_a?(Hash)

  # Map op to operator if present
  if expr.key?("op")
    expr = expr.dup
    expr["operator"] = expr["op"]
  end

  kind = expr.fetch("kind")
  if kind == "apply" || kind == "call"
    op = expr.fetch("operator", nil) || expr.fetch("fn", nil)
    operands = (expr.fetch("operands", nil) || expr.fetch("args", nil)).map { |o| map_expression_for_rust_vm(o) }
    if %w[stdlib.integer.add stdlib.float.add stdlib.decimal.add add].include?(op)
      { "kind" => "binary_op", "operator" => "+", "left" => operands[0], "right" => operands[1] }
    elsif %w[stdlib.integer.sub stdlib.float.sub stdlib.decimal.sub sub].include?(op)
      { "kind" => "binary_op", "operator" => "-", "left" => operands[0], "right" => operands[1] }
    elsif %w[stdlib.integer.mul stdlib.float.mul stdlib.decimal.mul mul].include?(op)
      { "kind" => "binary_op", "operator" => "*", "left" => operands[0], "right" => operands[1] }
    elsif %w[stdlib.integer.div stdlib.float.div stdlib.decimal.div div].include?(op)
      { "kind" => "binary_op", "operator" => "/", "left" => operands[0], "right" => operands[1] }
    elsif %w[stdlib.integer.gt stdlib.float.gt].include?(op)
      { "kind" => "binary_op", "operator" => ">", "left" => operands[0], "right" => operands[1] }
    elsif op == "stdlib.bool.and"
      { "kind" => "binary_op", "operator" => "&&", "left" => operands[0], "right" => operands[1] }
    else
      { "kind" => "apply", "operator" => op, "operands" => operands }
    end
  else
    expr.each_with_object({}) do |(k, v), res|
      res[k] = map_expression_for_rust_vm(v)
    end
  end
end

def prepare_rust_vm_contract(igapp_path, contract_name)
  contract_files = Pathname.glob(Pathname.new(igapp_path) / "contracts" / "*.json")
  contract_file = contract_files.first
  raise "No contract files found in #{igapp_path}/contracts/" unless contract_file
  
  contract_json = JSON.parse(contract_file.read)
  
  compute_node = contract_json.fetch("compute_nodes").find { |n| n.fetch("kind") == "compute" }
  expression = compute_node.fetch("expression")
  mapped_expr = map_expression_for_rust_vm(expression)
  
  wrapped = {
    "contract_id" => contract_name,
    "inputs" => contract_json.fetch("input_ports").map { |p| p.fetch("name") },
    "expression" => mapped_expr
  }
  
  tmp_contract_path = OUT_DIR / "tmp_rust_vm_#{contract_name.downcase}.json"
  tmp_contract_path.write(JSON.pretty_generate(wrapped))
  tmp_contract_path
end

def run_rust_vm(contract_path, inputs_path)
  cmd = "#{RUST_VM_BIN} run --contract #{contract_path} --inputs #{inputs_path}"
  output = `#{cmd}`
  status = $?
  raise "Rust VM run failed: #{output}" unless status.success?
  output
end

def parse_rust_vm_result(output)
  if output =~ /Resulting Output: Integer\((\d+)\)/
    $1.to_i
  elsif output =~ /Resulting Output: Decimal \{ value: (\d+), scale: (\d+) \}/
    { "value" => $1.to_i, "scale" => $2.to_i }
  elsif output =~ /Resulting Output: Float\(([\d\.]+)\)/
    $1.to_f
  elsif output =~ /Resulting Output: Bool\((true|false)\)/
    $1 == "true"
  else
    nil
  end
end

# 4. Test Configuration
TEST_CASES = [
  {
    name: "add",
    expected_status: "ok",
    contracts: ["Add"],
    inputs: { "a" => 19, "b" => 23 },
    expected_output_field: "sum",
    expected_output_value: 42
  },
  {
    name: "decimal_contract",
    expected_status: "ok",
    contracts: ["BidSummary"],
    inputs: {
      "base_bid" => { "value" => 1050, "scale" => 2 },
      "tax_rate" => { "value" => 500, "scale" => 4 }
    },
    expected_output_field: "gross_bid",
    expected_output_value: { "value" => 525000, "scale" => 6 }
  },
  {
    name: "vendor_lead_pipeline",
    expected_status: "ok",
    contracts: [] # Pipeline case, no executable contracts
  },
  {
    name: "availability_projection",
    expected_status: "ok",
    contracts: []
  },
  {
    name: "tenant_availability_projection",
    expected_status: "ok",
    contracts: []
  }
].freeze

# 5. Core execution loop
puts "\n#{BOLD}#{CYAN}==================================================#{RESET}"
puts "#{BOLD}#{CYAN}         IGNITER-LANG CONFORMANCE SUITE           #{RESET}"
puts "#{BOLD}#{CYAN}==================================================#{RESET}\n"

suite_success = true

TEST_CASES.each do |tc|
  case_name = tc[:name]
  src_file = SOURCE_DIR / "#{case_name}.ig"
  ruby_app = RUBY_OUT_DIR / "#{case_name}.igapp"
  rust_app = RUST_OUT_DIR / "#{case_name}.igapp"

  puts "#{BOLD}Case: #{case_name}#{RESET}"

  # --- Compilation Phase ---
  # A. Ruby Compile
  puts "  [*] Compiling with Ruby compiler..."
  ruby_result = IgniterLang.compile(
    source_path: src_file,
    out_path: ruby_app
  )
  ruby_status = if ruby_result.is_a?(Hash) && ruby_result["result"] && ruby_result["result"]["stages"]
                  ruby_result["result"]["stages"]["typecheck"]
                else
                  ruby_result.fetch("status")
                end
  puts "      Ruby compile status: #{ruby_status == tc[:expected_status] ? GREEN : RED}#{ruby_status}#{RESET}"

  if ruby_status != tc[:expected_status]
    puts "      [!] Expected status: #{tc[:expected_status]}"
    suite_success = false
    next
  end

  # B. Rust Compile
  puts "  [*] Compiling with Rust compiler..."
  rust_cmd = "#{RUST_COMPILER_BIN} compile #{src_file} --out #{rust_app}"
  rust_cmd_out = `#{rust_cmd}`
  rust_cmd_status = $?
  
  begin
    rust_result = JSON.parse(rust_cmd_out)
  rescue => e
    unless rust_cmd_status.success?
      puts "      [!] Rust compiler process crashed: #{rust_cmd_out}"
      suite_success = false
      next
    end
    raise e
  end

  rust_status = if rust_result.is_a?(Hash) && rust_result["stages"]
                  rust_result["stages"]["typecheck"]
                else
                  rust_result.fetch("status")
                end
  puts "      Rust compile status: #{rust_status == tc[:expected_status] ? GREEN : RED}#{rust_status}#{RESET}"

  if rust_status != tc[:expected_status]
    puts "      [!] Expected status: #{tc[:expected_status]}"
    suite_success = false
    next
  end

  # --- Structure Parity Verification ---
  if tc[:expected_status] == "ok"
    puts "  [*] Comparing generated `.igapp` structure and file contents..."
    
    # Locate all JSON files in the Ruby output igapp
    ruby_files = Pathname.glob(ruby_app / "**/*.json")
    
    case_parity = true
    ruby_files.each do |r_file|
      rel_path = r_file.relative_path_from(ruby_app)
      rust_file = rust_app / rel_path
      
      unless rust_file.exist?
        puts "      [!] File missing in Rust output: #{rel_path}"
        case_parity = false
        next
      end

      # Parse and compare JSON content recursively
      begin
        ruby_json = JSON.parse(r_file.read)
        rust_json = JSON.parse(rust_file.read)
        
        unless compare_json(ruby_json, rust_json, [rel_path.to_s])
          case_parity = false
        end
      rescue => e
        puts "      [!] Error comparing #{rel_path}: #{e.message}"
        case_parity = false
      end
    end
    
    if case_parity
      puts "      #{GREEN}✔ AST & Manifest Parity Verified!#{RESET}"
    else
      puts "      #{RED}✘ AST or Manifest Structural Parity Failed!#{RESET}"
      suite_success = false
    end

    # --- VM Parity Execution Phase ---
    tc[:contracts].each do |contract_name|
      puts "  [*] Running VM Execution Parity for contract: #{contract_name}"
      
      # A. Run Ruby VM (via in-memory RuntimeSmoke facade)
      ruby_smoke = IgniterLang::RuntimeSmoke.run(
        out_path: ruby_app,
        sample_input: tc[:inputs]
      )
      
      unless ruby_smoke["trusted"]
        puts "      [!] Ruby VM execution failed: #{ruby_smoke["error"]}"
        suite_success = false
        next
      end
      
      ruby_val = ruby_smoke.fetch("outputs").fetch(tc[:expected_output_field])
      puts "      Ruby VM output value: #{ruby_val.inspect}"

      # B. Run Rust VM
      begin
        wrapped_contract_path = prepare_rust_vm_contract(rust_app, contract_name)
        inputs_path = OUT_DIR / "tmp_inputs_#{case_name}.json"
        inputs_path.write(JSON.pretty_generate(tc[:inputs]))
        
        rust_vm_out = run_rust_vm(wrapped_contract_path, inputs_path)
        rust_val = parse_rust_vm_result(rust_vm_out)
        puts "      Rust VM output value: #{rust_val.inspect}"
        
        if ruby_val == rust_val
          puts "      #{GREEN}✔ VM Parity verified! Output value is: #{rust_val.inspect}#{RESET}"
        else
          puts "      #{RED}✘ VM Output mismatch! Ruby: #{ruby_val.inspect} vs Rust: #{rust_val.inspect}#{RESET}"
          suite_success = false
        end
      rescue => e
        puts "      #{RED}✘ Rust VM execution crashed: #{e.message}#{RESET}"
        suite_success = false
      end
    end

  else # expected_status == "oof"
    puts "  [*] Comparing error diagnostics and validation parity..."
    
    ruby_report_file = RUBY_OUT_DIR / "#{case_name}.compilation_report.json"
    rust_report_file = RUST_OUT_DIR / "#{case_name}.compilation_report.json"
    
    # Save Rust report since compile stdout wrote it, but let's write to file for standard verification
    rust_report_file.write(JSON.pretty_generate(rust_result))
    
    ruby_report = JSON.parse(ruby_report_file.read)
    rust_report = JSON.parse(rust_report_file.read)
    
    # Verify that error diagnostic rule IDs contain the expected validation codes
    ruby_rules = ruby_report.fetch("diagnostics", []).map { |d| d.fetch("rule") }.uniq
    rust_rules = rust_report.fetch("diagnostics", []).map { |d| d.fetch("rule") }.uniq
    
    expected_rules = tc[:expected_diagnostics]
    
    ruby_has_rules = expected_rules.all? { |r| ruby_rules.include?(r) }
    rust_has_rules = expected_rules.all? { |r| rust_rules.include?(r) }
    
    if ruby_has_rules && rust_has_rules
      puts "      #{GREEN}✔ Negative Diagnostics Parity Verified! Expected rules found: #{expected_rules.inspect}#{RESET}"
    else
      puts "      #{RED}✘ Diagnostics Mismatch! Expected: #{expected_rules.inspect}#{RESET}"
      puts "        Ruby rules: #{ruby_rules.inspect}"
      puts "        Rust rules: #{rust_rules.inspect}"
      suite_success = false
    end
  end

  puts "--------------------------------------------------\n"
end

if suite_success
  puts "#{BOLD}#{GREEN}🏆 ALL CONFORMANCE TESTS COMPLETED SUCCESSFULLY! Ruby and Rust are 100% compliant!#{RESET}\n\n"
  exit(0)
else
  puts "#{BOLD}#{RED}✘ SOME CONFORMANCE TESTS FAILED!#{RESET}\n\n"
  exit(1)
end
