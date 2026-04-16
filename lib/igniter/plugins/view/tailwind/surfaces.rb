# frozen_string_literal: true

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
