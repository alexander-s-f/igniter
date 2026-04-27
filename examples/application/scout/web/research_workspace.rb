# frozen_string_literal: true

require "uri"

require "igniter/web"

module Scout
  module Web
    STYLES = {
      shell: "max-width: 1080px; margin: 34px auto; padding: 30px; font-family: ui-sans-serif, system-ui; background: #edf4f0; border: 1px solid #18231f; box-shadow: 12px 12px 0 #18231f;",
      header: "display: flex; flex-wrap: wrap; justify-content: space-between; gap: 20px; align-items: flex-start;",
      eyebrow: "margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.16em; font-size: 12px;",
      title: "margin: 0; font-size: 44px; line-height: 1;",
      subtitle: "margin: 12px 0 0; max-width: 690px;",
      status: "min-width: 160px; padding: 16px; color: #edf4f0; background: #18231f; text-align: center;",
      status_value: "display: block; font-size: 22px; font-weight: 800;",
      stats: "display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin: 24px 0;",
      stat: "padding: 14px; border: 1px solid #18231f; background: #fffdf6;",
      stat_value: "display: block; font-size: 24px; font-weight: 800;",
      actions: "display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin: 14px 0 0;",
      button: "padding: 10px 14px; border: 1px solid #18231f; background: #8ecae6; cursor: pointer;",
      input: "width: min(100%, 360px); padding: 10px; border: 1px solid #18231f;",
      feedback: "margin: 18px 0; padding: 12px 14px; border: 1px solid #18231f; font-weight: 700;",
      feedback_notice: " background: #d9edc2;",
      feedback_error: " background: #ffd6c8;",
      grid: "display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 18px;",
      panel: "padding: 18px; background: #fffdf6; border: 1px solid #18231f;",
      panel_title: "margin: 0 0 12px; font-size: 22px;",
      source: "margin-top: 12px; padding: 14px; background: #e8f5ff; border: 1px solid #18231f;",
      finding: "margin-top: 12px; padding: 14px; background: #fff3cf; border: 1px solid #18231f;",
      contradiction: "margin-top: 12px; padding: 14px; background: #ffe3d7; border: 1px solid #18231f;",
      meta: "margin: 6px 0;",
      tag: "display: inline-block; margin: 6px 8px 0 0; padding: 4px 8px; background: #18231f; color: #fffdf6; font-size: 12px;",
      nested: "margin: 8px 0 0; padding-left: 20px;",
      receipt: "margin-top: 18px; padding: 18px; color: #fffdf6; background: #18231f;",
      activity_list: "margin: 0; padding-left: 20px;",
      activity_item: "margin-top: 8px;",
      activity_meta: "font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em;",
      inspection: "display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px;",
      inspection_link: "color: #18231f; font-weight: 800;",
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
      when "scout_session_started"
        feedback(:notice, "Research session started.", "scout_session_started")
      when "scout_findings_extracted"
        feedback(:notice, "Findings extracted from local sources.", "scout_findings_extracted")
      when "scout_checkpoint_chosen"
        feedback(:notice, "Direction checkpoint recorded.", "scout_checkpoint_chosen")
      when "scout_local_source_added"
        feedback(:notice, "Local source added.", "scout_local_source_added")
      when "scout_receipt_emitted"
        feedback(:notice, "Research receipt emitted.", "scout_receipt_emitted")
      end
    end

    def self.error_feedback(params)
      case params.fetch("error")
      when "scout_blank_topic"
        feedback(:error, "Topic cannot be blank.", "scout_blank_topic")
      when "scout_unknown_source"
        feedback(:error, "Local source was not found.", "scout_unknown_source")
      when "scout_unknown_session"
        feedback(:error, "Research session was not found.", "scout_unknown_session")
      when "scout_no_sources"
        feedback(:error, "Select at least one local source.", "scout_no_sources")
      when "scout_invalid_checkpoint"
        feedback(:error, "Checkpoint direction is not available yet.", "scout_invalid_checkpoint")
      when "scout_receipt_not_ready"
        feedback(:error, "Receipt is not ready until findings and checkpoint are complete.", "scout_receipt_not_ready")
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

    def self.activity_source_id(event)
      event.fetch(:source_id) || "-"
    end

    def self.source_ids_value(app, snapshot)
      ids = snapshot.source_refs.map { |source| source.fetch(:source_id) }
      ids = app.default_source_ids if ids.empty?
      ids.join(",")
    end

    def self.research_workspace_mount
      application = Igniter::Web.application do
        root title: "Scout research workspace" do
          app = assigns[:ctx].service(:scout).call
          snapshot = app.snapshot
          feedback = Scout::Web.feedback_for(assigns[:env])
          receipt_valid = !snapshot.receipt_id.to_s.empty?

          main class: "scout-workspace",
               "data-ig-poc-surface": "scout_research_workspace",
               "data-session-id": snapshot.session_id || "none",
               "data-topic": snapshot.topic || "none",
               "data-research-status": snapshot.status,
               "data-source-count": snapshot.source_count,
               "data-finding-count": snapshot.finding_count,
               "data-contradiction-count": snapshot.contradiction_count,
               "data-checkpoint-choice": snapshot.checkpoint_choice || "none",
               "data-receipt-id": snapshot.receipt_id || "none",
               "data-receipt-valid": receipt_valid,
               style: Scout::Web.style(:shell) do
            header style: Scout::Web.style(:header) do
              div do
                para "Igniter showcase POC", style: Scout::Web.style(:eyebrow)
                h1 "Scout research workspace", style: Scout::Web.style(:title)
                para "A local-source research loop: start a topic, extract source-backed findings, choose a direction, and emit a provenance receipt.",
                     style: Scout::Web.style(:subtitle)
              end

              aside class: "research-status",
                    "data-research-status": snapshot.status,
                    style: Scout::Web.style(:status) do
                strong snapshot.status.to_s, style: Scout::Web.style(:status_value)
                span "research state"
              end
            end

            section class: "research-stats", style: Scout::Web.style(:stats) do
              div "data-source-count": snapshot.source_count, style: Scout::Web.style(:stat) do
                strong snapshot.source_count.to_s, style: Scout::Web.style(:stat_value)
                span "sources"
              end
              div "data-finding-count": snapshot.finding_count, style: Scout::Web.style(:stat) do
                strong snapshot.finding_count.to_s, style: Scout::Web.style(:stat_value)
                span "findings"
              end
              div "data-contradiction-count": snapshot.contradiction_count, style: Scout::Web.style(:stat) do
                strong snapshot.contradiction_count.to_s, style: Scout::Web.style(:stat_value)
                span "tensions"
              end
              div "data-checkpoint-choice": snapshot.checkpoint_choice || "none", style: Scout::Web.style(:stat) do
                strong((snapshot.checkpoint_choice || "none").to_s, style: Scout::Web.style(:stat_value))
                span "checkpoint"
              end
            end

            section class: "session-starter", style: Scout::Web.style(:panel) do
              h2 "Start local research", style: Scout::Web.style(:panel_title)
              para "Source ids are local fixtures only. No network, LLM, connector, or background worker is used.",
                   style: Scout::Web.style(:meta)
              form action: "/sessions/start", method: "post", style: Scout::Web.style(:actions) do
                input name: "topic",
                      type: "text",
                      value: snapshot.topic || app.default_topic,
                      style: Scout::Web.style(:input)
                input name: "source_ids",
                      type: "text",
                      value: Scout::Web.source_ids_value(app, snapshot),
                      style: Scout::Web.style(:input)
                button "Start session",
                       type: "submit",
                       "data-action": "start-session",
                       style: Scout::Web.style(:button)
              end
            end

            if feedback
              section class: "feedback #{feedback.fetch(:kind)}",
                      "data-ig-feedback": feedback.fetch(:kind),
                      "data-feedback-code": feedback.fetch(:code),
                      style: Scout::Web.feedback_style(feedback) do
                para feedback.fetch(:message), style: "margin: 0;"
              end
            end

            div style: Scout::Web.style(:grid) do
              section class: "sources", style: Scout::Web.style(:panel) do
                h2 "Source pack", style: Scout::Web.style(:panel_title)
                para "Start a session to lock a local source set.", style: Scout::Web.style(:meta) if snapshot.source_refs.empty?
                snapshot.source_refs.each do |source|
                  article class: "source",
                          "data-source-id": source.fetch(:source_id),
                          "data-source-type": source.fetch(:source_type),
                          "data-source-path": source.fetch(:source_path),
                          "data-provenance-path": source.fetch(:source_path),
                          style: Scout::Web.style(:source) do
                    h3 "#{source.fetch(:source_id)}: #{source.fetch(:title)}", style: "margin: 0 0 8px;"
                    para source.fetch(:source_path), style: Scout::Web.style(:meta)
                    source.fetch(:tags).each do |tag|
                      span tag, "data-source-tag": tag, style: Scout::Web.style(:tag)
                    end
                  end
                end

                form action: "/sources/add", method: "post", style: Scout::Web.style(:actions) do
                  input type: "hidden", name: "session_id", value: snapshot.session_id
                  input name: "source_id", type: "text", placeholder: "SRC-004", style: Scout::Web.style(:input)
                  button "Add local source",
                         type: "submit",
                         "data-action": "add-local-source",
                         style: Scout::Web.style(:button)
                end
              end

              section class: "findings", style: Scout::Web.style(:panel) do
                h2 "Source-backed findings", style: Scout::Web.style(:panel_title)
                form action: "/findings/extract", method: "post", style: Scout::Web.style(:actions) do
                  input type: "hidden", name: "session_id", value: snapshot.session_id
                  button "Extract findings",
                         type: "submit",
                         "data-action": "extract-findings",
                         style: Scout::Web.style(:button)
                end

                snapshot.top_findings.each do |finding|
                  article class: "finding",
                          "data-finding-id": finding.fetch(:id),
                          "data-finding-direction": finding.fetch(:direction),
                          "data-finding-confidence": finding.fetch(:confidence_signal),
                          style: Scout::Web.style(:finding) do
                    h3 "#{finding.fetch(:id)}: #{finding.fetch(:direction)}", style: "margin: 0 0 8px;"
                    para finding.fetch(:statement), style: Scout::Web.style(:meta)
                    ol style: Scout::Web.style(:nested) do
                      finding.fetch(:source_refs).each do |ref|
                        li "data-source-ref": ref.fetch(:source_id),
                           "data-citation-id": ref.fetch(:citation_id),
                           "data-citation-anchor": ref.fetch(:citation_anchor),
                           "data-provenance-path": ref.fetch(:source_path) do
                          span "#{ref.fetch(:citation_id)} @ #{ref.fetch(:source_path)}"
                        end
                      end
                    end
                  end
                end
              end
            end

            section class: "contradictions", style: Scout::Web.style(:panel) do
              h2 "Direction checkpoint", style: Scout::Web.style(:panel_title)
              snapshot.contradictions.each do |contradiction|
                article class: "contradiction",
                        "data-contradiction-id": contradiction.fetch(:id),
                        "data-contradiction-count": snapshot.contradiction_count,
                        style: Scout::Web.style(:contradiction) do
                  h3 contradiction.fetch(:id), style: "margin: 0 0 8px;"
                  para contradiction.fetch(:summary), style: Scout::Web.style(:meta)
                  contradiction.fetch(:directions).each do |direction|
                    span direction,
                         "data-contradiction-direction": direction,
                         "data-checkpoint-option": direction,
                         style: Scout::Web.style(:tag)
                  end
                  ol style: Scout::Web.style(:nested) do
                    contradiction.fetch(:source_refs).each do |ref|
                      li "data-source-ref": ref.fetch(:source_id),
                         "data-citation-id": ref.fetch(:citation_id),
                         "data-citation-anchor": ref.fetch(:citation_anchor),
                         "data-provenance-path": ref.fetch(:source_path) do
                        span ref.fetch(:citation_id)
                      end
                    end
                  end
                end
              end

              form action: "/checkpoints", method: "post", style: Scout::Web.style(:actions) do
                input type: "hidden", name: "session_id", value: snapshot.session_id
                input name: "direction", type: "text", placeholder: "balanced", style: Scout::Web.style(:input)
                button "Choose checkpoint",
                       type: "submit",
                       "data-action": "choose-checkpoint",
                       style: Scout::Web.style(:button)
              end
            end

            section class: "receipt",
                    "data-receipt-id": snapshot.receipt_id || "none",
                    "data-receipt-valid": receipt_valid,
                    style: Scout::Web.style(:receipt) do
              h2 "Research receipt", style: "margin: 0 0 10px;"
              para "Receipt id: #{snapshot.receipt_id || "not emitted"}", style: "margin: 0 0 8px;"
              para "Receipt emission requires extracted findings plus a valid direction checkpoint.",
                   style: "margin: 0 0 12px;"
              form action: "/receipts", method: "post" do
                input type: "hidden", name: "session_id", value: snapshot.session_id
                button "Emit receipt",
                       type: "submit",
                       "data-action": "emit-receipt",
                       style: Scout::Web.style(:button)
              end
            end

            section class: "recent-activity",
                    "data-ig-activity": "recent",
                    "data-activity-count": snapshot.recent_events.length,
                    style: Scout::Web.style(:panel) do
              h2 "Recent activity", style: Scout::Web.style(:panel_title)
              ol style: Scout::Web.style(:activity_list) do
                snapshot.recent_events.each do |event|
                  source_id = Scout::Web.activity_source_id(event)
                  li "data-activity-index": event.fetch(:index),
                     "data-activity-kind": event.fetch(:kind),
                     "data-activity-source-id": source_id,
                     "data-activity-status": event.fetch(:status),
                     style: Scout::Web.style(:activity_item) do
                    span "#{Scout::Web.activity_label(event)}: #{source_id}",
                         style: Scout::Web.style(:activity_meta)
                  end
                end
              end
            end

            footer style: Scout::Web.style(:footer) do
              para "Read endpoint: GET /events -> topic=#{snapshot.topic || "none"} status=#{snapshot.status}",
                   style: "margin: 0;"
              div style: Scout::Web.style(:inspection) do
                a "Inspect events", href: "/events", style: Scout::Web.style(:inspection_link)
                a "Inspect receipt", href: "/receipt", style: Scout::Web.style(:inspection_link)
              end
            end
          end
        end
      end

      Igniter::Web.mount(:research_workspace, path: "/", application: application)
    end
  end
end
