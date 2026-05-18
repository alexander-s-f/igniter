# Track: PROP-038 Contract Digest Compile-Refusal Preconditions Design v0

Card: S3-R75-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-contract-digest-compile-refusal-preconditions-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-18

Authority ref:

- `docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design and evaluate preconditions for any future PROP-038 `contract_digest`
compile-refusal gate, using the accepted live validator implementation and
report-only invariants as inputs.

This track is design-only. It does not enable compile refusal, edit code, change
compiler/orchestrator behavior, widen public API/CLI behavior, mutate `.igapp`
artifacts, or centralize diagnostics.

---

## Inputs Read

- `docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md`
- `docs/gates/prop038-contract-digest-live-implementation-design-decision-v0.md`
- `docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md`
- `docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round74-status-curation-v0.md`
- `lib/igniter_lang/compiler_profile_contract_validator.rb`

---

## Current Accepted State

R74 accepts live internal validator support for all four PROP-038
`contract_digest_*` diagnostics:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

Accepted validator API:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

Accepted validator result keys:

```text
compile_refusal_authorized
compiler_integrated
diagnostic_codes
diagnostics
digest_reference_policy
format_version
kind
valid
```

Accepted fixed flags:

```text
compiler_integrated=false
compile_refusal_authorized=false
```

Accepted current compiler behavior:

- validator emits diagnostics;
- report-only integration annotates an in-memory nested report field only;
- diagnostics remain under `compiler_profile_contract_validation.diagnostics`;
- top-level `report["diagnostics"]` remains unchanged;
- compile status remains unchanged;
- public result remains unchanged;
- `.igapp` manifest remains unchanged;
- nil/non-Hash/provider-error paths remain no-field/no-refusal;
- compile refusal remains closed.

---

## Vocabulary Separation

Compile-refusal design must keep these meanings separate.

| Layer | Meaning | Current status |
| --- | --- | --- |
| Contract-object invalidity | The supplied `compiler_profile_contract` object is invalid under PROP-038 validator rules. | Live in validator result. |
| Report-only validation diagnostics | Validator diagnostics are attached as nested report metadata. | Live, in-memory, no compile effect. |
| Compiler compile refusal | The compiler refuses to produce/continue a compile result because a profile contract failed a required policy. | Closed. Not authorized. |
| Loader/report status | Manifest/profile rollout interpretation after assembly or load-time inspection. | Separate vocabulary; not opened here. |
| Runtime/production readiness | Execution, scheduler, cache, runtime authority, or production safety. | Separate runtime gates; not opened here. |

Core rule:

```text
compiler_profile_contract.* diagnostic != compile refusal
```

The diagnostic may become evidence for a future refusal decision only after a
separate compiler/orchestrator gate defines the refusal mode, source, status,
user-facing wording, and proof matrix.

---

## Preconditions Table

| Preconditions before refusal can be considered | Status after R74 | Required next action |
| --- | --- | --- |
| Live validator emits all four digest diagnostics. | Met. | None. |
| Report-only integration proves nested placement and no compile effect. | Met. | Preserve in all future proofs. |
| Refusal source is explicit and intentional. | Not met. | Define a strict profile/contract requirement mode. |
| Nil/non-Hash/provider-error paths remain legacy/no-field. | Met for current behavior. | Future refusal must keep them non-refusal unless a separate public contract-supply gate changes them. |
| Public API/CLI callers are shielded from accidental behavior change. | Met by absence of public surface. | Any caller-visible supply path needs separate design and authorization. |
| Compiler/orchestrator status semantics are defined. | Not met. | Design refusal status, stage behavior, and result/report shape separately. |
| User-facing diagnostic wording is defined. | Not met. | Separate wording/design card required before implementation. |
| Refusal report behavior is defined. | Not met. | Decide whether refusal writes a report, where, and in what shape. |
| Loader/report vocabulary remains separate. | Met by boundary. | Preserve; do not reuse loader `missing_required` for compile refusal. |
| Runtime/production readiness remains separate. | Met by boundary. | Preserve; digest validity must not imply runtime readiness. |
| Regression proof covers legacy and strict paths. | Not met for refusal. | Required before implementation. |

Minimum gate rule:

```text
No compile refusal may be authorized until explicit-contract strict mode,
compiler status semantics, and user-facing diagnostics are designed and accepted.
```

---

## Required Evidence Before Refusal

Any future refusal gate must require evidence for all of the following.

1. Explicit source:

```text
The compiler was intentionally asked to require a compiler_profile_contract.
```

Examples of possible future sources:

- internal orchestrator option;
- accepted public API option;
- accepted CLI flag;
- accepted manifest/profile policy;
- accepted gate-controlled profile requirement.

This track does not choose or authorize any of those sources.

2. Stable validator:

```text
CompilerProfileContractValidator validates contract_digest live and remains
API/result-shape stable.
```

R74 satisfies the validator part, but not compiler refusal.

3. Refusal semantics:

```text
The compiler has an accepted refusal status/result model for profile contract
failure.
```

This is not yet designed.

4. Diagnostic wording:

```text
User-facing compiler diagnostics explain what failed and how to recover without
leaking proof-only implementation detail.
```

This is not yet designed.

5. Legacy shielding:

```text
Existing callers without an explicit strict profile requirement see identical
compile behavior.
```

This must be proofed.

---

## Refusal Candidate Matrix

Initial refusal consideration should be limited to digest diagnostics. Broader
PROP-038 contract-object invalidity requires a separate gate.

| Diagnostic | Refusal candidate? | Conditions before candidate can open | Notes |
| --- | --- | --- | --- |
| `compiler_profile_contract.contract_digest_invalid` | Conditional candidate. | Explicit strict profile/contract required; caller supplied a Hash contract; user-facing wording accepted. | Missing or malformed identity means the contract cannot be trusted as content-addressed material. |
| `compiler_profile_contract.contract_digest_policy_unsupported` | Conditional candidate. | Explicit policy selection exists and unsupported policy is attributable to caller/config. | If no public policy selection exists, this should remain report-only/internal configuration evidence. |
| `compiler_profile_contract.contract_digest_mismatch` | Strongest conditional candidate. | Explicit strict profile/contract required; recompute succeeds; mismatch is proven stable. | This is the clearest identity contradiction. |
| `compiler_profile_contract.contract_digest_recompute_unavailable` | Hold by default. | Only consider under an explicit fail-closed strict mode with accepted wording and operational recovery story. | Internal canonicalizer failure should not accidentally become a compile break for legacy callers. |

Recommended first refusal candidate, if a later gate opens:

```text
compiler_profile_contract.contract_digest_mismatch
```

Reason:

- the contract has a valid digest reference shape;
- recomputation succeeded;
- the declared identity conflicts with the canonical contract material.

Not recommended as first refusal candidate:

```text
compiler_profile_contract.contract_digest_recompute_unavailable
```

Reason:

- it may represent validator/canonicalizer capability or internal failure;
- fail-closed behavior needs clearer user recovery and operational policy.

---

## Explicit Supply Requirement

Future compile refusal must require an explicit supplied profile/contract and an
explicit strict requirement mode.

Current accepted report-only provider behavior remains:

```text
Hash => validate and attach nested report-only result
nil or non-Hash => no report field
provider StandardError => no report field
validator StandardError => no report field
```

Future refusal must not reinterpret these current legacy paths as refusal:

| Path | Current behavior | Future precondition stance |
| --- | --- | --- |
| No provider | Legacy compile behavior. | Must remain non-refusal. |
| Provider returns nil | No validation field. | Must remain non-refusal unless a separate explicit required-profile source exists. |
| Provider returns non-Hash | No validation field. | Must remain non-refusal unless separately authorized. |
| Provider raises | No validation field. | Must remain non-refusal unless a fail-closed provider policy is separately authorized. |
| Validator raises | No validation field in current integration behavior. | Must remain non-refusal unless separately authorized. |

This prevents report-only provider plumbing from silently becoming a compile
gate.

---

## Public API And CLI Shielding

Current public compile API and CLI surfaces do not expose a contract-refusal
mode.

Future refusal must not be enabled by:

- default compile behavior;
- implicit provider presence;
- environment discovery;
- `.igapp` manifest side effects;
- loader/report interpretation;
- runtime readiness checks.

Any caller-visible entry point must receive separate authorization for:

```text
source shape
strictness mode
diagnostic wording
default behavior
failure status
compatibility policy
```

Until then, compile refusal can only be discussed as a future compiler design,
not as accepted behavior.

---

## Required Proof Matrix For Any Future Refusal Gate

Any future compile-refusal implementation card must first pass a design/proof
gate covering at least this matrix.

### Baseline Legacy Proof

Required cases:

| Case | Expected |
| --- | --- |
| no provider | Compile result unchanged. |
| nil provider | Compile result unchanged; no validation field. |
| non-Hash provider | Compile result unchanged; no validation field. |
| provider exception | Compile result unchanged; no validation field. |
| validator exception | Compile result unchanged unless explicit fail-closed mode is separately authorized. |

### Report-Only Preservation Proof

Required cases:

| Case | Expected |
| --- | --- |
| invalid digest in report-only mode | Nested diagnostics only; compile status unchanged. |
| mismatch in report-only mode | Nested diagnostics only; compile status unchanged. |
| unsupported policy in report-only mode | Nested diagnostics only; compile status unchanged. |
| recompute unavailable in report-only mode | Nested diagnostics only; compile status unchanged. |

### Strict-Mode Refusal Proof

Required cases if strict mode is later authorized:

| Case | Expected |
| --- | --- |
| explicit strict mode + valid digest | Compile succeeds with validation metadata. |
| explicit strict mode + digest mismatch | Compile refuses only if `contract_digest_mismatch` is authorized as refusal candidate. |
| explicit strict mode + malformed digest | Compile refuses only if `contract_digest_invalid` is authorized as refusal candidate. |
| explicit strict mode + unsupported policy | Refusal or configuration error follows accepted policy design. |
| explicit strict mode + recompute unavailable | Must follow accepted fail-open/fail-closed decision. |
| explicit strict mode + unrelated contract diagnostic | Must not refuse unless broader contract invalidity gate authorizes it. |

### Boundary Proof

Required checks:

- no top-level `report["diagnostics"]` mutation unless separately authorized;
- no `CompilerResult` widening unless separately authorized;
- no assembler execution change in report-only mode;
- no `.igapp` mutation;
- no loader/report or CompatibilityReport behavior;
- no `IgniterLang::Diagnostics` centralization;
- no runtime or production behavior.

### Command Matrix

Current regression commands that must remain PASS:

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
```

Future refusal proof commands must be added only after a refusal design gate
authorizes a proof-local refusal model.

---

## User-Facing Diagnostic Design Needed

Before compile refusal can be implemented, a separate design must answer:

- What compiler status names refusal?
- Does refusal appear in public result, internal report, or both?
- Is the user-facing code still `compiler_profile_contract.*`, or is there a
  compiler-level wrapper code?
- Is refusal wording different for API, CLI, and proof harnesses?
- Is a refusal report written?
- Does refusal identify the profile source, contract digest, policy, or only
  the diagnostic code?
- How are recovery hints phrased without promising runtime readiness?

Recommended direction:

```text
Use compiler-level wording that cites the underlying
compiler_profile_contract.* diagnostic as evidence.
```

Do not make validator diagnostics themselves the entire user-facing compiler
refusal UX.

---

## Blockers Before Refusal Implementation Authorization

Blocking items:

- no accepted strict profile/contract requirement source;
- no compiler/orchestrator refusal status design;
- no user-facing diagnostic wording design;
- no accepted fail-open/fail-closed policy for recompute unavailable;
- no proof-local strict-mode refusal matrix;
- no authorization to change compiler/orchestrator behavior;
- no authorization to change public API/CLI behavior;
- no authorization to change `CompilerResult`;
- no authorization to write refusal reports or persisted sidecars.

These blockers mean compile refusal must remain closed after this card.

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
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

## Recommendation For C3-A

Recommendation:

```text
accept
```

Reason:

- the track separates contract-object invalidity from compiler refusal;
- it preserves current live validator/report-only behavior;
- it identifies `contract_digest_mismatch` as the strongest conditional future
  refusal candidate;
- it keeps nil/non-Hash/provider-error paths legacy/no-field;
- it defines the required proof matrix and blockers before any refusal
  implementation authorization.

Recommended next route:

```text
hold compile-refusal implementation; optionally open a separate design card for
strict profile/contract requirement source and user-facing refusal wording.
```
