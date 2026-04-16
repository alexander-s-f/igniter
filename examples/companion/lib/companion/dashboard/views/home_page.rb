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
            theme: :companion,
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

        def render_head(head)
          head.tag(:script, type: "text/javascript") do |script|
            script.raw(script_source)
          end
        end

        def render_hero(view)
          hero_theme = ui_theme.hero(:dashboard)

          view.tag(:section,
                   class: hero_theme.fetch(:wrapper_class)) do |hero|
            hero.tag(:div, class: hero_theme.fetch(:glow_class))
            hero.tag(:div, class: hero_theme.fetch(:content_class)) do |content|
              content.tag(:p, "Operator Surface", class: hero_theme.fetch(:eyebrow_class))
              content.tag(:h1, "Companion Dashboard", class: hero_theme.fetch(:title_class))
              content.tag(:p,
                          "Stack-level overview for reminders, Telegram bindings, notification preferences, notes, and execution-store state across companion apps.",
                          class: hero_theme.fetch(:body_class))
              content.tag(:div, class: hero_theme.fetch(:meta_class)) do |meta|
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
            section.component(create_reminder_form_section)
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
          view.component(
            Igniter::Plugins::View::Tailwind::UI::ActionBar.new(
              tag: :section,
              class_name: ui_theme.surface(:footer_bar_class)
            ) do |bar|
              bar.tag(:span, "JSON API:")
              bar.tag(:a,
                      href: "/api/overview",
                      class: tailwind_tokens.underline_link(theme: :orange)) do |anchor|
                anchor.tag(:code, "/api/overview")
              end
              bar.tag(:a,
                      "Open schema demo",
                      href: "/views/training-checkin",
                      class: tailwind_tokens.underline_link(theme: :orange))
            end
          )
        end

        def panel(title, subtitle: nil, &block)
          ui_theme.panel(title: title, subtitle: subtitle, &block)
        end

        def create_reminder_form_section
          ui_theme.form_section(
            title: "Create Reminder",
            subtitle: "Quick operator flow for scheduling reminders.",
            action: "/reminders"
          ) do |form|
            form.label("reminder-task", "Task", class: ui_theme.field_label_class)
            form.input("task",
                       id: "reminder-task",
                       placeholder: "Pay rent",
                       required: true,
                        class: input_classes)

            form.label("reminder-timing", "When", class: ui_theme.field_label_class)
            form.input("timing",
                       id: "reminder-timing",
                       placeholder: "Tomorrow at 09:00",
                       required: true,
                       class: input_classes)

            form.label("reminder-channel", "Channel", class: ui_theme.field_label_class)
            form.select("channel",
                        id: "reminder-channel",
                        options: [["No channel", ""], ["Telegram", "telegram"]],
                        class: input_classes)

            form.label("reminder-chat-id", "Telegram chat", class: ui_theme.field_label_class)
            form.select("chat_id",
                        id: "reminder-chat-id",
                        options: telegram_chat_options,
                        class: input_classes)

            form.label("reminder-notifications", class: ui_theme.checkbox_label_class) do |label|
              label.raw(%(<input type="checkbox" name="notifications_enabled" value="1" checked class="#{ui_theme.checkbox_class}">))
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
                item.tag(:strong, reminder["task"], class: ui_theme.item_title_class)
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
                item.tag(:strong, name, class: ui_theme.item_title_class)
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
                item.tag(:strong, key, class: ui_theme.item_title_class)
                item.tag(:div, value, class: ui_theme.body_text_class(extra: "mt-2"))
              end
            end
          end
        end

        def execution_stores_markup(view, execution_stores)
          view.component(
            ui_theme.resource_list(
              items: execution_stores.map do |app_name, summary|
                {
                  title: app_name,
                  meta: "total=#{summary[:total]} pending=#{summary[:pending]}",
                  code: summary[:class]
                }
              end
            )
          )
        end

        def labelled_code(view, label, value)
          view.tag(:p, class: ui_theme.body_text_class(extra: "mb-3 flex flex-wrap items-center gap-2")) do |paragraph|
            paragraph.tag(:strong, label, class: ui_theme.item_title_class)
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
          ui_theme.input_class
        end

        def primary_button_classes
          tailwind_tokens.action(variant: :primary, theme: :orange, extra: "mt-3")
        end

        def secondary_button_classes
          tailwind_tokens.action(variant: :secondary, extra: "mt-3")
        end

        def pill_classes
          tailwind_tokens.badge(theme: :orange)
        end

        def tailwind_tokens
          Igniter::Plugins::View::Tailwind::UI::Tokens
        end

        def ui_theme
          Igniter::Plugins::View::Tailwind::UI::Theme.fetch(:companion)
        end

        def list_classes
          ui_theme.list_class
        end

        def list_item_classes
          ui_theme.list_item_class
        end

        def code_classes
          ui_theme.code_class
        end

        def empty_state_classes
          ui_theme.empty_state_class
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
