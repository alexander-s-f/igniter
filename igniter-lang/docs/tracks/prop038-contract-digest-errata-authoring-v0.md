# Track: PROP-038 Contract Digest Errata Authoring v0

Card: S3-R72-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-contract-digest-errata-authoring-v0`
Route: UPDATE
Status: done
Date: 2026-05-18

Authority ref:

- `docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Implementation Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Author PROP-038 errata/design text for the accepted `contract_digest`
proof-chain results without authorizing implementation.

---

## Inputs Read

- `docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-validation-policy-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round71-status-curation-v0.md`
- `experiments/prop038_contract_digest_report_only_integration_proof/out/prop038_contract_digest_report_only_integration_proof_summary.json`
- `experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json`
- `experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json`

---

## Updated

Updated:

```text
docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

No code or experiments were edited.

No new PROP number was created.

---

## Diff Summary

PROP-038 now includes:

- `prop038-contract-digest-validation-policy-design-v0` in source tracks;
- §9.5 `Contract Digest Validation Policy Errata`;
- §9.6 `Contract Digest Canonicalization Material`;
- four accepted `contract_digest_*` diagnostic codes in §10;
- §10.2 `Contract Digest Diagnostic Placement`;
- §10.3 `Contract Digest Report-Only Invariants`;
- R69/R70/R71 proof-chain links and proof evidence in §15.

Accepted diagnostic vocabulary added/confirmed:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

---

## Canonicalization Text Added

PROP-038 now records accepted R70 canonicalization material:

```text
contract object excluding contract_digest
```

Included fields:

```text
kind
format_version
profile_namespace
profile_kind
compiler_profile_id
descriptor_digest
finalization_payload_digest
required_slot_schema
slot_order
slot_assignments
strict_registries
ordered_rule_graph
non_authority
```

Excluded fields:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source_path / out_path
parsed_program
compiler_profile_source
```

Accepted rules recorded:

- object keys sort recursively;
- `slot_order` remains order-sensitive;
- strict registry names and entries are order-insensitive;
- ordered-rule list order is order-insensitive;
- `before` and `after` edge arrays are treated as sorted unique sets;
- `descriptor_digest` is included as a string field value;
- descriptor material is not fetched or recomputed.

---

## Report-Only Text Added

PROP-038 now states that digest diagnostics, if implemented later, belong under:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
```

They must not append to:

```text
report["diagnostics"]
```

They must not centralize in:

```text
IgniterLang::Diagnostics
```

without a separate Architect decision.

PROP-038 also states that `contract_digest` diagnostics do not change compile
status, `pass_result`, stages, public result, assembler execution, `.igapp`
manifest, or refusal-report behavior.

---

## Non-Authorization Preserved

This authoring track does not authorize:

- live validator implementation;
- compiler/orchestrator implementation;
- compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report behavior;
- CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.

---

## Remaining Review / Acceptance Questions

[Q] Should a later live validator implementation design implement all four
digest diagnostics together, or split shape-only and recompute-match into two
implementation cards?

[Q] Should future persisted/durable surfaces require 64-character
`contract_digest` references rather than `24+` prefix references?

[Q] Should report-only digest diagnostics ever become compile refusal, and if
so, which gate owns exact refusal behavior?

[Q] Should `IgniterLang::Diagnostics` ever centralize PROP-038 diagnostics after
report-only behavior is stable?

---

## Recommendation For C3-A

Recommendation:

```text
accept
```

Reason:

- PROP-038 now reflects the accepted R69-R71 digest proof chain.
- The four digest diagnostics are documented as design/proof vocabulary.
- Canonicalization material and report-only placement are documented.
- Non-authority and non-implementation boundaries remain explicit.
- No code, experiments, PROP status, or proposal index were changed.

Possible next route after acceptance:

```text
design-only live validator implementation route
```

Only if Architect chooses to open it. This track itself opens no implementation.

---

## Handoff

```text
Card: S3-R72-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop038-contract-digest-errata-authoring-v0
Status: done

[D] Decisions
- Updated PROP-038 with accepted contract_digest design/errata text.
- Added the four accepted contract_digest diagnostics.
- Documented nested diagnostic placement and report-only invariants.
- Documented accepted canonicalization material and descriptor/contract digest
  separation.

[S] Signals
- R69/R70/R71 proof chain is sufficient for PROP-038 errata/design text.
- The digest chain is still not live implementation authority.
- Compile refusal remains closed.

[T] Tests / Proofs
- Documentation-only authoring slice.
- No code or experiment commands were run.

[R] Recommendation
- C3-A: accept.
- Consider only design-only live validator implementation planning next, with
  all runtime/public/persisted surfaces still closed.

[Next]
- If accepted, route any live validator implementation through a separate design,
  pressure, and Architect authorization chain.
```
