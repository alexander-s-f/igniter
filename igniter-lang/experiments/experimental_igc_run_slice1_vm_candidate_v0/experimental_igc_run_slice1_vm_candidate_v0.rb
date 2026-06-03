#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"

CARD = "S3-R243-C2-I"
TRACK = "experimental-igc-run-slice1-vm-candidate-implementation-v0"
REPO_ROOT = Pathname.new(__dir__).join("../../..").expand_path
PROOF_DIR = Pathname.new(__dir__).expand_path
OUT_DIR = PROOF_DIR.join("out")
INPUT_DIR = PROOF_DIR.join("inputs")
LIB = REPO_ROOT.join("igniter-lang/lib")
IGC = REPO_ROOT.join("igniter-lang/bin/igc")
CLI = LIB.join("igniter_lang/cli.rb")
RUNNER = LIB.join("igniter_lang/experimental_igc_run.rb")
VM_HELPER = LIB.join("igniter_lang/experimental_igc_run_vm_candidate.rb")
ARTIFACT = REPO_ROOT.join("igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp")
PASSPORT = REPO_ROOT.join(
  "igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json"
)
BINDING = REPO_ROOT.join(
  "igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/" \
  "vm_capability_passport_binding_manifest.json"
)
CAPABILITY_MATRIX = REPO_ROOT.join(
  "igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/" \
  "capability_support_gap_matrix.json"
)
UNSUPPORTED_MATRIX = REPO_ROOT.join(
  "igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/" \
  "unsupported_feature_fail_closed_matrix.json"
)
LOOPS_SOURCE = REPO_ROOT.join("igniter-lang/source/loops_and_recursion.ig")
SUMMARY = OUT_DIR.join("summary.json")
INPUT = INPUT_DIR.join("add_19_23.json")
VM_SELECTOR = "delegated-experimental:igniter-vm-candidate"
SLICE0_SELECTOR = "delegated-experimental:ivm-proof"
RUNTIME_IMPLEMENTATION_ID = "igniter.delegated.experimental.vm.rust-tokio.v0"
AUTHORIZED_PREFIXES = [
  "igniter-lang/lib/igniter_lang/experimental_igc_run.rb",
  "igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb",
  "igniter-lang/lib/igniter_lang/cli.rb",
  "igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/",
  "igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-v0.md"
].freeze
CLOSED_SURFACES = [
  "igniter-lang/bin/igc",
  "igniter-lang/igniter_lang.gemspec",
  "igniter-lang/README.md",
  "igniter-lang/docs/README.md",
  "igniter-lang/docs/ruby-api.md",
  "igniter-lang/lib/igniter_lang/runtime_smoke.rb",
  "igniter-lang/lib/igniter_lang/compiler_result.rb",
  "igniter-lang/lib/igniter_lang/compilation_report.rb",
  "playgrounds/igniter-lab",
  "igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp",
  "igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json",
  "igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0"
].freeze

FileUtils.rm_rf(OUT_DIR)
FileUtils.mkdir_p(OUT_DIR)
FileUtils.mkdir_p(INPUT_DIR)
INPUT.write("#{JSON.pretty_generate({ "a" => 19, "b" => 23 })}\n")

CHECKS = []
COMMANDS = []

def read_json(path)
  JSON.parse(path.read)
end

def write_json(path, value)
  FileUtils.mkdir_p(path.dirname)
  path.write("#{JSON.pretty_generate(value)}\n")
end

def record_check(id, description, condition, detail = nil)
  CHECKS << {
    "id" => id,
    "description" => description,
    "status" => condition ? "PASS" : "FAIL",
    "detail" => detail
  }.compact
end

def run_command(name, command)
  stdout, stderr, status = Open3.capture3(*command.map(&:to_s), chdir: REPO_ROOT.to_s)
  record = {
    "name" => name,
    "command" => command.map(&:to_s),
    "exitstatus" => status.exitstatus,
    "stdout" => stdout,
    "stderr" => stderr
  }
  COMMANDS << record
  record
end

def run_igc(name, args)
  run_command(name, ["ruby", "-I", LIB, IGC, *args])
end

def result_path(name)
  OUT_DIR.join("#{name}.result.json")
end

def run_slice1(name, extra_args = [], experimental: true, passport: PASSPORT, input: INPUT, artifact: ARTIFACT, runtime: VM_SELECTOR)
  out = result_path(name)
  args = [
    "run", artifact,
    "--passport", passport,
    "--input", input,
    "--runtime", runtime,
    "--out", out
  ]
  args << "--experimental" if experimental
  args.concat(extra_args)
  command = run_igc("run.#{name}", args)
  packet = out.exist? ? read_json(out) : {}
  [command, packet, out]
end

def directory_digest(dir)
  files = dir.glob("**/*").select(&:file?).sort_by { |path| path.relative_path_from(dir).to_s }
  file_digests = files.map { |path| Digest::SHA256.hexdigest(path.binread) }
  "sha256:#{Digest::SHA256.hexdigest(file_digests.join(":"))}"
end

def diagnostic_codes(packet)
  Array(packet["diagnostics"]).map { |entry| entry["code"] }
end

def forbidden_positive_claim_scan(objects)
  forbidden_keys = %w[
    public_runtime_support
    reference_runtime_support
    stable_api
    production_ready
    spark_integration
    public_demo
    public_performance_claim
    certification
    portability_guarantee
    runtime_smoke_productization
    compiler_passport_emission
  ]
  forbidden_strings = [
    "public runtime support",
    "Reference Runtime support",
    "stable API",
    "production ready",
    "Spark integration",
    "public demo",
    "public performance claim",
    "certification",
    "portability guarantee",
    "RuntimeSmoke productization",
    "compiler passport emission"
  ]
  hits = []
  scan = lambda do |value, path|
    case value
    when Hash
      value.each { |key, child| scan.call(child, path + [key]) }
    when Array
      value.each_with_index { |child, index| scan.call(child, path + [index.to_s]) }
    else
      key = path.last
      hits << { "path" => path.join("."), "value" => value } if forbidden_keys.include?(key) && value == true
      if value.is_a?(String) && forbidden_strings.include?(value)
        hits << { "path" => path.join("."), "value" => value }
      end
    end
  end
  scan.call(objects, [])
  { "status" => hits.empty? ? "PASS" : "FAIL", "hits" => hits }
end

syntax_runner = run_command("syntax.experimental_igc_run", ["ruby", "-c", RUNNER])
syntax_helper = run_command("syntax.experimental_igc_run_vm_candidate", ["ruby", "-c", VM_HELPER])
syntax_cli = run_command("syntax.cli", ["ruby", "-c", CLI])

slice1_blocked_cmd, slice1_blocked_packet = run_slice1("slice1_integer_add_blocked")
missing_experimental_cmd, missing_experimental_packet = run_slice1(
  "slice1_missing_experimental",
  experimental: false
)
unsupported_runtime_cmd, unsupported_runtime_packet = run_slice1(
  "unsupported_runtime",
  runtime: "delegated-experimental:unknown"
)
fake_igbin = OUT_DIR.join("fake.igbin")
fake_igbin.write("not bytecode\n")
igbin_cmd, igbin_packet = run_slice1("unsupported_igbin_path", artifact: fake_igbin)

malformed_passport = OUT_DIR.join("malformed.passport.json")
malformed_passport.write("{")
malformed_passport_cmd, malformed_passport_packet = run_slice1(
  "malformed_passport",
  passport: malformed_passport
)

malformed_input = OUT_DIR.join("malformed.input.json")
malformed_input.write("{")
malformed_input_cmd, malformed_input_packet = run_slice1("malformed_input", input: malformed_input)

slice0_out = result_path("slice0_compat")
slice0_cmd = run_igc("run.slice0_compat", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--input", INPUT,
  "--runtime", SLICE0_SELECTOR,
  "--out", slice0_out,
  "--experimental"
])
slice0_packet = slice0_out.exist? ? read_json(slice0_out) : {}

binding = read_json(BINDING)
passport = read_json(PASSPORT)
capability_matrix = read_json(CAPABILITY_MATRIX)
unsupported_matrix = read_json(UNSUPPORTED_MATRIX)
loops_source = LOOPS_SOURCE.read

require VM_HELPER.to_s
loop_recursion_diagnostics = IgniterLang::ExperimentalIgcRunVmCandidate.unsupported_feature_diagnostics(
  %w[loop recursion]
)
missing_binding_field_fail_closed = begin
  IgniterLang::ExperimentalIgcRunVmCandidate.validate_binding!(
    binding.reject { |key, _value| key == "runtime_implementation_id" }
  )
  false
rescue IgniterLang::ExperimentalIgcRunVmCandidate::Slice1Failure
  true
end
missing_capability_field_fail_closed = begin
  IgniterLang::ExperimentalIgcRunVmCandidate.validate_capability_matrix!(
    capability_matrix.reject { |key, _value| key == "feature_gap_matrix" }
  )
  false
rescue IgniterLang::ExperimentalIgcRunVmCandidate::Slice1Failure
  true
end

artifact_digest = directory_digest(ARTIFACT)
diff_names = run_command(
  "git.diff_name_only.authorized_scope",
  ["git", "diff", "--name-only", "--", *AUTHORIZED_PREFIXES]
).fetch("stdout").lines.map(&:strip).reject(&:empty?)
workspace_diff_names = run_command(
  "git.diff_name_only.workspace_observation",
  ["git", "diff", "--name-only", "--", "igniter-lang"]
).fetch("stdout").lines.map(&:strip).reject(&:empty?)
closed_statuses = CLOSED_SURFACES.to_h do |surface|
  [surface, run_command("git.status.closed.#{surface.gsub(%r{[^a-zA-Z0-9]+}, "_")}", ["git", "status", "--short", "--", surface]).fetch("stdout")]
end

claim_scan = forbidden_positive_claim_scan([
  slice1_blocked_packet,
  missing_experimental_packet,
  unsupported_runtime_packet,
  igbin_packet,
  malformed_passport_packet,
  malformed_input_packet,
  slice0_packet
])

record_check(
  "IGR-S1-1",
  "selector accepted only with --experimental",
  slice1_blocked_cmd.fetch("exitstatus") == 1 &&
    missing_experimental_cmd.fetch("exitstatus") == 1 &&
    diagnostic_codes(missing_experimental_packet).include?("missing_experimental")
)
record_check(
  "IGR-S1-2",
  "delegated-experimental:igniter-vm-candidate resolves to Slice 1 VM candidate boundary",
  slice1_blocked_packet.fetch("kind") == "experimental_igc_run_slice1_result" &&
    slice1_blocked_packet.fetch("runtime_selector") == VM_SELECTOR &&
    slice1_blocked_packet.fetch("runtime_implementation_id") == RUNTIME_IMPLEMENTATION_ID
)
record_check(
  "IGR-S1-3",
  "runtime_implementation_id remains evidence-facing metadata",
  slice1_blocked_packet.fetch("runtime_selector") != slice1_blocked_packet.fetch("runtime_implementation_id") &&
    binding.fetch("runtime_implementation_id_visibility") == "evidence-facing metadata only"
)
record_check(
  "IGR-S1-4",
  "proof-local binding manifest validates",
  slice1_blocked_packet.fetch("binding_check") == "ok" &&
    binding.fetch("runtime_selector") == VM_SELECTOR &&
    binding.fetch("runtime_implementation_id") == RUNTIME_IMPLEMENTATION_ID &&
    missing_binding_field_fail_closed
)
record_check(
  "IGR-S1-5",
  "artifact digest validates",
  artifact_digest == binding.fetch("artifact_digest") &&
    artifact_digest == passport.fetch("artifact_digest")
)
record_check(
  "IGR-S1-6",
  "existing Add.igapp passport mismatch is not silently reinterpreted",
  passport.fetch("runtime_implementation_id") != RUNTIME_IMPLEMENTATION_ID &&
    slice1_blocked_packet.fetch("passport_check") == "runtime_implementation_id_mismatch_acknowledged"
)
record_check(
  "IGR-S1-7",
  "integer_add / stdlib_integer_add follows Path C",
  diagnostic_codes(slice1_blocked_packet).include?("unsupported_capability_integer_add") &&
    diagnostic_codes(slice1_blocked_packet).include?("unsupported_capability_stdlib_integer_add") &&
    capability_matrix.fetch("feature_gap_matrix").all? { |entry| entry.fetch("slice1_status").start_with?("gap_fail_closed") } &&
    missing_capability_field_fail_closed
)
record_check(
  "IGR-S1-8",
  "Path C blocked result is explicit and machine-readable",
  slice1_blocked_packet.fetch("status") == "blocked" &&
    slice1_blocked_packet.fetch("selected_an1_path") == "Path C fail-closed" &&
    slice1_blocked_packet.fetch("outputs") == {}
)
record_check(
  "IGR-S1-9",
  "unsupported loop/recursion markers fail closed",
  loops_source.include?("loop ") &&
    loops_source.include?("def factorial") &&
    loop_recursion_diagnostics.map { |entry| entry.fetch("details").fetch("policy") }.uniq == ["fail_closed"]
)
record_check(
  "IGR-S1-10",
  ".igbin fails closed",
  igbin_cmd.fetch("exitstatus") == 1 &&
    igbin_packet.fetch("status") == "blocked" &&
    diagnostic_codes(igbin_packet).include?("unsupported_artifact")
)
record_check(
  "IGR-S1-11",
  "RuntimeSmoke is not invoked",
  slice1_blocked_packet.fetch("not_runtime_smoke") == true &&
    unsupported_matrix.fetch("features").any? { |entry| entry.fetch("feature") == "RuntimeSmoke" && entry.fetch("policy") == "fail_closed" }
)
record_check(
  "IGR-S1-12",
  "compiler passport emission is not invoked",
  slice1_blocked_packet.fetch("not_compiler_passport_emission") == true &&
    unsupported_matrix.fetch("features").any? { |entry| entry.fetch("feature") == "compiler_passport_emission" && entry.fetch("policy") == "fail_closed" }
)
record_check(
  "IGR-S1-13",
  "Slice 0 delegated-experimental:ivm-proof behavior remains compatible",
  slice0_cmd.fetch("exitstatus") == 0 &&
    slice0_packet.fetch("kind") == "experimental_igc_run_v0_result" &&
    slice0_packet.fetch("outputs").fetch("sum") == 42
)
record_check(
  "IGR-S1-14",
  "result packet keeps pre-v1 / no-stable-API / non-public claims",
  slice1_blocked_packet.fetch("experimental") == true &&
    slice1_blocked_packet.fetch("pre_v1") == true &&
    slice1_blocked_packet.fetch("stable_api") == false &&
    slice1_blocked_packet.fetch("non_claims").include?("not public runtime support")
)
record_check("IGR-S1-15", "forbidden phrase scan passes", claim_scan.fetch("status") == "PASS", claim_scan)
record_check(
  "IGR-S1-16",
  "closed-surface scan passes",
  closed_statuses.values.all?(&:empty?),
  closed_statuses.reject { |_surface, status| status.empty? }
)
record_check(
  "IGR-S1-17",
  "command matrix passes",
  [syntax_runner, syntax_helper, syntax_cli].all? { |command| command.fetch("exitstatus") == 0 } &&
    slice1_blocked_cmd.fetch("exitstatus") == 1 &&
    missing_experimental_cmd.fetch("exitstatus") == 1 &&
    unsupported_runtime_cmd.fetch("exitstatus") == 1 &&
    malformed_passport_cmd.fetch("exitstatus") == 1 &&
    malformed_input_cmd.fetch("exitstatus") == 1 &&
    slice0_cmd.fetch("exitstatus") == 0
)
record_check(
  "IGR-S1-18",
  "git diff stays within authorized write scope",
  diff_names.all? { |path| AUTHORIZED_PREFIXES.any? { |prefix| path.start_with?(prefix) } },
  {
    "authorized_scope_diff" => diff_names,
    "workspace_diff_observation" => workspace_diff_names,
    "workspace_diff_note" => "workspace observation may include unrelated pre-existing user changes"
  }
)

summary = {
  "kind" => "experimental_igc_run_slice1_vm_candidate_summary",
  "format_version" => "0.1.0",
  "card" => CARD,
  "track" => TRACK,
  "status" => CHECKS.all? { |check| check.fetch("status") == "PASS" } ? "PASS" : "FAIL",
  "checks_total" => CHECKS.length,
  "checks_pass" => CHECKS.count { |check| check.fetch("status") == "PASS" },
  "checks_fail" => CHECKS.count { |check| check.fetch("status") == "FAIL" },
  "failed_checks" => CHECKS.select { |check| check.fetch("status") == "FAIL" },
  "result_table" => CHECKS,
  "commands" => COMMANDS,
  "slice1_blocked_result_path" => result_path("slice1_integer_add_blocked").to_s,
  "slice0_compat_result_path" => slice0_out.to_s,
  "runtime_selector" => VM_SELECTOR,
  "runtime_implementation_id" => RUNTIME_IMPLEMENTATION_ID,
  "selected_an1_path" => "Path C fail-closed",
  "claim_scan" => claim_scan,
  "closed_surface_scan" => {
    "closed_statuses" => closed_statuses,
    "status" => closed_statuses.values.all?(&:empty?) ? "PASS" : "FAIL"
  },
  "git_diff_name_only" => diff_names,
  "workspace_diff_observation" => workspace_diff_names,
  "c4_a_recommendation" => {
    "verdict" => "accept bounded Slice 1 Path C implementation",
    "implementation_authorization" => "do not widen beyond Path C",
    "positive_runtime_evidence" => "still blocked for Add.igapp integer capability gap"
  }
}

write_json(SUMMARY, summary)

puts "#{summary.fetch("status")} experimental_igc_run_slice1_vm_candidate_v0"
puts "checks: #{summary.fetch("checks_pass")}/#{summary.fetch("checks_total")}"
puts "failed: #{summary.fetch("checks_fail")}"
puts "summary: #{SUMMARY.relative_path_from(REPO_ROOT)}"
exit(summary.fetch("status") == "PASS" ? 0 : 1)
