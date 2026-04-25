# Agent Development Cycle Optimization

Date: 2026-04-25.
Author: external expert review.
Source: direct measurement of `docs/dev/tracks.md`, track files, and handoff
patterns across the full agent protocol.
Status: concrete proposal — implementation can begin immediately.

---

## The Core Problem

The current protocol has one dominant cost: **every agent reads `tracks.md` in
full at the start of every session**.

`tracks.md` is currently **1,702 lines / ~14,000 tokens**. Most of it is
completed work — historical "landed and accepted" entries that are irrelevant to
the current task. An agent reading tracks.md to find its one active task is
paying 14,000 tokens to find ~150 tokens of relevant information.

That is a **93:1 noise-to-signal ratio** at the first read.

Secondary costs:
- Constraint/forbid lists are repeated verbatim in every track file
- Sequential handoff chains force round-trips that could be parallel
- Full verification gates are run even for docs-only changes
- Track files accumulate history in-place, growing without bound

---

## Measured Baseline

From direct inspection:

| Document | Lines | Approx Tokens | Agent Reads Per Cycle |
|----------|-------|--------------|----------------------|
| `tracks.md` | 1,702 | ~14,000 | Every agent, every session |
| Typical track file | 80–150 | ~700–1,200 | 1 agent, 1 session |
| Handoff block (prose) | 20–30 | ~200–300 | Received by supervisor |
| "Out of scope" list | 10–15 | ~100–150 | Repeated in every track |

A single wave with 3 active agents:

```text
current cost per wave:
  3 agents × tracks.md = 3 × 14,000     = 42,000 tokens
  3 agents × active track = 3 × 900     =  2,700 tokens
  3 handoff prose blocks                 =    750 tokens
  total                                  = 45,450 tokens
```

---

## Proposal 1: Split `tracks.md` Into Active + Archive

**The single highest-impact change.**

Split into two files:

### `tracks.md` (new, trimmed)

Contains only what agents need to start:

```markdown
# Active Tracks

First file to read. Find your role → read only your track.

## Active Handoffs

| Agent | Current Task | Track | Dependencies | Return To |
| --- | --- | --- | --- | --- |
| [Agent Application] | Add feedback boundary | feedback-track.md | task-creation-track | Supervisor |
| [Agent Web] | Render feedback surface | feedback-track.md | task-creation-track | Supervisor |
| [Research Horizon] | Standby — activation frame | observatory-activation | expert docs | Supervisor |

## Current Cycle Summary (3 lines max)

Feedback pressure-test is active. Capsule transfer chain complete.
Research Horizon graduated three doctrines. Next: activation frame.

## Protocol

1. Read this file.
2. Read your track document (link above).
3. Do the task.
4. Append compact handoff to the track.
5. Return status to Supervisor.

[Compact Status Template]
...
```

Target size: **40–60 lines / ~400 tokens**.

### `tracks-history.md` (archive)

Everything that is currently "landed and accepted". Agents do NOT read this
unless explicitly directed. It is reference material for humans and for the
Supervisor when reviewing patterns.

**Estimated saving per agent session:**

```text
before: 14,000 tokens (tracks.md)
after:     400 tokens (tracks-active.md)
saving: 13,600 tokens per agent × per session
```

At 5 agent sessions per day: **68,000 tokens/day saved** from this change alone.

---

## Proposal 2: Shared Constraint Registry

Every track file contains an "out of scope" list that is ~80–90% identical
across all tracks:

```text
Out of scope:
- session/cookie framework
- persistent flash storage
- validation framework
- UI kit
- Plane/canvas
- flow/chat/proactive agent DSL
- SSE/live updates
- full interactive_app
- generator
- production server layer
- new package
- runtime agent execution
- browser transport
- cluster routing
- AI provider integration
```

This is ~150 tokens, copied verbatim into every track.

### Solution: Named constraint sets in `constraints.md`

```markdown
# Constraint Sets

## :no_runtime
no runtime agent execution, no autonomous delegation, no workflow engine

## :no_web_transport  
no browser transport, no SSE/live updates, no route activation, no mount binding

## :no_new_package
no new package, no shared runtime object

## :no_cluster
no cluster routing, no cluster placement, no peer coordination

## :no_ai_provider
no AI provider integration, no LLM calls

## :poc_scope
= :no_runtime + :no_web_transport + :no_new_package + :no_cluster + :no_ai_provider
  + no session/cookie framework, no validation framework, no UI kit, no generator
```

Track files then say:

```markdown
## Scope

In scope: feedback/refusal boundary, query-string based feedback.
Forbid: :poc_scope
```

Instead of 15 lines, that is **2 lines**. The full list is in `constraints.md`
and read once, not repeated in every track.

**Saving:** ~130 tokens per track reference × 40 active tracks = 5,200 tokens
eliminated. Ongoing saving: ~130 tokens per new track created.

---

## Proposal 3: Line-Up Handoff Format

The compression experiment (`compression-experiment.md`) measured the current
handoff format:

| Case | Prose Tokens | Line-Up Tokens | Ratio |
|------|-------------|----------------|-------|
| Completed task handoff | 115 | 78 | 1.47× |
| Supervisor scope assignment | 80 | 72 | 1.11× |
| Multi-step track + gate | 110 | 82 | 1.34× |

Apply Line-Up to actual agent handoffs. The Compact Status Template already
in `tracks.md` is halfway there — it just needs to be made more compact.

### Proposed micro-format for agent handoff

```text
[Agent Application / Codex]
track: application-web-poc-feedback-track.md
status: landed
delta:
  + app.rb: query-string feedback, blank-title refusal
  + README: feedback params documented
verify: smoke(74/0) rubocop(0) diff-check(ok)
ready: [Agent Web] can render feedback; [Supervisor] can review boundary
block: none
```

vs current prose format (~200–300 tokens):

```text
[Agent Application / Codex]
Track: docs/dev/application-web-poc-feedback-track.md
Status: application slice landed.
Changed:
- Added app-local command feedback redirects in
  examples/application/interactive_operator/app.rb.
- POST /tasks/create now redirects with notice=task_created and task=<id>
  on success.
[... 10 more lines ...]
Verification:
- ruby examples/application/interactive_web_poc.rb passed.
- ruby examples/run.rb smoke passed with 74 examples, 0 failures.
[... 3 more lines ...]
Needs:
- [Agent Web / Codex] can render compact success/error feedback from
  QUERY_STRING under examples/application/interactive_operator/web/operator_board.rb.
```

**Savings:** ~200 tokens → ~60 tokens per handoff = **70% reduction per message**.
At 20 handoffs per development day: saves 2,800 tokens/day.

---

## Proposal 4: Parallel Task Windows

The current protocol is implicitly sequential even when tasks are independent:

```
Supervisor assigns Task 1 (App) → App reports → Supervisor assigns Task 2 (Web)
→ Web reports → Supervisor reviews both
```

The feedback track already defines Task 1 (Application) and Task 2 (Web)
as independent. But the protocol still runs them sequentially because the handoff
template implies "report to Supervisor, then Supervisor assigns next agent".

### Proposed: explicit parallel window notation

In the track file, mark tasks that can run simultaneously:

```markdown
## Task 1 [parallel:A]: Application Feedback Boundary
Owner: [Agent Application / Codex]

## Task 2 [parallel:A]: Web Feedback Surface
Owner: [Agent Web / Codex]

## Verification Gate [after:parallel:A]
Both tasks must pass before supervisor acceptance.
```

When Supervisor sends a track with `[parallel:A]` tasks, both agents start
simultaneously. Each appends their report. Supervisor reviews once both are done.

**Saving:** eliminates one full round-trip per parallel window.
One round-trip = one agent session read (14,000 tokens currently, 400 tokens
after Proposal 1) + one supervisor review pass.
Even after Proposal 1, eliminating a round-trip saves ~800–1,200 tokens and
reduces elapsed time.

---

## Proposal 5: Graduated Verification

Current: every track has a full Verification Gate section listing all
verification commands, even for docs-only changes.

The commands are repeated verbatim in the gate AND in the agent's handoff report.

### Proposed: three verification tiers

```markdown
## Verification Tier

docs-only:
  git diff --check

code-narrow:
  ruby <smoke example>
  bundle exec rspec <touched-package>/spec
  bundle exec rubocop <touched files>
  git diff --check

code-full:
  bundle exec rake spec
  bundle exec rake rubocop
  git diff --check
```

The agent reports only the tier and result:

```text
verify: docs-only(ok)
verify: code-narrow(smoke 74/0, rspec 12/0, rubocop 0 offenses, diff-check ok)
```

Not the full command strings — those are derivable from the tier definition.

**Saving:** ~80–120 tokens per track gate section + ~60–80 tokens per handoff
report = ~150–200 tokens per track pair. Minor but clean.

---

## Proposal 6: Track Retirement Protocol

Track files currently grow in-place. Historical handoff blocks from agents
who completed their work accumulate in the file, growing it by ~100–200 tokens
per completed task.

### Proposed retirement rule:

When a track is accepted:
1. Replace the track file with a single "retired" stub:

```markdown
# <Track Name>

Status: accepted on 2026-04-25.
Summary: <one line>.
History: tracks-history.md#<anchor>

[Full content moved to tracks-history.md]
```

2. Move full content to `tracks-history.md`.
3. Remove from `tracks.md` Active Handoffs table.

This caps each active track at its planning size (~60–150 lines) and prevents
accumulation.

---

## Implementation Order

These proposals are independent and can be applied in any order. Priority by
impact-to-effort ratio:

| Priority | Proposal | Effort | Token Saving (per day) |
|----------|----------|--------|----------------------|
| 1 | Split tracks.md | 30 min | ~68,000 |
| 2 | Line-Up handoff format | 15 min (update template) | ~2,800 |
| 3 | Shared constraint registry | 45 min | ~1,500 ongoing |
| 4 | Track retirement protocol | 20 min (write rule) | prevents future growth |
| 5 | Parallel task windows | 10 min (add notation) | ~800/window |
| 6 | Graduated verification | 20 min | ~150/track |

**Start with Proposal 1.** It is a single file split with no protocol changes.
Saves ~68,000 tokens/day immediately. Everything else is incremental improvement
on top.

---

## Immediate Next Steps

### Step 1: Create `tracks-active.md` (30 minutes)

Extract from current `tracks.md`:
- Active Handoffs table (rows 66–76)
- Compact Status Template (rows 1688–1701)
- Agent Drill-Down Protocol (rows 42–58)
- Current Cycle Summary: 3 lines synthesizing the Broad Cycle Snapshot

Leave the rest (Broad Cycle Snapshot + all Track Map sections) in `tracks.md`
renamed to `tracks-history.md`.

Update the opening line in `tracks.md` (now `tracks-active.md`) so agents
know to read it first.

### Step 2: Update Agent Protocol (15 minutes)

Add to `tracks-active.md`:

```markdown
## Handoff Format

Use the micro-format in all agent reports:

[Agent Role / Codex]
track: <path>
status: landed | blocked | needs-review
delta: <changed files, one line each>
verify: <tier>(result)
ready: <who can proceed>
block: <blocker or "none">
```

### Step 3: Create `constraints.md` (45 minutes)

Extract all repeated forbid/out-of-scope lists from existing tracks into
named sets. Update the 5–6 currently active tracks to reference named sets.

---

## What This Does Not Change

- The Handoff Doctrine vocabulary (subject, sender, recipient, evidence, etc.)
- The supervisor gate model (Supervisor still accepts/rejects everything)
- Package ownership rules
- The research → doctrine → code graduation sequence
- The evidence-first principle
- Track content or acceptance criteria

The optimization is **purely in information density and document structure**,
not in protocol semantics.

---

## Estimated Total Saving

Combining all proposals (after steady-state adoption):

```text
Proposal 1 (tracks split):        ~68,000 tokens/day
Proposal 2 (micro-format):        ~2,800 tokens/day
Proposal 3 (constraint registry): ~1,500 tokens/day
Proposals 4-6 (minor):            ~500 tokens/day

Total:                             ~73,000 tokens/day
```

For context: `tracks.md` at 14,000 tokens costs the same as ~14 full handoff
messages. After the split, the entry point costs 400 tokens — the same as one
compact handoff. Every agent session is 97% cheaper at the first read.

---

## Candidate Handoff

```text
[External Expert / Codex]
Track: Agent Cycle Optimization
Changed: docs/experts/agent-cycle-optimization.md
Accepted/Ready: ready for supervisor and user review
Verification: documentation-only
Needs: [Architect Supervisor / Codex] or user to decide:
  (a) proceed with Proposal 1 immediately (tracks split) — 30 min, high impact
  (b) adopt micro-format handoffs in the next active track — 15 min
  (c) full adoption of all proposals in one pass — 2 hours
  (d) review and refine before applying
Recommendation: start with (a) only. Split tracks.md today. Measure
whether agent sessions feel materially lighter. Adopt others incrementally.
Risks: renaming tracks.md breaks any agents that have "read tracks.md first"
in their instructions. Update those instructions in the same pass.
```
