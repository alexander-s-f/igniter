# frozen_string_literal: true

require "json"

module Igniter
  module Frontend
    module Tailwind
      module Realtime
        module Adapters
          module_function

          def compose_hook(name:, adapters:)
            <<~JAVASCRIPT
              (() => {
                const bootstrapHandlers = [];
                const overviewHandlers = [];
                const activityHandlers = [];

                #{adapters.compact.join("\n\n")}

                window[#{JSON.generate(name)}] = (helpers, event) => {
                  const phase = event?.phase;
                  const payload = event?.payload || {};
                  const handlers = phase === "bootstrap" ? bootstrapHandlers : phase === "overview" ? overviewHandlers : phase === "activity" ? activityHandlers : [];
                  handlers.forEach((handler) => handler(helpers, payload, event));
                };
              })();
            JAVASCRIPT
          end

          def prompt_buttons(textarea_id:, selector: "[data-chat-prompt]")
            <<~JAVASCRIPT
              bootstrapHandlers.push((_helpers, _payload, _event) => {
                const textarea = document.getElementById(#{JSON.generate(textarea_id)});
                if (!textarea) return;
                document.querySelectorAll(#{JSON.generate(selector)}).forEach((button) => {
                  button.addEventListener("click", () => {
                    textarea.value = button.dataset.chatPrompt || "";
                    textarea.focus();
                  });
                });
              });
            JAVASCRIPT
          end

          def device_presence(device_selector:, bootstrap_selector:, status_badge_selector_template:, last_seen_selector_template:,
                              telemetry_selector_template:, topology_status_selector:, topology_counts_selector:,
                              chart_id:, online_metric_id:, status_badge_base_class:)
            <<~JAVASCRIPT
              const devicePresenceState = {};

              const refreshDevicePresenceTopologyHealth = (helpers) => {
                const counts = {
                  online: document.querySelector(`[data-chart-id="#{chart_id}"] [data-chart-value="online"]`)?.textContent || "0",
                  stale: document.querySelector(`[data-chart-id="#{chart_id}"] [data-chart-value="stale"]`)?.textContent || "0",
                  offline: document.querySelector(`[data-chart-id="#{chart_id}"] [data-chart-value="offline"]`)?.textContent || "0"
                };

                document.querySelectorAll(#{JSON.generate(topology_counts_selector)}).forEach((node) => {
                  const status = node.dataset.topologyDeviceCount;
                  node.textContent = `${status}=${counts[status] || 0}`;
                });

                const overall = Number(counts.offline) > 0 ? "degraded" : Number(counts.stale) > 0 ? "warning" : "healthy";
                helpers.applyStatusBadge(document.querySelector(#{JSON.generate(topology_status_selector)}), overall, #{JSON.generate(status_badge_base_class)});
              };

              const updateDevicePresenceCard = (helpers, payload) => {
                const deviceId = payload.device_id;
                if (!deviceId) return;
                const node = document.querySelector(#{JSON.generate(device_selector)}.replace("__ID__", deviceId));
                if (!node) return;
                const previous = devicePresenceState[deviceId] || node.dataset.deviceStatus || "offline";
                if (previous !== "online") {
                  if (previous === "offline") helpers.changeChart(#{JSON.generate(chart_id)}, "offline", -1);
                  if (previous === "stale") helpers.changeChart(#{JSON.generate(chart_id)}, "stale", -1);
                  helpers.changeChart(#{JSON.generate(chart_id)}, "online", 1);
                  helpers.changeMetric(#{JSON.generate(online_metric_id)}, 1);
                }
                devicePresenceState[deviceId] = "online";
                node.dataset.deviceStatus = "online";
                helpers.applyStatusBadge(document.querySelector(#{JSON.generate(status_badge_selector_template)}.replace("__ID__", deviceId)), "online", #{JSON.generate(status_badge_base_class)});
                const lastSeenNode = document.querySelector(#{JSON.generate(last_seen_selector_template)}.replace("__ID__", deviceId));
                if (lastSeenNode) lastSeenNode.textContent = `last_seen=${helpers.humanAge(payload.occurred_at)}`;
                const telemetryNode = document.querySelector(#{JSON.generate(telemetry_selector_template)}.replace("__ID__", deviceId));
                if (telemetryNode) telemetryNode.textContent = `battery=${payload.battery ?? "-"} signal=${payload.signal ?? "-"} ip=${payload.ip || "-"}`;
                refreshDevicePresenceTopologyHealth(helpers);
              };

              bootstrapHandlers.push((helpers, _payload, _event) => {
                document.querySelectorAll(#{JSON.generate(bootstrap_selector)}).forEach((node) => {
                  devicePresenceState[node.dataset.deviceId] = node.dataset.deviceStatus || "offline";
                });
                refreshDevicePresenceTopologyHealth(helpers);
              });

              overviewHandlers.push((helpers, _payload, _event) => {
                refreshDevicePresenceTopologyHealth(helpers);
              });

              activityHandlers.push((helpers, payload, _event) => {
                if (payload.type !== "device_heartbeat") return;
                updateDevicePresenceCard(helpers, {
                  device_id: payload.payload?.device_id || payload.title,
                  battery: payload.payload?.battery,
                  signal: payload.payload?.signal,
                  ip: payload.payload?.ip,
                  occurred_at: payload.occurred_at
                });
              });
            JAVASCRIPT
          end

          def notes_list(selector:, item_class:, title_class:, muted_class:, limit:)
            <<~JAVASCRIPT
              const prependRealtimeNote = (helpers, payload) => {
                const list = helpers.removeEmptyState(#{JSON.generate(selector)});
                if (!list) return;
                const item = document.createElement("li");
                item.className = #{JSON.generate(item_class)};
                item.innerHTML = `<strong class="#{escape_js(title_class)}">${payload.text || "Note added"}</strong><div class="#{escape_js(muted_class)} mt-2">source=${payload.source || "operator"} · created=${helpers.humanAge(payload.occurred_at)}</div>`;
                list.prepend(item);
                while (list.children.length > #{limit}) list.removeChild(list.lastChild);
              };

              activityHandlers.push((helpers, payload, _event) => {
                if (payload.type !== "note") return;
                prependRealtimeNote(helpers, { text: payload.detail, source: payload.source, occurred_at: payload.occurred_at });
              });
            JAVASCRIPT
          end

          def chat_transcript(selector:, item_class:, muted_class:, body_class:, status_badge_base_class:, limit:)
            <<~JAVASCRIPT
              const prependRealtimeChatTurn = (helpers, payload) => {
                const list = helpers.removeEmptyState(#{JSON.generate(selector)});
                if (!list) return;
                const item = document.createElement("li");
                item.className = #{JSON.generate(item_class)};
                const badge = `<span class="#{escape_js(status_badge_base_class)} ${'${helpers.statusToneClass(payload.role || "assistant")}' }">${'${payload.role || "assistant"}'}</span>`;
                item.innerHTML = `<div class="flex flex-wrap items-center gap-2">${'${badge}'}<span class="#{escape_js(muted_class)}">${'${payload.source || "dashboard"}'} · ${'${helpers.humanAge(payload.occurred_at)}'}</span></div><div class="#{escape_js(body_class)}">${'${payload.content || ""}'}</div>`;
                list.prepend(item);
                while (list.children.length > #{limit}) list.removeChild(list.lastChild);
              };

              activityHandlers.push((helpers, payload, _event) => {
                if (payload.type !== "chat_turn") return;
                prependRealtimeChatTurn(helpers, {
                  role: payload.payload?.role || "assistant",
                  source: payload.source,
                  content: payload.payload?.content || payload.detail,
                  occurred_at: payload.occurred_at
                });
              });
            JAVASCRIPT
          end

          def camera_events_list(selector:, item_class:, title_class:, muted_class:, body_class:, limit:, motion_metric_id: nil)
            motion_metric_js = if motion_metric_id
                                 %(if (payload.payload?.motion === true) helpers.changeMetric(#{JSON.generate(motion_metric_id)}, 1);)
                               else
                                 ""
                               end

            <<~JAVASCRIPT
              const prependRealtimeCameraEvent = (helpers, payload) => {
                const list = helpers.removeEmptyState(#{JSON.generate(selector)});
                if (!list) return;
                const item = document.createElement("li");
                item.className = #{JSON.generate(item_class)};
                item.innerHTML = `<strong class="#{escape_js(title_class)}">${'${payload.device_id || "camera"}'}</strong><div class="#{escape_js(muted_class)} mt-2">motion=${'${payload.motion === true}'} · source=${'${payload.source || "esp32-cam"}'} · created=${'${helpers.humanAge(payload.occurred_at)}'}</div><div class="#{escape_js(body_class)}">${'${payload.summary || "(no summary yet)"}'}</div>`;
                list.prepend(item);
                while (list.children.length > #{limit}) list.removeChild(list.lastChild);
              };

              activityHandlers.push((helpers, payload, _event) => {
                if (payload.type !== "camera_event") return;
                #{motion_metric_js}
                prependRealtimeCameraEvent(helpers, {
                  device_id: payload.payload?.device_id || payload.title,
                  motion: payload.payload?.motion === true,
                  summary: payload.payload?.summary || payload.detail,
                  source: payload.source,
                  occurred_at: payload.occurred_at
                });
              });
            JAVASCRIPT
          end

          def activity_timeline(selector:, item_class:, title_class:, muted_class:, link_class:, action_class:, limit:, source_urls:)
            <<~JAVASCRIPT
              const prependRealtimeTimelineEntry = (helpers, type, title, detail, occurredAt, sourceUrl, id) => {
                const list = helpers.removeEmptyState(#{JSON.generate(selector)});
                if (!list) return;
                const href = id ? `/?timeline=${type}&focus=${id}` : "/";
                const item = document.createElement("li");
                item.className = #{JSON.generate(item_class)};
                item.innerHTML = `<strong class="#{escape_js(title_class)}"><a href="${'${href}'}" class="#{escape_js(link_class)}">${'${type}'} · ${'${title}'}</a></strong><div class="#{escape_js(muted_class)} mt-2">${'${detail}'}</div><div class="#{escape_js(muted_class)} mt-2">${'${helpers.humanAge(occurredAt)}'}</div>${'${sourceUrl ? `<a href="${sourceUrl}" class="#{escape_js(action_class)}">open source</a>` : ""}'}`;
                list.prepend(item);
                while (list.children.length > #{limit}) list.removeChild(list.lastChild);
              };

              activityHandlers.push((helpers, payload, _event) => {
                if (!["note", "camera_event", "device_heartbeat"].includes(payload.type)) return;
                const sourceMap = #{JSON.generate(source_urls)};
                prependRealtimeTimelineEntry(
                  helpers,
                  payload.type,
                  payload.title,
                  payload.detail,
                  payload.occurred_at,
                  sourceMap[payload.type] || null,
                  payload.id
                );
              });
            JAVASCRIPT
          end

          private_class_method def escape_js(value)
            value.to_s.gsub("\\", "\\\\").gsub("\"", "\\\"")
          end
        end
      end
    end
  end
end
