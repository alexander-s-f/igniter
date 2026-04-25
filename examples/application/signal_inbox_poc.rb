#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "stringio"

require_relative "operator_signal_inbox/app"

app = OperatorSignalInbox.build

def rack_env(method, path, body = "")
  path_info, query_string = path.split("?", 2)
  {
    "REQUEST_METHOD" => method,
    "PATH_INFO" => path_info,
    "QUERY_STRING" => query_string.to_s,
    "rack.input" => StringIO.new(body)
  }
end

if ARGV.first == "server"
  require "webrick"

  server = WEBrick::HTTPServer.new(Port: Integer(ENV.fetch("PORT", "9293")), AccessLog: [], Logger: WEBrick::Log.new(File::NULL))
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
  puts "signal_inbox_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
  server.start
else
  initial_status, initial_headers, initial_body = app.call(rack_env("GET", "/"))
  blank_status, blank_headers, _blank_body = app.call(
    rack_env("POST", "/signals/escalate", "id=deploy-drift&note=++")
  )
  blank_state_status, _blank_state_headers, blank_state_body = app.call(
    rack_env("GET", blank_headers.fetch("location"))
  )
  missing_status, missing_headers, _missing_body = app.call(
    rack_env("POST", "/signals/acknowledge", "id=missing-signal")
  )
  acknowledge_status, acknowledge_headers, _acknowledge_body = app.call(
    rack_env("POST", "/signals/acknowledge", "id=cpu-spike")
  )
  acknowledged_status, _acknowledged_headers, acknowledged_body = app.call(
    rack_env("GET", acknowledge_headers.fetch("location"))
  )
  escalate_status, escalate_headers, _escalate_body = app.call(
    rack_env("POST", "/signals/escalate", "id=deploy-drift&note=Page+platform+owner")
  )
  escalated_status, _escalated_headers, escalated_body = app.call(
    rack_env("GET", escalate_headers.fetch("location"))
  )
  closed_status, closed_headers, _closed_body = app.call(
    rack_env("POST", "/signals/acknowledge", "id=deploy-drift")
  )
  final_status, _final_headers, final_body = app.call(rack_env("GET", closed_headers.fetch("location")))
  events_status, _events_headers, events_body = app.call(rack_env("GET", "/events"))
  initial_html = initial_body.join
  blank_state_html = blank_state_body.join
  acknowledged_html = acknowledged_body.join
  escalated_html = escalated_body.join
  final_html = final_body.join
  events_text = events_body.join

  puts "signal_inbox_poc_initial_status=#{initial_status}"
  puts "signal_inbox_poc_content_type=#{initial_headers.fetch("content-type")}"
  puts "signal_inbox_poc_initial_open=#{initial_html.include?("data-open-count=\"2\"")}"
  puts "signal_inbox_poc_initial_critical=#{initial_html.include?("data-critical-count=\"1\"")}"
  puts "signal_inbox_poc_surface=#{initial_html.include?("data-ig-poc-surface=\"operator_signal_inbox\"")}"
  puts "signal_inbox_poc_ack_form=#{initial_html.include?("data-action=\"acknowledge-signal\"")}"
  puts "signal_inbox_poc_escalate_form=#{initial_html.include?("data-action=\"escalate-signal\"")}"
  puts "signal_inbox_poc_blank_status=#{blank_status}"
  puts "signal_inbox_poc_blank_location=#{blank_headers.fetch("location").include?("error=blank_escalation_note")}"
  puts "signal_inbox_poc_blank_feedback=#{blank_state_status == 200 && blank_state_html.include?("data-feedback-code=\"blank_escalation_note\"")}"
  puts "signal_inbox_poc_missing_status=#{missing_status}"
  puts "signal_inbox_poc_missing_location=#{missing_headers.fetch("location").include?("error=signal_not_found")}"
  puts "signal_inbox_poc_ack_status=#{acknowledge_status}"
  puts "signal_inbox_poc_ack_location=#{acknowledge_headers.fetch("location").include?("notice=signal_acknowledged")}"
  puts "signal_inbox_poc_acknowledged_status=#{acknowledged_status}"
  puts "signal_inbox_poc_ack_feedback=#{acknowledged_html.include?("data-feedback-code=\"signal_acknowledged\"")}"
  puts "signal_inbox_poc_acknowledged_signal=#{acknowledged_html.include?("data-signal-id=\"cpu-spike\"") && acknowledged_html.include?("data-signal-status=\"acknowledged\"")}"
  puts "signal_inbox_poc_escalate_status=#{escalate_status}"
  puts "signal_inbox_poc_escalate_location=#{escalate_headers.fetch("location").include?("notice=signal_escalated")}"
  puts "signal_inbox_poc_escalated_status=#{escalated_status}"
  puts "signal_inbox_poc_escalate_feedback=#{escalated_html.include?("data-feedback-code=\"signal_escalated\"")}"
  puts "signal_inbox_poc_escalated_signal=#{escalated_html.include?("data-signal-id=\"deploy-drift\"") && escalated_html.include?("data-signal-status=\"escalated\"")}"
  puts "signal_inbox_poc_closed_status=#{closed_status}"
  puts "signal_inbox_poc_closed_location=#{closed_headers.fetch("location").include?("error=signal_closed")}"
  puts "signal_inbox_poc_final_status=#{final_status}"
  puts "signal_inbox_poc_final_open=#{final_html.include?("data-open-count=\"0\"")}"
  puts "signal_inbox_poc_final_critical=#{final_html.include?("data-critical-count=\"0\"")}"
  puts "signal_inbox_poc_closed_feedback=#{final_html.include?("data-feedback-code=\"signal_closed\"")}"
  puts "signal_inbox_poc_activity_surface=#{final_html.include?("data-ig-activity=\"recent\"")}"
  puts "signal_inbox_poc_activity_seeded=#{final_html.include?("data-activity-kind=\"signal_seeded\"")}"
  puts "signal_inbox_poc_activity_blank=#{final_html.include?("data-activity-kind=\"signal_escalate_refused\"")}"
  puts "signal_inbox_poc_activity_missing=#{final_html.include?("data-activity-kind=\"signal_acknowledge_refused\"")}"
  puts "signal_inbox_poc_activity_acknowledged=#{final_html.include?("data-activity-kind=\"signal_acknowledged\"")}"
  puts "signal_inbox_poc_activity_escalated=#{final_html.include?("data-activity-kind=\"signal_escalated\"")}"
  puts "signal_inbox_poc_acknowledged=#{app.service(:signal_inbox).acknowledged?("cpu-spike")}"
  puts "signal_inbox_poc_escalated=#{app.service(:signal_inbox).escalated?("deploy-drift")}"
  puts "signal_inbox_poc_events_status=#{events_status}"
  puts "signal_inbox_poc_events=#{events_text}"
  puts "signal_inbox_poc_events_actions=#{events_text.include?("actions=7")}"
  puts "signal_inbox_poc_events_seeded=#{events_text.include?("signal_seeded:deploy-drift:open")}"
  puts "signal_inbox_poc_events_blank=#{events_text.include?("signal_escalate_refused:deploy-drift:refused")}"
  puts "signal_inbox_poc_events_missing=#{events_text.include?("signal_acknowledge_refused:missing-signal:refused")}"
  puts "signal_inbox_poc_events_acknowledged=#{events_text.include?("signal_acknowledged:cpu-spike:acknowledged")}"
  puts "signal_inbox_poc_events_escalated=#{events_text.include?("signal_escalated:deploy-drift:escalated")}"
  puts "signal_inbox_poc_service=#{app.service(:signal_inbox).name}"
end
