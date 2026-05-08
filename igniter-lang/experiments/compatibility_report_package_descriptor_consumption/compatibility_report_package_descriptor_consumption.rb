#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"

module CompatibilityReportPackageDescriptorConsumption
  CARD = "S3-R10-C3-P"
  GATE = "gate_2_ratified_metadata_only"
  SUMMARY_PATH = Pathname(__dir__) / "compatibility_report_package_descriptor_consumption_summary.json"

  REQUIRED_PACKAGE_DESCRIPTOR_FIELDS = %w[
    kind
    adapter_kind
    adapter_ref
    adapter_version
    contract_version
    protocol
    protocol_schema_version
    ledger_protocol_ops
    supported_tbackend_ops
    hook_methods
    capabilities
    history_axes
    cursor_policy
    schema_fingerprint
    descriptor_hash
    descriptor_registry_hash
    evidence_mode
    source_snapshots
    non_authorization
  ].freeze

  EXPECTED_NON_AUTHORIZATION = %w[
    runtime_binding
    ledger_reads
    ledger_writes
    ledger_append
    ledger_replay
    ledger_compact
    ledger_subscribe
    migration_execution
  ].freeze

  BIHISTORY_WARNING = "descriptor bihistory_read is metadata evidence only; it does not prove physical BiHistory at(vt:, tt:) serving"

  module_function

  def compiled_requirement(schema_fingerprint:, cache_policy_kind: "temporal")
    {
      "contract_ref" => "contract:DispatchStatus",
      "contract_fragment_class" => "temporal",
      "required_ops" => %w[read append replay snapshot],
      "required_hook_methods" => %w[read_as_of bihistory_at],
      "required_capabilities" => %w[history_read bihistory_read],
      "history_axes" => %w[valid_time transaction_time],
      "schema_fingerprint" => schema_fingerprint,
      "cache_policy" => {
        "kind" => cache_policy_kind,
        "key_parts" => cache_policy_kind == "temporal" ? %w[contract inputs vt tt] : %w[contract inputs]
      }
    }
  end

  def ratified_package_descriptor(schema_fingerprint:)
    metadata_snapshot = {
      "schema_version" => 1,
      "stores" => [
        {
          "schema_version" => 1,
          "kind" => "store",
          "name" => "tickets",
          "key" => "id",
          "capabilities" => %w[write current_read as_of_read]
        }
      ],
      "histories" => [
        {
          "schema_version" => 1,
          "kind" => "history",
          "name" => "ticket_status_events",
          "key" => "ticket_id",
          "event_field" => "event",
          "timestamp_field" => "at"
        }
      ],
      "subscriptions" => [],
      "retention" => { "policies" => [] }
    }
    descriptor_snapshot = {
      "schema_version" => 1,
      "stores" => metadata_snapshot.fetch("stores"),
      "histories" => metadata_snapshot.fetch("histories"),
      "subscriptions" => []
    }
    descriptor_registry_hash = canonical_hash(
      "metadata_snapshot" => metadata_snapshot,
      "descriptor_snapshot" => descriptor_snapshot
    )

    payload_without_hash = {
      "kind" => "ledger_tbackend_adapter_descriptor",
      "adapter_kind" => "ledger_open_protocol",
      "adapter_ref" => "adapter:ledger-open-protocol/package-descriptor-v0",
      "adapter_version" => "0.1.0",
      "contract_version" => "tbackend.v0",
      "protocol" => "igniter_store",
      "protocol_schema_version" => 1,
      "ledger_protocol_ops" => %w[
        register_descriptor write append write_fact read query metadata_snapshot
        descriptor_snapshot sync_hub_profile replay compact subscribe
      ],
      "supported_tbackend_ops" => %w[read append replay snapshot compact subscribe],
      "hook_methods" => %w[read_as_of bihistory_at],
      "capabilities" => %w[history_read bihistory_read],
      "history_axes" => %w[valid_time transaction_time],
      "cursor_policy" => {
        "ordered" => "forward",
        "cursor_kinds" => %w[timestamp],
        "truncation_reported" => true,
        "tie_breaker" => "timestamp_then_fact_id_required"
      },
      "schema_fingerprint" => schema_fingerprint,
      "descriptor_registry_hash" => descriptor_registry_hash,
      "evidence_mode" => "receipt_required",
      "source_snapshots" => {
        "metadata_snapshot_present" => true,
        "descriptor_snapshot_present" => true
      },
      "non_authorization" => expected_non_authorization
    }

    payload_without_hash.merge("descriptor_hash" => canonical_hash(payload_without_hash))
  end

  def package_diagnostics(requirement:, descriptor:)
    missing_ops = Array(requirement["required_ops"]) - Array(descriptor["supported_tbackend_ops"])
    missing_hook_methods = Array(requirement["required_hook_methods"]) - Array(descriptor["hook_methods"])
    missing_capabilities = Array(requirement["required_capabilities"]) - Array(descriptor["capabilities"])
    missing_axes = Array(requirement["history_axes"]) - Array(descriptor["history_axes"])
    schema_fingerprint_match = requirement["schema_fingerprint"] == descriptor["schema_fingerprint"]
    blocked = [missing_ops, missing_hook_methods, missing_capabilities, missing_axes].any?(&:any?) ||
              !schema_fingerprint_match

    {
      "kind" => "ledger_tbackend_adapter_descriptor_diagnostics",
      "status" => blocked ? "blocked" : "ok",
      "missing_ops" => missing_ops,
      "missing_hook_methods" => missing_hook_methods,
      "missing_capabilities" => missing_capabilities,
      "missing_axes" => missing_axes,
      "schema_fingerprint_match" => schema_fingerprint_match,
      "descriptor_hash" => descriptor["descriptor_hash"],
      "descriptor_registry_hash" => descriptor["descriptor_registry_hash"]
    }
  end

  def consume(requirement:, descriptor:, diagnostics:)
    shape_diagnostic = descriptor_shape_diagnostic(descriptor)
    diagnostics_diagnostic = diagnostics_shape_diagnostic(diagnostics, descriptor)
    cache_diagnostic = cache_policy_diagnostic(requirement)
    authorization_diagnostic = non_authorization_diagnostic(descriptor)
    decision = decision_for(
      shape_diagnostic: shape_diagnostic,
      diagnostics: diagnostics,
      diagnostics_diagnostic: diagnostics_diagnostic,
      cache_diagnostic: cache_diagnostic,
      authorization_diagnostic: authorization_diagnostic
    )

    temporal_backend_descriptor = temporal_backend_descriptor_for(
      requirement: requirement,
      descriptor: descriptor,
      diagnostics: diagnostics,
      shape_diagnostic: shape_diagnostic,
      diagnostics_diagnostic: diagnostics_diagnostic,
      cache_diagnostic: cache_diagnostic,
      authorization_diagnostic: authorization_diagnostic
    )

    payload = {
      "kind" => "proof_local_compatibility_report",
      "card" => CARD,
      "gate" => GATE,
      "status" => decision == "blocked" ? "blocked" : "report_only",
      "schema_check" => {
        "decision" => diagnostics.is_a?(Hash) && diagnostics["schema_fingerprint_match"] == false ? "blocked" : "not_evaluated_here",
        "independent_from_backend_descriptor" => true
      },
      "backend_check" => {
        "decision" => decision,
        "report_only" => true,
        "runtime_enforced" => false,
        "temporal_backend_descriptor" => temporal_backend_descriptor
      },
      "non_authorization" => {
        "live_package_binding" => false,
        "runtime_binding" => false,
        "ledger_calls" => false,
        "ledger_reads" => false,
        "ledger_writes" => false,
        "ledger_replay" => false,
        "temporal_reads" => false,
        "live_adapter" => false,
        "gate_3_opened" => false
      }
    }
    payload.merge("report_id" => "compat/package_descriptor/#{short_hash(payload)}")
  end

  def descriptor_shape_diagnostic(descriptor)
    missing_fields = REQUIRED_PACKAGE_DESCRIPTOR_FIELDS.reject { |field| present?(descriptor[field]) }
    malformed_fields = []
    malformed_fields << "kind" unless descriptor["kind"] == "ledger_tbackend_adapter_descriptor"
    malformed_fields << "adapter_kind" unless descriptor["adapter_kind"] == "ledger_open_protocol"
    malformed_fields << "contract_version" unless descriptor["contract_version"] == "tbackend.v0"
    malformed_fields << "cursor_policy" unless valid_cursor_policy?(descriptor["cursor_policy"])
    malformed_fields << "non_authorization" unless descriptor["non_authorization"].is_a?(Hash)

    {
      "kind" => "package_descriptor_shape_diagnostic",
      "status" => missing_fields.empty? && malformed_fields.empty? ? "ok" : "blocked",
      "missing_fields" => missing_fields,
      "malformed_fields" => malformed_fields.uniq
    }
  end

  def diagnostics_shape_diagnostic(diagnostics, descriptor)
    return missing_diagnostics_diagnostic unless diagnostics.is_a?(Hash)

    missing_fields = %w[
      kind
      status
      missing_ops
      missing_hook_methods
      missing_capabilities
      missing_axes
      schema_fingerprint_match
      descriptor_hash
      descriptor_registry_hash
    ].reject { |field| diagnostics.key?(field) }

    malformed_fields = []
    malformed_fields << "kind" unless diagnostics["kind"] == "ledger_tbackend_adapter_descriptor_diagnostics"
    malformed_fields << "status" unless %w[ok blocked].include?(diagnostics["status"])
    malformed_fields << "descriptor_hash" unless diagnostics["descriptor_hash"] == descriptor["descriptor_hash"]
    malformed_fields << "descriptor_registry_hash" unless diagnostics["descriptor_registry_hash"] == descriptor["descriptor_registry_hash"]

    {
      "kind" => "package_descriptor_diagnostics_shape_diagnostic",
      "status" => missing_fields.empty? && malformed_fields.empty? ? "ok" : "blocked",
      "missing_fields" => missing_fields,
      "malformed_fields" => malformed_fields.uniq
    }
  end

  def missing_diagnostics_diagnostic
    {
      "kind" => "package_descriptor_diagnostics_shape_diagnostic",
      "status" => "blocked",
      "missing_fields" => ["diagnostics"],
      "malformed_fields" => []
    }
  end

  def cache_policy_diagnostic(requirement)
    temporal_contract = requirement["contract_fragment_class"] == "temporal"
    cache_policy = requirement["cache_policy"] || {}
    ok = !temporal_contract || cache_policy["kind"] == "temporal"
    {
      "kind" => "temporal_cache_policy_diagnostic",
      "status" => ok ? "ok" : "blocked",
      "rule" => ok ? nil : "OOF-TM9",
      "contract_fragment_class" => requirement["contract_fragment_class"],
      "cache_policy_kind" => cache_policy["kind"]
    }
  end

  def non_authorization_diagnostic(descriptor)
    flags = descriptor["non_authorization"]
    return { "kind" => "descriptor_non_authorization_diagnostic", "status" => "blocked", "violations" => ["non_authorization_missing"] } unless flags.is_a?(Hash)

    missing_flags = EXPECTED_NON_AUTHORIZATION.reject { |field| flags.key?(field) }
    positive_flags = flags.select { |_key, value| value != false }.keys
    {
      "kind" => "descriptor_non_authorization_diagnostic",
      "status" => missing_flags.empty? && positive_flags.empty? ? "ok" : "blocked",
      "missing_flags" => missing_flags,
      "violations" => positive_flags
    }
  end

  def decision_for(shape_diagnostic:, diagnostics:, diagnostics_diagnostic:, cache_diagnostic:, authorization_diagnostic:)
    return "blocked" unless shape_diagnostic["status"] == "ok"
    return "blocked" unless diagnostics_diagnostic["status"] == "ok"
    return "blocked" unless diagnostics["status"] == "ok"
    return "blocked" unless cache_diagnostic["status"] == "ok"
    return "blocked" unless authorization_diagnostic["status"] == "ok"

    "trusted_metadata"
  end

  def temporal_backend_descriptor_for(requirement:, descriptor:, diagnostics:, shape_diagnostic:, diagnostics_diagnostic:, cache_diagnostic:, authorization_diagnostic:)
    descriptor_hash = descriptor["descriptor_hash"]
    registry_hash = descriptor["descriptor_registry_hash"]
    {
      "source" => "ratified_package_descriptor_metadata",
      "package_class" => "Igniter::Store::TBackendAdapterDescriptor",
      "package_alias" => "Igniter::Ledger::TBackendAdapterDescriptor",
      "descriptor_kind" => descriptor["kind"],
      "adapter_kind" => descriptor["adapter_kind"],
      "descriptor_hash" => descriptor_hash,
      "descriptor_registry_hash" => registry_hash,
      "required_ops" => requirement["required_ops"],
      "supported_tbackend_ops" => Array(descriptor["supported_tbackend_ops"]),
      "required_hook_methods" => requirement["required_hook_methods"],
      "hook_methods" => Array(descriptor["hook_methods"]),
      "required_capabilities" => requirement["required_capabilities"],
      "capabilities" => Array(descriptor["capabilities"]),
      "required_axes" => requirement["history_axes"],
      "history_axes" => Array(descriptor["history_axes"]),
      "cursor_policy" => descriptor["cursor_policy"] || {},
      "diagnostics" => {
        "package_descriptor" => diagnostics,
        "descriptor_shape" => shape_diagnostic,
        "diagnostics_shape" => diagnostics_diagnostic,
        "cache_policy" => cache_diagnostic,
        "non_authorization" => authorization_diagnostic
      },
      "warnings" => [BIHISTORY_WARNING],
      "evidence_links" => evidence_links(descriptor_hash, registry_hash),
      "non_authorization" => descriptor["non_authorization"] || {}
    }
  end

  def evidence_links(descriptor_hash, registry_hash)
    links = []
    links << { "rel" => "described_by", "to" => descriptor_hash } if present?(descriptor_hash)
    links << { "rel" => "registry_snapshot", "to" => registry_hash } if present?(registry_hash)
    links
  end

  def valid_cursor_policy?(cursor_policy)
    cursor_policy.is_a?(Hash) &&
      cursor_policy["ordered"] == "forward" &&
      Array(cursor_policy["cursor_kinds"]).include?("timestamp") &&
      cursor_policy["truncation_reported"] == true &&
      cursor_policy["tie_breaker"] == "timestamp_then_fact_id_required"
  end

  def expected_non_authorization
    EXPECTED_NON_AUTHORIZATION.to_h { |field| [field, false] }
  end

  def remove_key(hash, key)
    hash.reject { |entry_key, _value| entry_key == key }
  end

  def without_array_value(hash, key, value)
    hash.merge(key => Array(hash[key]) - [value])
  end

  def with_non_authorization_violation(descriptor)
    descriptor.merge(
      "non_authorization" => descriptor.fetch("non_authorization").merge("ledger_reads" => true)
    )
  end

  def malformed_package_diagnostics(diagnostics)
    diagnostics.merge("kind" => "unexpected_diagnostics")
  end

  def present?(value)
    !value.nil? && value != "" && value != [] && value != {}
  end

  def canonical_hash(value)
    "sha256:#{Digest::SHA256.hexdigest(JSON.generate(canonicalize(value)))}"
  end

  def short_hash(value)
    Digest::SHA256.hexdigest(JSON.generate(canonicalize(value)))[0, 16]
  end

  def canonicalize(value)
    case value
    when Hash
      value.keys.map(&:to_s).sort.to_h { |key| [key, canonicalize(value[key])] }
    when Array
      value.map { |entry| canonicalize(entry) }
    else
      value
    end
  end

  def assert(label)
    raise "FAIL #{label}" unless yield

    puts "PASS #{label}"
  end

  def write_summary(summary)
    SUMMARY_PATH.write("#{JSON.pretty_generate(summary)}\n")
    SUMMARY_PATH
  end
end

if $PROGRAM_NAME == __FILE__
  include CompatibilityReportPackageDescriptorConsumption

  schema_fingerprint = "sha256:compiled-schema-proof"
  requirement = CompatibilityReportPackageDescriptorConsumption.compiled_requirement(
    schema_fingerprint: schema_fingerprint
  )
  descriptor = CompatibilityReportPackageDescriptorConsumption.ratified_package_descriptor(
    schema_fingerprint: schema_fingerprint
  )
  diagnostics = CompatibilityReportPackageDescriptorConsumption.package_diagnostics(
    requirement: requirement,
    descriptor: descriptor
  )

  cases = {
    "trusted_metadata" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: descriptor,
      diagnostics: diagnostics
    ),
    "missing_descriptor_hash" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: CompatibilityReportPackageDescriptorConsumption.remove_key(descriptor, "descriptor_hash"),
      diagnostics: CompatibilityReportPackageDescriptorConsumption.package_diagnostics(
        requirement: requirement,
        descriptor: CompatibilityReportPackageDescriptorConsumption.remove_key(descriptor, "descriptor_hash")
      )
    ),
    "missing_registry_hash" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: CompatibilityReportPackageDescriptorConsumption.remove_key(descriptor, "descriptor_registry_hash"),
      diagnostics: CompatibilityReportPackageDescriptorConsumption.package_diagnostics(
        requirement: requirement,
        descriptor: CompatibilityReportPackageDescriptorConsumption.remove_key(descriptor, "descriptor_registry_hash")
      )
    ),
    "missing_capability" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: CompatibilityReportPackageDescriptorConsumption.without_array_value(descriptor, "capabilities", "bihistory_read"),
      diagnostics: CompatibilityReportPackageDescriptorConsumption.package_diagnostics(
        requirement: requirement,
        descriptor: CompatibilityReportPackageDescriptorConsumption.without_array_value(descriptor, "capabilities", "bihistory_read")
      )
    ),
    "missing_axis" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: CompatibilityReportPackageDescriptorConsumption.without_array_value(descriptor, "history_axes", "transaction_time"),
      diagnostics: CompatibilityReportPackageDescriptorConsumption.package_diagnostics(
        requirement: requirement,
        descriptor: CompatibilityReportPackageDescriptorConsumption.without_array_value(descriptor, "history_axes", "transaction_time")
      )
    ),
    "missing_cursor_policy" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: CompatibilityReportPackageDescriptorConsumption.remove_key(descriptor, "cursor_policy"),
      diagnostics: diagnostics
    ),
    "missing_package_diagnostics" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: descriptor,
      diagnostics: nil
    ),
    "malformed_package_diagnostics" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: descriptor,
      diagnostics: CompatibilityReportPackageDescriptorConsumption.malformed_package_diagnostics(diagnostics)
    ),
    "non_authorization_violation" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: CompatibilityReportPackageDescriptorConsumption.with_non_authorization_violation(descriptor),
      diagnostics: diagnostics
    ),
    "bad_cache_policy" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: CompatibilityReportPackageDescriptorConsumption.compiled_requirement(
        schema_fingerprint: schema_fingerprint,
        cache_policy_kind: "core"
      ),
      descriptor: descriptor,
      diagnostics: diagnostics
    ),
    "malformed_descriptor_kind" => CompatibilityReportPackageDescriptorConsumption.consume(
      requirement: requirement,
      descriptor: descriptor.merge("kind" => "ledger_live_adapter"),
      diagnostics: diagnostics
    )
  }

  summary = {
    "kind" => "compatibility_report_package_descriptor_consumption_summary",
    "card" => CARD,
    "status" => "PASS",
    "gate" => GATE,
    "report_only" => true,
    "runtime_enforced" => false,
    "non_authorization" => {
      "live_package_binding" => false,
      "ledger_calls" => false,
      "temporal_reads" => false,
      "gate_3_opened" => false
    },
    "cases" => cases.to_h do |case_name, report|
      descriptor_report = report.fetch("backend_check").fetch("temporal_backend_descriptor")
      [
        case_name,
        {
          "decision" => report.fetch("backend_check").fetch("decision"),
          "report_id" => report.fetch("report_id"),
          "runtime_enforced" => report.fetch("backend_check").fetch("runtime_enforced"),
          "report_only" => report.fetch("backend_check").fetch("report_only"),
          "descriptor_hash" => descriptor_report["descriptor_hash"],
          "descriptor_registry_hash" => descriptor_report["descriptor_registry_hash"],
          "warnings" => descriptor_report.fetch("warnings"),
          "diagnostics" => descriptor_report.fetch("diagnostics")
        }
      ]
    end
  }

  trusted = cases.fetch("trusted_metadata")
  trusted_descriptor = trusted.fetch("backend_check").fetch("temporal_backend_descriptor")

  CompatibilityReportPackageDescriptorConsumption.assert("trusted package descriptor is trusted_metadata") do
    trusted.fetch("backend_check").fetch("decision") == "trusted_metadata"
  end
  CompatibilityReportPackageDescriptorConsumption.assert("descriptor hashes are preserved") do
    trusted_descriptor.fetch("descriptor_hash") == descriptor.fetch("descriptor_hash") &&
      trusted_descriptor.fetch("descriptor_registry_hash") == descriptor.fetch("descriptor_registry_hash")
  end
  CompatibilityReportPackageDescriptorConsumption.assert("capabilities axes cursor policy diagnostics are preserved") do
    trusted_descriptor.fetch("capabilities") == descriptor.fetch("capabilities") &&
      trusted_descriptor.fetch("history_axes") == descriptor.fetch("history_axes") &&
      trusted_descriptor.fetch("cursor_policy") == descriptor.fetch("cursor_policy") &&
      trusted_descriptor.fetch("diagnostics").fetch("package_descriptor") == diagnostics
  end
  CompatibilityReportPackageDescriptorConsumption.assert("non_authorization flags are preserved") do
    trusted_descriptor.fetch("non_authorization") == descriptor.fetch("non_authorization")
  end
  CompatibilityReportPackageDescriptorConsumption.assert("BiHistory warning is present") do
    trusted_descriptor.fetch("warnings").include?(BIHISTORY_WARNING)
  end
  (cases.keys - ["trusted_metadata"]).each do |case_name|
    CompatibilityReportPackageDescriptorConsumption.assert("#{case_name} is blocked") do
      cases.fetch(case_name).fetch("backend_check").fetch("decision") == "blocked"
    end
  end
  CompatibilityReportPackageDescriptorConsumption.assert("all reports are report-only and not runtime-enforced") do
    cases.values.all? do |report|
      report.fetch("backend_check").fetch("report_only") == true &&
        report.fetch("backend_check").fetch("runtime_enforced") == false
    end
  end
  CompatibilityReportPackageDescriptorConsumption.assert("proof does not authorize package binding, ledger calls, temporal reads, or Gate 3") do
    cases.values.all? do |report|
      non_authorization = report.fetch("non_authorization")
      non_authorization.fetch("live_package_binding") == false &&
        non_authorization.fetch("ledger_calls") == false &&
        non_authorization.fetch("temporal_reads") == false &&
        non_authorization.fetch("gate_3_opened") == false
    end
  end

  out_path = CompatibilityReportPackageDescriptorConsumption.write_summary(summary)
  puts "PASS summary written #{out_path.relative_path_from(Pathname(Dir.pwd))}"
end
