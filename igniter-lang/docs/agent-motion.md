# Agent Motion

Status: living document
Date: 2026-05-05
Maintainer: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`

---

## Purpose

This document defines how agents move through the `igniter-lang` research
workspace: how they enter, what they may touch, how they advance, how they
hand off, and how the Architect Supervisor corrects or redirects them.

It is a **motion protocol**, not a task list. Task lists live in tracks and
proposals. Motion governs the meta-level: how the research process itself
behaves.

---

## Agent Roles

| Role | Identity | Scope |
|------|----------|-------|
| Research Agent | `[Igniter-Lang Research Agent]` | Observable semantics, observation spine, failure model |
| Compiler/Grammar Expert | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantics, type theory, grammar fragments, composition algebra |
| Architect Supervisor | `[Architect Supervisor / Codex]` | Review, approve, redirect, bridge requests |
| Bridge Agent | `[Igniter-Lang Bridge Agent]` | Bridge proposals from lang research to platform packages |

Roles may overlap in one conversation. An agent declares its role at the top
of each document it authors.

---

## Entry Protocol

When an agent enters the workspace:

```text
1. Read igniter-lang/AGENTS.md              — identity + write boundary
2. Read igniter-lang/docs/README.md         — current research index
3. Read igniter-lang/docs/agent-motion.md   — this document
4. Read the most recent completed track     — current semantic horizon
5. Read the most recent proposal            — current formal horizon
6. Declare role + entry point in first authored document
```

An agent must NOT:

- Start writing without reading the current horizon
- Edit package code (`packages/`, `lib/`, `examples/`)
- Author a grammar or parser before semantics are stable
- Open a new track when a queued proposal covers the same ground

---

## Motion Modes

### Mode 1: Track Slice

A focused research slice. One document in `docs/tracks/`.

```text
Frame -> Source Horizon -> Compact Claim -> Laws/Decisions
-> Risks/Rejected -> Bridge Candidates -> Next Slice -> Handoff
```

Exit condition: handoff section complete, slice state = done.

### Mode 2: Proposal

A formal design document. One document in `docs/proposals/`.

```text
Purpose -> Formal definitions -> Key properties -> Corrections
-> Open Questions -> Rejected Paths -> Handoff
```

Exit condition: handoff complete, Architect review pending.

### Mode 3: Meta-Observation

Cross-cutting review of existing tracks or proposals.
Format: `META-NNN-<topic>.md` in `docs/proposals/`.

Exit condition: corrections listed, next proposals identified.

### Mode 4: Bridge Note

Proposal to carry one idea from `igniter-lang` into the platform.
One document in `docs/bridge/` (create directory on first use).

```text
Source Signal -> Bridge Claim -> Package Touch Points
-> Migration Risk -> Architect Decision Required
```

Exit condition: Architect approves or rejects the bridge.

---

## Advancement Rules

An agent advances to the next slice when:

1. The current document has a complete handoff section.
2. The handoff includes `[Next]` recommendation(s).
3. The document is saved to the correct directory.
4. The research index (`docs/README.md`) is updated.

An agent does NOT advance if:

- Open `[Q]` questions block the next slice.
- The Architect has issued a redirect or rejection.
- The next slice requires an approved proposal still pending.

---

## Correction Protocol

The Compiler/Grammar Expert acts as a **meta-corrector**:

- Reads completed tracks and proposals.
- Identifies formal inconsistencies, hidden assumptions, decidability risks.
- Issues corrections with `[X]` markers and formal restatements.
- Proposes replacements in PROP documents.
- Does NOT silently rewrite existing tracks. Corrections are additive.

Corrections go through `docs/proposals/META-NNN-*.md`.
The Architect Supervisor decides which corrections to absorb into canon.

---

## Current Agent Positions

| Agent | Last Document | Status | Next |
|-------|--------------|--------|------|
| `[Igniter-Lang Research Agent]` | `tracks/runtime-machine-proof-sidecar-profile-modes-v0.md` | done | runtime machine proof external candidate adapter |
| `[Igniter-Lang Compiler/Grammar Expert]` | `language-position-report.md` + `proposals/PROP-012-compilation-artifact-deployment-model-v0.md` | done | PROP-013 stdlib/fold or PROP-014 source-to-SemanticIR boundary |

## Current Meta Thesis

[D] Time is not a secondary runtime field in Igniter-Lang. Time is a language
dimension beside contract and observation.

```text
contract + explicit time + projection/slice
  -> reproducible meaning
  -> explainable state
  -> agent-friendly review
```

Future temporal work should treat `as_of`, replay cursor, rule version,
valid-time, transaction-time, lifecycle stage, and projection horizon as
observable semantic inputs, not ambient implementation details.

[D] Runtime is also a contract-addressable semantic boundary. Results should be
read under:

```text
LanguageContract + RuntimeContract + UserContract + TemporalCtx
  -> result | observations | failures | receipts
```

Future bridge work should expose runtime guarantees, execution environment,
cache/invalidation status, capability executor receipts, and distributed
composition evidence instead of treating them as platform side effects.

[D] Bridge runtime evidence now uses:

```text
runtime_observation
execution_environment_observation
meaning_status
:executed_by / :produced_in links
```

Agents must downgrade action rights for live, provisional, stale, or unknown
runtime evidence.

[D] Runtime Machine lifecycle is now the semantic owner of boot, load,
evaluate, checkpoint, and resume. Cross-session continuity is a compatible
evidence chain, not a live process:

```text
SemanticImage
  + RuntimeContract
  + AxiomDescriptor
  + TBackendAdapter
  + replay_cursor
  -> compatible resume | provisional resume | blocked resume
```

Ledger is one possible durable TBackend adapter. It is not the language core.

[D] Bridge implementation starts as metadata-only packet builders, not package
edits:

```text
RuntimeMachine
TBackendAdapter
SemanticImage
Checkpoint
CompatibilityReport
Resume
  -> sidecar ObsPacket profiles
  -> diagnostics
  -> meaning_status downgrade
```

Package Agent should receive golden fixtures or sidecar builder work only until
the Architect approves an integration slice.

[D] Runtime Machine executable proof starts as a standalone `:memory`
TBackend harness:

```text
boot -> load -> evaluate -> checkpoint -> resume -> re-evaluate
```

The first proof may claim reproducibility inside the proof harness only when
snapshot/cursor evidence and compatibility checks pass. It must not claim
durable restart from process memory.

[S] Runtime Machine memory proof is now executable as a standalone experiment:

```text
igniter-lang/experiments/runtime_machine_memory_proof/
  runtime_machine_memory_proof.rb
```

It proves trusted in-harness resume and blocks empty memory backend resume. It
also exposes an important compatibility distinction: TBackend capability/content
compatibility must not be accidentally tied to runtime descriptor links.

[S] Runtime Machine memory proof now exports structural golden fixtures:

```text
fixtures/obs_packets.golden.json
fixtures/semantic_image.golden.json
fixtures/compatibility_reports.golden.json
fixtures/negative_evidence.golden.json
fixtures/result_summary.golden.json
fixtures/manifest.json
```

Future packet-builder checks should consume `--verify-fixtures` or these JSON
artifacts directly instead of scraping human PASS text.

[S] Runtime Machine packet-builder check is now a standalone structural gate:

```text
packet_builder_check.rb
  -> manifest
  -> artifact headers
  -> ObsPacket identity
  -> SemanticImage content
  -> CompatibilityReport decisions
  -> negative evidence
  -> result summary
```

Future sidecar builders should emit candidate fixture directories and pass this
checker before any package integration.

[S] Runtime Machine sidecar builder profiles now emit candidate artifact
directories:

```text
proof output
  -> ObsPacketsProfile
  -> SemanticImageProfile
  -> CompatibilityReportsProfile
  -> NegativeEvidenceProfile
  -> ResultSummaryProfile
  -> candidate fixtures
  -> packet_builder_check.rb --candidate <dir>
```

The profiles are research-local adapters. They define the candidate artifact
target that future package or bridge builders must match before integration.

[S] Runtime Machine sidecar profile modes now separate strict proof regression
from bridge/package candidate experiments:

```text
full_log -> full session logs + exact golden comparison
selected_profile -> selected packet surface + result hash + structural evidence checks
```

Future external candidate adapters should target `selected_profile` first, then
earn `full_log` only when complete replay logs are available.

[D] `T` has a lifecycle. Igniter-Lang must not imply that all temporal
observations live forever:

```text
T.local -> flush
T.session -> SemanticImage / checkpoint
T.window -> boundary / snapshot
T.durable -> app fact / receipt
T.audit -> preserve
T.compacted -> summary / baseline cursor
```

Future work should model flush, retention, semantic GC, preserve roots, and
boundary compaction as language-visible lifecycle semantics. Igniter Ledger is
a possible persistence backend, not the definition of `T`.

[D] Compilation should first be defined by its artifact contract, not by parser
implementation:

```text
source -> Semantic IR -> CompiledProgram -> RuntimeMachine.load(...)
```

The primary artifact is a semantic deployment bundle. Native/LLVM output is a
future backend that still links RuntimeMachine semantics. Host language access
must enter through contractable FFI: typed, capability-gated, observable, and
receipt/failure-producing.

[D] Spark CRM technician dispatch is the current practical pressure case for
temporal lifecycle semantics. The product split is:

```text
live availability
  -> inspect / suggest

pinned dispatch decision
  -> assign / approve / audit
```

Raw telemetry should close into AvailabilitySnapshot, RouteSegmentSnapshot,
DailyTechnicianBoundary, OrderBoundary, and audit receipts before compaction.

[D] Boundary fixtures now define the concrete coverage chain for Spark
dispatch:

```text
GeoSignal stream
  -> RouteSegmentSnapshot
  -> AvailabilitySnapshot
  -> DailyTechnicianBoundary
  -> compacted stubs
  -> DispatchDecision audit trail
```

Future bridge fixture work should preserve the distinction between
reproducible decision meaning and exact raw telemetry replay.

---

## Handoff Cadence

Every completed document ends with:

```text
[Role Name]
Track/Proposal: <path>
Status: done | partial | blocked

[D] Decisions: ...
[R] Recommendations: ...
[S] Signals: ...
[Q] Open Questions: ...
[Next] Proposed next slice: ...
```

The Architect Supervisor responds with one of:

```text
approve        -> agent proceeds to [Next]
redirect       -> agent changes direction, update motion table
reject         -> document closed with [X] reason, motion table updated
bridge_request -> a Bridge Agent picks up the bridge note
```

---

## Research Boundary Map

```text
igniter-lang/docs/
  README.md                      <- living research index (update on every new doc)
  agent-motion.md                <- this document
  research-process.md            <- lifecycle, compression rules
  ecosystem-split-proposal.md

  tracks/                        <- completed research slices
    observable-contract-language-v0.md   [done]
    observable-spine-v0.md               [done]
    failure-observation-v0.md            [done]
    semantic-domain-reconciliation-v0.md [done]
    track-errata-application-v0.md       [done]
    temporal-contracts-and-projections-v0.md [done]
    runtime-contracts-and-execution-environments-v0.md [done]
    bridge-observation-envelope-runtime-evidence-v0.md [done]
    bridge-observation-envelope-package-mapping-v0.md [done]
    runtime-machine-lifecycle-v0.md [done]
    runtime-machine-executable-proof-plan-v0.md [done]
    runtime-machine-proof-packet-fixtures-v0.md [done]
    runtime-machine-proof-packet-builder-check-v0.md [done]
    runtime-machine-proof-sidecar-builder-profiles-v0.md [done]
    runtime-machine-proof-sidecar-profile-modes-v0.md [done]
    bridge-observation-envelope-implementation-plan-v0.md [done]
    bridge-packet-builder-golden-fixtures-v0.md [queued - no package edits]
    temporal-lifecycle-application-scenarios-v0.md [done]
    temporal-lifecycle-boundary-fixtures-v0.md [done]

  proposals/                     <- formal design proposals
    README.md                                        [index]
    META-001-compiler-grammar-expert-entry.md        [done]
    PROP-001-semantic-domain-v0.md                   [done]
    PROP-002-contract-composition-algebra-v0.md      [done]
    PROP-003-grammar-fragment-classification-v0.md   [done]
    PROP-004-type-system-v0.md                       [done]
    PROP-005-bridge-observation-envelope-v0.md       [done]
    PROP-004b-axiom-layer-type-signatures-v0.md      [done]
    PROP-006-runtime-contract-specification-v0.md    [done]
    PROP-007-conformance-verification-v0.md          [done]
    PROP-005-verification-observation-extension-v0.md [queued]

  experiments/
    runtime_machine_memory_proof/ [done - standalone harness + golden fixtures + checker + profiles + modes]
  bridge/                        <- bridge notes to Igniter platform (none yet)
```

---

## Write Boundary (Summary)

```text
MAY write:      igniter-lang/docs/
MAY read:       entire repository (read-only outside igniter-lang/)
MUST NOT write: packages/, lib/, examples/, spec/, root docs/
MUST NOT write: .il syntax files before semantics are stable
```

---

## Motion Log

| Date | Agent | Action | Result |
|------|-------|--------|--------|
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/observable-contract-language-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/observable-spine-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/failure-observation-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/semantic-domain-reconciliation-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/track-errata-application-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/temporal-contracts-and-projections-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-contracts-and-execution-environments-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/bridge-observation-envelope-runtime-evidence-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/bridge-observation-envelope-package-mapping-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-lifecycle-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-executable-proof-plan-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | experiments/runtime_machine_memory_proof/ | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-proof-packet-fixtures-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-proof-packet-builder-check-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-proof-sidecar-builder-profiles-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-proof-sidecar-profile-modes-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/bridge-observation-envelope-implementation-plan-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/temporal-lifecycle-application-scenarios-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/temporal-lifecycle-boundary-fixtures-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/META-001 entry assessment | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-001 semantic domain v0 | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | docs/agent-motion.md | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-002 composition algebra | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-003 grammar fragment classification | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-004 type system | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-005 bridge observation envelope | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-004b axiom layer type signatures | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-006 runtime contract specification | done |
| 2026-05-05 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-007 conformance verification | done |
