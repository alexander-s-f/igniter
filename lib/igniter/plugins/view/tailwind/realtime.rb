# frozen_string_literal: true

require "json"

require_relative "realtime/adapters"

module Igniter
  module Plugins
    module View
      module Tailwind
        module Realtime
          module_function

          def render_head(head, config:, projections:, hook_name: nil, include_mermaid: false, extra_script: nil)
            head.tag(:script, src: Tailwind::MERMAID_CDN_URL) if include_mermaid
            head.tag(:script, type: "text/javascript") do |script|
              script.raw(client_script(config: config, projections: projections, hook_name: hook_name, include_mermaid: include_mermaid))
            end
            return unless extra_script

            head.tag(:script, type: "text/javascript") do |script|
              script.raw(extra_script)
            end
          end

          def client_script(config:, projections:, hook_name: nil, include_mermaid: false)
            <<~JAVASCRIPT
              (() => {
                const config = #{JSON.generate(config)};
                const projections = #{JSON.generate(projections)};
                const hookName = #{JSON.generate(hook_name)};
                const includeMermaid = #{include_mermaid ? "true" : "false"};

                const resolvePath = (payload, path) => {
                  if (!path) return undefined;
                  return String(path).split(".").reduce((memo, key) => memo == null ? undefined : memo[key], payload);
                };

                const chartValue = (chartId, key) => {
                  const node = document.querySelector(`[data-chart-id="${chartId}"] [data-chart-value="${key}"]`);
                  return Number(node?.textContent || 0);
                };

                const helpers = {
                  updateGeneratedAt(value) {
                    document.querySelectorAll("[data-live-generated-at]").forEach((node) => {
                      node.textContent = value;
                    });
                  },

                  setMetric(metricId, value) {
                    const node = document.querySelector(`[data-metric-value="${metricId}"]`);
                    if (node) node.textContent = String(value);
                  },

                  metricValue(metricId) {
                    const node = document.querySelector(`[data-metric-value="${metricId}"]`);
                    return Number(node?.textContent || 0);
                  },

                  changeMetric(metricId, delta) {
                    helpers.setMetric(metricId, Math.max(0, helpers.metricValue(metricId) + Number(delta || 0)));
                  },

                  updateChart(chartId, items) {
                    const safeItems = Array.isArray(items) ? items : [];
                    const max = safeItems.reduce((memo, item) => Math.max(memo, Number(item?.value || 0)), 0);
                    safeItems.forEach((item) => {
                      const key = String(item?.key || item?.label || "").toLowerCase().replace(/[^a-z0-9]+/g, "_");
                      const valueNode = document.querySelector(`[data-chart-id="${chartId}"] [data-chart-value="${key}"]`);
                      const fillNode = document.querySelector(`[data-chart-id="${chartId}"] [data-chart-fill="${key}"]`);
                      if (valueNode) valueNode.textContent = String(item?.value || 0);
                      if (fillNode) {
                        const percent = max <= 0 ? 0 : (Number(item?.value || 0) / max) * 100;
                        fillNode.style.width = `${percent}%`;
                      }
                    });
                  },

                  changeChart(chartId, key, delta) {
                    const normalizedKey = String(key || "").toLowerCase().replace(/[^a-z0-9]+/g, "_");
                    const nodes = document.querySelectorAll(`[data-chart-id="${chartId}"] [data-chart-value]`);
                    const items = Array.from(nodes).map((node) => {
                      const itemKey = node.dataset.chartValue;
                      return {
                        key: itemKey,
                        value: itemKey === normalizedKey ? Math.max(0, chartValue(chartId, itemKey) + Number(delta || 0)) : chartValue(chartId, itemKey)
                      };
                    });
                    helpers.updateChart(chartId, items);
                  },

                  appendFeed(label, detail, limit = 6, itemClass = null) {
                    const feed = document.querySelector("[data-realtime-feed='true']");
                    if (!feed) return;
                    const placeholder = feed.querySelector("[data-empty-state='true']");
                    if (placeholder) feed.removeChild(placeholder);
                    const item = document.createElement("li");
                    item.className = itemClass || feed.dataset.itemClass || "";
                    item.textContent = `${label} · ${detail}`;
                    feed.prepend(item);
                    while (feed.children.length > limit) {
                      feed.removeChild(feed.lastChild);
                    }
                  },

                  removeEmptyState(selector) {
                    const list = document.querySelector(selector);
                    if (!list) return null;
                    const placeholder = list.querySelector("[data-empty-state='true']");
                    if (placeholder) list.removeChild(placeholder);
                    return list;
                  },

                  humanAge(value) {
                    if (!value) return "-";
                    const seconds = Math.max(0, Math.floor((Date.now() - Date.parse(value)) / 1000));
                    if (seconds < 10) return "just now";
                    if (seconds < 60) return `${seconds}s ago`;
                    const minutes = Math.floor(seconds / 60);
                    if (minutes < 60) return `${minutes}m ago`;
                    const hours = Math.floor(minutes / 60);
                    if (hours < 24) return `${hours}h ago`;
                    return `${Math.floor(hours / 24)}d ago`;
                  },

                  statusToneClass(label) {
                    switch (String(label || "").toLowerCase()) {
                      case "ready":
                      case "configured":
                      case "online":
                      case "healthy":
                        return "border-emerald-400/30 bg-emerald-400/10 text-emerald-200";
                      case "warning":
                      case "stale":
                        return "border-amber-300/30 bg-amber-300/10 text-amber-100";
                      case "degraded":
                      case "offline":
                        return "border-rose-300/30 bg-rose-300/10 text-rose-100";
                      default:
                        return "border-cyan-300/30 bg-cyan-300/10 text-cyan-100";
                    }
                  },

                  applyStatusBadge(node, label, baseClass = "status-badge inline-flex items-center rounded-full border px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.18em]") {
                    if (!node) return;
                    node.className = `${baseClass} ${helpers.statusToneClass(label)}`;
                    node.textContent = String(label);
                  }
                };

                const callHook = (phase, payload) => {
                  if (!hookName) return;
                  const hook = window[hookName];
                  if (typeof hook === "function") hook(helpers, { phase, payload, projections, config });
                };

                const applyOverviewPayload = (payload) => {
                  helpers.updateGeneratedAt(payload.generated_at);
                  Object.entries(projections?.overview?.metrics || {}).forEach(([metricId, path]) => {
                    const value = resolvePath(payload, path);
                    if (value !== undefined) helpers.setMetric(metricId, value);
                  });
                  Object.entries(projections?.overview?.charts || {}).forEach(([chartId, path]) => {
                    const value = resolvePath(payload, path);
                    if (value !== undefined) helpers.updateChart(chartId, value);
                  });
                  if (projections?.overview?.feed !== false) {
                    helpers.appendFeed("overview", `counts updated at ${payload.generated_at}`, projections?.feed_limit || 6);
                  }
                  callHook("overview", payload);
                };

                const applyActivityPayload = (payload) => {
                  const activityProjection = projections?.activity?.cases?.[payload.type] || {};
                  if (activityProjection.feed !== false) {
                    helpers.appendFeed(payload.title || payload.type || "activity", payload.detail || payload.source || "updated", projections?.feed_limit || 6);
                  }
                  Object.entries(activityProjection.metric_deltas || {}).forEach(([metricId, delta]) => {
                    helpers.changeMetric(metricId, delta);
                  });
                  Object.entries(activityProjection.chart_deltas || {}).forEach(([key, delta]) => {
                    const [chartId, chartKey] = String(key).split(".", 2);
                    helpers.changeChart(chartId, chartKey, delta);
                  });
                  callHook("activity", payload);
                };

                const refreshOverview = async () => {
                  try {
                    const response = await fetch(config.overview_path, { headers: { "Accept": "application/json" } });
                    if (!response.ok) return;
                    applyOverviewPayload(await response.json());
                  } catch (error) {
                    console.warn("igniter realtime refresh failed", error);
                  }
                };

                const connectStream = () => {
                  if (!window.EventSource) return false;
                  const stream = new window.EventSource(config.stream_path);
                  stream.addEventListener("overview", (event) => {
                    try {
                      applyOverviewPayload(JSON.parse(event.data));
                    } catch (error) {
                      console.warn("igniter realtime overview parse failed", error);
                    }
                  });
                  stream.addEventListener("activity", (event) => {
                    try {
                      applyActivityPayload(JSON.parse(event.data));
                    } catch (error) {
                      console.warn("igniter realtime activity parse failed", error);
                    }
                  });
                  stream.addEventListener("ping", (event) => {
                    try {
                      const payload = JSON.parse(event.data);
                      helpers.updateGeneratedAt(payload.generated_at);
                      helpers.appendFeed("ping", `heartbeat ${payload.generated_at}`, projections?.feed_limit || 6);
                      callHook("ping", payload);
                    } catch (error) {
                      console.warn("igniter realtime ping parse failed", error);
                    }
                  });
                  stream.addEventListener("error", () => {
                    helpers.appendFeed("stream", "disconnected, polling fallback active", projections?.feed_limit || 6);
                  });
                  helpers.appendFeed("stream", `connected to ${config.stream_path}`, projections?.feed_limit || 6);
                  return true;
                };

                const setupMermaid = () => {
                  if (!includeMermaid) return;
                  const run = () => {
                    if (window.mermaid && !window.__igniterMermaidReady) {
                      window.__igniterMermaidReady = true;
                      window.mermaid.initialize({ startOnLoad: true, theme: "dark", securityLevel: "loose" });
                    }
                  };
                  if (window.mermaid) run();
                  window.addEventListener("load", run);
                };

                document.addEventListener("DOMContentLoaded", () => {
                  callHook("bootstrap", null);
                  setupMermaid();
                  const connected = connectStream();
                  if (!connected) {
                    window.setInterval(refreshOverview, Number(config.poll_interval_seconds || 5) * 1000);
                  }
                });
              })();
            JAVASCRIPT
          end
        end
      end
    end
  end
end
