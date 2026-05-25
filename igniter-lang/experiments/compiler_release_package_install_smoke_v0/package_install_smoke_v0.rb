# frozen_string_literal: true

# package_install_smoke_v0.rb
# Card: S3-R173-C1-I
# Track: compiler-release-package-install-smoke-v0
# Authorization: S3-R172-C4-A
#
# Bounded local package/install smoke for igniter_lang 0.1.0.pre.stage2.
# Runs PKG-0..PKG-5 against an isolated temp gem home.
# Does NOT:
#   - edit version files or gemspec
#   - create tags, push, publish, sign, or deploy
#   - use repo-relative -I for installed checks
#   - use `igniter-lang compile` (forbidden by criteria)
#   - run profile-source smoke checks
#   - make public release/demo claims

require "open3"
require "json"
require "digest"
require "fileutils"
require "time"

REPO_ROOT     = File.expand_path("../../..", __dir__)
LANG_ROOT     = File.join(REPO_ROOT, "igniter-lang")
GEMSPEC_PATH  = File.join(LANG_ROOT, "igniter_lang.gemspec")
CORPUS_POS    = File.join(LANG_ROOT, "experiments/compiler_release_acceptance_harness_v0/corpus/positive")
CORPUS_NEG    = File.join(LANG_ROOT, "experiments/compiler_release_acceptance_harness_v0/corpus/negative")
VERSION       = "0.1.0.pre.stage2"
GEM_NAME      = "igniter_lang"
GEM_FILE      = "#{GEM_NAME}-#{VERSION}.gem"

RUN_ID        = "S3R173C1I_#{Time.now.utc.strftime("%Y%m%dT%H%M%SZ")}"
SMOKE_ROOT    = "/private/tmp/igniter_lang_package_install_smoke_#{RUN_ID}"
BUILD_DIR     = File.join(SMOKE_ROOT, "build")
GEM_HOME_DIR  = File.join(SMOKE_ROOT, "gem_home")
BIN_DIR       = File.join(SMOKE_ROOT, "bin")
CORPUS_DIR    = File.join(SMOKE_ROOT, "corpus")
OUT_DIR       = File.join(SMOKE_ROOT, "out")
GEM_PATH_LOCAL = File.join(BUILD_DIR, GEM_FILE)

OUT_REPO_DIR  = File.join(LANG_ROOT, "experiments/compiler_release_package_install_smoke_v0/out/#{RUN_ID}")

POSITIVE_SOURCES = %w[
  add_baseline.ig
  boolean_gate.ig
  integer_arithmetic.ig
  multi_input_diverse.ig
  poc_derived.ig
].freeze

NEGATIVE_SOURCES = %w[
  parse_refusal.ig
  type_mismatch.ig
  unresolved_symbol.ig
].freeze

def run_cmd(cmd, env: {}, cwd: LANG_ROOT)
  merged_env = ENV.to_h.merge(env)
  stdout, stderr, status = Open3.capture3(merged_env, cmd, chdir: cwd)
  {
    "cmd"         => cmd,
    "cwd"         => cwd,
    "exit_status" => status.exitstatus,
    "success"     => status.success?,
    "stdout"      => stdout.strip[0, 2000],
    "stderr"      => stderr.strip[0, 2000]
  }
end

def isolated_env
  {
    "GEM_HOME"   => GEM_HOME_DIR,
    "GEM_PATH"   => GEM_HOME_DIR,
    "BUNDLE_DISABLE_SHARED_GEMS" => "1",
    "BUNDLE_GEMFILE" => ""
  }
end

def igc_env
  isolated_env.merge("PATH" => "#{BIN_DIR}:/usr/bin:/bin:/usr/sbin:/sbin")
end

puts "=" * 70
puts "S3-R173-C1-I: package_install_smoke_v0"
puts "RUN_ID: #{RUN_ID}"
puts "SMOKE_ROOT: #{SMOKE_ROOT}"
puts "=" * 70

# Setup temp dirs
[BUILD_DIR, GEM_HOME_DIR, BIN_DIR, CORPUS_DIR, OUT_DIR].each do |d|
  FileUtils.mkdir_p(d)
end
FileUtils.mkdir_p(OUT_REPO_DIR)

command_matrix = []
criteria       = {}
failed_checks  = []
hold_reasons   = []

# ── PKG-0: gemspec syntax check ──────────────────────────────────────────────
puts "\nPKG-0: gemspec syntax check"
pkg0_cmd = "ruby -c #{GEMSPEC_PATH}"
pkg0 = run_cmd(pkg0_cmd, cwd: LANG_ROOT)
pkg0_pass = pkg0["success"] && pkg0["stdout"].include?("Syntax OK")
pkg0_hold = false
puts "  exit=#{pkg0["exit_status"]} pass=#{pkg0_pass} stdout=#{pkg0["stdout"][0, 80]}"
command_matrix << {
  "id"          => "PKG-0",
  "kind"        => "gemspec_syntax_check",
  "cmd"         => pkg0_cmd,
  "cwd"         => LANG_ROOT,
  "exit_status" => pkg0["exit_status"],
  "pass"        => pkg0_pass,
  "hold"        => pkg0_hold,
  "stdout_excerpt" => pkg0["stdout"][0, 200],
  "stderr_excerpt" => pkg0["stderr"][0, 200]
}
failed_checks << "PKG-0: gemspec syntax check failed" unless pkg0_pass

# ── PKG-1: build local gem ───────────────────────────────────────────────────
puts "\nPKG-1: gem build"
pkg1_cmd = "gem build #{GEMSPEC_PATH} --output #{GEM_PATH_LOCAL}"
pkg1 = run_cmd(pkg1_cmd, cwd: LANG_ROOT)
pkg1_artifact_exists = File.exist?(GEM_PATH_LOCAL)
pkg1_pass = pkg1["success"] && pkg1_artifact_exists
pkg1_hold = pkg1["success"] && !pkg1_artifact_exists
pkg1_sha256 = pkg1_artifact_exists ? "sha256:#{Digest::SHA256.hexdigest(File.binread(GEM_PATH_LOCAL))}" : nil
puts "  exit=#{pkg1["exit_status"]} artifact=#{pkg1_artifact_exists} pass=#{pkg1_pass}"
command_matrix << {
  "id"          => "PKG-1",
  "kind"        => "gem_build",
  "cmd"         => pkg1_cmd,
  "cwd"         => LANG_ROOT,
  "exit_status" => pkg1["exit_status"],
  "pass"        => pkg1_pass,
  "hold"        => pkg1_hold,
  "stdout_excerpt" => pkg1["stdout"][0, 400],
  "stderr_excerpt" => pkg1["stderr"][0, 400],
  "artifacts"   => pkg1_artifact_exists ? [GEM_PATH_LOCAL] : []
}
criteria["PKG-1"] = {
  "status"  => pkg1_pass ? "PASS" : (pkg1_hold ? "HOLD" : "FAIL"),
  "summary" => pkg1_pass ? "gem built; artifact present at #{GEM_PATH_LOCAL}" :
                           "build failed or artifact absent"
}
failed_checks << "PKG-1: gem build failed" if !pkg1_pass && !pkg1_hold
hold_reasons  << "PKG-1: artifact location ambiguous" if pkg1_hold

# ── PKG-2: isolated local install ────────────────────────────────────────────
puts "\nPKG-2: gem install (isolated)"
if pkg1_pass
  pkg2_cmd = "gem install --local --force --no-document --install-dir #{GEM_HOME_DIR} --bindir #{BIN_DIR} #{GEM_PATH_LOCAL}"
  pkg2 = run_cmd(pkg2_cmd, cwd: LANG_ROOT)
  igc_installed = File.exist?(File.join(BIN_DIR, "igc"))
  pkg2_pass = pkg2["success"] && igc_installed
  pkg2_hold = pkg2["success"] && !igc_installed
  puts "  exit=#{pkg2["exit_status"]} igc_present=#{igc_installed} pass=#{pkg2_pass}"
  command_matrix << {
    "id"          => "PKG-2",
    "kind"        => "gem_install_isolated",
    "cmd"         => pkg2_cmd,
    "cwd"         => LANG_ROOT,
    "exit_status" => pkg2["exit_status"],
    "pass"        => pkg2_pass,
    "hold"        => pkg2_hold,
    "stdout_excerpt" => pkg2["stdout"][0, 400],
    "stderr_excerpt" => pkg2["stderr"][0, 400],
    "igc_executable_present" => igc_installed
  }
  criteria["PKG-2"] = {
    "status"  => pkg2_pass ? "PASS" : (pkg2_hold ? "HOLD" : "FAIL"),
    "summary" => pkg2_pass ? "gem installed; igc present at #{File.join(BIN_DIR, 'igc')}" :
                             "install failed or igc executable absent"
  }
  failed_checks << "PKG-2: gem install failed or igc absent" if !pkg2_pass && !pkg2_hold
  hold_reasons  << "PKG-2: executable presence ambiguous" if pkg2_hold
else
  puts "  SKIPPED (PKG-1 not pass)"
  pkg2_pass = false
  criteria["PKG-2"] = { "status" => "FAIL", "summary" => "skipped: PKG-1 not PASS" }
  failed_checks << "PKG-2: skipped due to PKG-1 failure"
end

# ── PKG-3: require without repo -I ───────────────────────────────────────────
puts "\nPKG-3: require igniter_lang (isolated, no repo -I)"
if pkg2_pass
  require_script = [
    'require "igniter_lang";',
    'spec = Gem.loaded_specs.fetch("igniter_lang");',
    'abort "repo path leak: #{spec.full_gem_path}" if spec.full_gem_path.include?("#{LANG_ROOT}");',
    'puts "load OK #{IgniterLang::VERSION} path=#{spec.full_gem_path}"'
  ].join(" ").gsub(LANG_ROOT, LANG_ROOT)
  # Escape for shell
  require_expr = [
    %{require "igniter_lang";},
    %{spec = Gem.loaded_specs.fetch("igniter_lang");},
    %{abort "repo path leak: \#{spec.full_gem_path}" if spec.full_gem_path.include?("#{LANG_ROOT}");},
    %{puts "load OK \#{IgniterLang::VERSION} path=\#{spec.full_gem_path}"}
  ].join(" ")
  pkg3_cmd = %{ruby -e '#{require_expr}'}
  pkg3 = run_cmd(pkg3_cmd, env: isolated_env, cwd: "/private/tmp")
  pkg3_pass = pkg3["success"] && pkg3["stdout"].include?("load OK #{VERSION}")
  pkg3_repo_leak = pkg3["stdout"].include?(LANG_ROOT) || pkg3["stderr"].include?(LANG_ROOT)
  pkg3_pass = pkg3_pass && !pkg3_repo_leak
  puts "  exit=#{pkg3["exit_status"]} pass=#{pkg3_pass} stdout=#{pkg3["stdout"][0, 120]}"
  command_matrix << {
    "id"          => "PKG-3",
    "kind"        => "require_no_repo_i",
    "cmd"         => pkg3_cmd,
    "cwd"         => "/private/tmp",
    "exit_status" => pkg3["exit_status"],
    "pass"        => pkg3_pass,
    "hold"        => false,
    "stdout_excerpt" => pkg3["stdout"][0, 400],
    "stderr_excerpt" => pkg3["stderr"][0, 400],
    "repo_relative_i_used" => false,
    "repo_path_leak_observed" => pkg3_repo_leak
  }
  criteria["PKG-3"] = {
    "status"  => pkg3_pass ? "PASS" : "FAIL",
    "summary" => pkg3_pass ? "require OK; loaded from isolated gem home; no repo path leak" :
                             "require failed or repo path leaked"
  }
  failed_checks << "PKG-3: require failed or repo path leak" unless pkg3_pass
else
  puts "  SKIPPED (PKG-2 not pass)"
  pkg3_pass = false
  criteria["PKG-3"] = { "status" => "FAIL", "summary" => "skipped: PKG-2 not PASS" }
  failed_checks << "PKG-3: skipped due to PKG-2 failure"
end

# ── PKG-4: positive corpus via installed igc ─────────────────────────────────
puts "\nPKG-4: installed igc compile — positive corpus"
positive_corpus_results = []
pkg4_all_pass = true

if pkg2_pass
  POSITIVE_SOURCES.each do |source_name|
    src_path  = File.join(CORPUS_POS, source_name)
    base_name = File.basename(source_name, ".ig")
    out_path  = File.join(OUT_DIR, "#{base_name}.igapp")
    igc_path  = File.join(BIN_DIR, "igc")
    cmd = "#{igc_path} compile #{src_path} --out #{out_path}"
    result = run_cmd(cmd, env: igc_env, cwd: "/private/tmp")
    igapp_written = Dir.exist?(out_path)
    pass = result["success"] && igapp_written
    puts "  #{source_name}: exit=#{result["exit_status"]} igapp=#{igapp_written} pass=#{pass}"
    command_matrix << {
      "id"          => "PKG-4",
      "kind"        => "installed_igc_compile_positive",
      "cmd"         => cmd,
      "source"      => source_name,
      "cwd"         => "/private/tmp",
      "exit_status" => result["exit_status"],
      "pass"        => pass,
      "hold"        => false,
      "stdout_excerpt" => result["stdout"][0, 400],
      "stderr_excerpt" => result["stderr"][0, 400],
      "igapp_written" => igapp_written
    }
    positive_corpus_results << {
      "name"            => base_name,
      "source"          => source_name,
      "cmd_shape"       => "igc compile SOURCE --out OUT.igapp",
      "exit_status"     => result["exit_status"],
      "igapp_written"   => igapp_written,
      "result_status"   => pass ? "ok" : "failed",
      "pass"            => pass
    }
    unless pass
      pkg4_all_pass = false
      failed_checks << "PKG-4: #{source_name} compile failed (exit=#{result["exit_status"]} igapp=#{igapp_written})"
    end
  end
  criteria["PKG-4"] = {
    "status"  => pkg4_all_pass ? "PASS" : "FAIL",
    "summary" => "#{POSITIVE_SOURCES.size} positive sources; #{positive_corpus_results.count { |r| r["pass"] }} PASS"
  }
else
  puts "  SKIPPED (PKG-2 not pass)"
  pkg4_all_pass = false
  criteria["PKG-4"] = { "status" => "FAIL", "summary" => "skipped: PKG-2 not PASS" }
  failed_checks << "PKG-4: skipped due to PKG-2 failure"
end

# ── PKG-5: negative corpus refusal via installed igc ─────────────────────────
puts "\nPKG-5: installed igc compile — refusal corpus"
refusal_corpus_results = []
pkg5_all_pass = true

if pkg2_pass
  NEGATIVE_SOURCES.each do |source_name|
    src_path  = File.join(CORPUS_NEG, source_name)
    base_name = File.basename(source_name, ".ig")
    out_path  = File.join(OUT_DIR, "#{base_name}_should_not_exist.igapp")
    igc_path  = File.join(BIN_DIR, "igc")
    cmd = "#{igc_path} compile #{src_path} --out #{out_path}"
    result = run_cmd(cmd, env: igc_env, cwd: "/private/tmp")
    igapp_written = Dir.exist?(out_path)
    refusal_observed = !result["success"]
    pass = refusal_observed && !igapp_written
    # Try to determine refusal kind
    refusal_kind = if result["stderr"].match?(/parse/i) || result["stdout"].match?(/parse/i)
                     "parse_error"
                   elsif result["stderr"].match?(/OOF|type/i) || result["stdout"].match?(/OOF|type/i)
                     "oof"
                   elsif result["stderr"].match?(/unresolved|undefined/i) || result["stdout"].match?(/unresolved|undefined/i)
                     "oof"
                   else
                     "qualified_stderr"
                   end
    puts "  #{source_name}: exit=#{result["exit_status"]} refused=#{refusal_observed} igapp=#{igapp_written} pass=#{pass}"
    command_matrix << {
      "id"          => "PKG-5",
      "kind"        => "installed_igc_compile_refusal",
      "cmd"         => cmd,
      "source"      => source_name,
      "cwd"         => "/private/tmp",
      "exit_status" => result["exit_status"],
      "pass"        => pass,
      "hold"        => false,
      "stdout_excerpt" => result["stdout"][0, 400],
      "stderr_excerpt" => result["stderr"][0, 400],
      "refusal_observed" => refusal_observed,
      "igapp_written"    => igapp_written
    }
    refusal_corpus_results << {
      "name"             => base_name,
      "source"           => source_name,
      "cmd_shape"        => "igc compile SOURCE --out SHOULD_NOT_EXIST.igapp",
      "exit_status"      => result["exit_status"],
      "igapp_written"    => igapp_written,
      "refusal_observed" => refusal_observed,
      "refusal_kind"     => refusal_kind,
      "pass"             => pass
    }
    unless pass
      pkg5_all_pass = false
      if igapp_written
        failed_checks << "PKG-5: #{source_name} refusal wrote igapp (should be absent)"
      else
        failed_checks << "PKG-5: #{source_name} refusal check failed (exit=#{result["exit_status"]})"
      end
    end
  end
  criteria["PKG-5"] = {
    "status"  => pkg5_all_pass ? "PASS" : "FAIL",
    "summary" => "#{NEGATIVE_SOURCES.size} refusal sources; #{refusal_corpus_results.count { |r| r["pass"] }} PASS"
  }
else
  puts "  SKIPPED (PKG-2 not pass)"
  pkg5_all_pass = false
  criteria["PKG-5"] = { "status" => "FAIL", "summary" => "skipped: PKG-2 not PASS" }
  failed_checks << "PKG-5: skipped due to PKG-2 failure"
end

# ── Derive top-level status ───────────────────────────────────────────────────
# FAIL > HOLD > PASS
all_criteria_pass = criteria.values.all? { |c| c["status"] == "PASS" } &&
                    pkg0_pass && failed_checks.empty? && hold_reasons.empty?

top_status = if failed_checks.any?
               "FAIL"
             elsif hold_reasons.any?
               "HOLD"
             else
               "PASS"
             end

puts "\n" + "=" * 70
puts "RESULT: #{top_status}"
puts "failed_checks: #{failed_checks.size}"
puts "hold_reasons:  #{hold_reasons.size}"
puts "=" * 70

# ── Build summary JSON ────────────────────────────────────────────────────────
ruby_version_result = run_cmd("ruby --version", cwd: LANG_ROOT)

summary = {
  "kind"           => "compiler_release_package_install_smoke_summary",
  "format_version" => "0.1.0",
  "card"           => "S3-R173-C1-I",
  "track"          => "compiler-release-package-install-smoke-v0",
  "status"         => top_status,
  "authorized_by"  => "S3-R172-C4-A",
  "run_id"         => RUN_ID,
  "executed_at_utc" => Time.now.utc.iso8601,
  "release_scope"  => {
    "scope"                        => "bounded_local_package_install_smoke",
    "source_marker"                => "repo_local_compiler_rc_marker",
    "source_evidence_scope"        => "repo_local_compiler_rc",
    "public_claims_authorized"     => false,
    "rubygems_publish_authorized"  => false,
    "production_runtime_authorized" => false
  },
  "package" => {
    "gem_name"           => GEM_NAME,
    "version"            => VERSION,
    "gemspec_path"       => GEMSPEC_PATH,
    "built_gem_path"     => GEM_PATH_LOCAL,
    "built_gem_sha256"   => pkg1_sha256,
    "executable_expected" => "igc",
    "executable_observed" => File.exist?(File.join(BIN_DIR, "igc")) ? "igc" : "absent"
  },
  "environment" => {
    "ruby_version"             => ruby_version_result["stdout"],
    "gem_version"              => `gem --version`.strip,
    "smoke_root"               => SMOKE_ROOT,
    "gem_home"                 => GEM_HOME_DIR,
    "gem_path"                 => GEM_HOME_DIR,
    "bin_dir"                  => BIN_DIR,
    "cwd_for_require"          => "/private/tmp",
    "repo_relative_i_used"     => false,
    "rubylib_points_to_repo"   => false
  },
  "criteria"          => criteria,
  "command_matrix"    => command_matrix,
  "positive_corpus"   => positive_corpus_results,
  "refusal_corpus"    => refusal_corpus_results,
  "failed_checks"     => failed_checks,
  "hold_reasons"      => hold_reasons,
  "non_blocking_notes" => [],
  "non_claims" => {
    "no_public_release_claim"                            => true,
    "no_public_demo_claim"                               => true,
    "no_rubygems_publish"                                => true,
    "no_public_availability_claim"                       => true,
    "no_version_change"                                  => true,
    "no_git_tag"                                         => true,
    "no_push"                                            => true,
    "no_signing"                                         => true,
    "no_deploy"                                          => true,
    "no_release_execution_beyond_smoke"                  => true,
    "no_production_runtime"                              => true,
    "no_spark_integration"                               => true,
    "no_ruby_framework_compatibility_claim"              => true,
    "no_branch_conditional_claim"                        => true,
    "no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim" => true
  },
  "artifact_policy" => {
    "temp_root"                  => SMOKE_ROOT,
    "retained_summary_path"      => File.join(OUT_REPO_DIR, "package_install_smoke_summary.json"),
    "retain_command_logs"        => true,
    "retain_built_gem"           => false,
    "retain_positive_igapp_outputs" => "temp only; not retained in repo",
    "cleanup_isolated_gem_home"  => true,
    "cleanup_temp_root"          => "after summary written"
  }
}

# Write to temp out
temp_summary_path = File.join(OUT_DIR, "package_install_smoke_summary.json")
File.write(temp_summary_path, JSON.pretty_generate(summary))

# Write durable copy to repo
repo_summary_path = File.join(OUT_REPO_DIR, "package_install_smoke_summary.json")
File.write(repo_summary_path, JSON.pretty_generate(summary))

puts "\nSummary written:"
puts "  temp: #{temp_summary_path}"
puts "  repo: #{repo_summary_path}"

# Cleanup temp artifacts (keep summary in temp for inspection if needed)
if top_status == "PASS"
  FileUtils.rm_rf(GEM_HOME_DIR)
  FileUtils.rm_rf(BIN_DIR)
  FileUtils.rm_rf(CORPUS_DIR)
  FileUtils.rm_rf(BUILD_DIR)
  puts "Temp artifacts cleaned (GEM_HOME, BIN_DIR, corpus, build)."
  puts "Temp summary retained at: #{temp_summary_path}"
else
  puts "NOT cleaning temp (status=#{top_status}); retain for inspection: #{SMOKE_ROOT}"
end

puts "\n#{top_status} compiler_release_package_install_smoke_v0"
puts "RUN_ID=#{RUN_ID}"
puts "positive_corpus_entries=#{POSITIVE_SOURCES.size}"
puts "refusal_corpus_entries=#{NEGATIVE_SOURCES.size}"
puts "failed_checks=#{failed_checks.size}"
puts "hold_reasons=#{hold_reasons.size}"
puts "summary=#{repo_summary_path}"
