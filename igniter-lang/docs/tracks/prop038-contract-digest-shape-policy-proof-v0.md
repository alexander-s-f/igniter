# PROP-038 Contract Digest Shape Policy Proof v0

Card: S3-R69-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-contract-digest-shape-policy-proof-v0
Route: UPDATE
Status: done
Date: 2026-05-17

Authority ref:

- `docs/gates/prop038-contract-digest-validation-policy-decision-v0.md`

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - future PROP-038 policy text and digest-shape vocabulary.
- [Igniter-Lang Bridge Agent] - future report/transport interpretation only; no bridge behavior changed here.

---

## Scope

Build proof-local evidence for future PROP-038 `contract_digest` shape-policy
behavior under `prop038_24_plus`.

Read:

- `docs/gates/prop038-contract-digest-validation-policy-decision-v0.md`
- `docs/tracks/prop038-contract-digest-validation-policy-design-v0.md`
- `docs/discussions/prop038-contract-digest-validation-policy-pressure-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `lib/igniter_lang/compiler_profile_contract_validator.rb`
- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json`

This proof models the proposed future shape-policy validator locally inside the
experiment. It does not edit the live validator, compiler, orchestrator,
CompilationReport, public API/CLI, assembler, runtime, or any `.igapp` artifact.

---

## Produced

```text
igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/
  prop038_contract_digest_shape_policy_proof.rb
  out/prop038_contract_digest_shape_policy_proof_summary.json
```

Track doc:

```text
igniter-lang/docs/tracks/prop038-contract-digest-shape-policy-proof-v0.md
```

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | `PASS prop038_contract_digest_shape_policy_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | `PASS compiler_profile_contract_proof` |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | `PASS prop038_report_only_compiler_integration` |
| `ruby -c igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | `Syntax OK` |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | `Syntax OK` |

---

## Shape Policy

Proof-local accepted shape under `prop038_24_plus`:

```text
compiler_profile_contract/sha256:<24+ lowercase hex>
```

This is shape-only. It does not recompute the contract digest and does not prove
declared-vs-recomputed integrity.

Proof-local diagnostics:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
```

These diagnostics remain local to the proof. They are not added to the live
validator or to `IgniterLang::Diagnostics`.

---

## Case Matrix

| Case | Expected | Result |
| --- | --- | --- |
| `valid_short_contract_digest` | valid | PASS |
| `valid_full_contract_digest` | valid | PASS |
| `missing_contract_digest` | `compiler_profile_contract.contract_digest_invalid` | PASS |
| `contract_digest_wrong_namespace` | `compiler_profile_contract.contract_digest_invalid` | PASS |
| `contract_digest_too_short` | `compiler_profile_contract.contract_digest_invalid` | PASS |
| `contract_digest_non_hex` | `compiler_profile_contract.contract_digest_invalid` | PASS |
| `contract_digest_uppercase_hex` | `compiler_profile_contract.contract_digest_invalid` | PASS |
| `unsupported_digest_policy` | `compiler_profile_contract.contract_digest_policy_unsupported` | PASS |

The proof validates both 24-character prefix form and full 64-character SHA-256
form. Uppercase hex, non-hex, wrong namespace, missing value, and shorter than
24 characters are rejected by shape.

---

## Regression Checks

The summary records:

```json
{
  "status": "PASS",
  "failed_checks": [],
  "live_validator_changed": false,
  "compiler_integration_changed": false,
  "recompute_match_implemented": false,
  "compile_refusal_authorized": false,
  "implementation_authorized": false
}
```

Regression signals:

- existing 13-case validator matrix remains PASS;
- R67 report-only integration remains PASS;
- public result remains unchanged in the integration summary;
- accepted live validator result still has `compile_refusal_authorized=false`;
- live validator still emits no `contract_digest_*` diagnostics;
- proof output contains no `.igapp` artifact;
- proof output contains no refusal report.

---

## Non-Authorizations Preserved

No live validator implementation.

No recompute-match proof implementation.

No compile refusal.

No public API/CLI widening.

No `CompilerResult` changes.

No persisted success reports or sidecars.

No parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation except
proof-local generated summary output and the rerun of existing proof-local
report-only integration output.

No loader/report or CompatibilityReport.

No `IgniterLang::Diagnostics` centralization.

No RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
production behavior.

---

## Recommendation For C3-A

Recommendation:

```text
accept
```

Reason:

- all required shape-policy cases pass;
- regression checks pass;
- live validator and report-only compiler integration remain unchanged in
  authority and behavior;
- recompute-match remains explicitly unimplemented;
- compile refusal remains explicitly unauthorized.

Recommended next route after acceptance:

```text
prop038-contract-digest-recompute-match-proof-v0
```

only if Architect explicitly authorizes the next proof-local phase.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/prop038-contract-digest-shape-policy-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Modeled PROP-038 contract_digest validation as proof-local shape-only policy under prop038_24_plus.
- Kept current live validator behavior unchanged: no contract_digest validation is implemented.
- Kept recompute-match out of scope and explicitly false in summary.

[S] Signals:
- Summary status PASS with failed_checks [].
- Eight required digest shape-policy cases pass.
- Existing validator matrix and R67 report-only integration remain PASS.
- compile_refusal_authorized=false remains true for accepted live validator result.

[T] Tests / Proofs:
- PASS: ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
- PASS: ruby -c igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
- PASS: ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- PASS: ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
- PASS: ruby -c igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
- PASS: ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb

[R] Recommendations:
- C3-A can accept this proof-local shape-policy closure.
- Do not authorize implementation or compile refusal from this proof.
- If accepted, route separately to recompute-match proof design/implementation only as proof-local.

[Files] Changed:
- igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
- igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json
- igniter-lang/docs/tracks/prop038-contract-digest-shape-policy-proof-v0.md

[Q] Open Questions:
- What canonicalization proof material should be fixed before recompute-match?
- Should PROP-038 errata add contract_digest diagnostics before or after recompute-match proof?

[X] Rejected:
- No live validator implementation, recompute-match implementation, compile refusal, public API/CLI widening, report persistence, loader/report behavior, CompatibilityReport behavior, RuntimeMachine behavior, or production behavior was added.

[Next] Proposed next slice:
- Architect C3-A acceptance decision; if accepted, consider a separate proof-local recompute-match track.
```
