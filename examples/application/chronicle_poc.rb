#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "digest"
require "fileutils"
require "stringio"
require "tmpdir"
require "uri"

require_relative "chronicle/app"

def file_signature(root)
  Dir.glob(File.join(root, "**", "*")).select { |path| File.file?(path) }.sort.to_h do |path|
    [path.delete_prefix("#{root}/"), Digest::SHA256.hexdigest(File.read(path))]
  end
end

def rack_env(method, path, body = "")
  path_info, query_string = path.split("?", 2)
  {
    "REQUEST_METHOD" => method,
    "PATH_INFO" => path_info,
    "QUERY_STRING" => query_string.to_s,
    "rack.input" => StringIO.new(body)
  }
end

def form_body(values)
  URI.encode_www_form(values)
end

Dir.mktmpdir("igniter-chronicle-poc") do |workdir|
  data_root = File.join(Chronicle::APP_ROOT, "data")
  before_signature = file_signature(data_root)

  if ARGV.first == "server"
    require "webrick"

    app = Chronicle.build(data_root: data_root, workdir: workdir)
    server = WEBrick::HTTPServer.new(Port: Integer(ENV.fetch("PORT", "9295")), AccessLog: [], Logger: WEBrick::Log.new(File::NULL))
    server.mount_proc("/") do |request, response|
      status, headers, body = app.call(
        "REQUEST_METHOD" => request.request_method,
        "PATH_INFO" => request.path,
        "QUERY_STRING" => request.query_string.to_s,
        "rack.input" => StringIO.new(request.body.to_s)
      )
      response.status = status
      headers.each { |key, value| response[key] = value }
      response.body = body.join
    end
    trap("INT") { server.shutdown }
    puts "chronicle_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
    server.start
    next
  end

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

  web_workdir = File.join(workdir, "web")
  web_app = Chronicle.build(data_root: data_root, workdir: web_workdir)
  initial_status, initial_headers, initial_body = web_app.call(rack_env("GET", "/"))
  missing_web_status, missing_web_headers, _missing_web_body = web_app.call(
    rack_env("POST", "/proposals/scan", form_body(proposal_id: "missing"))
  )
  missing_web_state_status, _missing_web_state_headers, missing_web_state_body = web_app.call(
    rack_env("GET", missing_web_headers.fetch("location"))
  )
  scan_web_status, scan_web_headers, _scan_web_body = web_app.call(
    rack_env("POST", "/proposals/scan", form_body(proposal_id: "PR-001"))
  )
  scanned_web_status, _scanned_web_headers, scanned_web_body = web_app.call(
    rack_env("GET", scan_web_headers.fetch("location"))
  )
  web_snapshot = web_app.service(:chronicle).snapshot
  web_session_id = web_snapshot.session_id
  web_conflict_id = web_snapshot.top_conflicts.first.fetch(:decision_id)
  receipt_not_ready_web_status, receipt_not_ready_web_headers, _receipt_not_ready_web_body = web_app.call(
    rack_env("POST", "/receipts", form_body(session_id: web_session_id))
  )
  receipt_not_ready_web_state_status, _receipt_not_ready_web_state_headers, receipt_not_ready_web_state_body = web_app.call(
    rack_env("GET", receipt_not_ready_web_headers.fetch("location"))
  )
  acknowledge_web_status, acknowledge_web_headers, _acknowledge_web_body = web_app.call(
    rack_env("POST", "/conflicts/acknowledge", form_body(session_id: web_session_id, decision_id: web_conflict_id))
  )
  acknowledged_web_status, _acknowledged_web_headers, acknowledged_web_body = web_app.call(
    rack_env("GET", acknowledge_web_headers.fetch("location"))
  )
  blank_signer_web_status, blank_signer_web_headers, _blank_signer_web_body = web_app.call(
    rack_env("POST", "/signoffs", form_body(session_id: web_session_id, signer: " "))
  )
  blank_signer_web_state_status, _blank_signer_web_state_headers, blank_signer_web_state_body = web_app.call(
    rack_env("GET", blank_signer_web_headers.fetch("location"))
  )
  signoff_web_status, signoff_web_headers, _signoff_web_body = web_app.call(
    rack_env("POST", "/signoffs", form_body(session_id: web_session_id, signer: "platform"))
  )
  signed_web_status, _signed_web_headers, signed_web_body = web_app.call(
    rack_env("GET", signoff_web_headers.fetch("location"))
  )
  blank_reason_web_status, blank_reason_web_headers, _blank_reason_web_body = web_app.call(
    rack_env("POST", "/signoffs/refuse", form_body(session_id: web_session_id, signer: "security", reason: " "))
  )
  blank_reason_web_state_status, _blank_reason_web_state_headers, blank_reason_web_state_body = web_app.call(
    rack_env("GET", blank_reason_web_headers.fetch("location"))
  )
  refusal_web_status, refusal_web_headers, _refusal_web_body = web_app.call(
    rack_env("POST", "/signoffs/refuse", form_body(session_id: web_session_id, signer: "security", reason: "Needs legal export proof."))
  )
  refused_web_status, _refused_web_headers, refused_web_body = web_app.call(
    rack_env("GET", refusal_web_headers.fetch("location"))
  )
  receipt_web_status, receipt_web_headers, _receipt_web_body = web_app.call(
    rack_env("POST", "/receipts", form_body(session_id: web_session_id))
  )
  final_web_status, _final_web_headers, final_web_body = web_app.call(
    rack_env("GET", receipt_web_headers.fetch("location"))
  )
  events_web_status, _events_web_headers, events_web_body = web_app.call(rack_env("GET", "/events"))
  receipt_endpoint_status, _receipt_endpoint_headers, receipt_endpoint_body = web_app.call(rack_env("GET", "/receipt"))
  initial_html = initial_body.join
  missing_web_html = missing_web_state_body.join
  scanned_web_html = scanned_web_body.join
  receipt_not_ready_web_html = receipt_not_ready_web_state_body.join
  acknowledged_web_html = acknowledged_web_body.join
  blank_signer_web_html = blank_signer_web_state_body.join
  signed_web_html = signed_web_body.join
  blank_reason_web_html = blank_reason_web_state_body.join
  refused_web_html = refused_web_body.join
  final_web_html = final_web_body.join
  events_web_text = events_web_body.join
  receipt_endpoint_text = receipt_endpoint_body.join
  final_web_snapshot = web_app.service(:chronicle).snapshot
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
  puts "chronicle_poc_web_initial_status=#{initial_status}"
  puts "chronicle_poc_web_content_type=#{initial_headers.fetch("content-type")}"
  puts "chronicle_poc_web_surface=#{initial_html.include?("data-ig-poc-surface=\"chronicle_decision_compass\"")}"
  puts "chronicle_poc_web_initial_proposal=#{initial_html.include?("data-proposal-id=\"none\"")}"
  puts "chronicle_poc_web_missing_status=#{missing_web_status}"
  puts "chronicle_poc_web_missing_location=#{missing_web_headers.fetch("location").include?("error=chronicle_unknown_proposal")}"
  puts "chronicle_poc_web_missing_feedback=#{missing_web_state_status == 200 && missing_web_html.include?("data-feedback-code=\"chronicle_unknown_proposal\"")}"
  puts "chronicle_poc_web_scan_status=#{scan_web_status}"
  puts "chronicle_poc_web_scan_location=#{scan_web_headers.fetch("location").include?("notice=chronicle_scan_created")}"
  puts "chronicle_poc_web_scanned_status=#{scanned_web_status}"
  puts "chronicle_poc_web_scan_feedback=#{scanned_web_html.include?("data-feedback-code=\"chronicle_scan_created\"")}"
  puts "chronicle_poc_web_session=#{scanned_web_html.include?("data-session-id=\"#{web_session_id}\"")}"
  puts "chronicle_poc_web_proposal=#{scanned_web_html.include?("data-proposal-id=\"PR-001\"") && scanned_web_html.include?("data-proposal-status=\"needs_review\"")}"
  puts "chronicle_poc_web_conflicts=#{scanned_web_html.include?("data-conflict-count=\"3\"") && scanned_web_html.include?("data-open-conflict-count=\"3\"")}"
  puts "chronicle_poc_web_top_conflict=#{scanned_web_html.include?("data-conflict-decision-id=\"#{web_conflict_id}\"")}"
  puts "chronicle_poc_web_evidence=#{scanned_web_html.include?("data-evidence-ref=\"")}"
  puts "chronicle_poc_web_related=#{scanned_web_html.include?("data-related-decision-id=\"DR-041\"") && scanned_web_html.include?("data-related-edge=\"PR-001-&gt;DR-041\"")}"
  puts "chronicle_poc_web_receipt_not_ready_status=#{receipt_not_ready_web_status}"
  puts "chronicle_poc_web_receipt_not_ready_location=#{receipt_not_ready_web_headers.fetch("location").include?("error=chronicle_receipt_not_ready")}"
  puts "chronicle_poc_web_receipt_not_ready_feedback=#{receipt_not_ready_web_state_status == 200 && receipt_not_ready_web_html.include?("data-feedback-code=\"chronicle_receipt_not_ready\"")}"
  puts "chronicle_poc_web_ack_status=#{acknowledge_web_status}"
  puts "chronicle_poc_web_ack_location=#{acknowledge_web_headers.fetch("location").include?("notice=chronicle_conflict_acknowledged")}"
  puts "chronicle_poc_web_ack_feedback=#{acknowledged_web_status == 200 && acknowledged_web_html.include?("data-feedback-code=\"chronicle_conflict_acknowledged\"")}"
  puts "chronicle_poc_web_ack_marker=#{acknowledged_web_html.include?("data-conflict-decision-id=\"#{web_conflict_id}\"") && acknowledged_web_html.include?("data-conflict-acknowledged=\"true\"")}"
  puts "chronicle_poc_web_blank_signer_status=#{blank_signer_web_status}"
  puts "chronicle_poc_web_blank_signer_location=#{blank_signer_web_headers.fetch("location").include?("error=chronicle_blank_signer")}"
  puts "chronicle_poc_web_blank_signer_feedback=#{blank_signer_web_state_status == 200 && blank_signer_web_html.include?("data-feedback-code=\"chronicle_blank_signer\"")}"
  puts "chronicle_poc_web_signoff_status=#{signoff_web_status}"
  puts "chronicle_poc_web_signoff_location=#{signoff_web_headers.fetch("location").include?("notice=chronicle_signoff_recorded")}"
  puts "chronicle_poc_web_signoff_feedback=#{signed_web_status == 200 && signed_web_html.include?("data-feedback-code=\"chronicle_signoff_recorded\"")}"
  puts "chronicle_poc_web_signed_marker=#{signed_web_html.include?("data-signed-by=\"platform\"")}"
  puts "chronicle_poc_web_blank_reason_status=#{blank_reason_web_status}"
  puts "chronicle_poc_web_blank_reason_location=#{blank_reason_web_headers.fetch("location").include?("error=chronicle_blank_reason")}"
  puts "chronicle_poc_web_blank_reason_feedback=#{blank_reason_web_state_status == 200 && blank_reason_web_html.include?("data-feedback-code=\"chronicle_blank_reason\"")}"
  puts "chronicle_poc_web_refusal_status=#{refusal_web_status}"
  puts "chronicle_poc_web_refusal_location=#{refusal_web_headers.fetch("location").include?("notice=chronicle_signoff_refused")}"
  puts "chronicle_poc_web_refusal_feedback=#{refused_web_status == 200 && refused_web_html.include?("data-feedback-code=\"chronicle_signoff_refused\"")}"
  puts "chronicle_poc_web_refused_marker=#{refused_web_html.include?("data-refused-by=\"security\"")}"
  puts "chronicle_poc_web_receipt_status=#{receipt_web_status}"
  puts "chronicle_poc_web_receipt_location=#{receipt_web_headers.fetch("location").include?("notice=chronicle_receipt_emitted")}"
  puts "chronicle_poc_web_final_status=#{final_web_status}"
  puts "chronicle_poc_web_receipt_feedback=#{final_web_html.include?("data-feedback-code=\"chronicle_receipt_emitted\"")}"
  puts "chronicle_poc_web_receipt_marker=#{final_web_html.include?("data-receipt-id=\"chronicle-receipt:chronicle-session-pr-001\"") && final_web_html.include?("data-receipt-valid=\"true\"")}"
  puts "chronicle_poc_web_activity=#{final_web_html.include?("data-ig-activity=\"recent\"") && final_web_html.include?("data-activity-kind=\"receipt_emitted\"")}"
  puts "chronicle_poc_web_events_status=#{events_web_status}"
  puts "chronicle_poc_web_events=#{events_web_text}"
  puts "chronicle_poc_web_events_parity=#{events_web_text.include?("proposal=#{final_web_snapshot.proposal_id}") && events_web_text.include?("session=#{final_web_snapshot.session_id}") && events_web_text.include?("status=#{final_web_snapshot.status}") && events_web_text.include?("conflicts=#{final_web_snapshot.conflict_count}") && events_web_text.include?("open=#{final_web_snapshot.open_conflict_count}") && events_web_text.include?("receipt=#{final_web_snapshot.receipt_id}")}"
  puts "chronicle_poc_web_receipt_endpoint_status=#{receipt_endpoint_status}"
  puts "chronicle_poc_web_receipt_endpoint=#{receipt_endpoint_text.include?("Chronicle Decision Receipt") && receipt_endpoint_text.include?("valid: true")}"
  puts "chronicle_poc_web_fixture_no_mutation=#{before_signature == after_signature}"
  puts "chronicle_poc_web_runtime_sessions=#{Dir.glob(File.join(web_workdir, "sessions", "*.json")).length}"
  puts "chronicle_poc_web_runtime_receipts=#{Dir.glob(File.join(web_workdir, "receipts", "*.md")).length}"
end
