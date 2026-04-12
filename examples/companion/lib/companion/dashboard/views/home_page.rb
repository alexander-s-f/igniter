# frozen_string_literal: true

require "cgi"

module Companion
  module Dashboard
    module Views
      module HomePage
        module_function

        def render(snapshot) # rubocop:disable Metrics/MethodLength
          counts = snapshot.fetch(:counts)
          <<~HTML
            <!DOCTYPE html>
            <html lang="en">
              <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Companion Dashboard</title>
                <style>
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
                </style>
                <script>
                  async function postJson(path, payload) {
                    await fetch(path, {
                      method: "POST",
                      headers: { "Content-Type": "application/json" },
                      body: JSON.stringify(payload || {})
                    });
                    window.location.reload();
                  }
                </script>
              </head>
              <body>
                <main class="shell">
                  <section class="hero">
                    <h1>Companion Dashboard</h1>
                    <p>
                      Workspace-level overview for reminders, Telegram bindings, notification preferences,
                      notes, and execution-store state across companion apps.
                    </p>
                    <div class="meta">
                      Generated #{h(snapshot.fetch(:generated_at))} · apps=#{h(snapshot.dig(:workspace, :apps).join(", "))} ·
                      default=#{h(snapshot.dig(:workspace, :default_app))}
                    </div>
                  </section>

                  <section class="cards">
                    #{metric_card("Notes", counts[:notes])}
                    #{metric_card("Active Reminders", counts[:active_reminders])}
                    #{metric_card("Telegram Chats", counts[:telegram_bindings])}
                    #{metric_card("Preferences", counts[:notification_preferences])}
                  </section>

                  <section class="grid">
                    <article class="panel">
                      <h2>Reminders</h2>
                      #{reminders_markup(snapshot.fetch(:reminders))}
                    </article>
                    <article class="panel">
                      <h2>Telegram</h2>
                      #{telegram_markup(snapshot.fetch(:telegram), snapshot.fetch(:notification_preferences))}
                    </article>
                    <article class="panel">
                      <h2>Notes</h2>
                      #{notes_markup(snapshot.fetch(:notes))}
                    </article>
                    <article class="panel">
                      <h2>Execution Stores</h2>
                      #{execution_stores_markup(snapshot.fetch(:execution_stores))}
                    </article>
                  </section>

                  <p class="meta">
                    JSON API: <a href="/api/overview"><code>/api/overview</code></a>
                  </p>
                </main>
              </body>
            </html>
          HTML
        end

        def metric_card(label, value)
          <<~HTML
            <div class="card">
              <div class="label">#{h(label)}</div>
              <div class="value">#{h(value)}</div>
            </div>
          HTML
        end

        def reminders_markup(reminders)
          return "<p>No active reminders yet.</p>" if reminders.empty?

          items = reminders.last(8).reverse.map do |reminder|
            "<li><strong>#{h(reminder["task"])}</strong> <span class=\"pill\">#{h(reminder["timing"])}</span>" \
              "<br><code>channel=#{h(reminder["channel"] || "none")} chat=#{h(reminder["chat_id"] || "-")}</code>" \
              "<br><button onclick=\"postJson('/api/reminders/#{h(reminder["id"])}/complete', {})\">Mark Completed</button></li>"
          end
          "<ul>#{items.join}</ul>"
        end

        def telegram_markup(telegram, preferences)
          bindings = Array(telegram[:bindings])
          parts = []
          parts << "<p><strong>Preferred chat:</strong> <code>#{h(telegram[:preferred_chat_id] || "-")}</code></p>"
          parts << "<p><strong>Latest chat:</strong> <code>#{h(telegram[:latest_chat_id] || "-")}</code></p>"

          if bindings.empty?
            parts << "<p>No linked Telegram chats yet.</p>"
          else
            items = bindings.first(6).map do |binding|
              name = binding["username"] || binding["first_name"] || binding["title"] || binding["chat_id"]
              chat_id = binding["chat_id"]
              enabled = telegram_notifications_enabled?(preferences, chat_id)
              action_label = enabled ? "Disable Notifications" : "Enable Notifications"
              action_value = enabled ? "false" : "true"
              button_class = enabled ? "secondary" : ""

              "<li><strong>#{h(name)}</strong><br><code>chat_id=#{h(chat_id)} type=#{h(binding["type"] || "unknown")}</code>" \
                "<br><span class=\"pill\">notifications=#{h(enabled)}</span>" \
                "<br><button class=\"#{button_class}\" " \
                "onclick=\"postJson('/api/telegram/preferences', { chat_id: '#{h(chat_id)}', enabled: #{action_value} })\">" \
                "#{h(action_label)}</button></li>"
            end
            parts << "<ul>#{items.join}</ul>"
          end

          parts.join
        end

        def notes_markup(notes)
          return "<p>No notes saved yet.</p>" if notes.empty?

          items = notes.first(8).map do |key, value|
            "<li><strong>#{h(key)}</strong><br>#{h(value)}</li>"
          end
          "<ul>#{items.join}</ul>"
        end

        def execution_stores_markup(execution_stores)
          items = execution_stores.map do |app_name, summary|
            "<li><strong>#{h(app_name)}</strong><br><code>#{h(summary[:class])}</code>" \
              "<br>total=#{h(summary[:total])} pending=#{h(summary[:pending])}</li>"
          end
          "<ul>#{items.join}</ul>"
        end

        def h(value)
          CGI.escape_html(value.to_s)
        end

        def telegram_notifications_enabled?(preferences, chat_id)
          prefs = preferences["telegram:#{chat_id}"]
          return true if prefs.nil?

          prefs["telegram_enabled"] != false
        end
      end
    end
  end
end
