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

require_relative "lense/app"

def write_sample_project(root)
  FileUtils.mkdir_p(File.join(root, "app/services"))
  FileUtils.mkdir_p(File.join(root, "app/models"))
  File.write(File.join(root, "app/services/payment_processor.rb"), <<~RUBY)
    class PaymentProcessor
      def call(order)
        validate(order)
        fraud_score = order.fetch(:amount) > 100 ? 10 : 1
        fraud_score = order.fetch(:amount) > 100 ? 10 : 1
        if fraud_score > 5
          notify("manual review")
        elsif order.fetch(:currency) == "EUR"
          convert(order)
        else
          persist(order)
        end
        emit_event(order)
      rescue KeyError
        false
      end

      def validate(order)
        order.fetch(:amount)
      end

      def convert(order)
        order.fetch(:amount) * 1.1
      end

      def persist(order)
        order
      end

      def emit_event(order)
        order
      end

      def notify(message)
        message
      end
    end
  RUBY
  File.write(File.join(root, "app/models/user_profile.rb"), <<~RUBY)
    class UserProfile
      def display_name(user)
        # TODO: collapse duplicated formatting with account presenter
        first = user.fetch(:first_name)
        last = user.fetch(:last_name)
        "\#{first} \#{last}"
      end

      def audit_label(user)
        fraud_score = user.fetch(:amount) > 100 ? 10 : 1
        "\#{user.fetch(:id)}:\#{display_name(user)}"
      end
    end
  RUBY
end

def project_signature(root)
  Dir.glob(File.join(root, "**", "*.rb")).sort.to_h do |path|
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

Dir.mktmpdir("igniter-lense-poc") do |root|
  write_sample_project(root)
  before_signature = project_signature(root)

  if ARGV.first == "server"
    require "webrick"

    app = Lense.build(target_root: root, project_label: "sample_shop")
    server = WEBrick::HTTPServer.new(Port: Integer(ENV.fetch("PORT", "9294")), AccessLog: [], Logger: WEBrick::Log.new(File::NULL))
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
    puts "lense_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
    server.start
    next
  end

  app = Lense::App.new(target_root: root, project_label: "sample_shop")
  analysis = app.refresh_scan
  snapshot = app.snapshot
  top_finding = snapshot.top_findings.first
  session_result = app.start_session(top_finding.fetch(:id))
  done_result = app.record_step(
    session_result.session_id,
    action: "done",
    step_id: "inspect_evidence"
  )
  note_result = app.record_step(
    session_result.session_id,
    action: "note",
    note: "Extract a focused payment review helper before editing code."
  )
  skip_result = app.record_step(
    session_result.session_id,
    action: "skip",
    step_id: "plan_change"
  )
  blank_note = app.record_step(session_result.session_id, action: "note", note: " ")
  missing_result = app.start_session("missing:finding")
  final_snapshot = app.snapshot
  receipt = app.receipt(metadata: { source: :lense_poc }).to_h

  web_app = Lense.build(target_root: root, project_label: "sample_shop")
  initial_status, initial_headers, initial_body = web_app.call(rack_env("GET", "/"))
  refresh_status, refresh_headers, _refresh_body = web_app.call(rack_env("POST", "/scan"))
  refreshed_status, _refreshed_headers, refreshed_body = web_app.call(rack_env("GET", refresh_headers.fetch("location")))
  web_top_finding = web_app.service(:lense).snapshot.top_findings.first
  missing_web_status, missing_web_headers, _missing_web_body = web_app.call(
    rack_env("POST", "/sessions/start", form_body(finding_id: "missing:finding"))
  )
  missing_web_state_status, _missing_web_state_headers, missing_web_state_body = web_app.call(
    rack_env("GET", missing_web_headers.fetch("location"))
  )
  start_status, start_headers, _start_body = web_app.call(
    rack_env("POST", "/sessions/start", form_body(finding_id: web_top_finding.fetch(:id)))
  )
  started_status, _started_headers, started_body = web_app.call(rack_env("GET", start_headers.fetch("location")))
  web_session_id = web_app.service(:lense).snapshot.active_session.fetch(:id)
  blank_web_status, blank_web_headers, _blank_web_body = web_app.call(
    rack_env("POST", "/sessions/#{web_session_id}/steps", form_body(action: "note", note: " "))
  )
  blank_web_state_status, _blank_web_state_headers, blank_web_state_body = web_app.call(
    rack_env("GET", blank_web_headers.fetch("location"))
  )
  invalid_status, invalid_headers, _invalid_body = web_app.call(
    rack_env("POST", "/sessions/#{web_session_id}/steps", form_body(action: "dance"))
  )
  invalid_state_status, _invalid_state_headers, invalid_state_body = web_app.call(
    rack_env("GET", invalid_headers.fetch("location"))
  )
  done_status, done_headers, _done_body = web_app.call(
    rack_env("POST", "/sessions/#{web_session_id}/steps", form_body(action: "done", step_id: "inspect_evidence"))
  )
  done_state_status, _done_state_headers, done_state_body = web_app.call(rack_env("GET", done_headers.fetch("location")))
  note_status, note_headers, _note_body = web_app.call(
    rack_env("POST", "/sessions/#{web_session_id}/steps", form_body(action: "note", note: "Queue a small extraction PR."))
  )
  noted_status, _noted_headers, noted_body = web_app.call(rack_env("GET", note_headers.fetch("location")))
  skip_status, skip_headers, _skip_body = web_app.call(
    rack_env("POST", "/sessions/#{web_session_id}/steps", form_body(action: "skip", step_id: "plan_change"))
  )
  final_web_status, _final_web_headers, final_web_body = web_app.call(rack_env("GET", skip_headers.fetch("location")))
  events_status, _events_headers, events_body = web_app.call(rack_env("GET", "/events"))
  report_status, _report_headers, report_body = web_app.call(rack_env("GET", "/report"))
  initial_html = initial_body.join
  refreshed_html = refreshed_body.join
  missing_web_html = missing_web_state_body.join
  started_html = started_body.join
  blank_web_html = blank_web_state_body.join
  invalid_html = invalid_state_body.join
  done_html = done_state_body.join
  noted_html = noted_body.join
  final_web_html = final_web_body.join
  events_text = events_body.join
  report_text = report_body.join
  after_signature = project_signature(root)

  puts "lense_poc_scan_id=#{analysis.fetch(:scan).fetch(:scan_id).start_with?("lense-scan:")}"
  puts "lense_poc_project=#{final_snapshot.project_label}"
  puts "lense_poc_ruby_files=#{final_snapshot.ruby_file_count}"
  puts "lense_poc_line_count=#{final_snapshot.line_count}"
  puts "lense_poc_health_score=#{final_snapshot.health_score}"
  puts "lense_poc_findings=#{final_snapshot.finding_count}"
  puts "lense_poc_top_finding=#{top_finding.fetch(:type)}"
  puts "lense_poc_top_evidence=#{top_finding.fetch(:evidence_refs).first}"
  puts "lense_poc_session_started=#{session_result.feedback_code}"
  puts "lense_poc_session_id=#{session_result.session_id.start_with?("session-")}"
  puts "lense_poc_step_done=#{done_result.feedback_code}"
  puts "lense_poc_note_added=#{note_result.feedback_code}"
  puts "lense_poc_step_skipped=#{skip_result.feedback_code}"
  puts "lense_poc_blank_note=#{blank_note.feedback_code}"
  puts "lense_poc_missing_finding=#{missing_result.feedback_code}"
  puts "lense_poc_actions=#{final_snapshot.action_count}"
  puts "lense_poc_recent_events=#{final_snapshot.recent_events.map { |event| event.fetch(:kind) }.join(",")}"
  puts "lense_poc_receipt_valid=#{receipt.fetch(:valid)}"
  puts "lense_poc_receipt_kind=#{receipt.fetch(:kind)}"
  puts "lense_poc_receipt_refs=#{receipt.fetch(:evidence_refs).length}"
  puts "lense_poc_receipt_skipped=#{receipt.fetch(:skipped).length}"
  puts "lense_poc_no_mutation=#{before_signature == after_signature}"
  puts "lense_poc_service=#{app.sessions.name}"
  puts "lense_poc_web_initial_status=#{initial_status}"
  puts "lense_poc_web_content_type=#{initial_headers.fetch("content-type")}"
  puts "lense_poc_web_surface=#{initial_html.include?("data-ig-poc-surface=\"lense_dashboard\"")}"
  puts "lense_poc_web_scan_marker=#{initial_html.include?("data-scan-id=\"lense-scan:")}"
  puts "lense_poc_web_counts=#{initial_html.include?("data-ruby-file-count=\"2\"") && initial_html.include?("data-line-count=\"50\"")}"
  puts "lense_poc_web_findings=#{initial_html.include?("data-finding-count=\"3\"") && initial_html.include?("data-finding-id=\"#{web_top_finding.fetch(:id)}\"")}"
  puts "lense_poc_web_evidence=#{initial_html.include?("data-evidence-ref=\"file:app/services/payment_processor.rb\"")}"
  puts "lense_poc_web_report_marker=#{initial_html.include?("data-report-valid=\"true\"") && initial_html.include?("data-report-id=\"lense-receipt:lense-scan:")}"
  puts "lense_poc_web_refresh_status=#{refresh_status}"
  puts "lense_poc_web_refresh_location=#{refresh_headers.fetch("location").include?("notice=scan_refreshed")}"
  puts "lense_poc_web_refresh_feedback=#{refreshed_status == 200 && refreshed_html.include?("data-feedback-code=\"scan_refreshed\"")}"
  puts "lense_poc_web_missing_status=#{missing_web_status}"
  puts "lense_poc_web_missing_location=#{missing_web_headers.fetch("location").include?("error=finding_not_found")}"
  puts "lense_poc_web_missing_feedback=#{missing_web_state_status == 200 && missing_web_html.include?("data-feedback-code=\"finding_not_found\"")}"
  puts "lense_poc_web_start_status=#{start_status}"
  puts "lense_poc_web_start_location=#{start_headers.fetch("location").include?("notice=session_started")}"
  puts "lense_poc_web_started_status=#{started_status}"
  puts "lense_poc_web_started_feedback=#{started_html.include?("data-feedback-code=\"session_started\"")}"
  puts "lense_poc_web_session=#{started_html.include?("data-session-id=\"#{web_session_id}\"") && started_html.include?("data-session-state=\"open\"")}"
  puts "lense_poc_web_session_step=#{started_html.include?("data-session-step=\"inspect_evidence\"")}"
  puts "lense_poc_web_blank_status=#{blank_web_status}"
  puts "lense_poc_web_blank_location=#{blank_web_headers.fetch("location").include?("error=blank_note")}"
  puts "lense_poc_web_blank_feedback=#{blank_web_state_status == 200 && blank_web_html.include?("data-feedback-code=\"blank_note\"")}"
  puts "lense_poc_web_invalid_status=#{invalid_status}"
  puts "lense_poc_web_invalid_location=#{invalid_headers.fetch("location").include?("error=invalid_step_action")}"
  puts "lense_poc_web_invalid_feedback=#{invalid_state_status == 200 && invalid_html.include?("data-feedback-code=\"invalid_step_action\"")}"
  puts "lense_poc_web_done_status=#{done_status}"
  puts "lense_poc_web_done_location=#{done_headers.fetch("location").include?("notice=step_marked_done")}"
  puts "lense_poc_web_done_feedback=#{done_state_status == 200 && done_html.include?("data-feedback-code=\"step_marked_done\"")}"
  puts "lense_poc_web_note_status=#{note_status}"
  puts "lense_poc_web_note_location=#{note_headers.fetch("location").include?("notice=note_added")}"
  puts "lense_poc_web_note_feedback=#{noted_status == 200 && noted_html.include?("data-feedback-code=\"note_added\"")}"
  puts "lense_poc_web_skip_status=#{skip_status}"
  puts "lense_poc_web_skip_location=#{skip_headers.fetch("location").include?("notice=step_skipped")}"
  puts "lense_poc_web_final_status=#{final_web_status}"
  puts "lense_poc_web_skip_feedback=#{final_web_html.include?("data-feedback-code=\"step_skipped\"")}"
  puts "lense_poc_web_activity=#{final_web_html.include?("data-ig-activity=\"recent\"") && final_web_html.include?("data-activity-kind=\"note_added\"")}"
  puts "lense_poc_web_events_status=#{events_status}"
  puts "lense_poc_web_events=#{events_text}"
  puts "lense_poc_web_events_scan=#{events_text.include?(web_app.service(:lense).snapshot.scan_id)}"
  puts "lense_poc_web_events_findings=#{events_text.include?("findings=3")}"
  puts "lense_poc_web_events_session=#{events_text.include?("session=open")}"
  puts "lense_poc_web_events_actions=#{events_text.include?("actions=9")}"
  puts "lense_poc_web_events_parity=#{events_text.include?(web_app.service(:lense).snapshot.scan_id) && events_text.include?("findings=3") && events_text.include?("session=open") && events_text.include?("actions=9")}"
  puts "lense_poc_web_report_status=#{report_status}"
  puts "lense_poc_web_report_valid=#{report_text.include?(":valid=>true")}"
  puts "lense_poc_web_report_endpoint=#{report_status == 200 && report_text.include?(":valid=>true")}"
end
