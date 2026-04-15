# frozen_string_literal: true

require "igniter/view"
require "json"

module Companion
  module Dashboard
    module Views
      class HomePage < Igniter::Plugins::View::Page
        class MetricCard < Igniter::Plugins::View::Component
          def initialize(label:, value:)
            @label = label
            @value = value
          end

          def call(view)
            view.tag(:div, class: "card") do |card|
              card.tag(:div, @label, class: "label")
              card.tag(:div, @value, class: "value")
            end
          end
        end

        class Panel < Igniter::Plugins::View::Component
          def initialize(title:, &block)
            @title = title
            @block = block
          end

          def call(view)
            view.tag(:article, class: "panel") do |article|
              article.tag(:h2, @title)
              @block.call(article)
            end
          end
        end

        def self.render(snapshot:)
          new(snapshot: snapshot).render
        end

        def initialize(snapshot:)
          @snapshot = snapshot
        end

        def call(view)
          render_document(view, title: "Companion Dashboard") do |body|
            body.tag(:main, class: "shell") do |main|
              render_hero(main)
              render_metric_cards(main)
              render_panels(main)
              main.tag(:p, class: "meta") do |paragraph|
                paragraph.text("JSON API: ")
                paragraph.tag(:a, href: "/api/overview") { |anchor| anchor.tag(:code, "/api/overview") }
                paragraph.text(" · ")
                paragraph.tag(:a, href: "/views/training-checkin") { |anchor| anchor.text("Open schema demo") }
              end
            end
          end
        end

        private

        attr_reader :snapshot

        def yield_head(head)
          head.tag(:style) { |style| style.raw(stylesheet) }
          head.tag(:script) { |script| script.raw(script_source) }
        end

        def render_hero(view)
          view.tag(:section, class: "hero") do |hero|
            hero.tag(:h1, "Companion Dashboard")
            hero.tag(:p,
                     "Stack-level overview for reminders, Telegram bindings, notification preferences, " \
                     "notes, and execution-store state across companion apps.")
            hero.tag(:div, class: "meta") do |meta|
              meta.text("Generated #{snapshot.fetch(:generated_at)} · ")
              meta.text("apps=#{snapshot.dig(:stack, :apps).join(", ")} · ")
              meta.text("default=#{snapshot.dig(:stack, :default_app)}")
            end
          end
        end

        def render_metric_cards(view)
          counts = snapshot.fetch(:counts)

          view.tag(:section, class: "cards") do |section|
            section.component(MetricCard, label: "Notes", value: counts[:notes])
            section.component(MetricCard, label: "Active Reminders", value: counts[:active_reminders])
            section.component(MetricCard, label: "Telegram Chats", value: counts[:telegram_bindings])
            section.component(MetricCard, label: "Preferences", value: counts[:notification_preferences])
          end
        end

        def render_panels(view)
          view.tag(:section, class: "grid") do |section|
            section.component(panel("Create Reminder") { |panel_view| create_reminder_form(panel_view) })
            section.component(panel("Reminders") { |panel_view| reminders_markup(panel_view, snapshot.fetch(:reminders)) })
            section.component(panel("Telegram") do |panel_view|
              telegram_markup(panel_view, snapshot.fetch(:telegram), snapshot.fetch(:notification_preferences))
            end)
            section.component(panel("Notes") { |panel_view| notes_markup(panel_view, snapshot.fetch(:notes)) })
            section.component(panel("Execution Stores") do |panel_view|
              execution_stores_markup(panel_view, snapshot.fetch(:execution_stores))
            end)
          end
        end

        def panel(title, &block)
          Panel.new(title: title, &block)
        end

        def create_reminder_form(view)
          view.form(action: "/reminders", class: "stacked-form") do |form|
            form.label("reminder-task", "Task")
            form.input("task", id: "reminder-task", placeholder: "Pay rent", required: true)

            form.label("reminder-timing", "When")
            form.input("timing", id: "reminder-timing", placeholder: "Tomorrow at 09:00", required: true)

            form.label("reminder-channel", "Channel")
            form.select("channel",
                        id: "reminder-channel",
                        options: [["No channel", ""], ["Telegram", "telegram"]])

            form.label("reminder-chat-id", "Telegram chat")
            form.select("chat_id",
                        id: "reminder-chat-id",
                        options: telegram_chat_options)

            form.label("reminder-notifications") do |label|
              label.raw('<input type="checkbox" name="notifications_enabled" value="1" checked> ')
              label.text("Enable Telegram notifications")
            end

            form.submit("Create Reminder")
          end
        end

        def reminders_markup(view, reminders)
          return view.tag(:p, "No active reminders yet.") if reminders.empty?

          view.tag(:ul) do |list|
            reminders.last(8).reverse.each do |reminder|
              list.tag(:li) do |item|
                item.tag(:strong, reminder["task"])
                item.text(" ")
                item.tag(:span, reminder["timing"], class: "pill")
                item.tag(:br)
                item.tag(:code, "channel=#{reminder["channel"] || "none"} chat=#{reminder["chat_id"] || "-"}")
                item.tag(:br)
                item.button("Mark Completed",
                            onclick: "postJson('/api/reminders/#{reminder["id"]}/complete', {})")
              end
            end
          end
        end

        def telegram_markup(view, telegram, preferences)
          bindings = Array(telegram[:bindings])

          labelled_code(view, "Preferred chat:", telegram[:preferred_chat_id] || "-")
          labelled_code(view, "Latest chat:", telegram[:latest_chat_id] || "-")

          return view.tag(:p, "No linked Telegram chats yet.") if bindings.empty?

          view.tag(:ul) do |list|
            bindings.first(6).each do |binding|
              name = binding["username"] || binding["first_name"] || binding["title"] || binding["chat_id"]
              chat_id = binding["chat_id"]
              enabled = telegram_notifications_enabled?(preferences, chat_id)
              action_label = enabled ? "Disable Notifications" : "Enable Notifications"
              action_value = enabled ? "false" : "true"
              button_class = enabled ? "secondary" : nil

              list.tag(:li) do |item|
                item.tag(:strong, name)
                item.tag(:br)
                item.tag(:code, "chat_id=#{chat_id} type=#{binding["type"] || "unknown"}")
                item.tag(:br)
                item.tag(:span, "notifications=#{enabled}", class: "pill")
                item.tag(:br)
                item.button(action_label,
                            class: button_class,
                            onclick: "postJson('/api/telegram/preferences', { chat_id: #{js_string(chat_id)}, enabled: #{action_value} })")
              end
            end
          end
        end

        def notes_markup(view, notes)
          return view.tag(:p, "No notes saved yet.") if notes.empty?

          view.tag(:ul) do |list|
            notes.first(8).each do |key, value|
              list.tag(:li) do |item|
                item.tag(:strong, key)
                item.tag(:br)
                item.text(value)
              end
            end
          end
        end

        def execution_stores_markup(view, execution_stores)
          view.tag(:ul) do |list|
            execution_stores.each do |app_name, summary|
              list.tag(:li) do |item|
                item.tag(:strong, app_name)
                item.tag(:br)
                item.tag(:code, summary[:class])
                item.tag(:br)
                item.text("total=#{summary[:total]} pending=#{summary[:pending]}")
              end
            end
          end
        end

        def labelled_code(view, label, value)
          view.tag(:p) do |paragraph|
            paragraph.tag(:strong, label)
            paragraph.text(" ")
            paragraph.tag(:code, value)
          end
        end

        def js_string(value)
          JSON.generate(value.to_s)
        end

        def telegram_notifications_enabled?(preferences, chat_id)
          prefs = preferences["telegram:#{chat_id}"]
          return true if prefs.nil?

          prefs["telegram_enabled"] != false
        end

        def telegram_chat_options
          preferred_chat_id = snapshot.dig(:telegram, :preferred_chat_id).to_s
          bindings = Array(snapshot.dig(:telegram, :bindings))

          options = [["Auto / none", ""]]
          bindings.each do |binding|
            chat_id = binding["chat_id"].to_s
            name = binding["username"] || binding["first_name"] || binding["title"] || chat_id
            suffix = chat_id == preferred_chat_id ? " (preferred)" : ""
            options << ["#{name}#{suffix}", chat_id]
          end
          options.uniq
        end

        def stylesheet
          <<~CSS
            :root {
              --bg: #f5efe5;
              --panel: #fffaf2;
              --ink: #1f2a2e;
              --muted: #5c6b70;
              --line: #d9c8aa;
              --accent: #c26b3d;
              --accent-soft: #f1d1b8;
            }
            * { box-sizing: border-box; }
            body {
              margin: 0;
              font-family: "Iowan Old Style", "Palatino Linotype", serif;
              background:
                radial-gradient(circle at top left, rgba(194, 107, 61, 0.14), transparent 28%),
                linear-gradient(180deg, #f9f3ea 0%, var(--bg) 100%);
              color: var(--ink);
            }
            .shell {
              max-width: 1180px;
              margin: 0 auto;
              padding: 32px 20px 56px;
            }
            .hero {
              background: var(--panel);
              border: 1px solid var(--line);
              border-radius: 24px;
              padding: 28px;
              box-shadow: 0 18px 44px rgba(62, 39, 17, 0.08);
            }
            .hero h1 { margin: 0 0 8px; font-size: 40px; }
            .hero p { margin: 0; color: var(--muted); max-width: 720px; }
            .meta {
              margin-top: 14px;
              color: var(--muted);
              font-family: "Menlo", "SFMono-Regular", monospace;
              font-size: 13px;
            }
            .cards {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
              gap: 14px;
              margin: 22px 0 28px;
            }
            .card {
              background: var(--panel);
              border: 1px solid var(--line);
              border-radius: 18px;
              padding: 18px;
            }
            .card .label {
              color: var(--muted);
              font-size: 13px;
              text-transform: uppercase;
              letter-spacing: 0.08em;
            }
            .card .value {
              margin-top: 10px;
              font-size: 34px;
              line-height: 1;
            }
            .grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
              gap: 16px;
            }
            .panel {
              background: var(--panel);
              border: 1px solid var(--line);
              border-radius: 20px;
              padding: 18px;
            }
            .panel h2 {
              margin: 0 0 12px;
              font-size: 20px;
            }
            .panel ul {
              margin: 0;
              padding-left: 18px;
            }
            .panel li {
              margin: 0 0 10px;
            }
            .stacked-form {
              display: grid;
              gap: 10px;
            }
            .stacked-form label {
              display: grid;
              gap: 4px;
              color: var(--muted);
              font-size: 14px;
            }
            .stacked-form input,
            .stacked-form select,
            .stacked-form textarea {
              width: 100%;
              border: 1px solid var(--line);
              border-radius: 12px;
              padding: 10px 12px;
              background: #fffdf8;
              color: var(--ink);
              font: inherit;
            }
            .pill {
              display: inline-block;
              padding: 4px 10px;
              border-radius: 999px;
              background: var(--accent-soft);
              color: #7a3c18;
              font-size: 12px;
              font-family: "Menlo", "SFMono-Regular", monospace;
            }
            code {
              font-family: "Menlo", "SFMono-Regular", monospace;
              font-size: 12px;
            }
            a { color: var(--accent); }
            button {
              margin-top: 8px;
              border: 0;
              border-radius: 999px;
              padding: 7px 12px;
              background: var(--accent);
              color: white;
              font: inherit;
              cursor: pointer;
            }
            button.secondary {
              background: #8b9aa0;
            }
          CSS
        end

        def script_source
          <<~JS
            async function postJson(path, payload) {
              await fetch(path, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload || {})
              });
              window.location.reload();
            }
          JS
        end
      end
    end
  end
end
