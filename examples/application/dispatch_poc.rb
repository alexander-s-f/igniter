#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "digest"
require "stringio"
require "tmpdir"
require "uri"

require_relative "dispatch/app"

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

Dir.mktmpdir("igniter-dispatch-poc") do |workdir|
  data_root = File.join(Dispatch::APP_ROOT, "data")
  before_signature = file_signature(data_root)

  if ARGV.first == "server"
    require "webrick"

    app = Dispatch.build(data_root: data_root, workdir: workdir)
    server = WEBrick::HTTPServer.new(
      BindAddress: "127.0.0.1",
      Port: Integer(ENV.fetch("PORT", "9297")),
      AccessLog: [],
      Logger: WEBrick::Log.new(File::NULL)
    )
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
    puts "dispatch_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
    server.start
    next
  end

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

  web_workdir = File.join(workdir, "web")
  web_app = Dispatch.build(data_root: data_root, workdir: web_workdir)
  initial_status, initial_headers, initial_body = web_app.call(rack_env("GET", "/"))
  unknown_incident_web_status, unknown_incident_web_headers, _unknown_incident_web_body = web_app.call(
    rack_env("POST", "/incidents/open", form_body(incident_id: "INC-404"))
  )
  unknown_incident_web_state_status, _unknown_incident_web_state_headers, unknown_incident_web_state_body = web_app.call(
    rack_env("GET", unknown_incident_web_headers.fetch("location"))
  )
  open_web_status, open_web_headers, _open_web_body = web_app.call(
    rack_env("POST", "/incidents/open", form_body(incident_id: app.default_incident_id))
  )
  opened_web_status, _opened_web_headers, opened_web_body = web_app.call(
    rack_env("GET", open_web_headers.fetch("location"))
  )
  web_session_id = web_app.service(:dispatch).snapshot.session_id
  receipt_not_ready_web_status, receipt_not_ready_web_headers, _receipt_not_ready_web_body = web_app.call(
    rack_env("POST", "/receipts", form_body(session_id: web_session_id))
  )
  receipt_not_ready_web_state_status, _receipt_not_ready_web_state_headers, receipt_not_ready_web_state_body = web_app.call(
    rack_env("GET", receipt_not_ready_web_headers.fetch("location"))
  )
  triage_web_status, triage_web_headers, _triage_web_body = web_app.call(
    rack_env("POST", "/incidents/triage", form_body(session_id: web_session_id))
  )
  triaged_web_status, _triaged_web_headers, triaged_web_body = web_app.call(
    rack_env("GET", triage_web_headers.fetch("location"))
  )
  unknown_team_web_status, unknown_team_web_headers, _unknown_team_web_body = web_app.call(
    rack_env("POST", "/assignments", form_body(session_id: web_session_id, team: "frontend-oncall"))
  )
  unknown_team_web_state_status, _unknown_team_web_state_headers, unknown_team_web_state_body = web_app.call(
    rack_env("GET", unknown_team_web_headers.fetch("location"))
  )
  blank_escalation_web_status, blank_escalation_web_headers, _blank_escalation_web_body = web_app.call(
    rack_env("POST", "/escalations", form_body(session_id: web_session_id, team: "database-oncall", reason: " "))
  )
  blank_escalation_web_state_status, _blank_escalation_web_state_headers, blank_escalation_web_state_body = web_app.call(
    rack_env("GET", blank_escalation_web_headers.fetch("location"))
  )
  assignment_web_status, assignment_web_headers, _assignment_web_body = web_app.call(
    rack_env("POST", "/assignments", form_body(session_id: web_session_id, team: "payments-platform"))
  )
  assigned_web_status, _assigned_web_headers, assigned_web_body = web_app.call(
    rack_env("GET", assignment_web_headers.fetch("location"))
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
  unknown_incident_web_html = unknown_incident_web_state_body.join
  opened_web_html = opened_web_body.join
  receipt_not_ready_web_html = receipt_not_ready_web_state_body.join
  triaged_web_html = triaged_web_body.join
  unknown_team_web_html = unknown_team_web_state_body.join
  blank_escalation_web_html = blank_escalation_web_state_body.join
  assigned_web_html = assigned_web_body.join
  final_web_html = final_web_body.join
  events_web_text = events_web_body.join
  receipt_endpoint_text = receipt_endpoint_body.join
  final_web_snapshot = web_app.service(:dispatch).snapshot
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
  puts "dispatch_poc_web_initial_status=#{initial_status}"
  puts "dispatch_poc_web_content_type=#{initial_headers.fetch("content-type")}"
  puts "dispatch_poc_web_surface=#{initial_html.include?("data-ig-poc-surface=\"dispatch_command_center\"")}"
  puts "dispatch_poc_web_initial_incident=#{initial_html.include?("data-incident-id=\"none\"")}"
  puts "dispatch_poc_web_unknown_incident_status=#{unknown_incident_web_status}"
  puts "dispatch_poc_web_unknown_incident_location=#{unknown_incident_web_headers.fetch("location").include?("error=dispatch_unknown_incident")}"
  puts "dispatch_poc_web_unknown_incident_feedback=#{unknown_incident_web_state_status == 200 && unknown_incident_web_html.include?("data-feedback-code=\"dispatch_unknown_incident\"")}"
  puts "dispatch_poc_web_open_status=#{open_web_status}"
  puts "dispatch_poc_web_open_location=#{open_web_headers.fetch("location").include?("notice=dispatch_incident_opened")}"
  puts "dispatch_poc_web_opened_status=#{opened_web_status}"
  puts "dispatch_poc_web_open_feedback=#{opened_web_html.include?("data-feedback-code=\"dispatch_incident_opened\"")}"
  puts "dispatch_poc_web_incident=#{opened_web_html.include?("data-incident-id=\"INC-001\"")}"
  puts "dispatch_poc_web_service=#{opened_web_html.include?("data-service=\"payments-api\"")}"
  puts "dispatch_poc_web_receipt_not_ready_status=#{receipt_not_ready_web_status}"
  puts "dispatch_poc_web_receipt_not_ready_location=#{receipt_not_ready_web_headers.fetch("location").include?("error=dispatch_receipt_not_ready")}"
  puts "dispatch_poc_web_receipt_not_ready_feedback=#{receipt_not_ready_web_state_status == 200 && receipt_not_ready_web_html.include?("data-feedback-code=\"dispatch_receipt_not_ready\"")}"
  puts "dispatch_poc_web_triage_status=#{triage_web_status}"
  puts "dispatch_poc_web_triage_location=#{triage_web_headers.fetch("location").include?("notice=dispatch_triage_completed")}"
  puts "dispatch_poc_web_triaged_status=#{triaged_web_status}"
  puts "dispatch_poc_web_triage_feedback=#{triaged_web_html.include?("data-feedback-code=\"dispatch_triage_completed\"")}"
  puts "dispatch_poc_web_severity=#{triaged_web_html.include?("data-severity=\"critical\"")}"
  puts "dispatch_poc_web_cause=#{triaged_web_html.include?("data-suspected-cause=\"migration\"")}"
  puts "dispatch_poc_web_events=#{triaged_web_html.include?("data-event-count=\"4\"")}"
  puts "dispatch_poc_web_event_marker=#{triaged_web_html.include?("data-event-id=\"EVT-001\"")}"
  puts "dispatch_poc_web_citation=#{triaged_web_html.include?("data-event-citation=\"metrics#checkout_error_rate\"")}"
  puts "dispatch_poc_web_route=#{triaged_web_html.include?("data-route-team=\"payments-platform\"")}"
  puts "dispatch_poc_web_unknown_team_status=#{unknown_team_web_status}"
  puts "dispatch_poc_web_unknown_team_location=#{unknown_team_web_headers.fetch("location").include?("error=dispatch_unknown_team")}"
  puts "dispatch_poc_web_unknown_team_feedback=#{unknown_team_web_state_status == 200 && unknown_team_web_html.include?("data-feedback-code=\"dispatch_unknown_team\"")}"
  puts "dispatch_poc_web_blank_escalation_status=#{blank_escalation_web_status}"
  puts "dispatch_poc_web_blank_escalation_location=#{blank_escalation_web_headers.fetch("location").include?("error=dispatch_blank_escalation_reason")}"
  puts "dispatch_poc_web_blank_escalation_feedback=#{blank_escalation_web_state_status == 200 && blank_escalation_web_html.include?("data-feedback-code=\"dispatch_blank_escalation_reason\"")}"
  puts "dispatch_poc_web_assignment_status=#{assignment_web_status}"
  puts "dispatch_poc_web_assignment_location=#{assignment_web_headers.fetch("location").include?("notice=dispatch_owner_assigned")}"
  puts "dispatch_poc_web_assigned_status=#{assigned_web_status}"
  puts "dispatch_poc_web_assignment_feedback=#{assigned_web_html.include?("data-feedback-code=\"dispatch_owner_assigned\"")}"
  puts "dispatch_poc_web_assigned_team=#{assigned_web_html.include?("data-assigned-team=\"payments-platform\"")}"
  puts "dispatch_poc_web_handoff_ready=#{assigned_web_html.include?("data-handoff-ready=\"true\"")}"
  puts "dispatch_poc_web_receipt_status=#{receipt_web_status}"
  puts "dispatch_poc_web_receipt_location=#{receipt_web_headers.fetch("location").include?("notice=dispatch_receipt_emitted")}"
  puts "dispatch_poc_web_final_status=#{final_web_status}"
  puts "dispatch_poc_web_receipt_feedback=#{final_web_html.include?("data-feedback-code=\"dispatch_receipt_emitted\"")}"
  puts "dispatch_poc_web_receipt_marker=#{final_web_html.include?("data-receipt-id=\"dispatch-receipt:dispatch-session-inc-001\"")}"
  puts "dispatch_poc_web_receipt_valid=#{final_web_html.include?("data-receipt-valid=\"true\"")}"
  puts "dispatch_poc_web_activity=#{final_web_html.include?("data-ig-activity=\"recent\"") && final_web_html.include?("data-activity-kind=\"receipt_emitted\"")}"
  puts "dispatch_poc_web_events_status=#{events_web_status}"
  puts "dispatch_poc_web_events=#{events_web_text}"
  puts "dispatch_poc_web_events_parity=#{events_web_text.include?("incident=#{final_web_snapshot.incident_id}") && events_web_text.include?("assigned=#{final_web_snapshot.assigned_team}") && events_web_text.include?("receipt=#{final_web_snapshot.receipt_id}")}"
  puts "dispatch_poc_web_receipt_endpoint_status=#{receipt_endpoint_status}"
  puts "dispatch_poc_web_receipt_endpoint=#{receipt_endpoint_text.include?("Dispatch Incident Receipt") && receipt_endpoint_text.include?("valid: true") && receipt_endpoint_text.include?("metrics#checkout_error_rate")}"
  puts "dispatch_poc_web_fixture_no_mutation=#{before_signature == after_signature}"
  puts "dispatch_poc_web_runtime_sessions=#{Dir.glob(File.join(web_workdir, "sessions", "*.json")).length}"
  puts "dispatch_poc_web_runtime_receipts=#{Dir.glob(File.join(web_workdir, "receipts", "*.md")).length}"
end
