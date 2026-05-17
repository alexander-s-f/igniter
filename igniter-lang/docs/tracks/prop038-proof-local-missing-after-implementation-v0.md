# Track: PROP-038 Proof-Local Missing-After Implementation v0

Card: S3-R63-C1-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-proof-local-missing-after-implementation-v0`
Route: UPDATE
Status: done
Date: 2026-05-17

---

## Goal

Implement the first proof-local PROP-038 validation extension by adding
missing-`after` `missing_rule_reference` coverage in the existing
`compiler_profile_contract` proof.

Authority:

- `igniter-lang/docs/gates/prop038-compiler-profile-contract-implementation-authorization-decision-v0.md`

Authorized behavior mode:

```text
proof-local only
```

---

## Scope Kept

Edited only:

- `igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `igniter-lang/docs/tracks/prop038-proof-local-missing-after-implementation-v0.md`

No production compiler code was changed.

No changes were made to parser, TypeChecker, SemanticIR, assembler, `.igapp`,
CLI/API, loader/report, CompatibilityReport, dispatch, RuntimeMachine, Gate 3,
Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

Diagnostics remain local to the proof script.

---

## Implementation

Added a new negative proof-local contract case:

```text
missing_after_rule_reference
```

Case mutation:

```text
ordered_rule_graph.rules[0].after = ["parse.nonexistent_rule"]
```

Expected diagnostic:

```text
compiler_profile_contract.missing_rule_reference
```

The validator already checked both `before` and `after` references through the
same missing-reference path. This card adds explicit coverage and assertion for
the `after` direction.

---

## Summary Changes

Updated:

```text
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
```

Observed summary state after rerun:

```text
track=prop038-proof-local-missing-after-implementation-v0
extends_track=compiler-profile-contract-validator-coverage-proof-v0
status=PASS
cases=13
validator_case_matrix=13
checks=23
```

Added summary entries:

- `cases[].name = missing_after_rule_reference`
- `validator_case_matrix[].case = missing_after_rule_reference`
- `checks[].name = missing_after_rule_reference.diagnostic`

The added case reports:

```text
code: compiler_profile_contract.missing_rule_reference
path: ordered_rule_graph.rules.parse.contract_modifiers
```

The proof-local digest reference policy remains PROP-038-compatible:

```text
descriptor_digest: compiler_profile_descriptor/sha256:<24+ lowercase hex>
contract_digest:   compiler_profile_contract/sha256:<24+ lowercase hex>
```

---

## Command Matrix

| Command | Result | Output |
| --- | --- | --- |
| `ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `PASS compiler_profile_contract_proof` |

Additional summary verification:

```text
track=prop038-proof-local-missing-after-implementation-v0
extends_track=compiler-profile-contract-validator-coverage-proof-v0
status=PASS
cases=13
matrix=13
checks=23
library_blockers=4
integration_blockers=5
```

---

## Non-Authorizations Preserved

This proof did not create:

- production compiler integration;
- report-only compiler integration;
- compile refusal;
- public API or CLI widening;
- centralized diagnostics in `IgniterLang::Diagnostics`;
- `.igapp` output changes;
- loader/report or CompatibilityReport behavior;
- dispatch, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP,
  cache, or production behavior.

---

## Recommendation

```text
next gate: consider library validator design
```

Reason:

- the named proof-local missing-`after` coverage gap is now closed;
- continuing proof-local is only needed if a later reviewer asks for additional
  validator adversarial cases;
- report-only compiler integration and compile refusal should remain held;
- the next useful step is a design/authorization review for whether an internal
  library validator should be extracted, with descriptor digest input material,
  short-vs-full digest policy, diagnostic placement, and contract input
  ownership decided before any production compiler integration.

---

## Handoff

```text
Card: S3-R63-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop038-proof-local-missing-after-implementation-v0
Status: done

[D] Decisions
- Added proof-local missing-after ordered-rule coverage.
- Kept the same diagnostic:
  compiler_profile_contract.missing_rule_reference.
- Updated proof summary track metadata to this R63 track and linked it to the
  prior validator coverage proof.
- Replaced stale summary blocker labels with current library-validator and
  compiler-integration blocker groups.

[S] Shipped
- Updated proof script.
- Regenerated proof-local summary JSON.
- Added this track document.

[T] Tests / Proofs
- PASS ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- PASS ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb

[R] Recommendation
- Next gate should consider library validator design.
- Keep report-only compiler integration and compile-refusal behavior held.

[Q] Open
- Descriptor digest input material remains unresolved outside proof-local
  projection.
- Persisted/durable short-vs-full digest policy remains unresolved outside
  proof-local output.
```
