# frozen_string_literal: true

require "igniter/plugins/view"
require "igniter/plugins/view/tailwind"
require "json"

module Companion
  module Dashboard
    module Views
      class HomePage
        MetricCard = Igniter::Plugins::View::Tailwind::UI::MetricCard

        def self.render(snapshot:)
          new(snapshot: snapshot).render
        end

        def initialize(snapshot:)
          @snapshot = snapshot
        end

        def render
          Igniter::Plugins::View::Tailwind.render_page(
            title: "Companion Dashboard",
            body_class: "min-h-screen bg-[#160f0d] text-stone-100 antialiased selection:bg-orange-300/30 selection:text-white",
            main_class: "mx-auto flex min-h-screen w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8",
            tailwind_config: tailwind_config,
            head_content: method(:render_head)
          ) do |main|
            render_hero(main)
            render_metric_cards(main)
            render_panels(main)
            render_footer(main)
          end
        end

        private

        attr_reader :snapshot

        def tailwind_config
          {
            theme: {
              extend: {
                fontFamily: {
                  display: ["Fraunces", "Iowan Old Style", "Palatino Linotype", "serif"],
                  body: ["IBM Plex Sans", "Avenir Next", "system-ui", "sans-serif"],
                  mono: ["IBM Plex Mono", "SFMono-Regular", "Menlo", "monospace"]
                },
                colors: {
                  companion: {
                    accent: "#c26b3d",
                    panel: "#2a1914"
                  }
                }
              }
            }
          }
        end

        def render_head(head)
          head.tag(:script, type: "text/javascript") do |script|
            script.raw(script_source)
          end
        end

        def render_hero(view)
          view.tag(:section,
                   class: "relative overflow-hidden rounded-[34px] border border-orange-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(194,107,61,0.24),_transparent_18rem),linear-gradient(145deg,rgba(60,33,21,0.96),rgba(22,15,13,0.98))] px-6 py-8 shadow-2xl shadow-black/25 sm:px-8 lg:px-10") do |hero|
            hero.tag(:div, class: "absolute inset-y-0 right-0 hidden w-72 bg-[radial-gradient(circle_at_center,_rgba(251,146,60,0.14),_transparent_65%)] lg:block")
            hero.tag(:div, class: "relative z-10 max-w-4xl") do |content|
              content.tag(:p, "Operator Surface", class: "text-[11px] font-semibold uppercase tracking-[0.34em] text-orange-200/75")
              content.tag(:h1, "Companion Dashboard", class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl")
              content.tag(:p,
                          "Stack-level overview for reminders, Telegram bindings, notification preferences, notes, and execution-store state across companion apps.",
                          class: "mt-4 max-w-3xl text-base leading-7 text-stone-300 sm:text-lg")
              content.tag(:div, class: "mt-5 flex flex-wrap gap-x-4 gap-y-2 font-mono text-xs text-stone-400") do |meta|
                meta.tag(:span, "Generated #{snapshot.fetch(:generated_at)}")
                meta.tag(:span, "apps=#{snapshot.dig(:stack, :apps).join(", ")}")
                meta.tag(:span, "default=#{snapshot.dig(:stack, :default_app)}")
              end
            end
          end
        end

        def render_metric_cards(view)
          counts = snapshot.fetch(:counts)

          view.tag(:section, class: "grid gap-4 sm:grid-cols-2 xl:grid-cols-4") do |section|
            section.component(MetricCard, label: "Notes", value: counts[:notes], hint: "stored context")
            section.component(MetricCard, label: "Active Reminders", value: counts[:active_reminders], hint: "pending follow-ups")
            section.component(MetricCard, label: "Telegram Chats", value: counts[:telegram_bindings], hint: "linked users")
            section.component(MetricCard, label: "Preferences", value: counts[:notification_preferences], hint: "persisted channel state")
          end
        end

        def render_panels(view)
          view.tag(:section, class: "grid gap-5 xl:grid-cols-2") do |section|
            section.component(panel("Create Reminder", subtitle: "Quick operator flow for scheduling reminders.") do |panel_view|
              create_reminder_form(panel_view)
            end)
            section.component(panel("Reminders", subtitle: "Recent active reminders and quick completion actions.") do |panel_view|
              reminders_markup(panel_view, snapshot.fetch(:reminders))
            end)
            section.component(panel("Telegram", subtitle: "Linked chats, preferred routing, and notification toggles.") do |panel_view|
              telegram_markup(panel_view, snapshot.fetch(:telegram), snapshot.fetch(:notification_preferences))
            end)
            section.component(panel("Notes", subtitle: "Small durable memory surface for the companion stack.") do |panel_view|
              notes_markup(panel_view, snapshot.fetch(:notes))
            end)
            section.component(panel("Execution Stores", subtitle: "Execution persistence across companion apps.") do |panel_view|
              execution_stores_markup(panel_view, snapshot.fetch(:execution_stores))
            end)
          end
        end

        def render_footer(view)
          view.tag(:p, class: "rounded-3xl border border-white/10 bg-white/5 px-5 py-4 font-mono text-xs text-stone-300") do |paragraph|
            paragraph.text("JSON API: ")
            paragraph.tag(:a,
                          href: "/api/overview",
                          class: "text-orange-200 underline decoration-orange-200/30 underline-offset-4") do |anchor|
              anchor.tag(:code, "/api/overview")
            end
            paragraph.text(" · ")
            paragraph.tag(:a,
                          "Open schema demo",
                          href: "/views/training-checkin",
                          class: "text-orange-200 underline decoration-orange-200/30 underline-offset-4")
          end
        end

        def panel(title, subtitle: nil, &block)
          Igniter::Plugins::View::Tailwind::UI::Panel.new(
            title: title,
            subtitle: subtitle,
            wrapper_class: "rounded-[28px] border border-white/10 bg-[#2a1914]/90 p-6 shadow-2xl shadow-black/20 backdrop-blur",
            subtitle_class: "text-sm leading-6 text-stone-400",
            &block
          )
        end

        def create_reminder_form(view)
          view.form(action: "/reminders", class: "grid gap-3") do |form|
            form.label("reminder-task", "Task", class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300")
            form.input("task",
                       id: "reminder-task",
                       placeholder: "Pay rent",
                       required: true,
                       class: input_classes)

            form.label("reminder-timing", "When", class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300")
            form.input("timing",
                       id: "reminder-timing",
                       placeholder: "Tomorrow at 09:00",
                       required: true,
                       class: input_classes)

            form.label("reminder-channel", "Channel", class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300")
            form.select("channel",
                        id: "reminder-channel",
                        options: [["No channel", ""], ["Telegram", "telegram"]],
                        class: input_classes)

            form.label("reminder-chat-id", "Telegram chat", class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300")
            form.select("chat_id",
                        id: "reminder-chat-id",
                        options: telegram_chat_options,
                        class: input_classes)

            form.label("reminder-notifications", class: "flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-stone-200") do |label|
              label.raw('<input type="checkbox" name="notifications_enabled" value="1" checked class="h-4 w-4 rounded border-white/20 bg-stone-950 text-orange-300">')
              label.text("Enable Telegram notifications")
            end

            form.submit("Create Reminder",
                        class: primary_button_classes)
          end
        end

        def reminders_markup(view, reminders)
          return view.tag(:p, "No active reminders yet.", class: empty_state_classes) if reminders.empty?

          view.tag(:ul, class: list_classes) do |list|
            reminders.last(8).reverse.each do |reminder|
              list.tag(:li, class: list_item_classes) do |item|
                item.tag(:strong, reminder["task"], class: "font-semibold text-white")
                item.tag(:span, reminder["timing"], class: pill_classes)
                item.tag(:div, class: "mt-3") do |row|
                  row.tag(:code, "channel=#{reminder["channel"] || "none"} chat=#{reminder["chat_id"] || "-"}", class: code_classes)
                end
                item.button("Mark Completed",
                            class: primary_button_classes,
                            onclick: "postJson('/api/reminders/#{reminder["id"]}/complete', {})")
              end
            end
          end
        end

        def telegram_markup(view, telegram, preferences)
          bindings = Array(telegram[:bindings])

          labelled_code(view, "Preferred chat:", telegram[:preferred_chat_id] || "-")
          labelled_code(view, "Latest chat:", telegram[:latest_chat_id] || "-")

          return view.tag(:p, "No linked Telegram chats yet.", class: empty_state_classes) if bindings.empty?

          view.tag(:ul, class: list_classes) do |list|
            bindings.first(6).each do |binding|
              name = binding["username"] || binding["first_name"] || binding["title"] || binding["chat_id"]
              chat_id = binding["chat_id"]
              enabled = telegram_notifications_enabled?(preferences, chat_id)
              action_label = enabled ? "Disable Notifications" : "Enable Notifications"
              action_value = enabled ? "false" : "true"
              button_class = enabled ? secondary_button_classes : primary_button_classes

              list.tag(:li, class: list_item_classes) do |item|
                item.tag(:strong, name, class: "font-semibold text-white")
                item.tag(:div, class: "mt-3") do |row|
                  row.tag(:code, "chat_id=#{chat_id} type=#{binding["type"] || "unknown"}", class: code_classes)
                end
                item.tag(:span, "notifications=#{enabled}", class: "#{pill_classes} mt-3")
                item.button(action_label,
                            class: button_class,
                            onclick: "postJson('/api/telegram/preferences', { chat_id: #{js_string(chat_id)}, enabled: #{action_value} })")
              end
            end
          end
        end

        def notes_markup(view, notes)
          return view.tag(:p, "No notes saved yet.", class: empty_state_classes) if notes.empty?

          view.tag(:ul, class: list_classes) do |list|
            notes.first(8).each do |key, value|
              list.tag(:li, class: list_item_classes) do |item|
                item.tag(:strong, key, class: "font-semibold text-white")
                item.tag(:div, value, class: "mt-2 text-sm leading-6 text-stone-300")
              end
            end
          end
        end

        def execution_stores_markup(view, execution_stores)
          view.tag(:ul, class: list_classes) do |list|
            execution_stores.each do |app_name, summary|
              list.tag(:li, class: list_item_classes) do |item|
                item.tag(:strong, app_name, class: "font-semibold text-white")
                item.tag(:div, class: "mt-3") do |row|
                  row.tag(:code, summary[:class], class: code_classes)
                end
                item.tag(:div, "total=#{summary[:total]} pending=#{summary[:pending]}", class: "mt-2 text-sm text-stone-300")
              end
            end
          end
        end

        def labelled_code(view, label, value)
          view.tag(:p, class: "mb-3 flex flex-wrap items-center gap-2 text-sm text-stone-300") do |paragraph|
            paragraph.tag(:strong, label, class: "font-semibold text-white")
            paragraph.tag(:code, value, class: code_classes)
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

        def input_classes
          "w-full rounded-2xl border border-white/10 bg-[#160f0d] px-4 py-3 text-sm text-white placeholder:text-stone-500 focus:border-orange-300/50 focus:outline-none"
        end

        def primary_button_classes
          "mt-3 inline-flex rounded-full border border-orange-300/20 bg-orange-300/90 px-5 py-3 text-sm font-semibold uppercase tracking-[0.18em] text-stone-950 transition hover:bg-orange-200"
        end

        def secondary_button_classes
          "mt-3 inline-flex rounded-full border border-white/10 bg-white/10 px-5 py-3 text-sm font-semibold uppercase tracking-[0.18em] text-stone-100 transition hover:bg-white/15"
        end

        def pill_classes
          "inline-flex rounded-full border border-orange-300/20 bg-orange-300/10 px-3 py-1 text-xs font-mono uppercase tracking-[0.18em] text-orange-100"
        end

        def list_classes
          "space-y-4"
        end

        def list_item_classes
          "rounded-3xl border border-white/10 bg-white/5 p-4"
        end

        def code_classes
          "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-orange-100"
        end

        def empty_state_classes
          "text-sm leading-6 text-stone-400"
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
