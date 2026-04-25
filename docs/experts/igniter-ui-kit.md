# Igniter UI Kit — Interactive Agent Visual Language

Date: 2026-04-25.
Author: external expert review.
Scope: design system + component vocabulary for interactive agent applications.

---

## 1. Why A New Visual Language

Standard UI kits are designed for human → machine interactions: user clicks,
machine responds. Chat interfaces are better but still synchronous and
conversation-shaped.

Interactive agent environments have qualitatively different interaction
patterns:

- Agents work **asynchronously** in the background
- Agents **proactively interrupt** the human when something matters
- Agents have **uncertainty** and **alternatives**, not just results
- Multiple agents **coordinate** on a shared task
- Work produces **artifacts** with their own lifecycle
- Every decision has an **evidence trail**
- Long sessions have a **temporal shape** — what happened when, by whom

None of these patterns are first-class citizens in any existing UI kit.
Bootstrap, Tailwind, Shoelace, Material Design — all assume a human tapping
things and getting responses. None model the "agent colleague that's doing
something and wants your attention" paradigm.

Igniter UI Kit is designed from the ground up for this new application shape.

---

## 2. Design Philosophy

### 2.1 Machine Surfaces vs Human Surfaces

Two distinct visual registers coexist in an interactive agent app:

**Machine register** — operator consoles, status boards, data feeds:
- No border-radius (sharp edges feel like precision instruments)
- Monospace fonts for data, counters, IDs
- Dense information, structured grids
- Flat color fills, single-pixel borders
- Accent via contrast, not decoration

**Human register** — wizard steps, approvals, conversational surfaces:
- 2–4px radius for softness (humans, not machines)
- Readable sans-serif, generous leading
- One clear primary action per screen
- Whitespace as signal (what to focus on)
- Warm neutrals to reduce alert fatigue

The kit provides both registers. The developer declares the register; the
component applies it automatically.

### 2.2 The Five Visual Signals

The kit treats these states as first-class visual citizens, not afterthoughts:

| Signal | Meaning | Visual treatment |
|--------|---------|-----------------|
| `waiting` | Agent is running, human need not act | Pulse animation, muted color |
| `needs_input` | Agent is blocked, human must act | High contrast border, ping badge |
| `proposal` | Agent produced something for review | Left accent stripe, review badge |
| `evidence` | Reasoning available to inspect | Expand affordance, subtle indent |
| `handoff` | Work is being transferred | Directional arrow, from/to labels |

### 2.3 Semantic Color System

Not primary/secondary/success/danger. Semantic by actor:

```
─────────────────────────────────────────────────────────────────
ig-color--human        warm ink     #2f2a1f    human actor
ig-color--agent        cobalt       #1a4fd6    AI actor
ig-color--signal       amber        #f2b84b    needs attention
ig-color--positive     forest       #1e6641    resolved/done
ig-color--caution      ochre        #c8862a    degraded/partial
ig-color--negative     rust         #b03030    failed/blocked
ig-color--neutral      stone        #8a8278    background text
ig-color--surface-0    parchment    #f8f4ea    main background
ig-color--surface-1    cream        #fffdf7    card background
ig-color--surface-2    shell        #f0ece0    recessed background
ig-color--border       bark         #2f2a1f    main border
ig-color--border-soft  grain        #c8c0b0    soft border
─────────────────────────────────────────────────────────────────
```

Agent-generated content always carries `ig-color--agent` as the left-border
accent. Human-authored content carries `ig-color--human`. System events are
neutral. This makes authorship visible at a glance.

### 2.4 Typography Scale

```
ig-type--display    42px / 1.0 / 700    hero numbers, counts
ig-type--heading    24px / 1.2 / 700    section titles
ig-type--subheading 16px / 1.4 / 600    sub-labels, card titles
ig-type--body       15px / 1.6 / 400    readable prose
ig-type--caption    12px / 1.4 / 400    labels, metadata
ig-type--mono       13px / 1.5 / 400    IDs, data, code
ig-type--eyebrow    11px / 1.6 / 600    uppercase category labels
```

### 2.5 Spacing Grid

4px base. All components use multiples of 4: `4 8 12 16 24 32 48 64`.
No magic numbers in component CSS.

---

## 3. Component Taxonomy

Four tiers, each builds on the previous.

```
Tier 1 — Primitives      Atoms — no business logic, no children
  Badge, Signal, Chip, Avatar, Icon, Progress, Meter,
  Timestamp, Token, Divider, Skeleton

Tier 2 — Blocks           Molecules — composed from primitives
  StatBlock, EvidenceBlock, ProposalBlock, ArtifactBlock,
  ThreadMessage, AgentPresence, TaskItem, DecisionPoint,
  DelegationBlock, TimelineEvent, ContextSnippet, AlertBar

Tier 3 — Surfaces         Organisms — full interaction surfaces
  WorkspaceSurface, ChatSurface, StreamSurface, FlowSurface,
  AgentCanvas, ProposalSurface, ArtifactSurface,
  ObservationSurface, AlertSurface, TimelineSurface

Tier 4 — Compositions     Templates — preset surface assemblies
  DecisionWorkspace, OperatorConsole, AgentCockpit,
  TaskBoard, ArtifactWorkspace, OnboardingFlow, AlertCenter
```

The Arbre DSL keyword maps directly to Tier 2–3 component names:

```ruby
# Tier 2 — used inside zones
agent_presence :coordinator
stat_block :pending_count
proposal_block :plan
evidence_block :reasoning
task_item task
timeline_event event

# Tier 3 — declare at zone or surface level
chat_surface with: :coordinator
stream_surface :events, from: EventsProjection
flow_surface :onboarding, steps: OnboardingSteps
observation_surface :coordinator, mode: :live
```

---

## 4. Tier 1 — Primitives

### 4.1 `ig-badge`

A small inline label communicating status, priority, or category.

```
┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ ● open  │  │ ▲ high   │  │ ✓ done   │  │ ⚡ agent │
└─────────┘  └──────────┘  └──────────┘  └──────────┘
```

Arbre:
```ruby
ig_badge :open, label: "Open"
ig_badge :high, variant: :caution, label: "High"
ig_badge :done, variant: :positive, icon: :check
ig_badge :agent, variant: :agent, icon: :bolt
```

Variants: `:neutral`, `:positive`, `:caution`, `:negative`, `:signal`,
`:agent`, `:human`.

Props: `label:`, `variant:`, `icon:`, `size:` (`:sm`, `:md`, `:lg`), `dot:`
(boolean — show pulse dot instead of label).

---

### 4.2 `ig-signal`

A pulsing attention indicator. Used when an agent needs human input or a
background process needs attention.

```
●  1 new proposal        ●  Coordinator needs input
(amber, pulsing)         (cobalt, pulsing)
```

Variants: `:needs_input` (amber pulse), `:agent_active` (cobalt pulse),
`:proposal_ready` (cobalt solid), `:error` (rust solid).

---

### 4.3 `ig-avatar`

Represents an agent or human participant. Agents render with a distinct
machine-style treatment; humans with a warm circular form.

```
╔═══╗        ○
║ AI║        └─ human initials (warm ink)
╚═══╝
agent (sharp, cobalt accent)
```

Props: `name:`, `kind:` (`:agent`, `:human`, `:system`), `status:` (`:idle`,
`:active`, `:waiting`, `:offline`), `size:`.

---

### 4.4 `ig-progress`

Linear or arc progress indicator. Used for agent task completion, flow steps,
long-running operations.

```
Step 2 of 4      ████████░░░░░░░░  50%

──────────── ● ──────────────────
  details    setup   confirm   done
    ✓         ●        ○        ○
```

Props: `value:`, `max:`, `variant:` (`:linear`, `:arc`, `:steps`), `steps:`,
`current_step:`, `label:`.

---

### 4.5 `ig-skeleton`

Placeholder for loading content. Used when agent is computing but surface is
already visible.

```
┌────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓░░░░ ▓▓▓▓░░░░░    │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░           │
│ ▓▓▓░░░ ▓▓▓░░░ ▓▓▓░░░         │
└────────────────────────────────┘
(animated shimmer)
```

Props: `rows:`, `variant:` (`:text`, `:card`, `:avatar`, `:table`), `animated:`.

---

## 5. Tier 2 — Blocks

### 5.1 `ig-stat-block`

A key metric display. Can show trend, delta, agent-computed values.

```
┌──────────────────────┐
│  PENDING TASKS       │
│                      │
│      12              │
│   ↑ +3 today         │
│                      │
└──────────────────────┘
```

Arbre:
```ruby
stat_block :pending do
  label "Pending Tasks"
  value -> { tasks.pending_count }
  delta -> { tasks.delta_today }
  trend :up                          # :up, :down, :flat
  variant :signal                    # amber when > threshold
  threshold 10
end
```

Props: `label:`, `value:`, `delta:`, `trend:`, `variant:`, `threshold:`,
`link_to:` (navigate on click), `agent:` (which agent computed this).

---

### 5.2 `ig-agent-presence`

**The most important new component.** Displays an agent's current state,
what it's doing, and provides interaction affordances.

```
╔═══════════════════════════════════════════╗
║  ⚡ Coordinator                  ● active ║
║  Planning task breakdown for: Auth refac  ║
║  Started 2 min ago                        ║
║                                           ║
║  [ Message ]  [ Pause ]  [ View work ]    ║
╚═══════════════════════════════════════════╝
```

States:
```
● active  — blue pulse    — agent is running
○ idle    — grey dot      — agent available, not running
⧖ waiting — amber pulse   — agent needs input
✓ done    — green solid   — agent completed last task
✗ error   — red solid     — agent failed or stuck
```

Arbre:
```ruby
agent_presence :coordinator do
  show_activity true           # display current task description
  show_controls true           # message / pause / view work buttons
  show_history 3               # last N completed tasks
  on_click :open_agent_surface # what happens on main click
end
```

This component is always live — it subscribes to agent status events via SSE
and updates without page reload.

---

### 5.3 `ig-proposal-block`

**The core agent output component.** When an agent proposes something for
human review, it appears in this block. Not a chat bubble — a structured
review surface.

```
╔══════════════════════════════════════════════════════╗
║  ⚡ COORDINATOR PROPOSAL           [proposed 4m ago] ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  Task breakdown: "Auth refactor"                     ║
║                                                      ║
║  1. Extract JWT validation to middleware     2h est  ║
║  2. Add refresh token rotation               1h est  ║
║  3. Update API tests                         3h est  ║
║  4. Update documentation                    30m est  ║
║                                                      ║
║  Total: ~6.5 hours                                   ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  Confidence: ████████░░ 82%     3 alternatives       ║
╠══════════════════════════════════════════════════════╣
║  [ Accept ]  [ Modify ]  [ See alternatives ]  [ ✗ ] ║
╚══════════════════════════════════════════════════════╝
```

This is **not a message**. It is a structured artifact with:
- Clear agent attribution
- The proposed content (agent-rendered)
- Confidence indicator
- Explicit accept / modify / reject actions
- Optional "see alternatives" when agent has options

Arbre:
```ruby
proposal_block :plan do
  from_agent :coordinator
  content -> { agent(:coordinator).latest_proposal }
  confidence -> { agent(:coordinator).confidence }

  action :accept do |proposal|
    tasks.apply_plan(proposal)
    agent(:coordinator).cast(:execute_plan, plan: proposal)
    refresh :workspace
  end

  action :modify, opens: :flow      # opens modification flow
  action :reject do |proposal|
    agent(:coordinator).cast(:revise, reason: params[:reason])
  end

  show_alternatives true
end
```

---

### 5.4 `ig-evidence-block`

Shows agent reasoning. Collapsed by default, expandable. Every proposal and
AI-computed value can have an evidence block attached.

```
▶ Why did Coordinator suggest this?                    [expand]

▼ Coordinator's reasoning:                             [collapse]
  ─────────────────────────────────────────────────
  Source 1: PR #421 — "previous auth PR took 8h"
  Source 2: Tasks history — avg JWT task 2h
  Source 3: Your team velocity: 6h/day average

  Reasoning:
  → Found 3 similar past tasks
  → Estimated from historical data
  → Added 20% buffer for unfamiliarity
  ─────────────────────────────────────────────────
  Confidence: 82%  |  Alternatives considered: 3
```

Arbre:
```ruby
evidence_block do
  from_agent :coordinator
  sources -> { agent(:coordinator).last_evidence.sources }
  reasoning -> { agent(:coordinator).last_evidence.reasoning }
  confidence -> { agent(:coordinator).last_evidence.confidence }
  collapsed true      # expanded by default vs collapsed
end
```

This component is **critical for trust**. Users trust AI systems more when they
can see the reasoning. Making evidence an explicit first-class component (not
buried in a chat) is a key differentiator.

---

### 5.5 `ig-artifact-block`

An agent-produced document, plan, code, or structured output with its lifecycle.

```
╔════════════════════════════════════════════════════════╗
║  📄 DRAFT  Project Proposal v2                [agent] ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  # Auth Refactor Plan                                  ║
║                                                        ║
║  ## Scope                                              ║
║  Extract JWT validation...                             ║
║                                                        ║
║  ## Timeline                                           ║
║  Week 1: ...                                           ║
║                                                        ║
╠════════════════════════════════════════════════════════╣
║  ● draft  →  review  →  approved  →  deployed         ║
║                                                        ║
║  [ Edit ]  [ Request review ]  [ Compare with v1 ]    ║
╚════════════════════════════════════════════════════════╝
```

Lifecycle states: `draft`, `in_review`, `approved`, `rejected`, `deployed`.
Each state has distinct visual treatment and available actions.

Arbre:
```ruby
artifact_block :proposal_doc do
  from_agent :coordinator
  kind :document                     # :document, :code, :plan, :data
  content -> { artifacts.latest(:proposal) }
  lifecycle_state -> { artifacts.state(:proposal) }

  action :edit,           when: [:draft]
  action :request_review, when: [:draft]
  action :approve,        when: [:in_review]
  action :reject,         when: [:in_review]
  action :compare_diff,   always: true
end
```

---

### 5.6 `ig-decision-point`

A structured yes/no/delegate decision. Not a form — a decision artifact with
context, stakes, and clear consequences for each choice.

```
╔════════════════════════════════════════════════════════╗
║  ⚠  DECISION REQUIRED                                  ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  Should the auth refactor proceed this sprint?         ║
║                                                        ║
║  Context:  4 open blockers on the PR                   ║
║  Deadline: Sprint ends Friday                          ║
║  Impact:   3 dependent features blocked                ║
║                                                        ║
╠════════════════════════════════════════════════════════╣
║  [ ✓ Proceed — accept risk ]                           ║
║  [ → Move to next sprint — unblock dependents now ]    ║
║  [ ⚡ Ask Coordinator to plan unblocking ]             ║
╚════════════════════════════════════════════════════════╝
```

Arbre:
```ruby
decision_point :sprint_decision do
  question "Should the auth refactor proceed this sprint?"

  context do
    fact "4 open blockers on the PR"
    fact "Sprint ends #{sprint.end_date}"
    fact "3 dependent features blocked"
  end

  choice :proceed, label: "Proceed — accept risk" do
    tasks.mark_proceed(:auth_refactor)
    refresh :workspace
  end

  choice :defer, label: "Move to next sprint" do
    tasks.defer(:auth_refactor)
    redirect surface(:sprint_planning)
  end

  choice :delegate, label: "Ask Coordinator to plan unblocking" do
    agent(:coordinator).cast(:unblock_plan, task: :auth_refactor)
    notify "Coordinator is working on an unblocking plan"
  end
end
```

---

### 5.7 `ig-delegation-block`

Formalizes the hand-off of work to an agent. This is a **contract** between
the human and the agent: what to do, what constraints apply, when to report
back.

```
╔════════════════════════════════════════════════════════╗
║  DELEGATE TO COORDINATOR                               ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  Task:        Plan auth refactor work breakdown        ║
║  Constraints:                                          ║
║    • Keep under 8 hours total                          ║
║    • Don't change the database schema                  ║
║    • Flag if any task > 3h                             ║
║                                                        ║
║  Report back: When plan is ready, or if stuck          ║
║                                                        ║
╠════════════════════════════════════════════════════════╣
║  [ Send ]                              [ Cancel ]      ║
╚════════════════════════════════════════════════════════╝
```

Arbre:
```ruby
delegation_block :plan_refactor do
  to_agent :coordinator
  task "Plan auth refactor work breakdown"

  constraints do
    constraint "Keep under 8 hours total"
    constraint "Don't change the database schema"
    constraint "Flag if any task > 3 hours"
  end

  report_on :completion, :blocked

  on :confirm do |delegation|
    agent(:coordinator).cast(:accept_delegation, delegation: delegation.to_h)
    notify "Coordinator has accepted the task"
    redirect surface(:workspace)
  end
end
```

---

### 5.8 `ig-timeline-event`

A single event in a temporal surface. Distinguishes human actions, agent
actions, and system events visually.

```
14:23  ⚡  Coordinator started planning
14:31  ⚡  Coordinator identified 3 blockers
14:45  ●   You reviewed the plan
14:46  ⚡  Coordinator revised plan based on feedback
14:52  ✓  Plan approved, work delegated
```

Props: `timestamp:`, `actor:`, `actor_kind:` (`:agent`, `:human`, `:system`),
`event_type:`, `description:`, `expandable:`, `detail:`.

---

### 5.9 `ig-context-snippet`

Shows what context an agent is currently using. Collapsed by default. Enables
"what does the agent know right now?" inspection.

```
▶ Coordinator's context  (5 items)                     [expand]

▼ Coordinator's context:                               [collapse]
  ─────────────────────────────────────────────────
  tasks.pending (5):    triage-sensor, ack-runbook...
  sprint.current:       Sprint 12, ends 2026-04-28
  team.capacity:        32h remaining
  last_decision:        defer auth_refactor
  user.preference:      concise plans, flag risk
  ─────────────────────────────────────────────────
  [ Edit context ]  [ Clear ]
```

Arbre:
```ruby
context_snippet :coordinator_context do
  from_agent :coordinator
  collapsed true
  editable true        # allow human to add/remove context items
end
```

---

### 5.10 `ig-alert-bar`

**Proactive interruption from an agent.** Not a toast. A persistent, dismissible
surface element that the agent injects when it needs human attention without
waiting for a page load.

```
╔═══════════════════════════════════════════════════════╗
║  ⚡  Coordinator: Found a critical blocker on task #4  ║
║     "API test suite fails after JWT change (3 tests)"  ║
║  [ Review ]  [ I'll handle it ]  [ Dismiss ]          ║
╚═══════════════════════════════════════════════════════╝
```

This component is pushed to the page via SSE when an agent emits a
`needs_attention` event. It appears at the top of the current surface
without user action.

Arbre (agent side):
```ruby
on :blocked do |reason:, task_id:|
  broadcast :needs_attention,
            message: "Found a critical blocker on task ##{task_id}",
            detail: reason,
            actions: [
              { label: "Review",       cast: :show_blocker, params: { task_id: task_id } },
              { label: "I'll handle it", cast: :human_owns,  params: { task_id: task_id } }
            ]
end
```

The `ig-alert-bar` component listens on the SSE channel and renders incoming
`needs_attention` events automatically.

---

## 6. Tier 3 — Surfaces

### 6.1 `ig-workspace-surface`

The primary multi-zone working surface. Replaces the raw `main/header/aside`
HTML in the current operator board.

```
┌──────────────────────────────────────────────────────────────┐
│  WORKSPACE                   ●pending 12  ○active 3  ⚡AI   │
│  Task Assistant              ─────────────────────────────── │
├──────────────┬──────────────────────────────┬────────────────┤
│              │                              │                │
│  TASKS       │  MAIN AREA                   │  AGENT         │
│              │  (collection / artifact /    │  PRESENCE      │
│  ig-task     │   proposal / observation)    │                │
│  items       │                              │  ig-agent-     │
│              │                              │  presence      │
│              │                              │                │
│              │                              │  ig-evidence   │
│              │                              │  _block        │
├──────────────┴──────────────────────────────┴────────────────┤
│  FOOTER                              GET /events: open=12    │
└──────────────────────────────────────────────────────────────┘
```

ScreenSpec DSL:
```ruby
Igniter::Web.screen(:workspace, intent: :live_process) do
  title "Task Assistant"
  compose with: :agent_workspace      # new composition preset

  subject :tasks_overview             # → summary zone
  need :agent_status                  # → summary zone

  show :task_list                     # → main zone (collection)
  show :active_artifact               # → main zone (conditionally)

  presence :coordinator               # → aside zone (new DSL keyword)
  evidence :coordinator               # → aside zone (collapsed)

  action :new_task, run: :flow        # → footer zone
  action :delegate_all, run: :agent   # → footer zone
end
```

---

### 6.2 `ig-observation-surface`

Watch an agent work in real-time. The agent narrates what it's doing; the human
can interrupt, redirect, or take over.

```
┌──────────────────────────────────────────────────────────────┐
│  WATCHING: Coordinator planning "Auth Refactor"     ● live  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  14:23  Analyzing task scope...                              │
│  14:23  → Found 4 related PRs in history                    │
│  14:24  Estimating time from similar tasks...               │
│  14:24  → Similar avg: 6.2h, Coordinator using 6.5h target  │
│  14:25  Drafting subtask breakdown...                        │
│  14:25  ●●●  (streaming: subtask 3 of 4)                    │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│  [ ✋ Interrupt ]  [ Take over ]  [ Give hint ]             │
└──────────────────────────────────────────────────────────────┘
```

This is powered by agents emitting `observe_event` during their work loop.
The observation surface subscribes via SSE and streams events in real time.

Agent side:
```ruby
on :plan do |task_id:|
  observe "Analyzing task scope..."
  related = search_related_tasks(task_id)
  observe "Found #{related.size} related PRs in history"

  observe "Estimating time from similar tasks..."
  estimate = estimate_from_history(related)
  observe "Similar avg: #{estimate.avg}h, using #{estimate.target}h target"

  observe "Drafting subtask breakdown..."
  plan = complete_with_streaming("Create subtask breakdown...")
  # streaming emits observe events per token

  broadcast :plan_ready, plan: plan
end
```

ScreenSpec DSL:
```ruby
Igniter::Web.screen(:observe_coordinator, intent: :live_process) do
  title "Watching Coordinator"
  observe :coordinator, mode: :live           # new DSL keyword

  action :interrupt,   label: "Interrupt",   run: :cast
  action :take_over,   label: "Take over",   run: :cast
  action :give_hint,   label: "Give hint",   opens: :modal
end
```

---

### 6.3 `ig-proposal-surface`

A dedicated review surface for agent proposals. More space than `proposal_block`
for complex outputs.

```
┌──────────────────────────────────────────────────────────────┐
│  ⚡ COORDINATOR PROPOSAL                     proposed 4m ago │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Auth Refactor — Work Breakdown                              │
│                                                              │
│  1. ████████░░░░  Extract JWT middleware        2h           │
│  2. ████░░░░░░░░  Add refresh rotation          1h           │
│  3. ████████████  Update API tests              3h           │
│  4. ████░░░░░░░░  Update docs                  30m           │
│                                                              │
│  ▶ Why this plan?  (evidence — click to expand)              │
│  ▶ 3 alternative plans available                             │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│  Confidence: ████████░░ 82%                                  │
├──────────────────────────────────────────────────────────────┤
│  [ ✓ Accept & start ]  [ ✎ Modify ]  [ ⚡ Alternatives ]   │
└──────────────────────────────────────────────────────────────┘
```

---

### 6.4 `ig-flow-surface`

A wizard/step sequence. Existing screens become steps; progress is always
visible. Agent can assist per step (suggestions) or observe the entire flow.

```
┌──────────────────────────────────────────────────────────────┐
│  NEW TASK                                                    │
│  ── ● ──────── ○ ──────── ○ ──────── ○ ──                   │
│  details    ai-mode    confirm    done                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  What needs to be done?                                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Task title...                                        │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  Priority                                                    │
│  ○ Low   ● Medium   ○ High   ○ Critical                      │
│                                                              │
│  ╔══════════════════════════════════════════════════════╗   │
│  ║  ⚡ Coordinator suggests:   "High — similar to #421" ║   │
│  ║  [ Use suggestion ]  [ Ignore ]                      ║   │
│  ╚══════════════════════════════════════════════════════╝   │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│                                        [ Next → ]           │
└──────────────────────────────────────────────────────────────┘
```

---

### 6.5 `ig-timeline-surface`

A temporal view of what happened in a session, project, or agent's work.
Not just an event log — a rich interactive history with expandable events.

```
┌──────────────────────────────────────────────────────────────┐
│  SESSION HISTORY                           Today, Sprint 12  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ─ NOW ──────────────────────────────────────────────────── │
│                                                              │
│  14:52  ⚡  Coordinator — Plan approved, starting work       │
│  14:46  ⚡  Coordinator — Revised plan after feedback        │
│  14:45  ●   You — Reviewed and approved plan                │
│  14:31  ⚡  Coordinator — Found 3 blockers (expand →)       │
│  14:23  ⚡  Coordinator — Started planning "Auth Refactor"   │
│  14:21  ●   You — Delegated "Plan Auth Refactor"            │
│                                                              │
│  ─ 13:00 ───────────────────────────────────────────────── │
│                                                              │
│  13:04  ●   You — Created task "Auth Refactor"              │
│  13:00  ⚡  Coordinator — Wakeup, scanned 12 pending tasks  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 7. Tier 4 — Compositions (Presets)

New composition presets for the full interactive agent application shape.

### 7.1 `agent_workspace`

For working alongside a proactive agent. Left panel: task/item list. Main:
active artifact or observation. Right panel: agent presence + evidence.

Layout:
```
┌──────────┬────────────────────────────┬─────────────┐
│ list     │ main                       │ agent       │
│ sidebar  │ (artifact | proposal |     │ presence    │
│          │  observation | empty)      │ evidence    │
│          │                            │ context     │
├──────────┴────────────────────────────┴─────────────┤
│ footer   stat_blocks | primary_action                │
└──────────────────────────────────────────────────────┘
```

Preset signals:
- `requires_agent_presence: true`
- `supports_proactive_alerts: true`
- `default_aside_content: [:agent_presence, :evidence]`

### 7.2 `decision_workspace` (extended)

Extends existing preset with evidence block in aside and timeline in footer.

```
┌──────────┬────────────────────────────┬─────────────┐
│ summary  │ main (proposal | compare)  │ aside       │
│          │                            │ chat        │
│          │                            │ evidence    │
├──────────┴────────────────────────────┴─────────────┤
│ footer   actions | timeline (collapsed)              │
└──────────────────────────────────────────────────────┘
```

### 7.3 `agent_cockpit`

For managing multiple agents simultaneously.

```
┌─────────────────────────────────────────────────────┐
│  summary   agent status board (presence row)        │
├──────────────────────────────────────────────────────┤
│                                                      │
│  main   observation_surface (tabbed, per agent)      │
│                                                      │
├──────────────────────────────────────────────────────┤
│  footer   timeline | alerts                          │
└──────────────────────────────────────────────────────┘
```

New ScreenSpec DSL for this preset:

```ruby
Igniter::Web.screen(:cockpit, intent: :multi_agent) do
  title "Agent Cockpit"
  compose with: :agent_cockpit        # new preset

  presence :coordinator               # → summary zone (row)
  presence :analyst                   # → summary zone (row)
  presence :reviewer                  # → summary zone (row)

  observe :coordinator, tabbed: true  # → main zone (tabs)
  observe :analyst,     tabbed: true
  observe :reviewer,    tabbed: true

  alerts :all                         # → footer zone
  timeline :session                   # → footer zone (collapsed)
end
```

### 7.4 `artifact_workspace`

For reviewing and working with agent-produced documents.

```
┌──────────────────────────────────┬─────────────────┐
│                                  │ aside           │
│  main   artifact (full width)    │ proposal        │
│         with lifecycle bar       │ evidence        │
│         and version history      │ agent_presence  │
│                                  │                 │
├──────────────────────────────────┴─────────────────┤
│  footer   approve | request_changes | compare_diff  │
└──────────────────────────────────────────────────────┘
```

---

## 8. New ScreenSpec DSL Keywords

Extending the existing ScreenSpec vocabulary:

| New keyword | Zone | Purpose |
|-------------|------|---------|
| `presence :agent_name` | aside / summary | Agent presence block |
| `evidence :agent_name` | aside | Evidence/reasoning block |
| `observe :agent_name, mode:` | main | Live observation surface |
| `propose :name, from: :agent` | main | Proposal block for review |
| `artifact :name, kind:` | main | Artifact display with lifecycle |
| `delegate :name, to: :agent` | main | Delegation contract surface |
| `decide :name` | main / footer | Decision point component |
| `timeline :name, scope:` | footer / aside | Temporal event surface |
| `alert :agent_name` | top / summary | Proactive alert bar binding |
| `context_view :agent_name` | aside | Agent context inspection |

Usage in ScreenSpec:

```ruby
Igniter::Web.screen(:review_plan, intent: :human_decision) do
  title "Review Coordinator's Plan"
  compose with: :decision_workspace

  subject :auth_refactor              # summary zone

  propose :coordinator_plan,          # main zone
          from: :coordinator,
          kind: :plan

  evidence :coordinator               # aside zone (collapsed)
  context_view :coordinator           # aside zone (very collapsed)

  action :accept, run: "Contracts::AcceptPlan"   # footer
  action :reject, run: "Contracts::RejectPlan"   # footer
  action :modify, run: :flow                     # footer
end
```

---

## 9. CSS Architecture

The kit uses a **BEM-like flat class system** without preprocessors.
All classes follow the `ig-{block}--{modifier}` pattern already established
in the existing codebase.

### 9.1 CSS Custom Properties (Token Layer)

```css
:root {
  /* Colors — semantic */
  --ig-color-human:       #2f2a1f;
  --ig-color-agent:       #1a4fd6;
  --ig-color-signal:      #f2b84b;
  --ig-color-positive:    #1e6641;
  --ig-color-caution:     #c8862a;
  --ig-color-negative:    #b03030;
  --ig-color-neutral:     #8a8278;

  /* Surfaces */
  --ig-surface-0:         #f8f4ea;
  --ig-surface-1:         #fffdf7;
  --ig-surface-2:         #f0ece0;
  --ig-border:            #2f2a1f;
  --ig-border-soft:       #c8c0b0;

  /* Spacing */
  --ig-space-1:  4px;
  --ig-space-2:  8px;
  --ig-space-3:  12px;
  --ig-space-4:  16px;
  --ig-space-6:  24px;
  --ig-space-8:  32px;
  --ig-space-12: 48px;
  --ig-space-16: 64px;

  /* Typography */
  --ig-font-sans:  "ui-sans-serif", system-ui, sans-serif;
  --ig-font-mono:  "ui-monospace", "Cascadia Code", monospace;

  --ig-size-display:    42px;
  --ig-size-heading:    24px;
  --ig-size-subheading: 16px;
  --ig-size-body:       15px;
  --ig-size-caption:    12px;
  --ig-size-mono:       13px;
  --ig-size-eyebrow:    11px;

  /* Layout */
  --ig-radius-machine:  0px;
  --ig-radius-human:    4px;
  --ig-border-width:    1px;
  --ig-shadow-flat:     4px 4px 0 var(--ig-border);
  --ig-shadow-deep:     8px 8px 0 var(--ig-border);
}
```

### 9.2 Machine vs Human Register Classes

```css
/* Machine register — operator/data surfaces */
.ig-register--machine {
  border-radius: var(--ig-radius-machine);
  font-family: var(--ig-font-mono);
  background: var(--ig-surface-0);
  border: var(--ig-border-width) solid var(--ig-border);
}

/* Human register — wizard/conversation surfaces */
.ig-register--human {
  border-radius: var(--ig-radius-human);
  font-family: var(--ig-font-sans);
  background: var(--ig-surface-1);
  border: var(--ig-border-width) solid var(--ig-border-soft);
}

/* Agent-authored content stripe */
.ig-authored--agent {
  border-left: 3px solid var(--ig-color-agent);
  padding-left: var(--ig-space-4);
}

/* Human-authored content stripe */
.ig-authored--human {
  border-left: 3px solid var(--ig-color-human);
  padding-left: var(--ig-space-4);
}
```

### 9.3 Pulse Animation For Agent States

```css
@keyframes ig-pulse {
  0%, 100% { opacity: 1; }
  50%       { opacity: 0.4; }
}

@keyframes ig-ping {
  0%   { transform: scale(1);    opacity: 0.8; }
  100% { transform: scale(2.5);  opacity: 0; }
}

.ig-signal--active::before {
  content: "";
  display: inline-block;
  width: 8px; height: 8px;
  border-radius: 50%;
  background: var(--ig-color-agent);
  animation: ig-pulse 2s ease-in-out infinite;
  margin-right: var(--ig-space-2);
}

.ig-signal--needs-input::before {
  background: var(--ig-color-signal);
  animation: ig-pulse 1s ease-in-out infinite;
}
```

### 9.4 Skeleton Shimmer

```css
@keyframes ig-shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position:  200% 0; }
}

.ig-skeleton {
  background: linear-gradient(
    90deg,
    var(--ig-surface-2) 25%,
    var(--ig-surface-1) 50%,
    var(--ig-surface-2) 75%
  );
  background-size: 200% 100%;
  animation: ig-shimmer 1.5s ease-in-out infinite;
}
```

---

## 10. Arbre Component Registration

New components register themselves via `builder_method` following the existing
pattern in `Igniter::Web::Component`:

```ruby
# packages/igniter-web/lib/igniter/web/components/agent_presence_node.rb
module Igniter
  module Web
    module Components
      class AgentPresenceNode < Component
        builder_method :agent_presence_node

        def build(node, &block)
          agent_name = node.props[:agent]
          status     = node.props[:status] || :unknown

          super(
            class:    class_names("ig-node", "ig-agent-presence",
                                  "ig-signal--#{dasherize(status)}"),
            "data-ig-agent":        agent_name,
            "data-ig-agent-status": status,
            "data-ig-live":         true
          ) do
            header class: "ig-agent-presence-header" do
              div class: "ig-agent-presence-identity" do
                span class: "ig-agent-presence-name" do
                  text dasherize(agent_name.to_s)
                end
                span class: "ig-signal--#{dasherize(status)} ig-agent-presence-status" do
                  text status.to_s
                end
              end
            end

            if node.props[:show_activity] && node.props[:activity]
              div class: "ig-agent-presence-activity ig-authored--agent" do
                text node.props[:activity]
              end
            end

            if node.props[:show_controls]
              footer class: "ig-agent-presence-controls" do
                button "Message", type: "button",
                       class: "ig-action-button ig-action-button--sm",
                       "data-ig-cast": "message", "data-ig-agent": agent_name
                button "View work", type: "button",
                       class: "ig-action-button ig-action-button--sm",
                       "data-ig-cast": "show_observation", "data-ig-agent": agent_name
              end
            end

            render_build_block(block, self)
          end
        end

        private

        def tag_name = "article"
      end
    end
  end
end
```

New components to add to `igniter-web`:
- `components/agent_presence_node.rb` → `view_agent_presence_node`
- `components/proposal_node.rb` → `view_proposal_node`
- `components/evidence_node.rb` → `view_evidence_node`
- `components/artifact_node.rb` → `view_artifact_node`
- `components/decision_node.rb` → `view_decision_node`
- `components/delegation_node.rb` → `view_delegation_node`
- `components/timeline_node.rb` → `view_timeline_node`
- `components/alert_node.rb` → `view_alert_node`
- `components/stat_block_node.rb` → `view_stat_block_node`
- `components/skeleton_node.rb` → `view_skeleton_node`
- `components/observation_node.rb` → `view_observation_node`

---

## 11. ScreenSpec DSL Registration

New ScreenSpec elements register via the `element` registration protocol:

```ruby
# In ScreenSpec or a DSL extension module:

def presence(agent_name, **options)
  @elements << Element.new(
    kind: :agent_presence,
    name: agent_name,
    role: options.fetch(:role, :aside),
    options: options.merge(agent: agent_name)
  )
end

def evidence(agent_name, **options)
  @elements << Element.new(
    kind: :evidence,
    name: :"#{agent_name}_evidence",
    role: :aside,
    options: options.merge(agent: agent_name, collapsed: options.fetch(:collapsed, true))
  )
end

def observe(agent_name, **options)
  @elements << Element.new(
    kind: :observation,
    name: :"#{agent_name}_observation",
    role: options.fetch(:role, :main),
    options: options.merge(agent: agent_name)
  )
end

def propose(name, **options)
  @elements << Element.new(
    kind: :proposal,
    name: name,
    role: :main,
    options: options
  )
end

def decide(name, **options)
  @elements << Element.new(
    kind: :decision,
    name: name,
    role: options.fetch(:role, :main),
    options: options
  )
end

def timeline(name, **options)
  @elements << Element.new(
    kind: :timeline,
    name: name,
    role: :footer,
    options: options
  )
end
```

---

## 12. Composition Preset Extensions

New presets for the agent workspace patterns:

```ruby
# In CompositionPreset:

PRESETS[:agent_workspace] = {
  intent: :agent_collaboration,
  zone_order: [:summary, :main, :aside, :footer],
  preferred_zones: {
    subject:       :summary,
    need:          :summary,
    stat:          :summary,
    show:          :main,
    observe:       :main,
    propose:       :main,
    artifact:      :main,
    decide:        :main,
    presence:      :aside,
    evidence:      :aside,
    context_view:  :aside,
    chat:          :aside,
    action:        :footer,
    timeline:      :footer,
    alert:         :summary
  },
  policy_hints: {
    requires_agent_presence: true,
    supports_proactive_alerts: true,
    supports_live_updates: true
  }
}

PRESETS[:agent_cockpit] = {
  intent: :multi_agent,
  zone_order: [:summary, :main, :footer],
  preferred_zones: {
    presence: :summary,
    observe:  :main,
    timeline: :footer,
    alert:    :summary
  },
  policy_hints: {
    multi_agent: true,
    tabbed_main: true
  }
}

PRESETS[:artifact_workspace] = {
  intent: :artifact_review,
  zone_order: [:main, :aside, :footer],
  preferred_zones: {
    artifact: :main,
    propose:  :aside,
    evidence: :aside,
    presence: :aside,
    action:   :footer
  },
  policy_hints: {
    requires_action: true,
    artifact_first: true
  }
}
```

---

## 13. Live Update Architecture

For components that update without page reload (`agent_presence`, `alert_bar`,
`stream_node`, `observation_node`), the kit defines a lightweight client-side
update protocol using data attributes and a minimal vanilla JS runtime.

### 13.1 Data Attributes Protocol

```html
<!-- Component subscribes to SSE channel -->
<article data-ig-live="true"
         data-ig-channel="coordinator"
         data-ig-event="agent_status">
  <!-- content updated by JS on new event -->
</article>

<!-- Alert bar receives proactive push -->
<div data-ig-alert-zone="true"
     data-ig-channel="broadcast"
     data-ig-event="needs_attention">
  <!-- injected by JS when event arrives -->
</div>
```

### 13.2 Minimal JS Runtime

One small vanilla JS file (no framework dependency, ~200 lines) that:
1. Finds all `[data-ig-live]` elements on page load
2. Opens SSE connections for their channels
3. Updates component content on events via `innerHTML` or `morphdom`
4. Injects alert bars into `[data-ig-alert-zone]` on `needs_attention` events

```javascript
// igniter-web-live.js (~200 lines, no dependencies)
const IgniterLive = {
  channels: new Map(),

  init() {
    document.querySelectorAll("[data-ig-live]").forEach(el => {
      const channel = el.dataset.igChannel;
      const event   = el.dataset.igEvent;
      if (channel && event) this.subscribe(el, channel, event);
    });

    document.querySelectorAll("[data-ig-alert-zone]").forEach(el => {
      const channel = el.dataset.igChannel;
      this.subscribeAlerts(el, channel);
    });
  },

  subscribe(el, channel, event) {
    const source = this.getOrCreate(channel);
    source.addEventListener(event, e => {
      const data = JSON.parse(e.data);
      this.updateElement(el, data);
    });
  },

  subscribeAlerts(el, channel) {
    const source = this.getOrCreate(channel);
    source.addEventListener("needs_attention", e => {
      const data = JSON.parse(e.data);
      this.injectAlert(el, data);
    });
  },

  getOrCreate(channel) {
    if (!this.channels.has(channel)) {
      this.channels.set(channel, new EventSource(`/stream/${channel}`));
    }
    return this.channels.get(channel);
  },

  updateElement(el, data) {
    // Replace data attributes with new values
    Object.entries(data).forEach(([key, value]) => {
      const attr = `data-ig-${key.replace(/_/g, "-")}`;
      if (el.hasAttribute(attr)) el.setAttribute(attr, value);
    });
    // Re-render text content of labeled spans
    const valueEl = el.querySelector("[data-ig-live-value]");
    if (valueEl && data.value !== undefined) valueEl.textContent = data.value;
  },

  injectAlert(zone, data) {
    const bar = document.createElement("div");
    bar.className = "ig-alert-bar ig-authored--agent";
    bar.innerHTML = `
      <span class="ig-alert-message">${data.message}</span>
      ${(data.actions || []).map(a =>
        `<button class="ig-action-button ig-action-button--sm"
                 data-ig-cast="${a.cast}"
                 data-ig-params='${JSON.stringify(a.params || {})}'>${a.label}</button>`
      ).join("")}
      <button class="ig-alert-dismiss" data-ig-dismiss>✕</button>
    `;
    bar.querySelector("[data-ig-dismiss]")
      .addEventListener("click", () => bar.remove());
    zone.prepend(bar);
  }
};

document.addEventListener("DOMContentLoaded", () => IgniterLive.init());
```

Zero npm, zero webpack, zero framework. Drops into the existing Rack server
as a single static JS file served from `igniter-web/assets/`.

---

## 14. Complete App Example With UI Kit

Putting the entire kit together in the `TaskAssistant` app from the DSL
proposal:

```ruby
# surfaces/workspace_surface.rb
module Surfaces
  def self.workspace
    Igniter::Web.screen(:workspace, intent: :agent_collaboration) do
      title "Task Assistant"
      compose with: :agent_workspace

      # Summary zone
      subject :tasks_summary              # → overview stat block
      presence :coordinator               # → agent presence (live)
      alert :coordinator                  # → alert bar (proactive)

      # Main zone
      show :task_list                     # → collection with actions

      # Aside zone
      evidence :coordinator               # → evidence (collapsed)
      context_view :coordinator           # → context inspection

      # Footer zone
      action :new_task,    run: :flow,    label: "New Task"
      action :delegate_all, run: :agent,  label: "Delegate All"
      timeline :session,   collapsed: true
    end
  end
end
```

```ruby
# surfaces/proposal_surface.rb
module Surfaces
  def self.review_plan
    Igniter::Web.screen(:review_plan, intent: :human_decision) do
      title "Review AI Plan"
      compose with: :decision_workspace

      subject :task                       # summary zone
      propose :coordinator_plan,          # main zone
              from: :coordinator,
              kind: :plan

      evidence :coordinator               # aside zone
      chat with: :coordinator             # aside zone

      decide :plan_decision               # footer zone
      action :accept,  run: "Contracts::AcceptPlan"
      action :modify,  run: :flow
      action :reject,  run: "Contracts::RejectPlan"
    end
  end
end
```

```ruby
# surfaces/observation_surface.rb
module Surfaces
  def self.watch_coordinator
    Igniter::Web.screen(:watch_coordinator, intent: :live_process) do
      title "Watching Coordinator"
      compose with: :operator_console

      subject :current_task               # summary zone
      observe :coordinator, mode: :live   # main zone (live stream)
      context_view :coordinator           # aside zone

      action :interrupt,   label: "Interrupt",  run: :cast
      action :take_over,   label: "Take over",  run: :cast
      action :give_hint,   label: "Give hint",  opens: :modal
    end
  end
end
```

---

## 15. Implementation Roadmap

### Phase 1 — Design Tokens + Register CSS (1–2 days)

- Extract color/spacing/typography tokens to CSS custom properties
- Add `.ig-register--machine` and `.ig-register--human` classes
- Add `.ig-authored--agent` and `.ig-authored--human` stripe utilities
- Add pulse/ping animations for agent states
- Add skeleton shimmer animation
- Ship as `igniter-web/assets/igniter.css`

### Phase 2 — Tier 1 Primitives (2–3 days)

- `ig-badge` (ViewBadgeNode component)
- `ig-signal` (atom class, no component needed)
- `ig-avatar` (ViewAvatarNode component)
- `ig-progress` (ViewProgressNode component)
- `ig-skeleton` (ViewSkeletonNode component)
- Register all via `builder_method`

### Phase 3 — Tier 2 Agent Blocks (3–5 days)

- `ViewAgentPresenceNode` — most important, implement first
- `ViewStatBlockNode` — replaces manual stat HTML in operator board
- `ViewProposalNode` — core review surface
- `ViewEvidenceNode` — collapsed by default, expandable
- `ViewDecisionNode` — structured choice surface
- `ViewTimelineNode` — temporal history

### Phase 4 — ScreenSpec Extensions (2–3 days)

- `presence`, `evidence`, `observe`, `propose`, `decide`, `timeline` keywords
- New composition presets: `agent_workspace`, `agent_cockpit`, `artifact_workspace`
- Extended composition policy for new kinds
- Update `CompositionPreset::PRESETS` table

### Phase 5 — Live Update Runtime (1–2 days)

- `igniter-web-live.js` (~200 lines, zero deps)
- SSE subscription via `data-ig-live` / `data-ig-channel`
- Alert injection via `data-ig-alert-zone`
- Served from `igniter-web/assets/`
- The JS file is optional — app works without it, just no live updates

### Phase 6 — Tier 3 Full Surfaces (3–5 days)

- `ViewObservationSurface` (wraps stream + controls)
- `ViewProposalSurface` (full-width proposal review)
- `ViewFlowSurface` (step wizard with progress bar)
- `ViewTimelineSurface` (full temporal history)
- `ViewAlertSurface` (dedicated alert center)

### Phase 7 — Reference App Integration (ongoing)

- Port `interactive_operator` to use new components
- Build `task_assistant` reference app using full kit
- Validate component vocabulary against real usage
- Extract divergences back into component improvements

---

## 16. Open Questions

1. **CSS delivery**: Ship as a static file in `igniter-web/assets/`, or
   inline in `ViewGraphRenderer` output, or as a separate `igniter-ui` gem?
   The existing POC uses inline styles — moving to a stylesheet is the right
   direction but requires deciding how the file is served.

2. **JS delivery**: Similar question for `igniter-web-live.js`. The zero-
   dependency constraint is non-negotiable, but the serving mechanism needs
   a decision.

3. **Agent context protocol**: How does a component like `ViewAgentPresenceNode`
   get the agent's current status? Via the MountContext? Via a direct agent
   registry query? Via an injected prop from the surface definition?

4. **SSE channel naming**: The live update JS uses `/stream/:channel`. Who
   owns this endpoint? The `igniter-web` mount? The `igniter-application`
   Rack host? A dedicated `igniter-streams` adapter?

5. **Alert bar injection boundary**: When an agent broadcasts `needs_attention`,
   which page is targeted? How does the server know which browser tab to alert?
   Session cookies? WebSocket registry? SSE fan-out?

6. **Dark mode / theme switching**: The design token layer makes theming
   straightforward (swap `--ig-color-*` values) but no theme switching is
   proposed yet. This can be deferred.

7. **Accessibility**: The brutalist/sharp aesthetic is accessible-friendly
   (high contrast, clear structure) but `aria-*` attributes need to be added
   to all new components. Not in scope for the first iteration but must not
   be forgotten.

These questions do not block Phase 1–3 implementation. They become relevant
in Phase 4–5 when the live update and agent binding layers are introduced.
