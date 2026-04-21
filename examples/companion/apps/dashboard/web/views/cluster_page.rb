# frozen_string_literal: true

require "json"
require "igniter-frontend"
require_relative "../../contexts/cluster_context"

module Companion
  module Dashboard
    module Views
      class ClusterPage < Igniter::Frontend::ArbrePage
        template_root __dir__
        template "cluster_page"
        layout "layout"

        def initialize(context:)
          @context = context
        end

        def template_locals
          { page_context: @context }
        end

        def page_title
          @context.title
        end

        def body_class
          companion_theme.fetch(:body_class)
        end

        def main_class
          companion_theme.fetch(:main_class)
        end

        def tailwind_cdn_url
          Igniter::Frontend::Tailwind::PLAY_CDN_URL
        end

        def tailwind_config_script
          "tailwind.config = #{JSON.generate(companion_theme.fetch(:tailwind_config))};"
        end

        def cluster_bootstrap_json
          JSON.generate(@context.cluster_bootstrap_payload)
        end

        def cluster_view_script
          <<~JAVASCRIPT
            (() => {
              const root = document.getElementById("cluster-view-root");
              const bootstrapNode = document.getElementById("cluster-view-bootstrap");
              if (!root || !bootstrapNode) return;

              const elements = {
                canvas: document.getElementById("cluster-view-canvas"),
                historySlider: document.getElementById("cluster-history-slider"),
                historyFeed: document.getElementById("cluster-history-feed"),
                modeBadge: document.getElementById("cluster-live-mode"),
                snapshotMeta: document.getElementById("cluster-snapshot-meta"),
                bufferMeta: document.getElementById("cluster-buffer-meta"),
                liveToggle: document.getElementById("cluster-live-toggle"),
                returnLive: document.getElementById("cluster-return-live"),
                focusPanel: document.getElementById("cluster-focus-panel"),
                rawSnapshot: document.getElementById("cluster-raw-snapshot")
              };

              const state = {
                snapshots: [],
                currentIndex: 0,
                selectedNodeId: null,
                live: true
              };

              const maxSnapshots = 40;
              const overviewPath = root.dataset.overviewPath;
              const pollIntervalMs = Number(root.dataset.pollIntervalSeconds || 4) * 1000;
              const graphColumns = {
                stack: 0,
                runtime_node: 1,
                app: 2,
                assistant_lane: 3,
                assistant_request: 4,
                followup: 5
              };

              const escapeHtml = (value) => String(value == null ? "" : value)
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#39;");

              const resolvePath = (payload, path) => String(path || "")
                .split(".")
                .filter(Boolean)
                .reduce((memo, key) => (memo == null ? undefined : memo[key]), payload);

              const paletteForStatus = (status) => {
                const normalized = String(status || "").toLowerCase();
                if (["ready", "public", "default", "completed", "active", "mounted", "succeeded", "simulated"].includes(normalized)) {
                  return { fill: "rgba(16, 185, 129, 0.18)", stroke: "rgba(52, 211, 153, 0.75)", text: "#d1fae5" };
                }
                if (["open", "pending", "acknowledged", "manual", "warming", "private"].includes(normalized)) {
                  return { fill: "rgba(251, 191, 36, 0.16)", stroke: "rgba(251, 191, 36, 0.72)", text: "#fef3c7" };
                }
                if (["failed", "blocked", "unavailable", "offline", "degraded", "denied"].includes(normalized)) {
                  return { fill: "rgba(244, 63, 94, 0.16)", stroke: "rgba(251, 113, 133, 0.75)", text: "#ffe4e6" };
                }

                return { fill: "rgba(56, 189, 248, 0.14)", stroke: "rgba(125, 211, 252, 0.7)", text: "#e0f2fe" };
              };

              const historyItemClass = (active) => active
                ? "w-full rounded-2xl border border-orange-300/45 bg-orange-300/10 px-3 py-2 text-left text-xs text-orange-100"
                : "w-full rounded-2xl border border-white/10 bg-white/5 px-3 py-2 text-left text-xs text-stone-300 transition hover:border-orange-300/45 hover:text-orange-100";

              const prettyJson = (payload) => JSON.stringify(payload || {}, null, 2);

              const currentSnapshot = () => state.snapshots[state.currentIndex] || state.snapshots[state.snapshots.length - 1] || {};

              const clusterGraph = (snapshot) => resolvePath(snapshot, "visualization.graph") || { nodes: [], edges: [] };

              const graphLayout = (graph) => {
                const columns = new Map();
                Array(graph.nodes || []).forEach((node) => {
                  const kind = String(node.kind || "assistant_request");
                  const column = graphColumns[kind] == null ? 4 : graphColumns[kind];
                  if (!columns.has(column)) columns.set(column, []);
                  columns.get(column).push(node);
                });

                const positions = new Map();
                let maxRows = 1;
                columns.forEach((nodes, column) => {
                  maxRows = Math.max(maxRows, nodes.length);
                  nodes.forEach((node, index) => {
                    positions.set(node.id, {
                      x: 80 + (column * 210),
                      y: 56 + (index * 112)
                    });
                  });
                });

                return {
                  positions,
                  width: Math.max(1280, 80 + (Object.keys(graphColumns).length * 210)),
                  height: Math.max(460, 96 + (maxRows * 112))
                };
              };

              const renderGraph = (snapshot) => {
                if (!elements.canvas) return;
                const graph = clusterGraph(snapshot);
                const layout = graphLayout(graph);
                const edgeMarkup = Array(graph.edges || []).map((edge) => {
                  const source = layout.positions.get(edge.source);
                  const target = layout.positions.get(edge.target);
                  if (!source || !target) return "";

                  const startX = source.x + 164;
                  const startY = source.y + 34;
                  const endX = target.x;
                  const endY = target.y + 34;
                  const offset = Math.max(36, Math.abs(endX - startX) / 2);
                  const palette = paletteForStatus(edge.status);

                  return [
                    '<path d="M ', startX, " ", startY,
                    " C ", startX + offset, " ", startY,
                    ", ", endX - offset, " ", endY,
                    ", ", endX, " ", endY,
                    '" fill="none" stroke="', palette.stroke,
                    '" stroke-width="2" stroke-opacity="0.85" />'
                  ].join("");
                }).join("");

                const nodeMarkup = Array(graph.nodes || []).map((node) => {
                  const position = layout.positions.get(node.id);
                  if (!position) return "";

                  const palette = paletteForStatus(node.status);
                  const selected = state.selectedNodeId === node.id;
                  const label = escapeHtml(node.label);
                  const detail = escapeHtml(node.detail);
                  const status = escapeHtml(node.status);
                  const strokeWidth = selected ? 3 : 1.5;
                  const dash = node.emphasis === "primary" ? "" : ' stroke-dasharray="4 3"';

                  return [
                    '<g class="cluster-node" data-node-id="', escapeHtml(node.id), '" style="cursor:pointer">',
                    '<rect x="', position.x, '" y="', position.y, '" width="164" height="68" rx="18" fill="', palette.fill,
                    '" stroke="', palette.stroke, '" stroke-width="', strokeWidth, '"', dash, " />",
                    '<text x="', position.x + 14, '" y="', position.y + 24, '" fill="', palette.text,
                    '" font-size="13" font-weight="700">', label, "</text>",
                    '<text x="', position.x + 14, '" y="', position.y + 42, '" fill="#d6d3d1" font-size="11">', escapeHtml(node.kind), "</text>",
                    '<text x="', position.x + 14, '" y="', position.y + 58, '" fill="#a8a29e" font-size="10">', status, " · ", detail, "</text>",
                    "</g>"
                  ].join("");
                }).join("");

                elements.canvas.innerHTML = [
                  '<svg viewBox="0 0 ', layout.width, " ", layout.height,
                  '" class="h-[28rem] w-full rounded-[28px] border border-white/10 bg-[radial-gradient(circle_at_top_left,rgba(251,191,36,0.12),transparent_18rem),linear-gradient(180deg,rgba(28,25,23,0.96),rgba(12,10,9,0.98))]">',
                  '<rect x="0" y="0" width="', layout.width, '" height="', layout.height, '" fill="transparent" />',
                  edgeMarkup,
                  nodeMarkup,
                  "</svg>"
                ].join("");

                elements.canvas.querySelectorAll("[data-node-id]").forEach((node) => {
                  node.addEventListener("click", () => {
                    state.selectedNodeId = node.dataset.nodeId;
                    render();
                  });
                });
              };

              const relatedEdges = (snapshot, nodeId) => {
                const graph = clusterGraph(snapshot);
                return Array(graph.edges || []).filter((edge) => edge.source === nodeId || edge.target === nodeId);
              };

              const renderFocus = (snapshot) => {
                if (!elements.focusPanel) return;
                const graph = clusterGraph(snapshot);
                const nodes = Array(graph.nodes || []);
                const focused = nodes.find((node) => node.id === state.selectedNodeId) || nodes[0];

                if (!focused) {
                  elements.focusPanel.innerHTML = '<div class="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-stone-300">No graph nodes available yet.</div>';
                  return;
                }

                state.selectedNodeId ||= focused.id;
                const connections = relatedEdges(snapshot, focused.id);
                const palette = paletteForStatus(focused.status);

                elements.focusPanel.innerHTML = [
                  '<div class="space-y-4">',
                  '<div class="rounded-3xl border border-white/10 bg-white/5 p-4">',
                  '<div class="flex flex-wrap items-center gap-3">',
                  '<strong class="text-base font-semibold text-white">', escapeHtml(focused.label), "</strong>",
                  '<span class="inline-flex items-center rounded-full border px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.18em]" style="border-color:', palette.stroke, "; color:", palette.text, "; background:", palette.fill, '">', escapeHtml(focused.status), "</span>",
                  "</div>",
                  '<div class="mt-2 text-sm text-stone-300">', escapeHtml(focused.detail), "</div>",
                  '<div class="mt-3 text-xs uppercase tracking-[0.18em] text-stone-500">', escapeHtml(focused.kind), " · id=", escapeHtml(focused.id), "</div>",
                  "</div>",
                  '<div class="rounded-3xl border border-white/10 bg-[#160f0d] p-4">',
                  '<div class="text-xs font-semibold uppercase tracking-[0.18em] text-stone-400">Connections</div>',
                  '<ul class="mt-3 space-y-2 text-sm text-stone-300">',
                  (connections.length ? connections.map((edge) => [
                    "<li>",
                    escapeHtml(edge.source), " → ", escapeHtml(edge.target),
                    '<span class="text-stone-500"> · ', escapeHtml(edge.kind), " · ", escapeHtml(edge.label), "</span>",
                    "</li>"
                  ].join("")).join("") : '<li class="text-stone-500">No edges connected to this node.</li>'),
                  "</ul>",
                  "</div>",
                  "</div>"
                ].join("");
              };

              const updateFields = (snapshot) => {
                document.querySelectorAll("[data-cluster-field]").forEach((node) => {
                  const value = resolvePath(snapshot, node.dataset.clusterField);
                  node.textContent = value == null || value === "" ? "--" : String(value);
                });
              };

              const renderRawSnapshot = (snapshot) => {
                if (!elements.rawSnapshot) return;
                const preview = {
                  generated_at: snapshot.generated_at,
                  counts: snapshot.counts,
                  visualization: snapshot.visualization
                };
                elements.rawSnapshot.textContent = prettyJson(preview);
              };

              const renderHistory = () => {
                const latestIndex = Math.max(0, state.snapshots.length - 1);
                const latest = state.snapshots[latestIndex] || {};
                const current = currentSnapshot();

                if (elements.historySlider) {
                  elements.historySlider.max = String(latestIndex);
                  elements.historySlider.value = String(state.currentIndex);
                }

                if (elements.modeBadge) {
                  elements.modeBadge.textContent = state.live ? "Live" : "Paused";
                  elements.modeBadge.className = state.live
                    ? "inline-flex items-center rounded-full border border-emerald-400/30 bg-emerald-400/10 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.18em] text-emerald-200"
                    : "inline-flex items-center rounded-full border border-amber-300/30 bg-amber-300/10 px-3 py-1 text-[11px] font-semibold uppercase tracking-[0.18em] text-amber-100";
                }

                if (elements.snapshotMeta) {
                  const position = state.currentIndex + 1;
                  elements.snapshotMeta.textContent = `snapshot ${position}/${latestIndex + 1} · captured=${current.generated_at || "--"}`;
                }

                if (elements.bufferMeta) {
                  elements.bufferMeta.textContent = latest.generated_at
                    ? `latest=${latest.generated_at}`
                    : "waiting for first snapshot";
                }

                if (elements.historyFeed) {
                  const recent = state.snapshots.slice(-8).map((entry, offset, array) => ({
                    entry,
                    index: state.snapshots.length - array.length + offset
                  })).reverse();

                  elements.historyFeed.innerHTML = recent.map(({ entry, index }) => [
                    '<li>',
                    '<button type="button" class="', historyItemClass(index === state.currentIndex),
                    '" data-history-index="', index, '">',
                    '<span class="block font-semibold">', escapeHtml(entry.generated_at || `snapshot ${index + 1}`), "</span>",
                    '<span class="mt-1 block text-[11px] text-stone-400">', escapeHtml(resolvePath(entry, "visualization.timeline_entry.summary") || "--"), "</span>",
                    "</button>",
                    "</li>"
                  ].join("")).join("");

                  elements.historyFeed.querySelectorAll("[data-history-index]").forEach((button) => {
                    button.addEventListener("click", () => {
                      state.currentIndex = Number(button.dataset.historyIndex);
                      state.live = state.currentIndex === latestIndex;
                      render();
                    });
                  });
                }
              };

              const render = () => {
                const snapshot = currentSnapshot();
                updateFields(snapshot);
                renderGraph(snapshot);
                renderFocus(snapshot);
                renderRawSnapshot(snapshot);
                renderHistory();
              };

              const pushSnapshot = (payload) => {
                if (!payload || !payload.generated_at) return false;
                if (state.snapshots.some((entry) => entry.generated_at === payload.generated_at)) return false;

                state.snapshots.push(payload);
                if (state.snapshots.length > maxSnapshots) state.snapshots = state.snapshots.slice(-maxSnapshots);
                if (state.live) state.currentIndex = state.snapshots.length - 1;
                return true;
              };

              const refresh = async () => {
                try {
                  const response = await fetch(overviewPath, { headers: { Accept: "application/json" } });
                  if (!response.ok) return;
                  const payload = await response.json();
                  const changed = pushSnapshot(payload);
                  if (changed || state.live) render();
                } catch (error) {
                  console.warn("cluster overview refresh failed", error);
                }
              };

              if (elements.historySlider) {
                elements.historySlider.addEventListener("input", (event) => {
                  state.currentIndex = Number(event.currentTarget.value || 0);
                  state.live = state.currentIndex === state.snapshots.length - 1;
                  render();
                });
              }

              if (elements.liveToggle) {
                elements.liveToggle.addEventListener("click", () => {
                  state.live = !state.live;
                  if (state.live) state.currentIndex = state.snapshots.length - 1;
                  render();
                });
              }

              if (elements.returnLive) {
                elements.returnLive.addEventListener("click", () => {
                  state.live = true;
                  state.currentIndex = Math.max(0, state.snapshots.length - 1);
                  render();
                });
              }

              try {
                const initialPayload = JSON.parse(bootstrapNode.textContent || "{}");
                state.snapshots = initialPayload.generated_at ? [initialPayload] : [];
                state.currentIndex = Math.max(0, state.snapshots.length - 1);
                render();
              } catch (error) {
                console.warn("cluster bootstrap parse failed", error);
              }

              window.setInterval(refresh, pollIntervalMs);
            })();
          JAVASCRIPT
        end

        private

        def companion_theme
          @companion_theme ||= Igniter::Frontend::Tailwind.theme(:companion)
        end
      end
    end
  end
end
