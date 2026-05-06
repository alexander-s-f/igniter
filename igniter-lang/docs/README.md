# Igniter-Lang Research Index

Status: active research index

## Claim

Igniter-Lang should be explored as a separate language ecosystem, not as an
implementation detail of the current Igniter platform.

## Active Tracks

| Track | Status | Purpose |
|------|--------|---------|
| [tracks/observable-contract-language-v0.md](tracks/observable-contract-language-v0.md) | proposal | Completed first axiom slice for "everything observable, everything contract" |
| [tracks/observable-spine-v0.md](tracks/observable-spine-v0.md) | proposal | Completed minimal observation envelope and packet-kind spine |
| [tracks/failure-observation-v0.md](tracks/failure-observation-v0.md) | proposal | Completed structured failure packet model over the observation spine |
| [tracks/semantic-domain-reconciliation-v0.md](tracks/semantic-domain-reconciliation-v0.md) | done | Reconciled practical tracks with META-001 and PROP-001 formal corrections |
| [tracks/track-errata-application-v0.md](tracks/track-errata-application-v0.md) | done | Applied compact formal errata to completed practical tracks |
| [tracks/temporal-contracts-and-projections-v0.md](tracks/temporal-contracts-and-projections-v0.md) | done | Defined named slices, projection horizons, live/reproducible projections, and action semantics |
| [tracks/runtime-contracts-and-execution-environments-v0.md](tracks/runtime-contracts-and-execution-environments-v0.md) | done | Defined runtime contracts, execution environments, guarantees, and result meaning status |
| [tracks/bridge-observation-envelope-runtime-evidence-v0.md](tracks/bridge-observation-envelope-runtime-evidence-v0.md) | done | Extended bridge vocabulary with runtime evidence, meaning status, and runtime links |
| [tracks/bridge-observation-envelope-package-mapping-v0.md](tracks/bridge-observation-envelope-package-mapping-v0.md) | done | Mapped current package facts, projections, pins, decisions, and runtime session packets to bridge profiles |
| [tracks/runtime-machine-lifecycle-v0.md](tracks/runtime-machine-lifecycle-v0.md) | done | Defined Runtime Machine boot/load/evaluate/checkpoint/resume lifecycle, semantic image, TBackend adapters, compatibility, and CORE/ESCAPE boundary |
| [tracks/runtime-machine-executable-proof-plan-v0.md](tracks/runtime-machine-executable-proof-plan-v0.md) | done | Planned the minimal executable proof for :memory TBackend boot/load/evaluate/checkpoint/resume on a toy CORE contract |
| [tracks/runtime-machine-proof-packet-fixtures-v0.md](tracks/runtime-machine-proof-packet-fixtures-v0.md) | done | Extracted structural golden ObsPacket, SemanticImage, CompatibilityReport, negative evidence, and result summary artifacts from the memory proof |
| [tracks/runtime-machine-proof-packet-builder-check-v0.md](tracks/runtime-machine-proof-packet-builder-check-v0.md) | done | Added a standalone structural checker for memory proof golden artifacts and candidate packet-builder outputs |
| [tracks/runtime-machine-proof-sidecar-builder-profiles-v0.md](tracks/runtime-machine-proof-sidecar-builder-profiles-v0.md) | done | Added standalone sidecar profiles that emit candidate fixture directories accepted by the packet-builder checker |
| [tracks/runtime-machine-proof-sidecar-profile-modes-v0.md](tracks/runtime-machine-proof-sidecar-profile-modes-v0.md) | done | Defined full-log and selected-profile comparison modes for sidecar candidate artifacts |
| [tracks/runtime-machine-external-candidate-and-ffi-proof-v0.md](tracks/runtime-machine-external-candidate-and-ffi-proof-v0.md) | done | Defined selected-profile admission rules for external candidates and Ruby FFI as contractable ESCAPE proof |
| [tracks/runtime-machine-external-candidate-normalizer-fixtures-v0.md](tracks/runtime-machine-external-candidate-normalizer-fixtures-v0.md) | done | Added a standalone raw external candidate normalizer fixture that emits selected-profile artifacts and passes the checker |
| [tracks/add-igapp-devkit-fixture-v0.md](tracks/add-igapp-devkit-fixture-v0.md) | done | Defined the first hand-authored `.igapp/` artifact and RuntimeMachine load/evaluate/checkpoint proof target |
| [tracks/ffi-ruby-contractable-proof-v0.md](tracks/ffi-ruby-contractable-proof-v0.md) | done | Proved Ruby host calls as ESCAPE contracts: FFIRequirement, CapabilityGate, call discipline (intent→check→call→receipt/failure), evidence links |
| [tracks/runtime-machine-ffi-ruby-receipt-fixtures-v0.md](tracks/runtime-machine-ffi-ruby-receipt-fixtures-v0.md) | done | Added executable FFI read/write/failure golden receipt fixtures and checker coverage |
| [tracks/runtime-machine-schema-check-standalone-fix-v0.md](tracks/runtime-machine-schema-check-standalone-fix-v0.md) | done | Restored standalone RuntimeMachine proof by moving schema_check to loaded_schema_descriptor and adding trusted/provisional schema checks |
| [tracks/runtime-machine-schema-migration-fixture-v0.md](tracks/runtime-machine-schema-migration-fixture-v0.md) | done | Added standalone schema_check:migrating fixture with MigrationDescriptor, intent, and audit receipt evidence |
| [tracks/source-fixture-parser-acceptance-harness-v0.md](tracks/source-fixture-parser-acceptance-harness-v0.md) | partial | Started source fixture parser harness: `.ig` source fixtures parse to ParsedProgram JSON; `.igapp` comparison still pending |
| [tracks/polymorphic-add-devkit-fixture-v0.md](tracks/polymorphic-add-devkit-fixture-v0.md) | done | Added polymorphic Add pressure fixture with expected ParsedProgram shape, specialization rules, and no runtime overloads |
| [tracks/polymorphic-add-parser-pressure-map-v0.md](tracks/polymorphic-add-parser-pressure-map-v0.md) | done | Grammar/parser delta map for PROP-016 surface: trait, impl, contract_shape, generic contract header; separated parser vs semantic vs monomorphization work |
| [tracks/bridge-observation-envelope-implementation-plan-v0.md](tracks/bridge-observation-envelope-implementation-plan-v0.md) | done | Planned metadata-only packet builders for RuntimeMachine, TBackendAdapter, SemanticImage, Checkpoint, Resume, and CompatibilityReport |
| [tracks/temporal-lifecycle-application-scenarios-v0.md](tracks/temporal-lifecycle-application-scenarios-v0.md) | done | Pressure-tested temporal lifecycle, retention, flush, semantic GC, boundaries, and reproducibility with Spark CRM technician dispatch |
| [tracks/temporal-lifecycle-boundary-fixtures-v0.md](tracks/temporal-lifecycle-boundary-fixtures-v0.md) | done | Defined concrete GeoSignal-to-boundary fixtures for snapshots, compacted stubs, audit trails, and downgrade/block cases |

## Active Experiments

| Experiment | Status | Purpose |
|------------|--------|---------|
| [../experiments/runtime_machine_memory_proof/README.md](../experiments/runtime_machine_memory_proof/README.md) | done | runtime-machine-schema-migration-fixture-v0: standalone memory proof, golden fixtures, checker, sidecar profiles, profile modes, external candidate normalizer, FFI receipt fixtures, PROP-017 schema checks, and migration evidence |
| [../experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb](../experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb) | done | FFI Ruby receipt/failure fixture generator and checker |
| [../experiments/parser/igniter_lang_parser.rb](../experiments/parser/igniter_lang_parser.rb) | partial | Minimal recursive-descent parser for PROP-014/015 source fixtures; emits ParsedProgram JSON |

## Active Proposals

See [proposals/README.md](proposals/README.md) for the full index.

| Proposal | Status | Author | Summary |
|----------|--------|--------|---------|
| [proposals/META-001](proposals/META-001-compiler-grammar-expert-entry.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Entry assessment + meta-corrections to existing tracks |
| [proposals/PROP-001](proposals/PROP-001-semantic-domain-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantic domain: V, T, Tt, C, Expr, O, F |
| [proposals/PROP-002](proposals/PROP-002-contract-composition-algebra-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Contract composition: >>, \|\|, branch, over, embed — algebraic laws + closure theorem |
| [proposals/PROP-003](proposals/PROP-003-grammar-fragment-classification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Fragment classification: CORE / ESCAPE / OOF; Pass 0 compiler; DSL keyword mapping |
| [proposals/PROP-004](proposals/PROP-004-type-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Structural types, temporal capabilities, Projection[T,horizon], Obs[kind,T], soundness |
| [proposals/PROP-005](proposals/PROP-005-bridge-observation-envelope-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal envelope: ObsPacket[kind,T], Identity/Provenance/Policy, Option[T] payload, package mappings |
| [proposals/PROP-004b](proposals/PROP-004b-axiom-layer-type-signatures-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Three-tier axiom stack: language built-ins, runtime contracts, platform observations |
| [proposals/PROP-006](proposals/PROP-006-runtime-contract-specification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | RuntimeContract: scheduler, clock, cache, storage, capability, distributed ESCAPE; conformance |
| [proposals/PROP-007](proposals/PROP-007-conformance-verification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Conformance verification: 5 check suites, trust levels, agent trust decision procedure |
| [proposals/PROP-008](proposals/PROP-008-tbackend-contract-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | TBackend[T]: read/append/replay/snapshot/compact/subscribe; reproducible resume; adapter classes |
| [proposals/PROP-009](proposals/PROP-009-semantic-image-resume-compatibility-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | SemanticImage; CompatibilityReport; ResumeStatus: trusted/provisional/downgraded/blocked |
| [proposals/PROP-010](proposals/PROP-010-temporal-lifecycle-retention-semantics-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | 6 lifecycle classes; flush; semantic GC roots; 5 downgrade rules (DR-1..DR-5); retention matrix |
| [proposals/PROP-011](proposals/PROP-011-runtime-machine-lifecycle-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Runtime Machine: boot/load/evaluate/checkpoint/resume — typed lifecycle using PROP-006..PROP-010 |
| [proposals/PROP-012](proposals/PROP-012-compilation-artifact-deployment-model-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | CompiledProgram; 4 compiler stages; SemanticIR; artifact hash; 4 deployment modes; contractable FFI |
| [proposals/PROP-013](proposals/PROP-013-stdlib-fold-aggregate-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Collection[T], Option[T], Result[T,E]; fold/map/filter/group_by/avg; TR-1 termination; aggregated_from links |
| [proposals/PROP-014](proposals/PROP-014-source-syntax-semanticir-boundary-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Minimal syntax kernel; ParsedProgram shape; 4-stage path to SemanticIR; OOF rejection rules; .igapp/ mapping |
| [proposals/PROP-015](proposals/PROP-015-grammar-module-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | def blocks (pure/non-recursive/inlined); TypeDecl (structural records); module/import; full v0 BNF; Add + Availability source files |
| [proposals/PROP-016](proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Generic contracts; traits (compile-time); impl coherence; contract_shape; implements structural; monomorphization; compile-time overload only; no unresolved overloads in SemanticIR |
| [proposals/PROP-017](proposals/PROP-017-schema-evolution-contract-migration-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | SemVer; schema_fingerprint; 5 safe/7 breaking changes; schema_check (4th CompatibilityReport dim); MigrationDecl ESCAPE+audit+replaces; OOF-S1..S5 |

## Core Documents

| File | Purpose |
|------|---------|
| [../roles/README.md](../roles/README.md) | Role passports and neighbor map for Igniter-Lang agents |
| [ecosystem-split-proposal.md](ecosystem-split-proposal.md) | Defines the Igniter vs Igniter-Lang split |
| [research-process.md](research-process.md) | Research lifecycle, document rotation, handoff protocol |
| [agent-motion.md](agent-motion.md) | Current multi-agent movement and handoff routing |
| [temporal-positioning.md](temporal-positioning.md) | Meta thesis: time, contracts, projections, and language positioning |
| [temporal-lifecycle.md](temporal-lifecycle.md) | Meta thesis: lifecycle classes for T, flush, semantic GC, retention, and boundary compaction |
| [axiomatic-contract-model.md](axiomatic-contract-model.md) | Meta thesis: language, runtime, distributed execution, and time as contract boundaries |
| [runtime-machine.md](runtime-machine.md) | Meta thesis: Runtime Machine lifecycle, TBackend, semantic image, and resume model |
| [compilation-deployment.md](compilation-deployment.md) | Meta thesis: compilation artifacts, deployment modes, native backend path, and contractable FFI |
| [current-status.md](current-status.md) | Compact fixed point for the current round: theory, devkit proof, fixtures, gaps, and next slices |
| [language-position-report.md](language-position-report.md) | Meta thesis: language position, ECL paradigm, 7 blind spots, 7 insights, strategic assessment |
| [runtime-model-spec-questions-v0.md](runtime-model-spec-questions-v0.md) | Forward spec: variables (single-assignment), scoping (lexical 3-level), memory (value semantics/region), GC (evaluation+semantic), parallelism (structural DAG), self-hosting (Stage 0→5) |

## Research Vectors

- Observable Contract Language
- Everything Is Contract
- Organic Axiom Layer
- Agent-Friendly Language
- Temporal Contract Semantics
- Projections / Slices / As-Of Views
- Contract Synthesis
- Igniter Bridge
- Formal Semantic Domain (PROP-001)
- Contract Composition Algebra (PROP-002)
- Grammar Fragment Classification (PROP-003)
- Type System v0 (PROP-004)
- Temporal Contract Semantics (PROP-004 + temporal-positioning.md)
- Projections / Slices / As-Of Views (Projection[T, horizon] — PROP-004)
- Bridge Observation Envelope (PROP-005)
- Axiom Layer Type Signatures (PROP-004b)
- Runtime Contract Specification (PROP-006)
- Conformance Verification (PROP-007)
- TBackend Contract (PROP-008)
- Semantic Image and Resume Compatibility (PROP-009)
- Temporal Lifecycle and Retention Semantics (PROP-010)
- Runtime Machine Lifecycle (PROP-011)
- Runtime Machine Executable Proof Plan (Research Agent track)
- Runtime Machine Memory Proof (Experiment)
- Runtime Machine Proof Packet Fixtures (Research Agent track)
- Runtime Machine Proof Packet Builder Check (Research Agent track)
- Runtime Machine Proof Sidecar Builder Profiles (Research Agent track)
- Runtime Machine Proof Sidecar Profile Modes (Research Agent track)
- Runtime Machine External Candidate and FFI Proof (Research Agent track)
- Runtime Machine External Candidate Normalizer Fixtures (Research Agent track)
- Runtime Machine Schema Check Standalone Fix (Research Agent track)
- Runtime Machine Schema Migration Fixture (Research Agent track)
- Add.igapp Devkit Fixture (Compiler/Grammar Expert track)
- Compilation and Deployment (compilation-deployment.md)
- Temporal Lifecycle (temporal-lifecycle.md)
- Runtime Machine Lifecycle (PROP-011)
- Compilation Artifact and Deployment Model (PROP-012)
- Igniter-Lang Position Report (language-position-report.md)
- Temporal Lifecycle (temporal-lifecycle.md)
- Axiomatic Contract Model (axiomatic-contract-model.md)
- Runtime Machine (runtime-machine.md)
- Compilation and Deployment (compilation-deployment.md)
- stdlib v0 (PROP-013: Collection, Option, Result, fold, temporal primitives)
- Source Syntax to SemanticIR Boundary (PROP-014: minimal grammar kernel)
- Grammar and Module System (PROP-015: def, TypeDecl, module/import, full v0 BNF)
- Parser Acceptance Harness (DONE — add.ig + availability_projection.ig → ParsedProgram, 61 specs)
- Polymorphic Add Devkit Fixture (DONE — trait/impl/contract_shape pressure fixture, monomorphic SemanticIR specializations, no unresolved RuntimeMachine overloads)
- FFI Ruby Contractable Proof (DONE — CapabilityGate + call discipline, 36 specs)
- ESCAPE Capability Algebra (QUEUED — proposal ID TBD)
- Contract Schema Evolution and Migration (QUEUED — PROP-017)
- Pattern Matching and Generics (QUEUED — post-PROP-016)
- Runtime Machine FFI Ruby Receipt Fixtures (QUEUED — research track)

## Experiments and Source Files

```text
igniter-lang/experiments/parser/
  igniter_lang_parser.rb     <- Lexer + recursive-descent Parser (PROP-014/015 grammar kernel)

igniter-lang/experiments/runtime_machine_memory_proof/
  runtime_machine_memory_proof.rb <- standalone RuntimeMachine proof with schema_check
  compiled_program.rb       <- .igapp loader extension that supplies schema_descriptor
  ffi_ruby_proof.rb         <- FFIRequirement, CapabilityGate, FFIAdapter (PROP-012 §FFI)

igniter-lang/source/
  add.ig                     <- canonical CORE source (module Lang.Examples.Add)
  availability_projection.ig <- ESCAPE source with window/defs/TBackend reads
  polymorphic_add.ig         <- polymorphic Add pressure fixture, not current parser acceptance
  polymorphic_add.parsed_program.expected.json <- expected future ParsedProgram shape

spec/igniter/
  parser_acceptance_spec.rb     <- 61 acceptance tests (ParsedProgram -> fixture compare path)
  ffi_ruby_contractable_spec.rb <- 36 FFI call-discipline tests
  add_igapp_devkit_spec.rb      <- 32 Add devkit tests
  availability_projection_igapp_spec.rb <- 29 window lifecycle tests
Total: 158 examples, 0 failures
```

## Review Cadence

The research agent should produce compact completed slices. `[Architect
Supervisor / Codex]` periodically reviews a complete slice and then either:

- approves the direction
- narrows the next experiment
- rejects a branch
- requests a bridge note back to Igniter platform

## Handoff Format

Use the template in [../handoff/HANDOFF_TEMPLATE.md](../handoff/HANDOFF_TEMPLATE.md).
