# frozen_string_literal: true

require "uri"

require "igniter/web"

module Companion
  module Web
    STYLES = {
      shell: "max-width: 980px; margin: 28px auto; padding: 24px; font-family: ui-sans-serif, system-ui; color: #18201f; background: #f7f7f2; border: 1px solid #18201f;",
      header: "display: flex; justify-content: space-between; gap: 18px; align-items: flex-start; border-bottom: 1px solid #18201f; padding-bottom: 18px;",
      eyebrow: "margin: 0 0 6px; text-transform: uppercase; font-size: 12px; letter-spacing: .14em;",
      title: "margin: 0; font-size: 40px; line-height: 1;",
      status: "padding: 12px; border: 1px solid #18201f; background: #e8f0ff; min-width: 170px;",
      grid: "display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 14px; margin-top: 18px;",
      panel: "padding: 16px; border: 1px solid #18201f; background: #fff;",
      panel_accent: "padding: 16px; border: 1px solid #18201f; background: #eff8df;",
      h2: "margin: 0 0 12px; font-size: 20px;",
      form_row: "display: flex; gap: 8px; align-items: center; margin-top: 10px;",
      input: "min-width: 0; flex: 1; padding: 9px; border: 1px solid #18201f;",
      button: "padding: 9px 12px; border: 1px solid #18201f; background: #f3c14f; cursor: pointer;",
      item: "padding: 10px 0; border-top: 1px solid #d9d6c9;",
      muted: "color: #5b6461; font-size: 13px;",
      feedback: "margin-top: 14px; padding: 10px; border: 1px solid #18201f; background: #ffe3ce;",
      activity: "font-size: 13px; margin-top: 8px;"
    }.freeze

    def self.style(name)
      STYLES.fetch(name)
    end

    def self.feedback_for(env)
      params = URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).to_h
      return nil unless params["notice"] || params["error"]

      {
        kind: params["notice"] ? :notice : :error,
        code: params["notice"] || params["error"]
      }
    end

    def self.companion_dashboard_mount
      application = Igniter::Web.application do
        root title: "Igniter Companion" do
          store = assigns[:ctx].service(:companion).call
          hub = assigns[:ctx].service(:hub).call
          snapshot = store.snapshot
          feedback = Companion::Web.feedback_for(assigns[:env])

          main "data-ig-poc-surface": "companion_dashboard", style: Companion::Web.style(:shell) do
            header style: Companion::Web.style(:header) do
              div do
                para "Ready-to-go Igniter app", style: Companion::Web.style(:eyebrow)
                h1 "Igniter Companion", style: Companion::Web.style(:title)
                para snapshot.daily_summary.fetch(:summary), "data-companion-summary": "offline", style: Companion::Web.style(:muted)
              end

              aside "data-live-ready": snapshot.live_ready, style: Companion::Web.style(:status) do
                strong(snapshot.live_ready ? "Live ready" : "Offline mode")
                para(snapshot.live_ready ? "OPENAI_API_KEY is configured." : "Set OPENAI_API_KEY to enable live assistant features.",
                     style: Companion::Web.style(:muted))
              end
            end

            if feedback
              section "data-ig-feedback": feedback.fetch(:kind),
                      "data-feedback-code": feedback.fetch(:code),
                      style: Companion::Web.style(:feedback) do
                para feedback.fetch(:code).to_s.tr("_", " "), style: "margin: 0;"
              end
            end

            section style: Companion::Web.style(:grid) do
              div "data-capsule": "reminders", style: Companion::Web.style(:panel) do
                h2 "Reminders", style: Companion::Web.style(:h2)
                para "#{snapshot.open_reminders} open", "data-open-reminders": snapshot.open_reminders, style: Companion::Web.style(:muted)

                snapshot.reminders.each do |reminder|
                  div "data-reminder-id": reminder.id, "data-reminder-status": reminder.status, style: Companion::Web.style(:item) do
                    strong reminder.title
                    para "Due: #{reminder.due}", style: Companion::Web.style(:muted)
                    if reminder.status == :open
                      form action: "/reminders/#{reminder.id}/complete", method: "post" do
                        button "Done", type: "submit", "data-action": "complete-reminder", style: Companion::Web.style(:button)
                      end
                    end
                  end
                end

                form action: "/reminders/create", method: "post", style: Companion::Web.style(:form_row) do
                  input name: "title", type: "text", placeholder: "Call mom", style: Companion::Web.style(:input)
                  button "Add", type: "submit", "data-action": "create-reminder", style: Companion::Web.style(:button)
                end
              end

              div "data-capsule": "trackers", style: Companion::Web.style(:panel_accent) do
                h2 "Trackers", style: Companion::Web.style(:h2)
                para "#{snapshot.tracker_logs_today} logs today", "data-tracker-logs": snapshot.tracker_logs_today, style: Companion::Web.style(:muted)

                snapshot.trackers.each do |tracker|
                  div "data-tracker-id": tracker.id, "data-tracker-template": tracker.template, style: Companion::Web.style(:item) do
                    strong "#{tracker.name} (#{tracker.unit})"
                    form action: "/trackers/#{tracker.id}/log", method: "post", style: Companion::Web.style(:form_row) do
                      input name: "value", type: "text", placeholder: tracker.unit, style: Companion::Web.style(:input)
                      button "Log", type: "submit", "data-action": "log-tracker", style: Companion::Web.style(:button)
                    end
                  end
                end
              end

              div "data-capsule": "countdowns", style: Companion::Web.style(:panel) do
                h2 "Countdowns", style: Companion::Web.style(:h2)
                snapshot.countdowns.each do |countdown|
                  div "data-countdown-id": countdown.id, style: Companion::Web.style(:item) do
                    strong countdown.title
                    para countdown.target_date, style: Companion::Web.style(:muted)
                  end
                end
              end

              div "data-capsule": "body-battery", style: Companion::Web.style(:panel_accent) do
                h2 "Body battery", style: Companion::Web.style(:h2)
                strong "#{snapshot.body_battery.fetch(:score)} / 100", "data-body-battery-score": snapshot.body_battery.fetch(:score)
                para snapshot.body_battery.fetch(:status).capitalize,
                     "data-body-battery-status": snapshot.body_battery.fetch(:status),
                     style: Companion::Web.style(:muted)
                para snapshot.body_battery.fetch(:recommendation), "data-body-battery-recommendation": "true"
              end

              div "data-capsule": "daily-summary", style: Companion::Web.style(:panel_accent) do
                h2 "Daily summary", style: Companion::Web.style(:h2)
                para snapshot.daily_summary.fetch(:recommendation), "data-daily-recommendation": "true"
                if snapshot.live_summary
                  para snapshot.live_summary.fetch(:text),
                       "data-live-summary": "generated",
                       style: Companion::Web.style(:item)
                elsif snapshot.live_ready
                  form action: "/summary/live", method: "post" do
                    button "Generate live summary",
                           type: "submit",
                           "data-action": "generate-live-summary",
                           style: Companion::Web.style(:button)
                  end
                else
                  para "Add OPENAI_API_KEY to generate a live assistant summary.",
                       "data-live-summary": "setup-required",
                       style: Companion::Web.style(:muted)
                end
                para "Activity #{snapshot.action_count}", "data-action-count": snapshot.action_count, style: Companion::Web.style(:muted)
                snapshot.recent_events.each do |event|
                  para "#{event.fetch(:kind)} / #{event.fetch(:subject_id)}",
                       "data-activity-kind": event.fetch(:kind),
                       style: Companion::Web.style(:activity)
                end
              end

              div "data-capsule": "hub", "data-hub-catalog": hub.entries.map(&:name).join(","), style: Companion::Web.style(:panel) do
                h2 "Hub", style: Companion::Web.style(:h2)
                if hub.entries.empty?
                  para "No local hub catalog configured.", "data-hub-empty": "true", style: Companion::Web.style(:muted)
                else
                  para "#{hub.entries.length} capsule available", "data-hub-count": hub.entries.length, style: Companion::Web.style(:muted)
                  hub.entries.each do |entry|
                    installed = hub.installed?(entry.name)
                    div "data-hub-entry": entry.name, "data-hub-installed": installed, style: Companion::Web.style(:item) do
                      strong entry.title
                      para(installed ? "Installed" : "Available", style: Companion::Web.style(:muted))
                      para entry.description.to_s, style: Companion::Web.style(:muted)
                      para "Capabilities: #{entry.capabilities.join(", ")}", style: Companion::Web.style(:muted)
                      form action: "/hub/#{entry.name}/install", method: "post" do
                        button(installed ? "Reinstall" : "Install",
                               type: "submit",
                               "data-action": "install-hub-capsule",
                               style: Companion::Web.style(:button))
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      Igniter::Web.mount(:companion_dashboard, path: "/", application: application)
    end
  end
end
