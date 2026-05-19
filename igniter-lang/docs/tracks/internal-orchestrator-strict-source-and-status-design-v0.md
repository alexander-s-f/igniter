# Track: Internal Orchestrator Strict Source And Status Design v0

Card: S3-R79-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `internal-orchestrator-strict-source-and-status-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design the internal orchestrator strict source and status boundary for a
possible future PROP-038 live refusal implementation, resolving the existing
`CompilerOrchestrator#refusal` report-write tension before any implementation
can be considered.

This track is design-only. It does not edit code, enable live compile refusal,
change compiler/orchestrator behavior, widen public API/CLI behavior, change
`CompilerResult`, write reports or sidecars, mutate `.igapp`, or open
loader/report, CompatibilityReport, runtime, or production behavior.

---

## Inputs Read

- `docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md`
- `docs/tracks/prop038-live-refusal-implementation-boundary-design-v0.md`
- `docs/tracks/prop038-live-refusal-current-pipeline-surface-survey-v0.md`
- `docs/discussions/prop038-live-refusal-boundary-design-pressure-v0.md`
- `docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round78-status-curation-v0.md`

---

## Current Live Pipeline Constraints

Current compiler pipeline summary from R78 survey:

```text
IgniterLang.compile(...)
  -> CompilerOrchestrator#compile
     -> Parser / Classifier / TypeChecker / SemanticIREmitter
     -> CompilationReport.enrich(...)
     -> report_for_assembly = report
     -> compiler_profile_contract_provider call, only when pass_result == ok
     -> CompilationReport.with_compiler_profile_contract_validation(...)
     -> refusal(...) only when report["pass_result"] != "ok"
     -> Assembler.assemble_artifacts(report: report_for_assembly, ...)
     -> optional runtime_smoke
     -> CompilerResult.ok(...)
```

Accepted current behavior:

- contract validation is report-only;
- provider call occurs only when `report["pass_result"] == "ok"`;
- nil/non-Hash provider results and provider/validator exceptions produce no
  validation field;
- `report_for_assembly` is captured before report-only validation annotation;
- assembler receives the pre-annotation report;
- contract validation does not mutate `pass_result`, top-level diagnostics,
  public result, CLI output, `.igapp`, loader/report, or runtime behavior.

Existing refusal tension:

```text
CompilerOrchestrator#refusal writes <out without .igapp>.compilation_report.json
and returns CompilerResult.refusal(...)
```

Therefore a future strict PROP-038 refusal cannot both:

```text
reuse CompilerOrchestrator#refusal
and
avoid persisted report writes
```

unless `#refusal` itself grows an explicitly authorized non-persisting mode.

---

## Internal Strict Source Shape Proposal

Recommended future live source:

```text
internal orchestrator constructor option only
```

Design shape:

```ruby
CompilerOrchestrator.new(
  compiler_profile_contract_provider: provider,
  compiler_profile_contract_strict_requirement: strict_requirement
)
```

Where:

```text
compiler_profile_contract_strict_requirement
```

is an internal object or Hash-like value supplied only to the orchestrator
constructor. It is not a parameter on:

```text
IgniterLang.compile(...)
IgniterLang::CLI
bin/igc
.igapp/manifest.json
loader/report
CompatibilityReport
```

Proposed internal strict requirement shape:

```json
{
  "kind": "compiler_profile_contract_strict_requirement",
  "format_version": "0.1.0",
  "mode": "strict_contract_digest",
  "source": "internal_orchestrator_option",
  "refusal_candidates": [
    "compiler_profile_contract.contract_digest_mismatch"
  ],
  "recompute_unavailable_policy": "fail_open_report_only",
  "compile_refusal_authorized": false
}
```

Field meanings:

| Field | Meaning |
| --- | --- |
| `kind` | Identifies the strict requirement object. |
| `format_version` | Version for this internal source shape. |
| `mode` | `strict_contract_digest` only for the first live candidate. |
| `source` | Must be `internal_orchestrator_option` for this design route. |
| `refusal_candidates` | Initially only `compiler_profile_contract.contract_digest_mismatch`. |
| `recompute_unavailable_policy` | Initially `fail_open_report_only`. |
| `compile_refusal_authorized` | Must remain false until a later implementation gate authorizes live refusal. |

Legacy behavior:

| Condition | Required behavior |
| --- | --- |
| No strict requirement option | Existing report-only behavior unchanged. |
| Strict requirement nil | Existing report-only behavior unchanged. |
| Strict requirement non-Hash / malformed | Future design must choose configuration-error or ignored; no accidental refusal. |
| No provider | No validation field and no refusal. |
| Provider nil/non-Hash/error | No validation field and no refusal. |
| Validator error | No validation field and no refusal unless a later fail-closed policy opens. |

Public shielding:

- no Ruby facade argument;
- no CLI flag;
- no environment discovery;
- no manifest/profile policy;
- no loader/report interpretation;
- no default strict behavior.

---

## Source Validation Placement

Future strict source validation, if later authorized, should occur inside
`CompilerOrchestrator#compile` after contract validation evidence is available
and before assembly is invoked.

Recommended design sequence:

```text
compile report is ok
  -> call compiler_profile_contract_provider
  -> if provider returns Hash: validate contract
  -> attach or prepare report-only validation metadata
  -> if internal strict requirement source exists:
       validate strict requirement shape
       evaluate trigger against validator result
  -> if trigger allows:
       continue current success / assembly path
  -> if trigger would_refuse and live refusal is later authorized:
       produce strict refusal status/result before assembly
```

Do not evaluate strict source when there is no validation result. Missing
provider/validation remains no-field/no-refusal for this design.

Do not treat:

```text
validation["valid"] == false
```

as a refusal trigger by itself. The trigger must match an authorized refusal
candidate and strict requirement source.

---

## Status / Result Vocabulary Proposal

Keep vocabulary layered:

| Vocabulary | Layer | Status |
| --- | --- | --- |
| `not_evaluated`, `allow`, `would_refuse`, `configuration_error` | Proof-local trigger model | Accepted by R77. |
| `strict_validation_requested` | Internal trigger input | Design-only. |
| `compiler_profile_contract_refusal.*` | Wrapper evidence code namespace | Design/proof-local; not diagnostics centralization. |
| `refused` | Future live compiler status | Design-only here. |
| `oof`, `error`, `assembler_refused`, `runtime_smoke_failed` | Existing compiler statuses | Unchanged. |

Recommendation:

```text
Do not map strict contract failure to existing oof or error status.
```

Reason:

- `oof` means ordinary compiler/type/OOF failure from current report pass result;
- `error` means parse/internal/preflight-style failures;
- strict profile contract refusal is a distinct policy decision with different
  evidence and recovery.

Recommended future live status:

```text
refused
```

But `refused` requires separate `CompilerResult` authority. This track does not
authorize that status.

Design-only structured refusal evidence:

```json
{
  "status": "refused",
  "reason_code": "compiler_profile_contract_refusal.contract_digest_mismatch",
  "evidence_code": "compiler_profile_contract.contract_digest_mismatch",
  "strict_validation_source": "internal_orchestrator_option",
  "strict_validation_mode": "strict_contract_digest",
  "compile_refusal_authorized": true
}
```

Current public result shape remains closed. Wrapper evidence should not appear
in CLI or public API output until public result behavior is separately accepted.

---

## `CompilerResult` Boundary

Any future live implementation must decide whether to:

| Option | Meaning | `CompilerResult` authority needed? | Recommendation |
| --- | --- | --- | --- |
| Reuse `CompilerResult.refusal(...)` | Return existing refusal result shape, possibly with status `refused`. | Yes, because status/reason/public result behavior must be verified. | Not first unless report-write path is also accepted. |
| Add `CompilerResult.strict_refusal(...)` | Separate constructor for strict profile refusal. | Yes, explicit schema/visibility change. | Best long-term shape, but needs design/implementation authority. |
| Return `CompilerResult.ok(...)` with nested refusal metadata | Not true refusal. | Yes if metadata leaks to result; semantically weak. | Not recommended. |
| Raise exception | Avoid result schema changes. | Maybe less schema, but public API/CLI behavior changes. | Not recommended. |

Recommended status/result route before implementation:

```text
Design a new strict-refusal result shape first, then request explicit
CompilerResult authority.
```

Do not reuse public result fields or top-level diagnostics implicitly.

---

## Refusal Report Strategy Comparison

| Strategy | Meaning | Pros | Risks | Recommendation |
| --- | --- | --- | --- | --- |
| Reuse `CompilerOrchestrator#refusal` | Call existing refusal path and accept `.compilation_report.json` write. | Minimal new control flow; matches existing refusal mechanics. | Violates "no persisted report" first-live stance; must design report schema and user-visible artifact behavior. | Defer unless persisted report policy is accepted. |
| New non-persisting strict refusal path | Return a refusal result before assembly without writing report file. | Resolves R78 NB-2; keeps first live candidate in-memory; avoids sidecar policy. | New orchestrator path; needs exact result/status design and proof. | Recommended first live implementation design candidate. |
| Distinct PROP-038 refusal report policy | Write a separate strict-refusal report/schema. | Clean dedicated artifact if persistence is desired. | Opens report artifact policy, paths, lifecycle, and compatibility surface. | Defer. |

Recommendation:

```text
first design candidate = new non-persisting strict refusal path
```

Reason:

- it resolves the `#refusal` report-write tension without changing existing
  refusal behavior;
- it keeps live PROP-038 strict refusal separate from ordinary compile refusal
  until status/result semantics are accepted;
- it avoids adding persisted reports or sidecars before a report schema exists;
- it preserves `.igapp` by skipping assembly for the refused path.

Do not modify `CompilerOrchestrator#refusal` unless a later gate explicitly
authorizes either:

```text
reuse with persisted report
or
new no-write mode
```

Both are implementation choices, not accepted behavior here.

---

## Assembly / `report_for_assembly` Boundary

Preserve current accepted boundary:

```text
report_for_assembly = report
```

is captured before report-only validation annotation, and assembler receives
that pre-annotation report.

Future strict path:

| Trigger decision | Assembly stance |
| --- | --- |
| no strict source | Existing assembly behavior unchanged. |
| strict source + `allow` | Existing assembly behavior unchanged. |
| strict source + `configuration_error` | Must be separately designed; should not assemble if it becomes a live compiler stop. |
| strict source + future live `refused` | Assembly skipped before `Assembler.assemble_artifacts`. |

`.igapp` stance:

- no `.igapp` mutation in report-only path;
- no `.igapp` mutation in future refused path;
- no strict/refusal fields added to `.igapp`;
- no assembler vocabulary change;
- no `compiler_profile_source.*` reuse for PROP-038 strict refusal.

If a future design wants refusal artifacts, it must open a separate artifact
policy and not smuggle those artifacts through `.igapp`.

---

## Exact Blockers Before Implementation Authorization

Blocking items:

1. Accepted internal strict source shape and validation behavior.
2. Accepted malformed strict requirement policy: ignored vs configuration error.
3. Accepted live status/result shape, including whether `refused` is a new
   status.
4. Explicit `CompilerResult` authority if result shape changes.
5. Accepted non-persisting strict refusal path or accepted persisted report
   policy.
6. Accepted assembly skip behavior and `report_for_assembly` invariants.
7. Accepted public API/CLI non-widening proof or explicit widening decision.
8. Accepted legacy/no-field/no-refusal behavior for provider and validator
   errors.
9. Accepted fail-open policy for recompute unavailable, or separate fail-closed
   recovery design.
10. Accepted proof-local-to-live graduation rule:
    `would_refuse` may become `refused` only for mismatch.
11. Exact authorized write scope.
12. Updated proof/regression command matrix with syntax checks for any new proof
    scripts.

No implementation card should open until all blockers are explicitly closed by
an Architect decision.

---

## Proof / Regression Matrix For Future Implementation Review

### Required Existing Regression Commands

```bash
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb
```

### Required Future Syntax Checks

If a future implementation adds proof scripts, include:

```bash
ruby -c igniter-lang/experiments/<future_strict_live_refusal_proof>/<script>.rb
```

If it edits live files, include syntax checks for each edited Ruby file,
including at minimum:

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb
```

only if those files are in the authorized write scope.

### Strict Source Cases

| Case | Expected |
| --- | --- |
| no strict requirement | Current report-only behavior unchanged. |
| strict requirement nil | Current report-only behavior unchanged. |
| strict requirement malformed | Follows accepted malformed-policy decision; no accidental refusal. |
| strict requirement + valid contract | Compile succeeds; assembly behavior unchanged. |
| strict requirement + digest mismatch | Future live behavior follows accepted strict-refusal result path. |
| strict requirement + invalid digest | Does not refuse unless candidate scope expands. |
| strict requirement + unsupported policy | Configuration-error behavior follows accepted status design. |
| strict requirement + recompute unavailable | Fail-open/report-only unless fail-closed policy is separately accepted. |

### Legacy And Error Cases

| Case | Expected |
| --- | --- |
| no provider | No validation field and no refusal. |
| provider returns nil | No validation field and no refusal. |
| provider returns non-Hash | No validation field and no refusal. |
| provider raises | No validation field and no refusal. |
| validator raises | No validation field and no refusal unless separately authorized. |
| existing parse/type/oof failure | Existing refusal/error behavior unchanged. |

### Result / Report Cases

| Case | Expected |
| --- | --- |
| report-only invalid validation | Public result unchanged; no persisted report from validation. |
| strict mismatch refused | Result/status matches accepted strict-refusal shape. |
| strict mismatch refused | Wrapper evidence cites validator diagnostic. |
| strict mismatch refused | No top-level diagnostics centralization unless accepted. |
| strict mismatch refused | Report write behavior matches chosen strategy. |

### Assembly Cases

| Case | Expected |
| --- | --- |
| report-only mismatch | Assembly unchanged from R67/R74. |
| strict valid | Assembly unchanged. |
| strict mismatch refused | Assembly skipped before `.igapp` artifacts. |
| strict mismatch refused | No `.igapp` mutation. |

### Boundary Guards

- no public API/CLI widening unless explicitly authorized;
- no loader/report or CompatibilityReport behavior;
- no `IgniterLang::Diagnostics` centralization;
- no runtime or production behavior;
- no `compiler_profile_source.*` vocabulary reuse for PROP-038 strict refusal;
- no persisted reports unless chosen report strategy authorizes them.

---

## Recommended Next Route

Recommended next route:

```text
strict-refusal-result-shape-and-nonpersisting-path-design-v0
```

Goal:

```text
Design the strict-refusal result shape and non-persisting orchestrator path in
enough detail to decide whether implementation authorization can be considered.
```

Keep held:

- live implementation;
- Ruby API;
- CLI;
- manifest/profile policy;
- persisted reports/sidecars;
- loader/report;
- CompatibilityReport;
- fail-closed recompute unavailable;
- runtime/production behavior.

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
- live compile refusal;
- compiler/orchestrator behavior changes;
- public API/CLI widening;
- `CompilerResult` changes;
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

- internal strict source shape is explicit and constructor-only;
- public API/CLI and manifest/profile strict sources remain closed;
- status/result vocabulary keeps `refused` design-only until `CompilerResult`
  authority opens;
- report-write tension is resolved by recommending a new non-persisting strict
  refusal path as the first live design candidate;
- `report_for_assembly` and `.igapp` boundaries remain protected;
- implementation blockers and proof matrix are explicit.
