# Research Horizon — Expert Analysis

Date: 2026-04-25.
Author: external expert review.
Source: complete reading of `docs/research-horizon/` (12 documents).
Companion: `docs/experts/`

---

## 1. What The Research Horizon Is Doing Right

Before critique, the strengths are exceptional and worth naming explicitly —
not as flattery, but because they are architecturally rare.

### 1.1 The Supervisor Gate Is Genuinely Unusual

Most software projects have no formal separation between "ideas" and
"implementation". Ideas become issues, issues become PRs, PRs become features,
features create technical debt. The Research Horizon / Architect Supervisor
gate is a disciplined two-stage pipeline:

```
Research Horizon → [Supervisor review] → Docs-only doctrine
→ [Supervisor review] → Read-only report
→ [Supervisor review] → Package-local facade
→ [Supervisor review] → Full implementation
```

Every step requires an explicit graduation decision. Ideas accumulate evidence
before they become code. This is the correct structure for a system that claims
to be "evidence-first."

The graduation sequence already executed in 2026-04-25:
- Agent Handoff Protocol → **Handoff Doctrine** (docs-only) ✓
- Interaction Kernel → **Interaction Doctrine** (docs-only) ✓
- Runtime Observatory Graph → **Observatory Doctrine** (docs-only) ✓

Three ideas went from proposal to doctrine in one research cycle. That's a
productive research operation.

### 1.2 The "Evidence-First" Philosophy Is Internally Consistent

Every research document refuses the same things: no execution, no routing, no
AI calls, no mutation, no hidden discovery. This isn't caution for its own sake
— it's a coherent architectural philosophy.

The philosophy can be stated as:

> **Observe before acting. Inspect before executing. Review before deploying.**
> Every artifact should be readable by a human or agent before it causes
> anything to happen.

This philosophy is the reason Igniter's capsule transfer chain has seventeen
review steps. It's not over-engineering — it's an "evidence chain" that makes
distributed trust computable.

I'll name this pattern **"Evidence-First Architecture"** and develop it
separately. It deserves to be a named doctrine, not just an implicit pattern.

### 1.3 The Multi-Agent System Already Exists In Docs

`docs/dev/tracks.md` defines a multi-agent protocol in Markdown:
- `[Architect Supervisor / Codex]` — gate keeper, accepts/rejects
- `[Agent Contracts / Codex]` — owns contracts package
- `[Agent Application / Codex]` — owns application package
- `[Research Horizon / Codex]` — long-range research

Each agent has a named role, a scope of ownership, a handoff protocol, and
a verification step. This is a **working multi-agent coordination system**,
implemented without AI and without code. The docs-agent handoff format is:

```text
[Agent X / Codex]
Track: <name>
Changed: <files>
Accepted/Ready: <yes/no>
Verification: <commands>
Needs: <next decision>
```

This format is machine-parseable RIGHT NOW. An LLM agent reading a track file
could pick up exactly where the previous agent left off. The research horizon
hasn't made this observation explicit, but it's one of the most valuable
insights in the repository: **Igniter is already designed as a multi-agent
system at the documentation layer.**

The transition from docs-agent to runtime-agent requires almost no new
concepts — just connecting the existing handoff vocabulary to a real
execution bus.

### 1.4 Grammar Compression Research Is Well-Grounded

The trilogy — `grammar-compressed-interaction.md` +
`grammar-compression-research-survey.md` + `line-up-approximation-method.md`
— is more theoretically rigorous than most engineering-team research:

- Information Bottleneck for relevance-preserving compression ✓
- Rate-Distortion theory for lossy semantic compression ✓
- MDL for grammar economic cost ✓
- Controlled Natural Languages for ambiguity control ✓
- LLMLingua as empirical anchor ✓
- Frame semantics for role preservation (Line-Up) ✓
- AMR as structural ancestor of Line-Up ✓

The economic framing is exactly right:

```text
grammar_cost + pack_cost + unpack_cost + repair_cost < repeated_context_cost
```

The critical missing piece: **no experiment has been run.** Three documents
elaborate the hypothesis; zero documents measure it. I'll design a concrete
experiment separately.

---

## 2. What The Research Horizon Is Missing

### 2.1 Plastic Runtime Cells (Proposal D) Has No Synthesis

The Horizon Proposals document lists six proposals. Five have synthesis
documents:
- Agent Handoff Protocol → `agent-handoff-protocol.md` ✓
- Interaction Kernel → `interaction-kernel-report.md` ✓
- Runtime Observatory Graph → `runtime-observatory-graph.md` ✓
- Grammar Compression → three docs ✓
- DSL REPL Authoring → `dsl-repl-authoring-research.md` ✓

**Proposal D (Plastic Runtime Cells) has no synthesis document.**

This is the most architecturally ambitious proposal — a cell as a portable,
self-describing runtime unit combining capsule + contracts + interfaces +
credential policy + surface + placement constraints. It's also the one that
maps most directly to the future "distributed agent deployment" problem.

The omission is probably intentional — it's more complex than the others and
the capsule/transfer work needs to stabilize first. But it deserves a synthesis.
I'll write it separately.

### 2.2 No Temporal / Replay Research

Igniter has temporal replay capabilities (the `temporal` extension, `as_of`
inputs with Proc defaults). The research horizon never connects this to the
agent research.

**The gap**: agents operating in long-running distributed systems need to be
able to answer "what was the state at time T?" This is not just debugging — it
is a fundamental capability for:
- Rewinding to a known-good state after an agent makes a bad decision
- Auditing why an agent acted a certain way
- Replaying a workflow with corrected inputs
- Detecting when state has drifted from expected trajectory

The existing temporal extension is the embryo of a **time-travel debugging**
capability for the distributed agent system. The research horizon hasn't
noticed this connection.

### 2.3 No Research On The "Live System" Problem

All research treats the system as a collection of discrete artifacts (reports,
manifests, receipts). None addresses the question: **what does the system look
like when it's running and changing 100 times per second?**

The Runtime Observatory proposes a read-only frame, but a frame is a snapshot.
A live system produces a stream of state transitions, not snapshots.

The missing research: **stream processing semantics for the Observatory**. How
do you maintain a useful observatory view when:
- Contracts are resolving and invalidating continuously
- Agents are changing state every few seconds
- Cluster peers are coming and going
- Sessions are opening and closing

This is the delta-stream problem, and it's related to the incremental dataflow
extension already in Igniter. The connection hasn't been made.

### 2.4 No Research On Cross-Agent Coordination Protocols

The research horizon studies handoff (one agent gives work to another) and
observation (watching the state). But it doesn't study:
- **Negotiation**: two agents need to reach agreement
- **Consensus**: a group of agents vote on a decision
- **Broadcast**: one agent notifies many others simultaneously
- **Rendezvous**: two agents wait for each other before proceeding

These are coordination patterns from distributed systems theory (CSP, actors,
π-calculus). Igniter's cluster consensus (Raft) handles one of these, but the
agent layer hasn't been connected to coordination theory.

### 2.5 No Measurement Of Current Doc-Agent System Performance

The doc-agent handoff protocol exists and works. But nobody has measured:
- How many tokens does a typical handoff consume?
- How often do agents need clarification (repair cost)?
- How much context do agents carry forward?
- What is the compression ratio if you apply Line-Up to existing handoffs?

This is the perfect first experiment — apply the grammar compression research
to the existing docs-agent protocol and measure the economics. It doesn't
require building anything new.

---

## 3. Pattern Analysis

### 3.1 The "Observation Chain" Pattern

Every major concept in the research horizon follows the same build-up pattern:

```
1. Identify repeated signal across packages
2. Name the cross-cutting concept
3. Write synthesis with tiny vocabulary
4. Graduate as docs-only doctrine
5. Identify pressure points that would justify code
6. Defer implementation until pressure is real
```

This pattern produces:
- Handoff Doctrine
- Interaction Doctrine
- Observatory Doctrine

I call this the **Observation Chain**: each new doctrine adds one layer of
conceptual structure above existing artifacts, without merging their ownership.

The pattern is excellent for a growing system where ownership needs to stay
clear. The risk is that the chain eventually needs to be implemented — at some
point, a docs-only doctrine becomes insufficient and real code must appear.
The research horizon correctly defers this, but the team should be prepared
for the "code moment" when it arrives.

### 3.2 The "Residue Preservation" Principle

The Line-Up document introduces "residue" — the semantic content that must NOT
be compressed away: names, numbers, negations, obligations, forbidden actions,
risk terms. This is a key insight that generalizes beyond grammar compression.

The **Residue Preservation Principle**:

> When compressing any representation, some content is critical residue that
> must survive the compression. Residue is context-dependent: what counts as
> residue depends on the task.

This principle applies everywhere:
- When compressing handoff manifests → obligations are residue
- When compressing capsule reports → blockers are residue
- When compressing cluster plans → trust decisions are residue
- When compressing agent context → constraints are residue

The research horizon has discovered a general principle through one specific
case (grammar compression) without generalizing it.

### 3.3 The "Graduated Trust" Problem

The supervisor-review.md shows a binary acceptance/rejection model: proposals
are either accepted or rejected at each stage. But in practice, trust is
graduated:
- An idea might be "trusted for docs but not for code"
- A package might be "trusted for local use but not cluster deployment"
- An agent might be "trusted with read access but not write"

The current research horizon doesn't have vocabulary for this. Everything is
either "accepted" or "rejected/deferred." A more nuanced model would be:

```
trust_level:
  - research        → safe in horizon docs only
  - doctrine        → safe as vocabulary, no code
  - report          → safe as read-only artifact
  - local_package   → safe as package-local code
  - cross_package   → safe to share across packages
  - cluster_safe    → safe to run on distributed nodes
  - production_safe → verified under load
```

This maps directly to Igniter's capability system and could become a formal
part of the graduation protocol.

### 3.4 The "Inside-Out" Design Direction

Every Igniter design decision starts from the inside and grows outward:

- contracts before application
- application before cluster
- cluster before AI agents
- observation before action
- docs before code
- local before distributed

This is the opposite of most systems, which start with the user-visible surface
and bolt on the infrastructure. Igniter starts with the computation graph and
builds up to the UI.

The research horizon respects this but doesn't name it. I'll call it the
**Inside-Out Design Principle**: each layer is designed to be complete and
useful without the layer above it. Contracts work without application. Application
works without cluster. Cluster works without AI agents.

This makes the system testable and portable at every layer — which is exactly
what the capsule transfer model proves.

---

## 4. Tensions And Risks

### 4.1 Vocabulary Sprawl

The current-state-report.md identifies "vocabulary sprawl" as the highest-risk
area. I agree. Current named concepts:

```
Contracts layer:  input, compute, output, effect, branch, collection,
                  compose, scope, namespace, await, guard, expose, export,
                  const, lookup, map, project, aggregate, on_success
Extensions:       dataflow, incremental, saga, execution_report,
                  differential, provenance, invariants, capabilities,
                  content_addressing, temporal
Application:      capsule, manifest, layout, profile, environment,
                  mount, flow, session, operator, orchestration,
                  handoff_manifest, transfer_receipt, activation_plan
Web:              screen, zone, ask, action, stream, chat, compare,
                  subject, actor, need, show, composition_preset
Cluster:          peer, capability_query, placement_decision,
                  mesh_trace, governance_checkpoint, ownership_plan
Research:         handoff_doctrine, interaction_doctrine,
                  observatory_doctrine, line_up, grammar_compressed,
                  observation_frame, observation_node, observation_edge,
                  plastic_cell, capability_market
```

This is a long list. The risk is that new developers (or agents) need to learn
too many concepts before being productive. The research horizon should explicitly
scope which concepts are "core vocabulary" (universally needed) vs "advanced
vocabulary" (needed only in specific contexts).

Proposed core vocabulary (≤20 concepts that explain everything else):

```
contract, agent, session, surface, capsule,
handoff, observation, capability, trust, evidence,
plan, execute, review, approve, delegate,
stream, compose, observe, coordinate, deploy
```

### 4.2 The "Docs-Only Doctrine Can't Last" Risk

Docs-only doctrines are valuable interim steps, but they can't be the final
state. Eventually code must implement what docs describe, or the docs become
aspirational fiction.

The current doctrines (Handoff, Interaction, Observatory) are 1-2 weeks old.
They're appropriately docs-only. But the research horizon needs a **doctrine
age policy**: after N months of docs-only status without implementation, either
a research track starts or the doctrine is archived.

Without this policy, the research horizon risks accumulating beautiful docs
that nobody implements.

### 4.3 Grammar Compression Has No Deployment Path

The grammar compression trilogy is theoretically sophisticated. But it has no
clear path to deployment:
- Who builds the grammar? Humans? Agents? Both?
- Where does the grammar live? Docs? A DSL file? A shared registry?
- How do agents acquire the grammar? By reading docs? By training? By context?
- How is grammar drift handled when protocols evolve?

These are hard problems. The research horizon should acknowledge them rather
than leaving them as implicit future work.

### 4.4 The Agent Rebuild Risk

The current-state-report.md notes that `igniter-agents` and `igniter-ai` need
to be rebuilt. The research horizon has done excellent conceptual work on
handoff, interaction, and observation — but all of it assumes runtime agents
exist. If the agent rebuild is delayed, the doctrines age without validation.

The risk: research outpaces implementation, doctrines accumulate, and when
agents finally appear, the doctrines don't match reality.

Mitigation: treat the doc-agent handoff protocol (which already works) as a
"reference implementation" of the Handoff Doctrine. Validate doctrine against
the thing that already exists before it's validated against the thing that
doesn't yet exist.

---

## 5. New Insights From External Perspective

### 5.1 The Doc-Agent Protocol Is A Runtime Protocol In Disguise

The most important unrecognized insight in the research horizon: the
docs-agent handoff format in `docs/dev/tracks.md` is already a working
**multi-agent runtime protocol**, implemented in Markdown.

Every element of a runtime agent coordination system is present:
- Named roles with explicit capabilities (`[Architect Supervisor]`)
- Owned scope boundaries (each agent owns one package/directory)
- Structured message format (track, changed, accepted, verification, needs)
- Async operation (agents work independently, hand off when done)
- Supervisor gate (approval required before state transition)
- Audit trail (git commits with labeled messages)

To transition from docs-agent to runtime-agent requires:
1. Parse the existing track format into structured data
2. Subscribe agents to tracks they own
3. Let agents produce commits with the handoff format automatically
4. Let the supervisor agent parse and respond to handoff requests

The grammar-compressed-interaction research provides the compact representation
for step 1. The runtime agent rebuild provides the execution layer for steps
2-4. These two research streams should be explicitly connected.

### 5.2 "Dead Reckoning" For Agent State Continuity

In navigation, dead reckoning means estimating current position based on last
known position + velocity + elapsed time. For agent systems:

**Agent dead reckoning**: an agent can estimate its current world-state based
on the last known state (Observatory frame) + known state transitions (event
stream) + elapsed time, even without a fresh full-system snapshot.

This matters for distributed systems where:
- Getting a fresh Observatory frame is expensive (many artifacts to query)
- The agent needs to act quickly with slightly stale information
- The agent should flag when its estimate is too uncertain

Line-Up approximations could serve as "compressed state estimates" — lower
fidelity than a full frame, but cheap to compute and transmit. An agent
receiving a Line-Up state estimate knows: "this is approximate, these fields
are reliable, these may have drifted."

The research horizon has all the pieces (Line-Up + Observatory) but hasn't
connected them to this navigation metaphor.

### 5.3 "Semantic Versioning" For Agent Protocols

When a handoff format, interaction vocabulary, or grammar changes, existing
agents may fail to parse it. Software packages use semantic versioning (MAJOR.
MINOR.PATCH) for API compatibility. Agent protocols need a similar system.

**Protocol semantic versioning**:
- MAJOR: breaking change to handoff format (all agents must update)
- MINOR: new optional field added (backward compatible)
- PATCH: clarification of an existing field (no behavior change)

Igniter's content-addressing extension provides hash-based fingerprinting.
Applying this to protocol definitions would give:
```
handoff_protocol_v1 = sha256(protocol_definition_text)
```

Agents can declare which protocol version they speak. The supervisor can
gate graduation based on protocol version compatibility.

### 5.4 "Capability Budget" For Agent Planning

The Capability Market proposal (Proposal C) describes bidding on capabilities.
The Constraint-Aware Planner (Proposal F) describes planning under constraints.
Connecting these: **capability budget**.

An agent can declare: "I have budget to use: 1 LLM call, 3 tool invocations,
max 30 seconds." The planner selects a contract graph execution that fits
within this budget while satisfying the goal.

This is constraint satisfaction over capability costs, not just over data
dependencies. Contracts already declare dependencies; they could also declare
capability costs (LLM tokens, tool calls, external API calls). The planner
then finds the cheapest satisfying execution.

### 5.5 "Trust Gradient" For Evidence Quality

Currently, evidence is treated as binary: present or absent. But evidence has
quality gradations:

- Direct observation (I measured it myself): high trust
- Signed report from a trusted peer: medium-high trust
- Unsigned report from an untrusted peer: low trust
- Inference from related evidence: context-dependent trust
- Hearsay (agent B says agent A said): lowest trust

A **trust gradient** on evidence nodes in the Observatory would make the
difference between "I know this" and "I think this" visible in the graph. The
Plane visualization could color-code evidence by trust level.

This connects the Observatory research to the Capability Market (trust posture
already exists in PeerProfile) and to future AI agent decision-making.

### 5.6 "Temporal Replay As Agent Context Injection"

Igniter already has temporal replay (rerunning a contract with historical
`as_of` inputs). This capability should be exposed to agents as a context
injection primitive:

```ruby
agent_session.inject_context(:historical_state, at: 3.hours.ago)
```

An agent planning to fix a bug could say: "show me the system state right
before the failure happened." The temporal extension replays the contract graph
at that timestamp. The Observatory frame at that time is injected into the
agent's context.

This turns temporal replay from a debugging tool into a **first-class agent
capability** — the ability to understand the system's past in order to plan
its future.

---

## 6. Strategic Assessment

### 6.1 Where Igniter Is In Its Arc

Based on the research horizon, the system is approximately here:

```
Foundation (contracts/compiler/runtime)     ████████████████████  COMPLETE
Extensions (packs/dataflow/temporal/etc)    ████████████████░░░░  85%
Application (capsule/session/flow)          ████████████░░░░░░░░  60%
Web surfaces (screen/zone/component)        ██████████░░░░░░░░░░  50%
Cluster (mesh/routing/placement)            ████████░░░░░░░░░░░░  40%
Agent runtime (actors/tools/LLM)            ████░░░░░░░░░░░░░░░░  20%
Agent protocol (handoff/interaction/obs)    ████░░░░░░░░░░░░░░░░  20%
UI Kit (components/surfaces)               ░░░░░░░░░░░░░░░░░░░░   0%
Live Graph Canvas (Plane)                  ░░░░░░░░░░░░░░░░░░░░   0%
Grammar compression (experiments)          ░░░░░░░░░░░░░░░░░░░░   0%
```

The foundation is solid. The upper layers are research-ready but
implementation-incomplete. The most critical gap is the agent runtime rebuild,
because everything above it (protocol, UI Kit, Plane) depends on it.

### 6.2 The Right Next Moves

Based on full analysis, the highest-value next research moves (not
implementation — research is what the horizon does):

**Immediate (before any agent runtime code):**
1. Write the **Plastic Runtime Cells synthesis** (the missing Proposal D document)
2. Run the **grammar compression experiment** on existing handoff docs (measure it)
3. Write the **Evidence-First Architecture doctrine** (make the philosophy explicit)
4. Connect the **temporal replay** capability to the agent context research

**Before agent rebuild ships:**
1. Synthesize the **doc-agent protocol → runtime protocol** transition plan
2. Define the **capability budget** model for planning
3. Sketch the **trust gradient** vocabulary for Observatory evidence nodes

**After agent rebuild:**
1. Validate all three doctrines (Handoff, Interaction, Observatory) against live agents
2. First grammar compression deployment in the handoff protocol itself
3. First Plane rendering of a live agent session

### 6.3 The One Risk That Matters Most

Of all the risks identified, one matters most: **the agent rebuild is the
critical path for everything else.**

Doctrines, grammar compression, Plane visualization, UI Kit agent components —
all of these are research artifacts that need live agents to validate. Without
live agents, the research horizon will continue to produce excellent docs that
accumulate rather than inform.

The research horizon can't fix this — it's an implementation decision. But it
should explicitly flag it.

Recommendation: the Research Horizon should request from Architect Supervisor
a **milestone** for the agent rebuild — not a timeline, but a capability
threshold: "when `igniter-agents` can receive a handoff in the existing format
and act on it, graduate X, Y, Z doctrines to implementation tracks."

---

## 7. Summary: The Research Horizon's Position

The research horizon is doing sophisticated, disciplined work. It has:

1. Built a graduated graduation pipeline (research → doctrine → report → code)
2. Identified three major cross-cutting concepts (Handoff, Interaction, Observatory)
3. Grounded grammar compression in solid information theory
4. Proposed six coherent long-range concepts (with varying maturity)
5. Implicitly demonstrated a working multi-agent coordination system

What it needs:
1. One missing synthesis (Plastic Cells)
2. One concrete experiment (grammar compression)
3. One explicit philosophy statement (Evidence-First)
4. One critical-path flag (agent rebuild)
5. A doctrine age policy (so docs don't accumulate without implementation)

The research horizon is not a luxury — it's essential infrastructure for a
system that aspires to be an intelligent agent platform. Without disciplined
research, "AI features" become ad-hoc chat wrappers. With it, they become
principled participants in a designed protocol.

The current research output earns this:

> **Igniter's research horizon is the most architecturally coherent AI agent
> research operation I have seen in a Ruby-adjacent project.**

The next challenge is making that research operational.
