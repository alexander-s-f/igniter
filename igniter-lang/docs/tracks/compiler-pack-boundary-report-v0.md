# Track: Compiler Pack Boundary Report v0

Card: S3-R31-C7-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-pack-boundary-report-v0`
Status: done
Date: 2026-05-10

---

## Goal

Prove a candidate pack decomposition for the future profile-assembled
`igniter-lang` compiler without implementing `CompilerKernel`, changing compiler
implementation, changing `.igapp` format, or authorizing migration.

---

## R90 Update: Compiler Mainline Pack Boundary Report

Card: S3-R90-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Status: done
Date: 2026-05-20

This section is the current mainline boundary report authorized by
`docs/gates/compiler-mainline-next-axis-decision-v0.md`. The original S3-R31
report remains below as historical foundation. R90 does not edit code, Ch6, or
other specs, and does not authorize implementation.

S3-R90-C0-O selected this exact report path and write scope:

```text
igniter-lang/docs/tracks/compiler-pack-boundary-report-v0.md
```

It also selected historical handling: preserve the S3-R31 foundation body and
use the R90 section as the current addendum.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: proof fixture ownership and regression
  matrix follow-up.
- `[Igniter-Lang Implementation Agent]`: future implementation boundaries only;
  no implementation is opened here.
- `[Igniter-Lang Bridge Agent]`: loader/report/API surfaces remain closed.

### R90 Sources Read

- `docs/org/tracks/compiler-pack-boundary-report-r90-file-boundary-v0.md`
- `docs/gates/compiler-mainline-next-axis-decision-v0.md`
- `docs/tracks/stage3-round89-status-curation-v0.md`
- `docs/org/tracks/compiler-mainline-reentry-boundary-map-v0.md`
- `docs/tracks/compiler-mainline-next-axis-options-v0.md`
- `docs/tracks/compiler-mainline-touchpoint-and-proof-gap-survey-v0.md`
- `docs/discussions/compiler-mainline-next-axis-pressure-v0.md`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md`
- `docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`
- `docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`
- Current compiler files read only:
  - `lib/igniter_lang/compiler_orchestrator.rb`
  - `lib/igniter_lang/compiler_result.rb`
  - `lib/igniter_lang/compilation_report.rb`
  - `lib/igniter_lang/compiler_profile_contract_validator.rb`
  - `lib/igniter_lang/parser.rb`
  - `lib/igniter_lang/classifier.rb`
  - `lib/igniter_lang/typechecker.rb`
  - `lib/igniter_lang/semanticir_emitter.rb`
  - `lib/igniter_lang/assembler.rb`
- Proof fixture inventory under `experiments/`, read only.

### R90 Current Compiler Mainline Shape

The current compiler is still a monolithic proof compiler with a profile
evidence side-channel:

```text
CompilerOrchestrator
  Parser
  Classifier
  TypeChecker
  SemanticIREmitter.emit_typed
  CompilationReport.enrich
  optional compiler_profile_contract_validation report-only annotation
  optional internal-only strict terminal
  Assembler
```

Important accepted boundaries:

- `compiler_profile_source` is facade/CLI transport to the assembler; it is not
  a strict source and does not authorize dispatch migration.
- `compiler_profile_contract_validation` is nested report-only evidence on
  successful compile reports.
- The strict terminal path is internal-only, non-persisting, skips assembly, and
  does not write sidecars, `.igapp`, or compilation reports.
- `compile_refusal_authorized: false` remains part of nested validation
  evidence.
- `report.pass_result == "ok"` remains invariant for strict terminal paths.
- The validator is evidence; the orchestrator-level strict requirement decision
  is the authority for the accepted internal strict path.

Spark applied-pressure material is not compiler authority for this report.

### R89 Acceptance Bar And Hold Triggers Preserved

This R90 report satisfies the R89 acceptance bar only if it remains:

- descriptive and no-code;
- accurate against current compiler/profile evidence;
- explicit about Spark/compiler lane separation;
- clear about pass, fragment, OOF, proof, report-only, and strict terminal
  responsibilities;
- explicit about migration risks and `must_not_migrate_yet`;
- protective of all closed surfaces.

Hold or redirect any follow-up that implies or starts:

- live pack dispatch;
- pack registry implementation;
- parser/classifier/TypeChecker/SemanticIR/assembler rewrites;
- public profile input or public strict source;
- public API/CLI widening;
- `.igapp` or golden migration;
- loader/report or CompatibilityReport authority;
- RuntimeMachine/Gate 3 or runtime authority;
- Ledger/TBackend, cache, signing, or production behavior;
- Spark fixture/spec work as compiler authority.

### Pack Boundary Table

| Candidate boundary | Current files / evidence | Candidate owned surface | Current status | R90 boundary decision |
|---|---|---|---|---|
| `CoreLanguagePack` | `parser.rb`, `classifier.rb`, `typechecker.rb`, `semanticir_emitter.rb`, `assembler.rb`, `source_to_semanticir_fixture`, `production_compiler_cli` | Module/contract envelope, type declarations, core input/compute/output, literals, refs, field access, base SemanticIR and `.igapp` artifacts | Implemented as monolith | Candidate baseline pack only; do not split or dispatch yet. |
| `OOFRegistryPack` | Parser/classifier/typechecker hardcoded diagnostics; proof goldens; `compilation_report` diagnostics | OOF descriptor registry, owner/stage metadata, stable public codes | Data not centralized | Candidate support boundary; first proof should be shadow registry only. |
| `FragmentRegistryPack` | Classifier fragment assignment, SemanticIR/assembler fragment summaries, PROP-028/032 | Fragment vocabulary, precedence, max-fragment policy | Partly implemented and partly proposal-bound | Candidate support boundary; no independent pack computes max class yet. |
| `EscapeBoundaryPack` | `read`/`escape_boundaries` in classifier/typechecker/emitter/assembler; `requirements.json` proofs | External read metadata, requirements from escape boundaries, non-temporal read handling | Implemented as shared monolith behavior | Candidate baseline-adjacent pack; must not imply runtime authority. |
| `TemporalPack` | `history_type_proof`, `temporal_semanticir_access_node`, `temporal_assembler_boundary`, runtime load guard proofs | `History[T]`, `BiHistory[T]`, temporal access nodes, axes, temporal metadata, requirements and compatibility metadata | Compiler boundary implemented; runtime live reads guarded/closed | Candidate optional pack; metadata/runtime guard variants must stay separate. |
| `StreamPack` | `stream_t_proof`, `classifier_pass_proof`, stream source fixtures, stream SemanticIR goldens | `stream`, `window`, `fold_stream`, stream input/fold nodes, OOF-S family | Compiler/proof surface implemented; production ingress closed | Candidate optional pack; do not migrate TBackend/read-inside-fold or production runner. |
| `OLAPPack` | `olap_point_proof`, runtime smoke OLAP fixture, SemanticIR OLAP nodes | `OLAPPoint`, dimensions, measures, `olap_point_decl`, `olap_access_node`, `dims_record` | Compiler/proof boundary implemented; distributed OLAP closed | Candidate optional pack; no scatter/gather or executor implication. |
| `InvariantPack` | `invariant_severity_proof`, typechecker/source fixtures, SemanticIR invariant lowering | Invariant declarations, severity/message/source metadata, violation nodes, TINV/PINV diagnostics | Compiler/proof boundary implemented | Candidate optional pack; runtime/report violation enforcement remains separate. |
| `ContractModifiersPack` | `contract_modifiers_proof`, `contract_modifiers_pack_native_boundary` | `pure`, `observed`, `effect`, `privileged`, `irreversible`, modifier propagation, OOF-M1 | Implemented compiler boundary | Good first optional extraction candidate after shadow profile because blast radius is small. |
| `AssumptionsPack` | `assumptions_proof`, source-to-SemanticIR assumption fixture, PROP-032 accepted path | `assumptions {}`, `uses assumptions`, registry, refs, `epistemic` fragment, OOF-A1/TASSUMP-1 | Implemented through parser/source/SemanticIR proof path | Candidate optional pack; PROP-033 evidence-list validation remains out of scope. |
| `EvidenceObservationPack` | `classifier_pass_proof`, `source_to_semanticir_fixture`, evidence linked alert / confidence fixtures | Evidence and observation diagnostics, confidence misuse, alert evidence gates | Implemented as cross-cutting checks | Candidate optional/support pack; open whether to split evidence vs observation later. |
| `PipelinePack` | Parser OOF hardening proofs, pipeline fixtures, PROP-037 progression pressure under `pipeline` slot | Pipeline syntax pressure, parser gates, progression descriptor metadata slot for v0 | Parser/proof pressure only; no scheduler | Candidate future boundary; do not treat progression as a new fragment class in v0. |
| `CompilerProfileContractPack` | PROP-036/038 docs, `compiler_profile_contract_validator.rb`, `compilation_report.rb`, strict terminal proofs | Profile source transport, contract validation evidence, digest policy, strict terminal wrapper diagnostics | Live internal report-only and strict-terminal foundation accepted | Support boundary, not language pack; validator evidence is not authority. |

### Pass / Owner Map

| Pass / boundary | Current owner files | Candidate future owner | Notes |
|---|---|---|---|
| Parse | `parser.rb` | `CoreLanguagePack` plus optional parser rule contributors | Parser precedence is high risk; no pack rule dispatch is authorized. |
| Classify | `classifier.rb` | `CoreLanguagePack`, `OOFRegistryPack`, `FragmentRegistryPack`, optional pack classifiers | Owns many current OOF decisions including stream, modifiers, assumptions, evidence. |
| Typecheck | `typechecker.rb` | `CoreLanguagePack` plus optional type rule contributors | Owns temporal axes, stream fold body checks, OLAP, invariants, assumptions propagation. |
| SemanticIR lowering | `semanticir_emitter.rb` | `CoreLanguagePack` plus optional lowering contributors | JSON shape drift is critical; any migration needs byte-for-byte golden parity first. |
| Report enrichment | `compilation_report.rb`, `diagnostics.rb` | Compiler report support boundary | Nested profile validation evidence must remain isolated from top-level diagnostics. |
| Profile contract validation | `compiler_profile_contract_validator.rb` | `CompilerProfileContractPack` support boundary | Evidence only; refusal authority remains orchestrator strict requirement path. |
| Strict terminal | `compiler_orchestrator.rb`, `compiler_result.rb` | Orchestrator/status boundary, not pack validator | Internal-only; non-persisting; exact public key-set must be preserved. |
| Assembly | `assembler.rb` and profile id assembler helpers/proofs | `CoreLanguagePack` assembler plus constrained pack artifact hooks | `report_for_assembly` currently receives pre-profile-validation report; preserve until explicit authorization. |
| Runtime smoke | `compiler_orchestrator.rb` callback | Runtime proof harness | Not a compiler pack ownership source. |
| Public API / CLI | `lib/igniter_lang.rb`, CLI proof files | Closed for strict source | Only `compiler_profile_source` transport is open today; no public strict requirement. |

### OOF / Diagnostic Ownership Map

| Code family | Candidate owner | Current layer | R90 note |
|---|---|---|---|
| `OOF-P0`, `OOF-P1`, `OOF-P2`, `OOF-P28`, `OOF-TY0` | `CoreLanguagePack` / `OOFRegistryPack` | Parser/emitter/typechecker | Keep public code stability before registry migration. |
| `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5` | `PipelinePack` | Parser | Pipeline remains future/profile pressure, not scheduler authority. |
| `OOF-DM3` | `CoreLanguagePack` or future numeric type support | Parser | Do not create a new pack unless numeric surface expands. |
| `OOF-H*`, `OOF-BT*`, `OOF-TM*` | `TemporalPack` | Classifier/typechecker/assembler guard proofs | `History[T]` / `BiHistory[T]` compile semantics stay separate from live reads. |
| `OOF-S1`..`OOF-S5` | `StreamPack` | Parser/classifier/typechecker | Preserve SC-1/2/3 and OOF-S3 TypeChecker ownership. |
| `OOF-O1`..`OOF-O5` | `OLAPPack` | Parser/typechecker | Distributed OLAP and executor behavior remain closed. |
| `PINV-*`, `TINV-*`, `OOF-IV*`, `OOF-I*` | `InvariantPack` | Parser/typechecker/emitter | Runtime violation reporting is not opened by pack ownership. |
| `OOF-M1` | `ContractModifiersPack` | Classifier/typechecker | Strong candidate for first optional extraction proof after shadow profile. |
| `OOF-A1`, `TASSUMP-1` | `AssumptionsPack` | Classifier/typechecker/emitter | PROP-033 evidence-list validation remains excluded. |
| `OOF-CE4`, `OOF-OS2`, `OOF-OS4` | `EvidenceObservationPack` | Classifier/typechecker/emitter | Ownership should be clarified before observation/evidence split. |
| `OOF-PR*` | Progression design, not compiler pack authority | Descriptor proof only | Do not use PROP-037 progression OOFs to authorize compiler pack migration. |
| `compiler_profile_contract.*` | `CompilerProfileContractPack` support boundary | Validator nested diagnostics | Not OOF; nested under `compiler_profile_contract_validation.diagnostics`. |
| `compiler_profile_contract_refusal.*` | Orchestrator strict terminal boundary | `CompilerResult.strict_terminal` diagnostics | Wrapper diagnostics for internal strict terminal only. |

### Fragment Ownership Map

| Fragment class / state | Candidate owner | Current evidence | R90 disposition |
|---|---|---|---|
| `core` | `CoreLanguagePack` | Base contracts and CORE-typed temporal read values | Stable baseline. |
| `escape` | `EscapeBoundaryPack` | External reads, requirements, coarse external-boundary behavior | Keep as coarse class until FragmentRegistry proof resolves precedence. |
| `temporal` | `TemporalPack` | PROP-028, History/BiHistory classifier/typechecker/SemanticIR/assembler proofs | Stable node/contract fragment; value remains CORE-typed. |
| `stream` | `StreamPack` | Stream proofs and SemanticIR lowering | Stable candidate, but ingress/external boundary interplay needs registry proof. |
| `epistemic` | `AssumptionsPack` | PROP-032 assumptions proof and SemanticIR lowering | Implemented surface; keep evidence-list validation closed. |
| `oof` | `OOFRegistryPack` / report status boundary | OOF blocks SemanticIR and assembly | Treat as status/fragment marker until registry proof fixes vocabulary. |
| `olap` | `OLAPPack` candidate | OLAP nodes and OOFs, no production executor | Do not promote to fragment class without separate decision. |
| `progression` | None in v0 | PROP-037 keeps progression metadata under `pipeline` | No new PROGRESSION fragment class. |

### Proof Fixture Map

| Boundary | Existing proof / fixture evidence | Suggested owner |
|---|---|---|
| Core parse/classify/typecheck/emit | `classifier_pass_proof`, `typechecker_proof`, `source_to_semanticir_fixture`, `production_compiler_cli`, `stage1_close_candidate`, `stage2_close_candidate` | `CoreLanguagePack` plus support registries |
| Parser OOF hardening / pipeline gates | `parser_oof_hardening_stage2_proof` | `PipelinePack` / `CoreLanguagePack` |
| Temporal compiler boundary | `history_type_proof`, `temporal_semanticir_access_node`, `temporal_assembler_boundary`, `temporal_requirements_from_escape_boundaries`, `temporal_cache_key_proof` | `TemporalPack` |
| Temporal runtime/load guard separation | `temporal_runtime_load_guard`, `runtime_compatibility_report_temporal_load_check`, `temporal_executor_lib_prep`, `temporal_scope_exclusion_runtime_fixture`, `temporal_read_observation_proof` | Runtime/Bridge lane, not compiler pack authority |
| Stream | `stream_t_proof`, stream classifier/source fixtures | `StreamPack` |
| OLAP | `olap_point_proof`, runtime smoke OLAP artifact fixture | `OLAPPack` |
| Invariants | `invariant_severity_proof` | `InvariantPack` |
| Contract modifiers | `contract_modifiers_proof`, `contract_modifiers_pack_native_boundary` | `ContractModifiersPack` |
| Assumptions | `assumptions_proof`, assumption source-to-SemanticIR fixture | `AssumptionsPack` |
| Assembly / `.igapp` | `igapp_assembler_proof`, `temporal_assembler_boundary`, `production_compiler_cli` | Core assembler plus constrained pack hooks |
| PROP-036 profile source/id | `minimal_compiler_profile_finalization_proof`, `assembler_compiler_profile_id_field`, `prop036_artifact_hash_ordering_proof`, `prop036_loader_status_report_proof`, `prop036_cli_profile_source_b3_b6_implementation_proof`, `prop036_ruby_facade_profile_source_exposure` | Profile source / assembler identity boundary |
| PROP-038 contract validation | `compiler_profile_obligation_coverage_proof`, `compiler_profile_contract_proof`, validator coverage proofs, `prop038_report_only_compiler_integration`, digest shape/recompute/report-only proofs | `CompilerProfileContractPack` support boundary |
| PROP-038 strict terminal | `prop038_strict_mode_refusal_trigger_proof`, `prop038_strict_refusal_result_shape_proof`, accepted R84 live internal implementation evidence | Orchestrator/status boundary |
| Progression descriptor | `prop037_descriptor_oof_pr` and descriptor shape proofs | Future `PipelinePack` pressure only |

### Migration Risk Table

| Risk | Severity | Current pressure | Mitigation before migration |
|---|---:|---|---|
| Parser precedence drift | Critical | Optional parser rules across stream, OLAP, assumptions, invariants, modifiers | Shadow rule registry with conflict detection and byte-for-byte parse golden parity. |
| Fragment precedence drift | Critical | `temporal`, `stream`, `escape`, `epistemic`, `oof` coexist with mixed ownership | Central FragmentRegistry proof before any pack computes contract class. |
| OOF public-code drift | High | Diagnostics are asserted by proof goldens and status packets | OOF descriptor registry proof with owner/stage aliases and unchanged reports. |
| Type environment coupling | High | Temporal, stream, OLAP, invariants, assumptions all share env and refs | Typed accumulator protocol design before pack-local type handlers. |
| SemanticIR JSON drift | Critical | `.igapp`, source fixtures, assembler and runtime proofs depend on exact shapes | Byte-for-byte SemanticIR/CompilationReport/`.igapp` parity before dispatch. |
| Assembler report isolation leak | Critical | `report_for_assembly` currently excludes nested PROP-038 validation evidence | Preserve isolation until explicit assembly/report authority opens it. |
| Strict terminal authority leak | Critical | Validator emits evidence; orchestrator strict requirement decides terminal path | Never let validator diagnostics alone trigger live refusal. |
| Public result shape drift | High | `public_result` currently deny-removes `report`; strict terminal has exact key-set proofs | Require public key-set proof before any result/status refactor. |
| Loader/report inference | High | Compiler evidence could be mistaken for loader/report readiness | Keep CompatibilityReport and loader/report closed until separate route. |
| Runtime authority confusion | Critical | Pack names like Temporal/Stream/OLAP can sound executable | Separate compiler metadata, runtime capability, live executor, and production authority. |
| Spark lane contamination | Medium | Spark applied-pressure tracks are active nearby | Treat Spark only as pressure/specimen unless a compiler authority gate cites it. |
| Existing track history collision | Low | R31 used same filename | R90 updates this file with current section and retains R31 as historical baseline. |

### Ch6 / CompilationReport Spec-Lag Disposition

R90 records disposition only; it does not edit Ch6 or any spec chapter.

Ch6 / CompilationReport docs should later be synchronized to describe:

- nested `compiler_profile_contract_validation` evidence on successful reports;
- report-only invariants for PROP-038 validation diagnostics;
- `report_for_assembly` isolation from nested profile validation evidence;
- internal-only strict terminal behavior as non-persisting/no-sidecar/no-report/no-`.igapp`;
- distinction between ordinary persisted refusal reports and strict terminal
  wrapper diagnostics;
- `report.pass_result == "ok"` invariant for strict terminal paths;
- closed loader/report, CompatibilityReport, public API/CLI, runtime, and
  production surfaces.

Recommended future docs-only slice:
`ch6-compilation-report-profile-evidence-sync-v0`. It should be authorized
after this boundary report is accepted and before any public report/result
surface widening.

### Must Not Migrate Yet

- No `CompilerKernel` implementation.
- No live pack registry, pack dispatcher, or profile-assembled compiler.
- No parser, classifier, typechecker, SemanticIR, assembler, or orchestrator
  rewrite.
- No `.igapp` manifest/golden mutation from pack identity.
- No mandatory `compiler_profile_id` transition.
- No public API/CLI strict source.
- No loader/report or CompatibilityReport integration.
- No central `IgniterLang::Diagnostics` migration for PROP-038 diagnostics.
- No compile refusal widening beyond the accepted internal-only strict terminal
  foundation.
- No runtime, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory production
  evaluation, stream/OLAP executor, cache, signing, or production behavior.
- No progression scheduler, durable queue, checkpoint, or PROGRESSION fragment
  class.
- No Spark applied-pressure material as compiler authority.

### Recommended Later Proof / Design Slices

| Priority | Slice | Type | Purpose |
|---:|---|---|---|
| 1 | `compiler-pack-shadow-profile-proof-v1` | Proof-only | Refresh the existing shadow profile proof with current PROP-032 and R84/R86 accepted state; no dispatch. |
| 2 | `compiler-profile-slot-contract-map-v0` | Design/proof | Map pack slots to PROP-038 required/optional slot vocabulary and strict registries. |
| 3 | `oof-fragment-registry-shadow-proof-v0` | Proof-only | Freeze OOF descriptors and fragment precedence as data while preserving all goldens. |
| 4 | `prop038-strict-terminal-regression-hardening-v0` | Proof-only | Harden accepted strict terminal key-set, nested diagnostics, no-persistence, and success-path invariants. |
| 5 | `ch6-compilation-report-profile-evidence-sync-v0` | Docs-only | Close Ch6 / CompilationReport lag without changing behavior. |
| 6 | `contract-modifiers-pack-adapter-proof-v0` | Proof-only | First optional pack adapter candidate because its compiler surface is small and runtime risk is low. |
| 7 | `ordered-rule-contract-proof-v0` | Proof-only | Validate ordered rule graph before any pass registration or dispatch. |
| 8 | `compiler-profile-id-mandatory-transition-design-v0` | Design-only | Only after pack/profile report evidence is accepted; no `.igapp` mutation yet. |

### Closed Surfaces

This report leaves closed:

- code implementation;
- parser syntax changes;
- TypeChecker, SemanticIR, assembler, or RuntimeMachine behavior changes;
- pack dispatch or profile-assembled compiler migration;
- `.igapp`, goldens, manifest, loader/report, CompatibilityReport, and
  persisted report changes;
- public API/CLI profile or strict source widening;
- `CompilerResult` shape changes;
- production cache, signing, Ledger/TBackend, BiHistory production evaluation,
  stream/OLAP production execution, Gate 3, and runtime authority;
- Spark applied-pressure authority.

### R90 Recommendation

Accept the boundary report as a design map, not an implementation gate. The
next safest compiler route is `compiler-pack-shadow-profile-proof-v1`, with
`prop038-strict-terminal-regression-hardening-v0` as the backup if the team
wants to harden the accepted R84 foundation before touching pack registries.

---

## Sources Read

- `docs/agent-context.md`
- `docs/current-status.md`
- `docs/operating-model.md`
- `roles/research-agent.md`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/inbox/profile-baseline-pack-pattern-analysis.md`
- `docs/tracks/compiler-profile-architecture-direction-v0.md`
- `packages/igniter-contracts/lib/igniter/contracts/assembly/*.rb`
- `packages/igniter-contracts/lib/igniter/contracts/packs/*.rb`
- `packages/igniter-extensions/lib/igniter/extensions/*_pack.rb`
- `lib/igniter_lang/parser.rb`
- `lib/igniter_lang/classifier.rb`
- `lib/igniter_lang/typechecker.rb`
- `lib/igniter_lang/semanticir_emitter.rb`
- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `docs/proposals/PROP-022-history-type-constructor-v0.md`
- `docs/proposals/PROP-023-stream-input-surface-v0.md`
- `docs/proposals/PROP-024-olap-point-primitive-v0.md`
- `docs/proposals/PROP-025-invariant-severity-levels-v0.md`
- `docs/proposals/PROP-028-temporal-fragment-class-v0.md`
- `docs/proposals/PROP-031-contract-modifiers-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`

---

## Current Shape

The current compiler remains a proof compiler:

```text
CompilerOrchestrator
  Parser
  Classifier
  TypeChecker
  SemanticIREmitter.emit_typed
  Assembler
```

The profile-assembled target should not be a direct mechanical split of these
classes. The contracts assembly pattern shows the safer target:

```text
CompilerKernel
  installs CompilerPacks
  validates registries and dependencies
  freezes into CompilerProfile
CompilerEnvironment
  runs compiler passes using the profile
```

The pack boundary should therefore be capability-owned, not file-owned. A pack
owns grammar rules, classifier rules, type rules, SemanticIR lowering, assembler
hooks, OOF descriptors, and fragment-class contributions for one language
capability. The kernel owns ordering, duplicate-key checks, dependency checks,
profile fingerprinting, and frozen registry snapshots.

---

## Candidate Pack Map

| Candidate pack | Owned parser responsibilities | Owned classifier responsibilities | Owned typechecker / SemanticIR responsibilities | Owned assembler / profile responsibilities | OOF / fragment ownership | Dependencies / variants |
|---|---|---|---|---|---|---|
| `CoreLanguagePack` | Module envelope, type declarations, trait/impl/contract_shape, contract body basics, `input`, `compute`, `output`, literals, refs, field access, core calls/operators, basic type refs. | Core symbol table, dependency graph, unresolved symbol detection, core contract fragment default. | Primitive type IR, expression inference, output type checks, core compute/output nodes, typed report basics. | Base `.igapp` layout, `manifest.json`, `semantic_ir_program.json`, `compilation_report.json`, `requirements.json`, core contract files. | Owns `core`; owns base `oof` handling and generic `OOF-P0`, `OOF-P1`, `OOF-P2`, `OOF-TY0` unless superseded by a narrower pack. | Mandatory baseline. Variants: proof compiler adapter first, native pack later. |
| `OOFRegistryPack` | None directly; supplies parse-diagnostic schema. | Registers OOF descriptors and stage ownership. | Registers typecheck OOF descriptors and alias handling. | Allows reports/manifests to reference OOF metadata without hardcoded tables. | Owns the OOF descriptor registry and the `oof` fragment-class policy; individual packs own their codes. | Mandatory support pack, similar to diagnostics contributors in `igniter-contracts`. May be folded into `CoreLanguagePack` for first migration. |
| `FragmentRegistryPack` | None directly. | Supplies fragment vocabulary and precedence. | Supplies node/value/contract fragment validation. | Supplies fragment summary, max-fragment computation, and manifest fragment validation hooks. | Current/proposed classes: `core`, `escape`, `stream`, `temporal`, `epistemic`, `oof`. | Mandatory support pack. Must resolve PROP-028/PROP-032 precedence before native dispatch. |
| `EscapeBoundaryPack` | `escape`, `read`, lifecycle/scoped/cardinality/schema/tenant metadata. | Escape declaration classification and pure-contract interaction surface. | Read metadata passthrough, escape-boundary validation when not temporal. | Base requirements from `escape_boundaries`, capability/effect summaries. | Owns `escape` as the coarse external-boundary class; generic escape OOFs. | Depends on Core + FragmentRegistry. Variants: metadata-only, effect-surface-aware after later PROP. |
| `TemporalPack` | `History[T]`, `BiHistory[T]` type refs already parsed by generic type parser; future coordinate syntax remains pending. | Detect temporal reads; split node fragment `temporal` from bound value `core`; select `history_read` / `bihistory_read`. | `history_at`, `bihistory_at`, temporal axes, coordinate refs, temporal access nodes, cache-key contract metadata as proof information only. | Temporal contract index, temporal nodes, temporal requirements, compatibility guard metadata for inspection-only artifacts. | Owns `temporal`; owns `OOF-H1`, `OOF-H2`, `OOF-H3`, `OOF-H4`, `OOF-BT1`..`OOF-BT4`, compatibility aliases `OOF-TM1`, `OOF-TM3`..`OOF-TM6`. | Depends on Core, EscapeBoundary, FragmentRegistry, OOFRegistry. Variants: proof-local no-executor, guarded RuntimeMachine, future Ledger/TBackend-backed. |
| `StreamPack` | `stream`, `window`, `fold_stream`, stream bound annotations `@window_bounded`, `@count_bounded`. | Stream ingress classification, fold_stream producer tracking, direct stream use rejection, missing-window checks. | Fold body CORE restriction, fold result type, stream/window/fold SemanticIR nodes. | Stream node files, stream windows in requirements, stream capability/effect summaries. | Owns `stream_input` capability; owns stream-specific use of `stream` and/or `escape`; owns `OOF-S1`..`OOF-S5`. | Depends on Core, EscapeBoundary, FragmentRegistry. Variants: metadata-only, finite replay proof, production ingress/window runner. |
| `OLAPPack` | Top-level `olap_point`, `OLAPPoint[T, dims_record]`, slice records, source/indexed/granularity clauses. | Registers OLAPPoint symbols; prevents accidental direct core treatment of analytical storage. | `olap_env`, declaration validation, slice/rollup inference, `olap_point_decl`, `olap_access_node`. | Future OLAP requirements and analytical artifact hooks; current assembler has no dedicated OLAP artifact. | Currently mostly `core`/`escape` adjacent; candidate owns `OOF-O1`..`OOF-O5` and warning `OOF-O2`. | Depends on Core; semantically depends on Temporal theorem from PROP-022 but should not require Temporal runtime. Variants: local analytical proof, distributed scatter/gather later. |
| `InvariantPack` | `invariant`, `predicate`, `severity`, `label`, `message`, `overridable_with`. | Invariant dependency refs, source metadata, author fields. | Predicate Bool checks, severity validation, output effect propagation, invariant SemanticIR nodes and invariant coverage report section. | Invariant coverage in compilation report; future requirement/audit hooks. | Does not own a separate fragment class today; contributes core nodes and OOFs. Owns `OOF-IV1`, `OOF-IV2`, `OOF-IV3`, `OOF-I1`..`OOF-I5` as they land. | Depends on Core; optional dependency on Temporal/BiHistory when override audit becomes enforced. Variants: compile-only, runtime observation, audited override. |
| `ContractModifiersPack` | Optional contract modifier prefix: `pure`, `observed`, `effect`, `privileged`, `irreversible`. | Modifier propagation, modifier-to-fragment widening, `pure` plus escape violation. | OOF-M1 propagation and typed modifier passthrough. | Manifest pass-through of `modifier`; no validation yet. | Owns `OOF-M1`; does not own a fragment class, but contributes fragment-widening rules. | Depends on Core, EscapeBoundary, FragmentRegistry. Variants: parser/pass-through, strict Effect Surface after PROP-035. |
| `AssumptionsPack` | Future `assumptions {}` block, `assumption NAME`, `uses assumptions NAME`, optional output evidence refs. | Assumption registry, contract `assumption_refs`, `uses_assumptions` classification, undeclared-assumption OOF. | Strength range check, OOF-A1 propagation, typed `assumption_refs`. | Future SemanticIR `assumption_registry`, contract `assumption_refs`, receipt propagation; no runtime resolution. | Owns proposed `epistemic`; owns `OOF-A1`; future evidence OOFs belong to a later evidence pack. | Depends on Core, ContractModifiers, FragmentRegistry, OOFRegistry. Variants: draft/spec-only, proof-local, native pack after PROP-032 implementation authorization. |
| `EvidenceObservationPack` | No new base grammar currently; observes evidence-oriented current fixtures. | Current classifier checks for ConfidenceLabel-as-Bool and EvidenceLinkedAlert gates. | Current emitter/typechecker checks evidence alert validity and confidence label misuse. | Future ObsPacket/report contributors. | Owns current `OOF-CE4`, `OOF-OS2`, `OOF-OS4`. | Depends on Core. Open whether this remains one pack or splits into Evidence + Observation Surface. |
| `PipelinePack` | Top-level `pipeline`, `step`, illegal body placement gates, scoped read parser gates. | Future pipeline symbol registration and step ref validation. | Future pipeline typed flow checks. | Future pipeline package/manifest hooks. | Owns `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5`. | Depends on Core. Candidate is current-surface cleanup, not in the requested PROPs but present in parser. |

---

## Fragment Class Ownership

| Fragment class | Candidate owner | Current evidence | Open issue |
|---|---|---|---|
| `core` | `CoreLanguagePack` | Base contracts, inputs, computes, outputs. | None. |
| `escape` | `EscapeBoundaryPack` | `escape`, non-temporal `read`, current stream ingress classification, modifier widening. | Whether `escape` remains a class or becomes a legacy/coarse compatibility class once `stream`, `temporal`, and `epistemic` are first-class. |
| `stream` | `StreamPack` plus `FragmentRegistryPack` | Assembler has stream nodes and `fragment_precedence` includes `stream`; classifier currently marks stream declarations as `escape`. | Need a unified rule: stream ingress may be external, but contract class should likely become `stream`, not generic `escape`, when StreamPack is installed. |
| `temporal` | `TemporalPack` | PROP-028, classifier temporal reads, TypeChecker temporal access nodes, SemanticIR temporal nodes, assembler temporal requirements. | Parser coordinate syntax remains pending; runtime execution remains guarded. |
| `epistemic` | `AssumptionsPack` | PROP-032 draft proposes it; no implementation yet. | Unified precedence with `stream` and `escape` is unresolved. Candidate order: `oof > temporal > stream > escape > epistemic > core`, pending Architect/Compiler-Expert decision. |
| `oof` | `OOFRegistryPack` | Classifier/typechecker/emitter all block or omit IR on OOF. | Decide whether `oof` is a fragment class, status, or both in the future profile model. |

---

## OOF Code Ownership

| Code family | Candidate owner | Current / proposed stage owner |
|---|---|---|
| `OOF-P0`, `OOF-P1`, `OOF-P2`, `OOF-TY0` | `CoreLanguagePack` | Parser/emitter/typechecker generic parse/type errors. |
| `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5` | `PipelinePack` | Parser today. |
| `OOF-H*`, `OOF-BT*`, `OOF-TM*` | `TemporalPack` | TypeChecker today, with compatibility aliases. |
| `OOF-S1`, `OOF-S5` | `StreamPack` | Parser today. |
| `OOF-S2`, `OOF-S4` | `StreamPack` | Classifier today. |
| `OOF-S3` | `StreamPack` | TypeChecker today. |
| `OOF-O1`..`OOF-O5` | `OLAPPack` | Parser owns current `OOF-P0` OLAP clause errors; TypeChecker owns `OOF-O3`..`OOF-O5` and warning `OOF-O2`. The report recommends migrating parser-local OLAP parse errors to OLAPPack-owned descriptors, not necessarily renaming public codes. |
| `OOF-IV*`, `OOF-I*` | `InvariantPack` | Parser and TypeChecker today. |
| `OOF-M1` | `ContractModifiersPack` | Classifier detects; TypeChecker propagates. |
| `OOF-A1` | `AssumptionsPack` | Proposed Classifier detect; TypeChecker propagate. |
| `OOF-CE4`, `OOF-OS2`, `OOF-OS4` | `EvidenceObservationPack` | Classifier/emitter today. |
| `OOF-DM3` | `CoreLanguagePack` or future `NumericTypesPack` | Parser today for Decimal scale. |

---

## Dependency Shape

```text
CoreLanguagePack
  OOFRegistryPack
  FragmentRegistryPack
  EscapeBoundaryPack
    TemporalPack
    StreamPack
  OLAPPack
  InvariantPack
  ContractModifiersPack
    AssumptionsPack
  EvidenceObservationPack
  PipelinePack
```

This is not an install-order guarantee. It is a dependency sketch. The eventual
kernel needs explicit `before`, `after`, and `requires_pack` semantics because
classifier/typechecker rule precedence matters.

---

## Replaceable Implementation Variants

| Pack | Replaceable variants |
|---|---|
| Core | `ProofCompilerAdapter`, `NativeCorePack`, later optimized parser/typechecker implementations. |
| Temporal | `MetadataOnlyTemporalPack`, `GuardedRuntimeTemporalPack`, `LedgerTBackendTemporalPack`. |
| Stream | `MetadataOnlyStreamPack`, `FiniteReplayStreamPack`, `ProductionIngressStreamPack`. |
| OLAP | `LocalFixtureOLAPPack`, `SegmentedOLAPPack`, `DistributedScatterGatherOLAPPack`. |
| Invariant | `CompileOnlyInvariantPack`, `RuntimeObservationInvariantPack`, `AuditedOverrideInvariantPack`. |
| Contract modifiers | `PassThroughModifiersPack`, `EffectSurfaceStrictPack`. |
| Assumptions | `SpecOnlyAssumptionsPack`, `ProofAssumptionsPack`, `NativeEpistemicPack`. |
| Evidence / observation | `FixtureEvidencePack`, `ObsPacketEvidencePack`, later receipt/lineage-enforced implementation. |

The profile fingerprint must distinguish the implementation variant, not only
the capability name. Two profiles that both provide `temporal` but use different
TBackend semantics are not interchangeable.

---

## Migration Order

No migration is authorized by this report. If POC closure later authorizes the
first slice, the lowest-risk order is:

1. Create a shadow `CompilerPackManifest` / `CompilerProfile` proof that describes
   the existing monolithic compiler without dispatching through packs.
2. Register OOF descriptors and fragment-class descriptors as data, generated from
   the existing hardcoded behavior, while keeping output identical.
3. Add a profile compatibility summary to proof outputs only; do not add
   `compiler_profile_id` to `.igapp` manifests yet.
4. Split `CoreLanguagePack` as a facade over the current parser/classifier/
   typechecker/emitter/assembler methods, still no behavior routing changes.
5. Extract the first real optional pack only after the shadow profile catches
   duplicate keys, missing owners, precedence conflicts, and fixture drift.

Recommended first real optional pack after the shadow profile: `ContractModifiersPack`.
It is small, recent, and already has explicit cross-stage ownership (`modifier`
field plus `OOF-M1`). It tests parser/classifier/typechecker/SemanticIR pass
registration without entangling runtime execution, TBackend, stream windows, or
OLAP scatter/gather.

---

## Migration Risk Table

| Risk | Severity | Why it matters | Mitigation |
|---|---:|---|---|
| Parser rule precedence drift | High | Optional grammar from multiple packs can change parse outcomes or diagnostics. | Ordered parser-rule registry with deterministic conflict errors before native migration. |
| Fragment precedence conflict | High | PROP-028, current assembler, and PROP-032 use related but not identical vocabularies. | Central `FragmentRegistryPack`; no pack computes max class independently. |
| OOF code drift | High | Golden fixtures and reports depend on stable public codes and stages. | OOF descriptor registry with owner/stage; prove old and new reports match byte-for-byte before switching. |
| Type environment cross-pack coupling | High | Temporal, OLAP, invariants, stream, assumptions all use shared symbol/type env. | Keep a typed accumulator protocol in kernel; packs contribute handlers, not private env mutations. |
| SemanticIR shape drift | Critical | `.igapp` and proof fixtures depend on exact JSON shape. | Shadow profile first; no `.igapp` format changes; compare canonical JSON outputs. |
| Assembler hook leakage | Critical | Artifact requirements, contract index, compatibility metadata can silently authorize runtime behavior. | Assembler core owns artifact shape; packs contribute metadata hooks that cannot change top-level format without explicit PROP. |
| Runtime authority confusion | Critical | A pack that says it provides `temporal` must not imply live TBackend execution. | Separate capability name, implementation variant, runtime authorization, and guard policy in profile metadata. |
| Dependency cycles | Medium | Pack installs may require each other through grammar/type/assembler hooks. | Reuse `igniter-contracts` style dependency and circular-dependency validation. |
| Profile fingerprint adoption timing | Medium | Adding `compiler_profile_id` too early changes manifests and compatibility checks. | Keep profile id out of `.igapp` until an explicit manifest PROP. |
| Over-splitting support packs | Medium | OOF/fragment/diagnostics packs may add ceremony before behavior is stable. | First implement as shadow registries; only split code after proven value. |

---

## Recommended First Migration Slice After POC Closure

Recommended card:

```text
Track: compiler-pack-shadow-profile-proof-v0
Goal: Produce a frozen shadow CompilerProfile for the current monolithic compiler.
Scope:
- Define pack manifests as data for Core, OOFRegistry, FragmentRegistry,
  EscapeBoundary, Temporal, Stream, OLAP, Invariant, ContractModifiers,
  EvidenceObservation, and Pipeline.
- Do not dispatch compiler passes through packs.
- Do not change SemanticIR, CompilationReport, or .igapp shape.
- Prove profile data matches existing OOF codes, fragment classes, and artifact hooks.
Acceptance:
- Existing Stage 3 close/prelive regression chain remains PASS.
- Shadow profile summary is emitted only by a proof runner or track artifact.
- Byte-for-byte compiler outputs remain unchanged.
```

Reason: this validates pack decomposition and ownership before any pass routing.
It gives the Architect and Compiler Expert concrete registry data to review
while avoiding a rewrite under active Stage 3 pressure.

---

## Open Questions

[Q1] What is the canonical unified fragment precedence once `stream`, `escape`,
`temporal`, and `epistemic` all coexist? Candidate: `oof > temporal > stream >
escape > epistemic > core`, but this needs Architect/Compiler-Expert decision.

[Q2] Is `escape` a permanent fragment class, or a compatibility bucket that
should eventually split into observed/effect/privileged/irreversible/runtime
boundary classes?

[Q3] Should `OOFRegistryPack` and `FragmentRegistryPack` be real installed packs,
or kernel services populated by packs?

[Q4] Should the first profile fingerprint include implementation variant IDs
such as `TemporalPack::MetadataOnly`, or only capability names?

[Q5] Who owns assembler extension points: a general `ArtifactAssemblyPack`, the
core assembler, or each language pack via constrained hooks?

[Q6] Should current evidence/confidence behavior become an
`EvidenceObservationPack`, or wait for the upcoming output evidence / receipt
PROP sequence?

[Q7] Should `PipelinePack` be included in the first shadow profile despite not
being part of the requested PROP list, because parser OOF-PG codes already exist?

[Q8] When should `.igapp` gain `compiler_profile_id`, and is that a manifest PROP
or a compiler-pack migration PROP?

[Q9] For OLAP, should `History[T] ≡ OLAPPoint[T, {time: DateTime}]` be expressed
as a dependency from Temporal to OLAP, from OLAP to Temporal, or as a theorem in a
shared analytical model pack?

[Q10] For assumptions, is `epistemic` strictly a fragment class, or should it be
a separate accountability axis orthogonal to effect/runtime fragments?

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S3-R31-C7-P
Track: compiler-pack-boundary-report-v0
Status: done

[D] Decisions:
- Future pack boundaries should be capability-owned, not file-owned.
- The current compiler should first be described by a shadow profile; pass routing
  should not move until ownership and precedence are proven.
- Support registries for OOF descriptors and fragment classes are mandatory
  whether implemented as packs or kernel services.
- ContractModifiersPack is the recommended first real optional pack after a
  shadow profile because it is bounded and cross-stage.

[S] Signals:
- Pack decomposition can cover current parser/classifier/typechecker/SemanticIR/
  assembler responsibilities without changing `.igapp`.
- PROP boundaries do not map perfectly to pack boundaries; EvidenceObservation,
  Pipeline, OOFRegistry, and FragmentRegistry are needed to account for current code.
- Fragment precedence is the highest-risk design point before implementation.

[T] Tests / Proofs:
- Documentation-only no-code report.
- No compiler implementation changed.

[R] Risks:
- Parser/classifier precedence, OOF stage ownership, and assembler hooks can drift
  outputs if migrated directly.
- Runtime capability names must not imply live executor authority.
- Adding profile IDs to `.igapp` before an explicit manifest PROP would create
  format drift outside this report.

[Next]
- Route `compiler-pack-shadow-profile-proof-v0` after POC closure.
- Ask Architect / Compiler-Expert to resolve fragment precedence, OOF registry
  shape, and assembler hook ownership before any native pack migration.
```
