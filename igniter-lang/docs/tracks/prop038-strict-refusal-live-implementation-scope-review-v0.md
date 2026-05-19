# Track: PROP-038 Strict Refusal Live Implementation Scope Review v0

Card: S3-R82-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-strict-refusal-live-implementation-scope-review-v0`
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design and review the exact live implementation boundary for PROP-038 strict
refusal using the accepted R81 proof-local result-shape evidence, without
authorizing implementation.

This track is design/review only. It does not edit code, enable live compile
refusal, change compiler/orchestrator behavior, change `CompilerResult`, widen
public API/CLI behavior, write persisted reports or sidecars, mutate `.igapp`,
or open loader/report, CompatibilityReport, diagnostics centralization, runtime,
or production behavior.

---

## Inputs Read

- `docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md`
- `docs/tracks/prop038-strict-refusal-result-shape-proof-local-v0.md`
- `docs/discussions/prop038-strict-refusal-result-shape-proof-pressure-v0.md`
- `docs/gates/prop038-strict-refusal-result-shape-decision-v0.md`
- `docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round81-status-curation-v0.md`

---

## Accepted R81 Evidence

R81 accepts proof-local target shapes only.

Accepted proof-local public key-set:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
contracts
compilation_report_path
diagnostics
warnings
```

Accepted proof-local target statuses:

```text
refused
configuration_error
```

Accepted proof-local diagnostic codes:

```text
compiler_profile_contract_refusal.contract_digest_mismatch
compiler_profile_contract_refusal.strict_requirement_malformed
```

Accepted target properties:

- `compilation_report_path` is present and null;
- `igapp_path` is null;
- assembly is skipped;
- raw validator diagnostics stay nested;
- public diagnostics use wrapper codes only;
- no sidecar/report/artifact path is produced by the proof target;
- live compiler/orchestrator behavior remains unchanged.

---

## Candidate Live Write Scope

Candidate future implementation write scope, if a later gate authorizes live
implementation:

| Path | Candidate role | Authority required? | Notes |
| --- | --- | --- | --- |
| `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | Add internal strict requirement constructor option and non-persisting pre-assembly strict terminal branch. | Yes, `CompilerOrchestrator` authority. | Required for any live behavior. |
| `igniter-lang/lib/igniter_lang/compiler_result.rb` | Add strict-refusal / configuration-error result construction or equivalent status/result support. | Yes, `CompilerResult` authority. | Required if public/internal result status changes. |
| `igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/` | Future proof harness for live boundary. | Yes, proof scope authority. | New experiment recommended if implementation opens. |
| `igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json` | Possible rerun output. | Conditional. | Only if required command rerun changes summary due accepted live behavior. |
| `igniter-lang/docs/tracks/prop038-strict-refusal-live-implementation-v0.md` | Future implementation track. | Yes, docs boundary. | Only if implementation opens. |

Non-candidate write scope for first live implementation:

```text
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/bin/igc
igniter-lang/lib/igniter_lang/assembler.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/diagnostics.rb
igniter-lang/.igapp artifacts or goldens
loader/report or CompatibilityReport surfaces
```

If implementation requires any non-candidate path, the card must stop and route
back to design/authority.

---

## Authority Requirements

| Authority | Required for future live implementation? | Decision |
| --- | --- | --- |
| `CompilerOrchestrator` authority | Yes. | Needed for internal strict source option, trigger evaluation point, non-persisting terminal branch, and assembly skip. |
| `CompilerResult` authority | Yes. | Needed for future `status: "refused"`, `status: "configuration_error"`, key-set allowlist, and wrapper diagnostics. |
| Report / persisted artifact policy | No, if non-persisting path remains selected. | Separate authority required only if sidecar, persisted report, or `CompilerOrchestrator#refusal` reuse is chosen. |
| Public API authority | No. | Must remain closed for first live boundary. |
| CLI authority | No. | Must remain closed for first live boundary. |
| Diagnostics centralization authority | No. | Wrapper diagnostics stay local to strict result shape; no `IgniterLang::Diagnostics` centralization. |
| Assembler / `.igapp` authority | No. | Strict terminal path skips assembly; report-only/allow paths keep current assembly behavior. |
| Loader/report authority | No. | Remains closed. |
| CompatibilityReport authority | No. | Remains closed. |
| Runtime/production authority | No. | Remains closed. |

Conclusion:

```text
future first live implementation requires CompilerOrchestrator + CompilerResult
authority, but does not require API/CLI, persisted-report, diagnostics
centralization, assembler, loader/report, CompatibilityReport, runtime, or
production authority if it stays non-persisting and constructor-only.
```

---

## `report.pass_result` Policy

Recommendation:

```text
report.pass_result: "ok" remains invariant for all PROP-038 strict terminal
paths in this route.
```

Applies to:

- strict digest mismatch terminal path;
- malformed strict requirement `configuration_error`;
- future strict terminal paths that are evaluated only after baseline compile
  report enrichment with `pass_result == "ok"`.

Does not apply to:

- ordinary parse/type/OOF failures;
- assembler failures;
- runtime smoke failures;
- hypothetical future strict sources evaluated before baseline report exists.

Rationale:

- PROP-038 strict terminal behavior is layered after a baseline successful
  compiler pipeline has produced report evidence.
- Mutating `report["pass_result"]` would accidentally route through existing
  ordinary refusal mechanics and sidecar writes.
- The strict terminal status belongs to orchestration/result status, not to the
  baseline report pass result.

Proof expectation:

```text
strict terminal result status in ["refused", "configuration_error"]
AND internal report["pass_result"] == "ok"
```

---

## `configuration_error` Public Surface

Recommendation:

```text
configuration_error shares the same strict terminal public key-set allowlist.
```

Shared allowlist:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
contracts
compilation_report_path
diagnostics
warnings
```

Reason:

- R81 proof already modeled `configuration_error` with the same level of
  precision as `refused`.
- A smaller key-set would add a second public result surface and more CLI/API
  risk.
- Shared shape makes proof and public-result guards simpler.

Differences remain in values, not keys:

| Field | `refused` | `configuration_error` |
| --- | --- | --- |
| `status` | `refused` | `configuration_error` |
| public diagnostic code | `compiler_profile_contract_refusal.contract_digest_mismatch` | `compiler_profile_contract_refusal.strict_requirement_malformed` |
| evidence code | raw validator mismatch evidence | none or strict source path evidence |
| cause | contract digest identity conflict | malformed internal strict requirement |

Public result must not expose a separate `strict_requirement` object, raw strict
source payload, or nested validation object.

---

## Non-Persisting Path Boundary Sketch

Design-only sketch for future live implementation:

```text
CompilerOrchestrator#compile
  -> existing parse/classify/typecheck/emit/report enrichment
  -> preserve report_for_assembly = report
  -> if report["pass_result"] != "ok": existing #refusal path unchanged
  -> if report["pass_result"] == "ok":
       run existing report-only provider/validator path
       attach nested compiler_profile_contract_validation in memory
       if internal strict requirement absent:
         continue current assembly/success path
       if internal strict requirement malformed:
         return non-persisting configuration_error result
         do not call #refusal
         do not assemble
       if strict requirement valid and mismatch candidate present:
         return non-persisting refused result
         do not call #refusal
         do not assemble
       otherwise:
         continue current assembly/success path
```

Boundary rules:

- Do not call `CompilerOrchestrator#refusal` for PROP-038 strict terminal paths.
- Do not write `.compilation_report.json`.
- Do not write a distinct PROP-038 refusal report.
- Do not create or mutate `.igapp`.
- Do not call `Assembler.assemble_artifacts` on strict terminal paths.
- Do not append nested validation diagnostics to top-level report diagnostics.
- Do not expose strict source through facade, CLI, manifest, loader/report, or
  CompatibilityReport.

Ordinary refusal behavior remains unchanged:

- parse failure;
- normal OOF;
- assembler refusal;
- runtime smoke refusal;
- generic internal error.

---

## Candidate Result Shape Policy

Future live result must match the R81 accepted public key-set exactly.

Required public keys:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
contracts
compilation_report_path
diagnostics
warnings
```

Required absent public keys:

```text
report
compiler_profile_contract_validation
strict_refusal
wrapper_evidence
refusal_candidates
strict_validation_source
compile_refusal_authorized
raw_validation_diagnostics
```

Public diagnostics:

- wrapper code only;
- raw validator diagnostics absent from public diagnostics;
- nested validator diagnostics remain under internal report evidence.

`compilation_report_path`:

```text
present and null
```

for non-persisting strict terminal paths.

---

## Exact Blockers Before Implementation Authorization

Blocking items:

1. Architect acceptance of this live implementation scope review.
2. Explicit future implementation authorization naming candidate write scope.
3. `CompilerOrchestrator` authority for constructor-only strict source and
   non-persisting terminal branch.
4. `CompilerResult` authority for `refused` and `configuration_error` status
   result construction.
5. Confirmation that existing `CompilerOrchestrator#refusal` remains unused for
   first PROP-038 strict terminal paths.
6. Confirmation that no persisted report, sidecar, or `.igapp` artifact is
   written for strict terminal paths.
7. Confirmation that `configuration_error` shares the strict terminal public
   key-set.
8. Confirmation that `report.pass_result: "ok"` is invariant for all PROP-038
   strict terminal paths in this route.
9. Proof plan covering public key-set, nested diagnostic isolation, no sidecars,
   no API/CLI widening, report-only preservation, and ordinary refusal
   preservation.
10. Exact command matrix with syntax checks for edited live files and any new
    proof script.
11. Confirmation that fail-closed recompute-unavailable remains out of scope.
12. Confirmation that loader/report, CompatibilityReport, diagnostics
    centralization, runtime, and production remain closed.

No implementation card should open until all blockers are explicitly closed.

---

## Proof / Regression Matrix For Future Implementation

### Syntax Checks

If live implementation is authorized and edits candidate live files:

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb
```

If a new proof script is authorized:

```bash
ruby -c igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb
ruby igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb
```

### Existing Proof Chain

Must remain PASS:

```bash
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb
ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb
```

### Live Strict Terminal Cases

| Case | Expected |
| --- | --- |
| no strict requirement | current report-only behavior unchanged. |
| strict requirement nil | current report-only behavior unchanged. |
| malformed strict requirement | `configuration_error` result shape, non-persisting, pre-assembly. |
| strict valid contract | current assembly/success behavior unchanged. |
| strict digest mismatch | `refused` result shape, non-persisting, pre-assembly. |
| strict invalid digest | no refusal unless candidate scope later expands. |
| unsupported policy | configuration handling follows accepted design; no accidental refusal. |
| recompute unavailable | fail-open/report-only unless fail-closed later opens. |

### Result Shape Assertions

| Assertion | Expected |
| --- | --- |
| public key-set | exact R81 allowlist for both `refused` and `configuration_error`. |
| `configuration_error` key-set | same allowlist as `refused`. |
| `report.pass_result` | `ok` for all PROP-038 strict terminal paths in this route. |
| `compilation_report_path` | present and null. |
| `igapp_path` | null. |
| `stages.assemble` | `skipped`. |
| public diagnostics | wrapper code only. |
| raw validator diagnostics | nested only. |

### Non-Persisting Assertions

| Assertion | Expected |
| --- | --- |
| `CompilerOrchestrator#refusal` | not called for strict terminal paths. |
| `.compilation_report.json` | not written. |
| distinct PROP-038 report | not written. |
| sidecar paths | none. |
| `.igapp` | not created or mutated. |
| assembler | not called for strict terminal paths. |

### Preservation Assertions

| Surface | Expected |
| --- | --- |
| current report-only invalid validation | compiles/assembles unchanged. |
| no provider / nil / non-Hash / provider error | no-field/no-refusal. |
| validator error | no-field/no-refusal unless separately authorized. |
| parse/oof/assembler/runtime-smoke refusals | existing behavior unchanged, including existing report-write behavior. |
| public API/CLI | no new parameter, flag, stdout key, or exit behavior unless separately authorized. |
| loader/report and CompatibilityReport | untouched. |
| diagnostics centralization | untouched. |

---

## Recommendation For Future Implementation Shape

If C4-A accepts this design, the next possible route may be an implementation
authorization request with the candidate scope above.

Recommended implementation stance if opened later:

```text
one bounded internal compiler implementation slice:
  CompilerOrchestrator + CompilerResult + proof experiment
```

Not recommended:

- public API/CLI exposure in the same slice;
- persisted report policy in the same slice;
- assembler/`.igapp` mutation;
- diagnostics centralization;
- loader/report or CompatibilityReport integration.

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
- live compile refusal;
- live compiler/orchestrator behavior changes;
- `CompilerResult` code changes;
- public API/CLI widening;
- persisted reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, loader/report,
  CompatibilityReport, diagnostics centralization, RuntimeMachine, Gate 3,
  Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

---

## Recommendation For C4-A

Recommendation:

```text
accept
```

Reason:

- exact candidate live write scope is named and narrow;
- `CompilerOrchestrator` and `CompilerResult` authority requirements are
  explicit;
- report/persisted artifact, API/CLI, and diagnostics centralization authority
  are not required for the recommended non-persisting constructor-only slice;
- `configuration_error` shares the accepted strict terminal public key-set;
- `report.pass_result: "ok"` remains invariant for all PROP-038 strict terminal
  paths in this route;
- non-persisting/no-sidecar/no-report and report-only/current-live boundaries
  remain protected;
- proof/regression requirements are implementation-review ready.
