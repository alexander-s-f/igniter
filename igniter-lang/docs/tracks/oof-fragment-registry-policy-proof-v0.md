# OOF Fragment Registry Policy Proof v0

Card: LANG-R95-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Track: `oof-fragment-registry-policy-proof-v0`  
Status: done  
Date: 2026-05-20

---

## Role And Neighbor Awareness

Assigned track: proof-only policy modeling for OOF/Fragment Registry.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — future canon semantics and OOF /
  fragment policy review.
- `[Igniter-Lang Bridge Agent]` — loader/report, CompatibilityReport, runtime,
  package, and public API/CLI surfaces remain closed.

This track models policy only. It changes no specs, canon, compiler code,
runtime code, `.igapp` artifacts, or goldens.

---

## Current Horizon

```text
R92 shadow registry proof PASS established proof-local descriptor/fragment data.
R93 design recommended status-primary OOF with secondary non-loadable projection.
LANG-R95 exercises the remaining policy gaps before implementation can be considered.
The result can pass as proof evidence while still holding implementation closed.
```

---

## Read Set

- `docs/tracks/oof-fragment-registry-shadow-proof-v0.md`
- `experiments/oof_fragment_registry_shadow_proof/out/oof_fragment_registry_shadow_proof_summary.json`
- `experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
- `experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json`
- `docs/tracks/oof-fragment-registry-ownership-and-canon-semantics-design-v0.md`
- `docs/discussions/oof-fragment-registry-design-pressure-v0.md`
- `docs/gates/oof-fragment-registry-shadow-proof-decision-v0.md`

---

## Proof Output

Executable proof:

```text
igniter-lang/experiments/oof_fragment_registry_policy_proof/oof_fragment_registry_policy_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_proof_summary.json
igniter-lang/experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json
```

Result:

```text
PASS oof-fragment-registry-policy-proof-v0
cases: 16/16
checks: 7/7
recommendation: PASS_FOR_PROOF_ONLY_POLICY_MODEL_HOLD_IMPLEMENTATION
policy_id: oof_fragment_policy/sha256:027ba71cd5a14c104b3b246a
```

---

## Policy Model

The proof models four policy groups:

| Policy group | Modeled rule |
| --- | --- |
| Alias / collision | Canonical descriptor codes are unique; aliases must be represented by compatibility-alias descriptors; aliases must point to existing current replacement codes; aliases cannot be claimed by multiple canonical descriptors. |
| OOF projection guard | `oof` is status-primary with secondary fragment projection only; projection must be blocked, non-loadable, status-only, and capability-free. |
| Guarded non-fragments | `olap` and `progression` may appear as owner/metadata surfaces but cannot be promoted to fragment classes, given precedence, or made loadable. |
| Exclusion namespaces | `compiler_profile_contract.*` and `compiler_profile_contract_refusal.*` are outside the OOF namespace and cannot be descriptors or aliases. |

This is a proof-local policy model, not a registry implementation or canon
definition.

---

## Case Matrix

| Case | Expected | Result | Diagnostic exercised |
| --- | --- | --- | --- |
| `alias_policy.valid_shadow_descriptors` | accepted | PASS | none |
| `alias_policy.duplicate_code_rejected` | rejected | PASS | `oof_registry.code_collision` |
| `alias_policy.alias_claimed_by_multiple_codes_rejected` | rejected | PASS | `oof_registry.alias_collision` |
| `alias_policy.missing_replacement_rejected` | rejected | PASS | `oof_registry.alias_missing_replacement` |
| `alias_policy.candidate_replacement_rejected` | rejected | PASS | `oof_registry.alias_replacement_not_current` |
| `oof_projection.valid_blocked_non_loadable_status_only` | accepted | PASS | none |
| `oof_projection.loadable_rejected` | rejected | PASS | `fragment_registry.oof_projection_loadable` |
| `oof_projection.capability_rejected` | rejected | PASS | `fragment_registry.oof_projection_capability` |
| `oof_projection.not_status_primary_rejected` | rejected | PASS | `fragment_registry.oof_projection_not_status_primary` |
| `guarded_non_fragment.valid_olap_progression` | accepted | PASS | none |
| `guarded_non_fragment.olap_promotion_rejected` | rejected | PASS | `fragment_registry.guarded_non_fragment_promoted` |
| `guarded_non_fragment.progression_precedence_rejected` | rejected | PASS | `fragment_registry.guarded_non_fragment_precedence` |
| `guarded_non_fragment.olap_loadable_rejected` | rejected | PASS | `fragment_registry.guarded_non_fragment_loadable` |
| `exclusion.valid_shadow_descriptors` | accepted | PASS | none |
| `exclusion.compiler_profile_contract_descriptor_rejected` | rejected | PASS | `oof_registry.excluded_namespace` |
| `exclusion.compiler_profile_refusal_alias_rejected` | rejected | PASS | `oof_registry.excluded_namespace` |

---

## Proof Checks

| Check | Result |
| --- | --- |
| `source_shadow_proof.pass_evidence` | PASS |
| `case_matrix.all_expected_results` | PASS |
| `alias_policy.accepts_valid_shadow_descriptors` | PASS |
| `alias_policy.rejects_collisions` | PASS |
| `oof_projection.blocks_loadability_and_capability` | PASS |
| `guarded_non_fragment.olap_progression_guarded` | PASS |
| `exclusion.profile_contract_namespaces_blocked` | PASS |

No failed cases or checks.

---

## PASS / HOLD Recommendation

Recommendation:

```text
PASS_FOR_PROOF_ONLY_POLICY_MODEL
HOLD_IMPLEMENTATION
```

Meaning:

- PASS: the proof-local policy model covers alias/collision, OOF projection
  guard, guarded non-fragments, and profile-contract/refusal exclusion.
- HOLD: implementation remains closed because this track does not authorize
  live registry, dispatch, compiler changes, spec/canon mutation, loader/report,
  CompatibilityReport, runtime, or production behavior.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/oof_fragment_registry_policy_proof/oof_fragment_registry_policy_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/oof_fragment_registry_policy_proof/oof_fragment_registry_policy_proof.rb` | PASS / `cases: 16/16`, `checks: 7/7` |

No broad compiler/runtime suite was run. This proof is intentionally local and
does not affect live compiler behavior.

---

## Blockers Before Implementation

Still required before implementation can be considered:

- Architect decision accepting or redirecting this policy proof;
- exact live write scope, if implementation is ever opened;
- byte-for-byte diagnostic/report/golden parity plan;
- canon decision for status-primary OOF projection vocabulary;
- decision whether `PINV-*` / `TINV-*` stay proof markers or become descriptors;
- public-code lifecycle policy for candidate/proof-only descriptor promotion;
- proof that registry validation can be integrated without changing parser,
  classifier, TypeChecker, SemanticIR, assembler, CLI/API, or reports unless
  explicitly authorized.

---

## Closed Surfaces

This proof does not authorize:

- specs or canon edits;
- compiler/runtime code changes;
- registry implementation;
- pack dispatch;
- parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator rewrites;
- public diagnostic renames, deletions, promotions, or wording changes;
- public API/CLI widening;
- loader/report or CompatibilityReport changes;
- `.igapp` or golden mutation;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production
  executors, cache, signing, deployment, or production behavior.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: oof-fragment-registry-policy-proof-v0
Status: done
Card: LANG-R95-P1
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D]
- Added proof-local OOF/Fragment registry policy model and runner.
- Covered alias/collision policy, OOF projection guard, guarded non-fragments,
  and compiler_profile_contract/refusal namespace exclusions.
- Wrote policy model and summary JSON under experiments only.

[S]
- PASS as proof-only evidence: 16/16 cases, 7/7 checks.
- Recommendation is explicitly dual:
  PASS_FOR_PROOF_ONLY_POLICY_MODEL + HOLD_IMPLEMENTATION.
- No specs/canon/compiler/runtime surfaces changed.

[T]
- ruby -c igniter-lang/experiments/oof_fragment_registry_policy_proof/oof_fragment_registry_policy_proof.rb
  -> Syntax OK
- ruby igniter-lang/experiments/oof_fragment_registry_policy_proof/oof_fragment_registry_policy_proof.rb
  -> PASS oof-fragment-registry-policy-proof-v0
  -> cases: 16/16
  -> checks: 7/7

[R]
- C4/Architect can use this as policy proof evidence.
- Do not start implementation from this proof without a separate gate.

[Next]
- Pressure or decision route should decide whether this closes the remaining
  pre-implementation policy blockers or if PINV/TINV lifecycle needs its own
  proof/design card first.
```
