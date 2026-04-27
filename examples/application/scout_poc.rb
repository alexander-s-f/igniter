#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "digest"
require "tmpdir"

require_relative "scout/app"

def file_signature(root)
  Dir.glob(File.join(root, "**", "*")).select { |path| File.file?(path) }.sort.to_h do |path|
    [path.delete_prefix("#{root}/"), Digest::SHA256.hexdigest(File.read(path))]
  end
end

Dir.mktmpdir("igniter-scout-poc") do |workdir|
  data_root = File.join(Scout::APP_ROOT, "data")
  before_signature = file_signature(data_root)
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
end
