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
            section.component(MetricCard, label: "View Schemas", value: counts[:view_schemas], hint: "authoring surfaces")
            section.component(MetricCard, label: "Submissions", value: counts[:view_submissions], hint: "runtime feedback loop")
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
            section.component(panel("View Schemas", subtitle: "Catalog browser and lightweight authoring surface for persisted schemas.") do |panel_view|
              view_schemas_markup(panel_view, snapshot.fetch(:view_schemas))
            end)
            section.component(panel("Recent Submissions", subtitle: "Latest schema runtime outputs flowing back into the operator surface.") do |panel_view|
              view_submissions_markup(panel_view, snapshot.fetch(:view_submissions))
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
                      "Open training check-in",
                      href: "/views/training-checkin",
                      class: tailwind_tokens.underline_link(theme: :orange))
              bar.tag(:a,
                      "Open weekly review",
                      href: "/views/weekly-review",
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

        def view_schemas_markup(view, schemas)
          view.tag(:div, class: "space-y-4") do |container|
            container.tag(:p,
                          "Browse seeded schemas, open their rendered pages, fetch raw JSON, or draft create/patch payloads against the catalog API without leaving the dashboard.",
                          class: ui_theme.body_text_class)
            container.component(
              Igniter::Plugins::View::Tailwind::UI::ActionBar.new(class_name: "flex flex-wrap gap-2") do |actions|
                actions.tag(:a,
                            "Catalog JSON",
                            href: "/api/views",
                            class: tailwind_tokens.action(variant: :soft, theme: :orange, size: :sm))
                actions.tag(:a,
                            "Open weekly review",
                            href: "/views/weekly-review",
                            class: tailwind_tokens.action(variant: :ghost, theme: :orange, size: :sm))
              end
            )
          end

          view.tag(:div, class: "mt-4 grid gap-5 lg:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)]") do |grid|
            grid.tag(:div) do |column|
              if schemas.empty?
                column.tag(:p, "No view schemas stored yet.", class: empty_state_classes)
              else
                column.tag(:ul, class: list_classes) do |list|
                  schemas.each do |schema|
                    list.tag(:li, class: list_item_classes) do |item|
                      item.tag(:strong, schema.fetch(:title), class: ui_theme.item_title_class)
                      item.tag(:div, schema.fetch(:id), class: ui_theme.muted_text_class(extra: "mt-2"))
                      item.tag(:div,
                               "version=#{schema.fetch(:version)} · actions=#{schema.fetch(:action_ids).join(", ")}",
                               class: ui_theme.muted_text_class(extra: "mt-2"))
                      item.component(
                        Igniter::Plugins::View::Tailwind::UI::ActionBar.new(
                          class_name: "mt-3 flex flex-wrap gap-2"
                        ) do |actions|
                          actions.tag(:a,
                                      "Open view",
                                      href: schema.fetch(:view_path),
                                      class: tailwind_tokens.action(variant: :soft, theme: :orange, size: :sm))
                          actions.tag(:a,
                                      "JSON",
                                      href: schema.fetch(:api_path),
                                      class: tailwind_tokens.action(variant: :ghost, theme: :orange, size: :sm))
                          actions.tag(:button,
                                      "Load JSON",
                                      type: "button",
                                      class: tailwind_tokens.action(variant: :ghost, theme: :orange, size: :sm),
                                      onclick: "loadSchemaIntoEditor(#{js_string(schema.fetch(:id))})")
                          actions.tag(:button,
                                      "Clone",
                                      type: "button",
                                      class: tailwind_tokens.action(variant: :ghost, theme: :orange, size: :sm),
                                      onclick: "cloneSchemaIntoEditor(#{js_string(schema.fetch(:id))})")
                        end
                      )
                    end
                  end
                end
              end
            end

            grid.tag(:div, class: "space-y-4") do |column|
              render_schema_create_form(column)
              render_schema_patch_form(column)
            end
          end
        end

        def view_submissions_markup(view, submissions)
          view.tag(:div, class: "space-y-4") do |container|
            container.tag(:p,
                          "Recent submissions make the authoring loop concrete: define a schema, run it, then inspect which action fired and how it was processed.",
                          class: ui_theme.body_text_class)
            container.component(
              ui_theme.timeline_list(
                items: submissions.map { |submission| submission_timeline_item(submission) },
                empty_message: "No schema submissions yet. Open a seeded view and submit it once to populate this timeline.",
                title_link_class: tailwind_tokens.underline_link(theme: :orange),
                action_link_class: tailwind_tokens.action(variant: :ghost, theme: :orange, size: :sm)
              )
            )
          end
        end

        def render_schema_create_form(view)
          view.component(
            ui_theme.form_section(
              title: "Create Schema",
              subtitle: "Post a full schema payload directly to the catalog API.",
              action: "#",
              wrapper_class: "#{ui_theme.surface(:schema_card_class)} p-5"
            ) do |form|
              form.label("schema-create-id", "Suggested id", class: ui_theme.field_label_class)
              form.input("schema-create-id",
                         id: "schema-create-id",
                         value: "weekly-review-copy",
                         class: input_classes)

              form.label("schema-create-json", "Schema JSON", class: ui_theme.field_label_class)
              form.textarea("schema-create-json",
                            id: "schema-create-json",
                            rows: 16,
                            value: default_schema_payload,
                            class: ui_theme.input_class(extra: "min-h-48 font-mono text-xs"))

              form.view.tag(:p,
                            "Create posts the full payload to /api/views and then reloads the dashboard.",
                            class: ui_theme.muted_text_class)
              form.button("Create Schema",
                          type: "button",
                          class: primary_button_classes,
                          onclick: "createSchemaFromEditor()")
            end
          )
        end

        def render_schema_patch_form(view)
          view.component(
            ui_theme.form_section(
              title: "Patch Schema",
              subtitle: "Load an existing schema, edit a JSON patch, then apply it through the catalog API.",
              action: "#",
              wrapper_class: "#{ui_theme.surface(:schema_card_class)} p-5"
            ) do |form|
              form.label("schema-patch-id", "Schema id", class: ui_theme.field_label_class)
              form.input("schema-patch-id",
                         id: "schema-patch-id",
                         placeholder: "training-checkin",
                         class: input_classes)

              form.label("schema-patch-json", "Patch JSON", class: ui_theme.field_label_class)
              form.textarea("schema-patch-json",
                            id: "schema-patch-json",
                            rows: 12,
                            value: "{\n  \"title\": \"Weekly Review (Edited)\"\n}",
                            class: ui_theme.input_class(extra: "min-h-40 font-mono text-xs"))

              form.view.tag(:p,
                            "Delete removes the currently selected schema id. Clone loads an existing schema into the create editor with a copied id.",
                            class: ui_theme.muted_text_class)
              form.view.component(
                Igniter::Plugins::View::Tailwind::UI::ActionBar.new(class_name: "mt-3 flex flex-wrap gap-2") do |actions|
                  actions.tag(:button,
                              "Apply Patch",
                              type: "button",
                              class: tailwind_tokens.action(variant: :primary, theme: :orange, size: :sm),
                              onclick: "patchSchemaFromEditor()")
                  actions.tag(:button,
                              "Delete Schema",
                              type: "button",
                              class: tailwind_tokens.action(variant: :ghost, theme: :orange, size: :sm),
                              onclick: "deleteSchemaFromEditor()")
                end
              )
            end
          )
        end

        def labelled_code(view, label, value)
          view.tag(:p, class: ui_theme.body_text_class(extra: "mb-3 flex flex-wrap items-center gap-2")) do |paragraph|
            paragraph.tag(:strong, label, class: ui_theme.item_title_class)
            paragraph.tag(:code, value, class: code_classes)
          end
        end

        def submission_timeline_item(submission)
          created_at = submission.fetch(:created_at)
          processed_at = submission[:processed_at] || "pending"
          processing_type = submission[:processing_type] || "pending"

          {
            title: submission.fetch(:view_title),
            href: submission.fetch(:view_path),
            body: "action=#{submission.fetch(:action_id)} · status=#{submission.fetch(:status)} · type=#{processing_type}",
            meta: "submission=#{submission.fetch(:id)} · schema_v=#{submission.fetch(:schema_version)} · created=#{created_at} · processed=#{processed_at}",
            action_label: "Schema JSON",
            action_href: submission.fetch(:api_path)
          }
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

        def default_schema_payload
          JSON.pretty_generate(
            {
              id: "weekly-review-copy",
              version: 1,
              kind: "page",
              title: "Weekly Review Copy",
              actions: {
                save_review: {
                  method: "post",
                  path: "/views/weekly-review-copy/submissions"
                }
              },
              layout: {
                type: "stack",
                children: [
                  { type: "heading", level: 1, text: "Weekly Review Copy" },
                  { type: "notice", message: "Adjust this draft, then create it.", tone: "notice" },
                  {
                    type: "form",
                    action: "save_review",
                    children: [
                      {
                        type: "fieldset",
                        legend: "Signals",
                        description: "Start from one strong signal.",
                        children: [
                          { type: "input", name: "focus", label: "Focus", required: true }
                        ]
                      },
                      {
                        type: "actions",
                        children: [
                          { type: "submit", label: "Save" }
                        ]
                      }
                    ]
                  }
                ]
              }
            }
          )
        end

        def script_source
          <<~JS
            async function requestJson(path, options) {
              const response = await fetch(path, options || {});
              const text = await response.text();
              let parsed = {};

              try {
                parsed = text ? JSON.parse(text) : {};
              } catch (error) {
                parsed = { ok: false, error: text || "Invalid JSON response" };
              }

              if (!response.ok) {
                throw new Error(parsed.error || "Request failed");
              }

              return parsed;
            }

            async function postJson(path, payload) {
              await fetch(path, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload || {})
              });
              window.location.reload();
            }

            async function loadSchemaIntoEditor(schemaId) {
              const result = await requestJson(`/api/views/${encodeURIComponent(schemaId)}`);
              const payload = result.schema || {};
              document.getElementById("schema-patch-id").value = payload.id || schemaId;
              document.getElementById("schema-create-id").value = `${payload.id || schemaId}-copy`;
              document.getElementById("schema-create-json").value = JSON.stringify(payload, null, 2);
              document.getElementById("schema-patch-json").value = JSON.stringify({
                title: `${payload.title || schemaId} (Edited)`
              }, null, 2);
            }

            async function cloneSchemaIntoEditor(schemaId) {
              const result = await requestJson(`/api/views/${encodeURIComponent(schemaId)}`);
              const payload = result.schema || {};
              payload.id = `${payload.id || schemaId}-copy`;
              payload.title = `${payload.title || schemaId} Copy`;

              if (payload.actions) {
                Object.entries(payload.actions).forEach(([actionId, action]) => {
                  if (action && action.path) {
                    action.path = action.path.replace(`/views/${schemaId}/`, `/views/${payload.id}/`);
                  }
                });
              }

              document.getElementById("schema-create-id").value = payload.id;
              document.getElementById("schema-create-json").value = JSON.stringify(payload, null, 2);
            }

            async function createSchemaFromEditor() {
              const raw = document.getElementById("schema-create-json").value;
              const payload = JSON.parse(raw);
              const suggestedId = document.getElementById("schema-create-id").value.trim();
              if (suggestedId.length > 0) {
                payload.id = suggestedId;
              }

              await requestJson("/api/views", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
              });
              window.location.reload();
            }

            async function patchSchemaFromEditor() {
              const schemaId = document.getElementById("schema-patch-id").value.trim();
              const patch = JSON.parse(document.getElementById("schema-patch-json").value);
              await requestJson(`/api/views/${encodeURIComponent(schemaId)}`, {
                method: "PATCH",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(patch)
              });
              window.location.reload();
            }

            async function deleteSchemaFromEditor() {
              const schemaId = document.getElementById("schema-patch-id").value.trim();
              await requestJson(`/api/views/${encodeURIComponent(schemaId)}`, {
                method: "DELETE"
              });
              window.location.reload();
            }
          JS
        end
      end
    end
  end
end
