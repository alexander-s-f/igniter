# Agent Motion

Status: supervisor-owned historical protocol
Date: 2026-05-07
Maintainer: `[Architect Supervisor / Codex]`
Supervisor: `[Architect Supervisor / Codex]`

---

## Purpose

This document preserves the motion protocol for the `igniter-lang` research
workspace. It is no longer the daily work log.

Active motion now lives in:

- `docs/operating-model.md` for the supervisor-owned process contract
- `docs/current-status.md` for the compact state map
- `docs/tracks/*.md` for slice evidence and handoff

Agents should not update this file unless a track explicitly assigns a protocol
change. The Architect Supervisor owns input/output motion.

---

## Agent Roles

| Role | Identity | Scope |
|------|----------|-------|
| Research Agent | `[Igniter-Lang Research Agent]` | Observable semantics, observation spine, failure model |
| Compiler/Grammar Expert | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantics, type theory, grammar fragments, composition algebra |
| Architect Supervisor | `[Architect Supervisor / Codex]` | Review, approve, redirect, bridge requests |
| Bridge Agent | `[Igniter-Lang Bridge Agent]` | Bridge proposals from lang research to platform packages |
| Applied Pressure Agent | `[Igniter-Lang Applied Pressure Agent]` | Real-system pressure, domain scenarios, interop/tooling demands, rebuild experiments |

Roles may overlap in one conversation. An agent declares its role at the top
of each document it authors.

Role passports live in `igniter-lang/roles/`. A working slice must use exactly
one role identity. Neighbor roles can be listed as affected parties, but the
agent should not speak as multiple roles in one handoff.

---

## Entry Protocol

When an agent enters the workspace:

```text
1. Read igniter-lang/AGENTS.md              — identity + write boundary
2. Read igniter-lang/roles/README.md        — active roles + neighbor map
3. Read the assigned role file              — ownership + start path
4. Read igniter-lang/docs/README.md         — current research index
5. Read igniter-lang/docs/operating-model.md — active process contract
6. Read igniter-lang/docs/current-status.md  — compact current map
7. Read slice-specific tracks/proposals only
8. Declare role + entry point in first authored document
```

An agent must NOT:

- Start writing without reading the current horizon
- Edit package code (`packages/`, `lib/`, `examples/`)
- Author a grammar or parser before semantics are stable
- Open a new track when a queued proposal covers the same ground
- Stage, unstage, restore, remove, clean, or otherwise manage unrelated files

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

### Mode 5: Applied Pressure Slice

A longer, less frequent pressure slice grounded in a real domain or
general-purpose language demand. One document in `docs/tracks/`.

```text
Domain Scenario -> Current Language Fit -> Breakpoints
-> Capability Demands -> Proof Requests -> Formal Questions
-> Bridge Candidates -> Handoff
```

Exit condition: the pressure map is specific enough that Research,
Compiler/Grammar, or Bridge agents can take follow-up slices.

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
| `[Igniter-Lang Research Agent]` | `tracks/spark-technician-availability-fixture-v0.md` + `tracks/polymorphic-add-runtime-load-boundary-v0.md` | done / blocked-useful | polymorphic-add-runtime-loader-normalization-v0 or spark-lead-signal-boundary-fixture-v0 |
| `[Igniter-Lang Compiler/Grammar Expert]` | `tracks/spark-pipeline-grammar-v0.md` | done | spark-pipeline-parser-acceptance-v0 or decimal-idempotency-retention-formalization-v0 |
| `[Igniter-Lang Bridge Agent]` | `bridge/compiler-pipeline-profile-prop019-alignment-v0.md` | done | Architect-reviewed compiler pipeline PROP-019 carrier alignment plan |
| `[Igniter-Lang Applied Pressure Agent]` | `tracks/spark-lead-signal-boundary-pressure-v0.md` | done | spark-operation-action-lifecycle-pressure-v0 or sandbox-simulation-world-modeling-pressure-v0 |

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

[S] External candidate admission and Ruby FFI proof now share one boundary:

```text
declared source/effect/capability/lifecycle
  -> normalized selected_profile artifacts
  -> receipt_or_failure observation
  -> evidence-linked result
```

Package or bridge integration should remain blocked until an external candidate
passes the selected-profile checker and Ruby host calls are modeled as
contractable ESCAPE, not ambient implementation calls.

[S] External candidate normalization is now executable:

```text
external_candidate_fixture/raw_candidate.json
  -> external_candidate_normalizer.rb
  -> selected_profile candidate artifacts
  -> packet_builder_check.rb --profile-mode selected_profile
```

The generated `external_ref_map.json` and `adapter_diagnostics.json` are
human-review aids, not trusted admission evidence in v0.

[S] Stdlib, source boundary, and grammar kernel are now specified:

```text
PROP-013 -> bounded collections, fold/map/filter/group_by, Option, Result
PROP-014 -> source syntax boundary to ParsedProgram/ClassifiedProgram/TypedProgram/SemanticIR
PROP-015 -> def, TypeDecl, module/import, v0 BNF, source fixtures
```

The source fixture pair is now:

```text
igniter-lang/source/add.ig
igniter-lang/source/availability_projection.ig
```

Future parser work should target these fixtures first and compare toward the
existing `.igapp/` artifacts before claiming compiler progress.

[S] Minimal parser experiment has started:

```text
igniter-lang/experiments/parser/igniter_lang_parser.rb
  -> ParsedProgram JSON
```

It parses both source fixtures without parse errors, but it does not yet
classify, typecheck, lower to SemanticIR, or compare parsed surfaces to
`.igapp` fixtures.

[S] FFI receipt fixtures are now executable:

```text
ffi_ruby_receipt_fixtures.rb
  -> descriptors
  -> read_success
  -> write_audit_success
  -> capability_denied
  -> host_error
```

Future bridge/package work should treat these as the FFI admission fixture
surface until intent/delegation and normalized-equivalence rules are approved.

[D] Runtime model identity decisions are now captured:

```text
immutable bindings
lexical scope
value semantics
region-style evaluation memory
semantic GC through TBackend lifecycle
structural DAG parallelism
staged self-hosting
```

These decisions should be treated as language semantics, not runtime
implementation preferences.

[S] Polymorphic Add is now a source pressure fixture:

```text
igniter-lang/source/polymorphic_add.ig
igniter-lang/source/polymorphic_add.parsed_program.expected.json
```

It introduces `trait`, `impl`, `contract_shape`, and generic contract headers
as expected future ParsedProgram shape only. RuntimeMachine must still receive
monomorphic SemanticIR specializations such as `Add[Integer]` and `Add[Float]`;
no unresolved overload survives load.

[S] RuntimeMachine schema_check is standalone again:

```text
loaded_unit
loaded_schema_descriptor
  -> SemanticImage.schema_fingerprint
  -> CompatibilityReport.schema_check
```

`CompiledProgram` may supply the schema descriptor, but RuntimeMachine does not
depend on `loaded_program` for schema compatibility. The memory proof now checks
trusted schema match and provisional schema drift directly.

[S] RuntimeMachine schema migration has a standalone fixture:

```text
MigrationDescriptor
  -> CompatibilityReport schema_check:migrating
  -> intent_observation
  -> receipt_observation lifecycle:audit
     caused_by + produced_by + replaces
```

This fixture proves migration evidence shape only. Replacement SemanticImage
production remains the next boundary.

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
    runtime-machine-external-candidate-and-ffi-proof-v0.md [done]
    runtime-machine-external-candidate-normalizer-fixtures-v0.md [done]
    ffi-ruby-contractable-proof-v0.md [done]
    runtime-machine-ffi-ruby-receipt-fixtures-v0.md [done]
    runtime-machine-schema-check-standalone-fix-v0.md [done]
    runtime-machine-schema-migration-fixture-v0.md [done]
    source-fixture-parser-acceptance-harness-v0.md [partial]
    polymorphic-add-devkit-fixture-v0.md [done]
    bridge-observation-envelope-implementation-plan-v0.md [done]
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
    PROP-008-tbackend-contract-v0.md                 [done]
    PROP-009-semantic-image-resume-compatibility-v0.md [done]
    PROP-010-temporal-lifecycle-retention-semantics-v0.md [done]
    PROP-011-runtime-machine-lifecycle-v0.md         [done]
    PROP-012-compilation-artifact-deployment-model-v0.md [done]
    PROP-013-stdlib-fold-aggregate-v0.md             [done]
    PROP-014-source-syntax-semanticir-boundary-v0.md [done]
    PROP-015-grammar-module-system-v0.md             [done]

  source/
    add.ig [source fixture]
    availability_projection.ig [source fixture]
    polymorphic_add.ig [pressure fixture - trait/impl/contract_shape]
    polymorphic_add.parsed_program.expected.json [expected future ParsedProgram shape]

  experiments/
    runtime_machine_memory_proof/ [done - standalone harness + golden fixtures + checker + profiles + modes + external normalizer + FFI receipt fixtures]
    parser/ [partial - minimal source fixture parser to ParsedProgram JSON]
  bridge/                        <- bridge notes to Igniter platform
    README.md [active index]
    bridge-agent-entry-v0.md [done - Bridge Agent presence and pressure map]
    schema-compatibility-diagnostics-bridge-v0.md [done - metadata-only schema diagnostics bridge]
    schema-compatibility-diagnostics-package-touchpoint-map-v0.md [done - first package target recommendation]
    schema-compatibility-diagnostics-igniter-contracts-plan-v0.md [done - igniter-contracts implementation plan]
    schema-migration-bridge-profile-v0.md [done - migration evidence bridge profile]
    spark-availability-diagnostics-bridge-profile-v0.md [done - Spark availability metadata diagnostics profile]
    operation-diagnostics-and-receipts-bridge-profile-v0.md [done - generic operation diagnostics and receipts profile]
    lead-boundary-diagnostics-retention-bridge-profile-v0.md [done - lead boundary diagnostics and retention receipts profile]
    model-validity-and-scenario-comparison-bridge-profile-v0.md [done - simulation diagnostics and model validity profiles]
    human-agent-review-approval-bridge-profile-v0.md [done - human-agent review and acceptance profiles]
    osint-claim-factcheck-correction-bridge-profile-v0.md [done - OSINT-like claim/fact-check correction profiles]
    osint-product-bridge-profiles-v0.md [done - personal OSINT assistant product profiles]
    semanticir-verification-report-bridge-v0.md [done - SemanticIR proof result VerificationReport bridge]
    compiler-pipeline-profile-bridge-v0.md [done - unified compiler pipeline profile family]
    compiler-pipeline-profile-prop019-alignment-v0.md [done - PROP-019 aligned compiler pipeline profile examples]
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
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-external-candidate-and-ffi-proof-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-external-candidate-normalizer-fixtures-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-ffi-ruby-receipt-fixtures-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/bridge-observation-envelope-implementation-plan-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/temporal-lifecycle-application-scenarios-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/temporal-lifecycle-boundary-fixtures-v0.md | done |
| 2026-05-05 | `[Igniter-Lang Research Agent]` | tracks/polymorphic-add-devkit-fixture-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-schema-check-standalone-fix-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Research Agent]` | tracks/runtime-machine-schema-migration-fixture-v0.md | done |
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
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/polymorphic-add-parser-pressure-map-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/polymorphic-add-classifier-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/migration-replacement-image-formalization-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/specialization-request-source-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/spark-tenant-and-pipeline-formalization-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/spark-pipeline-grammar-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/spark-pipeline-parser-acceptance-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/decimal-idempotency-retention-formalization-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/operation-action-result-types-and-transition-semantics-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/decimal-grammar-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/observation-trust-classes-and-simulation-loop-semantics-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/claim-evidence-confidence-typing-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/meaning-diff-and-acceptance-semantics-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/osint-product-types-and-alert-gates-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-018-source-to-semanticir-minimal-pipeline-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-019-canonical-semanticir-envelope-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-020-classifier-pass-v0-formalization | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-019.1-semanticir-envelope-errata-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-021-typechecker-pass-v0-formalization | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-022-igapp-assembler-contract-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-023-classified-expr-boundary-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/classified-expr-implementation-acceptance-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-024-parser-oof-hardening-spec-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-027-production-compiler-diagnostics-contract-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/extract-canonical-json-diagnostics-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/temporal-option-and-bihistory-shape-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/history-type-parser-acceptance-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/bihistory-parser-typechecker-axes-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/invariant-severity-parser-and-typechecker-ownership-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/stream-parser-classifier-boundary-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/stream-classifier-escape-propagation-v0 | done |
| 2026-05-07 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/olap-point-parser-typechecker-boundary-v0 | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/bridge-agent-entry-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/schema-compatibility-diagnostics-bridge-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/schema-compatibility-diagnostics-package-touchpoint-map-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/schema-compatibility-diagnostics-igniter-contracts-plan-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/schema-migration-bridge-profile-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/spark-availability-diagnostics-bridge-profile-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/operation-diagnostics-and-receipts-bridge-profile-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/lead-boundary-diagnostics-retention-bridge-profile-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/model-validity-and-scenario-comparison-bridge-profile-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/human-agent-review-approval-bridge-profile-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/osint-claim-factcheck-correction-bridge-profile-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/osint-product-bridge-profiles-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/semanticir-verification-report-bridge-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/compiler-pipeline-profile-bridge-v0.md | done |
| 2026-05-06 | `[Igniter-Lang Bridge Agent]` | bridge/compiler-pipeline-profile-prop019-alignment-v0.md | done |

---

## Numbering Errata (appended 2026-05-07 by Meta Expert)

The Compiler/Grammar Expert logged two entries with incorrect PROP numbers on 2026-05-07.
The following table records the correction. Do not renumber entries in the history above.

| Logged as | Correct canonical number | File | Status |
|-----------|--------------------------|------|--------|
| `proposals/PROP-024-parser-oof-hardening-spec-v0` | **PROP-026** | `PROP-026-parser-oof-hardening-spec-v0.md` | ✅ PASS (proof) |
| `proposals/PROP-025-production-compiler-diagnostics-contract-v0` | **PROP-027** | `PROP-027-production-compiler-diagnostics-contract-v0.md` | authored |

Root cause: PROP-024 and PROP-025 were already assigned to OLAPPoint and invariant severity
(Stage 2 design PROPs). The Compiler Expert was unaware of this assignment at authoring time.
The files were renamed using `git mv` to PROP-026 and PROP-027.

Future PROP numbering: always check `proposals/README.md` §Queued for next available number.
Current next available: **PROP-028**.
