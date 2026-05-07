#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

require_relative "../../lib/igniter_lang/temporal_access_runtime"

module LedgerTBackendAdapterDescriptorFixture
  TemporalRuntime = IgniterLang::TemporalAccessRuntime
  Canonical = TemporalRuntime::Canonical

  ALL_TBACKEND_OPS = %w[read append replay snapshot compact subscribe].freeze
  ALL_HOOK_METHODS = %w[read_as_of bihistory_at].freeze
  ALL_CAPABILITIES = [
    TemporalRuntime::Capabilities::HISTORY_READ,
    TemporalRuntime::Capabilities::BIHISTORY_READ
  ].freeze
  ALL_AXES = %w[valid_time transaction_time].freeze

  module_function

  def sample_metadata_snapshot(include_history: true, include_subscription: true, include_retention: true)
    {
      "schema_version" => 1,
      "stores" => [
        {
          "schema_version" => 1,
          "kind" => "store",
          "name" => "tickets",
          "key" => "id",
          "fields" => [
            { "name" => "id", "type" => "string", "required" => true },
            { "name" => "status", "type" => "symbol" }
          ],
          "capabilities" => %w[write current_read as_of_read],
          "producer" => { "system" => "fixture" }
        }
      ],
      "histories" => include_history ? [
        {
          "schema_version" => 1,
          "kind" => "history",
          "name" => "ticket_status_events",
          "key" => "ticket_id",
          "event_field" => "event",
          "timestamp_field" => "at",
          "producer" => { "system" => "fixture" }
        }
      ] : [],
      "subscriptions" => include_subscription ? [
        {
          "schema_version" => 1,
          "kind" => "subscription",
          "name" => "ticket_changes",
          "source" => "tickets",
          "events" => %w[write compact]
        }
      ] : [],
      "retention" => include_retention ? [
        {
          "schema_version" => 1,
          "kind" => "retention",
          "name" => "ticket_status_retention",
          "source" => "ticket_status_events",
          "policy" => "preserve_active_runtime_evidence"
        }
      ] : []
    }
  end

  def sample_descriptor_snapshot(metadata_snapshot)
    {
      "schema_version" => metadata_snapshot.fetch("schema_version"),
      "stores" => metadata_snapshot.fetch("stores"),
      "histories" => metadata_snapshot.fetch("histories"),
      "subscriptions" => metadata_snapshot.fetch("subscriptions"),
      "retention" => metadata_snapshot.fetch("retention")
    }
  end

  def build_descriptor(metadata_snapshot:, descriptor_snapshot:, schema_fingerprint:,
                       adapter_ref: "adapter:ledger-open-protocol/proof-descriptor",
                       ledger_protocol_ops: default_ledger_protocol_ops)
    supported_ops = supported_tbackend_ops(ledger_protocol_ops)
    has_history_descriptor = !descriptor_snapshot.fetch("histories", []).empty?
    hook_methods = hook_methods_for(supported_ops, has_history_descriptor)
    capabilities = capabilities_for(hook_methods)
    history_axes = history_axes_for(hook_methods)

    payload = {
      "kind" => "ledger_tbackend_adapter_descriptor",
      "adapter_kind" => "ledger_open_protocol",
      "adapter_ref" => adapter_ref,
      "adapter_version" => "0.1.0-proof",
      "contract_version" => "tbackend.v0",
      "protocol" => "igniter_store",
      "protocol_schema_version" => metadata_snapshot.fetch("schema_version"),
      "ledger_protocol_ops" => ledger_protocol_ops,
      "supported_tbackend_ops" => supported_ops,
      "hook_methods" => hook_methods,
      "capabilities" => capabilities,
      "history_axes" => history_axes,
      "cursor_policy" => cursor_policy(ledger_protocol_ops),
      "schema_fingerprint" => schema_fingerprint,
      "descriptor_registry_hash" => descriptor_registry_hash(
        metadata_snapshot: metadata_snapshot,
        descriptor_snapshot: descriptor_snapshot
      ),
      "evidence_mode" => "receipt_required",
      "source_snapshots" => {
        "metadata_snapshot_present" => true,
        "descriptor_snapshot_present" => true
      },
      "non_authorization" => {
        "runtime_binding" => false,
        "ledger_reads" => false,
        "ledger_writes" => false,
        "ledger_replay" => false
      }
    }
    payload.merge("descriptor_hash" => Canonical.hash(payload))
  end

  def descriptor_registry_hash(metadata_snapshot:, descriptor_snapshot:)
    Canonical.hash(
      "metadata_snapshot" => metadata_snapshot,
      "descriptor_snapshot" => descriptor_snapshot
    )
  end

  def default_ledger_protocol_ops
    %w[
      register_descriptor write append write_fact read query metadata_snapshot
      descriptor_snapshot sync_hub_profile replay compact subscribe
    ]
  end

  def supported_tbackend_ops(ledger_protocol_ops)
    ops = []
    ops << "read" if (ledger_protocol_ops & %w[read query fact_ref]).any?
    ops << "append" if (ledger_protocol_ops & %w[write write_fact append]).any?
    ops << "replay" if (ledger_protocol_ops & %w[replay sync_hub_profile]).any?
    ops << "snapshot" if (ledger_protocol_ops & %w[metadata_snapshot descriptor_snapshot sync_hub_profile]).any?
    ops << "compact" if ledger_protocol_ops.include?("compact")
    ops << "subscribe" if ledger_protocol_ops.include?("subscribe")
    ops & ALL_TBACKEND_OPS
  end

  def hook_methods_for(supported_ops, has_history_descriptor)
    methods = []
    methods << "read_as_of" if supported_ops.include?("read")
    methods << "bihistory_at" if has_history_descriptor && supported_ops.include?("read") && supported_ops.include?("replay")
    methods & ALL_HOOK_METHODS
  end

  def capabilities_for(hook_methods)
    capabilities = []
    capabilities << TemporalRuntime::Capabilities::HISTORY_READ if hook_methods.include?("read_as_of")
    capabilities << TemporalRuntime::Capabilities::BIHISTORY_READ if hook_methods.include?("bihistory_at")
    capabilities & ALL_CAPABILITIES
  end

  def history_axes_for(hook_methods)
    axes = []
    axes << "valid_time" if hook_methods.include?("read_as_of")
    axes += %w[valid_time transaction_time] if hook_methods.include?("bihistory_at")
    axes.uniq & ALL_AXES
  end

  def cursor_policy(ledger_protocol_ops)
    replayable = (ledger_protocol_ops & %w[replay sync_hub_profile]).any?
    {
      "ordered" => "forward",
      "cursor_kinds" => replayable ? %w[timestamp] : [],
      "truncation_reported" => replayable,
      "tie_breaker" => "timestamp_then_fact_id_required"
    }
  end

  def diagnostics(requirement:, descriptor:)
    missing_ops = requirement.fetch("required_ops", []) - descriptor.fetch("supported_tbackend_ops")
    missing_hook_methods = requirement.fetch("required_hook_methods", []) - descriptor.fetch("hook_methods")
    missing_capabilities = requirement.fetch("required_capabilities", []) - descriptor.fetch("capabilities")
    missing_axes = requirement.fetch("history_axes", []) - descriptor.fetch("history_axes")
    schema_mismatch = requirement.fetch("schema_fingerprint") != descriptor.fetch("schema_fingerprint")

    {
      "kind" => "ledger_tbackend_adapter_descriptor_diagnostics",
      "status" => [missing_ops, missing_hook_methods, missing_capabilities, missing_axes].all?(&:empty?) && !schema_mismatch ? "ok" : "blocked",
      "missing_ops" => missing_ops,
      "missing_hook_methods" => missing_hook_methods,
      "missing_capabilities" => missing_capabilities,
      "missing_axes" => missing_axes,
      "schema_fingerprint_match" => !schema_mismatch,
      "descriptor_hash" => descriptor.fetch("descriptor_hash"),
      "descriptor_registry_hash" => descriptor.fetch("descriptor_registry_hash")
    }
  end

  def requirement(schema_fingerprint:)
    {
      "required_ops" => %w[read append replay snapshot],
      "required_hook_methods" => %w[read_as_of bihistory_at],
      "required_capabilities" => ALL_CAPABILITIES,
      "history_axes" => ALL_AXES,
      "schema_fingerprint" => schema_fingerprint
    }
  end

  def assert(label)
    raise "FAIL #{label}" unless yield

    puts "PASS #{label}"
  end
end

if $PROGRAM_NAME == __FILE__
  include LedgerTBackendAdapterDescriptorFixture

  schema_fingerprint = "sha256:compiled-schema-proof"
  metadata_snapshot = LedgerTBackendAdapterDescriptorFixture.sample_metadata_snapshot
  descriptor_snapshot = LedgerTBackendAdapterDescriptorFixture.sample_descriptor_snapshot(metadata_snapshot)
  descriptor = LedgerTBackendAdapterDescriptorFixture.build_descriptor(
    metadata_snapshot: metadata_snapshot,
    descriptor_snapshot: descriptor_snapshot,
    schema_fingerprint: schema_fingerprint
  )
  duplicate = LedgerTBackendAdapterDescriptorFixture.build_descriptor(
    metadata_snapshot: JSON.parse(JSON.generate(metadata_snapshot)),
    descriptor_snapshot: JSON.parse(JSON.generate(descriptor_snapshot)),
    schema_fingerprint: schema_fingerprint
  )
  check = LedgerTBackendAdapterDescriptorFixture.diagnostics(
    requirement: LedgerTBackendAdapterDescriptorFixture.requirement(schema_fingerprint: schema_fingerprint),
    descriptor: descriptor
  )

  missing_history_metadata = LedgerTBackendAdapterDescriptorFixture.sample_metadata_snapshot(include_history: false)
  missing_history_descriptor_snapshot = LedgerTBackendAdapterDescriptorFixture.sample_descriptor_snapshot(missing_history_metadata)
  missing_history_descriptor = LedgerTBackendAdapterDescriptorFixture.build_descriptor(
    metadata_snapshot: missing_history_metadata,
    descriptor_snapshot: missing_history_descriptor_snapshot,
    schema_fingerprint: schema_fingerprint
  )
  missing_history_check = LedgerTBackendAdapterDescriptorFixture.diagnostics(
    requirement: LedgerTBackendAdapterDescriptorFixture.requirement(schema_fingerprint: schema_fingerprint),
    descriptor: missing_history_descriptor
  )

  LedgerTBackendAdapterDescriptorFixture.assert("descriptor hash is stable") do
    descriptor.fetch("descriptor_hash") == duplicate.fetch("descriptor_hash")
  end
  LedgerTBackendAdapterDescriptorFixture.assert("full descriptor satisfies metadata-only requirement") do
    check.fetch("status") == "ok"
  end
  LedgerTBackendAdapterDescriptorFixture.assert("missing history blocks bihistory capability") do
    missing_history_check.fetch("status") == "blocked" &&
      missing_history_check.fetch("missing_hook_methods") == ["bihistory_at"] &&
      missing_history_check.fetch("missing_capabilities") == [TemporalRuntime::Capabilities::BIHISTORY_READ] &&
      missing_history_check.fetch("missing_axes") == ["transaction_time"]
  end
  LedgerTBackendAdapterDescriptorFixture.assert("fixture does not authorize runtime or ledger operations") do
    descriptor.fetch("non_authorization") == {
      "runtime_binding" => false,
      "ledger_reads" => false,
      "ledger_writes" => false,
      "ledger_replay" => false
    }
  end

  puts JSON.pretty_generate(
    "descriptor_hash" => descriptor.fetch("descriptor_hash"),
    "descriptor_registry_hash" => descriptor.fetch("descriptor_registry_hash"),
    "diagnostics_status" => check.fetch("status"),
    "missing_history_status" => missing_history_check.fetch("status")
  )
end
