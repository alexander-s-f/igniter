#!/usr/bin/env ruby
# frozen_string_literal: true

# Card:  S3-R161-C2-I
# Agent: [Igniter-Lang Implementation Agent]
# Track: compiler-release-acceptance-harness-implementation-proof-v0
# Route: UPDATE
# Authorized by: S3-R161-C1-A, S3-R161-C2-S
#
# Bounded proof-local compiler release acceptance harness runner.
# Proves harness runner shape and produces harness-local proof outputs only.
# Generated outputs are proof-local harness implementation evidence only.
# NOT official RC evidence. NOT a public release claim.

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

# --- Mode gate ---
HARNESS_MODE = begin
  m = nil
  argv = ARGV.dup
  until argv.empty?
    flag = argv.shift
    m = argv.shift if flag == "--mode"
  end
  m
end

unless HARNESS_MODE == "acceptance"
  warn "Usage: ruby compiler_release_acceptance_harness_v0.rb --mode acceptance"
  exit 1
end

# Load IgniterLang via load-path (no public require widening)
$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__)) unless
  $LOAD_PATH.include?(File.expand_path("../../lib", __dir__))
require "igniter_lang"

module CompilerReleaseAcceptanceHarnessV0
  ROOT         = Pathname.new(File.expand_path("../..", __dir__))
  HARNESS_DIR  = ROOT / "experiments/compiler_release_acceptance_harness_v0"
  CORPUS_POS   = HARNESS_DIR / "corpus/positive"
  CORPUS_NEG   = HARNESS_DIR / "corpus/negative"
  FIXTURES_DIR = HARNESS_DIR / "fixtures"
  OUT_DIR      = HARNESS_DIR / "out"
  BIN          = ROOT / "bin/igc"
  LIB_PATH     = ROOT / "lib"

  SUMMARY_PATH = OUT_DIR / "compiler_release_acceptance_harness_summary.json"

  FORMAT_VERSION = "0.1.0".freeze
  KIND           = "compiler_release_acceptance_harness_summary".freeze
  TRACK          = "compiler-release-acceptance-harness-implementation-proof-v0".freeze

  # R160 closed-surface token list (from design doc)
  CLOSED_SURFACE_TOKENS = %w[
    Spark
    spark
    sparkcrm
    SparkCRM
    ServiceCall
    LeadChannel
    OrdersAnalytics
    service_call_price_shadow_evidence
    service_call_override_divergence_policy
    lead_channel_seed_review_decision
    orders_analytics_evidence_coverage
    production
    Production
    production_runtime
    runtime_production
    public_demo
    demo_ready
    release_ready
    release_claim
    deployment
    deploy
    signing
    signature
    RubyGems
    gem_push
    Ledger
    TBackend
    BiHistory
    stream
    OLAP
    CompatibilityReport
    CompilationReceipt
    sidecar
    cache
    RuntimeMachine
    contract_fragment_for
  ].freeze

  # Multi-word tokens
  CLOSED_SURFACE_MULTIWORD = [
    "loader/report",
    ".ilk",
    "Gate 3",
    "root require"
  ].freeze

  # Fragment class names: allowed in JSON precedence arrays (assembler-generated metadata)
  FRAGMENT_CLASS_NAMES = %w[oof temporal stream escape epistemic core].freeze

  # Allowed context: line is a bare JSON fragment class string in a precedence array
  # e.g. '      "stream",' or '      "stream"'
  FRAGMENT_CLASS_LINE_RE = /\A\s*"(?:oof|temporal|stream|escape|epistemic|core)",?\s*\z/.freeze

  # Allowed context: "RuntimeMachine" in assembler-generated compatibility_metadata notes
  RUNTIME_MACHINE_NOTES_RE = /RuntimeMachine proof loader/.freeze

  module_function

  def ruby_bin
    RbConfig.ruby
  end

  def run_cmd(cmd)
    stdout, stderr, status = Open3.capture3(cmd)
    { "stdout" => stdout.strip, "stderr" => stderr.strip,
      "exit_status" => status.exitstatus, "success" => status.success? }
  end

  def igc_cmd(src, out, extra = nil)
    base = "#{ruby_bin} -I #{LIB_PATH} #{BIN} compile #{src} --out #{out}"
    extra ? "#{base} #{extra}" : base
  end

  # --- Load path smoke ---
  def check_load_path_smoke
    cmd = "#{ruby_bin} -I #{LIB_PATH} -e " \
          "'require \"igniter_lang\"; abort unless IgniterLang.respond_to?(:compile)'"
    r = run_cmd(cmd)
    {
      "surface"     => "repo_local_load_path_smoke",
      "kind"        => "load_path_smoke",
      "cmd"         => "ruby -I igniter-lang/lib -e " \
                       "'require \"igniter_lang\"; abort unless IgniterLang.respond_to?(:compile)'",
      "pass"        => r["success"],
      "exit_status" => r["exit_status"],
      "stderr"      => r["stderr"][0, 200]
    }
  end

  # --- CLI positive compile ---
  def run_cli_compile(src, out)
    cmd = igc_cmd(src, out)
    r   = run_cmd(cmd)
    {
      "surface"       => "repo_local_compiler_cli_positive_compile",
      "kind"          => "cli_positive_compile",
      "name"          => File.basename(src.to_s, ".ig"),
      "cmd"           => "ruby -I igniter-lang/lib igniter-lang/bin/igc compile " \
                         "#{File.basename(src.to_s)} --out #{File.basename(out.to_s)}",
      "pass"          => r["success"],
      "exit_status"   => r["exit_status"],
      "igapp_written" => Dir.exist?(out.to_s),
      "stdout"        => r["stdout"][0, 400]
    }
  end

  # --- CLI positive compile with profile source ---
  def run_cli_compile_with_profile(src, out, profile_src)
    cmd = igc_cmd(src, out, "--compiler-profile-source #{profile_src}")
    r   = run_cmd(cmd)
    {
      "surface"       => "repo_local_compiler_cli_positive_compile",
      "kind"          => "cli_positive_compile_with_profile",
      "name"          => "add_baseline_with_profile",
      "cmd"           => "ruby -I igniter-lang/lib igniter-lang/bin/igc compile " \
                         "add_baseline.ig --out add_baseline_with_profile.igapp " \
                         "--compiler-profile-source finalized_profile_source.json",
      "pass"          => r["success"],
      "exit_status"   => r["exit_status"],
      "igapp_written" => Dir.exist?(out.to_s),
      "stdout"        => r["stdout"][0, 400]
    }
  end

  # --- Ruby API compile ---
  def run_api_compile(src, out)
    orch = IgniterLang.compile(source_path: src.to_s, out_path: out.to_s)
    pass = orch.fetch("status") == "ok"
    {
      "surface"       => "repo_local_compiler_api_positive_compile",
      "kind"          => "api_positive_compile",
      "name"          => "api_add_baseline",
      "cmd"           => "IgniterLang.compile(source_path: 'add_baseline.ig', " \
                         "out_path: 'api_add_baseline.igapp')",
      "pass"          => pass,
      "status"        => orch.fetch("status"),
      "igapp_written" => Dir.exist?(out.to_s)
    }
  rescue => e
    {
      "surface" => "repo_local_compiler_api_positive_compile",
      "kind"    => "api_positive_compile",
      "name"    => "api_add_baseline",
      "pass"    => false,
      "error"   => e.message[0, 200]
    }
  end

  # --- CLI refusal (negative corpus) ---
  def run_cli_compile_expect_refusal(src, out, name)
    cmd  = igc_cmd(src, out)
    r    = run_cmd(cmd)
    pass = !r["success"] && !Dir.exist?(out.to_s)
    {
      "surface"          => "repo_local_compiler_cli_refusal",
      "kind"             => "cli_refusal",
      "name"             => name,
      "cmd"              => "ruby -I igniter-lang/lib igniter-lang/bin/igc compile " \
                            "#{File.basename(src.to_s)} --out #{name}_should_not_exist.igapp",
      "pass"             => pass,
      "exit_status"      => r["exit_status"],
      "no_igapp_written" => !Dir.exist?(out.to_s),
      "stdout"           => r["stdout"][0, 400]
    }
  end

  # --- CLI preflight: bad profile path ---
  def run_cli_bad_profile_path(src, out)
    bad = "/nonexistent/harness_proof_path/profile.json"
    cmd = igc_cmd(src, out, "--compiler-profile-source #{bad}")
    r   = run_cmd(cmd)
    pass = !r["success"] && !Dir.exist?(out.to_s)
    {
      "surface"          => "repo_local_compiler_cli_refusal",
      "kind"             => "cli_preflight_bad_path",
      "name"             => "bad_profile_path",
      "cmd"              => "ruby -I igniter-lang/lib igniter-lang/bin/igc compile " \
                            "add_baseline.ig --out ... --compiler-profile-source /nonexistent/path.json",
      "pass"             => pass,
      "exit_status"      => r["exit_status"],
      "no_igapp_written" => !Dir.exist?(out.to_s),
      "stderr"           => r["stderr"][0, 300]
    }
  end

  # --- CLI preflight: malformed JSON ---
  def run_cli_malformed_profile_json(src, out)
    malformed = FIXTURES_DIR / "malformed_profile_source.json"
    cmd  = igc_cmd(src, out, "--compiler-profile-source #{malformed}")
    r    = run_cmd(cmd)
    pass = !r["success"] && !Dir.exist?(out.to_s)
    {
      "surface"          => "repo_local_compiler_cli_refusal",
      "kind"             => "cli_preflight_malformed_json",
      "name"             => "malformed_profile_json",
      "cmd"              => "ruby -I igniter-lang/lib igniter-lang/bin/igc compile " \
                            "add_baseline.ig --out ... --compiler-profile-source malformed_profile_source.json",
      "pass"             => pass,
      "exit_status"      => r["exit_status"],
      "no_igapp_written" => !Dir.exist?(out.to_s),
      "stderr"           => r["stderr"][0, 300]
    }
  end

  # --- CLI semantic refusal (wrong_kind profile source) ---
  # Fix (S3-R163-C2-I): read the generated refusal compilation report for the
  # qualified compiler_profile_source.* diagnostic instead of relying on the
  # stdout snippet, which truncates before the diagnostics array.
  # Expected diagnostic source: wrong_kind_should_not_exist.compilation_report.json
  # Expected diagnostic: compiler_profile_source.wrong_kind
  def run_cli_semantic_refusal(src, out)
    wrong_kind = FIXTURES_DIR / "semantic_profile_source_wrong_kind.json"
    cmd  = igc_cmd(src, out, "--compiler-profile-source #{wrong_kind}")
    r    = run_cmd(cmd)

    no_igapp      = !Dir.exist?(out.to_s)
    exit_refused  = !r["success"]

    # Compute compilation report path (assembler_refused writes report next to out)
    report_path   = Pathname.new(out.to_s.delete_suffix(".igapp") + ".compilation_report.json")
    qualified_diag, diag_source, observed_diag = extract_qualified_profile_diagnostic(report_path, r["stdout"])

    # pass requires: non-zero exit, no igapp, AND has qualified diagnostic
    pass = exit_refused && no_igapp && qualified_diag

    {
      "surface"                      => "repo_local_compiler_cli_refusal",
      "kind"                         => "cli_semantic_profile_refusal",
      "name"                         => "semantic_profile_wrong_kind",
      "cmd"                          => "ruby -I igniter-lang/lib igniter-lang/bin/igc compile " \
                                        "add_baseline.ig --out ... --compiler-profile-source " \
                                        "semantic_profile_source_wrong_kind.json",
      "pass"                         => pass,
      "exit_status"                  => r["exit_status"],
      "no_igapp_written"             => no_igapp,
      "has_qualified_diagnostic"     => qualified_diag,
      "qualified_diagnostic_source"  => diag_source,
      "observed_qualified_diagnostic" => observed_diag,
      "stdout"                       => r["stdout"][0, 400]
    }
  end

  # Extract qualified compiler_profile_source.* diagnostic from the refusal report
  # or, if report is absent, from stdout. Returns [found_bool, source_label, observed_string].
  def extract_qualified_profile_diagnostic(report_path, stdout)
    if report_path.exist?
      begin
        report = JSON.parse(File.read(report_path.to_s, encoding: "utf-8"))
        diags  = report.fetch("diagnostics", [])
        hit    = diags.find { |d| d.fetch("message", "").include?("compiler_profile_source.") }
        if hit
          observed = hit["message"].to_s.split(":").first(3).join(":").strip
          return [true, "report_diagnostics", observed]
        end
      rescue => _e
        # fall through to stdout check
      end
    end
    # Fallback: stdout check (truncated; may miss diagnostics)
    if stdout.include?("compiler_profile_source.")
      return [true, "stdout_snippet", "compiler_profile_source.(stdout)"]
    end
    [false, "not_found", nil]
  end

  # --- Artifact check: compatibility_metadata.json shape ---
  def check_compatibility_metadata(igapp_dir, name)
    meta_path = Pathname.new("#{igapp_dir}/compatibility_metadata.json")
    unless meta_path.exist?
      return {
        "kind"  => "compat_meta_check",
        "name"  => name,
        "pass"  => false,
        "error" => "not found: compatibility_metadata.json in #{File.basename(igapp_dir.to_s)}"
      }
    end
    meta = JSON.parse(File.read(meta_path.to_s, encoding: "utf-8"))
    checks = {
      "kind_is_igapp_compatibility_metadata" =>
        meta["kind"] == "igapp_compatibility_metadata",
      "format_version_present" => meta.key?("format_version"),
      "canonical_artifact_present" => meta.key?("canonical_artifact"),
      "metadata_shape_only" => true
    }
    pass = checks.values.all?
    {
      "kind"                   => "compat_meta_check",
      "name"                   => name,
      "pass"                   => pass,
      "checks"                 => checks,
      "kind_value"             => meta["kind"],
      "format_version_value"   => meta["format_version"],
      "canonical_artifact"     => meta["canonical_artifact"],
      "not_public_compat_report" => true
    }
  rescue JSON::ParserError => e
    {
      "kind"  => "compat_meta_check",
      "name"  => name,
      "pass"  => false,
      "error" => "json_parse_error: #{e.message[0, 80]}"
    }
  end

  # --- Normalization: two-run stability check ---
  def check_normalization(src)
    out1 = OUT_DIR / "norm_run1.igapp"
    out2 = OUT_DIR / "norm_run2.igapp"
    r1   = run_cmd(igc_cmd(src, out1))
    r2   = run_cmd(igc_cmd(src, out2))

    excluded = %w[compiled_at source_hash artifact_hash program_id
                  semantic_ir_ref compilation_report_ref]

    unless r1["success"] && r2["success"]
      return {
        "pass"              => false,
        "strategy"          => "two_run_stability",
        "error"             => "one or both compile runs failed",
        "run1_exit"         => r1["exit_status"],
        "run2_exit"         => r2["exit_status"],
        "stable_fields"     => [],
        "normalized_fields" => ["compiled_at_excluded"],
        "excluded_fields"   => excluded
      }
    end

    sem1_path = "#{out1}/semantic_ir_program.json"
    sem2_path = "#{out2}/semantic_ir_program.json"

    sem1 = JSON.parse(File.read(sem1_path, encoding: "utf-8"))
    sem2 = JSON.parse(File.read(sem2_path, encoding: "utf-8"))

    stable = []
    compared = []

    %w[format_version kind].each do |f|
      compared << f
      stable << f if sem1[f] == sem2[f]
    end

    names1 = (sem1["contracts"] || []).map { |c| c["name"] }.sort
    names2 = (sem2["contracts"] || []).map { |c| c["name"] }.sort
    compared << "contract_names"
    stable << "contract_names" if names1 == names2

    types1 = (sem1["contracts"] || []).flat_map { |c|
      (c["inputs"] || []).map { |i| [i["name"], i["type"]] }
    }.sort
    types2 = (sem2["contracts"] || []).flat_map { |c|
      (c["inputs"] || []).map { |i| [i["name"], i["type"]] }
    }.sort
    compared << "input_type_signatures"
    stable << "input_type_signatures" if types1 == types2

    pass = stable.length == compared.length
    {
      "pass"              => pass,
      "strategy"          => "two_run_stability",
      "stable_fields"     => stable,
      "normalized_fields" => ["compiled_at_excluded"],
      "excluded_fields"   => excluded,
      "fields_compared"   => compared.length,
      "fields_stable"     => stable.length
    }
  rescue => e
    {
      "pass"              => false,
      "strategy"          => "two_run_stability",
      "error"             => e.message[0, 200],
      "stable_fields"     => [],
      "normalized_fields" => ["compiled_at_excluded"],
      "excluded_fields"   => excluded
    }
  end

  # --- Branch/conditional HOLD check ---
  # TypeChecker does not support if_expr (OOF-TY0 Unsupported expression kind: if_expr).
  # Branch/conditional coverage requires new semantics and is HOLD per C1-A NB-1.
  # Multi-input diversity is satisfied by mixed input types (Integer + Bool) in
  # multi_input_diverse.ig (compile unit 4 of 5).
  def check_branch_conditional
    {
      "hold"   => true,
      "reason" => "branch_conditional_if_expr_unsupported: TypeChecker does not support " \
                  "if_expr (OOF-TY0 Unsupported expression kind: if_expr). " \
                  "Branch/conditional coverage requires new semantics and is HOLD per C1-A NB-1. " \
                  "Multi-input diversity satisfied via mixed input types (Integer + Bool) " \
                  "in multi_input_diverse corpus entry (compile unit 4 of 5).",
      "nb1_disposition" => "multi_input_diversity_achieved_via_mixed_types"
    }
  end

  # --- Closed-surface scan ---
  # Scan targets: positive/negative .ig corpus files + generated igapp JSON artifacts.
  # Allowed-context exceptions:
  #   - FRAGMENT_CLASS_LINE_RE: "stream" (and other fragment class names) as bare JSON
  #     string in precedence arrays (assembler-generated manifest.json metadata)
  #   - RUNTIME_MACHINE_NOTES_RE: "RuntimeMachine" in compatibility_metadata.json notes
  #     (assembler-generated metadata, not a public surface claim)
  def run_closed_surface_scan(pos_sources, neg_sources)
    targets = pos_sources.map(&:to_s) + neg_sources.map(&:to_s)
    Dir[OUT_DIR / "*.igapp" / "*.json"].sort.each { |f| targets << f }

    hits = []
    all_tokens = CLOSED_SURFACE_TOKENS + CLOSED_SURFACE_MULTIWORD

    targets.each do |path|
      next unless File.exist?(path)
      basename = File.basename(path)
      begin
        content = File.read(path, encoding: "utf-8")
      rescue => _e
        next
      end
      content.each_line.with_index(1) do |line, lineno|
        all_tokens.each do |token|
          next unless line.include?(token)
          # Allowed: fragment class name as bare JSON string in precedence array
          next if FRAGMENT_CLASS_LINE_RE.match?(line) && FRAGMENT_CLASS_NAMES.include?(token)
          # Allowed: RuntimeMachine in assembler-generated compatibility_metadata notes
          next if token == "RuntimeMachine" && RUNTIME_MACHINE_NOTES_RE.match?(line)
          hits << "#{basename}:#{lineno}: token=#{token.inspect}"
        end
      end
    end

    {
      "token_list"    => all_tokens,
      "scan_targets"  => targets.map { |p| File.basename(p) },
      "hits"          => hits.uniq,
      "hits_count"    => hits.uniq.length,
      "status"        => hits.empty? ? "PASS" : "HOLD",
      "allowed_context_exceptions" => [
        "fragment_class_names_in_precedence_arrays",
        "runtime_machine_in_compatibility_metadata_notes"
      ]
    }
  end

  # --- Warnings check in igapp manifest ---
  def check_warnings_in_igapp(igapp_dir, name)
    manifest_path = Pathname.new("#{igapp_dir}/manifest.json")
    return { "name" => name, "unexpected_warning" => false, "detail" => "no_manifest" } unless
      manifest_path.exist?
    manifest = JSON.parse(File.read(manifest_path.to_s, encoding: "utf-8"))
    warnings = manifest["warnings"] || []
    {
      "name"               => name,
      "unexpected_warning" => !warnings.empty?,
      "warnings_count"     => warnings.length,
      "detail"             => warnings.empty? ? "none" : warnings.first.to_s[0, 100]
    }
  rescue => e
    { "name" => name, "unexpected_warning" => false, "error" => e.message[0, 100] }
  end

  # --- Feature coverage declaration ---
  def feature_coverage_list
    [
      {
        "feature"      => "add_style_baseline",
        "status"       => "covered",
        "corpus_entry" => "add_baseline"
      },
      {
        "feature"      => "boolean_gate_conjunction",
        "status"       => "covered",
        "corpus_entry" => "boolean_gate"
      },
      {
        "feature"      => "integer_arithmetic_multi_input",
        "status"       => "covered",
        "corpus_entry" => "integer_arithmetic",
        "note"         => "computed node depends on more than two inputs via chained computes"
      },
      {
        "feature"      => "multi_input_diverse_mixed_types",
        "status"       => "covered",
        "corpus_entry" => "multi_input_diverse",
        "nb1_note"     => "satisfies NB-1 mixed input types: Integer + Bool in same contract"
      },
      {
        "feature"      => "poc_derived_synthetic",
        "status"       => "covered",
        "corpus_entry" => "poc_derived"
      },
      {
        "feature"      => "branch_conditional_if_expr",
        "status"       => "hold",
        "reason"       => "TypeChecker does not support if_expr; requires new semantics per C1-A NB-1"
      }
    ]
  end

  # --- Non-claims ---
  def non_claims_list
    [
      "no_official_rc_evidence: generated outputs are proof-local harness evidence only",
      "no_release_execution: release execution not authorized",
      "no_public_demo_claim: public demo claims not authorized by C1-A",
      "no_spark_integration: Spark remains sanitized future fixture/design pressure only",
      "no_ruby_framework_release: Ruby Framework held until stable Lang RC export fixture",
      "no_public_api_cli_widening: runner uses existing compiler CLI/API/load-path surfaces only",
      "no_compatibility_report_public: compatibility_metadata.json checked as shape only",
      "no_rubygems_push: no gem tag, package, or publish",
      "no_production_runtime: proof-local runtime smoke only; not a production runtime claim",
      "no_public_analyzer_tracer_visualizer: internal machine-readable summary only"
    ]
  end

  # --- Artifact map ---
  def artifact_map
    artifacts = {}
    Dir[OUT_DIR / "*.igapp"].sort.each do |d|
      name = File.basename(d, ".igapp")
      artifacts[name] = {
        "path"  => Pathname.new(d).relative_path_from(ROOT.parent).to_s,
        "kind"  => "igapp_dir",
        "files" => Dir[File.join(d, "*.json")].map { |f| File.basename(f) }.sort
      }
    end
    artifacts["summary"] = {
      "path" => SUMMARY_PATH.relative_path_from(ROOT.parent).to_s,
      "kind" => "harness_summary_json"
    }
    artifacts
  end

  # --- Build summary ---
  def build_summary(
    status:, pos_corpus:, neg_corpus:, command_matrix:,
    artifact_checks:, normalization:, scan:, failed_checks:, hold_reasons:
  )
    {
      "kind"           => KIND,
      "format_version" => FORMAT_VERSION,
      "track"          => TRACK,
      "status"         => status,
      "decision"       => "bounded proof-local harness runner implementation; " \
                          "outputs are proof-local harness implementation evidence only; " \
                          "not official RC evidence",
      "release_scope"  => {
        "scope"                         => "repo_local_compiler_rc",
        "claimed_surfaces"              => %w[
          repo_local_compiler_cli_positive_compile
          repo_local_compiler_cli_refusal
          repo_local_compiler_api_positive_compile
          repo_local_load_path_smoke
          proof_local_runtime_smoke
        ],
        "public_claims_authorized"      => false,
        "production_runtime_authorized" => false
      },
      "corpus"         => {
        "positive"         => pos_corpus,
        "negative"         => neg_corpus,
        "feature_coverage" => feature_coverage_list
      },
      "command_matrix"  => command_matrix,
      "artifact_checks" => artifact_checks,
      "normalization"   => normalization,
      "warnings_policy" => {
        "result_shape_in_scope"              => true,
        "warning_producing_fixture_required" => false,
        "unexpected_warning_result"          => "HOLD"
      },
      "closed_surface_scan" => scan,
      "non_claims"          => non_claims_list,
      "failed_checks"       => failed_checks,
      "hold_reasons"        => hold_reasons,
      "artifacts"           => artifact_map
    }
  end

  # --- Main run ---
  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    failed_checks   = []
    hold_reasons    = []
    command_matrix  = []
    artifact_checks = []
    pos_corpus      = []
    neg_corpus      = []

    # 1. Load path smoke
    lp = check_load_path_smoke
    command_matrix << lp
    failed_checks << "load_path_smoke" unless lp["pass"]

    # 2. Positive corpus: CLI compile (5 units)
    positive_sources = Dir[CORPUS_POS / "*.ig"].sort
    positive_sources.each do |src|
      name = File.basename(src, ".ig")
      out  = OUT_DIR / "#{name}.igapp"
      r    = run_cli_compile(src, out)
      pos_corpus << r
      command_matrix << r
      failed_checks << "positive_cli.#{name}" unless r["pass"]
    end

    # 3. Positive corpus: CLI compile with finalized profile source
    profile_fixture = FIXTURES_DIR / "finalized_profile_source.json"
    if profile_fixture.exist?
      src = CORPUS_POS / "add_baseline.ig"
      out = OUT_DIR / "add_baseline_with_profile.igapp"
      r   = run_cli_compile_with_profile(src, out, profile_fixture)
      command_matrix << r
      failed_checks << "positive_cli_with_profile.add_baseline" unless r["pass"]
    else
      failed_checks << "fixture.finalized_profile_source_missing"
    end

    # 4. Ruby API compile
    api_out = OUT_DIR / "api_add_baseline.igapp"
    api_r   = run_api_compile(CORPUS_POS / "add_baseline.ig", api_out)
    command_matrix << api_r
    failed_checks << "api_compile.add_baseline" unless api_r["pass"]

    # 5. Negative corpus: CLI refusal (3 units)
    negative_sources = Dir[CORPUS_NEG / "*.ig"].sort
    negative_sources.each do |src|
      name = File.basename(src, ".ig")
      out  = OUT_DIR / "#{name}_should_not_exist.igapp"
      r    = run_cli_compile_expect_refusal(src, out, name)
      neg_corpus << r
      command_matrix << r
      failed_checks << "negative_cli.#{name}" unless r["pass"]
      if Dir.exist?(out.to_s)
        failed_checks << "negative_cli.#{name}.forbidden_igapp_write"
      end
    end

    # 6. CLI preflight refusals
    bad_path_r = run_cli_bad_profile_path(
      CORPUS_POS / "add_baseline.ig",
      OUT_DIR / "bad_path_should_not_exist.igapp"
    )
    command_matrix << bad_path_r
    failed_checks << "preflight.bad_profile_path" unless bad_path_r["pass"]

    malformed_r = run_cli_malformed_profile_json(
      CORPUS_POS / "add_baseline.ig",
      OUT_DIR / "malformed_should_not_exist.igapp"
    )
    command_matrix << malformed_r
    failed_checks << "preflight.malformed_profile_json" unless malformed_r["pass"]

    wrong_kind_r = run_cli_semantic_refusal(
      CORPUS_POS / "add_baseline.ig",
      OUT_DIR / "wrong_kind_should_not_exist.igapp"
    )
    command_matrix << wrong_kind_r
    failed_checks << "preflight.semantic_profile_wrong_kind" unless wrong_kind_r["pass"]
    unless wrong_kind_r["has_qualified_diagnostic"]
      failed_checks << "preflight.semantic_profile_wrong_kind.no_qualified_diagnostic"
    end

    # 7. Artifact checks: compatibility_metadata.json shape (NB-3)
    positive_sources.each do |src|
      name = File.basename(src, ".ig")
      out  = OUT_DIR / "#{name}.igapp"
      ac   = check_compatibility_metadata(out, name)
      artifact_checks << ac
      failed_checks << "compat_meta.#{name}" unless ac["pass"]
    end

    # 8. Normalization: two-run stability check (NB-2)
    norm = check_normalization(CORPUS_POS / "add_baseline.ig")
    failed_checks << "normalization_stability" unless norm["pass"]

    # 9. Branch/conditional: HOLD per C1-A NB-1
    branch_result = check_branch_conditional
    hold_reasons << branch_result["reason"] if branch_result["hold"]

    # 10. Warnings check: positive corpus must have zero warnings
    positive_sources.each do |src|
      name = File.basename(src, ".ig")
      out  = OUT_DIR / "#{name}.igapp"
      wc   = check_warnings_in_igapp(out, name)
      if wc["unexpected_warning"]
        hold_reasons << "unexpected_warning.#{name}: #{wc['detail']}"
      end
    end

    # 11. Closed-surface scan (NB-5)
    scan = run_closed_surface_scan(positive_sources, negative_sources)
    scan["hits"].each { |h| hold_reasons << "closed_surface_hit: #{h}" }

    # Status precedence: FAIL > HOLD > PASS (NB-5)
    status = if !failed_checks.empty?
               "FAIL"
             elsif !hold_reasons.empty?
               "HOLD"
             else
               "PASS"
             end

    summary = build_summary(
      status: status,
      pos_corpus: pos_corpus,
      neg_corpus: neg_corpus,
      command_matrix: command_matrix,
      artifact_checks: artifact_checks,
      normalization: norm,
      scan: scan,
      failed_checks: failed_checks,
      hold_reasons: hold_reasons
    )

    File.write(SUMMARY_PATH.to_s, "#{JSON.pretty_generate(summary)}\n")

    puts "#{status} compiler_release_acceptance_harness_v0"
    puts "positive_corpus_entries=#{pos_corpus.length}"
    puts "negative_corpus_entries=#{neg_corpus.length}"
    puts "command_matrix_entries=#{command_matrix.length}"
    puts "failed_checks=#{failed_checks.length}"
    puts "hold_reasons=#{hold_reasons.length}"
    puts "summary=#{SUMMARY_PATH.relative_path_from(ROOT.parent)}"

    # Return true for PASS or HOLD (harness ran; HOLD is not a runner failure)
    status == "PASS" || status == "HOLD"
  end
end

success = CompilerReleaseAcceptanceHarnessV0.run
exit(success ? 0 : 1)
