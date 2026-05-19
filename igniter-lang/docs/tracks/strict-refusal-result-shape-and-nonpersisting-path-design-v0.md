# Track: Strict Refusal Result Shape And Nonpersisting Path Design v0

Card: S3-R80-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `strict-refusal-result-shape-and-nonpersisting-path-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design the strict-refusal result shape and non-persisting orchestrator path for
a possible future PROP-038 live refusal implementation, without authorizing
implementation.

This track is design-only. It does not edit code, enable live compile refusal,
change compiler/orchestrator behavior, widen public API/CLI behavior, change
`CompilerResult`, write persisted reports or sidecars, mutate `.igapp`, or open
loader/report, CompatibilityReport, runtime, or production behavior.

---

## Inputs Read

- `docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md`
- `docs/tracks/internal-orchestrator-strict-source-and-status-design-v0.md`
- `docs/tracks/prop038-refusal-report-and-result-surface-survey-v0.md`
- `docs/discussions/prop038-internal-strict-source-status-pressure-v0.md`
- `docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md`
- `docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round79-status-curation-v0.md`

---

## Current Surface Facts

R79 survey establishes:

- current live compiler has no `status: "refused"`;
- current refusal paths use `CompilerOrchestrator#refusal`;
- `CompilerOrchestrator#refusal` always writes a sidecar compilation report;
- `CompilerResult.public_result(...)` strips only the internal `report` key;
- any new top-level result key becomes public by default;
- `CompilerResult.refusal(...)` derives public diagnostics only from top-level
  `report["diagnostics"]`;
- nested `compiler_profile_contract_validation.diagnostics` are ignored by the
  current refusal constructor;
- current PROP-038 validation remains report-only and nested;
- `report_for_assembly` is captured before report-only validation annotation;
- `.igapp` artifacts do not receive PROP-038 validation metadata today.

R79 decision requires this track to resolve:

- public result key-set behavior;
- nested diagnostics isolation;
- malformed strict requirement policy;
- non-persisting refusal-path design.

---

## Strict-Refusal Status Model

Recommendation:

```text
future strict digest refusal should use status "refused"
```

Layering:

| Layer | Proposed future value | Notes |
| --- | --- | --- |
| Orchestration status | `refused` | Future live status candidate only. |
| `CompilerResult["status"]` | `refused` | Requires explicit `CompilerResult` authority. |
| `report["pass_result"]` | Preserve baseline `ok` | Do not rewrite normal compiler pass semantics. |
| Trigger decision | `would_refuse` in proof, `refused` only after live gate | R77 proof vocabulary does not become live by rename. |
| CLI exit behavior | non-ok if public CLI ever sees `refused` | Requires separate CLI/API decision. |

Why not `oof` or `error`:

- `oof` is already used for normal compiler/type/OOF failure.
- `error` is used for parse/internal/preflight-style failures.
- strict contract digest refusal is a policy decision after a baseline compile
  has reached `pass_result: "ok"`.

Why not mutate `report["pass_result"]`:

- it would route through the existing main refusal gate and sidecar write path;
- it would blur normal compiler failure with strict profile policy failure;
- it would make `.compilation_report.json` persistence easy to trigger by
  accident.

Design rule:

```text
strict refusal status is layered beside the baseline report, not encoded by
changing report["pass_result"].
```

---

## Strict-Refusal Result Shape Proposal

This shape is a future design target only. It is not accepted as live
`CompilerResult` schema.

### Internal Result Shape

Recommended internal strict-refusal result fields:

```json
{
  "kind": "compiler_result",
  "format_version": "0.1.0",
  "status": "refused",
  "program_id": "semantic_ir/sha256:<...>",
  "source_path": "path/to/source.ig",
  "source_hash": "sha256:<64 hex>",
  "grammar_version": "0.1.0",
  "stages": {
    "parse": "ok",
    "classify": "ok",
    "typecheck": "ok",
    "emit": "ok",
    "assemble": "skipped"
  },
  "igapp_path": null,
  "contracts": [],
  "compilation_report_path": null,
  "diagnostics": [
    {
      "code": "compiler_profile_contract_refusal.contract_digest_mismatch",
      "message": "Strict compiler profile contract validation refused compilation because contract_digest does not match canonical contract material.",
      "path": "compiler_profile_contract_validation.contract_digest",
      "evidence_code": "compiler_profile_contract.contract_digest_mismatch"
    }
  ],
  "warnings": [],
  "report": {
    "pass_result": "ok",
    "compiler_profile_contract_validation": {
      "valid": false,
      "diagnostic_codes": [
        "compiler_profile_contract.contract_digest_mismatch"
      ],
      "report_only": true
    }
  }
}
```

Field policy:

| Field | Policy |
| --- | --- |
| `status` | Future `refused` only after separate authority. |
| `program_id` | Use `semantic_ir_ref` when available; otherwise nil. Do not use contract digest or report id. |
| `source_hash` | Preserve source hash semantics; do not replace with contract digest. |
| `stages.assemble` | `skipped` because refusal is pre-assembly. |
| `igapp_path` | nil. No artifact was produced. |
| `contracts` | empty, matching refusal-style behavior. |
| `compilation_report_path` | nil for non-persisting path. |
| `diagnostics` | Public wrapper diagnostic only, if public diagnostics are authorized. |
| `report` | Internal only; stripped by `public_result`. Contains nested validation evidence. |

### Public Result Shape

Recommended public result key set, if strict refusal public result is later
authorized:

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

The public result must not include:

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

Any evidence exposed publicly must be inside the accepted public diagnostic
shape, not as new top-level result keys.

---

## Program Identity And Evidence References

Policy:

| Value | Future strict-refusal behavior |
| --- | --- |
| `program_id` | Use `semantic_ir_ref` if the baseline compile emitted one. If strict refusal happens before SemanticIR exists in some future path, use nil. |
| `source_hash` | Preserve the source hash from the compiled source. |
| `contract_digest` | Evidence only; not `program_id`. |
| `compiler_profile_contract_refusal.*` | Wrapper reason code for public/compiler refusal diagnostics. |
| `compiler_profile_contract.*` | Underlying validator evidence code; remains nested in validation result. |

Reason:

- strict refusal is about profile contract identity, but the attempted compile is
  still identified by source and SemanticIR evidence where available;
- using contract digest as `program_id` would confuse program identity with
  profile policy identity.

---

## Non-Persisting Orchestrator Path Design

Recommendation:

```text
future first live implementation candidate should use a new non-persisting
strict refusal path, not CompilerOrchestrator#refusal.
```

Design placement:

```text
CompilationReport.enrich(...)
  -> report_for_assembly = report
  -> provider returns Hash
  -> CompilerProfileContractValidator.validate(...)
  -> report-only validation metadata prepared/attached
  -> internal strict requirement evaluated
  -> if strict mismatch would refuse and live gate authorizes refused:
       return strict-refusal result in memory
       do not call CompilerOrchestrator#refusal
       do not write .compilation_report.json
       do not call Assembler.assemble_artifacts
       do not mutate .igapp
  -> otherwise continue current report-only/success path
```

Path properties:

| Property | Required behavior |
| --- | --- |
| Existing `CompilerOrchestrator#refusal` | Unchanged. Ordinary parse/oof/assembler/runtime-smoke refusal still uses it. |
| New strict path | Separate future path; non-persisting. |
| Report writes | None for strict refusal first candidate. |
| Sidecars | None. |
| Assembly | Skipped for future strict refused path. |
| `.igapp` | Not created or mutated by strict refused path. |
| Report-only mode | Current behavior unchanged. |

Do not implement a no-write mode on `CompilerOrchestrator#refusal` in the first
candidate unless a later gate explicitly chooses that strategy. A new
strict-refusal path is easier to prove because it leaves all existing refusal
behavior untouched.

---

## Malformed Strict Requirement Policy

Options:

| Option | Meaning | Pros | Risks | Recommendation |
| --- | --- | --- | --- | --- |
| Ignored | Treat malformed strict requirement as absent. | Preserves compile behavior. | Silently disables strict mode; dangerous for explicit opt-in. | Not recommended. |
| Configuration error | Treat malformed strict requirement as an internal strict-source configuration error. | Fails visibly in strict-source design without pretending contract mismatch. | Needs status/result policy. | Recommended. |
| Proof-local only | Only model malformed behavior in proof, leave live open. | Avoids commitment. | Leaves implementation discretion open. | Not recommended. |
| Refusal | Treat malformed strict requirement as strict compile refusal. | Strong. | Confuses source configuration with contract digest mismatch. | Not recommended. |

Decision/recommendation:

```text
malformed strict requirement => configuration_error
```

Policy details:

- configuration error is not `compiler_profile_contract_refusal.contract_digest_mismatch`;
- configuration error is not caused by validator diagnostics;
- configuration error must not be produced when no strict source exists;
- configuration error must not be exposed through public API/CLI until a result
  shape is accepted;
- if later live, it should stop before assembly just like any strict-source
  terminal condition, but it must use a distinct status/reason from contract
  digest refusal.

Suggested design-only reason code:

```text
compiler_profile_contract_refusal.strict_requirement_malformed
```

This code is design-only and not `IgniterLang::Diagnostics`.

---

## Public Result Key-Set Policy

R79 pressure requires an explicit public result key-set assertion.

Policy:

```text
future strict-refusal public_result keys must match an accepted allowlist exactly.
```

Recommended allowlist:

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

Required proof assertion:

```text
public_result.keys == strict_refusal_public_key_allowlist
```

Required negative assertions:

- no `report` key;
- no nested `compiler_profile_contract_validation` key;
- no `strict_refusal` key;
- no `wrapper_evidence` key;
- no `compile_refusal_authorized` key;
- no raw nested validator diagnostic objects as top-level fields.

Rationale:

`CompilerResult.public_result` currently strips only `report`. Therefore any
new top-level key becomes public unless proof explicitly guards the key set.

---

## Nested Diagnostics Exposure Policy

R79 pressure also requires nested-diagnostics isolation.

Policy:

```text
nested compiler_profile_contract_validation.diagnostics remain internal report
evidence and must not be promoted to public diagnostics by default.
```

Public diagnostics, if future strict refusal result is accepted, should contain
one wrapper diagnostic:

```json
{
  "code": "compiler_profile_contract_refusal.contract_digest_mismatch",
  "message": "Strict compiler profile contract validation refused compilation because contract_digest does not match canonical contract material.",
  "path": "compiler_profile_contract_validation.contract_digest",
  "evidence_code": "compiler_profile_contract.contract_digest_mismatch"
}
```

Nested evidence remains:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
```

Do not append raw nested diagnostics to:

```text
report["diagnostics"]
```

Do not centralize wrapper or nested diagnostics in:

```text
IgniterLang::Diagnostics
```

unless a later decision explicitly opens diagnostics centralization.

Required proof assertions:

- public diagnostics contain wrapper code only;
- public diagnostics do not contain raw
  `compiler_profile_contract.contract_digest_mismatch`;
- nested validation diagnostics remain present inside internal `report`;
- top-level report diagnostics remain unchanged unless separately authorized.

---

## Report-Only And Legacy Preservation

Current behavior remains:

| Path | Required behavior |
| --- | --- |
| no strict requirement | Report-only behavior unchanged. |
| no provider | No validation field; no refusal. |
| provider nil | No validation field; no refusal. |
| provider non-Hash | No validation field; no refusal. |
| provider raises | No validation field; no refusal. |
| validator raises | No validation field; no refusal unless a separate fail-closed policy opens. |
| report-only invalid digest | Nested diagnostics only; compile/assembly unchanged. |

Strict mode must not be inferred from:

- provider presence;
- invalid validation result;
- nested diagnostic existence;
- `report_only: true`;
- `digest_reference_policy`;
- `contract_digest_mismatch`;
- CLI `--compiler-profile-source`;
- `.igapp` manifest content;
- loader/report vocabulary.

---

## `report_for_assembly` And `.igapp` Boundary

Preserve:

```text
report_for_assembly = report
```

as the current pre-validation assembly boundary for report-only behavior.

Future non-persisting strict path:

| Path | Assembly behavior |
| --- | --- |
| report-only | Current assembly behavior unchanged. |
| strict source + valid contract | Current assembly behavior unchanged. |
| strict source + mismatch refused | Do not call assembler. |
| strict source + malformed requirement configuration error | Do not call assembler if it becomes a live terminal status. |

`.igapp` policy:

- no strict-refusal fields in `.igapp`;
- no mutation to `.igapp` manifests or contract files;
- no `.igapp/compilation_report.json` from strict refused path;
- no reuse of `compiler_profile_source.*` assembler vocabulary for PROP-038
  strict refusal.

---

## Proof / Regression Matrix

### Existing Proof Chain

Must remain PASS:

```bash
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb
```

### Future Live Proof Syntax

If a future proof script is authorized:

```bash
ruby -c igniter-lang/experiments/<future_strict_refusal_result_proof>/<script>.rb
ruby igniter-lang/experiments/<future_strict_refusal_result_proof>/<script>.rb
```

If live files are edited, syntax-check each authorized Ruby file.

### Result Shape Assertions

| Assertion | Expected |
| --- | --- |
| `status` | `refused` only in strict-refusal result case. |
| `report["pass_result"]` | Preserved baseline value, expected `ok` for strict mismatch path. |
| `program_id` | `semantic_ir_ref` when present; nil only if no SemanticIR exists. |
| `source_hash` | Matches source hash, not contract digest. |
| `compilation_report_path` | nil for non-persisting strict refusal path. |
| `igapp_path` | nil for strict refused path. |
| `stages["assemble"]` | `skipped` for strict refused path. |

### Public Result Key-Set Assertions

| Assertion | Expected |
| --- | --- |
| public key allowlist | Exact match to accepted strict-refusal public key set. |
| public `report` key | absent. |
| public `compiler_profile_contract_validation` key | absent. |
| public `strict_refusal` / `wrapper_evidence` keys | absent. |
| public `compile_refusal_authorized` key | absent. |

### Nested Diagnostics Isolation Assertions

| Assertion | Expected |
| --- | --- |
| nested validation diagnostics | remain under internal `report["compiler_profile_contract_validation"]["diagnostics"]`. |
| public diagnostics | wrapper diagnostic only if public diagnostics are accepted. |
| raw validator code in public diagnostics | absent unless separately authorized. |
| top-level `report["diagnostics"]` | unchanged unless separately authorized. |
| `IgniterLang::Diagnostics` centralization | absent. |

### Non-Persisting Path Assertions

| Assertion | Expected |
| --- | --- |
| `.compilation_report.json` sidecar | not written for strict refused path. |
| distinct PROP-038 report | not written. |
| `.igapp` directory | not created or mutated by strict refused path. |
| `CompilerOrchestrator#refusal` | not called for strict refused path if non-persisting strategy is chosen. |

### Legacy And Report-Only Assertions

| Case | Expected |
| --- | --- |
| no strict source | current report-only behavior unchanged. |
| malformed strict source | configuration error policy, not accidental digest refusal. |
| no provider / nil / non-Hash / provider error | no-field/no-refusal. |
| validator error | no-field/no-refusal unless separately authorized. |
| report-only invalid digest | compile status/public result/assembly unchanged. |

### Public API / CLI Assertions

| Assertion | Expected |
| --- | --- |
| `IgniterLang.compile(...)` signature | unchanged unless separately authorized. |
| CLI flags | unchanged; no strict flag. |
| CLI stdout for normal paths | unchanged. |
| CLI exit behavior | unchanged unless public status behavior is separately authorized. |

---

## Exact Blockers Before Implementation Authorization

Blocking items:

1. Explicit acceptance of strict-refusal result shape.
2. Explicit `CompilerResult` authority for `status: "refused"` and public result
   key-set behavior.
3. Explicit acceptance of non-persisting orchestrator path and exact write scope.
4. Explicit decision that `CompilerOrchestrator#refusal` is not reused for the
   first strict-refusal path, or explicit persisted-report policy if reused.
5. Accepted malformed strict requirement policy:
   `configuration_error`.
6. Accepted nested diagnostics exposure policy.
7. Accepted public wrapper diagnostic shape.
8. Accepted no-report/no-sidecar behavior.
9. Accepted assembly skip and `.igapp` non-mutation behavior.
10. Accepted legacy/no-source/no-refusal preservation.
11. Accepted no public API/CLI widening proof.
12. Accepted fail-open recompute-unavailable behavior, or separate fail-closed
    recovery design.
13. Exact proof command matrix, including syntax checks for any new proof script
    and authorized live files.

No implementation card should open until all blockers are explicitly closed by
an Architect decision.

---

## Recommended Next Route

Recommended next route:

```text
strict-refusal-result-shape-pressure-v0
```

Purpose:

```text
Pressure-review the strict-refusal result shape, non-persisting path,
malformed-policy decision, public key-set policy, and nested-diagnostics
isolation before any implementation authorization is considered.
```

Hold:

- code implementation;
- live refusal;
- public API/CLI;
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

- future `refused` status is layered as orchestration/result status, not
  `report["pass_result"]`;
- result shape preserves program/source identity and keeps contract digest as
  evidence only;
- non-persisting path avoids `CompilerOrchestrator#refusal` sidecar writes;
- malformed strict requirement policy is resolved as `configuration_error`;
- public result key-set and nested-diagnostics isolation requirements are
  explicit;
- report-only, legacy/no-source, `report_for_assembly`, and `.igapp` boundaries
  remain protected.
