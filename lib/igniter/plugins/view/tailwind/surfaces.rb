# frozen_string_literal: true

require "json"

module Igniter
  module Plugins
    module View
      module Tailwind
        module Surfaces
          class Preset
            attr_reader :name
            attr_reader :theme_name
            attr_reader :realtime_preset
            attr_reader :components
            attr_reader :hooks

            def initialize(name:, theme_name:, realtime_preset: nil, components: [], hooks: {})
              @name = name.to_sym
              @theme_name = theme_name.to_sym
              @realtime_preset = realtime_preset
              @components = components.map(&:to_sym).freeze
              @hooks = hooks.transform_keys(&:to_sym).freeze
            end

            def theme
              Tailwind::UI::Theme.fetch(theme_name)
            end

            def render_head(head, config:)
              realtime_preset&.render_head(head, config: config)
            end

            def metric_card(id:, label:, value:, hint: nil)
              Tailwind::UI::MetricCard.new(
                label: label,
                value: value,
                hint: hint,
                wrapper_attributes: { data: { metric_id: id } },
                value_attributes: { data: { metric_value: id } }
              )
            end

            def panel(title:, subtitle: nil, &block)
              theme.panel(title: title, subtitle: subtitle, &block)
            end

            def ops_hero_actions(view, endpoints:)
              view.component(
                Tailwind::UI::ActionBar.new(
                  class_name: theme.hero(:dashboard).fetch(:action_bar_class)
                ) do |links|
                  endpoints.each do |endpoint|
                    label = endpoint[:label] || endpoint["label"]
                    path = endpoint[:path] || endpoint["path"]
                    links.tag(:a,
                              label,
                              href: path,
                              class: Tailwind::UI::Tokens.action(
                                variant: :soft,
                                theme: :amber,
                                size: :sm,
                                extra: "pill-link font-medium"
                              ))
                  end
                end
              )
            end

            def operations_pulse(view, generated_at:, poll_interval_seconds:, charts:)
              view.component(
                theme.live_badge(
                  label: "Realtime overview",
                  value: generated_at,
                  interval_seconds: poll_interval_seconds
                )
              )
              view.tag(:h3, "Device Status", class: theme.section_heading_class)
              view.component(theme.bar_chart(items: normalize_chart_items(charts.fetch(:device_status)), chart_id: "device-status"))
              view.tag(:h3, "Activity Mix", class: theme.section_heading_class)
              view.component(theme.bar_chart(items: normalize_chart_items(charts.fetch(:activity_mix)), chart_id: "activity-mix"))
              view.tag(:h3, "App Role Spread", class: theme.section_heading_class)
              view.component(theme.bar_chart(items: normalize_chart_items(charts.fetch(:app_roles)), chart_id: "app-roles"))
            end

            def realtime_feed(view, stream_path:, events:, waiting_message: "Waiting for live events...")
              view.tag(:p,
                       "Stream source #{stream_path}",
                       class: "#{theme.muted_text_class(extra: "muted")} mb-3",
                       data: { realtime_stream_path: stream_path })
              view.tag(:ul, **realtime_feed_attributes(item_class: theme.compact_card_class)) do |list|
                if events.empty?
                  list.tag(:li, waiting_message, class: theme.compact_card_class)
                else
                  events.each do |entry|
                    list.tag(:li,
                             "#{entry.fetch("title")} · #{entry.fetch("detail")}",
                             class: theme.compact_card_class)
                  end
                end
              end
            end

            def chat_prompt_bar(view, prompts:)
              view.tag(:div, class: "mb-5 flex flex-wrap gap-2") do |actions|
                prompts.each do |prompt|
                  actions.tag(:button,
                              prompt,
                              type: "button",
                              class: Tailwind::UI::Tokens.action(
                                variant: :ghost,
                                theme: :amber,
                                size: :sm,
                                extra: "justify-start text-left"
                              ),
                              data: { chat_prompt: prompt })
                end
              end
            end

            def activity_filter_bar(view, items:)
              view.component(
                Tailwind::UI::ActionBar.new(class_name: "hero-links mb-4 flex flex-wrap gap-3") do |links|
                  items.each do |item|
                    links.tag(:a,
                              item.fetch(:label),
                              href: item.fetch(:href),
                              class: item.fetch(:active) ? active_filter_class : filter_link_class)
                  end
                end
              )
            end

            def timeline_focus_actions(view, source_url:, clear_path:)
              view.component(
                Tailwind::UI::ActionBar.new(
                  tag: :p,
                  class_name: "mt-4 flex flex-wrap gap-3"
                ) do |paragraph|
                  paragraph.tag(:a,
                                "Open source API",
                                href: source_url,
                                class: Tailwind::UI::Tokens.action(variant: :soft, theme: :cyan, size: :sm))
                  paragraph.tag(:a,
                                "Clear focus",
                                href: clear_path,
                                class: Tailwind::UI::Tokens.action(variant: :ghost, theme: :amber, size: :sm))
                end
              )
            end

            def device_inventory(view, devices:, empty_message:)
              if devices.empty?
                view.tag(:p, empty_message, class: theme.empty_state_class(extra: "empty-state"))
                return
              end

              view.tag(:ul, class: theme.list_class, data: { device_list: "true" }) do |list|
                devices.each do |device|
                  list.tag(:li,
                           class: theme.list_item_class,
                           **device_item_attributes(id: device.fetch(:id), status: device.fetch(:status))) do |item|
                    item.tag(:strong, class: theme.item_title_class) do |heading|
                      heading.tag(:a, device.fetch(:title), href: device.fetch(:href), class: ops_title_link_class)
                    end
                    item.tag(:div, device.fetch(:subtitle), class: theme.muted_text_class(extra: "muted"))
                    item.tag(:code, device.fetch(:code), class: theme.code_class)
                    item.tag(:div, class: "mt-3 flex flex-wrap items-center gap-2") do |meta|
                      meta.component(
                        Tailwind::UI::StatusBadge.new(
                          label: device.fetch(:status),
                          html_attributes: device_status_badge_attributes(device.fetch(:id))
                        )
                      )
                      meta.tag(:span,
                               device.fetch(:last_seen),
                               class: theme.muted_text_class,
                               **device_last_seen_attributes(device.fetch(:id)))
                    end
                    next unless device[:telemetry]

                    item.tag(:div,
                             device.fetch(:telemetry),
                             class: "#{theme.muted_text_class(extra: "muted")} mt-2",
                             **device_telemetry_attributes(device.fetch(:id)))
                  end
                end
              end
            end

            def devices_panel(devices:, empty_message:)
              panel(
                title: "Devices",
                subtitle: "Declared device inventory and current route targets."
              ) do |view|
                device_inventory(view, devices: devices, empty_message: empty_message)
              end
            end

            def notes_list(view, notes:, empty_message:)
              view.tag(:ul, class: theme.list_class, **notes_list_attributes) do |list|
                if notes.empty?
                  list.tag(:li, empty_message, class: theme.empty_state_class(extra: "empty-state"), data: { empty_state: "true" })
                else
                  notes.each do |note|
                    list.tag(:li, class: theme.list_item_class, data: { note_id: note.fetch(:id) }) do |item|
                      item.tag(:strong, note.fetch(:title), class: theme.item_title_class)
                      item.tag(:div, note.fetch(:meta), class: "#{theme.muted_text_class(extra: "muted")} mt-2")
                    end
                  end
                end
              end
            end

            def notes_panel(notes:, empty_message:, error_message: nil, &block)
              panel(
                title: "Shared Notes",
                subtitle: "Fast operator scratchpad shared between main and dashboard."
              ) do |view|
                if error_message
                  view.tag(:p,
                           error_message,
                           class: "error-banner mb-4 rounded-2xl border border-rose-300/20 bg-rose-300/10 px-4 py-3 text-sm text-rose-100")
                end
                block&.call(view)
                notes_list(view, notes: notes, empty_message: empty_message)
              end
            end

            def chat_transcript(view, messages:, empty_message:)
              view.tag(:ul, class: theme.list_class, **chat_list_attributes) do |list|
                if messages.empty?
                  list.tag(:li, empty_message, class: theme.empty_state_class(extra: "empty-state"), data: { empty_state: "true" })
                else
                  messages.each do |message|
                    list.tag(:li, class: theme.list_item_class, data: { chat_turn_id: message.fetch(:id, "") }) do |item|
                      item.tag(:div, class: "flex flex-wrap items-center gap-2") do |meta|
                        meta.component(Tailwind::UI::StatusBadge.new(label: message.fetch(:role)))
                        meta.tag(:span, message.fetch(:meta), class: theme.muted_text_class)
                      end
                      item.tag(:div, message.fetch(:body), class: theme.body_text_class(extra: "mt-3 whitespace-pre-wrap"))
                      render_chat_action_card(item, message[:action]) if message[:action]
                    end
                  end
                end
              end
            end

            def chat_action_memory(view, queue:, history:)
              return if queue.empty? && history.empty?

              unless queue.empty?
                view.tag(:h3, "Action Queue", class: theme.section_heading_class)
                view.tag(:ul, class: theme.compact_list_class, data: { action_queue: "true" }) do |list|
                  queue.each do |entry|
                    list.tag(:li, class: "list-none", data: { action_key: entry.fetch(:action_key) }) do |item|
                      render_chat_action_card(item, entry, compact: true)
                    end
                  end
                end
              end

              return if history.empty?

              view.tag(:h3, "Recent Action Outcomes", class: theme.section_heading_class(extra: "mt-4"))
              view.tag(:ul, class: theme.compact_list_class, data: { action_history: "true" }) do |list|
                history.each do |entry|
                  list.tag(:li, class: "list-none", data: { action_key: entry.fetch(:action_key) }) do |item|
                    render_chat_action_card(item, entry, compact: true)
                  end
                end
              end
            end

            def chat_panel(messages:, prompts:, empty_message:, error_message: nil, action_queue: [], action_history: [], &block)
              panel(
                title: "Igniter Chat",
                subtitle: "Thin operator chat loop over the current home-lab snapshot."
              ) do |view|
                if error_message
                  view.tag(:p,
                           error_message,
                           class: "mb-4 rounded-2xl border border-rose-300/20 bg-rose-300/10 px-4 py-3 text-sm text-rose-100")
                end
                block&.call(view)
                chat_prompt_bar(view, prompts: prompts)
                chat_action_memory(view, queue: action_queue, history: action_history)
                chat_transcript(view, messages: messages, empty_message: empty_message)
              end
            end

            def camera_events_list(view, events:, empty_message:)
              view.tag(:ul, class: theme.list_class, **camera_events_list_attributes) do |list|
                if events.empty?
                  list.tag(:li, empty_message, class: theme.empty_state_class(extra: "empty-state"), data: { empty_state: "true" })
                else
                  events.each do |event|
                    list.tag(:li, class: theme.list_item_class, data: { camera_event_id: event.fetch(:id) }) do |item|
                      item.tag(:strong, event.fetch(:title), class: theme.item_title_class)
                      item.tag(:div, event.fetch(:meta), class: "#{theme.muted_text_class(extra: "muted")} mt-2")
                      item.tag(:div, event.fetch(:body), class: theme.body_text_class(extra: "mt-2 text-stone-200"))
                    end
                  end
                end
              end
            end

            def camera_events_panel(events:, empty_message:)
              panel(
                title: "Recent Camera Events",
                subtitle: "Thin edge-ingest slice for ESP32-CAM style traffic."
              ) do |view|
                camera_events_list(view, events: events, empty_message: empty_message)
              end
            end

            def activity_timeline(view, items:, empty_message:)
              view.tag(:ul, class: theme.list_class, **activity_timeline_attributes) do |list|
                if items.empty?
                  list.tag(:li, empty_message, class: theme.empty_state_class(extra: "empty-state"), data: { empty_state: "true" })
                else
                  items.each do |entry|
                    list.tag(:li,
                             class: theme.list_item_class,
                             data: { timeline_entry_id: entry.fetch(:id), timeline_entry_type: entry.fetch(:type) }) do |item|
                      item.tag(:strong, class: theme.item_title_class) do |heading|
                        heading.tag(:a, entry.fetch(:title), href: entry.fetch(:href), class: ops_title_link_class)
                      end
                      item.tag(:div, entry.fetch(:detail), class: "#{theme.muted_text_class(extra: "muted")} mt-2")
                      item.tag(:div, entry.fetch(:age), class: "#{theme.muted_text_class(extra: "muted")} mt-2")
                      next unless entry[:source_url]

                      item.tag(:a,
                               "open source",
                               href: entry.fetch(:source_url),
                               class: Tailwind::UI::Tokens.underline_link(theme: :amber, extra: "mt-3 inline-flex text-sm"))
                    end
                  end
                end
              end
            end

            def timeline_panel(filter_items:, items:, empty_message:)
              panel(
                title: "Activity Timeline",
                subtitle: "Merged recent notes, camera events, and device heartbeats."
              ) do |view|
                activity_filter_bar(view, items: filter_items)
                activity_timeline(view, items: items, empty_message: empty_message)
              end
            end

            def timeline_focus_panel(entry:, clear_path:, empty_message: "No focused item.")
              panel(
                title: "Timeline Focus",
                subtitle: "Drilldown into the currently selected timeline item."
              ) do |view|
                unless entry
                  view.tag(:p, empty_message, class: theme.empty_state_class(extra: "empty-state"))
                  next
                end

                view.tag(:p, class: "flex flex-wrap items-center gap-2") do |paragraph|
                  paragraph.component(Tailwind::UI::StatusBadge.new(label: entry.fetch(:type)))
                  paragraph.tag(:span, entry.fetch(:title), class: theme.section_heading_class(extra: "mt-0 text-stone-200"))
                end
                view.tag(:p, entry.fetch(:detail), class: "#{theme.muted_text_class(extra: "muted")} mt-3")
                view.tag(:p, "seen=#{entry.fetch(:seen)}", class: "#{theme.muted_text_class(extra: "muted")} mt-2")
                timeline_focus_actions(view, source_url: entry.fetch(:source_url), clear_path: clear_path)
              end
            end

            def health_readiness_panel(surfaces:, empty_message:)
              panel(
                title: "Health & Readiness",
                subtitle: "Declared health surfaces for the currently modelled app stack."
              ) do |view|
                if surfaces.empty?
                  view.tag(:p, empty_message, class: theme.empty_state_class(extra: "empty-state"))
                  next
                end

                view.tag(:ul, class: theme.list_class) do |list|
                  surfaces.each do |surface|
                    list.tag(:li, class: theme.list_item_class) do |item|
                      item.tag(:strong, surface.fetch(:title), class: theme.item_title_class)
                      item.tag(:div, class: "mt-3 flex flex-wrap items-center gap-2") do |meta|
                        meta.component(Tailwind::UI::StatusBadge.new(label: surface.fetch(:status)))
                        meta.tag(:span, surface.fetch(:meta), class: theme.muted_text_class)
                      end
                      next unless surface[:url]

                      item.tag(:a,
                               surface.fetch(:url),
                               href: surface.fetch(:url),
                               class: Tailwind::UI::Tokens.underline_link(theme: :amber, extra: "mt-3 inline-flex text-sm"))
                    end
                  end
                end
              end
            end

            def topology_health_panel(health:)
              panel(
                title: "Topology Health",
                subtitle: "High-level health verdict across devices and app surfaces."
              ) do |view|
                view.tag(:p, class: "flex flex-wrap items-center gap-2") do |paragraph|
                  paragraph.tag(:span, "overall=", class: theme.muted_text_class)
                  paragraph.component(
                    Tailwind::UI::StatusBadge.new(
                      label: health.fetch(:overall_status),
                      html_attributes: topology_overall_status_attributes
                    )
                  )
                end
                view.tag(:p, health.fetch(:readiness_summary), class: "#{theme.muted_text_class(extra: "muted")} mt-3")
                if health[:acknowledgement_summary]
                  view.tag(:p,
                           health.fetch(:acknowledgement_summary),
                           class: "#{theme.muted_text_class(extra: "muted")} mt-2",
                           data: { topology_health_acknowledged: "true" })
                end

                view.tag(:ul, class: theme.compact_list_class) do |list|
                  health.fetch(:device_status_counts).each do |entry|
                    list.tag(:li,
                             entry.fetch(:label),
                             class: theme.compact_item_class,
                             **topology_device_count_attributes(entry.fetch(:status)))
                  end
                end

                alerts = health.fetch(:alerts)
                next if alerts.empty?

                view.tag(:h3, "Alerts", class: theme.section_heading_class)
                view.tag(:ul, class: theme.compact_list_class) do |list|
                  alerts.each { |alert| list.tag(:li, alert, class: theme.compact_item_class) }
                end
              end
            end

            def network_topology_panel(topology_notes:, public_endpoints:, dependency_edges:)
              panel(
                title: "Network & Topology",
                subtitle: "Ports, public endpoints, app edges, and topology notes."
              ) do |view|
                unless topology_notes.empty?
                  view.tag(:h3, "Topology Notes", class: theme.section_heading_class)
                  view.tag(:ul, class: theme.compact_list_class) do |list|
                    topology_notes.each { |note| list.tag(:li, note, class: theme.compact_item_class) }
                  end
                end

                view.tag(:h3, "Public Endpoints", class: theme.section_heading_class)
                view.component(
                  theme.endpoint_list(
                    items: public_endpoints,
                    compact: true,
                    empty_message: "No public endpoints configured.",
                    link_class: Tailwind::UI::Tokens.underline_link(theme: :amber, extra: "text-sm")
                  )
                )

                view.tag(:h3, "App Edges", class: theme.section_heading_class)
                if dependency_edges.empty?
                  view.tag(:p, "No inter-app dependencies yet.", class: theme.empty_state_class(extra: "empty-state"))
                else
                  view.tag(:ul, class: theme.compact_list_class) do |list|
                    dependency_edges.each { |edge| list.tag(:li, edge, class: theme.compact_item_class) }
                  end
                end
              end
            end

            def app_services_panel(services:, empty_message:)
              panel(
                title: "App Services",
                subtitle: "Runtime-facing app roles, classes, commands, and dependencies."
              ) do |view|
                if services.empty?
                  view.tag(:p, empty_message, class: theme.empty_state_class(extra: "empty-state"))
                  next
                end

                view.tag(:ul, class: theme.list_class) do |list|
                  services.each do |service|
                    list.tag(:li, class: theme.list_item_class) do |item|
                      item.tag(:strong, class: theme.item_title_class) do |heading|
                        heading.tag(:a, service.fetch(:title), href: service.fetch(:href), class: ops_title_link_class)
                      end
                      item.tag(:div, service.fetch(:meta), class: "#{theme.muted_text_class(extra: "muted")} mt-2")
                      item.tag(:code, service.fetch(:class_name), class: "#{theme.code_class} mt-2 block")
                      item.tag(:code, service.fetch(:command), class: "#{theme.code_class} mt-2 block")
                      item.tag(:div, service.fetch(:path), class: "#{theme.muted_text_class(extra: "muted")} mt-2") if service[:path]
                      item.tag(:div, service.fetch(:depends_on), class: "#{theme.muted_text_class(extra: "muted")} mt-2") if service[:depends_on]
                    end
                  end
                end
              end
            end

            def resources_panel(stores:, var_files:, total_var_bytes:)
              panel(
                title: "Resources",
                subtitle: "Current workspace stores and local var files."
              ) do |view|
                view.tag(:h3, "Stores", class: theme.section_heading_class)
                view.component(theme.resource_list(items: stores, compact: true))

                view.tag(:h3, "Var Files", class: theme.section_heading_class)
                view.component(
                  theme.resource_list(
                    items: var_files,
                    compact: true,
                    empty_message: "No var files yet."
                  )
                )

                view.tag(:p, "total_var_bytes=#{total_var_bytes}", class: "#{theme.muted_text_class(extra: "muted")} mt-3")
              end
            end

            def debug_surfaces_panel(api_items:, files:, commands:)
              panel(
                title: "Debug Surfaces",
                subtitle: "Useful entrypoints, file anchors, and local commands."
              ) do |view|
                view.tag(:h3, "APIs", class: theme.section_heading_class)
                view.component(
                  theme.endpoint_list(
                    items: api_items,
                    compact: true,
                    link_class: Tailwind::UI::Tokens.underline_link(theme: :amber, extra: "text-sm")
                  )
                )

                view.tag(:h3, "Files", class: theme.section_heading_class)
                compact_code_list(view, files)

                view.tag(:h3, "Commands", class: theme.section_heading_class)
                compact_code_list(view, commands)
              end
            end

            def next_ideas_panel(ideas:, empty_message:)
              panel(
                title: "Next Ideas",
                subtitle: "Likely next slices once this proving surface feels stable."
              ) do |view|
                if ideas.empty?
                  view.tag(:p, empty_message, class: theme.empty_state_class(extra: "empty-state"))
                else
                  view.tag(:ul, class: theme.compact_list_class) do |list|
                    ideas.each { |idea| list.tag(:li, idea, class: theme.compact_item_class) }
                  end
                end
              end
            end

            def topology_flow_panel(diagram:, title: "Topology Mermaid", description: "Devices flow into edge, and app dependencies are overlaid as dotted links.")
              panel(
                title: "Topology Flow",
                subtitle: "Mermaid view of devices, routes, and inter-app dependencies."
              ) do |view|
                view.component(
                  theme.mermaid_diagram(
                    diagram: diagram,
                    title: title,
                    description: description
                  )
                )
              end
            end

            def execution_flow_panel(diagram:, title: "Execution Mermaid", description: "Ingest and operator actions converge into shared stores and the stack overview loop.")
              panel(
                title: "Execution Flow",
                subtitle: "Mermaid view of ingest, shared stores, stack overview, and dashboard loop."
              ) do |view|
                view.component(
                  theme.mermaid_diagram(
                    diagram: diagram,
                    title: title,
                    description: description
                  )
                )
              end
            end

            def form_section(title:, subtitle:, action:, method: "post", **options, &block)
              theme.form_section(title: title, subtitle: subtitle, action: action, method: method, **options, &block)
            end

            def authoring_catalog_panel(&block)
              panel(
                title: "View Schemas",
                subtitle: "Catalog browser and lightweight authoring surface for persisted schemas.",
                &block
              )
            end

            def schema_create_form_section(**options, &block)
              form_section(
                title: "Create Schema",
                subtitle: "Post a full schema payload directly to the catalog API.",
                action: "#",
                **options,
                &block
              )
            end

            def schema_patch_form_section(**options, &block)
              form_section(
                title: "Patch Schema",
                subtitle: "Load an existing schema, edit a JSON patch, then apply it through the catalog API.",
                action: "#",
                **options,
                &block
              )
            end

            def recent_submissions_panel(&block)
              panel(
                title: "Recent Submissions",
                subtitle: "Latest schema runtime outputs flowing back into the operator surface.",
                &block
              )
            end

            def submission_summary_panel(&block)
              panel(
                title: "Summary",
                subtitle: "Runtime-level context for this schema submission.",
                &block
              )
            end

            def submission_replay_panel(&block)
              panel(
                title: "Replay",
                subtitle: "Replay the stored raw payload back into the originating schema action.",
                &block
              )
            end

            def submission_payload_panel(kind, &block)
              case kind.to_sym
              when :raw
                panel(
                  title: "Raw Payload",
                  subtitle: "Original form values as they were submitted.",
                  &block
                )
              when :normalized
                panel(
                  title: "Normalized Payload",
                  subtitle: "Payload after schema normalization and type coercion.",
                  &block
                )
              when :processing_result
                panel(
                  title: "Processing Result",
                  subtitle: "Runtime result captured after submission processing.",
                  &block
                )
              else
                raise ArgumentError, "unsupported submission payload panel kind: #{kind}"
              end
            end

            def submission_diff_panel(&block)
              panel(
                title: "Normalization Diff",
                subtitle: "Field-level view of what changed between raw and normalized payloads.",
                &block
              )
            end

            def schema_catalog_intro(view, description:, catalog_path:, featured_view_path:, featured_view_label:)
              view.tag(:div, class: "space-y-4") do |container|
                container.tag(:p, description, class: theme.body_text_class)
                container.component(
                  Tailwind::UI::ActionBar.new(class_name: "flex flex-wrap gap-2") do |actions|
                    actions.tag(:a,
                                "Catalog JSON",
                                href: catalog_path,
                                class: Tailwind::UI::Tokens.action(variant: :soft, theme: :orange, size: :sm))
                    actions.tag(:a,
                                featured_view_label,
                                href: featured_view_path,
                                class: Tailwind::UI::Tokens.action(variant: :ghost, theme: :orange, size: :sm))
                  end
                )
              end
            end

            def schema_catalog_list(view, items:, empty_message:)
              if items.empty?
                view.tag(:p, empty_message, class: theme.empty_state_class)
                return
              end

              view.tag(:ul, class: theme.list_class) do |list|
                items.each do |item|
                  list.tag(:li, class: theme.list_item_class) do |card|
                    card.tag(:strong, item.fetch(:title), class: theme.item_title_class)
                    card.tag(:div, item.fetch(:id), class: theme.muted_text_class(extra: "mt-2"))
                    card.tag(:div, item.fetch(:meta), class: theme.muted_text_class(extra: "mt-2"))
                    card.component(
                      Tailwind::UI::ActionBar.new(class_name: "mt-3 flex flex-wrap gap-2") do |actions|
                        actions.tag(:a,
                                    "Open view",
                                    href: item.fetch(:view_path),
                                    class: Tailwind::UI::Tokens.action(variant: :soft, theme: :orange, size: :sm))
                        actions.tag(:a,
                                    "JSON",
                                    href: item.fetch(:api_path),
                                    class: Tailwind::UI::Tokens.action(variant: :ghost, theme: :orange, size: :sm))
                        actions.tag(:button,
                                    item.fetch(:load_label, "Load JSON"),
                                    type: "button",
                                    class: Tailwind::UI::Tokens.action(variant: :ghost, theme: :orange, size: :sm),
                                    onclick: item.fetch(:load_action))
                        actions.tag(:button,
                                    item.fetch(:clone_label, "Clone"),
                                    type: "button",
                                    class: Tailwind::UI::Tokens.action(variant: :ghost, theme: :orange, size: :sm),
                                    onclick: item.fetch(:clone_action))
                      end
                    )
                  end
                end
              end
            end

            def schema_catalog_grid_class
              "grid gap-5 lg:grid-cols-[minmax(0,1.2fr)_minmax(0,1fr)]"
            end

            def submission_timeline(view, description:, items:, empty_message:)
              view.tag(:div, class: "space-y-4") do |container|
                container.tag(:p, description, class: theme.body_text_class)
                container.component(
                  theme.timeline_list(
                    items: items,
                    empty_message: empty_message,
                    title_link_class: Tailwind::UI::Tokens.underline_link(theme: :orange),
                    action_link_class: Tailwind::UI::Tokens.action(variant: :ghost, theme: :orange, size: :sm)
                  )
                )
              end
            end

            def submission_replay_actions(view, source_view_path:, schema_path:)
              view.component(
                Tailwind::UI::ActionBar.new(class_name: "flex flex-wrap gap-2") do |bar|
                  bar.tag(:a,
                          "Open submission source view",
                          href: source_view_path,
                          class: Tailwind::UI::Tokens.action(variant: :soft, theme: :orange, size: :sm))
                  bar.tag(:a,
                          "Open schema JSON",
                          href: schema_path,
                          class: Tailwind::UI::Tokens.action(variant: :ghost, theme: :orange, size: :sm))
                end
              )
            end

            def submission_json_payload(view, payload)
              view.tag(:pre, class: "#{theme.code_class} overflow-x-auto whitespace-pre-wrap") do |pre|
                pre.text(JSON.pretty_generate(payload))
              end
            end

            def submission_detail_grid_class
              "grid gap-5 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]"
            end

            def realtime_feed_attributes(item_class: theme.compact_card_class)
              {
                class: theme.compact_list_class,
                data: {
                  realtime_feed: "true",
                  item_class: item_class
                }
              }
            end

            def notes_list_attributes
              { data: { notes_list: "true" } }
            end

            def chat_list_attributes
              { data: { chat_list: "true" } }
            end

            def camera_events_list_attributes
              { data: { camera_events_list: "true" } }
            end

            def activity_timeline_attributes
              { data: { activity_timeline: "true" } }
            end

            def device_item_attributes(id:, status:)
              { data: { device_id: id.to_s, device_status: status.to_s } }
            end

            def device_status_badge_attributes(id)
              { "data-device-status-badge": id.to_s }
            end

            def device_last_seen_attributes(id)
              { data: { device_last_seen: id.to_s } }
            end

            def device_telemetry_attributes(id)
              { data: { device_telemetry: id.to_s } }
            end

            def topology_overall_status_attributes
              { "data-topology-overall-status": "true" }
            end

            def topology_device_count_attributes(status)
              { data: { topology_device_count: status.to_s } }
            end

            private

            def filter_link_class
              Tailwind::UI::Tokens.action(variant: :ghost, theme: :amber, size: :sm, extra: "pill-link")
            end

            def active_filter_class
              Tailwind::UI::Tokens.action(
                variant: :primary,
                theme: :amber,
                size: :sm,
                extra: "pill-link active-pill font-medium"
              )
            end

            def normalize_chart_items(items)
              items.map do |item|
                {
                  key: item[:key] || item["key"],
                  label: item[:label] || item["label"],
                  value: item[:value] || item["value"]
                }.compact
              end
            end

            def ops_title_link_class
              "transition hover:text-amber-200"
            end

            def compact_code_list(view, values)
              view.tag(:ul, class: theme.compact_list_class) do |list|
                values.each do |value|
                  list.tag(:li, class: theme.compact_card_class) { |item| item.tag(:code, value, class: theme.code_class) }
                end
              end
            end

            def render_chat_action_card(view, action, compact: false)
              view.tag(
                :div,
                class: chat_action_card_class(action.fetch(:status), compact: compact),
                data: { action_status: normalized_action_status(action.fetch(:status)) }
              ) do |card|
                card.tag(:div, class: "flex flex-wrap items-center gap-2") do |meta|
                  meta.tag(:strong, action.fetch(:title), class: theme.item_title_class)
                  meta.component(
                    Tailwind::UI::StatusBadge.new(
                      label: action.fetch(:status),
                      tone: chat_action_status_tone(action.fetch(:status)),
                      html_attributes: { data: { action_status_badge: normalized_action_status(action.fetch(:status)) } }
                    )
                  )
                end
                card.tag(:p, action.fetch(:preview), class: theme.body_text_class(extra: compact ? "mt-2" : "mt-3"))
                card.tag(:p, action.fetch(:meta), class: theme.muted_text_class(extra: "mt-2")) if action[:meta]
                render_chat_action_details(card, action[:details])
                render_chat_action_payload(card, action[:payload], status: action.fetch(:status))

                render_chat_action_card_actions(card, action)
              end
            end

            def render_chat_action_card_actions(view, action)
              actions = []
              actions << action[:confirm] if action[:confirm]
              actions << action[:dismiss] if action[:dismiss]
              return if actions.empty?

              view.tag(:div, class: "mt-4 flex flex-wrap gap-3") do |row|
                actions.each do |entry|
                  row.form(action: entry.fetch(:path), method: entry.fetch(:method, "post"), class: "inline-flex") do |form|
                    entry.fetch(:hidden, {}).each { |name, value| form.hidden(name, value) }
                    form.submit(entry.fetch(:label), class: entry.fetch(:class_name))
                  end
                end
              end
            end

            def render_chat_action_details(view, details)
              items = Array(details).compact
              return if items.empty?

              view.tag(:dl, class: "mt-3 grid gap-2 text-sm", data: { action_details: "true" }) do |list|
                items.each do |detail|
                  next if detail[:value].to_s.strip.empty?

                  list.tag(:div, class: "grid gap-1 rounded-2xl border border-white/10 bg-black/10 px-3 py-2") do |row|
                    row.tag(:dt, detail.fetch(:label), class: "text-[11px] font-semibold uppercase tracking-[0.18em] text-stone-400")
                    row.tag(:dd, detail.fetch(:value), class: theme.body_text_class)
                  end
                end
              end
            end

            def render_chat_action_payload(view, payload, status:)
              data = payload.is_a?(Hash) ? payload : nil
              return if data.nil? || data.empty?

              label = normalized_action_status(status) == "confirmation_required" ? "Proposed Payload" : "Result Payload"
              view.tag(:div, class: "mt-3", data: { action_payload: "true" }) do |section|
                section.tag(:p, label, class: "text-[11px] font-semibold uppercase tracking-[0.18em] text-stone-400")
                section.tag(:pre, class: "#{theme.code_class} mt-2 overflow-x-auto whitespace-pre-wrap") do |code|
                  code.text(JSON.pretty_generate(data))
                end
              end
            end

            def chat_action_card_class(status, compact:)
              base = compact ? "rounded-2xl border p-4" : "mt-4 rounded-2xl border p-4"
              [base, chat_action_card_tone_class(status)].join(" ")
            end

            def chat_action_card_tone_class(status)
              case normalized_action_status(status)
              when "confirmation_required"
                "border-amber-300/25 bg-amber-300/10"
              when "completed"
                "border-emerald-300/25 bg-emerald-300/10"
              when "dismissed"
                "border-stone-300/15 bg-stone-400/5"
              when "unavailable"
                "border-rose-300/25 bg-rose-300/10"
              else
                "border-white/10 bg-white/5"
              end
            end

            def chat_action_status_tone(status)
              case normalized_action_status(status)
              when "confirmation_required"
                "border-amber-300/30 bg-amber-300/10 text-amber-100"
              when "completed"
                "border-emerald-300/30 bg-emerald-300/10 text-emerald-100"
              when "dismissed"
                "border-stone-300/20 bg-stone-400/10 text-stone-200"
              when "unavailable"
                "border-rose-300/30 bg-rose-300/10 text-rose-100"
              else
                "border-cyan-300/30 bg-cyan-300/10 text-cyan-100"
              end
            end

            def normalized_action_status(status)
              status.to_s.strip.downcase.tr(" ", "_")
            end
          end

          module_function

          def ops_dashboard
            theme = Tailwind::UI::Theme.fetch(:ops)
            Preset.new(
              name: :ops_dashboard,
              theme_name: :ops,
              realtime_preset: Tailwind::Realtime::Presets.home_ops(theme: theme),
              components: %i[
                metric_card
                panel
                live_badge
                bar_chart
                mermaid_diagram
                status_badge
                endpoint_list
                timeline_list
                ops_hero_actions
                operations_pulse
                realtime_feed
                chat_prompt_bar
                activity_filter_bar
                timeline_focus_actions
                device_inventory
                notes_list
                chat_transcript
                camera_events_list
                activity_timeline
                devices_panel
                notes_panel
                chat_panel
                camera_events_panel
                timeline_panel
                timeline_focus_panel
                health_readiness_panel
                topology_health_panel
                network_topology_panel
                app_services_panel
                resources_panel
                debug_surfaces_panel
                next_ideas_panel
                topology_flow_panel
                execution_flow_panel
              ],
              hooks: {
                metrics: %w[apps public-apps devices devices-online heartbeats notes chat-turns camera-events motion-events],
                lists: %w[notes chat camera_events activity_timeline],
                device_presence: %w[device_id device_status device_last_seen device_telemetry],
                topology_health: %w[topology_overall_status topology_device_count],
                realtime_feed: "realtime_feed"
              }
            )
          end

          def schema_authoring
            Preset.new(
              name: :schema_authoring,
              theme_name: :companion,
              components: %i[
                panel
                form_section
                banner
                key_value_list
                action_bar
                message_page
                schema_catalog
                submission_timeline
              ],
              hooks: {
                catalog: %w[view_schema_catalog schema_json_link schema_editor],
                submissions: %w[submission_browser submission_detail_link]
              }
            )
          end

          def submission_inspection
            Preset.new(
              name: :submission_inspection,
              theme_name: :companion,
              components: %i[
                payload_diff
                key_value_list
                panel
                message_page
                action_bar
                code_block
                submission_replay_actions
                submission_json_payload
              ],
              hooks: {
                payloads: %w[raw_payload normalized_payload processing_result],
                diffs: %w[payload_diff normalization_diff]
              }
            )
          end
        end
      end
    end
  end
end
