#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"

CARD = "S3-R234-C2-I"
TRACK = "experimental-igc-run-slice0-implementation-v0"
REPO_ROOT = Pathname.new(__dir__).join("../../..").expand_path
PROOF_DIR = Pathname.new(__dir__).expand_path
OUT_DIR = PROOF_DIR.join("out")
TMP_DIR = Pathname.new("/tmp/igniter_lang_cli_run_slice0")
IGC = REPO_ROOT.join("igniter-lang/bin/igc")
LIB = REPO_ROOT.join("igniter-lang/lib")
CLI = LIB.join("igniter_lang/cli.rb")
HELPER = LIB.join("igniter_lang/experimental_igc_run.rb")
TRACK_DOC = REPO_ROOT.join("igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md")
SOURCE = REPO_ROOT.join("igniter-lang/examples/experimental_executable_quickstart_v0/add_quickstart.ig")
ARTIFACT = REPO_ROOT.join("igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp")
PASSPORT = REPO_ROOT.join(
  "igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json"
)
INPUT = PROOF_DIR.join("inputs/add_19_23.json")
SUMMARY = OUT_DIR.join("summary.json")

FileUtils.mkdir_p(OUT_DIR)
FileUtils.mkdir_p(TMP_DIR)

CHECKS = []
COMMANDS = []

def record_check(name, status, detail = nil)
  CHECKS << { "name" => name, "status" => status, "detail" => detail }.compact
end

def check(name)
  record_check(name, yield ? "PASS" : "FAIL")
rescue => e
  record_check(name, "FAIL", "#{e.class}: #{e.message}")
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

def read_json(path)
  JSON.parse(path.read)
end

def write_json(path, value)
  FileUtils.mkdir_p(path.dirname)
  path.write(JSON.pretty_generate(value))
end

def mutated_passport(name)
  path = OUT_DIR.join("#{name}.passport.json")
  data = read_json(PASSPORT)
  yield data
  write_json(path, data)
  path
end

def run_igc(name, args)
  run_command(name, ["ruby", "-I", LIB, IGC, *args])
end

def run_result_path(name)
  OUT_DIR.join("#{name}.result.json")
end

def result_status(path)
  read_json(path).fetch("status")
end

syntax_cli = run_command("syntax.cli", ["ruby", "-c", CLI])
syntax_helper = run_command("syntax.experimental_igc_run", ["ruby", "-c", HELPER])
compile_out = TMP_DIR.join("Add.igapp")
compile_cmd = run_igc("compile.regression", ["compile", SOURCE, "--out", compile_out])

positive_out = TMP_DIR.join("result.json")
positive = run_igc("run.positive", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", positive_out,
  "--experimental"
])
positive_packet = positive_out.exist? ? read_json(positive_out) : {}

missing_experimental_out = run_result_path("missing_experimental")
missing_experimental = run_igc("run.missing_experimental", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", missing_experimental_out
])

missing_passport_out = run_result_path("missing_passport")
missing_passport = run_igc("run.missing_passport", [
  "run", ARTIFACT,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", missing_passport_out,
  "--experimental"
])

malformed_passport = OUT_DIR.join("malformed.passport.json")
malformed_passport.write("{")
malformed_passport_out = run_result_path("malformed_passport")
malformed_passport_cmd = run_igc("run.malformed_passport", [
  "run", ARTIFACT,
  "--passport", malformed_passport,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", malformed_passport_out,
  "--experimental"
])

mismatch_passport = mutated_passport("artifact_ref_mismatch") do |data|
  data["artifact_ref"] = "igniter-lang/examples/experimental_executable_quickstart_v0/out/Other.igapp"
end
mismatch_out = run_result_path("artifact_ref_mismatch")
mismatch_cmd = run_igc("run.artifact_ref_mismatch", [
  "run", ARTIFACT,
  "--passport", mismatch_passport,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", mismatch_out,
  "--experimental"
])

digest_passport = mutated_passport("artifact_digest_mismatch") do |data|
  data["artifact_digest"] = "sha256:#{Digest::SHA256.hexdigest("mismatch")}"
end
digest_out = run_result_path("artifact_digest_mismatch")
digest_cmd = run_igc("run.artifact_digest_mismatch", [
  "run", ARTIFACT,
  "--passport", digest_passport,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", digest_out,
  "--experimental"
])

igbin_passport = mutated_passport("unsupported_igbin") do |data|
  data["artifact_kind"] = "igbin_aot_binary"
end
igbin_out = run_result_path("unsupported_igbin")
igbin_cmd = run_igc("run.unsupported_igbin", [
  "run", ARTIFACT,
  "--passport", igbin_passport,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", igbin_out,
  "--experimental"
])

igbin_path_out = run_result_path("unsupported_path_igbin")
igbin_path_cmd = run_igc("run.unsupported_path_igbin", [
  "run", OUT_DIR.join("fake.igbin"),
  "--passport", PASSPORT,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", igbin_path_out,
  "--experimental"
])

deferred_passport = mutated_passport("deferred_output_contract") do |data|
  data["output_contract"] = { "deferred" => true }
end
deferred_out = run_result_path("deferred_output_contract")
deferred_cmd = run_igc("run.deferred_output_contract", [
  "run", ARTIFACT,
  "--passport", deferred_passport,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", deferred_out,
  "--experimental"
])

bad_runtime_out = run_result_path("unsupported_runtime")
bad_runtime = run_igc("run.unsupported_runtime", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--input", INPUT,
  "--runtime", "reference",
  "--out", bad_runtime_out,
  "--experimental"
])

missing_input_out = run_result_path("missing_input")
missing_input = run_igc("run.missing_input", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", missing_input_out,
  "--experimental"
])

malformed_input = OUT_DIR.join("malformed.input.json")
malformed_input.write("{")
malformed_input_out = run_result_path("malformed_input")
malformed_input_cmd = run_igc("run.malformed_input", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--input", malformed_input,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", malformed_input_out,
  "--experimental"
])

array_input = OUT_DIR.join("array.input.json")
write_json(array_input, [19, 23])
array_input_out = run_result_path("array_input")
array_input_cmd = run_igc("run.array_input", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--input", array_input,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", array_input_out,
  "--experimental"
])

missing_out = run_igc("run.missing_out", [
  "run", ARTIFACT,
  "--passport", PASSPORT,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--experimental"
])

missing_contract_passport = mutated_passport("missing_contract_name") do |data|
  data["output_contract"].delete("contract_name")
end
missing_contract_out = run_result_path("missing_contract_name")
missing_contract_cmd = run_igc("run.missing_contract_name", [
  "run", ARTIFACT,
  "--passport", missing_contract_passport,
  "--input", INPUT,
  "--runtime", "delegated-experimental:ivm-proof",
  "--out", missing_contract_out,
  "--experimental"
])

all_result_text = Dir[OUT_DIR.join("*.json")].map { |path| File.read(path) }.join("\n")
forbidden_result_phrases = [
  "production" + "-compiler-cli",
  "stable " + "run command",
  "stable " + "runtime API",
  "production " + "runtime support",
  "Reference " + "Runtime path",
  "igniter-tbackend integration via " + "igc run",
  "benchmark results for " + "igc run performance",
  "Spark" + "CRM",
  "certified " + "output",
  "portable artifact verified by " + "igc run",
  "public " + "performance claim"
]

allowed_negated_claims = [
  "not stable API",
  "not production ready",
  "not Reference Runtime support",
  "not public runtime support",
  "not Spark integration",
  "not release evidence",
  "not public performance claim"
]

scan_files = [
  CLI,
  HELPER,
  TRACK_DOC,
  Pathname.new(__FILE__).expand_path,
  PROOF_DIR.join("inputs/add_19_23.json")
] + Dir[OUT_DIR.join("*.json")].map { |path| Pathname.new(path) }

public_docs = [
  REPO_ROOT.join("igniter-lang/README.md"),
  REPO_ROOT.join("igniter-lang/igniter_lang.gemspec"),
  REPO_ROOT.join("igniter-lang/docs/README.md"),
  REPO_ROOT.join("igniter-lang/docs/ruby-api.md")
]

check("IGR-1.rejects_without_experimental") do
  missing_experimental["exitstatus"] != 0 &&
    result_status(missing_experimental_out) == "blocked" &&
    read_json(missing_experimental_out).dig("diagnostics", 0, "code") == "missing_experimental"
end

check("IGR-2.rejects_missing_passport") do
  missing_passport["exitstatus"] != 0 &&
    read_json(missing_passport_out).dig("diagnostics", 0, "code") == "missing_passport"
end

check("IGR-3.rejects_malformed_passport_json") do
  malformed_passport_cmd["exitstatus"] != 0 &&
    read_json(malformed_passport_out).dig("diagnostics", 0, "code") == "malformed_passport"
end

check("IGR-4.rejects_passport_artifact_ref_mismatch") do
  mismatch_cmd["exitstatus"] != 0 &&
    read_json(mismatch_out).dig("diagnostics", 0, "code") == "artifact_ref_mismatch"
end

check("IGR-5.rejects_artifact_digest_mismatch") do
  digest_cmd["exitstatus"] != 0 &&
    read_json(digest_out).dig("diagnostics", 0, "code") == "artifact_digest_mismatch"
end

check("IGR-6.rejects_unsupported_artifact_kind") do
  igbin_cmd["exitstatus"] != 0 &&
    read_json(igbin_out).dig("diagnostics", 0, "code") == "invalid_passport_artifact_kind" &&
    igbin_path_cmd["exitstatus"] != 0 &&
    read_json(igbin_path_out).dig("diagnostics", 0, "code") == "unsupported_artifact"
end

check("IGR-7.rejects_deferred_output_contract") do
  deferred_cmd["exitstatus"] != 0 &&
    read_json(deferred_out).dig("diagnostics", 0, "code") == "deferred_output_contract"
end

check("IGR-8.rejects_unsupported_runtime_selector") do
  bad_runtime["exitstatus"] != 0 &&
    read_json(bad_runtime_out).dig("diagnostics", 0, "code") == "unsupported_runtime"
end

check("IGR-9.executes_add_igapp_sum_42") do
  positive["exitstatus"] == 0 &&
    positive_packet.fetch("status") == "ok" &&
    positive_packet.fetch("outputs").fetch("sum") == 42
end

check("IGR-10.result_packet_is_local_experimental_output_only") do
  positive_packet.fetch("kind") == "experimental_igc_run_v0_result" &&
    positive_packet.fetch("not_compiler_result") &&
    positive_packet.fetch("not_compilation_report") &&
    positive_packet.fetch("not_compatibility_report") &&
    positive_packet.fetch("not_receipt_sidecar") &&
    positive_packet.fetch("not_release_evidence") &&
    positive_packet.fetch("not_public_api_response_contract")
end

check("IGR-11.no_runtime_smoke_or_production_compiler_cli_in_result") do
  !File.read(HELPER).include?("RuntimeSmoke") &&
    !all_result_text.include?("production" + "-compiler-cli")
end

check("IGR-12.compiler_passport_emission_remains_absent") do
  compile_cmd["exitstatus"] == 0 &&
    !compile_out.join("passport.json").exist? &&
    Dir[compile_out.join("*.passport.json")].empty?
end

check("IGR-13.compile_behavior_backward_compatible") do
  syntax_cli["exitstatus"] == 0 &&
    syntax_helper["exitstatus"] == 0 &&
    compile_cmd["exitstatus"] == 0 &&
    compile_out.join("manifest.json").exist?
end

check("IGR-14.public_docs_remain_unchanged_by_c2_i_scope") do
  public_docs.all? { |path| path.exist? } &&
    COMMANDS.none? { |cmd| cmd.fetch("command").include?(public_docs.first.to_s) }
end

check("IGR-15.claim_scan_passes") do
  scanned = scan_files.select(&:exist?).map { |path| [path, path.read] }
  result_claim_scan_text = allowed_negated_claims.reduce(all_result_text) do |text, allowed|
    text.gsub(allowed, "")
  end
  source_claim_scan = scanned.map do |path, text|
    stripped = allowed_negated_claims.reduce(text) { |memo, allowed| memo.gsub(allowed, "") }
    [path, stripped]
  end
  forbidden_result_phrases.none? { |phrase| result_claim_scan_text.include?(phrase) } &&
    source_claim_scan.none? { |_path, text| forbidden_result_phrases.any? { |phrase| text.include?(phrase) } }
end

check("IGR-16.rejects_missing_input") do
  missing_input["exitstatus"] != 0 &&
    read_json(missing_input_out).dig("diagnostics", 0, "code") == "missing_input"
end

check("IGR-17.rejects_malformed_input_json") do
  malformed_input_cmd["exitstatus"] != 0 &&
    read_json(malformed_input_out).dig("diagnostics", 0, "code") == "malformed_input"
end

check("IGR-18.rejects_non_object_input_json") do
  array_input_cmd["exitstatus"] != 0 &&
    read_json(array_input_out).dig("diagnostics", 0, "code") == "input_not_object"
end

check("IGR-19.rejects_missing_out") do
  missing_out["exitstatus"] != 0 && missing_out["stderr"].include?("igc run requires --out")
end

check("IGR-20.rejects_missing_output_contract_name") do
  missing_contract_cmd["exitstatus"] != 0 &&
    read_json(missing_contract_out).dig("diagnostics", 0, "code") == "missing_output_contract_name"
end

pass_count = CHECKS.count { |check| check.fetch("status") == "PASS" }
fail_count = CHECKS.count { |check| check.fetch("status") == "FAIL" }
overall = fail_count.zero? ? "PASS" : "FAIL"

summary = {
  "kind" => "experimental_igc_run_slice0_proof_v0_summary",
  "format_version" => "0.1.0",
  "card" => CARD,
  "track" => TRACK,
  "overall" => overall,
  "checks_total" => CHECKS.length,
  "checks_pass" => pass_count,
  "checks_fail" => fail_count,
  "failed_checks" => CHECKS.select { |check| check.fetch("status") == "FAIL" }.map { |check| check.fetch("name") },
  "positive_result_path" => positive_out.to_s,
  "proof_result_path" => SUMMARY.to_s,
  "commands" => COMMANDS,
  "checks" => CHECKS,
  "next_recommendation" => "Route S3-R234-C4-A to accept bounded Slice 0 if command matrix and scope review remain clean."
}

write_json(SUMMARY, summary)
puts "#{overall} experimental_igc_run_slice0_proof_v0"
puts "checks_total=#{CHECKS.length}"
puts "checks_pass=#{pass_count}"
puts "checks_fail=#{fail_count}"
puts "failed_checks=#{summary.fetch("failed_checks").inspect}"
puts "summary=#{SUMMARY}"

exit(overall == "PASS" ? 0 : 1)
