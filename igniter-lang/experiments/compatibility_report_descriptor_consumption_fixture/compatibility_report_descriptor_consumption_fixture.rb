#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

require_relative "../ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture"

module CompatibilityReportDescriptorConsumptionFixture
  DescriptorFixture = LedgerTBackendAdapterDescriptorFixture
  TemporalRuntime = IgniterLang::TemporalAccessRuntime
  Canonical = TemporalRuntime::Canonical

  module_function

  def compiled_temporal_requirement(schema_fingerprint:, cache_policy_kind: "temporal")
    {
      "contract_ref" => "contract:DispatchStatus",
      "contract_fragment_class" => "temporal",
      "required_ops" => %w[read append replay snapshot],
      "required_hook_methods" => %w[read_as_of bihistory_at],
      "required_capabilities" => [
        TemporalRuntime::Capabilities::HISTORY_READ,
        TemporalRuntime::Capabilities::BIHISTORY_READ
      ],
      "history_axes" => %w[valid_time transaction_time],
      "schema_fingerprint" => schema_fingerprint,
      "cache_policy" => {
        "kind" => cache_policy_kind,
        "key_parts" => cache_policy_kind == "temporal" ? %w[contract inputs vt tt] : %w[contract inputs]
      }
    }
  end

  def base_descriptor(schema_fingerprint:)
    metadata_snapshot = DescriptorFixture.sample_metadata_snapshot
    descriptor_snapshot = DescriptorFixture.sample_descriptor_snapshot(metadata_snapshot)
    DescriptorFixture.build_descriptor(
      metadata_snapshot: metadata_snapshot,
      descriptor_snapshot: descriptor_snapshot,
      schema_fingerprint: schema_fingerprint
    )
  end

  def consume(requirement:, descriptor:)
    diagnostic = descriptor_diagnostic(requirement: requirement, descriptor: descriptor)
    cache_diagnostic = cache_policy_diagnostic(requirement)
    authorization_diagnostic = non_authorization_diagnostic(descriptor)
    decision = decision_for(diagnostic, cache_diagnostic, authorization_diagnostic, descriptor)
    temporal_backend_descriptor = temporal_backend_descriptor_for(
      requirement: requirement,
      descriptor: descriptor,
      diagnostic: diagnostic,
      cache_diagnostic: cache_diagnostic,
      authorization_diagnostic: authorization_diagnostic
    )

    payload = {
      "kind" => "proof_local_compatibility_report",
      "dimension" => "temporal_backend_adapter",
      "status" => decision == "blocked" ? "blocked" : "report_only",
      "schema_check" => {
        "decision" => diagnostic.fetch("schema_fingerprint_match") ? "not_evaluated_here" : "blocked",
        "independent_from_backend_descriptor" => true
      },
      "backend_check" => {
        "decision" => decision,
        "runtime_enforced" => false,
        "report_only" => true,
        "temporal_backend_descriptor" => temporal_backend_descriptor
      },
      "non_authorization" => {
        "package_exposure" => false,
        "runtime_binding" => false,
        "ledger_reads" => false,
        "ledger_writes" => false,
        "ledger_replay" => false,
        "live_adapter" => false
      }
    }
    payload.merge("report_id" => "compat/descriptor_consumption/#{Canonical.short_hash(payload)}")
  end

  def descriptor_diagnostic(requirement:, descriptor:)
    missing_ops = requirement.fetch("required_ops", []) - descriptor.fetch("supported_tbackend_ops", [])
    missing_hook_methods = requirement.fetch("required_hook_methods", []) - descriptor.fetch("hook_methods", [])
    missing_capabilities = requirement.fetch("required_capabilities", []) - descriptor.fetch("capabilities", [])
    missing_axes = requirement.fetch("history_axes", []) - descriptor.fetch("history_axes", [])
    missing_hashes = %w[descriptor_hash descriptor_registry_hash].reject { |key| present?(descriptor[key]) }
    schema_fingerprint_match = requirement.fetch("schema_fingerprint") == descriptor["schema_fingerprint"]

    {
      "kind" => "tbackend_descriptor_consumption_diagnostics",
      "status" => [missing_ops, missing_hook_methods, missing_capabilities, missing_axes, missing_hashes].all?(&:empty?) && schema_fingerprint_match ? "ok" : "blocked",
      "missing_ops" => missing_ops,
      "missing_hook_methods" => missing_hook_methods,
      "missing_capabilities" => missing_capabilities,
      "missing_axes" => missing_axes,
      "missing_hashes" => missing_hashes,
      "schema_fingerprint_match" => schema_fingerprint_match,
      "descriptor_hash" => descriptor["descriptor_hash"],
      "descriptor_registry_hash" => descriptor["descriptor_registry_hash"]
    }
  end

  def cache_policy_diagnostic(requirement)
    temporal_contract = requirement.fetch("contract_fragment_class") == "temporal"
    cache_policy = requirement["cache_policy"] || {}
    temporal_cache = cache_policy["kind"] == "temporal"
    ok = !temporal_contract || temporal_cache
    {
      "kind" => "temporal_cache_policy_diagnostic",
      "status" => ok ? "ok" : "blocked",
      "rule" => ok ? nil : "OOF-TM9",
      "contract_fragment_class" => requirement.fetch("contract_fragment_class"),
      "cache_policy_kind" => cache_policy["kind"],
      "message" => ok ? "TEMPORAL cache policy present" : "TEMPORAL contract cannot use CORE cache key"
    }
  end

  def non_authorization_diagnostic(descriptor)
    flags = descriptor.fetch("non_authorization", {})
    violations = flags.select { |_key, value| value != false }.keys
    {
      "kind" => "descriptor_non_authorization_diagnostic",
      "status" => violations.empty? ? "ok" : "blocked",
      "violations" => violations,
      "expected_false" => %w[runtime_binding ledger_reads ledger_writes ledger_replay]
    }
  end

  def decision_for(descriptor_diagnostic, cache_diagnostic, authorization_diagnostic, descriptor)
    return "blocked" unless descriptor_diagnostic.fetch("status") == "ok"
    return "blocked" unless cache_diagnostic.fetch("status") == "ok"
    return "blocked" unless authorization_diagnostic.fetch("status") == "ok"

    cursor_policy = descriptor.fetch("cursor_policy", {})
    snapshot_state = descriptor.fetch("snapshot_policy", {})["state_bearing"]
    return "provisional_metadata" unless cursor_policy["tie_breaker"] == "timestamp_then_fact_id_required"
    return "provisional_metadata" if snapshot_state == false

    "trusted_metadata"
  end

  def temporal_backend_descriptor_for(requirement:, descriptor:, diagnostic:, cache_diagnostic:, authorization_diagnostic:)
    descriptor_hash = descriptor["descriptor_hash"]
    registry_hash = descriptor["descriptor_registry_hash"]
    {
      "descriptor_kind" => descriptor.fetch("kind", nil),
      "adapter_kind" => descriptor.fetch("adapter_kind", nil),
      "descriptor_hash" => descriptor_hash,
      "descriptor_registry_hash" => registry_hash,
      "schema_fingerprint_match" => diagnostic.fetch("schema_fingerprint_match"),
      "required_ops" => requirement.fetch("required_ops"),
      "supported_tbackend_ops" => descriptor.fetch("supported_tbackend_ops", []),
      "required_hook_methods" => requirement.fetch("required_hook_methods"),
      "hook_methods" => descriptor.fetch("hook_methods", []),
      "required_capabilities" => requirement.fetch("required_capabilities"),
      "capabilities" => descriptor.fetch("capabilities", []),
      "required_axes" => requirement.fetch("history_axes"),
      "history_axes" => descriptor.fetch("history_axes", []),
      "cursor_policy" => descriptor.fetch("cursor_policy", {}),
      "diagnostics" => {
        "descriptor" => diagnostic,
        "cache_policy" => cache_diagnostic,
        "non_authorization" => authorization_diagnostic
      },
      "evidence_links" => evidence_links(descriptor_hash, registry_hash)
    }
  end

  def evidence_links(descriptor_hash, registry_hash)
    links = []
    links << { "rel" => "described_by", "to" => descriptor_hash } if present?(descriptor_hash)
    links << { "rel" => "registry_snapshot", "to" => registry_hash } if present?(registry_hash)
    links
  end

  def present?(value)
    !value.nil? && value != ""
  end

  def without_descriptor_hash(descriptor)
    descriptor.reject { |key, _value| key == "descriptor_hash" }
  end

  def without_registry_hash(descriptor)
    descriptor.reject { |key, _value| key == "descriptor_registry_hash" }
  end

  def without_capability(descriptor, capability)
    descriptor.merge("capabilities" => descriptor.fetch("capabilities") - [capability])
  end

  def without_axis(descriptor, axis)
    descriptor.merge("history_axes" => descriptor.fetch("history_axes") - [axis])
  end

  def without_hook_method(descriptor, method_name)
    descriptor.merge("hook_methods" => descriptor.fetch("hook_methods") - [method_name])
  end

  def provisional_descriptor(descriptor)
    descriptor.merge(
      "cursor_policy" => descriptor.fetch("cursor_policy").merge("tie_breaker" => "timestamp_only_unproven"),
      "snapshot_policy" => { "state_bearing" => false }
    )
  end

  def assert(label)
    raise "FAIL #{label}" unless yield

    puts "PASS #{label}"
  end

  def write_summary(summary)
    out_path = Pathname(__dir__) / "compatibility_report_descriptor_consumption_summary.json"
    out_path.write("#{JSON.pretty_generate(summary)}\n")
    out_path
  end
end

if $PROGRAM_NAME == __FILE__
  include CompatibilityReportDescriptorConsumptionFixture

  schema_fingerprint = "sha256:compiled-schema-proof"
  requirement = CompatibilityReportDescriptorConsumptionFixture.compiled_temporal_requirement(
    schema_fingerprint: schema_fingerprint
  )
  descriptor = CompatibilityReportDescriptorConsumptionFixture.base_descriptor(
    schema_fingerprint: schema_fingerprint
  )

  cases = {
    "trusted_metadata" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: requirement,
      descriptor: descriptor
    ),
    "provisional_metadata" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: requirement,
      descriptor: CompatibilityReportDescriptorConsumptionFixture.provisional_descriptor(descriptor)
    ),
    "missing_capability" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: requirement,
      descriptor: CompatibilityReportDescriptorConsumptionFixture.without_capability(
        descriptor,
        TemporalRuntime::Capabilities::BIHISTORY_READ
      )
    ),
    "missing_axis" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: requirement,
      descriptor: CompatibilityReportDescriptorConsumptionFixture.without_axis(descriptor, "transaction_time")
    ),
    "missing_hook" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: requirement,
      descriptor: CompatibilityReportDescriptorConsumptionFixture.without_hook_method(descriptor, "bihistory_at")
    ),
    "missing_descriptor_hash" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: requirement,
      descriptor: CompatibilityReportDescriptorConsumptionFixture.without_descriptor_hash(descriptor)
    ),
    "missing_registry_hash" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: requirement,
      descriptor: CompatibilityReportDescriptorConsumptionFixture.without_registry_hash(descriptor)
    ),
    "bad_cache_policy" => CompatibilityReportDescriptorConsumptionFixture.consume(
      requirement: CompatibilityReportDescriptorConsumptionFixture.compiled_temporal_requirement(
        schema_fingerprint: schema_fingerprint,
        cache_policy_kind: "core"
      ),
      descriptor: descriptor
    )
  }

  summary = {
    "kind" => "compatibility_report_descriptor_consumption_summary",
    "card" => "S3-R3-C5-P",
    "status" => "PASS",
    "approved_gate" => "gate_1_proof_local_only",
    "runtime_enforced" => false,
    "report_only" => true,
    "non_authorization" => {
      "package_exposure" => false,
      "runtime_binding" => false,
      "ledger_reads" => false,
      "ledger_writes" => false,
      "ledger_replay" => false,
      "live_adapter" => false
    },
    "cases" => cases.transform_values do |report|
      {
        "decision" => report.fetch("backend_check").fetch("decision"),
        "report_id" => report.fetch("report_id"),
        "runtime_enforced" => report.fetch("backend_check").fetch("runtime_enforced"),
        "diagnostics" => report.fetch("backend_check").fetch("temporal_backend_descriptor").fetch("diagnostics")
      }
    end
  }

  CompatibilityReportDescriptorConsumptionFixture.assert("trusted descriptor is trusted_metadata") do
    cases.fetch("trusted_metadata").fetch("backend_check").fetch("decision") == "trusted_metadata"
  end
  CompatibilityReportDescriptorConsumptionFixture.assert("provisional descriptor is provisional_metadata") do
    cases.fetch("provisional_metadata").fetch("backend_check").fetch("decision") == "provisional_metadata"
  end
  %w[
    missing_capability
    missing_axis
    missing_hook
    missing_descriptor_hash
    missing_registry_hash
    bad_cache_policy
  ].each do |case_name|
    CompatibilityReportDescriptorConsumptionFixture.assert("#{case_name} is blocked") do
      cases.fetch(case_name).fetch("backend_check").fetch("decision") == "blocked"
    end
  end
  CompatibilityReportDescriptorConsumptionFixture.assert("all reports remain report-only") do
    cases.values.all? { |report| report.fetch("backend_check").fetch("runtime_enforced") == false }
  end

  out_path = CompatibilityReportDescriptorConsumptionFixture.write_summary(summary)
  puts "PASS summary written #{out_path.relative_path_from(Pathname(Dir.pwd))}"
end
