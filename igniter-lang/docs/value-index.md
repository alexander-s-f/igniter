# Igniter-Lang Value Index

Status: active hoisted-memory index
Owner: `[Architect Supervisor / Codex]` + `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-09

---

## Purpose

This file is the hoisted value layer for Igniter-Lang documentation.

Tracks, discussions, proposals, and archives preserve detail. This index keeps
the durable ideas visible so they do not get lost when the documentation grows.
Use it as a map, not as a replacement for the source documents.

Metaphor: valuable ideas should "hoist" out of deep documents the way `var`
hoists in JavaScript. The source remains where it was born; the compact signal
is lifted here with a link back to archaeology.

---

## Hoisting Rule

After a round, hoist only ideas that are likely to remain useful across future
rounds.

Hoist when an item is one of:

- a durable design decision;
- a repeated pressure signal from more than one agent/review;
- a boundary rule that prevents future bugs;
- a concept that changes how agents should read or build the system;
- a deferred idea with high future option value.

Do not hoist:

- routine PASS/FAIL evidence already visible in `current-status.md`;
- implementation details that only matter to one closed track;
- stale intermediate wording superseded by spec or current status;
- broad history with no current decision pressure.

Each hoisted item should have:

```text
Signal: one compact sentence
Status: current | pressure | deferred | archived
Category: one of the sections below
Source: one or more links
```

---

## Categories

```text
Current Canon          Accepted language/runtime shape or active gate rule
Runtime Boundary       RuntimeMachine, cache, executor, TBackend, CompatibilityReport
Compiler Boundary      Parser/classifier/typechecker/SemanticIR/assembler/package path
Temporal Model         Time, History/BiHistory, lifecycle, retention, projection
Agentic System         Human-agent workflow, roles, discussions, symbiosis
Syntax Pressure        Useful future syntax not yet canon
Applied Pressure       Spark CRM, OSINT, home-lab, business/domain pressure
Ledger Bridge          igniter-ledger / descriptor / backend capability bridge
Archaeology Pointer    Deep archive worth preserving for later excavation
```

---

## Current Canon

### Production Compiler Path

Signal: The production compiler path is now
`Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed -> Assembler`.

Status: current

Source:
- [current-status.md](current-status.md)
- [tracks/orchestrator-emit-typed-switch-v0.md](tracks/orchestrator-emit-typed-switch-v0.md)
- [spec/ch5-compiler-pipeline.md](spec/ch5-compiler-pipeline.md)

### TEMPORAL Load / Evaluate Split

Signal: TEMPORAL `.igapp` artifacts may load for inspection, but evaluation is
blocked until an approved executor and live TBackend binding exist.

Status: current

Source:
- [tracks/runtime-compatibility-report-temporal-load-check-v0.md](tracks/runtime-compatibility-report-temporal-load-check-v0.md)
- [tracks/runtime-smoke-temporal-post-switch-v0.md](tracks/runtime-smoke-temporal-post-switch-v0.md)
- [spec/ch7-runtime.md](spec/ch7-runtime.md)

### Entrypoint / Section Disposition

Signal: `entrypoint` and `section` remain proposal-only; PROP-029 proposes
`entrypoint` as a named evaluation/run profile over an existing contract and
`section` as grouping-only organization.

Status: current

Source:
- [tracks/prop-029-entrypoint-section-surface-v0.md](tracks/prop-029-entrypoint-section-surface-v0.md)
- [proposals/PROP-029-entrypoint-section-surface-v0.md](proposals/PROP-029-entrypoint-section-surface-v0.md)
- [tracks/spec-entrypoint-sync-v0.md](tracks/spec-entrypoint-sync-v0.md)
- [spec/ch2-source-surface.md](spec/ch2-source-surface.md)

---

## Runtime Boundary

### CompatibilityReport Is Report-Only Before Gate 3

Signal: CompatibilityReport can reason about readiness, but neither capability
metadata, ratified package descriptor metadata, approval tokens, nor positive
executor/live-binding flags authorize live temporal reads, replay, cache, or
Ledger binding.

Status: current

Source:
- [tracks/runtime-compatibility-report-temporal-load-check-v0.md](tracks/runtime-compatibility-report-temporal-load-check-v0.md)
- [tracks/runtime-compatibility-report-executor-boundary-v0.md](tracks/runtime-compatibility-report-executor-boundary-v0.md)
- [tracks/descriptor-compatibility-package-consumption-v0.md](tracks/descriptor-compatibility-package-consumption-v0.md)
- [tracks/compatibility-report-package-descriptor-consumption-v0.md](tracks/compatibility-report-package-descriptor-consumption-v0.md)
- [discussions/runtime-compatibility-and-typed-delta-pressure-v0.md](discussions/runtime-compatibility-and-typed-delta-pressure-v0.md)

### Executor Approval Token Is A Gate 3 Prerequisite

Signal: Explicit executor approval means a scoped `ExecutorApprovalToken`
backed by a recorded authority decision; it is required before live TEMPORAL
execution work, but it does not open Gate 3 by itself.

Status: current

Source:
- [proposals/PROP-030-executor-approval-token-contract-v0.md](proposals/PROP-030-executor-approval-token-contract-v0.md)
- [tracks/executor-approval-token-report-proof-v0.md](tracks/executor-approval-token-report-proof-v0.md)
- [tracks/guarded-runtime-executor-approval-enforcement-v0.md](tracks/guarded-runtime-executor-approval-enforcement-v0.md)
- [tracks/runtime-compatibility-report-executor-boundary-v0.md](tracks/runtime-compatibility-report-executor-boundary-v0.md)
- [discussions/stage3-round8-pre-gate3-pressure-v0.md](discussions/stage3-round8-pre-gate3-pressure-v0.md)

### Gate 3 Request Readiness Is Not Approval

Signal: A restricted Gate 3 request can be revised to ready for Architect
review, but Gate 3 remains closed until an Architect decision record exists;
the current request is ready for review, not approved.

Status: current

Source:
- [gates/runtime-temporal-executor-gate3-request-v0.md](gates/runtime-temporal-executor-gate3-request-v0.md)
- [tracks/runtime-temporal-executor-gate3-request-revision-v0.md](tracks/runtime-temporal-executor-gate3-request-revision-v0.md)
- [discussions/gate3-request-safety-pressure-v0.md](discussions/gate3-request-safety-pressure-v0.md)
- [discussions/gate3-request-revision-safety-pressure-v0.md](discussions/gate3-request-revision-safety-pressure-v0.md)
- [tracks/stage3-round12-status-curation-v0.md](tracks/stage3-round12-status-curation-v0.md)

### Full Post-Switch Smoke Is The Runtime Regression Baseline

Signal: The current post-switch runtime baseline covers all six `emit_typed`
surfaces while keeping TEMPORAL evaluation refused.

Status: current

Source:
- [tracks/runtime-smoke-post-switch-full-coverage-v0.md](tracks/runtime-smoke-post-switch-full-coverage-v0.md)
- [tracks/runtime-smoke-temporal-post-switch-v0.md](tracks/runtime-smoke-temporal-post-switch-v0.md)

### TEMPORAL Cache Key Must Include Time

Signal: CORE cache key is `f(inputs)`; TEMPORAL cache key is
`f(inputs, as_of/Tt)`. Any CORE-shaped cache key for TEMPORAL is a silent
staleness bug and must refuse at the executor boundary.

Status: current

Source:
- [proposals/PROP-028-temporal-fragment-class-v0.md](proposals/PROP-028-temporal-fragment-class-v0.md)
- [tracks/temporal-cache-key-proof-v0.md](tracks/temporal-cache-key-proof-v0.md)
- [tracks/executor-boundary-cache-key-contract-v0.md](tracks/executor-boundary-cache-key-contract-v0.md)
- [spec/ch7-runtime.md](spec/ch7-runtime.md)

---

## Compiler Boundary

### Stream Replay Metadata Lives In SemanticIR And `.igapp`

Signal: The current stream replay contract is explicit in SemanticIR nodes and
assembled `stream_nodes`; runtime smoke no longer depends on hidden
proof-local stream defaults.

Status: current

Source:
- [tracks/stream-replay-metadata-emission-v0.md](tracks/stream-replay-metadata-emission-v0.md)
- [tracks/runtime-smoke-post-switch-full-coverage-v0.md](tracks/runtime-smoke-post-switch-full-coverage-v0.md)
- [spec/ch6-semanticir.md](spec/ch6-semanticir.md)

### Invariant Source Metadata Is Descriptive Evidence

Signal: Invariant source metadata and start spans now survive the compiler
pipeline into SemanticIR/report coverage as descriptive evidence, not new
runtime enforcement.

Status: current

Source:
- [tracks/invariant-source-metadata-preservation-v0.md](tracks/invariant-source-metadata-preservation-v0.md)
- [tracks/invariant-typed-shape-discharge-v0.md](tracks/invariant-typed-shape-discharge-v0.md)

---

## Temporal Model

### Time Is A Semantic Dimension, Not A Clock Call

Signal: TEMPORAL contracts are deterministic over `(inputs, Tt)`, not just
`inputs`; runtime time must be explicit and non-ambient.

Status: current

Source:
- [axiomatic-contract-model.md](axiomatic-contract-model.md)
- [meta-proposals/META-EXPERT-008.4-origin-temporal-concordance-v0.md](meta-proposals/META-EXPERT-008.4-origin-temporal-concordance-v0.md)
- [proposals/PROP-028-temporal-fragment-class-v0.md](proposals/PROP-028-temporal-fragment-class-v0.md)

### Lifecycle Means Selective Memory, Not Store Forever

Signal: `T` does not mean "retain everything forever"; lifecycle/flush/archive
must be explicit semantic transitions with receipts.

Status: pressure

Source:
- [proposals/PROP-010-temporal-lifecycle-retention-semantics-v0.md](proposals/PROP-010-temporal-lifecycle-retention-semantics-v0.md)
- [temporal-lifecycle.md](temporal-lifecycle.md)
- [tracks/runtime-machine-lifecycle-v0.md](tracks/runtime-machine-lifecycle-v0.md)

---

## Ledger Bridge

### Descriptor Capability Is Not Physical Serving Proof

Signal: `bihistory_read` in a descriptor is metadata evidence; it does not prove
the native data plane serves `at(vt:, tt:)`.

Status: current

Source:
- [tracks/descriptor-compatibility-package-consumption-v0.md](tracks/descriptor-compatibility-package-consumption-v0.md)
- [../../packages/igniter-ledger/docs/reviews/2026-05-07-native-tbackend-gap-review.md](../../packages/igniter-ledger/docs/reviews/2026-05-07-native-tbackend-gap-review.md)

### Gate 2 And Gate 3 Must Stay Separate

Signal: Gate 2 is ratified for metadata-only descriptor exposure; Gate 3 is
live Ledger/TBackend read/write/replay/runtime binding and remains closed.

Status: current

Source:
- [tracks/descriptor-gate2-architect-ratification-record-v0.md](tracks/descriptor-gate2-architect-ratification-record-v0.md)
- [tracks/descriptor-package-exposure-gate2-ratification-v0.md](tracks/descriptor-package-exposure-gate2-ratification-v0.md)
- [tracks/descriptor-compatibility-package-consumption-v0.md](tracks/descriptor-compatibility-package-consumption-v0.md)
- [agent-context.md](agent-context.md)

---

## Agentic System

### Agent Context Is The First Memory Layer

Signal: Agents should read `agent-context.md` first and avoid reconstructing the
whole project from old tracks unless assigned archaeology.

Status: current

Source:
- [agent-context.md](agent-context.md)
- [operating-model.md](operating-model.md)
- [tracks/stage3-round6-docs-status-curation-v0.md](tracks/stage3-round6-docs-status-curation-v0.md)

### Discussions Are Bounded Pressure, Not Canon

Signal: discussions can route pressure to tracks/proposals/backlog, but they do
not authorize implementation or canon promotion by themselves.

Status: current

Source:
- [discussions/README.md](discussions/README.md)
- [operating-model.md](operating-model.md)

### AI / SOI Lens

Signal: Axiomatic Ideas ask "how is this possible and under what conditions?";
System-Forming Ideas ask "why does this system exist and what is it for?"

Status: pressure

Source:
- [meta-proposals/axiomatic-and-system-forming-ideas-lens-v0.md](meta-proposals/axiomatic-and-system-forming-ideas-lens-v0.md)

---

## Syntax Pressure

### Future Syntax Must Not Outrun Parser Truth Silently

Signal: expressive fixtures are valuable pressure, but they must remain marked
as non-canon until parser/spec/proof promotion happens.

Status: current

Source:
- [meta-proposals/syntax-pressure-registry-v0.md](meta-proposals/syntax-pressure-registry-v0.md)
- [meta-proposals/syntax-pressure-review-results-v0.md](meta-proposals/syntax-pressure-review-results-v0.md)
- [tracks/future-syntax-pressure-formalization-v0.md](tracks/future-syntax-pressure-formalization-v0.md)

### Semantic Density Passed, Ergonomics Now Needs A Lane

Signal: an external agent correctly inferred Field Supply Watch's domain,
evidence model, temporal model, and audit intent; the same review flagged
large-file monotony and human delight as the next product pressure.

Status: pressure

Source:
- [reviews/2026-05-08-agent-comprehension-ergonomics-review.md](reviews/2026-05-08-agent-comprehension-ergonomics-review.md)
- [meta-proposals/human-agent-comprehension-synthesis-v0.md](meta-proposals/human-agent-comprehension-synthesis-v0.md)

---

## Applied Pressure

### Spark CRM Is A Reality Test For Temporal / Ledger / Agent Semantics

Signal: technician availability, orders, schedules, vendor lead signals, and
telephony pressure keep the language grounded in real operational systems.

Status: pressure

Source:
- [tracks/spark-technician-availability-fixture-v0.md](tracks/spark-technician-availability-fixture-v0.md)
- [tracks/spark-lead-signal-boundary-pressure-v0.md](tracks/spark-lead-signal-boundary-pressure-v0.md)
- [tracks/spark-operation-action-lifecycle-pressure-v0.md](tracks/spark-operation-action-lifecycle-pressure-v0.md)

### OSINT Is A Fractal Use Case

Signal: OSINT pressure exercises evidence, claims, trust, correction,
traceability, safety gates, and human review at both language and product level.

Status: pressure

Source:
- [tracks/osint-fractal-traceability-pressure-v0.md](tracks/osint-fractal-traceability-pressure-v0.md)
- [tracks/personal-osint-assistant-product-pressure-v0.md](tracks/personal-osint-assistant-product-pressure-v0.md)
- [tracks/osint-product-real-use-pressure-v0.md](tracks/osint-product-real-use-pressure-v0.md)

---

## Archaeology Pointers

### Stage 3 R7 Docs Snapshot

Signal: Full active documentation state after S3-R7 is preserved before the
next compaction/hoisting wave.

Status: archived

Source:
- [archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/README.md](archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/README.md)

### Stage 2 Close Snapshot

Signal: Stage 2 proof/state baseline remains the best archaeology point for
History/BiHistory, stream, OLAP, invariant, compiler package, and descriptor
proofs before Stage 3.

Status: archived

Source:
- [archive/snapshots/2026-05-07-stage2-close/README.md](archive/snapshots/2026-05-07-stage2-close/README.md)

---

## Maintenance Rule

During status curation, add or update this file only when a durable idea should
remain visible beyond a single round.

If this file grows too large, split by category:

```text
docs/value-index.md              compact table of contents
docs/value/runtime-boundary.md
docs/value/temporal-model.md
docs/value/agentic-system.md
docs/value/applied-pressure.md
docs/value/archaeology.md
```

Do not split early. A single map is easier while the system is still forming.
