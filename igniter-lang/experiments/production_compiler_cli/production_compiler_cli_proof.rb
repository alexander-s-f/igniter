#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module ProductionCompilerCLIProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  BIN = LANG_ROOT / "bin/igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/source_to_semanticir_fixture"
  OUT_DIR = LANG_ROOT / "experiments/production_compiler_cli/out"
  SUMMARY_PATH = LANG_ROOT / "experiments/production_compiler_cli/production_compiler_cli_summary.json"

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    add_result = compile(
      source: FIXTURE_DIR / "add.ig",
      out: OUT_DIR / "add.igapp"
    )
    negative_result = compile(
      source: FIXTURE_DIR / "negative_unresolved_symbol.ig",
      out: OUT_DIR / "negative_unresolved_symbol.igapp"
    )

    checks = {
      "compile.add_exit_zero" => add_result.fetch("exitstatus").zero?,
      "compile.add_writes_igapp" => add_result.dig("json", "igapp_path") == (OUT_DIR / "add.igapp").to_s &&
        (OUT_DIR / "add.igapp/manifest.json").file?,
      "compile.add_stdout_shape" => add_result.dig("json", "kind") == "compiler_result" &&
        add_result.dig("json", "format_version") == "0.1.0" &&
        add_result.dig("json", "stages", "assemble") == "ok" &&
        add_result.dig("json", "warnings") == [],
      "runtime.load_output_trusted" => add_result.dig("json", "runtime_smoke", "compatibility_report_status") == "trusted",
      "runtime.evaluate_add_42" => add_result.dig("json", "runtime_smoke", "outputs", "sum") == 42,
      "compile.oof_exit_nonzero" => !negative_result.fetch("exitstatus").zero?,
      "compile.oof_writes_report" => (OUT_DIR / "negative_unresolved_symbol.compilation_report.json").file?,
      "compile.oof_writes_no_igapp" => !(OUT_DIR / "negative_unresolved_symbol.igapp").exist?,
      "compile.oof_uses_igapp_path" => negative_result.dig("json", "igapp_path").nil? &&
        !negative_result.dig("json").key?("out"),
      "compile.oof_diagnostics_have_category" => negative_result.dig("json", "diagnostics").all? do |diagnostic|
        diagnostic.fetch("category", nil) &&
          diagnostic.key?("contract") &&
          diagnostic.key?("node") &&
          diagnostic.key?("path") &&
          diagnostic.key?("span")
      end,
      "compile.oof_stages_and_warnings" => negative_result.dig("json", "stages", "assemble") == "skipped" &&
        negative_result.dig("json", "warnings") == []
    }
    summary = {
      "kind" => "production_compiler_cli_proof",
      "format_version" => "0.1.0",
      "track" => "production-compiler-diagnostics-implementation-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "checks" => checks,
      "positive" => add_result,
      "negative" => negative_result
    }
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def compile(source:, out:)
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      BIN.to_s,
      "compile",
      source.to_s,
      "--out",
      out.to_s,
      chdir: ROOT.to_s
    )
    {
      "command" => "#{BIN.relative_path_from(ROOT)} compile #{source.relative_path_from(ROOT)} --out #{out.relative_path_from(ROOT)}",
      "exitstatus" => status.exitstatus,
      "stdout" => stdout,
      "stderr" => stderr,
      "json" => parse_json(stdout)
    }
  end

  def parse_json(stdout)
    JSON.parse(stdout)
  rescue JSON::ParserError
    nil
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} production_compiler_cli_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "positive.igapp_path: #{summary.dig("positive", "json", "igapp_path")}"
    puts "positive.sum: #{summary.dig("positive", "json", "runtime_smoke", "outputs", "sum")}"
    puts "negative.category: #{summary.dig("negative", "json", "diagnostics", 0, "category")}"
    puts "negative.report: #{summary.dig("negative", "json", "compilation_report_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProductionCompilerCLIProof.run
exit(success ? 0 : 1)
