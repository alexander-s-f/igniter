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

require_relative "scout/app"

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

Dir.mktmpdir("igniter-scout-poc") do |workdir|
  data_root = File.join(Scout::APP_ROOT, "data")
  before_signature = file_signature(data_root)

  if ARGV.first == "server"
    require "webrick"

    app = Scout.build(data_root: data_root, workdir: workdir)
    server = WEBrick::HTTPServer.new(
      BindAddress: "127.0.0.1",
      Port: Integer(ENV.fetch("PORT", "9296")),
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
    puts "scout_poc_url=http://127.0.0.1:#{server.config[:Port]}/"
    server.start
    next
  end

  app = Scout::App.new(data_root: data_root, workdir: workdir)

  blank_topic = app.start_session(topic: " ", source_ids: app.default_source_ids)
  no_sources = app.start_session(topic: app.default_topic, source_ids: [])
  unknown_source = app.start_session(topic: app.default_topic, source_ids: ["SRC-404"])
  start_result = app.start_session(topic: app.default_topic, source_ids: app.default_source_ids)
  extract_result = app.extract_findings(session_id: start_result.session_id)
  extracted_snapshot = app.snapshot
  receipt_not_ready = app.emit_receipt(session_id: start_result.session_id, metadata: { source: :scout_poc })
  invalid_checkpoint = app.choose_checkpoint(session_id: start_result.session_id, direction: "web-scale")
  add_source = app.add_local_source(session_id: start_result.session_id, source_id: "SRC-004")
  reextract_result = app.extract_findings(session_id: start_result.session_id)
  checkpoint_result = app.choose_checkpoint(session_id: start_result.session_id, direction: "balanced")
  receipt_result = app.emit_receipt(session_id: start_result.session_id, metadata: { source: :scout_poc })
  final_snapshot = app.snapshot
  receipt_text = app.latest_receipt_text

  web_workdir = File.join(workdir, "web")
  web_app = Scout.build(data_root: data_root, workdir: web_workdir)
  initial_status, initial_headers, initial_body = web_app.call(rack_env("GET", "/"))
  blank_web_status, blank_web_headers, _blank_web_body = web_app.call(
    rack_env("POST", "/sessions/start", form_body(topic: " ", source_ids: app.default_source_ids.join(",")))
  )
  blank_web_state_status, _blank_web_state_headers, blank_web_state_body = web_app.call(
    rack_env("GET", blank_web_headers.fetch("location"))
  )
  no_sources_web_status, no_sources_web_headers, _no_sources_web_body = web_app.call(
    rack_env("POST", "/sessions/start", form_body(topic: app.default_topic, source_ids: " "))
  )
  no_sources_web_state_status, _no_sources_web_state_headers, no_sources_web_state_body = web_app.call(
    rack_env("GET", no_sources_web_headers.fetch("location"))
  )
  unknown_source_web_status, unknown_source_web_headers, _unknown_source_web_body = web_app.call(
    rack_env("POST", "/sessions/start", form_body(topic: app.default_topic, source_ids: "SRC-404"))
  )
  unknown_source_web_state_status, _unknown_source_web_state_headers, unknown_source_web_state_body = web_app.call(
    rack_env("GET", unknown_source_web_headers.fetch("location"))
  )
  start_web_status, start_web_headers, _start_web_body = web_app.call(
    rack_env("POST", "/sessions/start", form_body(topic: app.default_topic, source_ids: app.default_source_ids.join(",")))
  )
  started_web_status, _started_web_headers, started_web_body = web_app.call(
    rack_env("GET", start_web_headers.fetch("location"))
  )
  web_session_id = web_app.service(:scout).snapshot.session_id
  extract_web_status, extract_web_headers, _extract_web_body = web_app.call(
    rack_env("POST", "/findings/extract", form_body(session_id: web_session_id))
  )
  extracted_web_status, _extracted_web_headers, extracted_web_body = web_app.call(
    rack_env("GET", extract_web_headers.fetch("location"))
  )
  receipt_not_ready_web_status, receipt_not_ready_web_headers, _receipt_not_ready_web_body = web_app.call(
    rack_env("POST", "/receipts", form_body(session_id: web_session_id))
  )
  receipt_not_ready_web_state_status, _receipt_not_ready_web_state_headers, receipt_not_ready_web_state_body = web_app.call(
    rack_env("GET", receipt_not_ready_web_headers.fetch("location"))
  )
  invalid_checkpoint_web_status, invalid_checkpoint_web_headers, _invalid_checkpoint_web_body = web_app.call(
    rack_env("POST", "/checkpoints", form_body(session_id: web_session_id, direction: "web-scale"))
  )
  invalid_checkpoint_web_state_status, _invalid_checkpoint_web_state_headers, invalid_checkpoint_web_state_body = web_app.call(
    rack_env("GET", invalid_checkpoint_web_headers.fetch("location"))
  )
  add_source_web_status, add_source_web_headers, _add_source_web_body = web_app.call(
    rack_env("POST", "/sources/add", form_body(session_id: web_session_id, source_id: "SRC-004"))
  )
  added_source_web_status, _added_source_web_headers, added_source_web_body = web_app.call(
    rack_env("GET", add_source_web_headers.fetch("location"))
  )
  reextract_web_status, reextract_web_headers, _reextract_web_body = web_app.call(
    rack_env("POST", "/findings/extract", form_body(session_id: web_session_id))
  )
  reextracted_web_status, _reextracted_web_headers, reextracted_web_body = web_app.call(
    rack_env("GET", reextract_web_headers.fetch("location"))
  )
  checkpoint_web_status, checkpoint_web_headers, _checkpoint_web_body = web_app.call(
    rack_env("POST", "/checkpoints", form_body(session_id: web_session_id, direction: "balanced"))
  )
  checkpointed_web_status, _checkpointed_web_headers, checkpointed_web_body = web_app.call(
    rack_env("GET", checkpoint_web_headers.fetch("location"))
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
  blank_web_html = blank_web_state_body.join
  no_sources_web_html = no_sources_web_state_body.join
  unknown_source_web_html = unknown_source_web_state_body.join
  started_web_html = started_web_body.join
  extracted_web_html = extracted_web_body.join
  receipt_not_ready_web_html = receipt_not_ready_web_state_body.join
  invalid_checkpoint_web_html = invalid_checkpoint_web_state_body.join
  added_source_web_html = added_source_web_body.join
  reextracted_web_html = reextracted_web_body.join
  checkpointed_web_html = checkpointed_web_body.join
  final_web_html = final_web_body.join
  events_web_text = events_web_body.join
  receipt_endpoint_text = receipt_endpoint_body.join
  final_web_snapshot = web_app.service(:scout).snapshot
  after_signature = file_signature(data_root)

  puts "scout_poc_blank_topic=#{blank_topic.feedback_code}"
  puts "scout_poc_no_sources=#{no_sources.feedback_code}"
  puts "scout_poc_unknown_source=#{unknown_source.feedback_code}"
  puts "scout_poc_start=#{start_result.feedback_code}"
  puts "scout_poc_session_id=#{start_result.session_id.start_with?("scout-session-")}"
  puts "scout_poc_topic=#{final_snapshot.topic}"
  puts "scout_poc_sources=#{final_snapshot.source_count}"
  puts "scout_poc_extract=#{extract_result.feedback_code}"
  puts "scout_poc_findings_initial=#{extracted_snapshot.finding_count}"
  puts "scout_poc_contradictions_initial=#{extracted_snapshot.contradiction_count}"
  puts "scout_poc_receipt_not_ready=#{receipt_not_ready.feedback_code}"
  puts "scout_poc_invalid_checkpoint=#{invalid_checkpoint.feedback_code}"
  puts "scout_poc_add_source=#{add_source.feedback_code}"
  puts "scout_poc_reextract=#{reextract_result.feedback_code}"
  puts "scout_poc_checkpoint=#{checkpoint_result.feedback_code}"
  puts "scout_poc_checkpoint_choice=#{final_snapshot.checkpoint_choice}"
  puts "scout_poc_status=#{final_snapshot.status}"
  puts "scout_poc_findings=#{final_snapshot.finding_count}"
  puts "scout_poc_contradictions=#{final_snapshot.contradiction_count}"
  puts "scout_poc_top_finding=#{final_snapshot.top_findings.first.fetch(:id)}"
  puts "scout_poc_top_source=#{final_snapshot.top_findings.first.fetch(:source_refs).first.fetch(:citation_id)}"
  puts "scout_poc_receipt=#{receipt_result.feedback_code}"
  puts "scout_poc_receipt_id=#{final_snapshot.receipt_id}"
  puts "scout_poc_receipt_valid=#{receipt_text.include?("valid: true")}"
  puts "scout_poc_receipt_citation=#{receipt_text.include?("SRC-001#p1")}"
  puts "scout_poc_events=#{Scout.events_read_model(final_snapshot)}"
  puts "scout_poc_action_count=#{final_snapshot.action_count}"
  puts "scout_poc_recent_events=#{final_snapshot.recent_events.map { |event| event.fetch(:kind) }.join(",")}"
  puts "scout_poc_fixture_no_mutation=#{before_signature == after_signature}"
  puts "scout_poc_runtime_sessions=#{Dir.glob(File.join(workdir, "sessions", "*.json")).length}"
  puts "scout_poc_runtime_receipts=#{Dir.glob(File.join(workdir, "receipts", "*.md")).length}"
  puts "scout_poc_web_initial_status=#{initial_status}"
  puts "scout_poc_web_content_type=#{initial_headers.fetch("content-type")}"
  puts "scout_poc_web_surface=#{initial_html.include?("data-ig-poc-surface=\"scout_research_workspace\"")}"
  puts "scout_poc_web_initial_session=#{initial_html.include?("data-session-id=\"none\"")}"
  puts "scout_poc_web_blank_status=#{blank_web_status}"
  puts "scout_poc_web_blank_location=#{blank_web_headers.fetch("location").include?("error=scout_blank_topic")}"
  puts "scout_poc_web_blank_feedback=#{blank_web_state_status == 200 && blank_web_html.include?("data-feedback-code=\"scout_blank_topic\"")}"
  puts "scout_poc_web_no_sources_status=#{no_sources_web_status}"
  puts "scout_poc_web_no_sources_location=#{no_sources_web_headers.fetch("location").include?("error=scout_no_sources")}"
  puts "scout_poc_web_no_sources_feedback=#{no_sources_web_state_status == 200 && no_sources_web_html.include?("data-feedback-code=\"scout_no_sources\"")}"
  puts "scout_poc_web_unknown_source_status=#{unknown_source_web_status}"
  puts "scout_poc_web_unknown_source_location=#{unknown_source_web_headers.fetch("location").include?("error=scout_unknown_source")}"
  puts "scout_poc_web_unknown_source_feedback=#{unknown_source_web_state_status == 200 && unknown_source_web_html.include?("data-feedback-code=\"scout_unknown_source\"")}"
  puts "scout_poc_web_start_status=#{start_web_status}"
  puts "scout_poc_web_start_location=#{start_web_headers.fetch("location").include?("notice=scout_session_started")}"
  puts "scout_poc_web_started_status=#{started_web_status}"
  puts "scout_poc_web_started_feedback=#{started_web_html.include?("data-feedback-code=\"scout_session_started\"")}"
  puts "scout_poc_web_session=#{started_web_html.include?("data-session-id=\"#{web_session_id}\"") && started_web_html.include?("data-research-status=\"open\"")}"
  puts "scout_poc_web_topic=#{started_web_html.include?("data-topic=\"#{app.default_topic}\"")}"
  puts "scout_poc_web_sources=#{started_web_html.include?("data-source-count=\"3\"") && started_web_html.include?("data-source-id=\"SRC-001\"") && started_web_html.include?("data-source-type=\"internal_note\"")}"
  puts "scout_poc_web_extract_status=#{extract_web_status}"
  puts "scout_poc_web_extract_location=#{extract_web_headers.fetch("location").include?("notice=scout_findings_extracted")}"
  puts "scout_poc_web_extracted_status=#{extracted_web_status}"
  puts "scout_poc_web_extract_feedback=#{extracted_web_html.include?("data-feedback-code=\"scout_findings_extracted\"")}"
  puts "scout_poc_web_findings=#{extracted_web_html.include?("data-finding-count=\"6\"") && extracted_web_html.include?("data-finding-id=\"finding-1\"")}"
  puts "scout_poc_web_provenance=#{extracted_web_html.include?("data-citation-id=\"SRC-001#p1\"") && extracted_web_html.include?("data-citation-anchor=\"p1\"") && extracted_web_html.include?("data-provenance-path=\"")}"
  puts "scout_poc_web_contradiction=#{extracted_web_html.include?("data-contradiction-id=\"tension-governance-vs-velocity\"") && extracted_web_html.include?("data-contradiction-direction=\"governance\"")}"
  puts "scout_poc_web_receipt_not_ready_status=#{receipt_not_ready_web_status}"
  puts "scout_poc_web_receipt_not_ready_location=#{receipt_not_ready_web_headers.fetch("location").include?("error=scout_receipt_not_ready")}"
  puts "scout_poc_web_receipt_not_ready_feedback=#{receipt_not_ready_web_state_status == 200 && receipt_not_ready_web_html.include?("data-feedback-code=\"scout_receipt_not_ready\"")}"
  puts "scout_poc_web_invalid_checkpoint_status=#{invalid_checkpoint_web_status}"
  puts "scout_poc_web_invalid_checkpoint_location=#{invalid_checkpoint_web_headers.fetch("location").include?("error=scout_invalid_checkpoint")}"
  puts "scout_poc_web_invalid_checkpoint_feedback=#{invalid_checkpoint_web_state_status == 200 && invalid_checkpoint_web_html.include?("data-feedback-code=\"scout_invalid_checkpoint\"")}"
  puts "scout_poc_web_add_source_status=#{add_source_web_status}"
  puts "scout_poc_web_add_source_location=#{add_source_web_headers.fetch("location").include?("notice=scout_local_source_added")}"
  puts "scout_poc_web_add_source_feedback=#{added_source_web_status == 200 && added_source_web_html.include?("data-feedback-code=\"scout_local_source_added\"")}"
  puts "scout_poc_web_added_source=#{added_source_web_html.include?("data-source-id=\"SRC-004\"")}"
  puts "scout_poc_web_reextract_status=#{reextract_web_status}"
  puts "scout_poc_web_reextract_location=#{reextract_web_headers.fetch("location").include?("notice=scout_findings_extracted")}"
  puts "scout_poc_web_reextracted_status=#{reextracted_web_status}"
  puts "scout_poc_web_reextracted_findings=#{reextracted_web_html.include?("data-finding-count=\"8\"") && reextracted_web_html.include?("data-source-id=\"SRC-004\"")}"
  puts "scout_poc_web_checkpoint_status=#{checkpoint_web_status}"
  puts "scout_poc_web_checkpoint_location=#{checkpoint_web_headers.fetch("location").include?("notice=scout_checkpoint_chosen")}"
  puts "scout_poc_web_checkpoint_feedback=#{checkpointed_web_status == 200 && checkpointed_web_html.include?("data-feedback-code=\"scout_checkpoint_chosen\"")}"
  puts "scout_poc_web_checkpoint_marker=#{checkpointed_web_html.include?("data-checkpoint-choice=\"balanced\"")}"
  puts "scout_poc_web_receipt_status=#{receipt_web_status}"
  puts "scout_poc_web_receipt_location=#{receipt_web_headers.fetch("location").include?("notice=scout_receipt_emitted")}"
  puts "scout_poc_web_final_status=#{final_web_status}"
  puts "scout_poc_web_receipt_feedback=#{final_web_html.include?("data-feedback-code=\"scout_receipt_emitted\"")}"
  puts "scout_poc_web_receipt_marker=#{final_web_html.include?("data-receipt-id=\"scout-receipt:#{web_session_id}\"") && final_web_html.include?("data-receipt-valid=\"true\"")}"
  puts "scout_poc_web_activity=#{final_web_html.include?("data-ig-activity=\"recent\"") && final_web_html.include?("data-activity-kind=\"receipt_emitted\"")}"
  puts "scout_poc_web_events_status=#{events_web_status}"
  puts "scout_poc_web_events=#{events_web_text}"
  puts "scout_poc_web_events_parity=#{events_web_text.include?("topic=#{final_web_snapshot.topic}") && events_web_text.include?("session=#{final_web_snapshot.session_id}") && events_web_text.include?("status=#{final_web_snapshot.status}") && events_web_text.include?("sources=#{final_web_snapshot.source_count}") && events_web_text.include?("findings=#{final_web_snapshot.finding_count}") && events_web_text.include?("contradictions=#{final_web_snapshot.contradiction_count}") && events_web_text.include?("checkpoint=#{final_web_snapshot.checkpoint_choice}") && events_web_text.include?("receipt=#{final_web_snapshot.receipt_id}")}"
  puts "scout_poc_web_receipt_endpoint_status=#{receipt_endpoint_status}"
  puts "scout_poc_web_receipt_endpoint=#{receipt_endpoint_text.include?("Scout Research Receipt") && receipt_endpoint_text.include?("valid: true") && receipt_endpoint_text.include?("SRC-001#p1")}"
  puts "scout_poc_web_fixture_no_mutation=#{before_signature == after_signature}"
  puts "scout_poc_web_runtime_sessions=#{Dir.glob(File.join(web_workdir, "sessions", "*.json")).length}"
  puts "scout_poc_web_runtime_receipts=#{Dir.glob(File.join(web_workdir, "receipts", "*.md")).length}"
end
