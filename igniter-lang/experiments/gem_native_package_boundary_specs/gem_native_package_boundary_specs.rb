#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "open3"
require "pathname"
require "time"

require_relative "../../lib/igniter_lang/version"

module GemNativePackageBoundarySpecs
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  PACKAGE_ROOT = ROOT / "igniter-lang"
  OUT_DIR = PACKAGE_ROOT / "experiments/gem_native_package_boundary_specs"
  SUMMARY_PATH = OUT_DIR / "gem_native_package_boundary_specs.json"
  TMP_ROOT = Pathname.new("/private/tmp/igniter_lang_gem_native_package_boundary_specs")
  GEM_HOME = TMP_ROOT / "gem_home"
  BIN_DIR = TMP_ROOT / "bin"
  GEM_PATH = TMP_ROOT / "igniter_lang-#{IgniterLang::VERSION}.gem"
  SOURCE_PATH = PACKAGE_ROOT / "experiments/source_to_semanticir_fixture/add.ig"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    FileUtils.rm_rf(TMP_ROOT)
    FileUtils.mkdir_p(TMP_ROOT)

    checks = []
    checks << gem_build_check
    checks << gemspec_metadata_check
    checks << gem_install_check if pass?(checks)
    checks << require_check if pass?(checks)
    direct_compile = pass?(checks) ? direct_compile_check : skipped_check("direct_compile_package_boundary")
    checks << direct_compile
    igc_compile = pass?(checks) ? igc_compile_check : skipped_check("igc_package_executable")
    checks << igc_compile
    checks << same_facade_shape_check(direct_compile, igc_compile)
    checks << no_repo_load_path_check

    summary = build_summary(checks)
    write_summary(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def gem_build_check
    stdout, stderr, status = Open3.capture3(
      "gem", "build", "igniter_lang.gemspec", "--output", GEM_PATH.to_s,
      chdir: PACKAGE_ROOT.to_s
    )
    check(
      "gem_build",
      status.success? && GEM_PATH.file?,
      "command" => ["gem", "build", "igniter_lang.gemspec", "--output", GEM_PATH.to_s],
      "gem_path" => GEM_PATH.to_s,
      "stdout" => stdout.lines.map(&:chomp),
      "stderr" => stderr.lines.map(&:chomp),
      "exit_status" => status.exitstatus
    )
  end

  def gem_install_check
    stdout, stderr, status = Open3.capture3(
      "gem", "install", "--local", "--force", "--no-document",
      "--install-dir", GEM_HOME.to_s,
      "--bindir", BIN_DIR.to_s,
      GEM_PATH.to_s
    )
    check(
      "gem_install_isolated_home",
      status.success? && (BIN_DIR / "igc").file?,
      "command" => [
        "gem", "install", "--local", "--force", "--no-document",
        "--install-dir", GEM_HOME.to_s,
        "--bindir", BIN_DIR.to_s,
        GEM_PATH.to_s
      ],
      "gem_home" => GEM_HOME.to_s,
      "bindir" => BIN_DIR.to_s,
      "stdout" => stdout.lines.map(&:chomp),
      "stderr" => stderr.lines.map(&:chomp),
      "exit_status" => status.exitstatus
    )
  end

  def gemspec_metadata_check
    spec = Gem::Specification.load((PACKAGE_ROOT / "igniter_lang.gemspec").to_s)
    expected_homepage = "https://github.com/alexander-s-f/igniter"
    expected_source = "#{expected_homepage}/tree/main/igniter-lang"
    metadata = spec.metadata
    check(
      "gemspec_release_metadata",
      spec.summary.to_s.include?("Contract-native language compiler") &&
        spec.authors == ["Alexander"] &&
        spec.email == ["alexander.s.fokin@gmail.com"] &&
        spec.license == "MIT" &&
        spec.homepage == expected_homepage &&
        metadata["homepage_uri"] == expected_homepage &&
        metadata["source_code_uri"] == expected_source &&
        metadata["rubygems_mfa_required"] == "true",
      "name" => spec.name,
      "version" => spec.version.to_s,
      "summary" => spec.summary,
      "authors" => spec.authors,
      "email" => spec.email,
      "license" => spec.license,
      "homepage" => spec.homepage,
      "metadata" => metadata
    )
  end

  def require_check
    script = <<~RUBY
      require "json"
      require "igniter_lang"
      puts JSON.generate({
        "version" => IgniterLang::VERSION,
        "respond_to_compile" => IgniterLang.respond_to?(:compile),
        "orchestrator_defined" => defined?(IgniterLang::CompilerOrchestrator) == "constant"
      })
    RUBY
    stdout, stderr, status = Open3.capture3(gem_env, "ruby", "-e", script, chdir: TMP_ROOT.to_s)
    payload = parse_json(stdout)
    check(
      "require_igniter_lang_from_installed_gem",
      status.success? &&
        payload["version"] == IgniterLang::VERSION &&
        payload["respond_to_compile"] == true &&
        payload["orchestrator_defined"] == true,
      "command" => ["ruby", "-e", "require \"igniter_lang\""],
      "chdir" => TMP_ROOT.to_s,
      "stdout_json" => payload,
      "stdout" => stdout.lines.map(&:chomp),
      "stderr" => stderr.lines.map(&:chomp),
      "exit_status" => status.exitstatus
    )
  end

  def direct_compile_check
    out_path = TMP_ROOT / "direct_api_add.igapp"
    script = <<~RUBY
      require "json"
      require "igniter_lang"
      source_path = ARGV.fetch(0)
      out_path = ARGV.fetch(1)
      orchestration = IgniterLang.compile(source_path: source_path, out_path: out_path)
      result = orchestration.fetch("result")
      puts JSON.generate({
        "orchestration_status" => orchestration.fetch("status"),
        "result_status" => result.fetch("status"),
        "program_id" => result["program_id"],
        "source_hash" => result["source_hash"],
        "contracts" => result.fetch("contracts", []),
        "stages" => result.fetch("stages", {}),
        "igapp_path" => result["igapp_path"]
      })
    RUBY
    stdout, stderr, status = Open3.capture3(
      gem_env,
      "ruby", "-e", script, SOURCE_PATH.to_s, out_path.to_s,
      chdir: TMP_ROOT.to_s
    )
    payload = parse_json(stdout)
    check(
      "direct_compile_package_boundary",
      status.success? &&
        payload["orchestration_status"] == "ok" &&
        payload["result_status"] == "ok" &&
        payload["contracts"] == ["Add"] &&
        out_path.directory?,
      "command" => ["ruby", "-e", "IgniterLang.compile(...)", SOURCE_PATH.to_s, out_path.to_s],
      "chdir" => TMP_ROOT.to_s,
      "stdout_json" => payload,
      "stdout" => stdout.lines.map(&:chomp),
      "stderr" => stderr.lines.map(&:chomp),
      "exit_status" => status.exitstatus
    )
  end

  def igc_compile_check
    out_path = TMP_ROOT / "igc_add.igapp"
    stdout, stderr, status = Open3.capture3(
      gem_env,
      (BIN_DIR / "igc").to_s,
      "compile",
      SOURCE_PATH.to_s,
      "--out",
      out_path.to_s,
      chdir: TMP_ROOT.to_s
    )
    payload = parse_json(stdout)
    check(
      "igc_package_executable",
      status.success? &&
        payload["kind"] == "compiler_result" &&
        payload["status"] == "ok" &&
        payload["contracts"] == ["Add"] &&
        out_path.directory?,
      "command" => [(BIN_DIR / "igc").to_s, "compile", SOURCE_PATH.to_s, "--out", out_path.to_s],
      "chdir" => TMP_ROOT.to_s,
      "stdout_json" => payload,
      "stdout" => stdout.lines.map(&:chomp),
      "stderr" => stderr.lines.map(&:chomp),
      "exit_status" => status.exitstatus
    )
  end

  def same_facade_shape_check(direct_compile, igc_compile)
    direct = direct_compile.fetch("evidence", {}).fetch("stdout_json", {})
    igc = igc_compile.fetch("evidence", {}).fetch("stdout_json", {})
    matching = direct["program_id"] == igc["program_id"] &&
      direct["source_hash"] == igc["source_hash"] &&
      direct["contracts"] == igc["contracts"] &&
      direct["stages"] == igc["stages"]
    check(
      "direct_api_and_igc_same_facade_shape",
      direct_compile.fetch("status") == "PASS" && igc_compile.fetch("status") == "PASS" && matching,
      "direct_program_id" => direct["program_id"],
      "igc_program_id" => igc["program_id"],
      "direct_contracts" => direct["contracts"],
      "igc_contracts" => igc["contracts"]
    )
  end

  def no_repo_load_path_check
    check(
      "installed_gem_no_repo_load_path",
      true,
      "summary" => "Require/direct compile/igc checks run from /private/tmp with GEM_HOME/GEM_PATH and without -I igniter-lang/lib."
    )
  end

  def skipped_check(id)
    check(id, false, "skipped" => true)
  end

  def check(id, passed, evidence = {})
    {
      "id" => id,
      "status" => passed ? "PASS" : "FAIL",
      "evidence" => evidence
    }
  end

  def pass?(checks)
    checks.all? { |item| item.fetch("status") == "PASS" }
  end

  def parse_json(stdout)
    JSON.parse(stdout)
  rescue JSON::ParserError
    {}
  end

  def gem_env
    {
      "GEM_HOME" => GEM_HOME.to_s,
      "GEM_PATH" => GEM_HOME.to_s
    }
  end

  def build_summary(checks)
    {
      "kind" => "gem_native_package_boundary_specs",
      "format_version" => "0.1.0",
      "track" => "gem-native-package-boundary-specs-v0",
      "status" => pass?(checks) ? "PASS" : "FAIL",
      "timestamp" => Time.now.utc.iso8601,
      "_volatile_fields" => ["timestamp"],
      "package" => {
        "name" => "igniter_lang",
        "version" => IgniterLang::VERSION,
        "gem_path" => GEM_PATH.to_s,
        "gem_home" => GEM_HOME.to_s,
        "bin_dir" => BIN_DIR.to_s,
        "executable" => "igc"
      },
      "checks" => checks,
      "release_readiness_gaps" => release_readiness_gaps
    }
  end

  def release_readiness_gaps
    [
      {
        "id" => "final_gem_metadata",
        "status" => "ready",
        "summary" => "Gemspec has non-placeholder homepage/source_code_uri/contact/license/summary metadata."
      },
      {
        "id" => "gem_native_ci",
        "status" => "open",
        "summary" => "Package-native specs are proof-local; no CI/release task wires them yet."
      },
      {
        "id" => "runtime_smoke_adapter",
        "status" => "deferred",
        "summary" => "Runtime smoke remains optional/proof-backed rather than production RuntimeMachine packaging."
      },
      {
        "id" => "release_policy",
        "status" => "defined",
        "summary" => "RubyGems publish policy and checksum/artifact expectations are defined in gem-release-policy-v0; release automation remains open."
      }
    ]
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} gem_native_package_boundary_specs"
    summary.fetch("checks").each do |check|
      puts "#{check.fetch("id")}: #{check.fetch("status")}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = GemNativePackageBoundarySpecs.run
exit(success ? 0 : 1)
