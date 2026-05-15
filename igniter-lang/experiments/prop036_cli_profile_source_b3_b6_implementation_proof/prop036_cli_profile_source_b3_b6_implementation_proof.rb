#!/usr/bin/env ruby
# frozen_string_literal: true

# Track: prop036-cli-profile-source-b3-b6-implementation-proof-v0
# Card:  S3-R50-C2-I
# Agent: [Igniter-Lang Implementation Agent]
#
# Proof for the bounded igc --compiler-profile-source PATH.json transport.

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module Prop036CliProfileSourceB3B6ImplementationProof
  ROOT = Pathname.new(File.expand_path("../..", __dir__))
  REPO_ROOT = ROOT.parent
  BIN = ROOT / "bin/igc"
  SOURCE = ROOT / "experiments/source_to_semanticir_fixture/add.ig"
  VALID_PROFILE_SOURCE =
    ROOT / "experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json"
  OUT_DIR = ROOT / "experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out"
  INPUT_DIR = OUT_DIR / "inputs"
  SUMMARY_PATH = OUT_DIR / "prop036_cli_profile_source_b3_b6_implementation_proof_summary.json"

  FORMAT_VERSION = "0.1.0"

  FORBIDDEN_EXACT_TOKENS = %w[
    absent_legacy present_verified mismatch malformed missing_required
    runtime_ready evaluation_ready gate3_authorized runtime_authority
    production_ready
  ].freeze

  ALLOWED_QUALIFIED_SOURCE_VALIDATION_TERMS = %w[
    compiler_profile_source.wrong_kind
    compiler_profile_source.unfinalized
    compiler_profile_source.runtime_authority_forbidden
  ].freeze

  module_function

  def run
    reset_output
    inputs = prepare_inputs
    cases = []

    cases << run_legacy_no_flag
    cases << run_valid_profile_source
    cases.concat(run_preflight_refusals(inputs))
    cases.concat(run_semantic_refusals(inputs))

    self_test = scanner_self_test
    scan = scan_surface(cases)
    summary = build_summary(cases, scan, self_test)

    summary_scan_hits = scan_json_value(summary, "proof_summary")
    all_hits = scan.fetch("hits") + summary_scan_hits
    summary["forbidden_exact_token_hits"] = all_hits.length
    summary["status"] = cases.all? { |c| c.fetch("pass") } && all_hits.empty? && self_test.values.all? ? "PASS" : "FAIL"

    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")

    puts "#{summary.fetch("status")} prop036_cli_profile_source_b3_b6_implementation_proof"
    puts "cases=#{cases.count { |c| c.fetch("pass") }}/#{cases.length}"
    puts "forbidden_exact_token_hits=#{summary.fetch("forbidden_exact_token_hits")}"
    puts "scanner_self_test_bare_forbidden_token_fails=#{self_test.fetch("bare_forbidden_token_fails")}"
    puts "scanner_self_test_qualified_source_validation_allowed=#{self_test.fetch("qualified_source_validation_allowed")}"
    puts "summary=#{SUMMARY_PATH.relative_path_from(REPO_ROOT)}"

    summary.fetch("status") == "PASS"
  ensure
    restore_permissions
  end

  def reset_output
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(INPUT_DIR)
  end

  def prepare_inputs
    valid = JSON.parse(File.read(VALID_PROFILE_SOURCE))

    paths = {
      invalid_json: INPUT_DIR / "invalid_json.json",
      array_json: INPUT_DIR / "array_source.json",
      wrong_kind: INPUT_DIR / "wrong_kind_source.json",
      unfinalized: INPUT_DIR / "unfinalized_source.json",
      runtime_authority: INPUT_DIR / "runtime_authority_source.json",
      directory: INPUT_DIR / "directory_source",
      unreadable: INPUT_DIR / "unreadable_source.json",
      absent: INPUT_DIR / "absent_source.json"
    }

    File.write(paths.fetch(:invalid_json), "{not-json")
    File.write(paths.fetch(:array_json), JSON.pretty_generate([valid]))
    File.write(paths.fetch(:wrong_kind), JSON.pretty_generate(valid.merge("kind" => "compiler_profile_unified")))
    File.write(paths.fetch(:unfinalized), JSON.pretty_generate(valid.merge("status" => "draft")))
    File.write(paths.fetch(:runtime_authority), JSON.pretty_generate(valid.merge("runtime_authority_granted" => true)))
    FileUtils.mkdir_p(paths.fetch(:directory))
    File.write(paths.fetch(:unreadable), JSON.pretty_generate(valid))
    File.chmod(0o000, paths.fetch(:unreadable))

    paths
  end

  def restore_permissions
    unreadable = INPUT_DIR / "unreadable_source.json"
    File.chmod(0o644, unreadable) if unreadable.exist?
  rescue Errno::ENOENT
    nil
  end

  def igc_command(args)
    [RbConfig.ruby, "-I", (ROOT / "lib").to_s, BIN.to_s, *args]
  end

  def run_igc(label, args)
    command = igc_command(args)
    stdout, stderr, status = Open3.capture3(*command)
    {
      "label" => label,
      "command" => command.map(&:to_s).join(" "),
      "exitstatus" => status.exitstatus,
      "stdout" => stdout,
      "stderr" => stderr
    }
  end

  def run_legacy_no_flag
    out = OUT_DIR / "legacy_no_flag.igapp"
    result = run_igc("B4.legacy_no_flag", ["compile", SOURCE.to_s, "--out", out.to_s])
    manifest = read_manifest(out)
    pass = result.fetch("exitstatus").zero? &&
           compiler_result_json?(result.fetch("stdout")) &&
           result.fetch("stderr").empty? &&
           out.join("manifest.json").file? &&
           !manifest.key?("compiler_profile_id")

    case_record(result, pass, "B4", out_path: out, stdout_shape: "compiler_result_json",
                              stderr_text: result.fetch("stderr"),
                              artifact_paths: igapp_json_paths(out))
  end

  def run_valid_profile_source
    out = OUT_DIR / "valid_profile_source.igapp"
    result = run_igc(
      "valid_profile_source_success",
      ["compile", SOURCE.to_s, "--out", out.to_s, "--compiler-profile-source", VALID_PROFILE_SOURCE.to_s]
    )
    manifest = read_manifest(out)
    expected_id = JSON.parse(File.read(VALID_PROFILE_SOURCE)).fetch("compiler_profile_id")
    pass = result.fetch("exitstatus").zero? &&
           compiler_result_json?(result.fetch("stdout")) &&
           result.fetch("stderr").empty? &&
           out.join("manifest.json").file? &&
           manifest.fetch("compiler_profile_id") == expected_id

    case_record(result, pass, "valid_profile_source", out_path: out,
                                             stdout_shape: "compiler_result_json",
                                             stderr_text: result.fetch("stderr"),
                                             artifact_paths: igapp_json_paths(out),
                                             compiler_profile_id: manifest["compiler_profile_id"])
  end

  def run_preflight_refusals(inputs)
    cases = []
    cases << preflight_case(
      "B3.missing_profile_path",
      ["compile", SOURCE.to_s, "--out", (OUT_DIR / "b3_missing_path.igapp").to_s, "--compiler-profile-source"],
      OUT_DIR / "b3_missing_path.igapp",
      "--compiler-profile-source requires PATH.json"
    )
    cases << preflight_case(
      "B3.profile_path_not_found",
      ["compile", SOURCE.to_s, "--out", (OUT_DIR / "b3_not_found.igapp").to_s,
       "--compiler-profile-source", inputs.fetch(:absent).to_s],
      OUT_DIR / "b3_not_found.igapp",
      "compiler profile source path not found"
    )
    cases << preflight_case(
      "B3.profile_path_not_regular_file",
      ["compile", SOURCE.to_s, "--out", (OUT_DIR / "b3_directory.igapp").to_s,
       "--compiler-profile-source", inputs.fetch(:directory).to_s],
      OUT_DIR / "b3_directory.igapp",
      "compiler profile source path must be a regular file"
    )
    cases << unreadable_case(inputs)
    cases << preflight_case(
      "B3.invalid_json",
      ["compile", SOURCE.to_s, "--out", (OUT_DIR / "b3_invalid_json.igapp").to_s,
       "--compiler-profile-source", inputs.fetch(:invalid_json).to_s],
      OUT_DIR / "b3_invalid_json.igapp",
      "compiler profile source file must contain valid JSON",
      raw_content_forbidden: "{not-json"
    )
    cases << preflight_case(
      "B3.top_level_not_object",
      ["compile", SOURCE.to_s, "--out", (OUT_DIR / "b3_array_json.igapp").to_s,
       "--compiler-profile-source", inputs.fetch(:array_json).to_s],
      OUT_DIR / "b3_array_json.igapp",
      "compiler profile source JSON must be an object"
    )
    cases << preflight_case(
      "B3.unsupported_extra_argument",
      ["compile", SOURCE.to_s, "--out", (OUT_DIR / "b3_extra.igapp").to_s,
       "--compiler-profile-source", VALID_PROFILE_SOURCE.to_s, "--extra"],
      OUT_DIR / "b3_extra.igapp",
      "unsupported argument for igc compile"
    )
    cases
  end

  def unreadable_case(inputs)
    out = OUT_DIR / "b3_unreadable.igapp"
    path = inputs.fetch(:unreadable)
    if File.readable?(path)
      result = {
        "label" => "B3.unreadable_path_environment_constrained",
        "command" => "not run; chmod 000 remained readable in this environment",
        "exitstatus" => nil,
        "stdout" => "",
        "stderr" => ""
      }
      return case_record(result, true, "B3", out_path: out, stdout_shape: "empty",
                                            stderr_text: "",
                                            artifact_paths: [],
                                            environment_constrained: true)
    end

    preflight_case(
      "B3.unreadable_path",
      ["compile", SOURCE.to_s, "--out", out.to_s, "--compiler-profile-source", path.to_s],
      out,
      "compiler profile source path is not readable"
    )
  end

  def preflight_case(label, args, out_path, expected_stderr, raw_content_forbidden: nil)
    result = run_igc(label, args)
    stderr_lines = result.fetch("stderr").lines
    pass = !result.fetch("exitstatus").zero? &&
           result.fetch("stdout").empty? &&
           stderr_lines.length == 1 &&
           stderr_lines.first&.chomp == expected_stderr &&
           !out_path.exist? &&
           !report_path_for(out_path).exist?
    pass &&= !result.fetch("stderr").include?(raw_content_forbidden) if raw_content_forbidden

    case_record(result, pass, "B3", out_path: out_path, stdout_shape: "empty",
                                      stderr_text: result.fetch("stderr"),
                                      artifact_paths: [])
  end

  def run_semantic_refusals(inputs)
    [
      semantic_case("B5.wrong_kind", inputs.fetch(:wrong_kind), "compiler_profile_source.wrong_kind"),
      semantic_case("B5.unfinalized_status", inputs.fetch(:unfinalized), "compiler_profile_source.unfinalized"),
      semantic_case(
        "B5.runtime_authority_requested",
        inputs.fetch(:runtime_authority),
        "compiler_profile_source.runtime_authority_forbidden"
      )
    ]
  end

  def semantic_case(label, source_path, expected_reason)
    out = OUT_DIR / "#{label.tr(".", "_")}.igapp"
    result = run_igc(label, ["compile", SOURCE.to_s, "--out", out.to_s, "--compiler-profile-source", source_path.to_s])
    report_path = report_path_for(out)
    stdout_json = parse_json_or_nil(result.fetch("stdout"))
    report_text = report_path.exist? ? File.read(report_path) : ""
    pass = !result.fetch("exitstatus").zero? &&
           stdout_json&.fetch("kind", nil) == "compiler_result" &&
           result.fetch("stderr").empty? &&
           report_path.file? &&
           !out.exist? &&
           report_text.include?(expected_reason)

    case_record(result, pass, "B5", out_path: out, stdout_shape: "compiler_result_json",
                                      stderr_text: result.fetch("stderr"),
                                      artifact_paths: [report_path.relative_path_from(REPO_ROOT).to_s],
                                      expected_reason: expected_reason)
  end

  def case_record(result, pass, blocker, out_path:, stdout_shape:, stderr_text:, artifact_paths:, **extra)
    {
      "name" => result.fetch("label"),
      "blocker" => blocker,
      "pass" => pass,
      "command" => result.fetch("command"),
      "exitstatus" => result.fetch("exitstatus"),
      "stdout_shape" => stdout_shape,
      "stderr_text" => stderr_text,
      "artifact_paths" => artifact_paths,
      "out_path" => out_path.relative_path_from(REPO_ROOT).to_s,
      "stdout" => result.fetch("stdout"),
      "stderr" => result.fetch("stderr")
    }.merge(extra.transform_keys(&:to_s))
  end

  def compiler_result_json?(stdout)
    parse_json_or_nil(stdout)&.fetch("kind", nil) == "compiler_result"
  end

  def parse_json_or_nil(text)
    JSON.parse(text)
  rescue JSON::ParserError
    nil
  end

  def read_manifest(path)
    JSON.parse(File.read(Pathname.new(path) / "manifest.json"))
  end

  def igapp_json_paths(path)
    Dir.glob((Pathname.new(path) / "**/*.json").to_s).sort.map do |file|
      Pathname.new(file).relative_path_from(REPO_ROOT).to_s
    end
  end

  def report_path_for(out_path)
    raw = out_path.to_s
    Pathname.new(raw.end_with?(".igapp") ? "#{raw.delete_suffix(".igapp")}.compilation_report.json" : "#{raw}.compilation_report.json")
  end

  def scanner_self_test
    {
      "bare_forbidden_token_fails" => !scan_text("runtime_ready", "self_test").empty?,
      "qualified_source_validation_allowed" =>
        scan_text("compiler_profile_source.runtime_authority_forbidden", "self_test").empty? &&
        scan_json_value("compiler_profile_source.runtime_authority_forbidden", "self_test").empty?
    }
  end

  def scan_surface(cases)
    surface = []
    hits = []

    cases.each do |record|
      surface << "stdout:#{record.fetch("name")}"
      surface << "stderr:#{record.fetch("name")}"
      hits.concat(scan_text(record.fetch("stdout"), "stdout:#{record.fetch("name")}"))
      hits.concat(scan_text(record.fetch("stderr"), "stderr:#{record.fetch("name")}"))
    end

    json_files = Dir.glob((OUT_DIR / "**/*.json").to_s).sort.map { |path| Pathname.new(path) }
                    .reject { |path| path.to_s.start_with?(INPUT_DIR.to_s) }
    json_files.each do |path|
      surface << path.relative_path_from(REPO_ROOT).to_s
      hits.concat(scan_json_value(JSON.parse(File.read(path)), path.relative_path_from(REPO_ROOT).to_s))
    end

    { "surface" => surface, "hits" => hits }
  end

  def scan_text(text, label)
    text.scan(/[A-Za-z0-9_]+/).filter_map do |token|
      { "surface" => label, "token" => token } if FORBIDDEN_EXACT_TOKENS.include?(token)
    end
  end

  def scan_json_value(value, label, path = [], hits = [])
    case value
    when Hash
      value.each do |key, nested|
        hits << { "surface" => label, "kind" => "key", "path" => (path + [key]).join(".") } \
          if FORBIDDEN_EXACT_TOKENS.include?(key)
        scan_json_value(nested, label, path + [key], hits)
      end
    when Array
      value.each_with_index { |nested, index| scan_json_value(nested, label, path + [index], hits) }
    else
      hits << { "surface" => label, "kind" => "value", "path" => path.join(".") } \
        if FORBIDDEN_EXACT_TOKENS.include?(value)
    end
    hits
  end

  def build_summary(cases, scan, self_test)
    {
      "kind" => "prop036_cli_profile_source_b3_b6_implementation_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => "prop036-cli-profile-source-b3-b6-implementation-proof-v0",
      "status" => "PENDING",
      "cases" => cases,
      "commands" => cases.map { |record| record.fetch("command") }.uniq,
      "exitstatus" => cases.to_h { |record| [record.fetch("name"), record.fetch("exitstatus")] },
      "stdout_shape" => cases.to_h { |record| [record.fetch("name"), record.fetch("stdout_shape")] },
      "stderr_text" => cases.to_h { |record| [record.fetch("name"), record.fetch("stderr_text")] },
      "artifact_paths" => cases.to_h { |record| [record.fetch("name"), record.fetch("artifact_paths")] },
      "scan_surface" => scan.fetch("surface") + ["proof_summary"],
      "forbidden_exact_token_hits" => nil,
      "scanner_self_test_bare_forbidden_token_fails" => self_test.fetch("bare_forbidden_token_fails"),
      "scanner_self_test_qualified_source_validation_allowed" =>
        self_test.fetch("qualified_source_validation_allowed"),
      "allowed_qualified_source_validation_terms" => ALLOWED_QUALIFIED_SOURCE_VALIDATION_TERMS,
      "legacy_no_flag_manifest_omits_compiler_profile_id" =>
        cases.find { |record| record.fetch("name") == "B4.legacy_no_flag" }&.fetch("pass"),
      "valid_profile_source_manifest_emits_compiler_profile_id" =>
        cases.find { |record| record.fetch("name") == "valid_profile_source_success" }&.fetch("pass"),
      "invalid_profile_source_no_igapp" =>
        cases.select { |record| record.fetch("blocker") == "B5" }.all? { |record| record.fetch("pass") },
      "non_authorizations" => {
        "profile_source_discovery" => false,
        "profile_source_defaulting" => false,
        "profile_source_finalization_in_cli" => false,
        "inline_json_cli_input" => false,
        "compatibility_report_profile_section" => false,
        "dispatch_migration" => false,
        "runtime_machine_binding" => false,
        "ledger_tbackend" => false,
        "production_behavior" => false
      }
    }
  end
end

exit(Prop036CliProfileSourceB3B6ImplementationProof.run ? 0 : 1)
