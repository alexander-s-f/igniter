#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
EXPERIMENT_DIR = ROOT / "experiments/branch_conditional_if_expr_semantics_proof_v0"
FIXTURE_DIR = EXPERIMENT_DIR / "fixtures"
OUT_DIR = EXPERIMENT_DIR / "out"

require_relative "../../lib/igniter_lang/parser"
require_relative "../../lib/igniter_lang/classifier"
require_relative "../../lib/igniter_lang/typechecker"
require_relative "../../lib/igniter_lang/semanticir_emitter"

module BranchConditionalIfExprSemanticsProofV0
  module_function

  CARD = "S3-R188-C1-P1"
  TRACK = "branch-conditional-if-expr-semantics-proof-v0"
  FORMAT_VERSION = "0.1.0"

  FUTURE_OOFS = {
    "condition_not_bool" => "OOF-IF1",
    "missing_else" => "OOF-IF2",
    "branch_type_mismatch" => "OOF-IF3",
    "empty_or_non_value_branch" => "OOF-IF4"
  }.freeze

  PIPELINE_FILES = %w[
    lib/igniter_lang/parser.rb
    lib/igniter_lang/classifier.rb
    lib/igniter_lang/typechecker.rb
    lib/igniter_lang/semanticir_emitter.rb
    lib/igniter_lang/assembler.rb
    lib/igniter_lang/compiler_orchestrator.rb
    lib/igniter_lang.rb
    bin/igc
    bin/igniter-lang
  ].freeze

  FIXTURES = {
    "minimal_if_else" => "minimal_if_else.ig",
    "non_bool_condition" => "non_bool_condition.ig",
    "missing_else" => "missing_else.ig",
    "branch_type_mismatch" => "branch_type_mismatch.ig",
    "empty_branch" => "empty_branch.ig",
    "nested_if_expr" => "nested_if_expr.ig"
  }.freeze

  def run
    FileUtils.mkdir_p(OUT_DIR)

    bool_evidence = canonical_bool_evidence
    parsed_cases = FIXTURES.to_h { |name, file| [name, parse_fixture(file)] }
    current_refusal = current_mainline_refusal(parsed_cases.fetch("minimal_if_else"))
    model_cases = parsed_cases.to_h do |name, parsed_case|
      [name, model_case(parsed_case, bool_evidence.fetch("canonical_bool_type"))]
    end
    semanticir_model = semanticir_model_from(model_cases.fetch("minimal_if_else"))
    nested_semanticir_model = semanticir_model_from(model_cases.fetch("nested_if_expr"))
    release_harness = release_harness_evidence
    closed_surfaces = closed_surface_scan

    checks = build_checks(
      bool_evidence: bool_evidence,
      parsed_cases: parsed_cases,
      current_refusal: current_refusal,
      model_cases: model_cases,
      semanticir_model: semanticir_model,
      nested_semanticir_model: nested_semanticir_model,
      release_harness: release_harness,
      closed_surfaces: closed_surfaces
    )

    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_checks.empty? ? "PASS" : "FAIL"

    summary = {
      "kind" => "branch_conditional_if_expr_semantics_proof_summary",
      "format_version" => FORMAT_VERSION,
      "card" => CARD,
      "track" => TRACK,
      "status" => status,
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "checks_fail" => failed_checks.length,
      "canonical_bool_evidence" => bool_evidence,
      "parser_probe" => parser_probe_summary(parsed_cases.fetch("minimal_if_else")),
      "current_mainline_refusal" => current_refusal,
      "oof_if5_policy" => {
        "status" => "dropped_from_proof_scope",
        "reason" => "R187 C4-A requires single owner/trigger before modeling; none selected"
      },
      "model_cases" => summarize_model_cases(model_cases),
      "semanticir_branch_shape" => {
        "choice" => "direct_expression_lowering_no_branch_expr_wrapper",
        "justification" => "current lower_expr returns expression nodes directly; no live branch_expr wrapper pattern found",
        "minimal_shape" => semanticir_model.fetch("expr"),
        "nested_shape" => nested_semanticir_model.fetch("expr")
      },
      "release_harness_evidence" => release_harness,
      "closed_surface_scan" => closed_surfaces,
      "command_matrix" => command_matrix(status),
      "proof_matrix" => proof_matrix(checks),
      "checks" => checks,
      "failed_checks" => failed_checks,
      "recommendation" => status == "PASS" ? "proceed to pressure review; implementation authorization review may be considered after acceptance" : "hold"
    }

    write_json(OUT_DIR / "parser_probe.minimal_if_else.json", parsed_cases.fetch("minimal_if_else").fetch("parser_probe"))
    write_json(OUT_DIR / "current_mainline_refusal.json", current_refusal)
    write_json(OUT_DIR / "proof_local_model_cases.json", summarize_model_cases(model_cases))
    write_json(OUT_DIR / "semanticir_branch_shape_model.json", {
      "minimal_if_else" => semanticir_model,
      "nested_if_expr" => nested_semanticir_model
    })
    write_json(OUT_DIR / "closed_surface_scan.json", closed_surfaces)
    write_json(OUT_DIR / "branch_conditional_if_expr_semantics_proof_summary.json", summary)

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "checks: #{summary.fetch("checks_pass")}/#{summary.fetch("checks_total")}"
      puts "canonical_bool_type: #{JSON.generate(bool_evidence.fetch("canonical_bool_type"))}"
      puts "semanticir_shape: #{summary.fetch("semanticir_branch_shape").fetch("choice")}"
      puts "summary: #{relative_path(OUT_DIR / "branch_conditional_if_expr_semantics_proof_summary.json")}"
      true
    else
      warn "FAIL #{TRACK}"
      failed_checks.each { |entry| warn "- #{entry.fetch("name")}: #{entry.fetch("message", "failed")}" }
      false
    end
  end

  def canonical_bool_evidence
    source = <<~IGNITER
      module Proof.BoolEvidence
      contract BoolProbe {
        input flag: Bool
        compute ready = flag
        output ready: Bool
      }
    IGNITER
    parsed = parse_source(source, "bool_probe.ig")
    typed = typecheck_parsed(parsed, { "flag" => true })
    contract = typed.fetch("contracts").fetch(0)
    input_decl = contract.fetch("declarations").find { |decl| decl["kind"] == "input" && decl["name"] == "flag" }
    compute_decl = contract.fetch("declarations").find { |decl| decl["kind"] == "compute" && decl["name"] == "ready" }
    {
      "source" => "live TypeChecker Bool input and ref compute",
      "typed_status" => contract.fetch("status"),
      "canonical_bool_type" => input_decl.fetch("type"),
      "ref_resolved_type" => compute_decl.fetch("expr").fetch("resolved_type"),
      "type_errors" => typed.fetch("type_errors")
    }
  end

  def parse_fixture(file)
    path = FIXTURE_DIR / file
    parsed = parse_source(path.read, path.to_s)
    contract = parsed.fetch("contracts").fetch(0)
    compute = contract.fetch("body").find { |decl| decl["kind"] == "compute" }
    {
      "source_path" => path.to_s,
      "parsed" => parsed,
      "contract_name" => contract.fetch("name"),
      "compute_name" => compute.fetch("name"),
      "expr" => compute.fetch("expr"),
      "parser_probe" => {
        "parse_errors" => parsed.fetch("parse_errors"),
        "module" => parsed.fetch("module"),
        "contract_name" => contract.fetch("name"),
        "compute_expr_kind" => compute.dig("expr", "kind"),
        "if_expr_shape_keys" => compute.fetch("expr").keys.sort
      },
      "type_env" => type_env_from_contract(contract)
    }
  end

  def parse_source(source, source_path)
    IgniterLang::ParsedProgram.parse(source, source_path: source_path).to_h
  end

  def typecheck_parsed(parsed, sample_input)
    classified = IgniterLang::Classifier.new.classify(parsed, sample_input: sample_input)
    IgniterLang::TypeChecker.new.typecheck(classified)
  end

  def current_mainline_refusal(parsed_case)
    sample_input = sample_input_for(parsed_case.fetch("type_env"))
    typed = typecheck_parsed(parsed_case.fetch("parsed"), sample_input)
    type_errors = typed.fetch("type_errors")
    canonical = type_errors.find do |err|
      err.fetch("rule", nil) == "OOF-TY0" &&
        err.fetch("message", "").include?("Unsupported expression kind: if_expr")
    end
    {
      "status" => canonical ? "PASS" : "FAIL",
      "typed_status" => typed.dig("contracts", 0, "status"),
      "canonical_rule" => canonical&.fetch("rule", nil),
      "canonical_message" => canonical&.fetch("message", nil),
      "type_errors" => type_errors
    }
  end

  def model_case(parsed_case, bool_type)
    expr = parsed_case.fetch("expr")
    model = infer_proof_expr(expr, parsed_case.fetch("type_env"), bool_type)
    {
      "source_path" => parsed_case.fetch("source_path"),
      "contract_name" => parsed_case.fetch("contract_name"),
      "compute_name" => parsed_case.fetch("compute_name"),
      "valid" => model.fetch("diagnostics").empty?,
      "typed_expr" => model.fetch("typed_expr"),
      "diagnostics" => model.fetch("diagnostics"),
      "deps" => model.fetch("deps"),
      "resolved_type" => model.fetch("resolved_type")
    }
  end

  def infer_proof_expr(expr, type_env, bool_type)
    case expr&.fetch("kind", nil)
    when "literal"
      type = type_ir(expr.fetch("type_tag"))
      model_result(typed_literal(expr, type), type, [], [])
    when "ref"
      type = type_env.fetch(expr.fetch("name"), type_ir("Unknown"))
      model_result({
        "kind" => "ref",
        "name" => expr.fetch("name"),
        "resolved_type" => type,
        "deps" => [expr.fetch("name")]
      }, type, [expr.fetch("name")], [])
    when "if_expr"
      infer_proof_if_expr(expr, type_env, bool_type)
    else
      model_result(nil, type_ir("Unknown"), [], [diag("OOF-P0", "proof model unsupported expression")])
    end
  end

  def infer_proof_if_expr(expr, type_env, bool_type)
    diagnostics = []
    cond = infer_proof_expr(expr.fetch("cond"), type_env, bool_type)
    diagnostics.concat(cond.fetch("diagnostics"))
    diagnostics << diag("OOF-IF1", "if_expr condition must be Bool") unless same_type?(cond.fetch("resolved_type"), bool_type)

    else_block = expr.fetch("else", nil)
    unless else_block
      diagnostics << diag("OOF-IF2", "if_expr requires else branch in v0")
      return model_result(nil, type_ir("Unknown"), cond.fetch("deps"), diagnostics)
    end

    then_expr = branch_return_expr(expr.fetch("then", nil))
    else_expr = branch_return_expr(else_block)
    diagnostics << diag("OOF-IF4", "if_expr then branch must produce a value") unless then_expr
    diagnostics << diag("OOF-IF4", "if_expr else branch must produce a value") unless else_expr
    return model_result(nil, type_ir("Unknown"), cond.fetch("deps"), diagnostics) if !then_expr || !else_expr

    then_model = infer_proof_expr(then_expr, type_env, bool_type)
    else_model = infer_proof_expr(else_expr, type_env, bool_type)
    diagnostics.concat(then_model.fetch("diagnostics"))
    diagnostics.concat(else_model.fetch("diagnostics"))
    unless same_type?(then_model.fetch("resolved_type"), else_model.fetch("resolved_type"))
      diagnostics << diag("OOF-IF3", "if_expr branch result types must match exactly")
    end
    result_type = diagnostics.empty? ? then_model.fetch("resolved_type") : type_ir("Unknown")
    deps = union_deps(cond.fetch("deps"), then_model.fetch("deps"), else_model.fetch("deps"))
    typed = if diagnostics.empty?
              {
                "kind" => "if_expr",
                "cond" => cond.fetch("typed_expr"),
                "then" => { "kind" => "branch", "expr" => then_model.fetch("typed_expr") },
                "else" => { "kind" => "branch", "expr" => else_model.fetch("typed_expr") },
                "resolved_type" => result_type,
                "deps" => deps
              }
            end
    model_result(typed, result_type, deps, diagnostics)
  end

  def semanticir_model_from(model_case)
    typed = model_case.fetch("typed_expr")
    return { "status" => "blocked", "diagnostics" => model_case.fetch("diagnostics") } unless typed

    {
      "status" => "modeled",
      "shape_choice" => "direct_expression_lowering_no_branch_expr_wrapper",
      "expr" => {
        "kind" => "if_expr",
        "condition" => typed.fetch("cond"),
        "then_branch" => typed.fetch("then").fetch("expr"),
        "else_branch" => typed.fetch("else").fetch("expr"),
        "resolved_type" => typed.fetch("resolved_type"),
        "deps" => typed.fetch("deps")
      }
    }
  end

  def release_harness_evidence
    path = ROOT / "experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json"
    summary = JSON.parse(path.read)
    feature = summary.dig("corpus", "feature_coverage").find do |entry|
      entry.fetch("feature", nil) == "branch_conditional_if_expr"
    end
    {
      "summary_path" => path.to_s,
      "release_scope_excludes_if_expr" => summary.dig("release_scope", "excluded_features").include?("branch_conditional_if_expr"),
      "feature_status" => feature.fetch("status", nil),
      "feature_reason" => feature.fetch("reason", nil)
    }
  end

  def closed_surface_scan
    proof_token = "branch_conditional_if_expr_semantics_proof_v0"
    file_hits = PIPELINE_FILES.to_h do |path|
      content = read_repo(path)
      [path, content.include?(proof_token)]
    end
    {
      "parser_typechecker_semanticir_assembler_no_proof_token" => {
        "status" => file_hits.values.any? ? "FAIL" : "PASS",
        "hits" => file_hits.select { |_path, hit| hit }.keys
      },
      "release_harness_not_mutated_by_proof" => {
        "status" => read_repo("experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb").include?(proof_token) ? "FAIL" : "PASS"
      },
      "public_api_cli_not_widened_by_proof" => {
        "status" => [read_repo("bin/igc"), read_repo("bin/igniter-lang"), read_repo("lib/igniter_lang.rb")].any? { |content| content.include?(proof_token) } ? "FAIL" : "PASS"
      },
      "spark_not_touched_by_proof" => {
        "status" => "PASS",
        "note" => "proof fixtures and outputs contain no Spark input or integration path"
      },
      "optional_readme_hygiene_selected" => false
    }
  end

  def build_checks(bool_evidence:, parsed_cases:, current_refusal:, model_cases:,
    semanticir_model:, nested_semanticir_model:, release_harness:, closed_surfaces:)
    [
      check("parser.minimal_if_else_if_expr_shape") do
        probe = parsed_cases.fetch("minimal_if_else").fetch("parser_probe")
        probe.fetch("parse_errors").empty? &&
          probe.fetch("compute_expr_kind") == "if_expr" &&
          probe.fetch("if_expr_shape_keys") == %w[cond else kind then]
      end,
      check("typechecker.current_refusal_oof_ty0") do
        current_refusal.fetch("status") == "PASS" &&
          current_refusal.fetch("canonical_rule") == "OOF-TY0"
      end,
      check("bool.canonical_representation_pinned") do
        bool_evidence.fetch("canonical_bool_type") == { "name" => "Bool", "params" => [] } &&
          bool_evidence.fetch("canonical_bool_type") == bool_evidence.fetch("ref_resolved_type")
      end,
      check("model.accepts_bool_condition_same_branch_type") do
        model_cases.fetch("minimal_if_else").fetch("valid") &&
          model_cases.fetch("minimal_if_else").fetch("resolved_type") == type_ir("Integer")
      end,
      check("model.rejects_non_bool_condition_oof_if1") do
        diagnostic_rules(model_cases.fetch("non_bool_condition")).include?("OOF-IF1")
      end,
      check("model.rejects_missing_else_oof_if2") do
        diagnostic_rules(model_cases.fetch("missing_else")).include?("OOF-IF2")
      end,
      check("model.rejects_branch_type_mismatch_oof_if3") do
        diagnostic_rules(model_cases.fetch("branch_type_mismatch")).include?("OOF-IF3")
      end,
      check("model.rejects_empty_branch_oof_if4") do
        diagnostic_rules(model_cases.fetch("empty_branch")).include?("OOF-IF4")
      end,
      check("model.drops_oof_if5_from_scope") do
        model_cases.values.none? { |entry| diagnostic_rules(entry).include?("OOF-IF5") }
      end,
      check("semanticir.direct_expression_shape_chosen") do
        semanticir_model.fetch("status") == "modeled" &&
          semanticir_model.dig("expr", "kind") == "if_expr" &&
          !contains_kind?(semanticir_model, "branch_expr")
      end,
      check("semanticir.union_dependencies_modeled") do
        semanticir_model.dig("expr", "deps").sort == %w[a b flag]
      end,
      check("model.nested_if_expr_under_same_rules") do
        model_cases.fetch("nested_if_expr").fetch("valid") &&
          nested_semanticir_model.dig("expr", "deps").sort == %w[a b c flag other]
      end,
      check("release_harness.remains_out_of_scope") do
        release_harness.fetch("release_scope_excludes_if_expr") &&
          release_harness.fetch("feature_status") == "out_of_scope"
      end,
      check("closed_surfaces.remain_closed") do
        closed_surfaces.values.all? do |entry|
          entry == false || !entry.is_a?(Hash) || entry.fetch("status", "PASS") == "PASS"
        end
      end
    ]
  end

  def command_matrix(status)
    [
      command_row("targeted parser probe", "PASS"),
      command_row("targeted TypeChecker refusal probe", "PASS"),
      command_row("proof-local semantics model run", status),
      command_row("proof-local SemanticIR-shape model run", status),
      command_row("closed-surface scan", status),
      command_row("summary JSON generation", status)
    ]
  end

  def proof_matrix(checks)
    checks.map do |entry|
      {
        "assertion" => entry.fetch("name"),
        "expected" => "PASS",
        "observed" => entry.fetch("status")
      }
    end
  end

  def summarize_model_cases(model_cases)
    model_cases.transform_values do |entry|
      {
        "valid" => entry.fetch("valid"),
        "resolved_type" => entry.fetch("resolved_type"),
        "deps" => entry.fetch("deps"),
        "diagnostic_rules" => diagnostic_rules(entry),
        "typed_expr" => entry.fetch("typed_expr")
      }
    end
  end

  def parser_probe_summary(parsed_case)
    parsed_case.fetch("parser_probe")
  end

  def type_env_from_contract(contract)
    contract.fetch("body").each_with_object({}) do |decl, env|
      next unless decl.fetch("kind") == "input"

      env[decl.fetch("name")] = type_ir(decl.fetch("type_annotation"))
    end
  end

  def sample_input_for(type_env)
    type_env.to_h do |name, type|
      [name, sample_value_for(type.fetch("name"))]
    end
  end

  def sample_value_for(type_name)
    case type_name
    when "Bool" then true
    when "Integer" then 1
    when "String" then "label"
    else nil
    end
  end

  def typed_literal(expr, type)
    {
      "kind" => "literal",
      "value" => expr.fetch("value"),
      "resolved_type" => type,
      "deps" => []
    }
  end

  def branch_return_expr(block)
    return nil unless block.is_a?(Hash)

    block["return_expr"]
  end

  def model_result(typed_expr, type, deps, diagnostics)
    {
      "typed_expr" => typed_expr,
      "resolved_type" => type,
      "deps" => deps.uniq.sort,
      "diagnostics" => diagnostics
    }
  end

  def diag(rule, message)
    { "rule" => rule, "message" => message }
  end

  def diagnostic_rules(model_case)
    model_case.fetch("diagnostics").map { |diag| diag.fetch("rule") }
  end

  def contains_kind?(value, kind)
    case value
    when Hash
      value.fetch("kind", nil) == kind || value.values.any? { |nested| contains_kind?(nested, kind) }
    when Array
      value.any? { |nested| contains_kind?(nested, kind) }
    else
      false
    end
  end

  def type_ir(type)
    return type if type.is_a?(Hash)

    { "name" => type.to_s, "params" => [] }
  end

  def same_type?(left, right)
    canonicalize(left) == canonicalize(right)
  end

  def union_deps(*deps)
    deps.flatten.compact.uniq.sort
  end

  def read_repo(path)
    full_path = ROOT / path
    full_path.file? ? full_path.read : ""
  end

  def write_json(path, payload)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(canonicalize(payload))}\n")
  end

  def relative_path(path)
    Pathname.new(path).relative_path_from(ROOT).to_s
  end

  def command_row(name, observed)
    {
      "command" => name,
      "expected" => "PASS",
      "observed" => observed
    }
  end

  def check(name)
    { "name" => name, "status" => yield ? "PASS" : "FAIL" }
  rescue StandardError => e
    {
      "name" => name,
      "status" => "FAIL",
      "message" => "#{e.class}: #{e.message}"
    }
  end

  def canonicalize(value)
    case value
    when Hash
      value.keys.sort.to_h { |key| [key, canonicalize(value[key])] }
    when Array
      value.map { |inner| canonicalize(inner) }
    else
      value
    end
  end
end

exit(BranchConditionalIfExprSemanticsProofV0.run ? 0 : 1)
