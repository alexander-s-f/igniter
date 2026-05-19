# Track: PROP-038 Live Refusal Implementation Boundary Design v0

Card: S3-R78-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-live-refusal-implementation-boundary-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design the remaining boundary conditions before any live PROP-038 strict-mode
compile-refusal implementation can be considered, using the accepted R77
proof-local trigger experiment as evidence.

This track is design-only. It does not edit code, enable live compile refusal,
modify proof-local code, change compiler/orchestrator behavior, widen public
API/CLI behavior, change `CompilerResult`, write persisted reports or sidecars,
mutate `.igapp`, or open loader/report, CompatibilityReport, runtime, or
production behavior.

---

## Inputs Read

- `docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`
- `docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md`
- `docs/discussions/prop038-strict-mode-refusal-trigger-proof-local-pressure-v0.md`
- `docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round77-status-curation-v0.md`

---

## Accepted R77 Evidence

R77 accepts the proof-local strict trigger model only.

Accepted proof-local source:

```json
{
  "kind": "compiler_profile_contract_strict_requirement",
  "format_version": "0.1.0",
  "mode": "strict_contract_digest",
  "source": "proof_local_gate",
  "refusal_candidates": ["compiler_profile_contract.contract_digest_mismatch"],
  "recompute_unavailable_policy": "fail_open_report_only",
  "compile_refusal_authorized": false
}
```

Accepted proof-local decision vocabulary:

```text
not_evaluated
allow
would_refuse
configuration_error
```

Accepted proof-local behavior:

- only `compiler_profile_contract.contract_digest_mismatch` maps to
  `would_refuse`;
- `contract_digest_invalid` remains held/control;
- `contract_digest_policy_unsupported` maps to `configuration_error`;
- `contract_digest_recompute_unavailable` remains fail-open/report-only;
- nil, non-Hash, provider-error, and validator-error paths remain
  no-field/no-refusal;
- `compiler_refusal_authorized=false` across all proof cases;
- `refused` live vocabulary is not introduced.

---

## Remaining Blocker Table

| Blocker | Status after R77 | Required before live implementation |
| --- | --- | --- |
| Production/compiler strict source | Open. Proof-local source accepted only for experiment. | Choose a live source and accepted source shape. |
| Live compiler/orchestrator implementation boundary | Open. No `lib` changes accepted. | Decide exact files, call point, and stop conditions. |
| Ruby API source shape | Open and closed to implementation. | Separate public API design if chosen. |
| CLI source shape | Open and closed to implementation. | Separate CLI design if chosen. |
| Manifest/profile policy source shape | Open and closed to implementation. | Separate `.igapp`/loader/profile policy design if chosen. |
| `CompilerResult` / status model | Open. | Decide whether refusal is represented in public result, internal report, exception, or separate status object. |
| Refusal report behavior | Open. | Decide whether a refused compile writes any report, where, and in what schema. |
| Fail-closed policy for recompute unavailable | Open. | Keep fail-open for first live candidate or design operational recovery. |
| `.igapp` / assembly strict-mode boundary | Open. | Decide whether refusal prevents assembly and how `report_for_assembly` behaves. |
| Loader/report boundary | Closed / not authorized. | Keep separate unless a later gate opens it. |
| CompatibilityReport boundary | Closed / not authorized. | Keep separate unless a later gate opens it. |
| Diagnostics centralization | Closed / not authorized. | Do not use `IgniterLang::Diagnostics` without a separate decision. |
| Runtime/production readiness | Closed / not authorized. | Digest refusal must not imply runtime readiness. |

Minimum rule:

```text
R77 would_refuse may graduate to live refused only behind a separate live
implementation gate that closes source, status, result, report, and assembly
boundaries.
```

---

## Live Strict Source Option Table

| Live source option | Meaning | Advantages | Risks | Recommendation |
| --- | --- | --- | --- | --- |
| Internal orchestrator option | A future internal compiler/orchestrator option carries an explicit strict requirement object. | Closest to existing report-only provider plumbing; no public API/CLI commitment; good first live design candidate. | Still changes live compiler behavior and needs status/assembly design. | Design next, not implement. |
| Ruby facade/API option | Public `IgniterLang.compile(...)` accepts strict mode/profile contract source. | Direct caller control. | Public compatibility, source-shape, docs, and support burden. | Defer. |
| CLI flag | CLI exposes strict profile contract validation. | Useful for users and CI eventually. | Requires stable wording, exit status, JSON output, and public docs. | Defer until API/status model stabilizes. |
| Manifest/profile policy | `.igapp` or profile metadata declares strict requirement. | Aligns with packaged artifacts eventually. | Crosses into assembly, loader/report, CompatibilityReport, and manifest semantics. | Defer; not first. |
| Gate-controlled profile requirement | Architect/gate supplies strict requirement for controlled proof or staged validation. | Proven in R77 as proof-local; useful for staged rollout. | Not a production/compiler source by itself. | Keep as proof/design source, not live source. |

Recommended first live-source candidate to design next:

```text
internal orchestrator option
```

Reason:

- it is the narrowest live source that could exercise a real compiler boundary;
- it can reuse the existing internal provider/report-only context without
  forcing public API or CLI semantics;
- it can require an explicit strict requirement object, preserving legacy
  no-field/no-refusal behavior;
- it lets public API, CLI, manifest/profile policy, loader/report, and runtime
  stay closed.

Do not implement it yet. The next step should be a dedicated design/pressure
card for the internal orchestrator source and status boundary.

---

## Proposed Live Refusal Pipeline Placement

Current report-only behavior:

```text
compile source
  -> build base compiler report/result
  -> optional provider returns contract Hash
  -> live validator returns validation result
  -> nested report-only annotation may be added
  -> compile status/public result/assembly remain unchanged
```

Future strict-mode placement, if later authorized:

```text
compile source
  -> build base compiler report and pass_result
  -> call explicit strict source / provider boundary
  -> run CompilerProfileContractValidator
  -> attach or prepare compiler_profile_contract_validation metadata
  -> evaluate strict trigger
  -> if trigger decision is allow: continue current report-only/success path
  -> if trigger decision graduates from would_refuse to refused:
       shape compiler refusal status/result
       do not run assembly for refused compile
       do not mutate .igapp
       write refusal report only if separately authorized
```

Placement decisions:

| Pipeline point | Proposed future stance |
| --- | --- |
| Report-only validation | Always occurs before strict trigger evaluation when a contract Hash exists. |
| `pass_result` | Existing compiler pass result is input evidence; strict refusal should not rewrite normal pass semantics. |
| Assembly | Strict refusal, if live, should occur before assembly to avoid producing `.igapp` artifacts for a refused compile. |
| `report_for_assembly` | If decision is `allow`, existing pre-annotation assembly behavior may continue. If `refused`, assembly should be skipped. |
| Public result shaping | Must be explicitly designed; do not infer from proof-local `would_refuse`. |
| Refusal report creation | Closed until a report schema and write policy are accepted. |

This placement keeps digest refusal as a post-validation, pre-assembly compiler
gate. It does not make validation diagnostics themselves compiler status.

---

## `CompilerResult` / Status / Refusal-Report Options

### Status Options

| Option | Meaning | Pros | Risks | Recommendation |
| --- | --- | --- | --- | --- |
| Internal report-only status | Keep refusal modeled only in internal report metadata. | Minimal surface. | Not a real live refusal. | Current behavior only. |
| New compile status `refused` | Public/internal result can represent a refused compile. | Clear semantic distinction. | Requires `CompilerResult` and public behavior design. | Best eventual live semantics, but not authorized. |
| Exception-only refusal | Raise an exception on strict mismatch. | Simple to wire. | Poor structured reporting; API/CLI divergence risk. | Not recommended first. |
| Report object only | Return structured refusal report without changing public result shape. | Structured, less exception-driven. | Still a public/result surface change if exposed. | Needs separate design. |

Recommended status direction for future design:

```text
new explicit compile status refused, with wrapper evidence, only after
CompilerResult/public result design is accepted.
```

### Refusal Report Options

| Option | Meaning | Recommendation |
| --- | --- | --- |
| No persisted report | Refusal is returned in-memory only. | Best first live design candidate. |
| Proof-local JSON only | Refusal proof writes experiment summary only. | Already accepted in R77; not live. |
| Persisted refusal report | Write a refusal report/sidecar when strict mode refuses. | Defer; requires path, schema, lifecycle, and cleanup design. |
| Loader/report integration | Feed refusal into loader/report or CompatibilityReport. | Defer; separate layer. |

First live implementation should not write persisted reports or sidecars.

### Wrapper Evidence Shape

If live `refused` is later authorized, it should carry structured evidence like:

```json
{
  "status": "refused",
  "reason_code": "compiler_profile_contract_refusal.contract_digest_mismatch",
  "evidence_code": "compiler_profile_contract.contract_digest_mismatch",
  "strict_validation_source": "internal_orchestrator_option",
  "compile_refusal_authorized": true
}
```

This shape is design-only. It is not accepted as `CompilerResult` schema.

---

## Graduation Rule For `would_refuse`

Decision:

```text
R77 proof-local would_refuse can graduate to live refused only behind a separate
implementation gate.
```

Required gate contents:

- accepted live strict source;
- accepted compiler/orchestrator write scope;
- accepted status/result shape;
- accepted wrapper code shape;
- accepted assembly skip behavior;
- accepted report/refusal-report behavior;
- accepted legacy/no-field/no-refusal preservation proof;
- accepted public/API/CLI non-widening or explicit widening decision.

Do not graduate:

```text
would_refuse => refused
```

by renaming proof-local vocabulary or by treating `validation["valid"] == false`
as a compiler stop condition.

---

## Proof And Regression Requirements

Any future live implementation review must include at least this matrix.

### Existing Proofs Must Remain PASS

```bash
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb
```

### Live Strict Source Proof

| Case | Expected |
| --- | --- |
| no strict source | Current report-only/no-refusal behavior unchanged. |
| internal strict source + valid contract | Compile succeeds; no refusal. |
| internal strict source + digest mismatch | Live behavior follows accepted status model. |
| internal strict source + invalid digest | Must remain non-refusal unless candidate scope expands. |
| internal strict source + unsupported policy | Must follow accepted configuration-error policy, not accidental refusal. |
| internal strict source + recompute unavailable | Must remain fail-open unless a fail-closed policy is separately accepted. |

### Legacy/Error Path Proof

| Case | Expected |
| --- | --- |
| no provider | No refusal. |
| provider returns nil | No refusal. |
| provider returns non-Hash | No refusal. |
| provider raises | No refusal unless a separate fail-closed provider policy opens. |
| validator raises | No refusal unless a separate fail-closed validator policy opens. |
| existing compile failure before validation | Existing failure path unchanged; strict profile logic does not mask it. |

### Assembly And Artifact Proof

| Case | Expected |
| --- | --- |
| report-only mismatch | Assembly behavior unchanged from R67/R74. |
| strict source + allow | Assembly behavior unchanged. |
| strict source + live refused | Assembly skipped, `.igapp` unchanged or absent according to accepted artifact policy. |
| strict source + live refused | `report_for_assembly` is not used to produce artifacts. |

### Result/Report Proof

| Case | Expected |
| --- | --- |
| report-only invalid validation | Public result unchanged; nested metadata only. |
| live refused mismatch | Status/result matches accepted `CompilerResult` design. |
| live refused mismatch | Wrapper evidence cites validator diagnostic. |
| live refused mismatch | No top-level diagnostics or `IgniterLang::Diagnostics` centralization unless separately authorized. |
| live refused mismatch | Refusal report behavior matches accepted report policy. |

### Boundary Guard Proof

Required guards:

- public API/CLI unchanged unless explicitly authorized;
- no parser, TypeChecker, SemanticIR change;
- no loader/report or CompatibilityReport mutation;
- no runtime or production behavior;
- no `.igapp` mutation in refused path unless an artifact policy explicitly
  authorizes a refusal artifact;
- proof-local wrapper code names do not leak into validator diagnostics.

---

## Recommended Next Route

Recommended next route:

```text
internal-orchestrator-strict-source-and-status-design-v0
```

Goal:

```text
Design the internal orchestrator strict source, status/result shape, and
pre-assembly refusal point without implementing live refusal.
```

Keep held:

- Ruby API;
- CLI;
- manifest/profile policy;
- loader/report;
- CompatibilityReport;
- fail-closed recompute unavailable;
- persisted refusal reports/sidecars;
- runtime/production behavior.

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
- live compile refusal;
- proof-local code changes;
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

- remaining live-refusal blockers are explicit;
- the first live-source candidate is narrowed to an internal orchestrator option
  for future design, not implementation;
- public API, CLI, manifest/profile policy, loader/report, CompatibilityReport,
  runtime, and production remain held;
- the proposed live refusal point is post-validation and pre-assembly;
- `would_refuse` can only graduate to live `refused` behind a separate
  implementation gate;
- proof/regression requirements are defined for any later implementation review.
