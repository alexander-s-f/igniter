# Agent Track Pattern — Formal Specification

Date: 2026-04-25.
Author: external expert review.
Source: `docs/dev/agent-track-lifecycle-doctrine.md`, `docs/dev/tracks.md`,
`docs/dev/constraints.md`, direct analysis of the full docs/dev track corpus.
Status: formal specification — ready for supervisor review as a scalability
investment and future Igniter native agent capability.

---

## The Central Insight

The docs-agent protocol that emerged in this project is not just project
management. It is a distributed computation model running in prose:

| Protocol Concept | Igniter Concept |
|------------------|----------------|
| Track | `Contract` — inputs, computation, outputs, validation |
| Signal | `input` node |
| Agent work | `compute` node |
| Handoff | `output` node (structured observation) |
| Supervisor gate | verification / `guard` |
| Constraint set | capability policy |
| Active Tracks table | `CompiledGraph` resolution order |
| Tracks History | archived execution cache |
| Parallel window | `runner :thread_pool` |
| Research docs | `const` — available but not in the resolution path |

**The Agent Track system is an Igniter contract graph running on language models
as executors.**

This means: when Igniter grows first-class agent capabilities, this protocol
can be compiled directly. Every rule in this document is a design constraint
on that future compiler.

---

## 1. Formal Vocabulary

Precise definitions. These are the canonical names across all future Igniter
agent tooling.

### Track

A bounded, named unit of agent work with explicit inputs, outputs, policy, and
verification. A track has exactly one lifecycle at a time.

```
Track {
  id:           stable name (kebab-case, matches filename)
  goal:         one sentence
  owner:        [AgentRole]        # who does the work
  gate:         AgentRole          # who accepts/rejects
  constraints:  [ConstraintSet]    # named policy sets
  scope_in:     [string]           # explicit allowed targets
  scope_out:    [string]           # explicit forbidden targets
  dependencies: [Track.id]        # must be accepted before this starts
  parallel:     WindowId?          # if set, runs concurrently with same window
  state:        TrackState
  tasks:        [Task]
  handoffs:     [Handoff]
  acceptance:   AcceptanceRecord?
}
```

### TrackState

```
proposed → open → active → pending_review → accepted
                                          → rejected
                                          → deferred → (archived | re-opened)
                  → blocked
```

State transitions are explicit — they require a labeled actor note. No track
changes state without a record of who changed it and why.

### Task

A discrete unit of work within a track, assigned to one owner. A track can
have multiple tasks, potentially in parallel.

```
Task {
  id:       integer (1, 2, ...)
  goal:     one sentence
  owner:    AgentRole
  window:   WindowId?   # parallel window membership
  state:    pending | active | complete | blocked
  criteria: [string]   # acceptance criteria
}
```

### Window

A parallel execution group. Tasks in the same window can proceed simultaneously.
The gate reviews all tasks in a window together.

```
Window {
  id:     string (e.g. "A", "B", "main")
  tasks:  [Task.id]
  gate:   AgentRole   # who reviews the full window
}
```

### Signal

A trigger that may open a new track. A signal alone does not create a track.
The gate must convert a signal into an open track with scope.

```
Signal {
  kind:    :pressure | :failure | :research | :expert | :handoff | :user
  source:  string
  content: string
  track?:  Track.id   # nil until gate converts it
}
```

### AgentRole

A named actor with a defined scope and capability declaration.

```
AgentRole {
  name:          string                     # e.g. "Agent Application"
  scope:         [package | area]           # what they can change
  capabilities:  [ConstraintSet]            # what policy they operate under
  kind:          :implementor | :supervisor | :researcher | :observer
}
```

Roles are not identities — they are function declarations. The same LLM
session can fill different roles in different tracks.

### ConstraintSet

A named, versioned boundary policy. Referenced by name, not repeated inline.

```
ConstraintSet {
  name:     :symbol
  forbid:   [string]   # explicit prohibitions
  allow:    [string]   # explicit permissions
  extends:  [ConstraintSet.name]?   # inheritance
}
```

Constraint sets compose: `:poc_scope extends [:no_runtime, :no_web, :no_cluster]`.

### Handoff

A structured observation emitted by an agent upon task completion.

```
Handoff {
  role:     AgentRole
  track:    Track.id
  status:   :landed | :blocked | :needs_review
  delta:    [FileChange]
  verify:   VerifyResult
  ready:    [AgentRole]    # who can proceed
  block:    BlockerRef?
}
```

### AcceptanceRecord

The gate's decision on a completed track.

```
AcceptanceRecord {
  gate:       AgentRole
  decision:   :accepted | :rejected | :deferred | :follow_up
  rationale:  string
  next:       Track.id?     # if follow_up, what opens next
  timestamp:  timestamp
}
```

### MemoryLayer

The context architecture. Each layer has a read cost and a write policy.

```
MemoryLayer {
  name:         :active | :warm | :cold | :speculative
  documents:    [path]
  read_cost:    :always | :on_demand | :directed_only
  write_policy: :append | :replace | :archive_first
  ttl:          session | project | permanent
}
```

---

## 2. Memory Architecture

Context has four layers. Agents read only the layers their task requires.

```
┌─────────────────────────────────────────────────────┐
│  ACTIVE (hot)           ~400 tokens                 │
│  tracks.md              always loaded               │
│  current track file     always loaded               │
├─────────────────────────────────────────────────────┤
│  WARM (constraint)      ~300 tokens                 │
│  constraints.md         loaded once per session     │
│  lifecycle doctrine     loaded once per session     │
├─────────────────────────────────────────────────────┤
│  COLD (history)         unlimited, never active     │
│  tracks-history.md      load only when directed     │
│  retired track files    load only when referenced   │
├─────────────────────────────────────────────────────┤
│  SPECULATIVE (research) unlimited, off the path     │
│  docs/research-horizon/ load only when accepted     │
│  docs/experts/          load only when accepted     │
└─────────────────────────────────────────────────────┘
```

### Layer Rules

**Active layer:** an agent session must start by reading the active layer.
Nothing else is required unless the track links it explicitly. The active layer
must stay under ~600 tokens total across its documents.

**Warm layer:** constraint sets and lifecycle doctrine are read once per session,
not per track. They are shared policy — their cost is amortized.

**Cold layer:** history is never active. Agents do not browse history. The gate
may consult history to check precedent, but agents only read it if their track
says `see: tracks-history.md#<anchor>`.

**Speculative layer:** research and expert proposals are off the execution path
until the gate explicitly graduates a proposal into an open track. An agent
reading speculative docs without direction is out of scope.

### Memory Compression Protocol

When a track is accepted:

1. The gate appends one `AcceptanceRecord` to the track file.
2. The track file moves to `tracks-history.md` (full content, anchored by track id).
3. The track file is replaced by a stub:

```markdown
# <Track Name>
Status: accepted 2026-04-25. See [tracks-history.md#<id>](./tracks-history.md#<id>).
```

4. The Active Handoffs table in `tracks.md` removes the row.

This bounds active context growth to O(active_tracks), not O(project_history).

---

## 3. Track Topology

Tracks are not isolated. They form a directed graph.

### Linear Chain

The most common topology. Each track depends on the previous:

```
signal → [Track A] → accepted → [Track B] → accepted → [Track C]
```

The capsule transfer chain (15+ tracks) is a linear chain. Each track opens
only after its predecessor is accepted. Long chains should be reviewed for
opportunities to merge adjacent tracks that have no logical independence.

### Parallel Window

Tasks within one track that are independent of each other:

```
Track: Feedback POC
  Task 1 [window:A]: Application boundary  (Agent Application)
  Task 2 [window:A]: Web rendering         (Agent Web)
  Gate reviews window A when both tasks report
```

A track can have multiple windows if later tasks depend on earlier window
completion:

```
window:A → [both tasks complete] → window:B → [next tasks start]
```

This is the equivalent of `runner :thread_pool` in a contract graph.

### Branch

A gate decision opens one of several next tracks depending on outcome:

```
Track: Proposal Review
  accepted → [Track: Narrow Implementation]
  rejected → [Track: Research Reframe]
  deferred → [Track: Hold / Revisit Trigger]
```

Branch topology is the agent equivalent of a `branch` node in a contract.

### Tree

One track opens multiple independent child tracks that can proceed in parallel:

```
Track: Architecture Decision
  accepted →
    [Track: Contracts slice]     (Agent Contracts)
    [Track: Application slice]   (Agent Application)
    [Track: Web slice]           (Agent Web)
  All three can proceed simultaneously.
  Gate reviews when all three report.
```

Tree topology is the agent equivalent of a `collection` node.

### Topology Rules

- No cycles: a track cannot depend on itself or any of its descendants.
- Explicit dependencies: if track B depends on A, this must be declared in B's
  `dependencies` field. Implicit dependencies are forbidden.
- Depth limit (recommended): chains longer than 8 tracks without a tree or
  branch should be reviewed. Long chains accumulate debt: each track narrows
  scope without reflecting on the bigger shape.

---

## 4. Agent Role Model

Roles are capability declarations, not identities. A role says: what this actor
can change, under what policy, and to whom they report.

### Role Taxonomy

```
:supervisor
  Can: open tracks, accept/reject/defer, update Active Tracks, update constraints
  Cannot: implement (usually), change package code directly
  Reports to: user / project owner

:implementor
  Can: write code and docs in their declared scope
  Cannot: accept their own work, open new tracks, change constraint sets
  Reports to: :supervisor

:researcher
  Can: write in docs/research-horizon/, docs/experts/
  Cannot: write package code, open implementation tracks
  Reports to: :supervisor

:observer
  Can: read anything, append observations to tracks
  Cannot: change code, docs, or track state
  Reports to: :supervisor
```

### Role Scope

Each implementor role has a declared scope:

```
[Agent Application / Codex]   scope: packages/igniter-application, examples/application
[Agent Web / Codex]           scope: packages/igniter-web, examples (web surfaces)
[Agent Contracts / Codex]     scope: packages/igniter-contracts, packages/igniter-extensions
[Agent Embed / Codex]         scope: packages/igniter-embed, examples/contracts
[Agent Cluster / Codex]       scope: packages/igniter-cluster
[Research Horizon / Codex]    scope: docs/research-horizon
```

A handoff that touches files outside the declared scope requires explicit gate
approval before the work begins.

### Role Capability Inheritance

Roles inherit constraint sets:

```
all roles: :no_private_data_in_public_tracks
implementors: :no_unapproved_scope_expansion
researchers: :research_only
```

This means a researcher never needs to re-read constraint rules — they are
embedded in the role definition.

---

## 5. Constraint System

Constraint sets are named, composable, versioned policies. They are the
permission system for agent work.

### Anatomy of a Constraint Set

```
:interactive_poc_guardrails {
  forbid: [
    full_interactive_app_facade,
    ui_kit,
    plane_canvas,
    sse_live_updates,
    session_framework,
    generator,
    production_server,
    cluster_placement
  ]
  allow: [
    app_local_ruby_services,
    compact_rack_surfaces,
    query_string_feedback,
    smoke_scripts
  ]
  extends: []
}
```

### Constraint Composition

Sets compose via `extends`:

```
:poc_scope extends [:no_runtime, :no_web_transport, :no_new_package]
```

The composed set is the union of all prohibitions and the intersection of all
permissions. Compositions are resolved at track-open time and embedded in the
track file, so agents do not need to recursively resolve sets at runtime.

### Constraint Versioning

Constraint sets carry an implicit version: the git commit at which they were
last changed. A track references the constraint set by name and inherits the
version current when the track opens. If a set changes after a track opens,
the track is not retroactively affected.

This is equivalent to `cache_ttl` semantics in Igniter's node cache: the policy
is frozen at the point of consumption.

### Constraint Set Lifecycle

```
proposed (by researcher / expert)
  → supervisor review
  → accepted into constraints.md
  → referenced by tracks
  → deprecated (when the domain it covers is fully implemented or retired)
```

Constraint sets do not accumulate indefinitely. When a domain area completes
(e.g. the POC pressure test line closes), its constraint set is archived into
a history file alongside the tracks it governed.

---

## 6. Handoff Protocol

The handoff is the unit of agent communication. It is a structured observation
— not a narrative, not a plan, not an explanation. It answers exactly six
questions:

1. **Who** — role and track
2. **What changed** — delta (files, one line each)
3. **Did it verify** — tier and result
4. **Who can proceed** — ready
5. **What is blocked** — block or none
6. **What state** — status

```text
[Agent Role / Codex]
track: <path>
status: landed | blocked | needs-review
delta:
  + <file>: <one-line description>
  ~ <file>: <one-line description>
  - <file>: <one-line description>
verify: <tier>(<result>)
ready: <AgentRole list>
block: none | <BlockerRef>
```

### Verification Tiers

```
docs-only:    git diff --check
code-narrow:  <smoke example> + rspec <touched packages> + rubocop <touched files>
code-full:    rake spec + rake rubocop
```

The tier is declared in the track's Verification Gate section. Agents do not
choose their own tier.

### Handoff Invariants

These must hold for every handoff:

- `track` must reference a currently open track in the Active Handoffs table.
- `status: landed` requires `verify` to pass.
- `status: blocked` requires `block` to name a specific blocker (not "various issues").
- `delta` must list only files within the agent's declared scope, unless the
  track explicitly authorizes cross-scope changes.
- `ready` must name roles that exist in the Active Handoffs table or be `supervisor`.

A handoff that violates any invariant is returned without acceptance. The gate
names the violated invariant, not a general critique.

### Context Shrinkage

A handoff is smaller than the work it summarizes. This is intentional.

```
Agent reads:   ~1,200 tokens (active track + deps)
Agent works:   writes ~500 tokens of code/docs
Agent reports: ~60 tokens (handoff)

Gate reads:    ~60 tokens (handoff) + ~80 tokens (diff review)
Gate decides:  ~30 tokens (acceptance note)
```

The gate never needs to re-read the full track to review a handoff. The delta
and verify result are sufficient for a well-scoped task. If the gate cannot
decide from a handoff, the task was too large.

---

## 7. Scaling Model

How this pattern behaves as the system grows.

### Scaling to More Agents

The Active Handoffs table is the routing table. Each row is one agent assignment.
Adding an agent is adding a row. The agent reads only its row and its linked
track.

At 10 agents:
- Active Tracks table: ~10 rows × ~100 chars = ~1,000 tokens
- Each agent reads table + their track = ~1,600 tokens total

At 50 agents:
- Active Tracks table: ~50 rows = ~5,000 tokens
- This approaches the old `tracks.md` problem.
- Mitigation: group agents by area. The table becomes a two-level index:
  `Area → [Agent rows]`. Agents read their area section only.

At 100+ agents:
- The table splits into area-level routing files: `tracks-application.md`,
  `tracks-contracts.md`, etc.
- Each area file is kept under ~600 tokens.
- `tracks.md` becomes a pure index: `Area → file`, ~20 lines.

This is the same scaling pattern as distributed hash tables: route to the shard,
read only the shard.

### Scaling to More Tracks

Tracks accumulate in history. History is cold — it does not affect active
agent context.

History does have cost: the gate must occasionally consult history for
precedent. Mitigate with anchored search:

- Every history entry has a stable anchor: `#<track-id>`.
- Gate queries history by anchor, not by scanning.
- Future: a content-addressed index over `tracks-history.md` lets the gate
  find precedent by concept, not by position.

At 1,000 archived tracks, history file is ~2,000 lines. Gate never reads it
in full — only queries specific anchors.

### Scaling to More Projects

When multiple projects use the same agent pool:

- Each project has its own `tracks.md`, `constraints.md`, and `tracks-history.md`.
- The agent pool is stateless: roles are declared per-project, not globally.
- Cross-project context is forbidden unless explicitly bridged by a cross-project
  handoff track.

This is the same principle as capsule isolation: a capsule's identity is stable
within its host, not globally. A track's identity is stable within its project.

### Scaling to Longer Sessions

Long-running agent sessions accumulate conversation context. The protocol
mitigates this:

- Handoffs are the only persistent output. Conversation context is ephemeral.
- The gate reads handoffs, not conversation transcripts.
- A fresh agent session reading the active layer + current track is indistinguishable
  from a continuation of the previous session, because the track file IS the
  session state.

This is stateless agent design: the track file is the state machine. The agent
is the executor.

---

## 8. Error and Failure Handling

### Verification Failure

Agent produces work but verification fails:

```
[Agent Application / Codex]
track: feedback-track.md
status: blocked
delta:
  + app.rb: feedback redirects
verify: code-narrow(rspec 12/0, rubocop 3 OFFENSES)
ready: none
block: rubocop: Style/StringLiterals in app.rb:42,58,71
```

Gate does not re-assign the task. The same agent fixes the violation and
resubmits. A blocked handoff is not a failure — it is correct protocol.

### Scope Violation

Agent changes files outside their declared scope without authorization:

Gate returns the handoff with:

```
[Architect Supervisor / Codex]
Returned: scope violation.
Delta includes packages/igniter-contracts/... which is outside [Agent Application] scope.
Options: (a) remove the cross-scope change, (b) request gate authorization for
cross-scope work, (c) open a new track owned by [Agent Contracts].
```

The violation is named precisely. The agent resubmits or escalates.

### Conflicting Handoffs

Two agents in a parallel window produce conflicting output (e.g. both modify
the same file in incompatible ways):

Gate resolves the conflict before accepting either. Options:

- Accept one, return the other with a correction note.
- Open a reconciliation track owned by both agents.
- Redesign the window to eliminate the overlap.

Conflicts are evidence that the window was incorrectly scoped — two tasks that
share a file are not truly parallel.

### Blocked Track

A track cannot proceed because of an external dependency (e.g. waiting for
a library to release, waiting for a supervisor decision, waiting for private
app pressure):

```
[Agent Cluster / Codex]
track: cluster-target-plan.md
status: blocked
delta: none
verify: n/a
ready: none
block: waiting for capsule host activation to stabilize (dependency: host-activation-commit-readiness-track)
```

The gate acknowledges the block and removes the row from Active Handoffs until
the dependency resolves. The track remains open but inactive. This is the
`standby` state.

### Supervisor Unavailable

If the gate is unavailable, no track can change state. Agents complete their
work and emit handoffs. Handoffs accumulate in track files as `pending_review`.
When the gate returns, it reviews the queue.

The protocol does not self-activate. No track accepts itself.

---

## 9. Formal Lifecycle Diagram

```
                          signal
                            │
                            ▼
                      ┌─────────┐
                      │proposed │ ← gate converts signal
                      └────┬────┘
                           │ gate opens track
                           ▼
                      ┌─────────┐
             ┌────────│  open   │────────┐
             │        └────┬────┘        │
             │ gate assigns│             │ gate rejects
             │             ▼             │ at open
             │       ┌──────────┐        │
             │       │  active  │        ▼
             │       └────┬─────┘   ┌──────────┐
             │            │         │ rejected │
             │   agent    │         └──────────┘
             │  handoff   │
             │            ▼
             │    ┌──────────────┐
             │    │pending_review│
             │    └──────┬───────┘
             │           │ gate reviews
             │    ┌──────┴───────────────┐
             │    │                      │
             ▼    ▼                      ▼
        ┌─────────┐              ┌────────────┐
        │accepted │              │  deferred  │
        └────┬────┘              └─────┬──────┘
             │                         │
             │ compression              │ re-signal
             ▼                         ▼
        ┌──────────┐             ┌──────────┐
        │ archived │             │ re-opened │
        └──────────┘             └──────────┘
```

At any point a track can transition to `blocked`, which suspends it without
closing it. A `blocked` track returns to `active` when its blocker resolves.

---

## 10. Integration with Igniter

This pattern maps directly to Igniter concepts. The mapping is the blueprint
for a future native implementation.

### Track as a Contract

```ruby
class FeedbackTrack < Igniter::Contract
  define do
    input :signal         # what triggered this track
    input :constraints    # named constraint sets

    compute :application_boundary,
      depends_on: [:signal, :constraints],
      call: AgentApplication,
      window: :A

    compute :web_surface,
      depends_on: [:signal, :constraints],
      call: AgentWeb,
      window: :A

    guard :window_A_complete,
      depends_on: [:application_boundary, :web_surface],
      call: GateReview

    output :acceptance, from: :window_A_complete
  end
end
```

Agent roles are `Executor` subclasses. The gate is a `guard` node. Parallel
windows are `runner :thread_pool`. Constraint sets are capability declarations
on each `compute` node.

### Handoff as an Observation

A handoff maps directly to `ObservationFrame` from the Runtime Observatory
Doctrine:

```
Handoff.track    → ObservationNode.id
Handoff.status   → ObservationFacet(status)
Handoff.delta    → ObservationEvidence(changes)
Handoff.verify   → ObservationEvidence(verification)
Handoff.block    → ObservationBlocker
Handoff.ready    → ObservationEdge(triggers)
```

When the Observatory Frame is implemented, agent handoffs are naturally
observable through it — no separate tooling needed.

### Track Graph as a Compiled Graph

The Active Handoffs table is the current resolution order of the track graph.
The dependency declarations between tracks are edges in a `CompiledGraph`.
The gate is the compiler: it validates that the graph is acyclic, that
dependencies are satisfied, and that scope assignments do not conflict.

Future: `Igniter::Agents::TrackCompiler.compile(tracks_directory)` produces
a `CompiledTrackGraph` — the same data structure as a contract's `CompiledGraph`,
but over tracks instead of nodes.

### Constraint Sets as Capability Policy

```ruby
ConstraintSet.define :interactive_poc_guardrails do
  forbid :full_interactive_app_facade
  forbid :ui_kit
  forbid :sse_live_updates
  allow  :app_local_ruby_services
  allow  :compact_rack_surfaces
end

class AgentApplication < Igniter::AI::Agent
  requires_capability :interactive_poc_guardrails
end
```

This is the same `requires_capability` system already implemented in
`Igniter::AI::Tool`. Constraint sets are capability declarations for agents.

---

## 11. Graduation Path

From the current docs-only protocol to a native Igniter agent capability.

### Level 0: Docs Protocol (current)

Track files are Markdown. Agents are LLM sessions. The gate is a human or
LLM acting in supervisor role. Handoffs are text messages appended to files.

This is already working. All subsequent levels are additive.

### Level 1: Structured Track Files (next)

Track files get a structured header in YAML front-matter:

```yaml
---
track: application-web-poc-feedback
state: active
owner: [agent-application, agent-web]
gate: architect-supervisor
constraints: [interactive_poc_guardrails]
dependencies: [application-web-poc-task-creation]
window_A: [task-1, task-2]
verify_tier: code-narrow
---
```

This makes tracks machine-readable without changing their prose content.
A CLI tool can parse the front-matter and generate the Active Handoffs table
automatically, eliminating manual table maintenance.

**Cost:** 15–30 minutes to add front-matter to 5–6 active tracks. Immediately
parseable by tools.

### Level 2: Track Index Generator

A small Ruby script reads all track files with Level 1 front-matter and
generates `tracks.md` automatically:

```bash
bundle exec igniter tracks:index
```

Output: the Active Handoffs table, sorted by dependency order. Gate no longer
maintains the table by hand.

**Cost:** ~100 lines of Ruby. No new package needed — lives in a `bin/` script
or as a Rake task.

### Level 3: Handoff Validator

A CLI command validates handoff format and invariants:

```bash
bundle exec igniter tracks:validate-handoff path/to/track.md
```

Checks:
- Role exists in Active Handoffs table
- Delta files are within role scope
- Verification tier matches track declaration
- Status is valid
- Block is named if status is blocked

**Cost:** ~150 lines of Ruby. Runs in verification gate.

### Level 4: Track Compiler (Igniter-native)

`Igniter::Agents::TrackCompiler` reads structured track files and produces a
`CompiledTrackGraph`:

```ruby
graph = Igniter::Agents::TrackCompiler.compile("docs/dev/")
graph.resolution_order  # → [track_A, track_B, ...]
graph.parallel_windows  # → { "A" => [task_1, task_2] }
graph.blocked_tracks    # → [track with unresolved dependencies]
```

**Cost:** ~300 lines of Ruby. Lives in a new `igniter-agents` package.
Blocked on Level 1 and 2.

### Level 5: Native Agent Execution (future)

`Igniter::AI::Agent` subclasses can be assigned to tracks. The runtime
executor manages parallel windows, handoff collection, gate review, and
state transitions automatically.

This is the fully compiled agent system. Tracks are contracts. Agents are
executors. The gate is a guard node. The whole system runs inside Igniter's
existing runtime.

**Cost:** significant. Blocked on Levels 1–4 and capsule/activation stability.

---

## 12. What Must Not Be Built Yet

Following the supervisor graduation discipline:

**Not acceptable as implementation:**
- Level 4 or 5 without Level 1–3 working in production
- A "track runtime" that manages agent sessions automatically
- Cross-project agent coordination
- Autonomous track opening (the gate must always authorize)
- Self-accepting tracks

**Acceptable as immediate next step:**
- This specification document (done)
- Level 1: add front-matter to 5–6 active tracks
- Update `agent-track-lifecycle-doctrine.md` with formal vocabulary references

**Acceptable as near-term code:**
- Level 2: `tracks:index` generator (~100 lines)
- Level 3: `tracks:validate-handoff` CLI (~150 lines)

---

## Relationship to Other Patterns

| Pattern | Relationship |
|---------|-------------|
| Handoff Doctrine | Track handoffs use HandoffParty + HandoffReceipt vocabulary |
| Interaction Doctrine | Gate review is an operator surface — PendingInput from Interaction |
| Observatory Doctrine | Track state maps to ObservationFrame — tracks are nodes |
| Plastic Runtime Cells | A track is a cell's lifecycle unit — the cell owns the track graph |
| Grammar Compression | Compact handoff format applies Line-Up directly; constraint registry eliminates forbid repetition |
| Agent Cycle Optimization | This document is the formalization of the patterns proposed there |

---

## Candidate Handoff

```text
[External Expert / Codex]
Track: Agent Track Pattern Formalization
Changed: docs/experts/agent-track-pattern.md
Accepted/Ready: ready for supervisor review as scalability specification
Verification: documentation-only
Needs: [Architect Supervisor / Codex] decide:
  (a) accept as expert specification, graduate Level 1 front-matter into a
      narrow implementation track
  (b) accept as reference, incorporate vocabulary into agent-track-lifecycle-
      doctrine.md without new code
  (c) defer Level 1+ pending more POC cycles
Recommendation: accept as expert reference (b). Extract the formal vocabulary
(Track, Task, Window, Signal, Handoff, MemoryLayer) into the doctrine as
canonical names. Begin Level 1 front-matter after the next POC cycle.
Risks: premature formalization can over-engineer a protocol that is still
evolving. The current docs-only system is the living prototype — let it teach
before compiling it.
```
