# frozen_string_literal: true

require "igniter-frontend"

module Companion
  module Dashboard
    module Views
      class HomePage < Igniter::Frontend::Page
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
          view.raw(
            Igniter::Frontend::Tailwind.render_page(
              title: "Companion Dashboard",
              theme: :companion
            ) do |main|
              render_hero(main)
              render_metrics(main)
              render_panels(main)
            end
          )
        end

        private

        attr_reader :snapshot
        attr_reader :error_message
        attr_reader :form_values
        attr_reader :base_path

        def render_hero(view)
          hero_theme = ui_theme.hero(:dashboard)

          view.tag(:section, class: hero_theme.fetch(:wrapper_class)) do |hero|
            hero.tag(:div, class: hero_theme.fetch(:glow_class))
            hero.tag(:div, class: hero_theme.fetch(:content_class)) do |content|
              content.tag(:p, "Operator Surface", class: hero_theme.fetch(:eyebrow_class))
              content.tag(:h1, "Companion Dashboard", class: hero_theme.fetch(:title_class))
              content.tag(
                :p,
                "Fresh proving ground for the rebuilt Igniter stack model: notes, node topology, routing, and self-heal flow in one live operator surface.",
                class: hero_theme.fetch(:body_class)
              )
              content.tag(:div, class: hero_theme.fetch(:meta_class)) do |meta|
                meta.tag(:span, "generated=#{snapshot.fetch(:generated_at)}")
                meta.tag(:span, "root=#{snapshot.dig(:stack, :root_app)}")
                meta.tag(:span, "node=#{snapshot.dig(:stack, :default_node)}")
              end
              content.component(
                Igniter::Frontend::Tailwind::UI::ActionBar.new(
                  class_name: "mt-6 flex flex-wrap gap-3"
                ) do |actions|
                  actions.tag(
                    :a,
                    "Overview API",
                    href: route("/api/overview"),
                    class: token.action(variant: :primary, theme: :orange, size: :sm)
                  )
                  actions.tag(
                    :a,
                    "Main status",
                    href: "/v1/home/status",
                    class: token.action(variant: :soft, theme: :orange, size: :sm)
                  )
                end
              )
            end
          end
        end

        def render_metrics(view)
          counts = snapshot.fetch(:counts)
          metrics = [
            ["apps", "Apps", snapshot.dig(:stack, :apps).size, "mounted surfaces"],
            ["nodes", "Nodes", counts.fetch(:nodes), "visible topology"],
            ["notes", "Notes", counts.fetch(:notes), "shared operator memory"],
            ["peers", "Peers", counts.fetch(:discovered_peers), "mesh discoveries"]
          ]

          view.tag(:section, class: "grid gap-4 sm:grid-cols-2 xl:grid-cols-4") do |section|
            metrics.each do |id, label, value, hint|
              section.component(
                Igniter::Frontend::Tailwind::UI::MetricCard.new(
                  label: label,
                  value: value,
                  hint: hint,
                  wrapper_attributes: { data: { metric_id: id } },
                  value_attributes: { data: { metric_value: id } }
                )
              )
            end
          end
        end

        def render_panels(view)
          view.tag(:section, class: "grid gap-5 xl:grid-cols-2") do |section|
            section.component(current_node_panel)
            section.component(self_heal_panel)
            section.component(workload_panel)
            section.component(governance_panel)
            section.component(admission_panel)
            section.component(notes_panel)
            section.component(nodes_panel)
          end
        end

        def current_node_panel
          node = snapshot.fetch(:current_node)
          peers = snapshot.fetch(:discovered_peers)

          ui_theme.panel(title: "Current Node", subtitle: "Capability envelope for this local Companion instance.") do |panel|
            panel.component(
              Igniter::Frontend::Tailwind::UI::KeyValueList.new(rows: [
                ["name", node.dig(:node, :name)],
                ["role", node.dig(:node, :role)],
                ["profile", node.dig(:node, :profile)],
                ["url", node.dig(:node, :url)],
                ["effective", node.dig(:capabilities, :effective).join(", ")],
                ["mocked", format_collection(node.dig(:capabilities, :mocked))],
                ["tags", format_collection(node.fetch(:tags))],
                ["seeds", format_collection(node.fetch(:seeds))],
                ["mounted apps", format_collection(snapshot.dig(:stack, :apps))],
                ["mounts", inline_counts(snapshot.dig(:stack, :mounts))]
              ])
            )

            panel.tag(:h3, "Discovered Peers", class: ui_theme.section_heading_class)
            if peers.empty?
              panel.tag(:p, "No discovered peers yet.", class: ui_theme.empty_state_class)
            else
              panel.component(
                ui_theme.resource_list(
                  items: peers.map do |peer|
                    {
                      title: peer.fetch(:name),
                      meta: "caps=#{peer.fetch(:capabilities).join(", ")}",
                      body: "tags=#{peer.fetch(:tags).join(", ")}",
                      code: peer.fetch(:url)
                    }
                  end,
                  compact: true
                )
              )
            end
          end
        end

        def self_heal_panel
          routing = snapshot.fetch(:routing)
          tick    = routing[:latest_self_heal_tick]
          wl_tick = routing[:latest_workload_tick]

          ui_theme.panel(
            title: "Self-Heal Demo",
            subtitle: "Trigger a synthetic routing incident and watch automated remediation update the governance trail."
          ) do |panel|
            panel.component(
              Igniter::Frontend::Tailwind::UI::ActionBar.new(
                class_name: "flex flex-wrap gap-3"
              ) do |actions|
                actions.form(action: route("/demo/self-heal?scenario=governance_gate"), method: "post") do |form|
                  form.submit("Trigger Governance Gate", class: token.action(variant: :primary, theme: :orange, size: :sm))
                end
                actions.form(action: route("/demo/self-heal?scenario=peer_unreachable"), method: "post") do |form|
                  form.submit("Trigger Peer Repair", class: token.action(variant: :secondary, size: :sm))
                end
              end
            )

            if routing[:active]
              panel.component(
                Igniter::Frontend::Tailwind::UI::KeyValueList.new(rows: [
                  ["status", "active"],
                  ["total", routing[:total]],
                  ["pending", routing[:pending]],
                  ["failed", routing[:failed]],
                  ["plans", routing[:plan_count]],
                  ["incidents", inline_counts(routing[:incidents])],
                  ["plan actions", inline_counts(routing[:plan_actions])],
                  ["last routing tick", tick ? tick[:timestamp] : "pending"],
                  ["last workload tick", wl_tick ? wl_tick[:timestamp] : "none"]
                ])
              )

              panel.tag(:h3, "Routing Entries", class: ui_theme.section_heading_class)
              panel.component(
                ui_theme.resource_list(
                  items: routing[:entries].map do |entry|
                    {
                      title: "#{entry[:node_name]} (#{entry[:status]})",
                      body: entry[:routing_trace_summary],
                      meta: "incident=#{entry[:incident_type]} action=#{entry[:plan_action]}"
                    }
                  end,
                  compact: true
                )
              )
            else
              panel.tag(:p, "No routing incidents published yet.", class: ui_theme.empty_state_class)
            end
          end
        end

        def workload_panel
          workload = snapshot.fetch(:workload, [])

          ui_theme.panel(
            title: "Workload Health",
            subtitle: "Per-peer failure rates and latency from the WorkloadTracker sliding window."
          ) do |panel|
            if workload.empty?
              panel.tag(:p, "No workload signals recorded yet. Signals are collected automatically during request routing.", class: ui_theme.empty_state_class)
            else
              panel.component(
                Igniter::Frontend::Tailwind::UI::KeyValueList.new(
                  rows: workload.map do |r|
                    status = if r[:degraded] && r[:overloaded]
                               "degraded + overloaded"
                             elsif r[:degraded]
                               "DEGRADED"
                             elsif r[:overloaded]
                               "OVERLOADED"
                             else
                               "healthy"
                             end
                    [
                      r[:peer_name],
                      "signals=#{r[:total]} failure_rate=#{r[:failure_rate]} avg_ms=#{r[:avg_ms] || '-'} [#{status}]"
                    ]
                  end
                )
              )
            end
          end
        end

        def governance_panel
          gov    = snapshot.fetch(:governance, {})
          cp     = gov[:checkpoint]
          events = gov[:recent_events] || []
          by_type = gov[:by_type] || {}

          ui_theme.panel(
            title: "Governance Trail",
            subtitle: "Live event stream, compaction state, and replicated checkpoint."
          ) do |panel|
            panel.component(
              Igniter::Frontend::Tailwind::UI::KeyValueList.new(rows: [
                ["total events", gov[:total] || 0],
                ["checkpoint peer", cp ? cp[:peer_name] : "none"],
                ["crest_digest", cp ? cp[:crest_digest] : "-"],
                ["checkpointed_at", cp ? cp[:checkpointed_at] : "-"],
                ["chained", cp ? cp[:chained].to_s : "-"]
              ])
            )

            unless by_type.empty?
              panel.tag(:h3, "Events by Type", class: ui_theme.section_heading_class)
              panel.component(
                Igniter::Frontend::Tailwind::UI::KeyValueList.new(
                  rows: by_type.map { |type, count| [type.to_s, count] }.sort_by { |t, _| t }
                )
              )
            end

            unless events.empty?
              panel.tag(:h3, "Recent Events", class: ui_theme.section_heading_class)
              panel.component(
                ui_theme.resource_list(
                  items: events.map do |ev|
                    {
                      title: ev[:type].to_s,
                      meta: "source=#{ev[:source]}",
                      body: ev[:timestamp].to_s
                    }
                  end,
                  compact: true
                )
              )
            end
          end
        end

        def admission_panel
          pending = snapshot.fetch(:pending_admissions, [])

          ui_theme.panel(
            title: "Admission Queue",
            subtitle: "Peers awaiting operator approval to join the cluster."
          ) do |panel|
            if pending.empty?
              panel.tag(:p, "No pending admission requests.", class: ui_theme.empty_state_class)
            else
              pending.each do |req|
                panel.component(
                  ui_theme.resource_list(
                    items: [
                      {
                        title: req[:peer_name],
                        meta:  "node_id=#{req[:node_id]} routable=#{req[:routable]}",
                        body:  "caps=#{req[:capabilities].join(', ')} requested=#{req[:requested_at]}"
                      }
                    ],
                    compact: true
                  )
                )
                panel.component(
                  Igniter::Frontend::Tailwind::UI::ActionBar.new(class_name: "flex gap-2 mb-4") do |actions|
                    actions.form(
                      action: route("/admin/admission?action=admit&request_id=#{req[:request_id]}"),
                      method: "post"
                    ) do |form|
                      form.submit("Approve", class: token.action(variant: :primary, theme: :orange, size: :sm))
                    end
                    actions.form(
                      action: route("/admin/admission?action=reject&request_id=#{req[:request_id]}"),
                      method: "post"
                    ) do |form|
                      form.submit("Reject", class: token.action(variant: :secondary, size: :sm))
                    end
                  end
                )
              end
            end
          end
        end

        def notes_panel
          notes = snapshot.fetch(:notes)

          ui_theme.panel(title: "Shared Notes", subtitle: "Simple cross-app proving slice shared by main and dashboard.") do |panel|
            if error_message
              panel.component(
                Igniter::Frontend::Tailwind::UI::Banner.new(
                  message: error_message,
                  tone: :error,
                  base_class: "mb-4 rounded-2xl border px-4 py-3 text-sm"
                )
              )
            end

            panel.form(action: route("/notes"), method: "post", class: "grid gap-3") do |form|
              form.label("note-text", "Add note", class: ui_theme.field_label_class)
              form.textarea(
                "text",
                id: "note-text",
                rows: 3,
                placeholder: "Capture a lab observation or operator todo",
                value: form_values.fetch("text", ""),
                class: ui_theme.input_class(extra: "min-h-28")
              )
              form.submit("Save Note", class: token.action(variant: :primary, theme: :orange))
            end

            panel.tag(:h3, "Recent Notes", class: ui_theme.section_heading_class)
            if notes.empty?
              panel.tag(:p, "No notes saved yet.", class: ui_theme.empty_state_class)
            else
              panel.component(
                ui_theme.resource_list(
                  items: notes.map do |note|
                    {
                      title: note.fetch("text"),
                      meta: "source=#{note.fetch("source")}",
                      body: "created=#{note.fetch("created_at")}"
                    }
                  end,
                  compact: true
                )
              )
            end
          end
        end

        def nodes_panel
          ui_theme.panel(title: "Mounted Nodes", subtitle: "Quick view of visible nodes, ports, and app mounts.") do |panel|
            panel.component(
              ui_theme.resource_list(
                items: snapshot.fetch(:nodes).map do |name, node|
                  mounts = node.fetch(:mounts)
                  {
                    title: name.to_s,
                    meta: "role=#{node.fetch(:role)}",
                    body: "host=#{node.fetch(:host)} port=#{node.fetch(:port)} public=#{node.fetch(:public)}",
                    code: mounts.empty? ? node.fetch(:command) : "mounts=#{mounts.map { |app, mount| "#{app}: #{mount}" }.join(", ")}\n#{node.fetch(:command)}"
                  }
                end
              )
            )
          end
        end

        def route(path)
          prefix = base_path.to_s
          return path if prefix.empty?

          [prefix, path.sub(%r{\A/}, "")].join("/")
        end

        def format_collection(values)
          return "none" if values.nil? || values.empty?

          values.join(", ")
        end

        def inline_counts(counts)
          return "none" if counts.nil? || counts.empty?

          counts.map { |key, value| "#{key}=#{value}" }.join(", ")
        end

        def ui_theme
          Igniter::Frontend::Tailwind::UI::Theme.fetch(:companion)
        end

        def token
          Igniter::Frontend::Tailwind::UI::Tokens
        end
      end
    end
  end
end
