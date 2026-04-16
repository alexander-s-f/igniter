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
