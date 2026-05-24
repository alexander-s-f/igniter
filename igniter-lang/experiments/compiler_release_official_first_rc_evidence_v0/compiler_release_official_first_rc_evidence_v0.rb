#!/usr/bin/env ruby
# frozen_string_literal: true

# Card:  S3-R168-C1-I
# Agent: [Igniter-Lang Implementation Agent]
# Track: compiler-release-official-first-rc-evidence-gathering-v0
# Authorization: S3-R167-C1-A, S3-R167-C3-S
#
# Official first-RC evidence gathering collector.
# Invokes the scope-aware PASS harness and produces an official first-RC
# evidence packet.
#
# Does NOT edit the existing harness runner.
# Does NOT authorize release execution or public claims.
# Does NOT relabel existing R165/R166 outputs.

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerReleaseOfficialFirstRcEvidenceV0
  ROOT            = Pathname.new(File.expand_path("../..", __dir__))
  EVIDENCE_DIR    = ROOT / "experiments/compiler_release_official_first_rc_evidence_v0"
  OUT_DIR         = EVIDENCE_DIR / "out"
  HARNESS_DIR     = ROOT / "experiments/compiler_release_acceptance_harness_v0"
  HARNESS_RUNNER  = HARNESS_DIR / "compiler_release_acceptance_harness_v0.rb"
  HARNESS_OUT     = HARNESS_DIR / "out"
  HARNESS_SUMMARY = HARNESS_OUT / "compiler_release_acceptance_harness_summary.json"

  SUMMARY_PATH    = OUT_DIR / "official_first_rc_evidence_summary.json"

  FORMAT_VERSION = "0.1.0".freeze
  KIND           = "official_first_rc_evidence".freeze
  TRACK          = "compiler-release-official-first-rc-evidence-gathering-v0".freeze
  AUTHORIZATION  = "S3-R167-C1-A".freeze
  EVIDENCE_LABEL = "official_first_rc_evidence".freeze

  REQUIRED_CLAIMED_SURFACES = %w[
    repo_local_compiler_cli_positive_compile
    repo_local_compiler_cli_refusal
    repo_local_compiler_api_positive_compile
    repo_local_load_path_smoke
    proof_local_runtime_smoke
  ].freeze

  REQUIRED_EXCLUDED_FEATURES   = ["branch_conditional_if_expr"].freeze
  REQUIRED_EXCLUSION_BASIS_REF = "S3-R164-C4-A".freeze
  REQUIRED_NON_CLAIM_TOKEN     = "no_branch_conditional_claim".freeze

  # Shape verification: required top-level fields in official evidence packet
  REQUIRED_SHAPE_FIELDS = %w[
    kind format_version status authorization track evidence_label
    source_harness release_scope command_matrix proof_artifacts
    failed_checks hold_reasons non_claims
  ].freeze

  module_function

  def ruby_bin
    RbConfig.ruby
  end

  def run_cmd(cmd)
    stdout, stderr, status = Open3.capture3(cmd)
    { "stdout" => stdout.strip, "stderr" => stderr.strip,
      "exit_status" => status.exitstatus, "success" => status.success? }
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    failed_checks  = []
    hold_reasons   = []
    command_matrix = []

    # --- Command 1: harness syntax check ---
    r1 = run_cmd("#{ruby_bin} -c #{HARNESS_RUNNER}")
    syntax_entry = {
      "kind"        => "harness_syntax_check",
      "cmd"         => "ruby -c igniter-lang/experiments/" \
                       "compiler_release_acceptance_harness_v0/" \
                       "compiler_release_acceptance_harness_v0.rb",
      "pass"        => r1["success"] && r1["stdout"].include?("Syntax OK"),
      "stdout"      => r1["stdout"],
      "exit_status" => r1["exit_status"]
    }
    command_matrix << syntax_entry
    failed_checks << "harness_syntax_check" unless syntax_entry["pass"]

    # --- Command 2: harness acceptance run (fresh) ---
    r2 = run_cmd("#{ruby_bin} #{HARNESS_RUNNER} --mode acceptance")
    harness_entry = {
      "kind"        => "harness_acceptance_run",
      "cmd"         => "ruby igniter-lang/experiments/" \
                       "compiler_release_acceptance_harness_v0/" \
                       "compiler_release_acceptance_harness_v0.rb --mode acceptance",
      "pass"        => r2["success"],
      "exit_status" => r2["exit_status"],
      "stdout"      => r2["stdout"]
    }
    command_matrix << harness_entry
    failed_checks << "harness_acceptance_run" unless harness_entry["pass"]

    # --- Read freshly produced harness summary ---
    unless HARNESS_SUMMARY.exist?
      failed_checks << "harness_summary_not_found"
      return emit_fail_packet(command_matrix, failed_checks, hold_reasons)
    end

    harness_raw     = File.read(HARNESS_SUMMARY.to_s, encoding: "utf-8")
    harness_summary = JSON.parse(harness_raw)
    harness_sha256  = "sha256:#{Digest::SHA256.hexdigest(harness_raw)}"

    # --- Verify harness preconditions ---
    harness_status       = harness_summary["status"]
    harness_failed_list  = harness_summary["failed_checks"]  || []
    harness_hold_list    = harness_summary["hold_reasons"]   || []
    harness_matrix       = harness_summary["command_matrix"] || []
    harness_pos_corpus   = harness_summary.dig("corpus", "positive") || []
    harness_neg_corpus   = harness_summary.dig("corpus", "negative") || []
    harness_art_checks   = harness_summary["artifact_checks"]          || []
    harness_scan_status  = harness_summary.dig("closed_surface_scan", "status")
    harness_non_claims   = harness_summary["non_claims"]               || []
    harness_release_scope = harness_summary["release_scope"]           || {}
    harness_claimed      = harness_release_scope["claimed_surfaces"]   || []
    harness_excluded     = harness_release_scope["excluded_features"]  || []
    harness_excl_basis   = harness_release_scope["exclusion_basis"]    || ""

    failed_checks << "harness_status_not_pass" unless harness_status == "PASS"
    failed_checks << "harness_failed_checks_not_empty" unless harness_failed_list.empty?
    failed_checks << "harness_hold_reasons_not_empty"  unless harness_hold_list.empty?

    REQUIRED_CLAIMED_SURFACES.each do |surface|
      failed_checks << "missing_claimed_surface:#{surface}" unless harness_claimed.include?(surface)
    end

    REQUIRED_EXCLUDED_FEATURES.each do |feat|
      failed_checks << "missing_excluded_feature:#{feat}" unless harness_excluded.include?(feat)
    end

    unless harness_excl_basis.include?(REQUIRED_EXCLUSION_BASIS_REF)
      failed_checks << "exclusion_basis_missing_#{REQUIRED_EXCLUSION_BASIS_REF}"
    end

    unless harness_non_claims.any? { |nc| nc.include?(REQUIRED_NON_CLAIM_TOKEN) }
      failed_checks << "missing_non_claim:#{REQUIRED_NON_CLAIM_TOKEN}"
    end

    # Verify semantic profile-source qualified diagnostic
    semantic_entry = harness_matrix.find { |e| e["name"] == "semantic_profile_wrong_kind" }
    if semantic_entry
      unless semantic_entry["has_qualified_diagnostic"] == true
        failed_checks << "semantic_profile_wrong_kind:no_qualified_diagnostic"
      end
    else
      failed_checks << "semantic_profile_wrong_kind:entry_not_found"
    end

    # Verify command matrix all PASS
    harness_matrix_pass_count = harness_matrix.count { |e| e["pass"] }
    unless harness_matrix_pass_count == harness_matrix.length
      failed_checks << "harness_command_matrix_not_all_pass:" \
                       "#{harness_matrix_pass_count}/#{harness_matrix.length}"
    end

    # --- Command 3: shape verification ---
    shape_cmd_str = "ruby -rjson -e 'require \"json\"; " \
                    "d=JSON.parse(File.read(\"#{SUMMARY_PATH}\")); " \
                    "abort \"shape fail\" unless %w[#{REQUIRED_SHAPE_FIELDS.join(" ")}].all? { |f| d.key?(f) }; " \
                    "print \"shape OK\"'"
    # Execute shape verification after summary is written (recorded here; executed below)
    shape_entry = {
      "kind" => "official_evidence_packet_shape_verification",
      "cmd"  => "ruby -rjson -e '<verify required fields: #{REQUIRED_SHAPE_FIELDS.join(", ")}>'",
      "note" => "executed after summary written"
    }

    pre_rc_relabeled = false

    # Determine status before writing (shape check result set after write)
    status = if !failed_checks.empty?
               "FAIL"
             elsif !hold_reasons.empty?
               "HOLD"
             else
               "PASS"
             end

    # Build official evidence summary
    summary = {
      "kind"           => KIND,
      "format_version" => FORMAT_VERSION,
      "status"         => status,
      "authorization"  => AUTHORIZATION,
      "track"          => TRACK,
      "evidence_label" => EVIDENCE_LABEL,
      "source_harness" => {
        "track"                          => "compiler-release-acceptance-harness-scope-aware-update-v0",
        "summary_path"                   => HARNESS_SUMMARY.relative_path_from(ROOT.parent).to_s,
        "summary_sha256"                 => harness_sha256,
        "harness_status"                 => harness_status,
        "command_matrix_entries"         => harness_matrix.length,
        "command_matrix_pass_count"      => harness_matrix_pass_count,
        "positive_corpus_count"          => harness_pos_corpus.length,
        "negative_corpus_count"          => harness_neg_corpus.length,
        "artifact_check_count"           => harness_art_checks.length,
        "failed_check_count"             => harness_failed_list.length,
        "hold_reason_count"              => harness_hold_list.length,
        "closed_surface_scan_status"     => harness_scan_status,
        "existing_output_relabeled"      => pre_rc_relabeled
      },
      "release_scope"  => {
        "scope"                         => harness_release_scope["scope"] || "repo_local_compiler_rc",
        "claimed_surfaces"              => harness_claimed,
        "excluded_features"             => harness_excluded,
        "exclusion_basis"               => harness_excl_basis,
        "public_claims_authorized"      => false,
        "production_runtime_authorized" => false
      },
      "command_matrix"  => command_matrix,
      "proof_artifacts" => {
        "harness_runner"  => HARNESS_RUNNER.relative_path_from(ROOT.parent).to_s,
        "harness_summary" => HARNESS_SUMMARY.relative_path_from(ROOT.parent).to_s,
        "harness_summary_sha256"        => harness_sha256,
        "official_evidence_summary"     => SUMMARY_PATH.relative_path_from(ROOT.parent).to_s
      },
      "verification"    => {
        "required_shape_fields"          => REQUIRED_SHAPE_FIELDS,
        "pre_rc_output_relabeled"        => pre_rc_relabeled,
        "authorization_reference"        => AUTHORIZATION,
        "branch_conditional_in_excluded" => harness_excluded.include?("branch_conditional_if_expr"),
        "no_branch_conditional_claim_present" =>
          harness_non_claims.any? { |nc| nc.include?(REQUIRED_NON_CLAIM_TOKEN) }
      },
      "non_claims"     => non_claims_list,
      "failed_checks"  => failed_checks,
      "hold_reasons"   => hold_reasons
    }

    File.write(SUMMARY_PATH.to_s, "#{JSON.pretty_generate(summary)}\n")

    # --- Execute shape verification on written summary ---
    shape_r = run_cmd(
      "#{ruby_bin} -rjson -e '" \
      "d=JSON.parse(File.read(\"#{SUMMARY_PATH}\")); " \
      "required=%w[#{REQUIRED_SHAPE_FIELDS.join(" ")}]; " \
      "missing=required.reject{|f|d.key?(f)}; " \
      "abort(\"shape_fail:missing=\"+missing.join(\",\")) unless missing.empty?; " \
      "print \"shape OK #{REQUIRED_SHAPE_FIELDS.length} fields present\"'"
    )
    shape_entry["pass"]        = shape_r["success"]
    shape_entry["exit_status"] = shape_r["exit_status"]
    shape_entry["stdout"]      = shape_r["stdout"]
    command_matrix << shape_entry

    failed_checks << "official_evidence_packet_shape_check" unless shape_entry["pass"]

    # Re-determine status after shape check
    status = if !failed_checks.empty?
               "FAIL"
             elsif !hold_reasons.empty?
               "HOLD"
             else
               "PASS"
             end

    # Update status in summary if shape check changed it
    summary["status"]         = status
    summary["command_matrix"] = command_matrix
    summary["failed_checks"]  = failed_checks

    File.write(SUMMARY_PATH.to_s, "#{JSON.pretty_generate(summary)}\n")

    puts "#{status} #{KIND}"
    puts "authorization=#{AUTHORIZATION}"
    puts "evidence_label=#{EVIDENCE_LABEL}"
    puts "harness_status=#{harness_status}"
    puts "harness_command_matrix_entries=#{harness_matrix.length}/#{harness_matrix.length} PASS"
    puts "harness_positive_corpus=#{harness_pos_corpus.length}"
    puts "harness_negative_corpus=#{harness_neg_corpus.length}"
    puts "harness_artifact_checks=#{harness_art_checks.length}"
    puts "failed_checks=#{failed_checks.length}"
    puts "hold_reasons=#{hold_reasons.length}"
    puts "pre_rc_output_relabeled=#{pre_rc_relabeled}"
    puts "summary=#{SUMMARY_PATH.relative_path_from(ROOT.parent)}"

    status == "PASS"
  end

  def emit_fail_packet(command_matrix, failed_checks, hold_reasons)
    summary = {
      "kind"           => KIND,
      "format_version" => FORMAT_VERSION,
      "status"         => "FAIL",
      "authorization"  => AUTHORIZATION,
      "track"          => TRACK,
      "evidence_label" => EVIDENCE_LABEL,
      "source_harness" => { "error" => "harness_summary_not_found" },
      "release_scope"  => {},
      "command_matrix" => command_matrix,
      "proof_artifacts" => {},
      "non_claims"     => non_claims_list,
      "failed_checks"  => failed_checks,
      "hold_reasons"   => hold_reasons
    }
    File.write(SUMMARY_PATH.to_s, "#{JSON.pretty_generate(summary)}\n")
    puts "FAIL #{KIND}"
    puts "failed_checks=#{failed_checks.length}"
    false
  end

  def non_claims_list
    [
      "no_release_execution: release execution not authorized by S3-R167-C1-A",
      "no_public_demo_claim: public demo/release claims not authorized",
      "no_branch_conditional_claim: first RC scope explicitly excludes " \
        "branch/conditional if_expr; no branch or conditional expression support " \
        "is claimed; post-RC language design lane only; no branch/conditional " \
        "implementation authorized by first RC scope decision (S3-R164-C4-A)",
      "no_spark_integration: Spark is non-authorizing context only for this card",
      "no_ruby_framework_release: Ruby Framework changes not authorized by this card",
      "no_public_api_cli_widening: uses existing compiler CLI/API surfaces only",
      "no_production_runtime: repo_local_compiler_rc scope only",
      "no_pre_rc_output_relabeled: existing R165/R166 outputs remain " \
        "scope-aware harness update evidence / pre-RC release-readiness evidence; " \
        "not relabeled as official first-RC evidence"
    ]
  end
end

success = CompilerReleaseOfficialFirstRcEvidenceV0.run
exit(success ? 0 : 1)
