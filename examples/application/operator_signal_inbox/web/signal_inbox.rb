# frozen_string_literal: true

require "uri"

require "igniter/web"

module OperatorSignalInbox
  module Web
    STYLES = {
      shell: "max-width: 820px; margin: 40px auto; padding: 28px; font-family: ui-sans-serif, system-ui; background: #eef4f2; border: 1px solid #1d332f; box-shadow: 10px 10px 0 #1d332f;",
      header: "display: flex; justify-content: space-between; gap: 18px; align-items: flex-start;",
      eyebrow: "margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.16em; font-size: 12px;",
      title: "margin: 0; font-size: 40px; line-height: 1;",
      counters: "display: flex; gap: 10px;",
      counter: "min-width: 106px; padding: 14px; color: #eef4f2; background: #1d332f; text-align: center;",
      critical_counter: " background: #8e2f26;",
      counter_value: "display: block; font-size: 32px;",
      intro: "margin: 22px 0; max-width: 660px;",
      feedback: "margin: 18px 0; padding: 12px 14px; border: 1px solid #1d332f; font-weight: 700;",
      feedback_notice: " background: #d8edce;",
      feedback_error: " background: #ffd9cd;",
      card: "margin-top: 14px; padding: 18px; background: #fffdf7; border: 1px solid #1d332f;",
      closed_card: " opacity: 0.64;",
      signal_title: "margin: 0 0 8px;",
      signal_meta: "margin: 0 0 8px;",
      signal_note: "margin: 8px 0 0; font-style: italic;",
      actions: "display: flex; flex-wrap: wrap; gap: 10px; align-items: center; margin-top: 14px;",
      note_input: "width: min(100%, 260px); padding: 10px; border: 1px solid #1d332f;",
      action_button: "padding: 10px 14px; border: 1px solid #1d332f; background: #f0b84d; cursor: pointer;",
      closed_label: "margin: 12px 0 0; font-weight: 700;",
      activity_panel: "margin-top: 22px; padding: 18px; background: #fff6d8; border: 1px solid #1d332f;",
      activity_title: "margin: 0 0 12px; font-size: 18px;",
      activity_list: "margin: 0; padding-left: 20px;",
      activity_item: "margin-top: 8px;",
      activity_meta: "font-size: 12px; text-transform: uppercase; letter-spacing: 0.08em;",
      footer: "margin-top: 22px; font-size: 13px;",
      footer_text: "margin: 0;"
    }.freeze

    def self.style(name)
      STYLES.fetch(name)
    end

    def self.card_style(signal)
      style = STYLES.fetch(:card).dup
      style << STYLES.fetch(:closed_card) unless signal.status == :open
      style
    end

    def self.counter_style(kind)
      style = STYLES.fetch(:counter).dup
      style << STYLES.fetch(:critical_counter) if kind == :critical
      style
    end

    def self.status_label(signal)
      case signal.status
      when :open
        "Open"
      when :acknowledged
        "Acknowledged"
      when :escalated
        "Escalated"
      else
        signal.status.to_s.tr("_", " ")
      end
    end

    def self.severity_label(signal)
      signal.severity.to_s.capitalize
    end

    def self.feedback_for(env)
      params = URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).to_h
      return notice_feedback(params) if params.key?("notice")
      return error_feedback(params) if params.key?("error")

      nil
    end

    def self.notice_feedback(params)
      case params.fetch("notice")
      when "signal_acknowledged"
        feedback(:notice, "Signal acknowledged.", "signal_acknowledged")
      when "signal_escalated"
        feedback(:notice, "Signal escalated.", "signal_escalated")
      end
    end

    def self.error_feedback(params)
      case params.fetch("error")
      when "blank_escalation_note"
        feedback(:error, "Escalation note cannot be blank.", "blank_escalation_note")
      when "signal_not_found"
        feedback(:error, "Signal not found.", "signal_not_found")
      when "signal_closed"
        feedback(:error, "Signal is already closed.", "signal_closed")
      end
    end

    def self.feedback(kind, message, code)
      {
        kind: kind,
        code: code,
        message: message
      }.freeze
    end

    def self.feedback_style(feedback)
      "#{style(:feedback)}#{style(:"feedback_#{feedback.fetch(:kind)}")}"
    end

    def self.activity_label(event)
      case event.fetch(:kind)
      when :signal_seeded
        "Seeded signal"
      when :signal_acknowledged
        "Acknowledged signal"
      when :signal_escalated
        "Escalated signal"
      when :signal_acknowledge_refused
        "Acknowledge refused"
      when :signal_escalate_refused
        "Escalate refused"
      else
        event.fetch(:kind).to_s.tr("_", " ")
      end
    end

    def self.signal_id(event)
      event.fetch(:signal_id) || "-"
    end

    def self.signal_inbox_mount
      application = Igniter::Web.application do
        root title: "Operator signal inbox" do
          snapshot = assigns[:ctx].service(:signal_inbox).call.snapshot(recent_limit: 7)
          feedback = OperatorSignalInbox::Web.feedback_for(assigns[:env])

          main class: "signal-inbox",
               "data-ig-poc-surface": "operator_signal_inbox",
               style: OperatorSignalInbox::Web.style(:shell) do
            header style: OperatorSignalInbox::Web.style(:header) do
              div do
                para "Interactive Igniter POC", style: OperatorSignalInbox::Web.style(:eyebrow)
                h1 "Operator signal inbox", style: OperatorSignalInbox::Web.style(:title)
              end

              div style: OperatorSignalInbox::Web.style(:counters) do
                aside class: "open-count",
                      "data-open-count": snapshot.open_count,
                      style: OperatorSignalInbox::Web.counter_style(:open) do
                  strong snapshot.open_count.to_s, style: OperatorSignalInbox::Web.style(:counter_value)
                  span "open"
                end

                aside class: "critical-count",
                      "data-critical-count": snapshot.critical_count,
                      style: OperatorSignalInbox::Web.counter_style(:critical) do
                  strong snapshot.critical_count.to_s, style: OperatorSignalInbox::Web.style(:counter_value)
                  span "critical"
                end
              end
            end

            para "This page repeats the application/web POC pattern with signal-specific commands, feedback, and read snapshots.",
                 style: OperatorSignalInbox::Web.style(:intro)

            if feedback
              section class: "feedback #{feedback.fetch(:kind)}",
                      "data-ig-feedback": feedback.fetch(:kind),
                      "data-feedback-code": feedback.fetch(:code),
                      style: OperatorSignalInbox::Web.feedback_style(feedback) do
                para feedback.fetch(:message), style: "margin: 0;"
              end
            end

            snapshot.signals.each do |signal|
              section class: "signal #{signal.status}",
                      "data-signal-id": signal.id,
                      "data-signal-status": signal.status,
                      "data-signal-severity": signal.severity,
                      style: OperatorSignalInbox::Web.card_style(signal) do
                h2 signal.summary, style: OperatorSignalInbox::Web.style(:signal_title)
                para "Source: #{signal.source}", style: OperatorSignalInbox::Web.style(:signal_meta)
                para "Severity: #{OperatorSignalInbox::Web.severity_label(signal)}",
                     style: OperatorSignalInbox::Web.style(:signal_meta)
                para "Status: #{OperatorSignalInbox::Web.status_label(signal)}",
                     style: OperatorSignalInbox::Web.style(:signal_meta)
                para "Escalation note: #{signal.note}", style: OperatorSignalInbox::Web.style(:signal_note) if signal.note

                if signal.status == :open
                  div style: OperatorSignalInbox::Web.style(:actions) do
                    form action: "/signals/acknowledge", method: "post" do
                      input type: "hidden", name: "id", value: signal.id
                      button "Acknowledge",
                             type: "submit",
                             "data-action": "acknowledge-signal",
                             style: OperatorSignalInbox::Web.style(:action_button)
                    end

                    form action: "/signals/escalate", method: "post" do
                      input type: "hidden", name: "id", value: signal.id
                      input name: "note",
                            type: "text",
                            placeholder: "Escalation note",
                            required: true,
                            style: OperatorSignalInbox::Web.style(:note_input)
                      button "Escalate",
                             type: "submit",
                             "data-action": "escalate-signal",
                             style: OperatorSignalInbox::Web.style(:action_button)
                    end
                  end
                else
                  para "Closed by operator command",
                       class: "closed",
                       style: OperatorSignalInbox::Web.style(:closed_label)
                end
              end
            end

            section class: "recent-activity",
                    "data-ig-activity": "recent",
                    "data-activity-count": snapshot.recent_events.length,
                    style: OperatorSignalInbox::Web.style(:activity_panel) do
              h2 "Recent signal activity", style: OperatorSignalInbox::Web.style(:activity_title)
              ol style: OperatorSignalInbox::Web.style(:activity_list) do
                snapshot.recent_events.each do |event|
                  signal_id = OperatorSignalInbox::Web.signal_id(event)
                  li "data-activity-index": event.fetch(:index),
                     "data-activity-kind": event.fetch(:kind),
                     "data-activity-signal-id": signal_id,
                     "data-activity-status": event.fetch(:status),
                     style: OperatorSignalInbox::Web.style(:activity_item) do
                    span "#{OperatorSignalInbox::Web.activity_label(event)}: #{signal_id}",
                         style: OperatorSignalInbox::Web.style(:activity_meta)
                  end
                end
              end
            end

            footer style: OperatorSignalInbox::Web.style(:footer) do
              para "Read endpoint: GET /events -> open=#{snapshot.open_count} critical=#{snapshot.critical_count}",
                   style: OperatorSignalInbox::Web.style(:footer_text)
            end
          end
        end
      end

      Igniter::Web.mount(:signal_inbox, path: "/", application: application)
    end
  end
end
