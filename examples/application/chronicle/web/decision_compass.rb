# frozen_string_literal: true

require "uri"

require "igniter/web"

module Chronicle
  module Web
    STYLES = {
      shell: "max-width: 1040px; margin: 34px auto; padding: 30px; font-family: ui-sans-serif, system-ui; background: #eef0e8; border: 1px solid #20251d; box-shadow: 12px 12px 0 #20251d;",
      header: "display: flex; flex-wrap: wrap; justify-content: space-between; gap: 20px; align-items: flex-start;",
      eyebrow: "margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.16em; font-size: 12px;",
      title: "margin: 0; font-size: 44px; line-height: 1;",
      subtitle: "margin: 12px 0 0; max-width: 660px;",
      status: "min-width: 150px; padding: 16px; color: #eef0e8; background: #20251d; text-align: center;",
      status_value: "display: block; font-size: 22px; font-weight: 800;",
      stats: "display: grid; grid-template-columns: repeat(auto-fit, minmax(145px, 1fr)); gap: 12px; margin: 24px 0;",
      stat: "padding: 14px; border: 1px solid #20251d; background: #fffdf4;",
      stat_value: "display: block; font-size: 25px; font-weight: 800;",
      actions: "display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin: 14px 0 0;",
      button: "padding: 10px 14px; border: 1px solid #20251d; background: #e9b44c; cursor: pointer;",
      input: "width: min(100%, 250px); padding: 10px; border: 1px solid #20251d;",
      feedback: "margin: 18px 0; padding: 12px 14px; border: 1px solid #20251d; font-weight: 700;",
      feedback_notice: " background: #d8eac1;",
      feedback_error: " background: #ffd6c8;",
      grid: "display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 18px;",
      panel: "padding: 18px; background: #fffdf4; border: 1px solid #20251d;",
      panel_title: "margin: 0 0 12px; font-size: 22px;",
      conflict: "margin-top: 12px; padding: 14px; background: #fff4d1; border: 1px solid #20251d;",
      conflict_acknowledged: " opacity: 0.68;",
      meta: "margin: 6px 0;",
      evidence: "display: inline-block; margin: 6px 8px 0 0; padding: 4px 8px; background: #20251d; color: #fffdf4; font-size: 12px;",
      relation_list: "margin: 0; padding-left: 20px;",
      relation_item: "margin-top: 8px;",
      signer: "display: inline-block; margin: 4px 6px 0 0; padding: 4px 8px; border: 1px solid #20251d; background: #eef0e8;",
      receipt: "margin-top: 18px; padding: 18px; color: #fffdf4; background: #20251d;",
      activity_list: "margin: 0; padding-left: 20px;",
      activity_item: "margin-top: 8px;",
      activity_meta: "font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em;",
      inspection: "display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px;",
      inspection_link: "color: #20251d; font-weight: 800;",
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
      when "chronicle_scan_created"
        feedback(:notice, "Proposal scan created.", "chronicle_scan_created")
      when "chronicle_conflict_acknowledged"
        feedback(:notice, "Conflict acknowledged.", "chronicle_conflict_acknowledged")
      when "chronicle_signoff_recorded"
        feedback(:notice, "Sign-off recorded.", "chronicle_signoff_recorded")
      when "chronicle_signoff_refused"
        feedback(:notice, "Sign-off refusal recorded.", "chronicle_signoff_refused")
      when "chronicle_receipt_emitted"
        feedback(:notice, "Decision receipt emitted.", "chronicle_receipt_emitted")
      end
    end

    def self.error_feedback(params)
      case params.fetch("error")
      when "chronicle_unknown_proposal"
        feedback(:error, "Proposal not found.", "chronicle_unknown_proposal")
      when "chronicle_unknown_session"
        feedback(:error, "Session not found.", "chronicle_unknown_session")
      when "chronicle_unknown_decision"
        feedback(:error, "Decision not found in this session.", "chronicle_unknown_decision")
      when "chronicle_blank_signer"
        feedback(:error, "Signer cannot be blank.", "chronicle_blank_signer")
      when "chronicle_blank_reason"
        feedback(:error, "Refusal reason cannot be blank.", "chronicle_blank_reason")
      when "chronicle_receipt_not_ready"
        feedback(:error, "Receipt is not ready yet.", "chronicle_receipt_not_ready")
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

    def self.conflict_style(conflict)
      style = style(:conflict).dup
      style << style(:conflict_acknowledged) if conflict.fetch(:acknowledged)
      style
    end

    def self.activity_label(event)
      event.fetch(:kind).to_s.tr("_", " ")
    end

    def self.activity_decision_id(event)
      event.fetch(:decision_id) || "-"
    end

    def self.decision_compass_mount
      application = Igniter::Web.application do
        root title: "Chronicle decision compass" do
          app = assigns[:ctx].service(:chronicle).call
          snapshot = app.snapshot
          feedback = Chronicle::Web.feedback_for(assigns[:env])
          receipt_valid = !snapshot.receipt_id.to_s.empty?

          main class: "chronicle-compass",
               "data-ig-poc-surface": "chronicle_decision_compass",
               "data-proposal-id": snapshot.proposal_id || "none",
               "data-proposal-status": snapshot.status,
               "data-session-id": snapshot.session_id || "none",
               "data-conflict-count": snapshot.conflict_count,
               "data-open-conflict-count": snapshot.open_conflict_count,
               "data-receipt-id": snapshot.receipt_id || "none",
               "data-receipt-valid": receipt_valid,
               style: Chronicle::Web.style(:shell) do
            header style: Chronicle::Web.style(:header) do
              div do
                para "Igniter showcase POC", style: Chronicle::Web.style(:eyebrow)
                h1 "Chronicle decision compass", style: Chronicle::Web.style(:title)
                para "A local proposal is checked against existing decisions, then acknowledged, signed off, refused, and closed with a receipt.",
                     style: Chronicle::Web.style(:subtitle)
              end

              aside class: "proposal-status",
                    "data-proposal-status": snapshot.status,
                    style: Chronicle::Web.style(:status) do
                strong snapshot.status.to_s, style: Chronicle::Web.style(:status_value)
                span "review state"
              end
            end

            section class: "proposal-stats", style: Chronicle::Web.style(:stats) do
              div "data-proposal-id": snapshot.proposal_id || "none", style: Chronicle::Web.style(:stat) do
                strong((snapshot.proposal_id || "none").to_s, style: Chronicle::Web.style(:stat_value))
                span "proposal"
              end
              div "data-conflict-count": snapshot.conflict_count, style: Chronicle::Web.style(:stat) do
                strong snapshot.conflict_count.to_s, style: Chronicle::Web.style(:stat_value)
                span "conflicts"
              end
              div "data-open-conflict-count": snapshot.open_conflict_count, style: Chronicle::Web.style(:stat) do
                strong snapshot.open_conflict_count.to_s, style: Chronicle::Web.style(:stat_value)
                span "open"
              end
              div "data-receipt-id": snapshot.receipt_id || "none", style: Chronicle::Web.style(:stat) do
                strong(snapshot.receipt_id ? "ready" : "none", style: Chronicle::Web.style(:stat_value))
                span "receipt"
              end
            end

            section class: "proposal-selector", style: Chronicle::Web.style(:panel) do
              h2 "Scan proposal", style: Chronicle::Web.style(:panel_title)
              para "Seed proposals are read from the app fixture directory; smoke runs write only to the runtime workdir.",
                   style: Chronicle::Web.style(:meta)
              form action: "/proposals/scan", method: "post", style: Chronicle::Web.style(:actions) do
                input name: "proposal_id",
                      type: "text",
                      value: snapshot.proposal_id || "PR-001",
                      style: Chronicle::Web.style(:input)
                button "Scan proposal",
                       type: "submit",
                       "data-action": "scan-proposal",
                       style: Chronicle::Web.style(:button)
              end
            end

            if feedback
              section class: "feedback #{feedback.fetch(:kind)}",
                      "data-ig-feedback": feedback.fetch(:kind),
                      "data-feedback-code": feedback.fetch(:code),
                      style: Chronicle::Web.feedback_style(feedback) do
                para feedback.fetch(:message), style: "margin: 0;"
              end
            end

            div style: Chronicle::Web.style(:grid) do
              section class: "conflicts", style: Chronicle::Web.style(:panel) do
                h2 "Conflict evidence", style: Chronicle::Web.style(:panel_title)
                para "No proposal has been scanned yet.", style: Chronicle::Web.style(:meta) if snapshot.top_conflicts.empty?

                snapshot.top_conflicts.each do |conflict|
                  article class: "conflict",
                          "data-conflict-decision-id": conflict.fetch(:decision_id),
                          "data-conflict-acknowledged": conflict.fetch(:acknowledged),
                          style: Chronicle::Web.conflict_style(conflict) do
                    h3 "#{conflict.fetch(:decision_id)}: #{conflict.fetch(:title)}",
                       style: "margin: 0 0 8px;"
                    para "Status: #{conflict.fetch(:status)} | Evidence: #{conflict.fetch(:evidence_kind)}",
                         style: Chronicle::Web.style(:meta)
                    para conflict.fetch(:evidence_excerpt),
                         style: Chronicle::Web.style(:meta)
                    span conflict.fetch(:evidence_ref),
                         "data-evidence-ref": conflict.fetch(:evidence_ref),
                         style: Chronicle::Web.style(:evidence)
                    conflict.fetch(:shared_tags).each do |tag|
                      span "tag:#{tag}", style: Chronicle::Web.style(:evidence)
                    end

                    unless conflict.fetch(:acknowledged)
                      form action: "/conflicts/acknowledge", method: "post", style: Chronicle::Web.style(:actions) do
                        input type: "hidden", name: "session_id", value: snapshot.session_id
                        input type: "hidden", name: "decision_id", value: conflict.fetch(:decision_id)
                        button "Acknowledge conflict",
                               type: "submit",
                               "data-action": "acknowledge-conflict",
                               style: Chronicle::Web.style(:button)
                      end
                    end
                  end
                end
              end

              section class: "relationships", style: Chronicle::Web.style(:panel) do
                h2 "Decision relationships", style: Chronicle::Web.style(:panel_title)
                ol style: Chronicle::Web.style(:relation_list) do
                  snapshot.related_decisions.each do |decision|
                    li "data-related-decision-id": decision.fetch(:decision_id),
                       "data-related-edge": "#{snapshot.proposal_id || "none"}->#{decision.fetch(:decision_id)}",
                       style: Chronicle::Web.style(:relation_item) do
                      strong "#{decision.fetch(:decision_id)} "
                      span decision.fetch(:title)
                    end
                  end
                end
              end
            end

            section class: "signoffs", style: Chronicle::Web.style(:panel) do
              h2 "Sign-off state", style: Chronicle::Web.style(:panel_title)
              div do
                snapshot.required_signoffs.each do |signer|
                  span signer, "data-required-signer": signer, style: Chronicle::Web.style(:signer)
                end
                snapshot.signed_by.each do |signer|
                  span signer, "data-signed-by": signer, style: Chronicle::Web.style(:signer)
                end
                snapshot.refused_by.each do |signer|
                  span signer, "data-refused-by": signer, style: Chronicle::Web.style(:signer)
                end
              end

              form action: "/signoffs", method: "post", style: Chronicle::Web.style(:actions) do
                input type: "hidden", name: "session_id", value: snapshot.session_id
                input name: "signer", type: "text", placeholder: "platform", style: Chronicle::Web.style(:input)
                button "Record sign-off",
                       type: "submit",
                       "data-action": "record-signoff",
                       style: Chronicle::Web.style(:button)
              end

              form action: "/signoffs/refuse", method: "post", style: Chronicle::Web.style(:actions) do
                input type: "hidden", name: "session_id", value: snapshot.session_id
                input name: "signer", type: "text", placeholder: "security", style: Chronicle::Web.style(:input)
                input name: "reason", type: "text", placeholder: "Reason", style: Chronicle::Web.style(:input)
                button "Refuse sign-off",
                       type: "submit",
                       "data-action": "refuse-signoff",
                       style: Chronicle::Web.style(:button)
              end
            end

            section class: "receipt",
                    "data-receipt-id": snapshot.receipt_id || "none",
                    "data-receipt-valid": receipt_valid,
                    style: Chronicle::Web.style(:receipt) do
              h2 "Decision receipt", style: "margin: 0 0 10px;"
              para "Receipt id: #{snapshot.receipt_id || "not emitted"}", style: "margin: 0 0 8px;"
              para "A receipt can be emitted after conflicts are acknowledged and sign-off state reaches ready or blocked.",
                   style: "margin: 0 0 12px;"
              form action: "/receipts", method: "post" do
                input type: "hidden", name: "session_id", value: snapshot.session_id
                button "Emit receipt",
                       type: "submit",
                       "data-action": "emit-receipt",
                       style: Chronicle::Web.style(:button)
              end
            end

            section class: "recent-activity",
                    "data-ig-activity": "recent",
                    "data-activity-count": snapshot.recent_events.length,
                    style: Chronicle::Web.style(:panel) do
              h2 "Recent activity", style: Chronicle::Web.style(:panel_title)
              ol style: Chronicle::Web.style(:activity_list) do
                snapshot.recent_events.each do |event|
                  decision_id = Chronicle::Web.activity_decision_id(event)
                  li "data-activity-index": event.fetch(:index),
                     "data-activity-kind": event.fetch(:kind),
                     "data-activity-decision-id": decision_id,
                     "data-activity-status": event.fetch(:status),
                     style: Chronicle::Web.style(:activity_item) do
                    span "#{Chronicle::Web.activity_label(event)}: #{decision_id}",
                         style: Chronicle::Web.style(:activity_meta)
                  end
                end
              end
            end

            footer style: Chronicle::Web.style(:footer) do
              para "Read endpoint: GET /events -> proposal=#{snapshot.proposal_id || "none"} status=#{snapshot.status}",
                   style: "margin: 0;"
              div style: Chronicle::Web.style(:inspection) do
                a "Inspect events", href: "/events", style: Chronicle::Web.style(:inspection_link)
                a "Inspect receipt", href: "/receipt", style: Chronicle::Web.style(:inspection_link)
              end
            end
          end
        end
      end

      Igniter::Web.mount(:decision_compass, path: "/", application: application)
    end
  end
end
