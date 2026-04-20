# frozen_string_literal: true

require "cgi"
require "uri"

module Igniter
  class App
    module Observability
      class OperatorConsoleHandler
        def initialize(app_class:, api_path: "/api/operator", action_path: "/api/operator/actions", title: nil)
          @app_class = app_class
          @api_path = api_path
          @action_path = action_path
          @title = title
        end

        def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
          request_params = query_params(env).merge(symbolize_keys(params))

          {
            status: 200,
            body: render_page(base_path: env["SCRIPT_NAME"].to_s, request_params: request_params),
            headers: { "Content-Type" => "text/html; charset=utf-8" }
          }
        end

        private

        attr_reader :app_class, :api_path, :action_path, :title

        def render_page(base_path:, request_params:)
          resolved_api_path = route(base_path, api_path)
          resolved_action_path = route(base_path, action_path)
          initial = initial_values(request_params)

          <<~HTML
            <!doctype html>
            <html lang="en">
              <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>#{h(page_title)}</title>
                <style>
                  :root { color-scheme: light; }
                  body { margin: 0; font-family: ui-sans-serif, system-ui, sans-serif; background: #f5f1e8; color: #1c1b18; }
                  main { max-width: 1080px; margin: 0 auto; padding: 32px 20px 48px; }
                  .hero, .panel { background: #fffdf9; border: 1px solid #ded4c4; border-radius: 18px; box-shadow: 0 8px 24px rgba(40, 24, 8, 0.06); }
                  .hero { padding: 24px; margin-bottom: 20px; background: linear-gradient(135deg, #fdf8ef, #efe0c8); }
                  .hero h1 { margin: 0 0 8px; font-size: 30px; }
                  .hero p { margin: 8px 0; color: #4b4339; }
                  .meta { font-size: 14px; color: #6b6154; }
                  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 20px; }
                  .panel { padding: 18px; }
                  .filters { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 16px; }
                  label { display: grid; gap: 6px; font-size: 13px; color: #5a5145; }
                  input { border: 1px solid #cdbca3; border-radius: 10px; padding: 10px 12px; font: inherit; background: white; }
                  button { border: 0; border-radius: 999px; padding: 10px 16px; font: inherit; font-weight: 600; background: #0b5f56; color: white; cursor: pointer; }
                  button.secondary { background: #e7dfd0; color: #2f2a22; }
                  .actions { display: flex; gap: 10px; align-items: center; margin-bottom: 16px; flex-wrap: wrap; }
                  .stat { display: grid; gap: 8px; }
                  .stat strong { font-size: 26px; }
                  .hint { font-size: 13px; color: #6b6154; }
                  pre { margin: 0; white-space: pre-wrap; word-break: break-word; font-family: ui-monospace, SFMono-Regular, monospace; font-size: 13px; color: #2b2621; }
                  code { font-family: ui-monospace, SFMono-Regular, monospace; }
                  table { width: 100%; border-collapse: collapse; font-size: 14px; }
                  th, td { text-align: left; padding: 10px 8px; border-top: 1px solid #ede4d6; vertical-align: top; }
                  th { font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; color: #6b6154; }
                  .empty { color: #6b6154; font-style: italic; }
                  a { color: #0b5f56; }
                </style>
              </head>
              <body>
                <main>
                  <section class="hero">
                    <h1>#{h(page_title)}</h1>
                    <p>Operator-facing view over agent sessions, orchestration inbox state, and persisted ignite targets.</p>
                    <p class="meta">app=#{h(app_class.name)} · api=#{h(resolved_api_path)} · actions=#{h(resolved_action_path)}</p>
                  </section>

                  <section class="panel">
                    <div class="filters">
                      <label>
                        Record ID
                        <input id="record_id" name="id" placeholder="ignite:edge-1" value="#{h(initial[:id])}">
                      </label>
                      <label>
                        Graph
                        <input id="graph" name="graph" placeholder="AnonymousContract" value="#{h(initial[:graph])}">
                      </label>
                      <label>
                        Execution ID
                        <input id="execution_id" name="execution_id" placeholder="execution id" value="#{h(initial[:execution_id])}">
                      </label>
                      <label>
                        Node
                        <input id="node" name="node" placeholder="approval" value="#{h(initial[:node])}">
                      </label>
                      <label>
                        Status
                        <input id="status" name="status" placeholder="open,resolved" value="#{h(initial[:status])}">
                      </label>
                      <label>
                        Combined State
                        <input id="combined_state" name="combined_state" placeholder="joined,ignition" value="#{h(initial[:combined_state])}">
                      </label>
                      <label>
                        Lane
                        <input id="lane" name="lane" placeholder="ops_review" value="#{h(initial[:lane])}">
                      </label>
                      <label>
                        Queue
                        <input id="queue" name="queue" placeholder="manual-review" value="#{h(initial[:queue])}">
                      </label>
                      <label>
                        Assignee
                        <input id="assignee" name="assignee" placeholder="ops:alice" value="#{h(initial[:assignee])}">
                      </label>
                      <label>
                        Latest Action Actor
                        <input id="latest_action_actor" name="latest_action_actor" placeholder="alex" value="#{h(initial[:latest_action_actor])}">
                      </label>
                      <label>
                        Latest Action Origin
                        <input id="latest_action_origin" name="latest_action_origin" placeholder="dashboard_ui" value="#{h(initial[:latest_action_origin])}">
                      </label>
                      <label>
                        Latest Action Source
                        <input id="latest_action_source" name="latest_action_source" placeholder="operator_action_api" value="#{h(initial[:latest_action_source])}">
                      </label>
                      <label>
                        Order By
                        <input id="order_by" name="order_by" placeholder="status" value="#{h(initial[:order_by])}">
                      </label>
                      <label>
                        Direction
                        <input id="direction" name="direction" placeholder="asc" value="#{h(initial[:direction])}">
                      </label>
                      <label>
                        Limit
                        <input id="limit" name="limit" value="#{h(initial[:limit])}" inputmode="numeric">
                      </label>
                    </div>
                    <div class="actions">
                      <button id="refresh" type="button">Load Overview</button>
                      <button id="clear" class="secondary" type="button">Clear Execution Scope</button>
                      <a id="open_api" href="#{h(resolved_api_path)}">Open JSON API</a>
                      <a href="#records">Jump to records</a>
                    </div>
                    <p class="hint">Leave graph and execution id empty for the app-wide operator field, or provide both to inspect one durable execution. Filters apply to both the API and this console.</p>
                  </section>

                  <section class="panel" style="margin-bottom: 20px;">
                    <h2>Operator Actions</h2>
                    <p class="hint">Use row actions to `wake`, `approve`, `reply`, `complete`, `handoff`, or `dismiss` orchestration items. Runtime-completing actions try to resume through durable store state when available.</p>
                    <div class="filters" style="margin-top: 16px;">
                      <label>
                        Action Actor
                        <input id="action_actor" name="action_actor" placeholder="operator-console" value="#{h(initial[:action_actor])}">
                      </label>
                    </div>
                  </section>

                  <section class="grid">
                    <article class="panel stat">
                      <span class="hint">Total</span>
                      <strong id="total">0</strong>
                    </article>
                    <article class="panel stat">
                      <span class="hint">Joined</span>
                      <strong id="joined">0</strong>
                    </article>
                    <article class="panel stat">
                      <span class="hint">Live Sessions</span>
                      <strong id="live_sessions">0</strong>
                    </article>
                    <article class="panel stat">
                      <span class="hint">Inbox Items</span>
                      <strong id="inbox_items">0</strong>
                    </article>
                  </section>

                  <section class="panel" style="margin-bottom: 20px;">
                    <h2>Summary</h2>
                    <pre id="summary">waiting for data…</pre>
                  </section>

                  <section class="panel" style="margin-bottom: 20px;">
                    <h2>Record Detail</h2>
                    <pre id="record_detail">select a record…</pre>
                  </section>

                  <section class="panel" id="records">
                    <h2>Records</h2>
                    <table>
                      <thead>
                        <tr>
                          <th>Node</th>
                          <th>State</th>
                          <th>Status</th>
                          <th>Lane / Queue</th>
                          <th>Assignee</th>
                          <th>Execution</th>
                          <th>History</th>
                          <th>Actions</th>
                        </tr>
                      </thead>
                      <tbody id="records_body">
                        <tr><td colspan="8" class="empty">waiting for data…</td></tr>
                      </tbody>
                    </table>
                  </section>
                </main>

                <script>
                  (() => {
                    const apiPath = #{resolved_api_path.inspect};
                    const recordIdInput = document.getElementById("record_id");
                    const graphInput = document.getElementById("graph");
                    const executionInput = document.getElementById("execution_id");
                    const nodeInput = document.getElementById("node");
                    const statusInput = document.getElementById("status");
                    const combinedStateInput = document.getElementById("combined_state");
                    const laneInput = document.getElementById("lane");
                    const queueInput = document.getElementById("queue");
                    const assigneeInput = document.getElementById("assignee");
                    const latestActionActorInput = document.getElementById("latest_action_actor");
                    const latestActionOriginInput = document.getElementById("latest_action_origin");
                    const latestActionSourceInput = document.getElementById("latest_action_source");
                    const actionActorInput = document.getElementById("action_actor");
                    const orderByInput = document.getElementById("order_by");
                    const directionInput = document.getElementById("direction");
                    const limitInput = document.getElementById("limit");
                    const openApiLink = document.getElementById("open_api");
                    const total = document.getElementById("total");
                    const joined = document.getElementById("joined");
                    const liveSessions = document.getElementById("live_sessions");
                    const inboxItems = document.getElementById("inbox_items");
                    const summary = document.getElementById("summary");
                    const recordDetail = document.getElementById("record_detail");
                    const recordsBody = document.getElementById("records_body");

                    function buildParams(includeExecutionScope = true) {
                      const params = new URLSearchParams();

                      if (includeExecutionScope && (graphInput.value.trim() || executionInput.value.trim())) {
                        params.set("graph", graphInput.value.trim());
                        params.set("execution_id", executionInput.value.trim());
                      }

                      [
                        [recordIdInput, "id"],
                        [nodeInput, "node"],
                        [statusInput, "status"],
                        [combinedStateInput, "combined_state"],
                        [laneInput, "lane"],
                        [queueInput, "queue"],
                        [assigneeInput, "assignee"],
                        [latestActionActorInput, "latest_action_actor"],
                        [latestActionOriginInput, "latest_action_origin"],
                        [latestActionSourceInput, "latest_action_source"],
                        [orderByInput, "order_by"],
                        [directionInput, "direction"],
                        [limitInput, "limit"]
                      ].forEach(([input, name]) => {
                        if (input.value.trim()) {
                          params.set(name, input.value.trim());
                        }
                      });

                      return params;
                    }

                    function setOpenApiLink(params) {
                      const query = params.toString();
                      openApiLink.href = query ? `${apiPath}?${query}` : apiPath;
                    }

                    const actionPath = #{resolved_action_path.inspect};

                    function setSummary(payload) {
                      total.textContent = String(payload.summary?.total ?? 0);
                      joined.textContent = String(payload.summary?.joined_records ?? 0);
                      liveSessions.textContent = String(payload.summary?.live_sessions ?? 0);
                      inboxItems.textContent = String(payload.summary?.inbox_items ?? 0);
                      summary.textContent = JSON.stringify(payload.summary ?? {}, null, 2);
                    }

                    function actionButtons(record) {
                      const allowed = Array.isArray(record.policy?.allowed_operations) ? record.policy.allowed_operations : [];
                      if (allowed.length === 0) {
                        return "";
                      }

                      return allowed.map((operation) => {
                        const attrs = [
                          ["data-operator-id", String(record.id || "")],
                          ["data-operator-operation", String(operation || "")],
                          ["data-operator-graph", String(record.graph || "")],
                          ["data-operator-execution", String(record.execution_id || "")]
                        ].map(([name, value]) => `${name}="${escapeHtml(value)}"`).join(" ");

                        return `<button type="button" class="secondary" ${attrs}>${escapeHtml(String(operation))}</button>`;
                      }).join(" ");
                    }

                    function renderRecords(payload) {
                      const records = Array.isArray(payload.records) ? payload.records : [];
                      if (records.length === 0) {
                        recordsBody.innerHTML = '<tr><td colspan="8" class="empty">no records</td></tr>';
                        recordDetail.textContent = "no record selected";
                        return;
                      }

                      renderRecordDetail(records[0]);
                      recordsBody.innerHTML = records.map((record) => {
                        const lane = record.lane?.name || record.lane || "—";
                        const queue = record.queue || "—";
                        const assignee = record.assignee || "—";
                        const execution = record.graph && record.execution_id
                          ? `${record.graph} / ${record.execution_id}`
                          : "—";
                        const latestEvent = record.latest_action_event || {};
                        const history = record.action_history_count
                          ? `${record.action_history_count} events · ${String(latestEvent.event || "unknown")} · ${String(latestEvent.actor || latestEvent.source || "unspecified")}`
                          : "—";
                        const scopedParams = new URLSearchParams();
                        if (record.id) {
                          scopedParams.set("id", String(record.id));
                        }
                        if (record.graph && record.execution_id) {
                          scopedParams.set("graph", String(record.graph));
                          scopedParams.set("execution_id", String(record.execution_id));
                        }
                        if (record.node) {
                          scopedParams.set("node", String(record.node));
                        }
                        if (limitInput.value.trim()) {
                          scopedParams.set("limit", limitInput.value.trim());
                        }
                        const inspectPath = scopedParams.toString()
                          ? `${window.location.pathname}?${scopedParams.toString()}`
                          : window.location.pathname;
                        const inspectApiPath = scopedParams.toString()
                          ? `${apiPath}?${scopedParams.toString()}`
                          : apiPath;
                        const inspectLinks = record.id
                          ? `<a href="${escapeHtml(inspectPath)}">Inspect</a> · <a href="${escapeHtml(inspectApiPath)}">JSON</a>`
                          : "—";
                        const operatorButtons = actionButtons(record);
                        const actions = operatorButtons
                          ? `${inspectLinks}<br>${operatorButtons}`
                          : inspectLinks;
                        return `<tr>
                          <td><code>${escapeHtml(String(record.node || "—"))}</code></td>
                          <td>${escapeHtml(String(record.combined_state || "—"))}</td>
                          <td>${escapeHtml(String(record.status || "—"))}</td>
                          <td>${escapeHtml(`${lane} / ${queue}`)}</td>
                          <td>${escapeHtml(String(assignee))}</td>
                          <td>${escapeHtml(execution)}</td>
                          <td>${escapeHtml(history)}</td>
                          <td>${actions}</td>
                        </tr>`;
                      }).join("");
                    }

                    function renderRecordDetail(record) {
                      const detail = {
                        id: record.id || null,
                        node: record.node || null,
                        combined_state: record.combined_state || null,
                        status: record.status || null,
                        action: record.action || null,
                        queue: record.queue || null,
                        assignee: record.assignee || null,
                        phase: record.phase || null,
                        reply_mode: record.reply_mode || null,
                        graph: record.graph || null,
                        execution_id: record.execution_id || null,
                        latest_action_event: record.latest_action_event || null,
                        timeline: record.ignition_timeline || record.action_history || []
                      };

                      recordDetail.textContent = JSON.stringify(detail, null, 2);
                    }

                    function escapeHtml(value) {
                      return value
                        .replaceAll("&", "&amp;")
                        .replaceAll("<", "&lt;")
                        .replaceAll(">", "&gt;")
                        .replaceAll('"', "&quot;");
                    }

                    async function loadOverview() {
                      const params = buildParams(true);
                      setOpenApiLink(params);

                      const response = await fetch(params.toString() ? `${apiPath}?${params.toString()}` : apiPath);
                      const payload = await response.json();
                      if (!response.ok) {
                        throw new Error(payload.error || `request failed with status ${response.status}`);
                      }

                      setSummary(payload);
                      renderRecords(payload);
                    }

                    async function postAction(payload) {
                      const response = await fetch(actionPath, {
                        method: "POST",
                        headers: {
                          "Content-Type": "application/json",
                          "Accept": "application/json"
                        },
                        body: JSON.stringify(payload)
                      });
                      const result = await response.json();
                      if (!response.ok) {
                        throw new Error(result.error || `action failed with status ${response.status}`);
                      }

                      return result;
                    }

                    async function runOperatorAction(button) {
                      const payload = {
                        id: button.dataset.operatorId,
                        operation: button.dataset.operatorOperation
                      };

                      if (button.dataset.operatorGraph && button.dataset.operatorExecution) {
                        payload.graph = button.dataset.operatorGraph;
                        payload.execution_id = button.dataset.operatorExecution;
                      }

                      if (actionActorInput.value.trim()) {
                        payload.actor = actionActorInput.value.trim();
                      }
                      payload.origin = "operator_console";
                      payload.actor_channel = window.location.pathname;

                      const operation = payload.operation;
                      let note = "";

                      if (["approve", "reply", "complete"].includes(operation)) {
                        const rawValue = window.prompt(`Value for ${operation} (JSON or plain text)`, "");
                        if (rawValue === null) {
                          return;
                        }
                        if (rawValue !== "") {
                          try {
                            payload.value = JSON.parse(rawValue);
                          } catch (error) {
                            payload.value = rawValue;
                          }
                        }
                        note = window.prompt(`Note for ${operation} (optional)`, "") || "";
                      } else if (operation === "handoff") {
                        const assignee = window.prompt("Assignee (optional)", "") || "";
                        const queue = window.prompt("Queue (optional)", "") || "";
                        const channel = window.prompt("Channel (optional)", "") || "";
                        if (!assignee && !queue && !channel) {
                          throw new Error("handoff requires assignee, queue, or channel");
                        }
                        payload.assignee = assignee;
                        payload.queue = queue;
                        payload.channel = channel;
                        note = window.prompt("Note for handoff (optional)", "") || "";
                      } else {
                        note = window.prompt(`Note for ${operation} (optional)`, "") || "";
                      }

                      if (note) {
                        payload.note = note;
                      }

                      await postAction(payload);
                      await loadOverview();
                    }

                    document.getElementById("refresh").addEventListener("click", () => {
                      loadOverview().catch((error) => {
                        summary.textContent = error.message;
                        recordsBody.innerHTML = '<tr><td colspan="8" class="empty">failed to load records</td></tr>';
                      });
                    });

                    document.getElementById("clear").addEventListener("click", () => {
                      graphInput.value = "";
                      executionInput.value = "";
                      recordIdInput.value = "";
                      nodeInput.value = "";
                      statusInput.value = "";
                      laneInput.value = "";
                      queueInput.value = "";
                      assigneeInput.value = "";
                      latestActionActorInput.value = "";
                      latestActionOriginInput.value = "";
                      latestActionSourceInput.value = "";
                      orderByInput.value = "";
                      directionInput.value = "asc";
                      loadOverview().catch((error) => {
                        summary.textContent = error.message;
                        recordsBody.innerHTML = '<tr><td colspan="8" class="empty">failed to load records</td></tr>';
                      });
                    });

                    recordsBody.addEventListener("click", (event) => {
                      const button = event.target.closest("button[data-operator-operation]");
                      if (!button) {
                        return;
                      }

                      runOperatorAction(button).catch((error) => {
                        summary.textContent = error.message;
                      });
                    });

                    loadOverview().catch((error) => {
                      summary.textContent = error.message;
                      recordsBody.innerHTML = '<tr><td colspan="8" class="empty">failed to load records</td></tr>';
                    });
                  })();
                </script>
              </body>
            </html>
          HTML
        end

        def route(base_path, suffix)
          [base_path.to_s.sub(%r{/+\z}, ""), suffix].join
        end

        def query_params(env)
          URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end

        def symbolize_keys(hash)
          hash.to_h.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end

        def initial_values(request_params)
          {
            graph: request_params[:graph].to_s,
            id: request_params[:id].to_s,
            execution_id: request_params[:execution_id].to_s,
            node: request_params[:node].to_s,
            status: request_params[:status].to_s,
            combined_state: request_params[:combined_state].to_s,
            lane: request_params[:lane].to_s,
            queue: request_params[:queue].to_s,
            assignee: request_params[:assignee].to_s,
            latest_action_actor: request_params[:latest_action_actor].to_s,
            latest_action_origin: request_params[:latest_action_origin].to_s,
            latest_action_source: request_params[:latest_action_source].to_s,
            action_actor: request_params[:action_actor].to_s.empty? ? "operator-console" : request_params[:action_actor].to_s,
            order_by: request_params[:order_by].to_s,
            direction: request_params[:direction].to_s.empty? ? "asc" : request_params[:direction].to_s,
            limit: request_params[:limit].to_s.empty? ? "20" : request_params[:limit].to_s
          }.freeze
        end

        def h(value)
          CGI.escapeHTML(value.to_s)
        end

        def page_title
          title || "#{app_class.name} Operator Console"
        end
      end
    end
  end
end
