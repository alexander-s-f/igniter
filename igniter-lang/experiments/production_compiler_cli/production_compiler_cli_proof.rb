#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

require_relative "../../lib/igniter_lang"

module ProductionCompilerCLIProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  BIN = LANG_ROOT / "bin/igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/source_to_semanticir_fixture"
  OUT_DIR = LANG_ROOT / "experiments/production_compiler_cli/out"
  API_OUT = Pathname.new("/private/tmp/igniter_lang_compiler_package_boundary_direct_api.igapp")
  SUMMARY_PATH = LANG_ROOT / "experiments/production_compiler_cli/production_compiler_cli_summary.json"

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.rm_rf(API_OUT)
    FileUtils.mkdir_p(OUT_DIR)

    add_result = compile(
      source: FIXTURE_DIR / "add.ig",
      out: OUT_DIR / "add.igapp"
    )
    negative_result = compile(
      source: FIXTURE_DIR / "negative_unresolved_symbol.ig",
      out: OUT_DIR / "negative_unresolved_symbol.igapp"
    )
    direct_api_result = direct_api_compile(
      source: FIXTURE_DIR / "add.ig",
      out: API_OUT
    )
    load_path_result = load_path_smoke

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
        negative_result.dig("json", "warnings") == [],
      "package_boundary.direct_api_compile_ok" => direct_api_result.fetch("status") == "ok" &&
        direct_api_result.dig("result", "status") == "ok" &&
        direct_api_result.fetch("igapp_exists"),
      "package_boundary.cli_and_api_same_facade_shape" => direct_api_result.dig("result", "program_id") == add_result.dig("json", "program_id") &&
        direct_api_result.dig("result", "source_hash") == add_result.dig("json", "source_hash") &&
        direct_api_result.dig("result", "contracts") == add_result.dig("json", "contracts") &&
        direct_api_result.dig("result", "stages", "assemble") == add_result.dig("json", "stages", "assemble"),
      "package_boundary.lib_load_path_facade" => load_path_result.fetch("exitstatus").zero? &&
        load_path_result.fetch("stdout").include?("compile=true") &&
        load_path_result.fetch("stdout").include?("orchestrator=constant")
    }
    summary = {
      "kind" => "production_compiler_cli_proof",
      "format_version" => "0.1.0",
      "track" => "compiler-package-boundary-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "checks" => checks,
      "positive" => add_result,
      "negative" => negative_result,
      "direct_api" => direct_api_result,
      "load_path" => load_path_result
    }
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def direct_api_compile(source:, out:)
    orchestration = IgniterLang.compile(
      source_path: source,
      out_path: out,
      sample_input: { "a" => 2, "b" => 3 }
    )
    {
      "command" => "ruby-api IgniterLang.compile #{source.relative_path_from(ROOT)} --out #{out.relative_path_from(ROOT)}",
      "status" => orchestration.fetch("status"),
      "result" => orchestration.fetch("result"),
      "igapp_exists" => (out / "manifest.json").file?
    }
  end

  def load_path_smoke
    script = [
      "require 'igniter_lang'",
      "puts \"compile=#{IgniterLang.respond_to?(:compile)}\"",
      "puts \"orchestrator=#{defined?(IgniterLang::CompilerOrchestrator) ? 'constant' : 'missing'}\""
    ].join("; ")
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      "-I",
      (LANG_ROOT / "lib").to_s,
      "-e",
      script,
      chdir: ROOT.to_s
    )
    {
      "command" => "ruby -I #{(LANG_ROOT / "lib").relative_path_from(ROOT)} -e 'require \"igniter_lang\"'",
      "exitstatus" => status.exitstatus,
      "stdout" => stdout,
      "stderr" => stderr
    }
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
    puts "direct_api.status: #{summary.dig("direct_api", "status")}"
    puts "load_path.stdout: #{summary.dig("load_path", "stdout").to_s.strip}"
    puts "negative.category: #{summary.dig("negative", "json", "diagnostics", 0, "category")}"
    puts "negative.report: #{summary.dig("negative", "json", "compilation_report_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProductionCompilerCLIProof.run
exit(success ? 0 : 1)
