# Igniter-Lang Proposals Index

Status: active index
Maintainer: `[Igniter-Lang Compiler/Grammar Expert]`

This directory contains design proposals for Architect review.
Proposals are smaller than full research tracks — they focus on a single
design decision or formal specification.

---

## Active Proposals

| File | Status | Author | Summary |
|------|--------|--------|---------|
| [META-001-compiler-grammar-expert-entry.md](META-001-compiler-grammar-expert-entry.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Entry assessment, meta-corrections to existing tracks, proposed research vectors |
| [PROP-001-semantic-domain-v0.md](PROP-001-semantic-domain-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantic domain: values, types, temporal context, contracts, observations, failures |
| [PROP-002-contract-composition-algebra-v0.md](PROP-002-contract-composition-algebra-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Typed port graph algebra: >>, ||, branch, over, embed; algebraic laws; composition closure theorem |
| [PROP-003-grammar-fragment-classification-v0.md](PROP-003-grammar-fragment-classification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Three-class fragment model: CORE / ESCAPE / OOF; Pass 0 compiler; DSL keyword mapping |
| [PROP-004-type-system-v0.md](PROP-004-type-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Structural types, temporal capabilities, Projection[T,horizon], Obs[kind,T], soundness theorem |
| [PROP-005.1-obspacket-patch-lifecycle-verification-v0.md](PROP-005.1-obspacket-patch-lifecycle-verification-v0.md) | patch | `[Igniter-Lang Compiler/Grammar Expert]` | ObsPacket v0.1: lifecycle field, 9th ObsKind :verification_observation, WF-10/11, canonical hash |
| [PROP-005-bridge-observation-envelope-v0.md](PROP-005-bridge-observation-envelope-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal envelope spec: Obs[kind,T], Identity/Provenance/Policy groups, Option[T] payload, package mappings |
| [PROP-004b-axiom-layer-type-signatures-v0.md](PROP-004b-axiom-layer-type-signatures-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Three-tier axiom stack: built-ins, runtime contracts, platform observations; language boundary definition |
| [PROP-006-runtime-contract-specification-v0.md](PROP-006-runtime-contract-specification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | RuntimeContract: scheduler, clock, cache, storage, capability, distributed ESCAPE; conformance levels |
| [PROP-007-conformance-verification-v0.md](PROP-007-conformance-verification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Verification protocol: 5 check suites, warning/failure rules, trust levels; agent trust decision |
| [PROP-008-tbackend-contract-v0.md](PROP-008-tbackend-contract-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | TBackend[T]: read, append, replay, snapshot, compact, subscribe; reproducible resume; adapter classes |
| [PROP-009-semantic-image-resume-compatibility-v0.md](PROP-009-semantic-image-resume-compatibility-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | SemanticImage, CompatibilityReport, ResumeStatus: trusted/provisional/downgraded/blocked rules |
| [PROP-009.1-resume-ordering-errata.md](PROP-009.1-resume-ordering-errata.md) | errata | `[Igniter-Lang Compiler/Grammar Expert]` | Clarifies CompatibilityReport as evaluation gate (after Boot+Verification); GATE-1 invariant |
| [PROP-010-temporal-lifecycle-retention-semantics-v0.md](PROP-010-temporal-lifecycle-retention-semantics-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | 6 lifecycle classes, flush semantics, semantic GC roots, 5 downgrade rules, lifecycle matrix |
| [PROP-011-runtime-machine-lifecycle-v0.md](PROP-011-runtime-machine-lifecycle-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Runtime Machine: 5 typed lifecycle steps (boot/load/evaluate/checkpoint/resume) using PROP-006..010 |
| [PROP-012-compilation-artifact-deployment-model-v0.md](PROP-012-compilation-artifact-deployment-model-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | CompiledProgram, 4 compiler stages, SemanticIR, artifact hash, 4 deployment modes, contractable FFI |
| [PROP-013-stdlib-fold-aggregate-v0.md](PROP-013-stdlib-fold-aggregate-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Collection[T], Option[T], Result[T,E], fold/map/filter/group_by/avg; TR-1 termination; aggregated_from links |
| [PROP-014-source-syntax-semanticir-boundary-v0.md](PROP-014-source-syntax-semanticir-boundary-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Minimal syntax kernel; ParsedProgram; 4-stage path to SemanticIR; OOF rejection; .igapp/ fixture mapping |
| [PROP-015-grammar-module-system-v0.md](PROP-015-grammar-module-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | def blocks (pure/non-recursive); TypeDecl (structural); module/import; full v0 BNF; complete source for both fixtures |
| [PROP-016-polymorphism-traits-contract-shapes-v0.md](PROP-016-polymorphism-traits-contract-shapes-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Generic contracts; traits (compile-time, not OO); impl coherence; contract_shape; implements (structural); monomorphization; compile-time overload; no unresolved overloads in SemanticIR |
| [PROP-017-schema-evolution-contract-migration-v0.md](PROP-017-schema-evolution-contract-migration-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | SemVer versioning; schema_fingerprint; 5 safe/7 breaking changes; CompatibilityReport schema_check (4th dim); MigrationDecl (ESCAPE+audit receipt+replaces link); OOF-S1..S5 |
| [PROP-018-source-to-semanticir-minimal-pipeline-v0.md](PROP-018-source-to-semanticir-minimal-pipeline-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Minimal pipeline proof: source.ig → parser → classifier → SemanticIR; fixture structure; pipeline smoke test |
| [PROP-019-canonical-semanticir-envelope-v0.md](PROP-019-canonical-semanticir-envelope-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Canonical SemanticIRProgram envelope; CompilationReport; .igapp/ layout; OOF rejection gate |
| [PROP-019.1-semanticir-envelope-errata-v0.md](PROP-019.1-semanticir-envelope-errata-v0.md) | errata | `[Igniter-Lang Compiler/Grammar Expert]` | Removes oof_log from clean envelope; adds compilation_report_ref; assembler acceptance criteria |
| [PROP-020-classifier-pass-v0-formalization.md](PROP-020-classifier-pass-v0-formalization.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Classifier pass: CORE/ESCAPE/OOF marking, propagation rules, proven in experiments/ |
| [PROP-021-typechecker-pass-v0-formalization.md](PROP-021-typechecker-pass-v0-formalization.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | TypeChecker: structural resolution, trait checking, monomorphization, narrow v0 scope |
| [PROP-022-history-type-constructor-v0.md](PROP-022-history-type-constructor-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | **Stage 2**: History[T]/BiHistory[T] as first-class type constructors; temporal operations; unification with OLAPPoint |
| [PROP-023-stream-input-surface-v0.md](PROP-023-stream-input-surface-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | **Stage 2**: stream T as ESCAPE input; window declaration; fold_stream bounded reduction; KPN/ω-transducer grounding |
| [PROP-024-olap-point-primitive-v0.md](PROP-024-olap-point-primitive-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | **Stage 2**: OLAPPoint[T,Dims] as first-class primitive; olap_point declaration; cluster scatter-gather |
| [PROP-025-invariant-severity-levels-v0.md](PROP-025-invariant-severity-levels-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | **Stage 2**: invariant severity :error/:warn/:soft/:metric; label; overridable_with |

---

## Queued Proposals (not yet authored)

| ID | Title | Depends On | Stage | Priority |
|----|-------|------------|-------|----------|
| PROP-026 | Probabilistic types ~T (ProbLog subset) | PROP-022, PROP-025 | 2 | medium |
| PROP-027 | Deadline contracts + WCET analysis | PROP-003, PROP-016 | 3 | medium |
| PROP-028 | Full unit algebra (dimensional type checking) | PROP-004 errata E5 | 3 | medium |
| PROP-029 | Plastic Runtime Cells (ownership + migration) | PROP-006, PROP-012 | 3 | medium |
| PROP-030 | Rule synthesis via LP (goal-directed) | PROP-022, PROP-025 | 4 | low |

---

## Proposal Lifecycle

```text
authored -> proposal -> Architect review -> approved | rejected | redirect
```

Approved proposals may become:

- a new track (`docs/tracks/`)
- an experiment (`docs/experiments/`)
- a bridge note (`docs/bridge/`)
- an implementation candidate

---

## Key Meta-Corrections (from META-001)

These are corrections to existing tracks that should be reviewed before
new tracks are authored:

1. **Law 3 / Law 6 tension** — Restate Law 3 as: "The default core is a
   finite, stratified dependency graph, *parameterized over an explicit
   temporal context Tt*. Each evaluation at a fixed Tt is a closed
   computation." (PROP-001 formalizes this.)

2. **Observation envelope field categories** — Separate required fields
   into Identity / Provenance / Policy groups. Two packets are the "same
   observation" iff their identity fields agree. (PROP-001 §6.)

3. **Two-dimensional failure status** — `degraded` and `failed` are
   orthogonal. Replace flat `status` with
   `computation_status x service_level`. (PROP-001 §7.)

4. **Reason code openness** — The closed core reason codes must be
   formally distinguished from open platform extensions. Platform
   extensions are advisory; they cannot change core failure semantics.
   (META-001.)
