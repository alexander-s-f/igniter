# frozen_string_literal: true

require "igniter/plugins/view"

module Companion
  module Dashboard
    module Views
      class HomePage < Igniter::Plugins::View::Page
        def self.render(snapshot:, error_message: nil, form_values: {}, base_path: "")
          new(
            snapshot: snapshot,
            error_message: error_message,
            form_values: form_values,
            base_path: base_path
          ).render
        end

        def initialize(snapshot:, error_message:, form_values:, base_path:)
          @snapshot = snapshot
          @error_message = error_message
          @form_values = form_values
          @base_path = base_path
        end

        def call(view)
          render_document(view, title: "Companion Dashboard") do |body|
            body.tag(:main, class: "shell") do |main|
              render_hero(main)
              render_metrics(main)
              render_node(main)
              render_self_heal(main)
              render_notes(main)
              render_nodes(main)
            end
          end
        end

        private

        attr_reader :snapshot
        attr_reader :error_message
        attr_reader :form_values
        attr_reader :base_path

        def yield_head(head)
          head.tag(:style) { |style| style.raw(stylesheet) }
        end

        def render_hero(view)
          view.tag(:section, class: "hero") do |hero|
            hero.tag(:h1, "Companion Dashboard")
            hero.tag(:p, "Fresh proving ground for the rebuilt Igniter stack model.")
            hero.tag(:div, class: "meta") do |meta|
              meta.text("generated=#{snapshot.fetch(:generated_at)} · ")
              meta.text("root=#{snapshot.dig(:stack, :root_app)} · ")
              meta.text("node=#{snapshot.dig(:stack, :default_node)}")
            end
            hero.tag(:p, class: "links") do |links|
              links.tag(:a, "Overview API", href: route("/api/overview"))
              links.text(" · ")
              links.tag(:a, "Main status", href: "/v1/home/status")
            end
          end
        end

        def render_metrics(view)
          counts = snapshot.fetch(:counts)

          view.tag(:section, class: "metrics") do |section|
            section.tag(:article, class: "metric-card") do |card|
              card.tag(:span, "Apps", class: "metric-label")
              card.tag(:strong, snapshot.dig(:stack, :apps).size.to_s, class: "metric-value")
            end

            section.tag(:article, class: "metric-card") do |card|
              card.tag(:span, "Nodes", class: "metric-label")
              card.tag(:strong, counts.fetch(:nodes).to_s, class: "metric-value")
            end

            section.tag(:article, class: "metric-card") do |card|
              card.tag(:span, "Notes", class: "metric-label")
              card.tag(:strong, counts.fetch(:notes).to_s, class: "metric-value")
            end

            section.tag(:article, class: "metric-card") do |card|
              card.tag(:span, "Peers", class: "metric-label")
              card.tag(:strong, counts.fetch(:discovered_peers).to_s, class: "metric-value")
            end
          end
        end

        def render_node(view)
          node = snapshot.fetch(:current_node)
          capabilities = node.dig(:capabilities, :effective)
          mocked = node.dig(:capabilities, :mocked)
          seeds = node.fetch(:seeds)
          peers = snapshot.fetch(:discovered_peers)

          view.tag(:section, class: "notes-panel") do |section|
            section.tag(:div, class: "panel-head") do |head|
              head.tag(:h2, "Current Node")
              head.tag(:p, "Capability envelope for this local Companion instance.")
            end

            section.tag(:p, "name=#{node.dig(:node, :name)} role=#{node.dig(:node, :role)} profile=#{node.dig(:node, :profile)}")
            section.tag(:p, "url=#{node.dig(:node, :url)}")
            section.tag(:p, "effective_capabilities=#{capabilities.join(", ")}")
            section.tag(:p, "mocked_capabilities=#{mocked.empty? ? "none" : mocked.join(", ")}")
            section.tag(:p, "tags=#{node.fetch(:tags).join(", ")}")
            section.tag(:p, "seeds=#{seeds.empty? ? "none" : seeds.join(", ")}")
            section.tag(:p, "mounted_apps=#{snapshot.dig(:stack, :apps).join(", ")} mounts=#{inline_counts(snapshot.dig(:stack, :mounts))}")

            if peers.empty?
              section.tag(:p, "No discovered peers yet.", class: "empty-state")
            else
              section.tag(:ul, class: "notes-list") do |list|
                peers.each do |peer|
                  list.tag(:li) do |item|
                    item.tag(:strong, peer.fetch(:name))
                    item.tag(:div, class: "note-meta") do |meta|
                      meta.text("caps=#{peer.fetch(:capabilities).join(", ")} · tags=#{peer.fetch(:tags).join(", ")} · url=#{peer.fetch(:url)}")
                    end
                  end
                end
              end
            end
          end
        end

        def render_notes(view)
          notes = snapshot.fetch(:notes)

          view.tag(:section, class: "notes-panel") do |section|
            section.tag(:div, class: "panel-head") do |head|
              head.tag(:h2, "Shared Notes")
              head.tag(:p, "Simple cross-app proving slice shared by main and dashboard.")
            end

            if error_message
              section.tag(:p, error_message, class: "error-banner")
            end

            section.form(action: route("/notes"), method: "post", class: "stacked-form") do |form|
              form.label("note-text", "Add note")
              form.textarea("text",
                            id: "note-text",
                            rows: 3,
                            placeholder: "Capture a lab observation or operator todo",
                            value: form_values.fetch("text", ""))
              form.submit("Save Note")
            end

            if notes.empty?
              section.tag(:p, "No notes saved yet.", class: "empty-state")
            else
              section.tag(:ul, class: "notes-list") do |list|
                notes.each do |note|
                  list.tag(:li) do |item|
                    item.tag(:strong, note.fetch("text"))
                    item.tag(:div, class: "note-meta") do |meta|
                      meta.text("source=#{note.fetch("source")} · created=#{note.fetch("created_at")}")
                    end
                  end
                end
              end
            end
          end
        end

        def render_self_heal(view)
          routing = snapshot.fetch(:routing)
          tick = routing[:latest_self_heal_tick]

          view.tag(:section, class: "notes-panel") do |section|
            section.tag(:div, class: "panel-head") do |head|
              head.tag(:h2, "Self-Heal Demo")
              head.tag(:p, "Trigger a synthetic routing incident and watch automated cluster remediation update the governance crest.")
            end

            section.tag(:div, class: "demo-actions") do |actions|
              actions.form(action: route("/demo/self-heal?scenario=governance_gate"), method: "post", class: "inline-form") do |form|
                form.submit("Trigger Governance Gate")
              end
              actions.form(action: route("/demo/self-heal?scenario=peer_unreachable"), method: "post", class: "inline-form") do |form|
                form.submit("Trigger Peer Repair")
              end
            end

            if routing[:active]
              section.tag(:p, "routing_report=active total=#{routing[:total]} pending=#{routing[:pending]} failed=#{routing[:failed]} plans=#{routing[:plan_count]}")
              section.tag(:p, "incidents=#{inline_counts(routing[:incidents])}")
              section.tag(:p, "plan_actions=#{inline_counts(routing[:plan_actions])}")

              if tick
                section.tag(
                  :p,
                  "last_self_heal=#{tick[:timestamp]} applied=#{tick.dig(:payload, :applied)} blocked=#{tick.dig(:payload, :blocked)} skipped=#{tick.dig(:payload, :skipped)}"
                )
              end

              section.tag(:ul, class: "notes-list") do |list|
                routing[:entries].each do |entry|
                  list.tag(:li) do |item|
                    item.tag(:strong, "#{entry[:node_name]} (#{entry[:status]})")
                    item.tag(:div, entry[:routing_trace_summary], class: "note-meta")
                  end
                end
              end
            else
              section.tag(:p, "No routing incidents published yet.", class: "empty-state")
            end
          end
        end

        def render_nodes(view)
          view.tag(:section, class: "grid") do |grid|
            snapshot.fetch(:nodes).each do |name, node|
              grid.tag(:article, class: "card") do |card|
                card.tag(:h2, name.to_s)
                card.tag(:p, "role=#{node.fetch(:role)}")
                card.tag(:p, "host=#{node.fetch(:host)} port=#{node.fetch(:port)} public=#{node.fetch(:public)}")
                mounts = node.fetch(:mounts)
                unless mounts.empty?
                  card.tag(:p, "mounts=#{mounts.map { |app, mount| "#{app}: #{mount}" }.join(", ")}")
                end
                card.tag(:code, node.fetch(:command))
              end
            end
          end
        end

        def route(path)
          prefix = base_path.to_s
          return path if prefix.empty?

          [prefix, path.sub(%r{\A/}, "")].join("/")
        end

        def inline_counts(counts)
          return "none" if counts.nil? || counts.empty?

          counts.map { |key, value| "#{key}=#{value}" }.join(", ")
        end

        def stylesheet
          <<~CSS
            :root {
              color-scheme: light;
              --bg: #f3efe6;
              --ink: #1f2520;
              --muted: #5a665d;
              --card: #fffaf2;
              --line: #d4c9b8;
              --accent: #2f6c5b;
            }

            * { box-sizing: border-box; }
            body {
              margin: 0;
              font-family: "Iowan Old Style", "Palatino Linotype", serif;
              background:
                radial-gradient(circle at top left, rgba(47, 108, 91, 0.12), transparent 28rem),
                linear-gradient(180deg, #f8f4ec 0%, var(--bg) 100%);
              color: var(--ink);
            }

            .shell {
              width: min(980px, calc(100vw - 32px));
              margin: 0 auto;
              padding: 40px 0 64px;
            }

            .hero, .card, .notes-panel, .metric-card {
              background: var(--card);
              border: 1px solid var(--line);
              border-radius: 20px;
              box-shadow: 0 18px 40px rgba(31, 37, 32, 0.08);
            }

            .hero {
              padding: 28px;
              margin-bottom: 24px;
            }

            .hero h1, .card h2 {
              margin: 0 0 12px;
            }

            .meta, .links, .card p, .card code, .panel-head p, .note-meta, .metric-label {
              color: var(--muted);
            }

            .links a {
              color: var(--accent);
              text-decoration: none;
            }

            .metrics {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
              gap: 16px;
              margin-bottom: 24px;
            }

            .metric-card {
              padding: 20px;
            }

            .metric-label, .metric-value {
              display: block;
            }

            .metric-value {
              margin-top: 8px;
              font-size: 32px;
            }

            .notes-panel {
              padding: 24px;
              margin-bottom: 24px;
            }

            .panel-head h2, .panel-head p {
              margin: 0 0 10px;
            }

            .stacked-form label,
            .stacked-form textarea,
            .stacked-form button,
            .inline-form button {
              display: block;
              width: 100%;
            }

            .stacked-form label {
              margin-bottom: 8px;
            }

            .stacked-form textarea {
              min-height: 96px;
              margin-bottom: 12px;
              padding: 12px;
              border-radius: 12px;
              border: 1px solid var(--line);
              background: #fffdf8;
              font: inherit;
              color: inherit;
            }

            .stacked-form button {
              max-width: 220px;
              padding: 12px 16px;
              border: 0;
              border-radius: 999px;
              background: var(--accent);
              color: white;
              cursor: pointer;
              font: inherit;
            }

            .demo-actions {
              display: flex;
              flex-wrap: wrap;
              gap: 12px;
              margin: 12px 0 18px;
            }

            .inline-form {
              margin: 0;
            }

            .inline-form button {
              max-width: none;
              min-width: 220px;
              padding: 12px 16px;
              border: 0;
              border-radius: 999px;
              background: #214b7a;
              color: white;
              cursor: pointer;
              font: inherit;
            }

            .error-banner {
              margin: 0 0 16px;
              padding: 12px 14px;
              border-radius: 12px;
              background: #fff0e8;
              color: #8a3d1f;
            }

            .empty-state {
              margin: 16px 0 0;
            }

            .notes-list {
              margin: 18px 0 0;
              padding-left: 20px;
            }

            .notes-list li + li {
              margin-top: 12px;
            }

            .note-meta {
              margin-top: 4px;
              font-size: 14px;
            }

            .grid {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
              gap: 16px;
            }

            .card {
              padding: 20px;
            }

            .card code {
              display: block;
              white-space: pre-wrap;
              font-family: "SFMono-Regular", "Menlo", monospace;
              font-size: 12px;
            }
          CSS
        end
      end
    end
  end
end
