# frozen_string_literal: true

require "uri"

require "igniter/web"

module Dispatch
  module Web
    STYLES = {
      shell: "max-width: 1120px; margin: 34px auto; padding: 30px; font-family: ui-sans-serif, system-ui; background: #f7efe2; border: 1px solid #251b12; box-shadow: 12px 12px 0 #251b12;",
      header: "display: flex; flex-wrap: wrap; justify-content: space-between; gap: 20px; align-items: flex-start;",
      eyebrow: "margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.16em; font-size: 12px;",
      title: "margin: 0; font-size: 44px; line-height: 1;",
      subtitle: "margin: 12px 0 0; max-width: 720px;",
      status: "min-width: 180px; padding: 16px; color: #f7efe2; background: #251b12; text-align: center;",
      status_value: "display: block; font-size: 22px; font-weight: 800;",
      stats: "display: grid; grid-template-columns: repeat(auto-fit, minmax(145px, 1fr)); gap: 12px; margin: 24px 0;",
      stat: "padding: 14px; border: 1px solid #251b12; background: #fffaf0;",
      stat_value: "display: block; font-size: 24px; font-weight: 800;",
      panel: "padding: 18px; background: #fffaf0; border: 1px solid #251b12;",
      panel_title: "margin: 0 0 12px; font-size: 22px;",
      grid: "display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 18px;",
      actions: "display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin: 14px 0 0;",
      input: "width: min(100%, 300px); padding: 10px; border: 1px solid #251b12;",
      button: "padding: 10px 14px; border: 1px solid #251b12; background: #f4a261; cursor: pointer;",
      feedback: "margin: 18px 0; padding: 12px 14px; border: 1px solid #251b12; font-weight: 700;",
      feedback_notice: " background: #cdeac0;",
      feedback_error: " background: #ffd3c2;",
      event: "margin-top: 12px; padding: 14px; background: #e6f2ff; border: 1px solid #251b12;",
      route: "margin-top: 12px; padding: 14px; background: #fcefb4; border: 1px solid #251b12;",
      receipt: "margin-top: 18px; padding: 18px; color: #fffaf0; background: #251b12;",
      meta: "margin: 6px 0;",
      tag: "display: inline-block; margin: 6px 8px 0 0; padding: 4px 8px; background: #251b12; color: #fffaf0; font-size: 12px;",
      nested: "margin: 8px 0 0; padding-left: 20px;",
      activity_list: "margin: 0; padding-left: 20px;",
      activity_item: "margin-top: 8px;",
      activity_meta: "font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em;",
      inspection: "display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px;",
      inspection_link: "color: #251b12; font-weight: 800;",
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
      when "dispatch_incident_opened"
        feedback(:notice, "Incident command session opened.", "dispatch_incident_opened")
      when "dispatch_triage_completed"
        feedback(:notice, "Deterministic triage and routing evidence completed.", "dispatch_triage_completed")
      when "dispatch_owner_assigned"
        feedback(:notice, "Owner assignment checkpoint recorded.", "dispatch_owner_assigned")
      when "dispatch_incident_escalated"
        feedback(:notice, "Escalation checkpoint recorded.", "dispatch_incident_escalated")
      when "dispatch_receipt_emitted"
        feedback(:notice, "Incident handoff receipt emitted.", "dispatch_receipt_emitted")
      end
    end

    def self.error_feedback(params)
      case params.fetch("error")
      when "dispatch_unknown_incident"
        feedback(:error, "Incident fixture was not found.", "dispatch_unknown_incident")
      when "dispatch_unknown_session"
        feedback(:error, "Incident command session was not found.", "dispatch_unknown_session")
      when "dispatch_triage_not_ready"
        feedback(:error, "Run triage before recording a checkpoint.", "dispatch_triage_not_ready")
      when "dispatch_unknown_team"
        feedback(:error, "Team fixture was not found.", "dispatch_unknown_team")
      when "dispatch_invalid_assignment"
        feedback(:error, "Selected team is not a valid routing option.", "dispatch_invalid_assignment")
      when "dispatch_blank_escalation_reason"
        feedback(:error, "Escalation requires a reason.", "dispatch_blank_escalation_reason")
      when "dispatch_receipt_not_ready"
        feedback(:error, "Receipt is not ready until triage and a checkpoint are complete.", "dispatch_receipt_not_ready")
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

    def self.activity_label(event)
      event.fetch(:kind).to_s.tr("_", " ")
    end

    def self.activity_incident_id(event)
      event.fetch(:incident_id) || "-"
    end

    def self.selected_team(snapshot)
      snapshot.assigned_team || snapshot.escalated_team || "none"
    end

    def self.command_center_mount
      application = Igniter::Web.application do
        root title: "Dispatch command center" do
          app = assigns[:ctx].service(:dispatch).call
          snapshot = app.snapshot
          feedback = Dispatch::Web.feedback_for(assigns[:env])
          selected_team = Dispatch::Web.selected_team(snapshot)
          receipt_valid = !snapshot.receipt_id.to_s.empty?

          main class: "dispatch-command-center",
               "data-ig-poc-surface": "dispatch_command_center",
               "data-session-id": snapshot.session_id || "none",
               "data-incident-id": snapshot.incident_id || "none",
               "data-incident-status": snapshot.status,
               "data-service": snapshot.service || "none",
               "data-severity": snapshot.severity,
               "data-suspected-cause": snapshot.suspected_cause,
               "data-event-count": snapshot.event_count,
               "data-assigned-team": snapshot.assigned_team || "none",
               "data-escalated-team": snapshot.escalated_team || "none",
               "data-handoff-ready": snapshot.handoff_ready,
               "data-receipt-id": snapshot.receipt_id || "none",
               "data-receipt-valid": receipt_valid,
               style: Dispatch::Web.style(:shell) do
            header style: Dispatch::Web.style(:header) do
              div do
                para "Igniter showcase POC", style: Dispatch::Web.style(:eyebrow)
                h1 "Dispatch command center", style: Dispatch::Web.style(:title)
                para "A replayable incident command loop: open a seeded event bundle, triage it, record assignment or escalation, and emit a handoff receipt.",
                     style: Dispatch::Web.style(:subtitle)
              end

              aside class: "incident-status",
                    "data-incident-status": snapshot.status,
                    style: Dispatch::Web.style(:status) do
                strong snapshot.status.to_s, style: Dispatch::Web.style(:status_value)
                span "incident state"
              end
            end

            section class: "incident-stats", style: Dispatch::Web.style(:stats) do
              div "data-severity": snapshot.severity, style: Dispatch::Web.style(:stat) do
                strong snapshot.severity.to_s, style: Dispatch::Web.style(:stat_value)
                span "severity"
              end
              div "data-suspected-cause": snapshot.suspected_cause, style: Dispatch::Web.style(:stat) do
                strong snapshot.suspected_cause.to_s, style: Dispatch::Web.style(:stat_value)
                span "cause"
              end
              div "data-event-count": snapshot.event_count, style: Dispatch::Web.style(:stat) do
                strong snapshot.event_count.to_s, style: Dispatch::Web.style(:stat_value)
                span "events"
              end
              div "data-handoff-ready": snapshot.handoff_ready, style: Dispatch::Web.style(:stat) do
                strong snapshot.handoff_ready.to_s, style: Dispatch::Web.style(:stat_value)
                span "handoff ready"
              end
            end

            section class: "incident-intake", style: Dispatch::Web.style(:panel) do
              h2 "Incident intake", style: Dispatch::Web.style(:panel_title)
              para "Seeded fixtures only. Dispatch does not poll production, run queues, call connectors, or execute remediation.",
                   style: Dispatch::Web.style(:meta)
              form action: "/incidents/open", method: "post", style: Dispatch::Web.style(:actions) do
                input name: "incident_id",
                      type: "text",
                      value: snapshot.incident_id || app.default_incident_id,
                      style: Dispatch::Web.style(:input)
                button "Open incident",
                       type: "submit",
                       "data-action": "open-incident",
                       style: Dispatch::Web.style(:button)
              end
            end

            if feedback
              section class: "feedback #{feedback.fetch(:kind)}",
                      "data-ig-feedback": feedback.fetch(:kind),
                      "data-feedback-code": feedback.fetch(:code),
                      style: Dispatch::Web.feedback_style(feedback) do
                para feedback.fetch(:message), style: "margin: 0;"
              end
            end

            div style: Dispatch::Web.style(:grid) do
              section class: "event-evidence", style: Dispatch::Web.style(:panel) do
                h2 "Event evidence", style: Dispatch::Web.style(:panel_title)
                if snapshot.top_events.empty?
                  para "Open and triage an incident to render seeded event evidence.",
                       style: Dispatch::Web.style(:meta)
                end
                snapshot.top_events.each do |event|
                  article class: "event",
                          "data-event-id": event.fetch(:id),
                          "data-event-kind": event.fetch(:kind),
                          "data-event-signal": event.fetch(:signal),
                          "data-event-service": event.fetch(:service),
                          "data-event-citation": event.fetch(:citation),
                          "data-event-severity-hint": event.fetch(:severity_hint),
                          "data-provenance-path": event.fetch(:source_path),
                          style: Dispatch::Web.style(:event) do
                    h3 "#{event.fetch(:id)}: #{event.fetch(:signal)}", style: "margin: 0 0 8px;"
                    para event.fetch(:summary), style: Dispatch::Web.style(:meta)
                    para event.fetch(:source_path), style: Dispatch::Web.style(:meta)
                    span event.fetch(:severity_hint), "data-event-severity-hint": event.fetch(:severity_hint), style: Dispatch::Web.style(:tag)
                  end
                end

                form action: "/incidents/triage", method: "post", style: Dispatch::Web.style(:actions) do
                  input type: "hidden", name: "session_id", value: snapshot.session_id
                  button "Run triage",
                         type: "submit",
                         "data-action": "triage-incident",
                         style: Dispatch::Web.style(:button)
                end
              end

              section class: "routing", style: Dispatch::Web.style(:panel) do
                h2 "Triage and routing", style: Dispatch::Web.style(:panel_title)
                if snapshot.route_options.empty?
                  para "Triage computes route options from seeded events and runbook rules.",
                       style: Dispatch::Web.style(:meta)
                end
                snapshot.route_options.each do |route|
                  article class: "route",
                          "data-route-option": route.fetch(:team),
                          "data-route-team": route.fetch(:team),
                          "data-route-reason": route.fetch(:rationale),
                          style: Dispatch::Web.style(:route) do
                    h3 "#{route.fetch(:team)} (#{route.fetch(:role)})", style: "margin: 0 0 8px;"
                    para route.fetch(:rationale), style: Dispatch::Web.style(:meta)
                  end
                end
                ol style: Dispatch::Web.style(:nested) do
                  snapshot.routing_evidence.each do |ref|
                    li "data-event-id": ref.fetch(:event_id),
                       "data-event-citation": ref.fetch(:citation),
                       "data-provenance-path": ref.fetch(:source_path) do
                      span "#{ref.fetch(:event_id)} #{ref.fetch(:citation)}"
                    end
                  end
                end
              end
            end

            section class: "checkpoint", style: Dispatch::Web.style(:panel) do
              h2 "Assignment or escalation checkpoint", style: Dispatch::Web.style(:panel_title)
              para "Record an owner from the routing options, or escalate with a reason when database review is needed.",
                   style: Dispatch::Web.style(:meta)
              para "Selected team: #{selected_team}",
                   "data-assigned-team": snapshot.assigned_team || "none",
                   "data-escalated-team": snapshot.escalated_team || "none",
                   style: Dispatch::Web.style(:meta)
              div style: Dispatch::Web.style(:grid) do
                form action: "/assignments", method: "post", style: Dispatch::Web.style(:actions) do
                  input type: "hidden", name: "session_id", value: snapshot.session_id
                  input name: "team", type: "text", value: snapshot.assigned_team || "payments-platform", style: Dispatch::Web.style(:input)
                  button "Assign owner",
                         type: "submit",
                         "data-action": "assign-owner",
                         style: Dispatch::Web.style(:button)
                end
                form action: "/escalations", method: "post", style: Dispatch::Web.style(:actions) do
                  input type: "hidden", name: "session_id", value: snapshot.session_id
                  input name: "team", type: "text", value: snapshot.escalated_team || "database-oncall", style: Dispatch::Web.style(:input)
                  input name: "reason", type: "text", placeholder: "migration rollback needs database review", style: Dispatch::Web.style(:input)
                  button "Escalate incident",
                         type: "submit",
                         "data-action": "escalate-incident",
                         style: Dispatch::Web.style(:button)
                end
              end
            end

            section class: "receipt",
                    "data-receipt-id": snapshot.receipt_id || "none",
                    "data-receipt-valid": receipt_valid,
                    style: Dispatch::Web.style(:receipt) do
              h2 "Incident handoff receipt", style: "margin: 0 0 10px;"
              para "Receipt id: #{snapshot.receipt_id || "not emitted"}", style: "margin: 0 0 8px;"
              if receipt_valid
                para "Receipt is ready. Inspect the Markdown artifact through /receipt.",
                     style: "margin: 0 0 12px;"
              else
                para "Receipt emission requires triage plus an assignment or escalation checkpoint.",
                     style: "margin: 0 0 12px;"
              end
              form action: "/receipts", method: "post" do
                input type: "hidden", name: "session_id", value: snapshot.session_id
                button "Emit receipt",
                       type: "submit",
                       "data-action": "emit-receipt",
                       style: Dispatch::Web.style(:button)
              end
            end

            section class: "recent-activity",
                    "data-ig-activity": "recent",
                    "data-activity-count": snapshot.recent_events.length,
                    style: Dispatch::Web.style(:panel) do
              h2 "Recent activity", style: Dispatch::Web.style(:panel_title)
              ol style: Dispatch::Web.style(:activity_list) do
                snapshot.recent_events.each do |event|
                  incident_id = Dispatch::Web.activity_incident_id(event)
                  li "data-activity-index": event.fetch(:index),
                     "data-activity-kind": event.fetch(:kind),
                     "data-activity-incident-id": incident_id,
                     "data-activity-status": event.fetch(:status),
                     style: Dispatch::Web.style(:activity_item) do
                    span "#{Dispatch::Web.activity_label(event)}: #{incident_id}",
                         style: Dispatch::Web.style(:activity_meta)
                  end
                end
              end
            end

            footer style: Dispatch::Web.style(:footer) do
              para "Read endpoint: GET /events -> incident=#{snapshot.incident_id || "none"} status=#{snapshot.status}",
                   style: "margin: 0;"
              para "Fixture-backed only: no production polling, queue runtime, connectors, LLM triage, shell execution, or cluster placement.",
                   style: Dispatch::Web.style(:meta)
              div style: Dispatch::Web.style(:inspection) do
                a "Inspect events", href: "/events", style: Dispatch::Web.style(:inspection_link)
                a "Inspect receipt", href: "/receipt", style: Dispatch::Web.style(:inspection_link)
              end
            end
          end
        end
      end

      Igniter::Web.mount(:command_center, path: "/", application: application)
    end
  end
end
