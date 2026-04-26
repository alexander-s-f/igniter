# frozen_string_literal: true

require "uri"

require "igniter/web"

module Lense
  module Web
    STYLES = {
      shell: "max-width: 980px; margin: 36px auto; padding: 30px; font-family: ui-sans-serif, system-ui; background: #f4efe3; border: 1px solid #252018; box-shadow: 12px 12px 0 #252018;",
      header: "display: flex; justify-content: space-between; gap: 20px; align-items: flex-start;",
      eyebrow: "margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.16em; font-size: 12px;",
      title: "margin: 0; font-size: 46px; line-height: 1;",
      subtitle: "margin: 12px 0 0; max-width: 620px;",
      score: "min-width: 132px; padding: 16px; color: #f4efe3; background: #252018; text-align: center;",
      score_value: "display: block; font-size: 38px;",
      stats: "display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin: 24px 0;",
      stat: "padding: 14px; border: 1px solid #252018; background: #fffaf0;",
      stat_value: "display: block; font-size: 26px; font-weight: 800;",
      actions: "display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin: 16px 0;",
      button: "padding: 10px 14px; border: 1px solid #252018; background: #f2b84b; cursor: pointer;",
      input: "width: min(100%, 340px); padding: 10px; border: 1px solid #252018;",
      feedback: "margin: 18px 0; padding: 12px 14px; border: 1px solid #252018; font-weight: 700;",
      feedback_notice: " background: #d9edc2;",
      feedback_error: " background: #ffd4c9;",
      grid: "display: grid; grid-template-columns: minmax(0, 1.1fr) minmax(0, 0.9fr); gap: 18px;",
      panel: "padding: 18px; background: #fffdf7; border: 1px solid #252018;",
      panel_title: "margin: 0 0 12px; font-size: 22px;",
      finding: "margin-top: 12px; padding: 14px; background: #fff6d8; border: 1px solid #252018;",
      finding_title: "margin: 0 0 8px;",
      finding_meta: "margin: 6px 0;",
      evidence: "display: inline-block; margin: 6px 8px 0 0; padding: 4px 8px; background: #252018; color: #fffaf0; font-size: 12px;",
      session_step: "margin-top: 10px; padding: 12px; background: #f7ead0; border: 1px solid #252018;",
      activity_list: "margin: 0; padding-left: 20px;",
      activity_item: "margin-top: 8px;",
      activity_meta: "font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em;",
      report: "margin-top: 18px; padding: 18px; color: #fffaf0; background: #252018;",
      footer: "margin-top: 22px; font-size: 13px;"
    }.freeze

    def self.style(name)
      STYLES.fetch(name)
    end

    def self.feedback_for(env)
      params = URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).to_h
      return notice_feedback(params) if params.key?("notice")
      return error_feedback(params) if params.key?("error")

      nil
    end

    def self.notice_feedback(params)
      case params.fetch("notice")
      when "scan_refreshed"
        feedback(:notice, "Scan refreshed.", "scan_refreshed")
      when "session_started"
        feedback(:notice, "Guided session started.", "session_started")
      when "step_marked_done"
        feedback(:notice, "Step marked done.", "step_marked_done")
      when "step_skipped"
        feedback(:notice, "Step skipped.", "step_skipped")
      when "note_added"
        feedback(:notice, "Note added.", "note_added")
      end
    end

    def self.error_feedback(params)
      case params.fetch("error")
      when "finding_not_found"
        feedback(:error, "Finding not found.", "finding_not_found")
      when "session_not_found"
        feedback(:error, "Session not found.", "session_not_found")
      when "invalid_step_action"
        feedback(:error, "Step action is invalid.", "invalid_step_action")
      when "blank_note"
        feedback(:error, "Note cannot be blank.", "blank_note")
      end
    end

    def self.feedback(kind, message, code)
      {
        kind: kind,
        message: message,
        code: code
      }.freeze
    end

    def self.feedback_style(feedback)
      "#{style(:feedback)}#{style(:"feedback_#{feedback.fetch(:kind)}")}"
    end

    def self.finding_label(finding)
      finding.fetch(:type).to_s.tr("_", " ")
    end

    def self.active_step(session)
      return nil unless session

      session.fetch(:steps).find { |step| step.fetch(:status) == :open } || session.fetch(:steps).first
    end

    def self.activity_label(event)
      event.fetch(:kind).to_s.tr("_", " ")
    end

    def self.activity_session_id(event)
      event.fetch(:session_id) || "-"
    end

    def self.lense_dashboard_mount
      application = Igniter::Web.application do
        root title: "Lense codebase workbench" do
          app = assigns[:ctx].service(:lense).call
          snapshot = app.snapshot
          feedback = Lense::Web.feedback_for(assigns[:env])
          receipt = app.receipt(metadata: { source: :lense_web }).to_h
          active_session = snapshot.active_session
          active_step = Lense::Web.active_step(active_session)

          main class: "lense-dashboard",
               "data-ig-poc-surface": "lense_dashboard",
               "data-scan-id": snapshot.scan_id,
               "data-health-score": snapshot.health_score,
               "data-ruby-file-count": snapshot.ruby_file_count,
               "data-line-count": snapshot.line_count,
               "data-finding-count": snapshot.finding_count,
               "data-report-id": receipt.fetch(:receipt_id),
               "data-report-valid": receipt.fetch(:valid),
               style: Lense::Web.style(:shell) do
            header style: Lense::Web.style(:header) do
              div do
                para "Igniter showcase POC", style: Lense::Web.style(:eyebrow)
                h1 "Lense workbench", style: Lense::Web.style(:title)
                para "A deterministic local codebase scan with guided issue sessions and a receipt-shaped report.",
                     style: Lense::Web.style(:subtitle)
              end

              aside class: "health-score",
                    "data-health-score": snapshot.health_score,
                    style: Lense::Web.style(:score) do
                strong snapshot.health_score.to_s, style: Lense::Web.style(:score_value)
                span "health score"
              end
            end

            section class: "stats", style: Lense::Web.style(:stats) do
              div "data-ruby-file-count": snapshot.ruby_file_count, style: Lense::Web.style(:stat) do
                strong snapshot.ruby_file_count.to_s, style: Lense::Web.style(:stat_value)
                span "Ruby files"
              end
              div "data-line-count": snapshot.line_count, style: Lense::Web.style(:stat) do
                strong snapshot.line_count.to_s, style: Lense::Web.style(:stat_value)
                span "lines"
              end
              div "data-finding-count": snapshot.finding_count, style: Lense::Web.style(:stat) do
                strong snapshot.finding_count.to_s, style: Lense::Web.style(:stat_value)
                span "findings"
              end
            end

            div style: Lense::Web.style(:actions) do
              form action: "/scan", method: "post" do
                button "Refresh scan",
                       type: "submit",
                       "data-action": "refresh-scan",
                       style: Lense::Web.style(:button)
              end
            end

            if feedback
              section class: "feedback #{feedback.fetch(:kind)}",
                      "data-ig-feedback": feedback.fetch(:kind),
                      "data-feedback-code": feedback.fetch(:code),
                      style: Lense::Web.feedback_style(feedback) do
                para feedback.fetch(:message), style: "margin: 0;"
              end
            end

            div style: Lense::Web.style(:grid) do
              section class: "findings", style: Lense::Web.style(:panel) do
                h2 "Top findings", style: Lense::Web.style(:panel_title)
                snapshot.top_findings.each do |finding|
                  article class: "finding",
                          "data-finding-id": finding.fetch(:id),
                          style: Lense::Web.style(:finding) do
                    h3 "#{Lense::Web.finding_label(finding)}: #{finding.fetch(:subject)}",
                       style: Lense::Web.style(:finding_title)
                    para finding.fetch(:summary), style: Lense::Web.style(:finding_meta)
                    para "Severity signal: #{finding.fetch(:severity_score)}",
                         style: Lense::Web.style(:finding_meta)
                    finding.fetch(:evidence_refs).each do |ref|
                      span ref, "data-evidence-ref": ref, style: Lense::Web.style(:evidence)
                    end
                    form action: "/sessions/start", method: "post", style: Lense::Web.style(:actions) do
                      input type: "hidden", name: "finding_id", value: finding.fetch(:id)
                      button "Start guided session",
                             type: "submit",
                             "data-action": "start-session",
                             style: Lense::Web.style(:button)
                    end
                  end
                end
              end

              section class: "session", style: Lense::Web.style(:panel) do
                h2 "Guided session", style: Lense::Web.style(:panel_title)
                if active_session
                  article "data-session-id": active_session.fetch(:id),
                          "data-session-state": active_session.fetch(:status),
                          "data-session-step": active_step&.fetch(:id),
                          style: Lense::Web.style(:session_step) do
                    h3 "Session #{active_session.fetch(:id)}", style: Lense::Web.style(:finding_title)
                    para "Finding: #{active_session.fetch(:finding_id)}", style: Lense::Web.style(:finding_meta)
                    para "Current step: #{active_step&.fetch(:title) || "complete"}",
                         style: Lense::Web.style(:finding_meta)

                    form action: "/sessions/#{active_session.fetch(:id)}/steps",
                         method: "post",
                         style: Lense::Web.style(:actions) do
                      input type: "hidden", name: "step_id", value: active_step&.fetch(:id)
                      button "Mark done",
                             type: "submit",
                             name: "action",
                             value: "done",
                             "data-action": "mark-step-done",
                             style: Lense::Web.style(:button)
                      button "Skip",
                             type: "submit",
                             name: "action",
                             value: "skip",
                             "data-action": "skip-step",
                             style: Lense::Web.style(:button)
                    end

                    form action: "/sessions/#{active_session.fetch(:id)}/steps",
                         method: "post",
                         style: Lense::Web.style(:actions) do
                      input name: "note",
                            type: "text",
                            placeholder: "Operator note",
                            required: true,
                            style: Lense::Web.style(:input)
                      button "Add note",
                             type: "submit",
                             name: "action",
                             value: "note",
                             "data-action": "add-note",
                             style: Lense::Web.style(:button)
                    end
                  end
                else
                  para "Start a guided session from a finding to see step controls.",
                       "data-session-state": "none",
                       style: Lense::Web.style(:finding_meta)
                end
              end
            end

            section class: "recent-activity",
                    "data-ig-activity": "recent",
                    "data-activity-count": snapshot.recent_events.length,
                    style: Lense::Web.style(:panel) do
              h2 "Recent activity", style: Lense::Web.style(:panel_title)
              ol style: Lense::Web.style(:activity_list) do
                snapshot.recent_events.each do |event|
                  session_id = Lense::Web.activity_session_id(event)
                  li "data-activity-index": event.fetch(:index),
                     "data-activity-kind": event.fetch(:kind),
                     "data-activity-session-id": session_id,
                     "data-activity-status": event.fetch(:status),
                     style: Lense::Web.style(:activity_item) do
                    span "#{Lense::Web.activity_label(event)}: #{session_id}",
                         style: Lense::Web.style(:activity_meta)
                  end
                end
              end
            end

            section class: "report",
                    "data-report-id": receipt.fetch(:receipt_id),
                    "data-report-valid": receipt.fetch(:valid),
                    style: Lense::Web.style(:report) do
              h2 "Receipt report", style: "margin: 0 0 10px;"
              para "Kind: #{receipt.fetch(:kind)}", style: "margin: 0 0 6px;"
              para "Evidence refs: #{receipt.fetch(:evidence_refs).length}", style: "margin: 0 0 6px;"
              para "Skipped/deferred: #{receipt.fetch(:skipped).length}", style: "margin: 0;"
            end

            footer style: Lense::Web.style(:footer) do
              para "Read endpoint: GET /events -> scan=#{snapshot.scan_id} findings=#{snapshot.finding_count}",
                   style: "margin: 0;"
            end
          end
        end
      end

      Igniter::Web.mount(:lense_dashboard, path: "/", application: application)
    end
  end
end
