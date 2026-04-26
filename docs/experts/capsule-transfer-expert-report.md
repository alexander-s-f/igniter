# Capsule Transfer — Expert Report

Date: 2026-04-26.
Perspective: expert in distributed agent systems and interactive platforms.
Subject: Capsule Transfer track — strategic analysis and forward direction.

---

## 1. Visionary Perspective

Capsule Transfer is not a deploy mechanism. It is **the first first-class vocabulary
for agent-supervised software delivery**.

Looking at the full chain — declaration → handoff manifest → bundle plan →
artifact verification → applied verification → receipt — what we see is
something fundamentally different from `git push` or `docker pull`. This is a
protocol with explicit **chain-of-custody**: each step produces evidence, each
piece of evidence becomes input for the next, and **no mutating step executes
without a preceding verification**.

In a world where AI agents coordinate the delivery and activation of software
across hosts, tenants, and cluster nodes, this protocol becomes a structural
load-bearing element. Not infrastructure. **A new primitive**.

The core visionary claim:

> Capsule Transfer is the foundation for an enterprise application supply chain
> under agent control. It is what `npm publish` + CI/CD could have become if
> it had been designed from day one as an auditable, refusal-first,
> agent-supervised process.

Comparison with existing mechanisms:

| Mechanism | Delivery unit | Audit | Explicit refusal | Activation separated |
|---|---|---|---|---|
| `gem install` | files | none | no | no |
| Docker | image | partial | no | no |
| CI/CD pipeline | artifact | log | no | no |
| **Capsule Transfer** | **capsule** | **receipt chain** | **yes** | **yes** |

The separation of "files moved" from "runtime activated" is not an
implementation detail. It is a **fundamental architectural boundary** — and that
boundary is where the system's strength lives.

---

## 2. Idea, Model, Amplification

### 2.1 The Idea

A capsule is a unit of portable application. Not a Docker image (missing host
semantics), not a gem (no business-logic declaration), not a zip archive (no
intent). A capsule is a **declared intent** plus a **verified payload** plus an
**activation protocol**.

The handoff manifest is the contract between source and destination. The transfer
receipt is the closing evidence document. The activation receipt is the future
second evidence document — it closes the activation lifecycle separately and
independently.

### 2.2 The Model

The full model can be expressed as three orthogonal layers:

```
Capsule Transfer Model
├── TRANSPORT LAYER
│   ├── Declaration      → what wants to move
│   ├── Inventory        → what actually exists
│   ├── Bundle           → what is packaged and verified
│   └── Apply            → what is applied at the destination
│
├── EVIDENCE LAYER
│   ├── Transfer Receipt   → "files moved" (closed)
│   ├── Commit Readiness   → "activation is possible" (descriptive only)
│   └── Activation Receipt → "runtime activated" (future)
│
└── REFUSAL LAYER
    ├── Dry-run gate     → every step runs as dry-run first
    ├── Manifest guard   → rejection on plan-vs-fact divergence
    └── Commit boundary  → only narrow application-owned operations
```

This is **not a pipeline** — it is a **contractual chain**. Each layer is
independent and can be halted or refused without invalidating earlier evidence.

### 2.3 Amplification

The amplification path is **agents as activation reviewers**.

Today: a human reads `commit_readiness`, a human decides whether to trigger
activation.

Tomorrow: an agent receives the transfer receipt, analyzes the activation
evidence, verifies the adapter, signs the decision, and only then does the
narrow application-owned operation execute. The agent here is not an executor —
it is an **auditor with decision authority**.

This opens the next level: **automated compliance gates** — where regulatory
requirements (SOC2, HIPAA) are expressed as activation predicates, and a capsule
physically cannot become active without passing through them.

---

## 3. Perspective Development

### 3.1 Where We Are

The track has covered substantial ground:

- ✅ Transfer chain: 14 steps, end-to-end verified
- ✅ Activation review chain: 7 steps, dry-run + commit-readiness
- ✅ Boundary review: only narrow application-owned boundary accepted
- 🔄 Active: Evidence and Receipt track (docs/design only)
- ⏸ Blocked: activation commit implementation

The current pause is intentional and correct. This is not stagnation. This is
discipline.

### 3.2 The Critical Fork

The most important design decision not yet made is **the shape of the activation
receipt**.

The transfer receipt exists and closes the transport layer. The activation
receipt will close the runtime layer. But between them sits the **evidence
packet**: the exact fields that must enter the future activation commit.

This evidence packet is the highest-stakes design decision in the track. If its
shape is weak — incomplete fields, no operation digest, no idempotency key —
Phase 3 will be brittle. If its shape is bloated, implementation becomes
unwieldy.

**Getting this right before moving forward is non-negotiable.**

### 3.3 Long-Term Trajectory

```
Phase 1: Stable transport chain (DONE)
Phase 2: Boundary review (DONE)
Phase 3: Narrow activation commit ← requires evidence/receipt shape first
Phase 4: Activation verification + receipt ← closes the activation lifecycle
Phase 5: Web/host mount activation ← separate lane, not application-owned
Phase 6: Enterprise orchestration ← the real prize
```

Phase 6 is where all of this is heading: CI/CD gates, compliance audit, internal
application marketplaces, agent-assisted migrations. It is the level at which
Capsule Transfer becomes a product-level feature rather than internal tooling.

### 3.4 Connection to the Agent Platform

In the context of Igniter as an interactive agent platform (the vision articulated
in expert-review.md), Capsule Transfer is the **infrastructural enabler** for:

- **Multi-tenant agent environments**: agent applications move between tenants
  with a full audit trail
- **Agent marketplace**: capsules are published, inspected, and transferred with
  explicit receipts — like an App Store, but for AI agents
- **Hot deployment without downtime**: transfer receipt → activation evidence →
  activation commit → activation receipt, all under the supervision of a live
  supervisor agent

---

## 4. Recommendations

### 4.1 Priority #1: Make the Evidence & Receipt Track Exhaustive

The current active track is docs/design only. That is correct. But the shape of
the evidence packet must be **exhaustive**, not minimal. Every field must have an
explicit justification:

- **operation_digest**: without it, any replay attack or race condition can apply
  a stale plan — this is not paranoia, it is correctness
- **idempotency_key**: a capsule may be applied twice under a network failure —
  without a key there is no safe retry
- **adapter_capability_map**: before commit, the adapter must declare what it
  supports — this prevents silent failures on hosts with restricted permissions
- **caller_metadata + receipt_sink**: who decided and where to send the result —
  essential for enterprise audit

Both agents (Application and Web) must produce complete shapes, not sketches.

### 4.2 Preserve the Hard Separation: Transfer Receipt ≠ Activation Receipt

This is an architectural principle, not an implementation detail. These two
events must remain independent evidence documents permanently — they have
different lifecycles, different consumers, and different audit requirements. Do
not yield to the temptation to merge them for simplicity.

### 4.3 Phase 6 Deserves Its Own Vision Document

Enterprise Orchestration (Phase 6) is currently described as seven bullet points
in a roadmap. That is not enough. This is the part that makes all the preceding
work economically justified. A dedicated document —
`docs/experts/capsule-enterprise-orchestration.md` or
`docs/dev/capsule-enterprise-vision.md` — is warranted, covering:

- concrete use cases (air-gapped delivery, compliance gates, marketplace)
- who the buyer of this feature is (DevOps lead, CTO, compliance officer)
- how the capsule receipt chain integrates with existing tooling (GitHub Actions,
  Kubernetes admission webhooks, OPA/Gatekeeper)

### 4.4 Activation Commit Must Be Agent-Readable

When Phase 3 opens, the activation commit must return data that an AI agent can
parse and act on — not only a human-readable description. A structured result:
`operation_id`, `committed?`, `skipped_operations`, `reason_map`.

This is the foundation for automated activation review agents in Phase 6.

### 4.5 Do Not Rush Phase 3

The current position — blocking implementation until evidence shapes are
finalized — is correct. Add one more acceptance criterion for Phase 3: at least
one real adapter (not a stub) must exist before implementation opens. Without a
real adapter, there is no way to validate the correctness of the evidence packet
shape.

---

## 5. Insights and Ideas

### 5.1 Capsule as a Trust Boundary

A capsule does not just move files — it moves **trust context**. The transfer
receipt is a signed assertion: "these files were verified before transfer." In a
distributed agent world, this means the agent on the receiving host can accept
the capsule without re-verifying its contents (trust the receipt), but must
independently verify its own environment's readiness (activation readiness).

This is isomorphic to JWT: the contents are signed, the recipient verifies the
signature rather than re-verifying the payload.

### 5.2 Receipt Chain as a Distributed Event Log

The receipt chain (transfer → activation) is effectively an **append-only
distributed event log** for the application lifecycle. This opens up:

- temporal queries: "what was the state of host-X at time T?"
- diff between two receipts: what changed between two activations of the same
  capsule
- agent subscriptions: an agent subscribes to receipt events and makes decisions
  on that stream

### 5.3 The "Activation Budget" Pattern

An idea worth considering for Phase 3: rather than enumerating allowed operations
explicitly, define an **activation budget** — a maximum number of filesystem
mutations, a maximum depth, a maximum file count. If the commit would exceed the
budget, automatic refusal without manual review. This is defence-in-depth layered
on top of explicit boundary review.

### 5.4 Capsule Composition as a Dependency Graph

A capsule may depend on another capsule (a base capsule). The transfer chain then
becomes a topologically sorted dependency graph. Igniter contracts are precisely
validated dependency graphs. Using the same compiler to validate capsule
dependencies is not just an appealing idea — it is a natural fit.

### 5.5 Evidence Accumulation vs. Evidence Snapshot

The current model is evidence snapshot: a set of fields that must be present at
commit time. The alternative is evidence accumulation: each step appends evidence
to a growing immutable object, and the commit is simply the final append.

The advantage: an auditor sees the full decision history, not just the terminal
state. This is especially valuable in regulated environments.

### 5.6 Capsule as the Agent Deployment Primitive

In the context of an interactive agent platform: when a user "installs" a new
assistant agent into their workspace, that is a capsule transfer. The manifest
describes the agent (capabilities, tools, LLM requirements), the transfer receipt
confirms installation, and the activation receipt confirms the agent is live. The
user sees "Install Agent" — but underneath is a fully verifiable supply chain.

This is what separates Igniter from yet another AI framework: **agents deployable
as first-class auditable artifacts**.

---

## 6. Conclusion

Capsule Transfer is strategically sound and well-disciplined work. The current
pause before activation commit is not slowness — it is maturity.

The one real risk is that the Evidence & Receipt track gets done "well enough"
rather than "correctly." The shape of the evidence packet is one of those
decisions that becomes expensive to redo once code is written on top of it.

**The primary recommendation**: invest whatever time is needed in the Evidence &
Receipt track. That document becomes the contract for all of Phase 3 through 6.
Once it is accepted, the roadmap ahead unfolds quickly and cleanly.

Capsule Transfer has the potential to become what Apple Notarization is for
macOS — a verifiable chain-of-custody for software delivery — but with agents as
**active participants** in the process rather than passive instruments of a CI
pipeline.
