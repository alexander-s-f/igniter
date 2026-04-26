#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "digest"
require "fileutils"
require "tmpdir"

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

Dir.mktmpdir("igniter-lense-poc") do |root|
  write_sample_project(root)
  before_signature = project_signature(root)

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
end
