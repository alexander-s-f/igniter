# Track: PROP-037 External Progression Proposal Authoring v0

Card: S3-R36-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Status: done
Date: 2026-05-11

---

## Goal

Author formal PROP-037 proposal text for External Progression and Service
Liveness Semantics.

This card is proposal-authoring only. It does not authorize parser, TypeChecker,
SemanticIR, RuntimeMachine, Ledger/TBackend, durable queue/checkpoint, production
execution, ProgressionPack migration, or a new `PROGRESSION` fragment class.

---

## Inputs Read

- `docs/gates/progression-prop-number-assignment-decision-v0.md`
- `docs/tracks/external-progression-prop-scope-draft-v0.md`
- `docs/tracks/external-progression-semantics-decision-prep-v0.md`
- `docs/tracks/progression-pack-shadow-boundary-v0.md`
- `docs/proposals/PROP-023-stream-input-surface-v0.md`
- `docs/spec/ch13-managed-recursion.md`
- `docs/current-status.md`
- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `roles/compiler-grammar-expert.md`

Neighbor roles affected:

- `[Igniter-Lang Research Agent]` may later own proof fixtures or pressure
  evidence once implementation is authorized.
- `[Igniter-Lang Bridge Agent]` may later map runtime/profile/manifest handoff
  implications if governance accepts the proposal.

---

## Delivered

- Created `docs/proposals/PROP-037-external-progression-service-liveness-v0.md`.
- Updated `docs/proposals/README.md` to mark PROP-037 as
  `authored-pending-review` and remove it from the unauthored queue.
- Created this track doc.

---

## Decisions Captured In PROP-037

### Progression Is Not Stream

Progression is defined as a runtime/liveness semantic surface for externally
materialized event potential, service-step lifecycle, receipts, checkpointing,
cancellation, and backpressure.

It is distinct from:

- `Stream[T]`, which remains a data-flow/input surface.
- `fold_stream`, which remains the bounded stream-to-CORE fold bridge governed
  by PROP-023 and OOF-S1..OOF-S5.
- local managed recursion, which remains represented by finite, structural,
  fuel-bounded, and convergent loop classes.

### Service Loop Reframe

Service loops are specified as progression-backed liveness surfaces. A service
loop must name progression obligations instead of pretending to be a local
recursion construct or a plain stream fold.

### Metadata-First Adoption

PROP-037 proposes a runtime capability and manifest metadata shape first. It
does not add a parser syntax, new TypeChecker surface, new SemanticIR nodes, or a
new fragment class.

### Source Descriptor Shape

The proposal defines a descriptor centered on:

- `progression_ref`
- `source_kind`
- `source_ref`
- `payload_type`
- `materialization_policy`
- `handler_ref`
- `receipt_policy`
- `liveness`

### `external_event` Vocabulary Decision

The v0 `source_kind` vocabulary is closed:

- `clock.every`
- `queue`
- `external_event`

`external_event` is the open extension point below the top-level vocabulary:
profiles/runtimes may specialize `source_ref`, `payload_type`, authority, and
capability metadata. Adding a new top-level `source_kind` requires a later
proposal, errata, or profile extension decision.

### Event And Receipt Shapes

The proposal defines descriptive shapes for:

- `ProgressionEvent`
- `ProgressionStepReceipt`

These are proposal artifacts only. They are not runtime objects or SemanticIR
nodes until separately authorized.

---

## OOF-PR Categories

PROP-037 reserves these progression diagnostics:

| Code | Meaning |
|------|---------|
| OOF-PR1 | Progression usage without a source descriptor |
| OOF-PR2 | Unbounded eager execution of an external progression source |
| OOF-PR3 | Progression-capable service surface without cancellation semantics |
| OOF-PR4 | Infinite or resumable progression without checkpoint semantics |
| OOF-PR5 | Service/infinite progression without bounded-step policy |
| OOF-PR6 | Effectful progression work hidden inside CORE/pure computation |
| OOF-PR7 | Progression source without receipt policy |
| OOF-PR8 | Nested progression inside pure contract/compute boundary |
| OOF-PR9 | Unsupported progression source kind or missing runtime capability |

OOF-PR5 is proposed as an error for service/infinite progression. Later
experiment-only bounded surfaces may choose a softer profile-specific rule only
with explicit authorization.

---

## Implementation Blockers

PROP-037 is not ready for implementation until governance accepts or amends the
proposal. After acceptance, separate implementation cards must decide:

- Manifest field ownership for `progression_sources`.
- CompatibilityReport schema and readiness/refusal behavior.
- Whether any parser/source syntax is needed, and if so which PROP owns it.
- TypeChecker diagnostics and capability validation boundaries.
- SemanticIR node/artifact names, if metadata-only representation proves
  insufficient.
- Runtime proof-local scheduler/step boundary, still without production
  execution.
- Receipt sink/checkpoint store abstractions, without assuming Ledger/TBackend.
- Whether ProgressionPack remains shadow-only or receives a migration proposal.

---

## Command Matrix

No code or proof commands were required for this doc-only proposal-authoring
card.

| Command | Result | Notes |
|---------|--------|-------|
| Not run | N/A | Proposal/index/track documentation only |

---

## Handoff

Card: S3-R36-C4-P

[D] PROP-037 formal proposal authored and indexed as `authored-pending-review`.

[S] Scope is proposal-only. No parser, TypeChecker, SemanticIR, runtime,
Ledger/TBackend, durable queue/checkpoint, production execution,
ProgressionPack migration, or new fragment class is authorized.

[T] No tests were run because this card changed documentation only.

[R] Main residual risk is governance wording: acceptance must confirm whether
the closed v0 `source_kind` set and OOF-PR5 severity are the desired initial
shape.

[Next] Architect/Meta review can accept, amend, or defer PROP-037. Any
implementation must be routed through a later card with explicit layer
authorization.
