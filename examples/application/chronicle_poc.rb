#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "digest"
require "fileutils"
require "tmpdir"

require_relative "chronicle/app"

def file_signature(root)
  Dir.glob(File.join(root, "**", "*")).select { |path| File.file?(path) }.sort.to_h do |path|
    [path.delete_prefix("#{root}/"), Digest::SHA256.hexdigest(File.read(path))]
  end
end

Dir.mktmpdir("igniter-chronicle-poc") do |workdir|
  data_root = File.join(Chronicle::APP_ROOT, "data")
  before_signature = file_signature(data_root)
  app = Chronicle::App.new(data_root: data_root, workdir: workdir)

  missing_result = app.scan_proposal(proposal_id: "missing")
  scan_result = app.scan_proposal(proposal_id: "PR-001")
  scanned_snapshot = app.snapshot
  receipt_not_ready = app.emit_receipt(session_id: scan_result.session_id, metadata: { source: :chronicle_poc })
  first_conflict = scanned_snapshot.top_conflicts.first
  acknowledge_result = app.acknowledge_conflict(
    session_id: scan_result.session_id,
    decision_id: first_conflict.fetch(:decision_id)
  )
  blank_signer_result = app.sign_off(session_id: scan_result.session_id, signer: " ")
  signoff_result = app.sign_off(session_id: scan_result.session_id, signer: "platform")
  blank_reason_result = app.refuse_signoff(session_id: scan_result.session_id, signer: "security", reason: " ")
  refusal_result = app.refuse_signoff(
    session_id: scan_result.session_id,
    signer: "security",
    reason: "Security needs legal export proof before approval."
  )
  receipt_result = app.emit_receipt(session_id: scan_result.session_id, metadata: { source: :chronicle_poc })
  final_snapshot = app.snapshot
  receipt_text = app.latest_receipt_text
  after_signature = file_signature(data_root)

  puts "chronicle_poc_missing_proposal=#{missing_result.feedback_code}"
  puts "chronicle_poc_scan=#{scan_result.feedback_code}"
  puts "chronicle_poc_session_id=#{scan_result.session_id.start_with?("chronicle-session-")}"
  puts "chronicle_poc_proposal=#{final_snapshot.proposal_id}"
  puts "chronicle_poc_conflicts=#{final_snapshot.conflict_count}"
  puts "chronicle_poc_open_conflicts=#{final_snapshot.open_conflict_count}"
  puts "chronicle_poc_top_conflict=#{first_conflict.fetch(:decision_id)}"
  puts "chronicle_poc_receipt_not_ready=#{receipt_not_ready.feedback_code}"
  puts "chronicle_poc_acknowledge=#{acknowledge_result.feedback_code}"
  puts "chronicle_poc_blank_signer=#{blank_signer_result.feedback_code}"
  puts "chronicle_poc_signoff=#{signoff_result.feedback_code}"
  puts "chronicle_poc_blank_reason=#{blank_reason_result.feedback_code}"
  puts "chronicle_poc_refusal=#{refusal_result.feedback_code}"
  puts "chronicle_poc_status=#{final_snapshot.status}"
  puts "chronicle_poc_signed=#{final_snapshot.signed_by.join(",")}"
  puts "chronicle_poc_refused=#{final_snapshot.refused_by.join(",")}"
  puts "chronicle_poc_receipt=#{receipt_result.feedback_code}"
  puts "chronicle_poc_receipt_id=#{final_snapshot.receipt_id}"
  puts "chronicle_poc_receipt_valid=#{receipt_text.include?("valid: true")}"
  puts "chronicle_poc_events=#{Chronicle.events_read_model(final_snapshot)}"
  puts "chronicle_poc_action_count=#{final_snapshot.action_count}"
  puts "chronicle_poc_recent_events=#{final_snapshot.recent_events.map { |event| event.fetch(:kind) }.join(",")}"
  puts "chronicle_poc_fixture_no_mutation=#{before_signature == after_signature}"
  puts "chronicle_poc_runtime_sessions=#{Dir.glob(File.join(workdir, "sessions", "*.json")).length}"
  puts "chronicle_poc_runtime_receipts=#{Dir.glob(File.join(workdir, "receipts", "*.md")).length}"
end
