#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "digest"
require "tmpdir"

require_relative "dispatch/app"

def file_signature(root)
  Dir.glob(File.join(root, "**", "*")).select { |path| File.file?(path) }.sort.to_h do |path|
    [path.delete_prefix("#{root}/"), Digest::SHA256.hexdigest(File.read(path))]
  end
end

Dir.mktmpdir("igniter-dispatch-poc") do |workdir|
  data_root = File.join(Dispatch::APP_ROOT, "data")
  before_signature = file_signature(data_root)
  app = Dispatch::App.new(data_root: data_root, workdir: workdir)

  unknown_incident = app.open_incident(incident_id: "INC-404")
  open_result = app.open_incident(incident_id: app.default_incident_id)
  receipt_not_ready = app.emit_receipt(session_id: open_result.session_id, metadata: { source: :dispatch_poc })
  triage_result = app.triage_incident(session_id: open_result.session_id)
  triaged_snapshot = app.snapshot
  unknown_team = app.assign_owner(session_id: open_result.session_id, team: "frontend-oncall")
  blank_escalation = app.escalate_incident(session_id: open_result.session_id, team: "database-oncall", reason: " ")
  assignment_result = app.assign_owner(session_id: open_result.session_id, team: "payments-platform")
  assigned_snapshot = app.snapshot
  receipt_result = app.emit_receipt(session_id: open_result.session_id, metadata: { source: :dispatch_poc })
  final_snapshot = app.snapshot
  receipt_text = app.latest_receipt_text
  after_signature = file_signature(data_root)

  puts "dispatch_poc_unknown_incident=#{unknown_incident.feedback_code}"
  puts "dispatch_poc_open=#{open_result.feedback_code}"
  puts "dispatch_poc_session_id=#{open_result.session_id.start_with?("dispatch-session-")}"
  puts "dispatch_poc_incident=#{final_snapshot.incident_id}"
  puts "dispatch_poc_title=#{final_snapshot.title}"
  puts "dispatch_poc_receipt_not_ready=#{receipt_not_ready.feedback_code}"
  puts "dispatch_poc_triage=#{triage_result.feedback_code}"
  puts "dispatch_poc_severity=#{triaged_snapshot.severity}"
  puts "dispatch_poc_cause=#{triaged_snapshot.suspected_cause}"
  puts "dispatch_poc_events=#{triaged_snapshot.event_count}"
  puts "dispatch_poc_routes=#{triaged_snapshot.route_options.map { |route| route.fetch(:team) }.join(",")}"
  puts "dispatch_poc_unknown_team=#{unknown_team.feedback_code}"
  puts "dispatch_poc_blank_escalation=#{blank_escalation.feedback_code}"
  puts "dispatch_poc_assignment=#{assignment_result.feedback_code}"
  puts "dispatch_poc_assigned_team=#{assigned_snapshot.assigned_team}"
  puts "dispatch_poc_handoff_ready=#{assigned_snapshot.handoff_ready}"
  puts "dispatch_poc_status=#{final_snapshot.status}"
  puts "dispatch_poc_receipt=#{receipt_result.feedback_code}"
  puts "dispatch_poc_receipt_id=#{final_snapshot.receipt_id}"
  puts "dispatch_poc_receipt_valid=#{receipt_text.include?("valid: true")}"
  puts "dispatch_poc_receipt_citation=#{receipt_text.include?("metrics#checkout_error_rate")}"
  puts "dispatch_poc_receipt_deferred=#{receipt_text.include?("no_remediation_execution")}"
  puts "dispatch_poc_events_read=#{Dispatch.events_read_model(final_snapshot)}"
  puts "dispatch_poc_action_count=#{final_snapshot.action_count}"
  puts "dispatch_poc_recent_events=#{final_snapshot.recent_events.map { |event| event.fetch(:kind) }.join(",")}"
  puts "dispatch_poc_fixture_no_mutation=#{before_signature == after_signature}"
  puts "dispatch_poc_runtime_sessions=#{Dir.glob(File.join(workdir, "sessions", "*.json")).length}"
  puts "dispatch_poc_runtime_receipts=#{Dir.glob(File.join(workdir, "receipts", "*.md")).length}"
end
