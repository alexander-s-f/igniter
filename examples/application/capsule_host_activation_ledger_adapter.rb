#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "tmpdir"

require "igniter/application"

def activation_evidence_packet(dry_run:, readiness:, digest:, adapter:)
  {
    packet_id: "activation-packet-1",
    schema_version: "activation-ledger-v1",
    transfer_receipt_id: "transfer-receipt-1",
    activation_readiness_id: "activation-readiness-1",
    activation_plan_id: "activation-plan-1",
    activation_plan_verification_id: "activation-plan-verification-1",
    activation_dry_run_id: "activation-dry-run-1",
    commit_readiness_id: "activation-commit-readiness-1",
    operation_digest: digest,
    commit_decision: true,
    idempotency_key: "activation-key-1",
    caller_metadata: { source: :example },
    receipt_sink: "activation-ledger",
    application_host_adapter: adapter.to_h,
    dry_run: dry_run,
    commit_readiness: readiness
  }
end

Dir.mktmpdir("igniter-capsule-host-ledger") do |root|
  adapter = Igniter::Application.file_backed_host_activation_ledger_adapter(root: root)
  dry_run = {
    dry_run: true,
    committed: false,
    executable: true,
    would_apply: [
      { type: :confirm_load_path, status: :dry_run, destination: "operator" },
      { type: :confirm_provider, status: :dry_run, destination: :incident_runtime },
      { type: :confirm_contract, status: :dry_run, destination: "Contracts::ResolveIncident" },
      { type: :confirm_lifecycle, status: :dry_run, destination: :boot }
    ],
    skipped: [
      { type: :confirm_host_export, status: :skipped, reason: :host_owned_evidence },
      { type: :review_mount_intent, status: :skipped, reason: :web_or_host_owned_mount }
    ],
    refusals: [],
    warnings: [],
    surface_count: 1
  }
  readiness = Igniter::Application.host_activation_commit_readiness(
    dry_run,
    provided_adapters: [
      adapter.to_h,
      { name: :host_evidence_acknowledgement, kind: :host_evidence },
      { name: :web_mount_adapter_evidence, kind: :web_or_host_mount_evidence }
    ]
  ).to_h
  digest = Igniter::Application.host_activation_operation_digest(dry_run)
  packet = activation_evidence_packet(dry_run: dry_run, readiness: readiness, digest: digest, adapter: adapter)

  result = Igniter::Application.host_activation_ledger_commit(packet, adapter: adapter).to_h
  verification = Igniter::Application.verify_host_activation_ledger(
    packet,
    commit_result: result,
    adapter: adapter
  ).to_h
  receipt = Igniter::Application.host_activation_receipt(
    verification,
    evidence_packet: packet,
    commit_result: result,
    metadata: { source: :example }
  ).to_h
  duplicate = Igniter::Application.host_activation_ledger_commit(packet, adapter: adapter).to_h
  changed_dry_run = dry_run.merge(
    would_apply: [
      { type: :confirm_lifecycle, status: :dry_run, destination: :shutdown }
    ]
  )
  conflict = Igniter::Application.host_activation_ledger_commit(
    activation_evidence_packet(
      dry_run: changed_dry_run,
      readiness: readiness,
      digest: Igniter::Application.host_activation_operation_digest(changed_dry_run),
      adapter: adapter
    ),
    adapter: adapter
  ).to_h
  readback = adapter.readback(idempotency_key: "activation-key-1", operation_digest: digest)
  ledger_files = Dir.glob(File.join(root, "activation-ledger", "*.json"))

  puts "application_capsule_host_activation_ledger_committed=#{result.fetch(:committed)}"
  puts "application_capsule_host_activation_ledger_applied=#{result.fetch(:applied_operations).length}"
  puts "application_capsule_host_activation_ledger_skipped=#{result.fetch(:skipped_operations).length}"
  puts "application_capsule_host_activation_ledger_refusals=#{result.fetch(:refusals).length}"
  puts "application_capsule_host_activation_ledger_receipts=#{result.fetch(:adapter_receipts).length}"
  puts "application_capsule_host_activation_ledger_files=#{ledger_files.length}"
  puts "application_capsule_host_activation_ledger_duplicate=#{duplicate.fetch(:committed)}"
  puts "application_capsule_host_activation_ledger_readback=#{readback.length}"
  puts "application_capsule_host_activation_ledger_conflict_committed=#{conflict.fetch(:committed)}"
  puts "application_capsule_host_activation_ledger_conflict_refusal=#{conflict.fetch(:refusals).any?}"
  puts "application_capsule_host_activation_ledger_digest=#{digest.length == 64}"
  puts "application_capsule_host_activation_ledger_adapter=#{adapter.to_h.fetch(:name)}"
  puts "application_capsule_host_activation_ledger_verify_valid=#{verification.fetch(:valid)}"
  puts "application_capsule_host_activation_ledger_verify_complete=#{verification.fetch(:complete)}"
  puts "application_capsule_host_activation_ledger_verify_findings=#{verification.fetch(:findings).length}"
  puts "application_capsule_host_activation_ledger_verify_verified=#{verification.fetch(:verified_operations).length}"
  puts "application_capsule_host_activation_receipt_complete=#{receipt.fetch(:complete)}"
  puts "application_capsule_host_activation_receipt_valid=#{receipt.fetch(:valid)}"
  puts "application_capsule_host_activation_receipt_committed=#{receipt.fetch(:committed)}"
  puts "application_capsule_host_activation_receipt_refs=#{receipt.fetch(:adapter_receipt_refs).length}"
  puts "application_capsule_host_activation_receipt_host_leftovers=#{receipt.fetch(:host_leftovers).length}"
  puts "application_capsule_host_activation_receipt_web_leftovers=#{receipt.fetch(:web_leftovers).length}"
  puts "application_capsule_host_activation_receipt_separate=#{receipt.fetch(:audit_metadata).fetch(:separate_from_transfer_receipt)}"
end
