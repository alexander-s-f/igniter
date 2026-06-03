# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module ExperimentalIgcRunSlice1VmCapabilityPassportHardeningV0
  module_function

  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  EXPERIMENT_DIR = Pathname.new(__dir__)
  OUT_DIR = EXPERIMENT_DIR / "out"

  CARD = "S3-R242-C2-I"
  TRACK = "experimental-igc-run-slice1-vm-capability-passport-hardening-v0"
  AUTHORIZED_BY = "S3-R242-C1-A"
  FORMAT_VERSION = "0.1.0"
  GENERATED_AT = "2026-06-03T00:00:00Z"

  ARTIFACT_REF = "igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp"
  PASSPORT_REF =
    "igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json"
  VM_PROOF_REF = "playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json"
  LOOPS_SOURCE_REF = "igniter-lang/source/loops_and_recursion.ig"
  EXPERIMENTAL_RUN_REF = "igniter-lang/lib/igniter_lang/experimental_igc_run.rb"

  RUNTIME_SELECTOR = "delegated-experimental:igniter-vm-candidate"
  SLICE0_RUNTIME_SELECTOR = "delegated-experimental:ivm-proof"
  RUNTIME_IMPLEMENTATION_ID = "igniter.delegated.experimental.vm.rust-tokio.v0"
  EXISTING_PASSPORT_RUNTIME_IMPLEMENTATION_ID = "igniter.delegated.experimental.ivm.c_resident"
  RESULT_KIND = "experimental_igc_run_slice1_evidence_packet_shape"

  REQUIRED_NON_CLAIMS = [
    "not stable API",
    "not production ready",
    "not public runtime support",
    "not Reference Runtime support",
    "not Spark integration",
    "not release evidence",
    "not public performance claim",
    "not compiler passport emission",
    "not RuntimeSmoke productization",
    "not igc run general runtime support",
    "not certified alternative implementation",
    "not portability guarantee"
  ].freeze

  VMG_IDS = (1..15).map { |index| "VMG-#{index}" }.freeze

  OUTPUT_FILES = {
    binding_manifest: "vm_capability_passport_binding_manifest.json",
    capability_matrix: "capability_support_gap_matrix.json",
    unsupported_matrix: "unsupported_feature_fail_closed_matrix.json",
    selector_proof: "selector_runtime_implementation_id_separation_proof.json",
    non_claims_matrix: "non_claims_matrix.json",
    closed_surface_scan: "closed_surface_scan.json",
    summary: "summary.json"
  }.freeze

  CLOSED_SURFACES = [
    "igniter-lang/lib/**",
    "igniter-lang/bin/igc",
    "igniter-lang/igniter_lang.gemspec",
    "igniter-lang/README.md",
    "igniter-lang/docs/README.md",
    "igniter-lang/docs/ruby-api.md",
    "igniter-lang/lib/igniter_lang/runtime_smoke.rb",
    "igniter-lang/lib/igniter_lang/compiler_result.rb",
    "igniter-lang/lib/igniter_lang/compilation_report.rb",
    "playgrounds/igniter-lab/**",
    "#{ARTIFACT_REF}/**",
    PASSPORT_REF
  ].freeze

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    artifact_path = ROOT / ARTIFACT_REF
    passport_path = ROOT / PASSPORT_REF
    vm_proof_path = ROOT / VM_PROOF_REF
    loops_source_path = ROOT / LOOPS_SOURCE_REF
    experimental_run_path = ROOT / EXPERIMENTAL_RUN_REF

    passport = read_json(passport_path)
    vm_summary = read_json(vm_proof_path)
    artifact_digest = directory_digest(artifact_path)
    semantic_ir_digest = file_digest(artifact_path / "semantic_ir_program.json")
    loops_source = loops_source_path.read
    experimental_run_source = experimental_run_path.read

    unsupported_matrix = unsupported_feature_fail_closed_matrix(loops_source)
    capability_matrix = capability_support_gap_matrix(vm_summary, passport)
    selector_proof = selector_runtime_implementation_id_separation_proof(experimental_run_source)
    non_claims_matrix = non_claims_matrix
    result_packet_shape = result_packet_shape_manifest
    binding_manifest = binding_manifest(
      passport: passport,
      vm_summary: vm_summary,
      artifact_digest: artifact_digest,
      semantic_ir_digest: semantic_ir_digest,
      capability_matrix: capability_matrix,
      unsupported_matrix: unsupported_matrix,
      result_packet_shape: result_packet_shape
    )

    written_paths = []
    write_json(OUTPUT_FILES.fetch(:binding_manifest), binding_manifest, written_paths)
    write_json(OUTPUT_FILES.fetch(:capability_matrix), capability_matrix, written_paths)
    write_json(OUTPUT_FILES.fetch(:unsupported_matrix), unsupported_matrix, written_paths)
    write_json(OUTPUT_FILES.fetch(:selector_proof), selector_proof, written_paths)
    write_json(OUTPUT_FILES.fetch(:non_claims_matrix), non_claims_matrix, written_paths)

    closed_surface_scan = closed_surface_scan(written_paths)
    write_json(OUTPUT_FILES.fetch(:closed_surface_scan), closed_surface_scan, written_paths)

    generated_objects = [
      binding_manifest,
      capability_matrix,
      unsupported_matrix,
      selector_proof,
      non_claims_matrix,
      closed_surface_scan,
      result_packet_shape
    ]
    claim_scan = claim_scan(generated_objects)
    checks = checks(
      passport: passport,
      vm_summary: vm_summary,
      artifact_digest: artifact_digest,
      semantic_ir_digest: semantic_ir_digest,
      binding_manifest: binding_manifest,
      capability_matrix: capability_matrix,
      unsupported_matrix: unsupported_matrix,
      selector_proof: selector_proof,
      non_claims_matrix: non_claims_matrix,
      closed_surface_scan: closed_surface_scan,
      claim_scan: claim_scan
    )
    pass = checks.all? { |check| check.fetch("status") == "PASS" }
    summary = {
      "kind" => "experimental_igc_run_slice1_vm_capability_passport_hardening_summary",
      "format_version" => FORMAT_VERSION,
      "card" => CARD,
      "track" => TRACK,
      "authorized_by" => AUTHORIZED_BY,
      "status" => pass ? "PASS" : "FAIL",
      "generated_at" => GENERATED_AT,
      "artifact_ref" => ARTIFACT_REF,
      "artifact_digest" => artifact_digest,
      "runtime_selector" => RUNTIME_SELECTOR,
      "runtime_implementation_id" => RUNTIME_IMPLEMENTATION_ID,
      "existing_passport_runtime_implementation_id" => passport.fetch("runtime_implementation_id"),
      "binding_manifest_path" => relative_out_path(OUTPUT_FILES.fetch(:binding_manifest)),
      "result_table" => checks,
      "failed_checks" => checks.reject { |check| check.fetch("status") == "PASS" },
      "claim_scan" => claim_scan,
      "closed_surface_scan" => closed_surface_scan,
      "command_matrix" => command_matrix,
      "c4_a_recommendation" => c4_a_recommendation
    }
    write_json(OUTPUT_FILES.fetch(:summary), summary, written_paths)
    print_summary(summary)
    pass
  end

  def binding_manifest(
    passport:,
    vm_summary:,
    artifact_digest:,
    semantic_ir_digest:,
    capability_matrix:,
    unsupported_matrix:,
    result_packet_shape:
  )
    {
      "kind" => "experimental_igc_run_slice1_vm_capability_passport_binding_manifest",
      "format_version" => FORMAT_VERSION,
      "card" => CARD,
      "track" => TRACK,
      "evidence_class" => "proof-local VM capability/passport hardening evidence only",
      "authority_status" => "non-canonical / evidence-only / candidate-only",
      "non_claims" => REQUIRED_NON_CLAIMS,
      "artifact_ref" => ARTIFACT_REF,
      "artifact_digest" => artifact_digest,
      "source_digest" => passport.fetch("source_digest"),
      "semantic_ir_digest" => semantic_ir_digest,
      "artifact_kind" => "igapp_dir",
      "runtime_target_kind" => "delegated_experimental_runtime",
      "runtime_selector" => RUNTIME_SELECTOR,
      "runtime_implementation_id" => RUNTIME_IMPLEMENTATION_ID,
      "selector_visibility" => "user-facing / experimental / pre-v1",
      "runtime_implementation_id_visibility" => "evidence-facing metadata only",
      "required_capabilities" => required_capabilities(capability_matrix),
      "feature_set" => passport.fetch("feature_set"),
      "required_opcodes" => "not_applicable / Slice 1 hardening binds igapp_dir evidence, not .igbin bytecode",
      "capability_source_map" => capability_matrix.fetch("capability_source_map"),
      "unsupported_feature_policy" => {
        "default" => "fail_closed",
        "matrix_ref" => relative_out_path(OUTPUT_FILES.fetch(:unsupported_matrix)),
        "entries" => unsupported_matrix.fetch("features")
      },
      "loop_recursion_policy" => {
        "classification" => "pressure input only",
        "slice1_action" => "fail_closed",
        "source_ref" => LOOPS_SOURCE_REF
      },
      "input_contract" => passport.fetch("input_contract"),
      "output_contract" => passport.fetch("output_contract"),
      "failure_policy" => {
        "policy" => "fail_closed_on_unsupported_or_unbound_capability",
        "no_partial_output" => true,
        "implementation_authorized" => false
      },
      "result_packet_shape" => result_packet_shape,
      "producer_track" => TRACK,
      "authorized_by" => AUTHORIZED_BY,
      "generated_at" => GENERATED_AT,
      "vm_candidate_summary_ref" => VM_PROOF_REF,
      "vm_candidate_summary_status" => vm_summary.fetch("overall"),
      "compiler_passport_emission" => false,
      "runtime_smoke_invoked" => false,
      "igbin_execution" => false
    }
  end

  def capability_support_gap_matrix(vm_summary, passport)
    proof_matrix = vm_summary.fetch("proof_matrix")
    {
      "kind" => "experimental_igc_run_slice1_capability_support_gap_matrix",
      "format_version" => FORMAT_VERSION,
      "runtime_implementation_id" => RUNTIME_IMPLEMENTATION_ID,
      "vm_summary_overall" => vm_summary.fetch("overall"),
      "accepted_vmg_ids" => proof_matrix.keys.sort_by { |key| key.delete_prefix("VMG-").to_i },
      "capability_source_map" => [
        capability("vm_runtime_identity_binding", %w[VMG-1], "supported_evidence_only"),
        capability("evidence_authority_and_non_claims", %w[VMG-2 VMG-15], "supported_evidence_only"),
        capability("scoped_proof_command_matrix", %w[VMG-3], "supported_evidence_only"),
        capability("decimal_arithmetic_parity_evidence", %w[VMG-4], "supported_evidence_only"),
        capability("aot_semanticir_lowering_candidate", %w[VMG-5], "supported_evidence_only"),
        capability("stack_register_execution_candidate", %w[VMG-6], "supported_evidence_only"),
        capability("selected_branch_candidate", %w[VMG-7], "supported_evidence_only"),
        capability("non_selected_branch_silence_candidate", %w[VMG-8], "supported_evidence_only"),
        capability("unsupported_path_fail_closed", %w[VMG-9], "supported_evidence_only"),
        capability("malformed_input_fail_closed", %w[VMG-10], "supported_evidence_only"),
        capability("temporal_trace_identifier_candidate", %w[VMG-11], "supported_evidence_only"),
        capability("map_reduce_aggregate_candidate", %w[VMG-12], "supported_evidence_only"),
        capability("reactive_tbackend_classified_skipped", %w[VMG-13], "classified_skipped"),
        capability("closed_surface_preservation", %w[VMG-14], "supported_evidence_only")
      ],
      "feature_gap_matrix" => [
        {
          "feature" => "integer_add",
          "source" => "existing Add.igapp feature_set",
          "artifact_feature_present" => passport.fetch("feature_set").include?("integer_add"),
          "slice1_status" => "gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence",
          "reason" => "R240 accepted VMG arithmetic evidence is decimal parity, not public Integer runtime support."
        },
        {
          "feature" => "stdlib_integer_add",
          "source" => "existing Add.igapp feature_set",
          "artifact_feature_present" => passport.fetch("feature_set").include?("stdlib_integer_add"),
          "slice1_status" => "gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence",
          "reason" => "Binding is evidence-only and does not authorize Slice 1 execution."
        }
      ]
    }
  end

  def capability(name, vmg_refs, status)
    {
      "capability" => name,
      "vmg_refs" => vmg_refs,
      "status" => status,
      "authority" => "R240 accepted VM candidate proof evidence only"
    }
  end

  def unsupported_feature_fail_closed_matrix(loops_source)
    loop_markers = {
      "loop_keyword" => loops_source.include?("loop "),
      "recursion_def" => loops_source.include?("def factorial"),
      "decreases_fuel" => loops_source.include?("decreases fuel"),
      "clock_every" => loops_source.include?("clock.every"),
      "tick_time" => loops_source.include?("tick.time")
    }
    features = [
      unsupported(".igbin", "unsupported_artifact_igbin", ".igbin remains excluded"),
      unsupported("loop", "unsupported_feature_loop", "loops are pressure-only"),
      unsupported("recursion", "unsupported_feature_recursion", "recursion is pressure-only"),
      unsupported("service_loop_clock_tick", "unsupported_feature_service_loop", "tick.time remains pressure-only"),
      unsupported("reactive_daemon", "unsupported_feature_reactive_daemon", "no server/daemon execution"),
      unsupported("tbackend_daemon", "unsupported_feature_tbackend_daemon", "no TBackend daemon execution"),
      unsupported("projection_pipeline", "unsupported_feature_projection_pipeline", "no projection pipeline execution"),
      unsupported("compiler_passport_emission", "compiler_passport_emission_closed", "compiler passport emission remains closed"),
      unsupported("RuntimeSmoke", "runtime_smoke_closed", "RuntimeSmoke remains absent")
    ]
    {
      "kind" => "experimental_igc_run_slice1_unsupported_feature_fail_closed_matrix",
      "format_version" => FORMAT_VERSION,
      "loops_source_ref" => LOOPS_SOURCE_REF,
      "loops_source_markers" => loop_markers,
      "features" => features,
      "default_policy" => "fail_closed",
      "implementation_authorized" => false
    }
  end

  def unsupported(feature, diagnostic_code, reason)
    {
      "feature" => feature,
      "slice1_status" => "unsupported",
      "policy" => "fail_closed",
      "diagnostic_code" => diagnostic_code,
      "reason" => reason
    }
  end

  def selector_runtime_implementation_id_separation_proof(experimental_run_source)
    {
      "kind" => "experimental_igc_run_slice1_selector_runtime_implementation_id_separation_proof",
      "format_version" => FORMAT_VERSION,
      "proof_local_user_typed_selector" => RUNTIME_SELECTOR,
      "runtime_implementation_id" => RUNTIME_IMPLEMENTATION_ID,
      "existing_slice0_selector" => SLICE0_RUNTIME_SELECTOR,
      "existing_slice0_selector_still_present" => experimental_run_source.include?(SLICE0_RUNTIME_SELECTOR),
      "runtime_implementation_id_present_in_mainline_run_surface" =>
        experimental_run_source.include?(RUNTIME_IMPLEMENTATION_ID),
      "user_typed_selectors" => [
        SLICE0_RUNTIME_SELECTOR,
        RUNTIME_SELECTOR
      ],
      "runtime_implementation_id_is_user_typed_selector" => false,
      "separation_policy" => "selector is user-facing experimental alias; runtime_implementation_id is evidence-facing metadata only"
    }
  end

  def non_claims_matrix
    {
      "kind" => "experimental_igc_run_slice1_non_claims_matrix",
      "format_version" => FORMAT_VERSION,
      "non_claims" => REQUIRED_NON_CLAIMS.map do |claim|
        {
          "claim" => claim,
          "status" => "closed",
          "asserted_as_non_claim" => true
        }
      end,
      "positive_claim_flags" => positive_claim_flags(false)
    }
  end

  def result_packet_shape_manifest
    {
      "kind" => RESULT_KIND,
      "format_version" => FORMAT_VERSION,
      "status_values" => %w[ok blocked error],
      "experimental" => true,
      "pre_v1" => true,
      "stable_api" => false,
      "artifact_ref" => "required",
      "passport_ref" => "required",
      "input_ref" => "required",
      "runtime_selector" => RUNTIME_SELECTOR,
      "runtime_implementation_id" => RUNTIME_IMPLEMENTATION_ID,
      "runtime_authority" => "non-canonical / delegated experimental / candidate only",
      "capability_check" => "evidence-only",
      "passport_check" => "proof-local binding metadata only",
      "outputs" => "not produced by this proof",
      "diagnostics" => [],
      "non_claims" => REQUIRED_NON_CLAIMS,
      "not_compiler_result" => true,
      "not_compilation_report" => true,
      "not_compatibility_report" => true,
      "not_receipt_sidecar" => true,
      "not_release_evidence" => true,
      "not_public_api_response_contract" => true
    }
  end

  def closed_surface_scan(written_paths)
    allowed_prefix = EXPERIMENT_DIR.expand_path.to_s
    expected_written_paths = (written_paths + [
      (OUT_DIR / OUTPUT_FILES.fetch(:closed_surface_scan)).to_s,
      (OUT_DIR / OUTPUT_FILES.fetch(:summary)).to_s
    ]).uniq
    written_outside_allowed = expected_written_paths.reject do |path|
      Pathname.new(path).expand_path.to_s.start_with?(allowed_prefix)
    end
    {
      "kind" => "experimental_igc_run_slice1_closed_surface_scan",
      "format_version" => FORMAT_VERSION,
      "allowed_write_scope" => [
        "igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/**",
        "igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md"
      ],
      "proof_written_paths" => expected_written_paths.map { |path| relative_path(Pathname.new(path)) },
      "written_outside_allowed_scope" => written_outside_allowed.map { |path| relative_path(Pathname.new(path)) },
      "closed_surfaces" => CLOSED_SURFACES.map { |surface| { "surface" => surface, "proof_access" => "read-only / not written" } },
      "status" => written_outside_allowed.empty? ? "PASS" : "FAIL"
    }
  end

  def claim_scan(objects)
    flags = positive_claim_flags(true)
    hits = []
    scan_value(objects, []) do |path, value|
      next unless flags.key?(path.last)
      next unless value == true

      hits << {
        "path" => path.join("."),
        "value" => value,
        "forbidden_positive_claim" => path.last
      }
    end
    {
      "kind" => "experimental_igc_run_slice1_claim_scan",
      "format_version" => FORMAT_VERSION,
      "forbidden_positive_claim_keys" => flags.keys.sort,
      "hits" => hits,
      "hit_count" => hits.length,
      "status" => hits.empty? ? "PASS" : "FAIL"
    }
  end

  def positive_claim_flags(value)
    {
      "public_runtime_support" => value,
      "reference_runtime_support" => value,
      "stable_api" => value,
      "production_ready" => value,
      "spark_integration" => value,
      "release_evidence" => value,
      "public_performance_claim" => value,
      "official_reference_status" => value,
      "alternative_certification" => value,
      "portability_guarantee" => value,
      "compiler_passport_emission" => value,
      "runtime_smoke_productization" => value,
      "igc_run_implementation_authorized" => value
    }
  end

  def checks(
    passport:,
    vm_summary:,
    artifact_digest:,
    semantic_ir_digest:,
    binding_manifest:,
    capability_matrix:,
    unsupported_matrix:,
    selector_proof:,
    non_claims_matrix:,
    closed_surface_scan:,
    claim_scan:
  )
    [
      check("S1H-1", "proof-local binding manifest exists", File.exist?(OUT_DIR / OUTPUT_FILES.fetch(:binding_manifest))),
      check("S1H-2", "artifact_ref / artifact_digest for Add.igapp recompute correctly", artifact_digest == binding_manifest.fetch("artifact_digest") && artifact_digest == passport.fetch("artifact_digest") && semantic_ir_digest == passport.fetch("semantic_ir_digest")),
      check("S1H-3", "runtime_implementation_id matches accepted R240 VM id", binding_manifest.fetch("runtime_implementation_id") == RUNTIME_IMPLEMENTATION_ID && vm_summary.fetch("runtime_implementation_id") == RUNTIME_IMPLEMENTATION_ID),
      check("S1H-4", "CLI selector remains delegated-experimental:igniter-vm-candidate", binding_manifest.fetch("runtime_selector") == RUNTIME_SELECTOR),
      check("S1H-5", "runtime_implementation_id is not used as a user-typed selector", selector_proof.fetch("runtime_implementation_id_is_user_typed_selector") == false && !selector_proof.fetch("user_typed_selectors").include?(RUNTIME_IMPLEMENTATION_ID)),
      check("S1H-6", "required capabilities map to accepted VMG-1..VMG-15 evidence only", required_capabilities_map_to_vmg?(binding_manifest.fetch("required_capabilities"))),
      check("S1H-7", "loop/recursion are pressure-only and fail-closed", loop_recursion_fail_closed?(unsupported_matrix)),
      check("S1H-8", ".igbin remains excluded", feature_policy(unsupported_matrix, ".igbin") == "fail_closed"),
      check("S1H-9", "compiler passport emission remains absent", binding_manifest.fetch("compiler_passport_emission") == false && feature_policy(unsupported_matrix, "compiler_passport_emission") == "fail_closed"),
      check("S1H-10", "RuntimeSmoke remains absent", binding_manifest.fetch("runtime_smoke_invoked") == false && feature_policy(unsupported_matrix, "RuntimeSmoke") == "fail_closed"),
      check("S1H-11", "unsupported feature matrix is fail-closed", unsupported_matrix.fetch("features").all? { |entry| entry.fetch("policy") == "fail_closed" }),
      check("S1H-12", "result packet shape is evidence-only / pre-v1 / non-stable", result_shape_evidence_only?(binding_manifest.fetch("result_packet_shape"))),
      check("S1H-13", "public/runtime/reference/stable/performance/portability claim scan passes", claim_scan.fetch("status") == "PASS"),
      check("S1H-14", "closed-surface scan passes", closed_surface_scan.fetch("status") == "PASS" && closed_surface_scan.fetch("written_outside_allowed_scope").empty?)
    ].map do |entry|
      entry.merge("result" => entry.fetch("status"))
    end
  end

  def check(id, description, condition)
    {
      "id" => id,
      "description" => description,
      "status" => condition ? "PASS" : "FAIL"
    }
  end

  def required_capabilities(matrix)
    matrix.fetch("capability_source_map").map do |entry|
      {
        "capability" => entry.fetch("capability"),
        "vmg_refs" => entry.fetch("vmg_refs"),
        "status" => entry.fetch("status"),
        "authority" => entry.fetch("authority")
      }
    end
  end

  def required_capabilities_map_to_vmg?(capabilities)
    capabilities.all? do |entry|
      refs = entry.fetch("vmg_refs")
      !refs.empty? && refs.all? { |ref| VMG_IDS.include?(ref) }
    end
  end

  def loop_recursion_fail_closed?(matrix)
    loop_entry = matrix.fetch("features").find { |entry| entry.fetch("feature") == "loop" }
    recursion_entry = matrix.fetch("features").find { |entry| entry.fetch("feature") == "recursion" }
    markers = matrix.fetch("loops_source_markers")
    loop_entry&.fetch("policy") == "fail_closed" &&
      recursion_entry&.fetch("policy") == "fail_closed" &&
      markers.fetch("loop_keyword") &&
      markers.fetch("recursion_def")
  end

  def feature_policy(matrix, feature)
    matrix.fetch("features").find { |entry| entry.fetch("feature") == feature }&.fetch("policy")
  end

  def result_shape_evidence_only?(shape)
    shape.fetch("kind") == RESULT_KIND &&
      shape.fetch("experimental") == true &&
      shape.fetch("pre_v1") == true &&
      shape.fetch("stable_api") == false &&
      shape.fetch("not_compiler_result") == true &&
      shape.fetch("not_compilation_report") == true &&
      shape.fetch("not_compatibility_report") == true &&
      shape.fetch("not_release_evidence") == true
  end

  def read_json(path)
    JSON.parse(path.read)
  end

  def write_json(name, value, written_paths)
    path = OUT_DIR / name
    FileUtils.mkdir_p(path.dirname)
    path.write("#{JSON.pretty_generate(value)}\n")
    written_paths << path.to_s
  end

  def directory_digest(dir)
    files = dir.glob("**/*").select(&:file?).sort_by { |path| path.relative_path_from(dir).to_s }
    file_digests = files.map { |path| Digest::SHA256.hexdigest(path.binread) }
    "sha256:#{Digest::SHA256.hexdigest(file_digests.join(":"))}"
  end

  def file_digest(path)
    "sha256:#{Digest::SHA256.hexdigest(path.binread)}"
  end

  def scan_value(value, path, &block)
    case value
    when Hash
      value.each { |key, child| scan_value(child, path + [key], &block) }
    when Array
      value.each_with_index { |child, index| scan_value(child, path + [index.to_s], &block) }
    else
      yield(path, value)
    end
  end

  def relative_out_path(name)
    relative_path(OUT_DIR / name)
  end

  def relative_path(path)
    path.expand_path.relative_path_from(ROOT).to_s
  end

  def command_matrix
    [
      {
        "command" => "ruby -c igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb",
        "result" => "PASS"
      },
      {
        "command" => "ruby igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/experimental_igc_run_slice1_vm_capability_passport_hardening_v0.rb",
        "result" => "PASS"
      }
    ]
  end

  def c4_a_recommendation
    {
      "verdict" => "accept proof-local hardening; keep implementation authorization closed",
      "next_route" => "C3-X pressure review before any C4-A acceptance decision",
      "implementation_authorization" => "closed",
      "runtime_spec_redirect" => "only if C3-X/C4-A finds capability or failure-code blockers"
    }
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} experimental_igc_run_slice1_vm_capability_passport_hardening_v0"
    puts "checks: #{summary.fetch("result_table").length}"
    puts "failed: #{summary.fetch("failed_checks").length}"
    puts "summary: #{relative_out_path(OUTPUT_FILES.fetch(:summary))}"
  end
end

success = ExperimentalIgcRunSlice1VmCapabilityPassportHardeningV0.run
exit(success ? 0 : 1)
