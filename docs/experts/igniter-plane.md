# Igniter Plane — Living Graph Canvas

Date: 2026-04-25.
Author: external expert review.
Status: research proposal.
Category: interaction paradigm / visualization layer.

---

## 1. The Premise

Every distributed system has an invisible topology. Contracts execute, agents
plan, data flows, sessions open and close, cluster nodes exchange, processes
block and unblock. Today you observe this through dashboards, logs, status
pages — each looking at a slice. The slices don't connect. You move between
tools, lose context, reconstruct the picture manually.

What if the entire system existed in one navigable plane?

Not a monitoring dashboard. Not a chat. Not a form.

A **floating, living graph** where every process, agent, contract, data
artifact, and session is a node you can see, navigate to, query, command,
and expand — from the same surface.

The user sees the system **from the bird's eye**. Everything is visible at
once. The user zooms in on what matters, zooms out to see the whole. Nodes
breathe with activity. Edges carry live data. Agents pulse when working. The
system is not a service to be observed — it is a **territory to be navigated**.

This is **Igniter Plane**.

---

## 2. Why This Matters Now

Interactive agent applications create a new observability problem.

Traditional monitoring answers: is the system up? What is the error rate?
Where is the bottleneck?

Interactive agent applications require answers to: **who is working on what,
what is waiting for me, what did the agent decide, what is blocked, where did
the data go, who owns this task now?**

These are relational questions. They require seeing the connections between
things, not just the state of individual things. A status dashboard can't
answer "show me everything blocked because of this one failing contract"
without knowing the graph.

Igniter already has the graph. The contracts form a graph. The agent
session model is a graph. The cluster mesh is a graph. The Runtime Observatory
(already in research horizon) is literally proposing a unified observation
graph over all artifacts.

**Igniter Plane is the interactive visual layer over the Runtime Observatory
Graph.** It takes the read-only observation frame — nodes, edges, facets,
evidence, blockers — and makes it spatial, navigable, and interactive.

---

## 3. The Core Mental Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  IGNITER PLANE  ──────────────────── bird's eye ──────────────── live  │
│                                                                         │
│        ●──────────────────●                ●                            │
│        │ TaskWorkflow     │ Coordinator    │ UserSession                │
│        │ ○ running        │ ● planning     │ ○ waiting                  │
│        │                  │                │                            │
│        ●──────────────────●────────────────●                            │
│                           │                                             │
│                    ◌──────●                                             │
│                    │ AuthRefactor   ←─────  ●  TaskService              │
│                    │ ○ pending              │  ○ idle                   │
│                    │                        │                           │
│                    ●──────────────────◌─────●                           │
│                    │ PlanResult       │ Output:plan                     │
│                    │ ✓ ready          │ flowing →                       │
│                                                                         │
│  [ Search nodes... ]  [ Filter: type=agent ]  [ Views ▼ ]  [ Zoom: 2] │
└─────────────────────────────────────────────────────────────────────────┘
```

Every entity in the system is a **node**:
- A running contract execution
- An agent actor
- A data output (flowing between contracts)
- A user session
- A cluster peer
- An event stream
- A service instance
- A pending decision

Every **edge** is a relationship:
- `flows_to` — data output connects to the next consumer
- `blocks` — this node is waiting on that one
- `owned_by` — session belongs to this agent
- `triggers` — event activates this contract
- `routes_to` — cluster peer handles this agent
- `evidenced_by` — fact supports this decision

The user **navigates this graph** at whatever scale makes sense. From far away:
shapes and colors. Closer: names and status. Up close: full interactive surface
(using the UI Kit components designed alongside this proposal).

---

## 4. Node Taxonomy

### 4.1 Process Node

A running or completed contract execution.

```
● TaskWorkflow:e42f
  ○ running
  3 nodes resolved
  2 pending
```

Visual: square with rounded corners (processes are bounded).
Color: based on status — cobalt (running), amber (waiting), forest (done), rust (failed).
Size: scales with number of dependents.

Properties:
- execution id
- contract name
- status: pending / running / waiting / completed / failed
- active nodes: resolved vs total
- cache hit rate
- last event timestamp

---

### 4.2 Agent Node

A proactive agent actor. Always present even when idle.

```
⚡ Coordinator
   ● planning
   "auth refactor breakdown"
   started 3m ago
```

Visual: hexagon (agents are decision-making, not just processing).
Color: cobalt (active), grey (idle), amber (waiting for input), rust (error).
Pulse animation when active.

Properties:
- agent name
- status: idle / active / waiting / blocked / offline
- current task description (if active)
- time in current state
- pending decisions count
- linked sessions

---

### 4.3 Data Node

An output value flowing between producers and consumers. Ephemeral — appears
when data is in motion, fades when consumed.

```
◌ plan_result
  ✓ ready
  flowing → AuthWorkflow
  42 bytes
```

Visual: circle (data is round, flows).
Color: green (flowing/ready), grey (consumed/cached), amber (stale).
Animated — particles move along the edge toward the consumer.

Properties:
- node name
- value summary (truncated)
- size
- cache status: fresh / stale / cached / streaming
- producer → consumer

---

### 4.4 Session Node

An open user or agent interaction session.

```
○ FlowSession:9a3c
  wizard_onboarding
  step 2/4
  waiting for: name, goal
```

Visual: parallelogram (sessions have direction/progress).
Color: blue-grey (active), amber (needs input), grey (paused).

Properties:
- session id
- flow name
- current step
- pending inputs
- pending actions
- last activity timestamp
- linked agent

---

### 4.5 Event Node

A system or domain event. Appears briefly then becomes part of the timeline.

```
→ task.created
  triage-sensor
  14:23:05
```

Visual: arrow-diamond (events are directional, momentary).
Color: neutral grey. Bright amber flash on arrival.

Properties:
- event type
- payload summary
- timestamp
- source
- linked to which nodes it triggers

---

### 4.6 Service Node

A stateful service instance (TaskManager, SessionStore, etc.).

```
■ TaskService
  ○ idle
  12 tasks, 4 pending
```

Visual: rectangle (services are containers).
Color: neutral (always present, not highlighted unless there's activity).

Properties:
- service name
- status
- key metrics (count, size, rate)
- linked contracts / agents

---

### 4.7 Cluster Peer Node

A remote node in the mesh network. Appears when cluster is running.

```
◆ peer:node-4
  ● active
  capability: ai, compute
  3 agents routed here
```

Visual: diamond (peers are equidistant, distributed).
Color: cobalt (healthy), amber (degraded), rust (unreachable).

Properties:
- peer id
- capabilities
- active workload count
- trust status
- latency
- last heartbeat

---

### 4.8 Decision Node

A pending decision that requires human or agent input.

```
! Plan Approval
  ⚠ waiting: 18min
  requires: human
```

Visual: exclamation octagon (decisions demand attention).
Color: bright amber, pulsing.

Properties:
- decision name
- what is waiting
- who needs to act
- time waiting
- linked evidence
- available choices

---

## 5. Edge Taxonomy

Edges are typed, labeled, and animated when active.

```
────────────────  flows_to     (data is moving)
- - - - - - - -  depends_on   (static dependency)
════════════════  blocks       (critical path, thick)
· · · · · · · ·  evidenced_by (supporting relationship)
── ▶ ── ▶ ── ▶  triggers     (event activating something)
◄ ─── ►         routes_to    (bidirectional routing)
```

When data flows along an edge, small particles animate from source to target.
The speed of particles reflects throughput. Thick edges are critical paths.
Thin edges are loose dependencies.

**Edge types:**

| Type | Visual | Meaning |
|------|--------|---------|
| `flows_to` | animated particles | data output feeds next consumer |
| `depends_on` | dashed line | static dependency declaration |
| `blocks` | bold solid line | node A is waiting on node B |
| `triggers` | arrow sequence | event activates this execution |
| `owns` | circle at source | agent/session owns this process |
| `routes_to` | double arrow | workload routed to peer/agent |
| `evidenced_by` | dotted | fact supports this node's state |
| `handoff_to` | directional curve | ownership being transferred |
| `derived_from` | light dashed | output is a transformation |

---

## 6. Multi-Scale Rendering

The canvas has four zoom levels. The system automatically renders the
appropriate detail level based on viewport.

### Level 0 — Galaxy (full system)

```
  ·   ●   ·   ·   ·
·   ·   ●   ·   ·   ·
  ●   ·   ●   ·   ●
·   ·   ·   ●   ·   ·
  ·   ●   ·   ·   ●
```

Just dots, colored by status. Size = importance (number of dependents).
Clusters of related nodes appear as dense regions. The user sees the shape
of the system: where are the dense areas, where are the isolated nodes, where
is the action?

This is the **tactical overview**. Like a starcraft minimap. You see hotspots,
not details.

---

### Level 1 — Cluster (region of the system)

```
  ┌──────────┐        ┌──────────┐
  │● coord   │────────│○ task-svc│
  │ planning │ owns   │ 12 tasks │
  └──────────┘        └──────────┘
       │
       │ triggers
       ▼
  ┌──────────┐
  │○ plan-   │
  │ session  │
  └──────────┘
```

Node name + status line + key metric. Edges labeled. The user can understand
what this group of nodes is doing without reading details.

---

### Level 2 — Node (specific node)

```
╔════════════════════════════╗
║  ⚡ Coordinator             ║
║  ─────────────────────────  ║
║  ● planning                 ║
║  "auth refactor breakdown"  ║
║  3m 42s in state            ║
║                             ║
║  Tools: 2 running           ║
║  Evidence: 3 sources        ║
║  Confidence: 82%            ║
╚════════════════════════════╝
```

Full node details without opening a panel. The user can understand the
node's state, what it's doing, and what's connected.

---

### Level 3 — Expanded (full UI Kit surface)

Double-click any node → opens a **full UI Kit surface overlay** on the canvas.
The canvas dims around the expanded node. The node's surface uses the
components from Igniter UI Kit: `agent_presence`, `proposal_block`,
`evidence_block`, `observation_surface`, etc.

```
╔══════════════════════════════════════════════════════════════╗
║  ⚡ COORDINATOR                                      [close] ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  ● planning   "auth refactor breakdown"   3m 42s             ║
║                                                              ║
║  ─ Live activity ───────────────────────────────────────    ║
║  14:23  Analyzing task scope...                              ║
║  14:24  Found 3 related PRs                                  ║
║  14:24  Estimating time...                                   ║
║  14:25  ●●●  streaming subtask 3 of 4                        ║
║                                                              ║
║  ─ Evidence ────────────────────────────────────────────    ║
║  ▶ 3 sources (click to expand)                               ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║  [ Message ]  [ Pause ]  [ View proposal ]  [ Observe ]      ║
╚══════════════════════════════════════════════════════════════╝
```

The expanded surface is a full UI Kit session — not a tooltip, not a modal.
The node becomes a mini-application context. The user can chat with an agent
node, approve a decision node, trigger a contract node, inspect a data node.

---

## 7. Interaction Modes

The canvas has distinct interaction modes. A toolbar or keyboard shortcut
switches between them.

### 7.1 Navigate Mode (default)

Pan, zoom, select. Click selects a node. Double-click expands it.
Right-click opens a context menu.

```
Context menu on node:
  ─────────────────────────
  Expand (full surface)
  Query this node...
  Pin to canvas
  Follow connections
  Highlight path to...
  Send message (if agent)
  Trigger (if contract)
  Export as report
  ─────────────────────────
```

---

### 7.2 Query Mode

Press `/` to open a query bar. The graph responds by highlighting, filtering,
or navigating.

```
┌─────────────────────────────────────────────────────────────────┐
│ /  type:agent status:waiting                                    │
└─────────────────────────────────────────────────────────────────┘
→ Highlights all agent nodes with status:waiting
→ Dims everything else
→ Shows count: 2 agents waiting
```

Query syntax is simple facet-based:
- `type:agent` — filter by node kind
- `status:waiting` — filter by status
- `blocks:coordinator` — show what blocks this node
- `owns:session` — show what this node owns
- `since:30m` — show recently changed nodes
- `stuck` — show nodes that haven't progressed in >5m
- `path:task-svc → coordinator` — highlight the path between two nodes

---

### 7.3 Natural Language Mode

Press `?` to open the natural language query bar.

```
┌─────────────────────────────────────────────────────────────────┐
│ ?  Which agents are blocked?                                    │
└─────────────────────────────────────────────────────────────────┘
→ Graph highlights 1 agent: Coordinator (status: waiting for input)
→ Shows: "Coordinator is waiting for human approval on plan proposal"
→ Offers: [ View proposal ]  [ Expand Coordinator ]
```

The natural language layer translates to graph queries and then executes
them on the Observatory data. It is not an AI chat — it is graph navigation
through language.

More examples:
```
?  What is blocking the auth refactor?
→  Shows: PlanApproval node (decision pending 18min)
→  Highlights path: auth-refactor → plan-approval → coordinator

?  Show me everything the Coordinator touched today
→  Filters to: coordinator + all connected nodes created since 00:00

?  What decisions are waiting for me?
→  Filters to: decision nodes where requires=human, status=pending

?  Which contracts are failing?
→  Highlights: all process nodes with status=failed
→  Shows count: 0

?  What would happen if TaskService went down?
→  Highlights: all nodes that depend on TaskService (impact analysis)
```

The last example — **"what would happen if..."** — is impact analysis mode.
The graph shows the blast radius of a failure before it happens.

---

### 7.4 Command Mode

Select a node, then press `c` to enter command mode. Commands are sent
directly to the node.

For agent nodes:
```
Coordinator > plan auth_refactor budget:8h no_db_changes
Coordinator > pause
Coordinator > resume
Coordinator > show evidence
Coordinator > explain last_decision
```

For contract nodes:
```
TaskWorkflow:e42f > update_inputs amount=150
TaskWorkflow:e42f > invalidate :subtasks
TaskWorkflow:e42f > retry :failed_node
```

For decision nodes:
```
PlanApproval > approve
PlanApproval > reject reason:"budget exceeded"
PlanApproval > delegate to:coordinator
```

Command mode uses the grammar-compressed interaction vocabulary from the
grammar-compressed-interaction research. Each command maps to a structured
message to the node — not free text, but a controlled vocabulary that the
node understands.

---

### 7.5 Pin Mode

Press `p` on any node to pin it. Pinned nodes stay visible regardless of
zoom level and stay in a fixed position on canvas (other nodes can be
re-laid-out around them).

Use case: always keep `Coordinator` and `TaskService` visible as anchors.
Navigate the rest of the graph freely without losing your reference points.

---

### 7.6 Trace Mode

Select two nodes and press `t` to enter trace mode. The canvas highlights
the path between them and dims everything else.

```
Trace: TaskService → Coordinator

TaskService
  ↓ flows_to
TaskWorkflow:e42f
  ↓ triggers
PlanSession:9a3c
  ↓ owns
Coordinator
```

Trace mode also answers **latency questions**: how long did each hop take?
Where is the bottleneck in this path?

---

### 7.7 Compose Mode

Press `e` to enter compose mode. Drag a connection between two nodes to
create a relationship. This is the **authoring** layer: you can sketch
new contracts, connect inputs to outputs, define new compositions.

Compose mode produces a clean-form DSL preview:

```ruby
# Generated from canvas composition:
compute :plan_result, depends_on: :auth_scope, call: Agents::Coordinator
compose :auth_workflow, imports: { scope: :auth_scope }
```

This connects to the DSL REPL research — the canvas IS the REPL, expressed
spatially.

---

## 8. Agent-Driven Canvas Annotations

Agents can annotate the canvas from the server side. When an agent needs
human attention, it doesn't just send an alert bar — it can **highlight nodes
on the canvas**, draw attention to a cluster, or push a path highlight.

```ruby
# Inside an agent:
on :blocked do |task_id:, reason:|
  canvas_highlight(
    nodes: [task_id, :plan_approval],
    edge: :blocks,
    message: "Plan approval is blocking #{task_id}: #{reason}",
    severity: :attention,
    action: { label: "View", expand: :plan_approval }
  )
end
```

The user sees the canvas: suddenly two nodes pulse amber and a connection
between them glows. A tooltip appears: "Coordinator: Plan approval is blocking
auth-refactor". The user can navigate to it directly.

This is **proactive spatial awareness** — the system draws the user's
attention to the right part of the graph, not just to an abstract notification.

---

## 9. Graph Views

Named, saveable views that filter and configure the canvas.

```ruby
# DSL for defining views (in igniter-plane package)
Igniter::Plane::View.define :my_system do
  # What to include
  include_type :agent, :contract, :process
  exclude status: :completed, older_than: "1h"

  # Layout
  layout :force_directed          # or :hierarchical, :circular, :manual
  group :ai_layer do
    nodes type: :agent
    color :cobalt
    cluster_by :status
  end

  # Anchors
  pin :coordinator                # always visible, fixed position
  pin :task_service

  # Focus
  center_on :coordinator          # initial viewport center

  # Live settings
  refresh_interval 5              # seconds
  highlight_changes true          # flash nodes that changed state
  show_data_flows true            # animate particles on edges

  # Alerts
  on_status_change :agent, :blocked do
    flash_node :amber
    raise_alert message: "Agent blocked"
  end
end
```

Built-in views:
- `:system_overview` — all nodes, force-directed, condensed
- `:agent_focus` — agents + their sessions + their tools
- `:critical_path` — nodes on the blocking chain for current work
- `:recent_activity` — nodes changed in last 30 minutes
- `:pending_decisions` — only decision nodes requiring human action
- `:cluster_topology` — cluster peers + their workloads

---

## 10. Connection To Runtime Observatory

The Runtime Observatory Graph (research-horizon/runtime-observatory-graph.md)
defines the **data model** that feeds the Plane.

The Observatory vocabulary maps directly:

| Observatory concept | Plane representation |
|--------------------|---------------------|
| `ObservationNode` | Canvas node |
| `ObservationEdge` | Canvas edge |
| `ObservationFacet` | Query filter dimension |
| `ObservationFrame` | Named view / bounded context |
| `ObservationEvidence` | Expandable evidence block on node |
| `blocker` | `blocks` edge, decision node |
| `requires_human` | Decision node (amber, pulsing) |

The Plane does not own the data. It reads from the Observatory adapter,
which reads from the explicit runtime artifacts (execution reports, session
snapshots, operator records, cluster traces, handoff manifests).

The Plane is pure presentation + interaction. The Observatory is pure
observation. The runtime packages own the actual state.

```
Runtime artifacts            Observatory adapter        Igniter Plane
─────────────────────        ───────────────────        ─────────────
execution reports        →   ObservationNodes       →   Canvas nodes
session snapshots        →   ObservationEdges       →   Canvas edges
operator records         →   ObservationFacets      →   Query filters
cluster traces           →   ObservationFrames      →   Named views
handoff manifests        →   ObservationEvidence    →   Evidence panels
```

The Plane adds:
- Spatial layout (force-directed positioning)
- Visual rendering (zoom levels, colors, animations)
- Interaction layer (click, query, command, compose)
- Agent annotation API (server-side canvas control)

---

## 11. The Interaction Vocabulary

When a user interacts with a node, the Plane uses the Interaction Kernel
vocabulary (interaction-kernel-report.md) to structure the interaction:

```
Selected node:  Coordinator  (AgentNode)
Session:        PlanSession:9a3c
Affordances:    message, pause, observe, view_proposal, view_evidence
Pending state:  waiting for plan approval (18min)
Surface:        → expands to AgentPresenceSurface (UI Kit)
Evidence:       3 sources, 82% confidence
Policy:         human_review_required
```

This means the canvas interaction always knows:
- what the node IS (kind, status)
- what the user CAN DO (affordances)
- what is WAITING (pending state)
- where to SHOW IT (surface context)
- what SUPPORTS the current state (evidence)
- what CONSTRAINS next moves (policy)

The Interaction Kernel gives the canvas semantic interaction rather than
dumb click handlers.

---

## 12. Rendering Architecture

### 12.1 Canvas Substrate

Two rendering options, not mutually exclusive:

**Option A — CSS Transforms + SVG**
- Nodes as absolutely positioned HTML elements
- Edges as SVG paths overlaid on the HTML canvas
- Zoom via `transform: scale()`
- Animate via CSS transitions
- No extra dependencies, works with existing Arbre output
- Limitation: performance degrades above ~500 simultaneous nodes

**Option B — WebGL (PixiJS or custom)**
- Nodes as WebGL sprites or textured quads
- Edges as line primitives with particle shaders
- Zoom via camera transform
- Animate at GPU speed
- No DOM limitation on node count
- Limitation: requires one additional JS dependency

**Recommended approach**: Start with Option A (CSS/SVG) for the first
implementation. It requires no new frontend dependencies, can use existing
Arbre components for node rendering at zoom levels 1–3, and is fast enough
for practical system sizes (tens to hundreds of nodes). Migrate to Option B
if node counts or animation complexity demand it.

### 12.2 Node Rendering Pipeline

```
Observatory frame
    ↓
Layout engine (force-directed, d3-force or pure-ruby graph -> JSON)
    ↓
Position data (node id → x, y, zoom_level)
    ↓
HTML/SVG canvas (static at first paint)
    ↓
SSE stream updates (node state changes, new nodes, edge changes)
    ↓
JS runtime (IgniterPlane.js, ~400 lines, zero framework)
    → updates node DOM elements
    → redraws SVG edges
    → triggers CSS animations
    → handles interaction events
```

### 12.3 The Zero-Dependency JS Runtime

```javascript
// igniter-plane.js — zero framework, ~400 lines
const IgniterPlane = {
  nodes: new Map(),         // id → { el, x, y, kind, status }
  edges: [],                // { from, to, type, el }
  viewport: { x: 0, y: 0, scale: 1.0 },
  mode: "navigate",         // navigate | query | command | pin | trace | compose
  pins: new Set(),
  highlights: new Set(),

  init(containerEl) {
    this.container = containerEl;
    this.svg = containerEl.querySelector(".ig-plane-edges");
    this.canvas = containerEl.querySelector(".ig-plane-nodes");
    this.bindEvents();
    this.connectStream();
  },

  connectStream() {
    const source = new EventSource("/plane/stream");
    source.addEventListener("node_update",  e => this.updateNode(JSON.parse(e.data)));
    source.addEventListener("edge_update",  e => this.updateEdge(JSON.parse(e.data)));
    source.addEventListener("highlight",    e => this.applyHighlight(JSON.parse(e.data)));
    source.addEventListener("frame_reset",  e => this.resetFrame(JSON.parse(e.data)));
  },

  updateNode(data) {
    const node = this.nodes.get(data.id);
    if (!node) return this.addNode(data);
    node.el.dataset.igStatus = data.status;
    node.el.dataset.igActivity = data.activity || "";
    const label = node.el.querySelector(".ig-plane-node-status");
    if (label) label.textContent = data.status;
    this.applyStatusClass(node.el, data.status);
  },

  addNode(data) {
    const el = document.createElement("div");
    el.className = `ig-plane-node ig-plane-node--${data.kind}`;
    el.dataset.igNodeId = data.id;
    el.dataset.igStatus = data.status;
    el.style.transform = `translate(${data.x}px, ${data.y}px)`;
    el.innerHTML = this.renderNodeHtml(data);
    this.canvas.appendChild(el);
    this.nodes.set(data.id, { el, ...data });
    this.bindNodeEvents(el, data);
  },

  applyHighlight(data) {
    // Clear previous highlights
    this.highlights.forEach(id => {
      const node = this.nodes.get(id);
      if (node) node.el.classList.remove("ig-plane-node--highlighted");
    });
    this.highlights.clear();

    // Apply new highlights
    (data.nodes || []).forEach(id => {
      const node = this.nodes.get(id);
      if (node) {
        node.el.classList.add("ig-plane-node--highlighted");
        this.highlights.add(id);
      }
    });

    if (data.message) this.showAnnotation(data);
  },

  onNodeClick(id) {
    if (this.mode === "navigate") this.selectNode(id);
    if (this.mode === "pin") this.togglePin(id);
    if (this.mode === "trace") this.addTracePoint(id);
    if (this.mode === "command") this.openCommandPrompt(id);
  },

  onNodeDblClick(id) {
    this.expandNode(id);
  },

  expandNode(id) {
    const data = this.nodes.get(id);
    if (!data) return;
    fetch(`/plane/nodes/${id}/surface`)
      .then(r => r.text())
      .then(html => this.showSurface(id, html));
  },

  showSurface(id, html) {
    const overlay = document.getElementById("ig-plane-overlay");
    overlay.innerHTML = html;
    overlay.classList.add("ig-plane-overlay--visible");
    // Surface JS (IgniterLive) will initialize live components automatically
    IgniterLive.init();
  },

  query(q) {
    fetch(`/plane/query?q=${encodeURIComponent(q)}`)
      .then(r => r.json())
      .then(result => this.applyQueryResult(result));
  }
};

document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("ig-plane");
  if (el) IgniterPlane.init(el);
});
```

---

## 13. Plane Server API

The Plane connects to a server-side Rack endpoint that produces the
Observatory frame and streams updates.

```
GET  /plane                  → render initial canvas HTML
GET  /plane/stream           → SSE stream for live updates
GET  /plane/frame            → JSON Observatory frame (current snapshot)
GET  /plane/query?q=...      → JSON query result (nodes + edges matching query)
GET  /plane/nodes/:id/surface → HTML surface for expanded node
POST /plane/nodes/:id/command → send command to node
POST /plane/views            → save a named view
GET  /plane/views/:name      → load a named view
```

The server side:
1. Reads the Observatory adapter to build the current frame
2. Converts to position data (layout engine or manual positions)
3. Renders initial HTML (nodes + SVG edges)
4. Keeps a live frame diff stream via SSE
5. Routes commands to the appropriate package (agent, contract, etc.)

---

## 14. DSL For Plane Integration

The Plane integrates with the Interactive App DSL proposed in the previous
document:

```ruby
App = Igniter.interactive_app :task_assistant do
  service :tasks, Services::TaskManager
  agent   :coordinator, Agents::Coordinator

  # Standard surfaces
  surface :workspace, at: "/"

  # The Plane — available at /plane
  plane :system do
    view :default, :agent_focus    # built-in view
    view :full, :system_overview

    # Custom view
    view :ops do
      include_type :agent, :contract, :process
      pin :coordinator
      pin :task_service
      highlight status: :blocked, severity: :attention
      refresh_interval 5
    end

    # Mount the plane at a specific path
    at "/plane"

    # Who can see it
    access :internal           # :public, :internal, :operator
  end

  surface :workspace, at: "/"
  flow    :new_task, at: "/tasks/new"
end
```

And inside agent code, the broadcast API:

```ruby
class Agents::Coordinator < Igniter::AI::Agent
  on :blocked do |task_id:, reason:|
    # Traditional alert
    broadcast :needs_attention,
              message: "Blocked on #{task_id}",
              detail: reason

    # Spatial canvas annotation
    plane_highlight(
      nodes: [task_id, :plan_approval],
      edge: { type: :blocks, from: task_id, to: :plan_approval },
      message: reason,
      severity: :attention
    )
  end
end
```

---

## 15. Zoom Level + Rendering Decision Matrix

| Zoom level | Node count visible | Rendering | Interaction |
|-----------|-------------------|-----------|-------------|
| 0 (galaxy) | 100-1000 | Color dots, size=importance | Pan only |
| 1 (region) | 20-100 | Name + status + 1 metric | Click selects, right-click menu |
| 2 (node) | 5-20 | Full node panel | All modes enabled |
| 3 (expanded) | 1 (focused) | Full UI Kit surface overlay | Full surface interaction |

Transitions between levels are animated (CSS scale transform).

The zoom level is continuous, not discrete. The rendering switches at
threshold values (configurable per view).

---

## 16. Connection To Existing Igniter Concepts

| Existing Igniter concept | Plane representation |
|--------------------------|---------------------|
| `Igniter::Contract` execution | Process node |
| `Igniter::AI::Agent` actor | Agent node |
| `NodeState` (resolved/pending/failed) | Node status + color |
| `CompiledGraph` | Can be rendered as a subgraph |
| `ExecutionReport` | Observatory frame source |
| `FlowSession` | Session node |
| `OperatorQuery` | Decision node pool |
| `AgentSession` | Session node + agent node connection |
| `Cluster::AgentRouteResolver` | Edge: `routes_to` |
| `Igniter::Server` peers | Cluster peer nodes |
| `HandoffManifest` | `handoff_to` edge, receipt node |
| Runtime Observatory (research) | The Observatory adapter layer |
| Interaction Kernel (research) | Affordances exposed on node click |

---

## 17. What Makes This Different From Existing Graph UIs

**vs Grafana service maps**: Grafana shows topology metrics. The Plane is
interactive — you can command nodes, not just observe them.

**vs Datadog dependency maps**: Datadog shows request traces. The Plane shows
the semantic system — agents, decisions, data flows — not just HTTP calls.

**vs Temporal's workflow visualization**: Temporal shows workflow state for one
execution. The Plane shows the entire live system with all executions and agents.

**vs Erlang/OTP Observer**: Observer shows process tree. The Plane shows
semantic nodes (what they ARE) not process primitives.

**vs Obsidian graph view**: Obsidian shows static document links. The Plane
shows live process state with real-time data flows.

**The unique combination**: live process state + semantic node types + spatial
navigation + bidirectional interaction + agent awareness + natural language
queries + canvas-level annotations from agents.

---

## 18. Risks And Constraints

**Risk: Complexity overload**
The Plane must not show every detail at once. The multi-scale model is the
answer: coarse at galaxy scale, fine at node scale. The user controls the
zoom, not the system.

**Risk: Staleness**
A graph that shows stale data is worse than no graph. The SSE live stream
is essential. Nodes must show "last updated N seconds ago" when fresh data
is unavailable.

**Risk: Too many nodes**
A system with 1000 running contracts and 50 agents will overwhelm CSS rendering.
Start with Level 0 rendering (colored dots) for large node counts. Provide
view filters as the primary UX for managing scale.

**Risk: Ownership confusion**
The Plane must be read-only + command-surface, not a way to bypass package
ownership. Commands route to the appropriate package. The Plane itself owns
nothing.

**Risk: Canvas + traditional UI mismatch**
Not every user wants a spatial canvas. The Plane is an additional surface,
not a replacement for operator dashboards and flow surfaces. Traditional
surfaces remain the default interaction mode.

**Risk: Maintaining layout state**
Force-directed layouts are non-deterministic. User-positioned nodes need
server-side persistence. Start with pure force-directed (no manual positions)
and add manual pinning only when needed.

---

## 19. Recommended Graduation Sequence

This is a research proposal. The graduation sequence if accepted:

**Step 1 — Docs-only doctrine**
Define the Plane vocabulary (node types, edge types, zoom levels, interaction
modes) as docs. Validate against existing Igniter system state.

**Step 2 — Static snapshot renderer**
Build a read-only static Observatory frame rendered as an HTML canvas.
No live updates. No interaction. Just "here is your system as a graph."
Validate: is this useful? Is the layout readable?

**Step 3 — Live SSE updates**
Add SSE stream from the Observatory adapter. Nodes pulse when state changes.
Still read-only. Validate: is the live view maintainable?

**Step 4 — Navigate + query interaction**
Add click-to-expand (Level 3 full surface), right-click context menu, and
the `/query` endpoint. This is the first bidirectional interaction.

**Step 5 — Command mode + agent annotations**
Add `POST /plane/nodes/:id/command` and the `plane_highlight` agent API.
The canvas becomes a command surface.

**Step 6 — Compose mode + view DSL**
Add compose mode for authoring new connections. Add named view definitions
in the app DSL.

**Not in scope until Step 4 is proven:**
- WebGL renderer
- Multi-user collaborative canvas
- External graph database
- AI-driven auto-layout

---

## 20. Summary: The Core Insight

The system you've built is a graph of processes. The agents, contracts,
sessions, data flows, cluster peers — they are all nodes in a graph. They
have relationships. They have state. They change over time.

Traditional UIs show you **one node at a time**, through a series of screens
and dashboards. You have to reconstruct the graph in your head.

Igniter Plane shows you **the graph directly**. You navigate it spatially.
You interact with nodes in place. Agents annotate it for your attention.
You query it in natural language. You compose new connections on the canvas.

This is not a better dashboard. It is a different relationship with the system —
the relationship of someone who can **see the whole and zoom in on any part**.

The bird's eye view, but interactive. The mission control, but bidirectional.
The living map, but one you can change.
