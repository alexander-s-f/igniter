# Track: PROP-038 Contract Digest Strict-Mode Refusal Trigger Design v0

Card: S3-R76-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-contract-digest-strict-mode-refusal-trigger-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-contract-digest-compile-refusal-preconditions-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design strict-mode/refusal trigger semantics and user-facing compiler refusal
wording for a possible future PROP-038 `contract_digest` compile-refusal gate,
without implementing or enabling refusal.

This track is design-only. It does not edit code, create a proof-local refusal
experiment, enable compile refusal, change compiler/orchestrator behavior, widen
public API/CLI behavior, mutate `.igapp` artifacts, or centralize diagnostics.

---

## Inputs Read

- `docs/gates/prop038-contract-digest-compile-refusal-preconditions-decision-v0.md`
- `docs/tracks/prop038-contract-digest-compile-refusal-preconditions-design-v0.md`
- `docs/discussions/prop038-contract-digest-compile-refusal-preconditions-pressure-v0.md`
- `docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round75-status-curation-v0.md`

---

## Current Accepted State

R74 accepted live internal validator diagnostics for:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

R75 accepted the preconditions design and keeps this core rule:

```text
compiler_profile_contract.* diagnostic != compile refusal
```

Current live behavior remains:

- validator diagnostics may be emitted;
- report-only integration may attach nested in-memory validation metadata;
- diagnostics remain under `compiler_profile_contract_validation.diagnostics`;
- top-level `report["diagnostics"]` remains unchanged;
- compile status remains unchanged;
- public result remains unchanged;
- nil, non-Hash, provider-error, and validator-error paths remain
  no-field/no-refusal;
- compile refusal remains closed.

---

## Strict-Mode Source Option Table

| Source option | Meaning | First proof-local fit | Public-surface risk | Recommendation |
| --- | --- | --- | --- | --- |
| Internal orchestrator option | Future internal option asks compiler/orchestrator to evaluate a supplied contract under strict mode. | Good eventual implementation shape, but it touches compiler/orchestrator behavior. | Medium: could accidentally become production behavior. | Not first. Require proof-local model first. |
| Accepted public API option | Future `IgniterLang.compile(...)` option exposes strict contract requirement to callers. | Poor first fit. | High: widens public API and compatibility surface. | Defer. Requires separate API design. |
| Accepted CLI flag | Future CLI flag enables strict contract requirement. | Poor first fit. | High: user-visible behavior and wording must be stable first. | Defer. Requires separate CLI design. |
| Accepted manifest/profile policy | Future manifest/profile policy declares profile requirement. | Poor first fit. | High: crosses into `.igapp`, loader/report, and profile rollout semantics. | Defer. Requires loader/report alignment. |
| Accepted gate-controlled profile requirement | Proof-local object says strict contract validation is required for the proof scenario. | Best first fit. | Low if kept proof-local and non-production. | Recommended first proof-local source. |

Recommended first future proof-local source:

```text
gate-controlled proof-local strict requirement object
```

Reason:

- it can model strict/refusal trigger semantics without widening API/CLI;
- it can consume the accepted live validator result without changing the
  validator API;
- it can keep public compile behavior unchanged;
- it can prove whether the trigger vocabulary and wording are coherent before
  any compiler/orchestrator implementation is requested.

Suggested proof-local shape if later authorized:

```json
{
  "kind": "compiler_profile_contract_strict_requirement",
  "format_version": "0.1.0",
  "mode": "strict_contract_digest",
  "source": "proof_local_gate",
  "refusal_candidates": [
    "compiler_profile_contract.contract_digest_mismatch"
  ],
  "recompute_unavailable_policy": "fail_open_report_only",
  "compile_refusal_authorized": false
}
```

The final field remains false in proof design unless a later Architect gate
explicitly authorizes a proof-local refusal model. This shape is not a runtime
or compiler API.

---

## Trigger Vocabulary Proposal

Keep trigger state distinct from validator diagnostics.

| Vocabulary item | Layer | Meaning |
| --- | --- | --- |
| `report_only` | Compiler report mode | Current behavior. Validation may annotate nested report metadata and must not affect compile result. |
| `strict_validation_requested` | Future trigger input | A caller, gate, or proof-local source explicitly requires strict contract validation. |
| `strict_validation_source` | Future trigger input | The authority that requested strict validation, such as `proof_local_gate`, future internal option, API, CLI, or manifest policy. |
| `refusal_candidate_diagnostic` | Validator evidence | A `compiler_profile_contract.*` diagnostic that a strict policy may consider. |
| `compiler_refusal_decision` | Compiler-level decision | Future wrapper decision that may refuse compile if strict mode is authorized and candidate evidence qualifies. |
| `loader_report_status` | Loader/report layer | Manifest/load interpretation; not a compile trigger here. |
| `runtime_readiness` | Runtime layer | Execution or production readiness; not implied by digest validity. |

Recommended proof-local trigger record:

```json
{
  "kind": "compiler_profile_contract_refusal_trigger_evaluation",
  "format_version": "0.1.0",
  "mode": "report_only",
  "strict_validation_requested": false,
  "strict_validation_source": null,
  "refusal_candidate_diagnostics": [],
  "compiler_refusal_decision": "not_evaluated",
  "compiler_refusal_authorized": false
}
```

If strict proof-local evaluation is later authorized, `mode` may become:

```text
strict_contract_digest
```

Allowed proof-local decision vocabulary:

| Decision | Meaning |
| --- | --- |
| `not_evaluated` | Report-only mode or no strict source. |
| `allow` | Strict source exists and no authorized refusal candidate is present. |
| `would_refuse` | Proof-local model only: an authorized candidate would cause refusal if compile refusal were enabled. |
| `configuration_error` | Strict policy selection itself is invalid or unsupported. |

Do not use `refused` until a later implementation gate actually authorizes
compile refusal.

---

## Wrapper Code Decision

Recommendation:

```text
Use compiler-level wrapper codes that cite compiler_profile_contract.*
diagnostics as evidence.
```

Reason:

- validator diagnostics describe contract-object invalidity;
- compiler refusal describes a compiler decision under explicit strict mode;
- user-facing compiler messages need source, mode, and recovery context;
- wrapper codes prevent `compiler_profile_contract.*` from silently becoming
  compile-status vocabulary.

Proposed wrapper code namespace for proof-local design:

```text
compiler_profile_contract_refusal.*
```

Initial wrapper codes:

| Wrapper code | Evidence diagnostic | Meaning |
| --- | --- | --- |
| `compiler_profile_contract_refusal.contract_digest_mismatch` | `compiler_profile_contract.contract_digest_mismatch` | Strict contract digest identity check would refuse because declared digest conflicts with canonical contract material. |
| `compiler_profile_contract_refusal.contract_digest_invalid` | `compiler_profile_contract.contract_digest_invalid` | Strict contract digest identity check would refuse because the supplied contract digest is missing or malformed. |
| `compiler_profile_contract_refusal.contract_digest_policy_unsupported` | `compiler_profile_contract.contract_digest_policy_unsupported` | Strict policy selection cannot be evaluated as requested. |
| `compiler_profile_contract_refusal.contract_digest_recompute_unavailable` | `compiler_profile_contract.contract_digest_recompute_unavailable` | Strict evaluation could not recompute digest; behavior depends on accepted fail-open/fail-closed policy. |

These are design vocabulary only. They are not `IgniterLang::Diagnostics`, not
top-level report diagnostics, and not public API.

---

## User-Facing Wording Matrix

Use concise wording that names the strict mode and cites underlying evidence.

| Context | Proposed wording | Notes |
| --- | --- | --- |
| API | `Compile refused: strict compiler profile contract validation failed. Evidence: compiler_profile_contract.contract_digest_mismatch for contract_digest.` | Suitable for exception/result text if API refusal is later authorized. Not active now. |
| CLI | `Compile refused by strict profile contract policy: contract_digest does not match canonical contract material.` | CLI can be more direct, but must still cite evidence in structured output if such output is later authorized. |
| Proof harness | `would_refuse: compiler_profile_contract_refusal.contract_digest_mismatch evidence=compiler_profile_contract.contract_digest_mismatch` | Proof should avoid claiming live refusal. |
| Report-only mode | `Profile contract validation reported compiler_profile_contract.contract_digest_mismatch; compile result unchanged.` | Current behavior wording. |
| Recompute unavailable, fail-open | `Strict profile contract digest could not be recomputed; policy is fail-open, so compile proceeds with report-only evidence.` | Only if fail-open policy is accepted. |
| Recompute unavailable, fail-closed | `Compile refused: strict profile contract digest recomputation was unavailable under fail-closed policy.` | Only if fail-closed policy is accepted later. |

Wording constraints:

- do not promise runtime readiness;
- do not imply loader/report acceptance;
- do not say `.igapp` output is verified;
- do not expose private canonicalization helper names;
- include the evidence diagnostic code in structured proof/API output;
- reserve human prose for UX, not for authority.

---

## Fail-Open / Fail-Closed Policy Options

`contract_digest_recompute_unavailable` is the only digest diagnostic that may
come from validator capability or unexpected canonicalization failure rather
than contract identity contradiction.

| Policy | Meaning | Pros | Risks | Recommendation |
| --- | --- | --- | --- | --- |
| Fail-open report-only | Compile proceeds; nested diagnostics record recompute unavailable. | Preserves current behavior and avoids internal failures breaking compile. | Strict mode is less strict for this one failure class. | Recommended for first proof-local model. |
| Fail-closed | Compile would refuse when recompute is unavailable. | Strong integrity posture. | User may be blocked by internal canonicalizer/capability failure; recovery story is unclear. | Defer until operational recovery is designed. |
| Configuration error | Treat unavailable recompute as strict-policy configuration failure, not contract refusal. | Separates policy/capability from contract invalidity. | Requires a separate status vocabulary. | Good future option, not first. |
| Dual policy | Strict mode declares either fail-open or fail-closed. | Flexible. | Adds configuration surface and proof matrix size. | Defer until public/internal source is chosen. |

Recommended first proof-local policy:

```text
contract_digest_recompute_unavailable => fail_open_report_only
```

Reason:

- R75 held this diagnostic by default;
- current report-only behavior is proven stable;
- mismatch is the stronger first refusal candidate;
- fail-closed needs user recovery and operational support that do not exist yet.

---

## Refined Proof-Local Refusal Matrix

No proof-local refusal experiment is authorized by this track. If one opens
later, it should use the proof-local gate source and prove this matrix.

### Mode Separation

| Case | Expected |
| --- | --- |
| report-only + valid contract | Compile/result behavior unchanged; nested validation may be valid. |
| report-only + digest mismatch | Compile/result behavior unchanged; nested diagnostic only. |
| report-only + digest invalid | Compile/result behavior unchanged; nested diagnostic only. |
| report-only + recompute unavailable | Compile/result behavior unchanged; nested diagnostic only. |
| no strict source | Trigger evaluation is `not_evaluated`. |

### Strict Proof-Local Trigger

| Case | Expected |
| --- | --- |
| strict source + valid contract | Trigger evaluation `allow`; no refusal candidate. |
| strict source + digest mismatch | Trigger evaluation `would_refuse` with wrapper `compiler_profile_contract_refusal.contract_digest_mismatch`. |
| strict source + digest invalid | Trigger evaluation `would_refuse` only if the proof gate includes invalid digest as a candidate. |
| strict source + unsupported policy | Trigger evaluation `configuration_error` unless the proof gate explicitly treats it as `would_refuse`. |
| strict source + recompute unavailable + fail-open | Trigger evaluation `allow` with report-only evidence retained. |
| strict source + recompute unavailable + fail-closed | Not in first proof-local model; requires separate gate. |
| strict source + unrelated structural diagnostic | Trigger evaluation `allow` for digest-only refusal model. |

### Legacy Path Shielding

| Case | Expected |
| --- | --- |
| no provider | Legacy compile behavior; no refusal trigger. |
| nil provider | Legacy compile behavior; no validation field; no refusal trigger. |
| non-Hash provider | Legacy compile behavior; no validation field; no refusal trigger. |
| provider error | Legacy compile behavior; no validation field; no refusal trigger. |
| validator error | Legacy compile behavior unless a later fail-closed validator-error policy is authorized. |

### Boundary Guards

Required proof assertions:

- top-level `report["diagnostics"]` remains unchanged in report-only mode;
- public result remains unchanged in report-only mode;
- no `CompilerResult` widening;
- no `.igapp` mutation;
- no loader/report or CompatibilityReport behavior;
- no runtime/production behavior;
- wrapper codes appear only in proof-local trigger evaluation, not validator
  diagnostics.

### Regression Commands

Existing accepted commands must remain PASS:

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
```

Future strict proof-local commands should be added only after a gate authorizes
the proof-local experiment.

---

## Surfaces Still Closed

This design does not open:

- live compiler/orchestrator refusal;
- public API strict mode;
- CLI strict mode;
- manifest/profile policy strict mode;
- `CompilerResult` fields;
- refusal reports, persisted reports, or sidecars;
- loader/report or CompatibilityReport status;
- runtime or production readiness.

The first proof-local model should not reuse loader/report names such as:

```text
missing_required
present_verified
runtime_ready
```

Those belong to other layers and would confuse compiler refusal with load or
runtime acceptance.

---

## Open Blockers

Remaining blockers before any refusal implementation authorization:

| Blocker | Status after this track |
| --- | --- |
| Accepted strict source for production/compiler implementation | Open. Proof-local source recommended only. |
| Compiler/orchestrator implementation boundary | Open. No code or write scope authorized. |
| Public API/CLI source shape | Open and deferred. |
| Manifest/profile policy source shape | Open and deferred. |
| `CompilerResult`/status model | Open; wrapper codes are design vocabulary only. |
| Refusal report behavior | Open and deferred. |
| Fail-closed policy for recompute unavailable | Open and not recommended first. |
| Proof-local strict-mode experiment | Open; not authorized by this track. |

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
- proof-local refusal experiment;
- enabling compile refusal;
- compiler/orchestrator changes;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.

---

## Recommendation For C4-A

Recommendation:

```text
accept
```

Reason:

- strict-mode source options are separated and ranked;
- first future proof-local source is bounded to a gate-controlled proof object,
  not public API/CLI/manifest policy;
- trigger vocabulary separates report-only mode, strict request, candidate
  evidence, wrapper refusal decision, loader/report, and runtime readiness;
- wrapper compiler-level refusal codes are recommended without making validator
  diagnostics compile-status vocabulary;
- `contract_digest_recompute_unavailable` remains fail-open/report-only for the
  first proof-local model;
- proof-local matrix is refined while compile refusal remains closed.

Recommended next route:

```text
optional pressure review; then, only if Architect chooses, a proof-local
strict-mode trigger experiment that does not change compiler/orchestrator,
public API/CLI, CompilerResult, .igapp, loader/report, or runtime behavior.
```
