# Compiler Code And Experiment Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Source card: `S3-R64-C0-O`
Authority: orientation only, not canon

---

## Purpose

Give future agents a compact, path-indexed map of Igniter-Lang compiler code,
experiments, proofs, and evidence layers without broad rereads.

This map does not authorize code changes, semantic changes, proposal changes,
or gate decisions.

---

## Surface Legend

```text
implementation  production code in igniter-lang/lib/
proof           executable proof or fixture in igniter-lang/experiments/
golden          stable expected output used by proof-local validation
summary         compact proof result, usually *_summary.json
authority       proposal/gate/status/card source, not changed by this map
evidence        track/discussion/proof result, not authority by itself
history         archive/lineup/history context, read only when assigned
orientation     this map and docs/org reports
```

---

## Production Compiler Spine

| Surface | Path | Type | Value | Touch Boundary |
| --- | --- | --- | --- | --- |
| Facade | `igniter-lang/lib/igniter_lang.rb` | implementation | Public Ruby entrypoint `IgniterLang.compile(...)` and dependency injection hook for orchestrator | Code change requires implementation card |
| Orchestrator | `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | implementation | Production pipeline: parse -> classify -> typecheck -> emit_typed -> assemble -> optional runtime smoke | Protected for profile/source routing and stage order |
| Parser | `igniter-lang/lib/igniter_lang/parser.rb` | implementation | Lexer/parser for accepted grammar kernel and newer surfaces such as assumptions, stream, OLAP, invariants | Parser syntax needs PROP/gate path |
| Classifier | `igniter-lang/lib/igniter_lang/classifier.rb` | implementation | Fragment/OOF classifier; temporal reads produce core values but temporal node class | Fragment/OOF behavior needs Compiler/Grammar authority |
| TypeChecker | `igniter-lang/lib/igniter_lang/typechecker.rb` | implementation | TypedProgram, type env, assumptions, OLAP, invariant and stream checks | Type rules need proposal/proof authority |
| SemanticIR Emitter | `igniter-lang/lib/igniter_lang/semanticir_emitter.rb` | implementation | `emit_typed` canonical path; emits SemanticIR and compilation report | SemanticIR shape/golden changes need authorization |
| Assembler | `igniter-lang/lib/igniter_lang/assembler.rb` | implementation | Builds `.igapp`; validates refs, requirements, compatibility metadata, and PROP-036 `compiler_profile_source` | `.igapp`/hash/profile fields are protected |
| Compilation Report | `igniter-lang/lib/igniter_lang/compilation_report.rb` | implementation | Report enrichment, parse/runtime/internal errors, diagnostic categories | Loader/report status sections remain protected |
| Compiler Result | `igniter-lang/lib/igniter_lang/compiler_result.rb` | implementation | Public result envelope and refusal envelope | Public API changes need explicit approval |
| CLI | `igniter-lang/lib/igniter_lang/cli.rb` | implementation | `igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]` | CLI widening/default/discovery remains protected |
| Diagnostics | `igniter-lang/lib/igniter_lang/diagnostics.rb` | implementation | Diagnostic shaping and error/warning filtering | OOF/error vocabulary changes need proof |
| Temporal Executor | `igniter-lang/lib/igniter_lang/temporal_executor.rb` | implementation | Gate 3 Phase 1 temporal executor boundary | Runtime/Gate 3 widening closed |
| Temporal Access Runtime | `igniter-lang/lib/igniter_lang/temporal_access_runtime.rb` | implementation | Runtime temporal access primitives | Runtime semantics changes closed unless authorized |

---

## Current Production Flow

```text
IgniterLang.compile
  -> CompilerOrchestrator#compile
    -> ParsedProgram.parse
    -> Classifier#classify(sample_input:)
    -> TypeChecker#typecheck
    -> SemanticIREmitter#emit_typed
    -> CompilationReport.enrich
    -> Assembler#assemble_artifacts
    -> CompilerResult.ok/refusal
```

Important current profile behavior:

```text
compiler_profile_source enters at facade/orchestrator/CLI boundary.
orchestrator passes it unchanged.
assembler validates it and extracts compiler_profile_id.
nil preserves legacy_optional behavior.
```

---

## Profile-Related Experiment Families

### PROP-036 - compiler_profile_id manifest identity

| Family | Key paths | Value | Primary outputs |
| --- | --- | --- | --- |
| manifest boundary | `experiments/compiler_profile_id_manifest_boundary/` | Early boundary proof for compiler profile id in manifests | `out/compiler_profile_id_manifest_boundary_summary.json` |
| finalization proof | `experiments/minimal_compiler_profile_finalization_proof/` | Stable `compiler_profile_source` object and finalization payload | `out/minimal_compiler_profile_finalization_summary.json`, `out/compiler_profile_source.stage3_proof.json` |
| assembler field | `experiments/assembler_compiler_profile_id_field/` | Proves assembler injects `compiler_profile_id` before artifact hash | `out/assembler_compiler_profile_id_field_summary.json`, `out/*.igapp/manifest.json` |
| artifact hash ordering | `experiments/prop036_artifact_hash_ordering_proof/` | Guards hash-material ordering around profile id | `out/prop036_artifact_hash_ordering_summary.json` |
| orchestrator pass-through | `experiments/prop036_orchestrator_profile_source_pass_through/` | Shows orchestrator transports profile source without finalizing/discovering | `out/prop036_orchestrator_profile_source_pass_through_summary.json` |
| Ruby facade exposure | `experiments/prop036_ruby_facade_profile_source_exposure/` | Bounded public Ruby facade transport | `out/prop036_ruby_facade_profile_source_exposure_summary.json` |
| CLI proof | `experiments/prop036_cli_profile_source_b3_b6_implementation_proof/` | B3/B4/B5/B6 CLI transport/refusal/negative scan proof | `out/prop036_cli_profile_source_b3_b6_implementation_proof_summary.json` |
| loader status proof | `experiments/prop036_loader_status_report_proof/` | Proof-local loader/report status shape, not implementation authority | `out/prop036_loader_status_report_summary.json` |

Authority/evidence links:

```text
docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md
docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md
docs/gates/prop036-cli-release-readiness-decision-v0.md
docs/gates/prop036-cli-remaining-blockers-formal-closure-decision-v0.md
docs/tracks/prop036-cli-profile-source-b3-b6-implementation-proof-v0.md
docs/tracks/prop036-cli-release-confidence-smoke-v0.md
```

Do not touch without Architect approval:

```text
CLI widening
profile discovery/defaulting/finalization in public surfaces
loader/report status implementation
CompatibilityReport profile sections
golden migration beyond named proof scope
dispatch migration
RuntimeMachine / Gate 3 widening
production behavior
```

### PROP-038 - compiler_profile_contract

| Family | Key paths | Value | Primary outputs |
| --- | --- | --- | --- |
| obligation coverage | `experiments/compiler_profile_obligation_coverage_proof/` | Report-only obligation coverage proof | `out/compiler_profile_obligation_coverage_summary.json` |
| contract proof | `experiments/compiler_profile_contract_proof/` | Canonical proof-local `compiler_profile_contract` shape | `out/compiler_profile_contract_proof_summary.json` |
| validator coverage | `experiments/compiler_profile_validator_implementation_plan/` | Validator planning and coverage model | `out/compiler_profile_validator_implementation_plan_summary.json`, `out/compiler_profile_validator_implementation_plan.json` |
| spec/rule unification | `experiments/compiler_profile_spec_and_rule_unification/` | Pressure around spec/rule/profile unification | `out/compiler_profile_spec_and_rule_unification_summary.json` |

Authority/evidence links:

```text
docs/proposals/PROP-038-compiler-profile-contract-v0.md
docs/gates/prop038-compiler-profile-contract-acceptance-decision-v0.md
docs/gates/prop038-compiler-profile-contract-implementation-authorization-decision-v0.md
docs/gates/prop038-proof-local-missing-after-acceptance-decision-v0.md
docs/tracks/compiler-profile-contract-proof-v0.md
docs/tracks/compiler-profile-contract-validator-coverage-proof-v0.md
docs/tracks/prop038-compiler-profile-contract-implementation-scope-survey-v0.md
docs/tracks/prop038-proof-local-missing-after-implementation-v0.md
docs/discussions/prop038-compiler-profile-contract-pressure-v0.md
docs/discussions/prop038-implementation-scope-pressure-v0.md
docs/discussions/prop038-proof-local-missing-after-pressure-v0.md
```

Do not touch without Architect approval:

```text
implementation based on obligation/contract coverage
compile refusal behavior
parser/typechecker/SemanticIR/assembler changes
.igapp emission changes
loader/report and CompatibilityReport sections
RuntimeMachine binding
production behavior
```

---

## Other Compiler/Profile Research Families

| Family | Paths | Value |
| --- | --- | --- |
| Descriptor/schema | `experiments/compiler_profile_descriptor_schema/`, `compiler_profile_descriptor_error_taxonomy_sharpening/` | Profile descriptor shapes and diagnostic taxonomy |
| Slots/order | `experiments/compiler_profile_slots_model/`, `compiler_profile_preflight_chain_index/` | Slot ordering and chain dependency thinking |
| Shadow pack | `experiments/compiler_pack_shadow_profile_proof/`, `compiler_kernel_pack_registry_spike/` | Post-POC compiler-pack architecture pressure, not current dispatch |
| Profile syntax pressure | `experiments/profile_source_syntax_*`, `profile_source_lowering_target/` | Future syntax/lowering research, not parser authority |
| Authority/build receipts | `experiments/compiler_profile_authority_boundary/`, `compiler_profile_auditable_build_receipt/` | Future authority/receipt pressure, not current production behavior |

---

## Runtime / Temporal / Audit Proof Families

Orientation only. Do not deep-read unless the active card names them.

| Family | Paths | Value |
| --- | --- | --- |
| Temporal compiler surfaces | `temporal_*`, `history_type_proof/`, `sparkcrm_bihistory_fixture/` | Temporal fragment, History/BiHistory, assembler/load guard proofs |
| Runtime smoke / compatibility | `runtime_smoke_*`, `runtime_compatibility_report_temporal_load_check/`, `compatibility_report_*` | Runtime/CompatibilityReport proof-local surfaces |
| Gate 3 Phase 1 | `temporal_executor_*`, `phase1_*`, `executor_*`, `guarded_runtime_*` | Restricted live-read and approval-token proof chain |
| Durable audit | `production_durable_*`, `durable_audit_*`, `startup_freshness_override_proof/`, `volatile_fields_lint/` | Production-facing durable audit proof chain and deployment prep |
| Language syntax/proposals | `assumptions_proof/`, `contract_modifiers_proof/`, `prop037_*`, `pressure-specimens/` | PROP-031/032/037 and pressure fixture evidence |

---

## Proof Output Navigation

Prefer these outputs before opening proof scripts:

```text
*/out/*_summary.json
*/summary.json
*/out/*_matrix.json
*/out/*_packet.json
*/golden/*.json
*/out/*.igapp/manifest.json
*/out/*.igapp/compilation_report.json
*/out/*.igapp/semantic_ir_program.json
```

Read order for future agents:

```text
1. active card / gate / proposal named by card
2. current-status and S3 cards index
3. matching track report
4. experiment summary JSON
5. proof script only if exact method or rerun is required
6. golden or .igapp output only if output shape is under review
```

---

## Authority Boundaries

This map is orientation only. It must not be used to infer permission.

Authority sources:

```text
igniter-lang/AGENTS.md
igniter-lang/roles/*.md
igniter-lang/docs/cards/S3/*.md
igniter-lang/docs/gates/*.md
igniter-lang/docs/proposals/*.md
igniter-lang/docs/current-status.md
```

Evidence sources:

```text
igniter-lang/docs/tracks/*.md
igniter-lang/docs/discussions/*.md
igniter-lang/experiments/**/out/*.json
igniter-lang/experiments/**/golden/*.json
```

Implementation sources:

```text
igniter-lang/lib/igniter_lang/*.rb
```

History/orientation sources:

```text
igniter-lang/docs/archive/
igniter-lang/docs/lineups/
igniter-lang/docs/org/
```

---

## Missing Map Gaps

Known orientation gaps for future org slices:

```text
1. No one-page exact PROP-036 -> code-surface closure table.
2. No one-page exact PROP-038 -> proposed implementation surface table.
3. Runtime/Gate 3 proof families are mapped only at family level here.
4. Pressure specimens need a separate "language pressure atlas" map.
5. Root package bridge surfaces are visible but not indexed in this org map.
```

---

## Suggested Future Org Slices

```text
1. prop036-code-surface-closure-map-v0
2. prop038-implementation-surface-watch-map-v0
3. runtime-proof-family-orientation-map-v0
4. language-pressure-specimen-atlas-v0
5. igniter-package-bridge-orientation-map-v0
```
