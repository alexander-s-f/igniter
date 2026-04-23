# frozen_string_literal: true

module Igniter
  module Frontend
    module Tailwind
      module Realtime
        module Presets
          class Preset
            attr_reader :hook_name
            attr_reader :projections
            attr_reader :include_mermaid
            attr_reader :extra_script

            def initialize(hook_name:, projections:, include_mermaid:, extra_script:)
              @hook_name = hook_name
              @projections = projections
              @include_mermaid = include_mermaid
              @extra_script = extra_script
            end

            def render_head(head, config:)
              Tailwind::Realtime.render_head(
                head,
                config: config,
                projections: projections,
                hook_name: hook_name,
                include_mermaid: include_mermaid,
                extra_script: extra_script
              )
            end
          end

          module_function

          def operator_surface(hook_name:, projections:, adapters:, include_mermaid: false)
            Preset.new(
              hook_name: hook_name,
              projections: projections,
              include_mermaid: include_mermaid,
              extra_script: Tailwind::Realtime::Adapters.compose_hook(name: hook_name, adapters: adapters)
            )
          end

          def home_ops(theme:)
            operator_surface(
              hook_name: "homeLabRealtimeProjector",
              include_mermaid: true,
              projections: {
                feed_limit: 6,
                overview: {
                  metrics: {
                    "devices-online" => "counts.devices_online",
                    "heartbeats" => "counts.device_heartbeats",
                    "notes" => "counts.notes",
                    "chat-turns" => "counts.chat_messages",
                    "camera-events" => "counts.camera_events",
                    "motion-events" => "counts.motion_events"
                  },
                  charts: {
                    "device-status" => "charts.device_status",
                    "activity-mix" => "charts.activity_mix",
                    "app-roles" => "charts.app_roles"
                  }
                },
                activity: {
                  cases: {
                    "note" => {
                      metric_deltas: { "notes" => 1 },
                      chart_deltas: { "activity-mix.notes" => 1 }
                    },
                    "camera_event" => {
                      metric_deltas: { "camera-events" => 1 },
                      chart_deltas: { "activity-mix.camera_events" => 1 }
                    },
                    "device_heartbeat" => {
                      metric_deltas: { "heartbeats" => 1 },
                      chart_deltas: { "activity-mix.heartbeats" => 1 }
                    },
                    "chat_turn" => {
                      metric_deltas: { "chat-turns" => 1 },
                      feed: false
                    }
                  }
                }
              },
              adapters: [
                Tailwind::Realtime::Adapters.prompt_buttons(
                  textarea_id: "chat-message"
                ),
                Tailwind::Realtime::Adapters.device_presence(
                  device_selector: "[data-device-id=\"__ID__\"]",
                  bootstrap_selector: "[data-device-id]",
                  status_badge_selector_template: "[data-device-status-badge=\"__ID__\"]",
                  last_seen_selector_template: "[data-device-last-seen=\"__ID__\"]",
                  telemetry_selector_template: "[data-device-telemetry=\"__ID__\"]",
                  topology_status_selector: "[data-topology-overall-status='true']",
                  topology_counts_selector: "[data-topology-device-count]",
                  chart_id: "device-status",
                  online_metric_id: "devices-online",
                  status_badge_base_class: Tailwind::UI::StatusBadge::DEFAULT_BASE_CLASS
                ),
                Tailwind::Realtime::Adapters.notes_list(
                  selector: "[data-notes-list='true']",
                  item_class: theme.list_item_class,
                  title_class: theme.item_title_class,
                  muted_class: theme.muted_text_class(extra: "muted"),
                  limit: 8
                ),
                Tailwind::Realtime::Adapters.chat_transcript(
                  selector: "[data-chat-list='true']",
                  item_class: theme.list_item_class,
                  muted_class: theme.muted_text_class(extra: "muted"),
                  body_class: theme.body_text_class(extra: "mt-3 whitespace-pre-wrap"),
                  status_badge_base_class: Tailwind::UI::StatusBadge::DEFAULT_BASE_CLASS,
                  limit: 10
                ),
                Tailwind::Realtime::Adapters.camera_events_list(
                  selector: "[data-camera-events-list='true']",
                  item_class: theme.list_item_class,
                  title_class: theme.item_title_class,
                  muted_class: theme.muted_text_class(extra: "muted"),
                  body_class: theme.body_text_class(extra: "mt-2 text-stone-200"),
                  motion_metric_id: "motion-events",
                  limit: 8
                ),
                Tailwind::Realtime::Adapters.activity_timeline(
                  selector: "[data-activity-timeline='true']",
                  item_class: theme.list_item_class,
                  title_class: theme.item_title_class,
                  muted_class: theme.muted_text_class(extra: "muted"),
                  link_class: "transition hover:text-amber-200",
                  action_class: Tailwind::UI::Tokens.underline_link(theme: :amber, extra: "mt-3 inline-flex text-sm"),
                  limit: 8,
                  source_urls: {
                    "note" => "http://127.0.0.1:4567/v1/notes",
                    "camera_event" => "http://127.0.0.1:4570/v1/camera_events",
                    "device_heartbeat" => "http://127.0.0.1:4570/v1/devices"
                  }
                )
              ]
            )
          end
        end
      end
    end
  end
end
