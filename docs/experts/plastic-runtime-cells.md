# Plastic Runtime Cells — Research Synthesis

Date: 2026-04-25.
Author: external expert review.
Source: `docs/research-horizon/horizon-proposals.md` (Proposal D), full
reading of application capsule, cluster, and transfer research.
Status: research synthesis (not yet submitted for supervisor review).

---

## Why This Document Exists

Horizon Proposals lists six long-range proposals. Five have dedicated synthesis
documents. **Proposal D (Plastic Runtime Cells) has no synthesis.** This is the
most architecturally ambitious of the six — a cell as a portable, self-
describing, deployable runtime unit. Given that all surrounding proposals have
now been synthesized, the gap is significant.

This document synthesizes the Plastic Runtime Cells concept using the same
method as `agent-handoff-protocol.md`, `interaction-kernel-report.md`, and
`runtime-observatory-graph.md`: map existing artifacts, propose tiny vocabulary,
state what research allows, and what implementation must wait for.

---

## 1. Thesis

> A Runtime Cell is the smallest portable unit of agency in a distributed
> Igniter system: a capsule plus its contracts, declared interfaces, credential
> policy, operator surface, and optional placement constraints — packaged as a
> self-describing, movable, inspectable unit of work.

"Plastic" means **malleable but bounded**: a cell can be created, moved,
replicated, split, merged, retired, or handed to an agent — but only through
explicit declared mutations, each of which leaves an evidence trail.

A cell is not a container (Docker/Kubernetes). A cell is not a microservice.
A cell is not a capsule (a capsule is one layer of a cell's portability
envelope). A cell is the **minimal unit of distributed Igniter agency** —
the thing an agent can own, move, inspect, and hand off.

---

## 2. Existing Building Blocks

Everything needed to define a cell already exists across packages. The
synthesis is the missing piece.

### 2.1 Application Capsule

From `igniter-application`, already implemented:

- `ApplicationCapsule` — the capsule inspection report
- `ApplicationHandoffManifest` — what moves with the capsule
- `ApplicationTransferReceipt` — audit of what was transferred
- `ApplicationTransferBundle` — the packaged transfer artifact
- `ApplicationCapsuleComposition` — how capsules compose

**What a capsule contributes to a cell**: the portability envelope —
imports, exports, declared dependencies, and the review chain before anything
moves.

### 2.2 Host Activation Review

From the capsule transfer chain:

- Host activation readiness (can this host accept this capsule?)
- Host activation plan (what operations would activation involve?)
- Host activation verification (did the operations succeed?)
- Mount intents (which surfaces will be activated?)

**What activation contributes to a cell**: the deployment interface — the
contract between a cell and the host that receives it.

### 2.3 Contract Profiles

From `igniter-contracts`:

- `CompiledGraph` — the frozen validated execution graph
- Executor registries — what callable objects the graph uses
- Pack/profile system — which capabilities are enabled
- Content-addressing fingerprints — stable identity for a graph

**What contracts contribute to a cell**: the computation truth — what the
cell can compute, validated before deployment.

### 2.4 Cluster Placement

From `igniter-cluster`, already designed:

- `CapabilityQuery` — what does the cell need from a host?
- `PlacementDecision` — where should the cell run?
- `PeerTopology` — what placement options exist?
- Credential locality policy — which secrets stay on which node?
- Ownership plans — who is responsible for this workload?

**What cluster contributes to a cell**: the placement and routing layer —
where the cell runs, why, and who decided.

### 2.5 Operator Surfaces

From `igniter-web` and `igniter-application`:

- `SurfaceManifest` — what interactions does this cell offer?
- Flow sessions — what user workflows are in progress?
- Operator queries — what is pending for human review?

**What surfaces contribute to a cell**: the human interface — how an operator
or agent interacts with the cell's work.

### 2.6 Credential And Capability Policy

From cluster credential locality work:

- Secrets should not leave their host node
- Capabilities are declared, not discovered
- Trust is explicit and per-peer

**What credential policy contributes to a cell**: the security boundary —
what the cell can access and what stays behind when it moves.

---

## 3. The Cell Model

A Runtime Cell is the composition of these existing artifacts into one
named, movable, inspectable unit:

```
RuntimeCell {
  identity:     CellIdentity
  contracts:    [CompiledGraph]        # what it computes
  interfaces:   CellInterface          # declared inputs/outputs
  capsule:      ApplicationCapsule     # portability envelope
  surface:      SurfaceManifest        # human interaction layer
  policy:       CellPolicy             # credentials + capabilities
  placement:    PlacementDecision?     # where it runs (optional)
  health:       CellHealth             # current vitality
  mutations:    [CellMutation]         # history of structural changes
  observation:  ObservationFrame?      # current observatory view
}
```

This is an inspection shape, not a runtime object. The cell is what you
inspect before deciding to move, replicate, hand off, or retire it.

### 3.1 Cell Identity

```
CellIdentity {
  id:           stable UUID or content-addressed fingerprint
  name:         human-readable name
  version:      semantic version (see note on protocol versioning)
  kind:         :compute | :serve | :coordinate | :observe
  created_at:   timestamp
  owner:        HandoffParty (agent, human, system)
  fingerprint:  content-addressed hash of contracts + interfaces
}
```

The fingerprint allows two instances of the "same" cell to be compared.
If the fingerprint matches, the cells are semantically identical (same
contracts, same interfaces). If it differs, something changed.

### 3.2 Cell Interface

The declared boundary — what the cell accepts and produces:

```
CellInterface {
  inputs:       [declared input name + type]
  outputs:      [declared output name + type]
  capabilities: [capability name]           # what it needs to run
  credentials:  [credential name]           # what secrets it uses
  surfaces:     [surface manifest ref]      # what interactions it offers
  events:       [emitted event names]       # what it broadcasts
  subscriptions: [subscribed event names]  # what it listens to
}
```

The interface is the **cell's contract with the world**. It must be
satisfied before a cell can run, and it must be preserved when a cell moves.

### 3.3 Cell Policy

The security and capability constraints:

```
CellPolicy {
  credential_locality:  :local | :inherited | :none
  allowed_hosts:        [peer selector]
  forbidden_hosts:      [peer selector]
  trust_minimum:        trust_level
  max_replication:      Integer?
  migration_allowed:    Boolean
  data_residency:       [region selector]?
}
```

Policy is the answer to "where can this cell go, and what can it do when
it gets there?"

### 3.4 Cell Health

The current vitality — not a monitoring dashboard, but a structured
summary of viability:

```
CellHealth {
  status:         :healthy | :degraded | :blocked | :failed | :unknown
  blocking_on:    [BlockerRef]          # from Observatory
  pending_inputs: [PendingInput]        # from Interaction Doctrine
  last_heartbeat: timestamp?
  error_summary:  String?
  evidence:       [ObservationEvidence] # from Observatory
}
```

Health is read-only. Changing it requires a cell mutation.

### 3.5 Cell Mutation

Every structural change to a cell is an explicit mutation with an evidence
trail:

```
CellMutation {
  kind:       :create | :move | :replicate | :split | :merge |
              :update_policy | :retire | :hand_off
  actor:      HandoffParty          # from Handoff Doctrine
  from_host:  PeerRef?
  to_host:    PeerRef?
  reason:     String
  evidence:   [evidence ref]
  receipt:    HandoffReceipt?       # from Handoff Doctrine
  timestamp:  timestamp
}
```

A mutation log is the cell's lifecycle history. An auditor can read it and
understand exactly how the cell arrived at its current state.

---

## 4. Plasticity Operations

"Plastic" means the cell can be shaped. Six fundamental mutations:

### 4.1 Move

The cell's primary workload is transferred from one host to another.

Preconditions:
- Origin host initiates a capsule transfer
- Destination host passes activation readiness check
- Policy allows migration
- All required capabilities exist on destination
- Credentials are re-provisioned on destination

Produces:
- `ApplicationHandoffManifest`
- `ApplicationTransferReceipt`
- `CellMutation(kind: :move)`

This is the existing capsule transfer chain, named and scoped as a cell
operation.

### 4.2 Replicate

A second instance of the cell is created on a different host while the
original continues running.

Use cases:
- High availability (if one instance fails, the other continues)
- Geographic distribution (reduce latency for distributed users)
- Shadow mode (run old and new version in parallel)

Preconditions:
- Policy allows replication (max_replication check)
- All capabilities and credentials can be re-provisioned
- Destination host passes activation readiness

Produces:
- `CellMutation(kind: :replicate)`
- New cell with new identity but same fingerprint as source

### 4.3 Split

A cell's responsibilities are divided into two cells. One cell handles
a subset of the original's contracts; the other handles the remainder.

Use cases:
- Cell has grown too large and needs to be decomposed
- Some contracts need stricter credential locality
- Performance isolation between workloads

Preconditions:
- The contract graph is composable into two independent subgraphs
- Both subgraphs have valid interfaces
- Human or planner reviews the split proposal before execution

Produces:
- Two cells with new identities
- `CellMutation(kind: :split)` on the original (now retired)
- A split plan with evidence and rationale

### 4.4 Merge

Two cells' responsibilities are combined into one. The inverse of split.

Use cases:
- Two cells are always deployed together (eliminate coordination overhead)
- Security requires tighter credential co-location
- Simplification after experimentation

Preconditions:
- The combined graph is valid
- The combined interface is declared
- Policy is compatible

Produces:
- One cell with a new identity
- `CellMutation(kind: :merge)` on both originals (now retired)

### 4.5 Hand Off

The cell's ownership is transferred from one agent/human to another. The
cell itself doesn't move — its accountability changes.

Uses the Handoff Doctrine vocabulary directly:
- Subject: the cell
- Sender: current owner
- Recipient: new owner
- Context: cell state + health
- Evidence: mutation history + current observation frame
- Obligations: what the new owner must do
- Receipt: new owner's acknowledgment

Produces:
- `CellMutation(kind: :hand_off)`
- `HandoffReceipt` (from Handoff Doctrine)
- Updated `CellIdentity.owner`

### 4.6 Retire

The cell's work is complete. All resources are released, all sessions are
closed, all outputs are archived.

Produces:
- `CellMutation(kind: :retire)`
- Final health snapshot
- Archive of all produced artifacts

Retirement is never automatic. It requires an explicit actor (human or agent)
and evidence that the cell's work is genuinely complete.

---

## 5. The "Plasticity" Claim

Why "plastic" rather than "portable" (which capsule already covers)?

Portability means: the cell can be moved while preserving its identity.

Plasticity means: the cell can be **structurally changed** while preserving
its accountability trace.

Portability is a property of the capsule. Plasticity is a property of the
cell that includes the capsule.

A capsule transfer preserves the capsule. A cell split creates two new cells
from one, which is not portable transfer — it's structural change. A cell merge
creates one from two. A cell replication runs the same capsule on multiple
hosts simultaneously.

These structural changes require a higher-level concept than capsule.

The cell is the answer.

---

## 6. What This Enables For Agents

Agents need a named unit of work they can own, inspect, move, and hand off.
Today, they have:
- Contracts (computation units, not ownership units)
- Sessions (interaction units, not deployment units)
- Capsules (transfer units, not ownership units)

The cell provides the missing ownership unit. An agent can say:

```
"I own cell:auth-workflow on host:node-4. It is healthy. I will replicate
it to host:node-7 before upgrading the underlying contract graph."
```

Without cells, this statement has no formal structure. The agent is making
claims about multiple separate artifacts (capsule, contract, host) without
a unified identity.

With cells, the statement maps to:
- `cell = CellIdentity(id: "auth-workflow", owner: agent_ref)`
- `observation = ObservationFrame(cell)` → health: healthy, host: node-4
- `mutation = CellMutation(kind: :replicate, to_host: "node-7")`
- After: two cells, same fingerprint, different hosts

The cell vocabulary makes distributed agent ownership legible.

---

## 7. Relationship To Other Research Horizon Concepts

| Concept | Relationship to Cell |
|---------|---------------------|
| Handoff Doctrine | Cell hand_off mutation uses HandoffParty + HandoffReceipt |
| Interaction Doctrine | CellHealth includes PendingInput from Interaction |
| Observatory Doctrine | Cells are ObservationNodes in an Observatory Frame |
| Grammar Compression | Cell operations can be Line-Up compressed for agent context |
| Capability Market | Placement decisions use CapabilityQuery over cell needs |
| Constraint-Aware Planner | Planner selects split/replicate/move mutations to meet goal |

The cell is the "thing" that all other concepts act on. It's the noun that
the verbs (handoff, observe, plan, compress) take as their object.

---

## 8. What Must Not Be Built Yet

Following the supervisor graduation discipline:

**Not acceptable as implementation until capsule transfer and host
activation are stable:**

- Cell runtime manager (a process that manages cell lifecycle)
- Automatic replication based on load
- Automatic split based on graph analysis
- Cell-aware load balancer
- Cell mutation transactions (coordinated cross-host atomicity)
- Cell gossip protocol (advertising cell presence)
- Cell marketplace (cells bidding on hosts)

**Acceptable as first research move:**
- This synthesis document
- A tiny docs-only Cell vocabulary aligned with capsule/cluster docs
- A research sketch mapping existing capsule reports to `CellInspectionReport`

**Acceptable as first code if pressure appears:**
- `Igniter::Application.cell_inspection_report(capsule)` — read-only
  adapter that wraps existing capsule reports in cell vocabulary
- Strictly read-only, no mutation, no activation, no routing

---

## 9. Candidate Research Questions

For the supervisor to evaluate graduation:

1. Can the existing capsule transfer chain be described completely as a
   cell move mutation + evidence trail?

2. Is the cell split/merge operation needed before any single application
   demonstrates it?

3. Which current application workloads would benefit from replication?

4. What would an agent need to declare to "own" a cell?

5. How does cell identity relate to content-addressed contract fingerprinting?
   Can the cell fingerprint be derived from the contract fingerprints it
   contains?

---

## 10. Recommended Graduation

Following the established pattern:

**Step 1** — Docs-only doctrine: `docs/dev/cell-doctrine.md`
- Define CellIdentity, CellInterface, CellPolicy, CellMutation vocabulary
- Map to existing capsule, cluster, and handoff artifacts
- Explicitly forbid runtime cell management, automatic replication, and
  cross-host coordination

**Step 2** — If pressure appears: read-only `CellInspectionReport`
- Wraps existing capsule inspection + health + mutation log
- Consumes explicit existing artifacts only
- Lives in `igniter-application` (where capsules already live)

**Step 3** — Much later: cell mutation planning
- A planner can propose a `CellMutationPlan` (move/replicate/split)
- Human or agent approves before any mutation executes
- The plan is a proposal, not an automatic action

---

## Candidate Handoff

```text
[External Expert / Codex]
Track: Plastic Runtime Cells synthesis
Changed: docs/experts/plastic-runtime-cells.md
Accepted/Ready: ready for supervisor review as research synthesis
Verification: documentation-only; no tests run
Needs: [Architect Supervisor / Codex] decide whether to accept as
research, graduate to docs-only doctrine, or defer until capsule
transfer and host activation are stable.
Recommendation: accept as research. Graduate to docs-only doctrine
(cell-doctrine.md) only after capsule host activation track completes.
Risks: Proposal D is the most ambitious horizon concept; premature
implementation would conflict with capsule, cluster, and agent work
currently in flight.
```
