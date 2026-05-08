# Track: Temporal Fragment Classifier TypeChecker v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/temporal-fragment-classifier-typechecker-v0
Card: S3-R2-C2-P
Status: done
Date: 2026-05-08
Depends on: S3-R1-C2-P

---

## Context

PROP-028 introduces `TEMPORAL` as a refined fragment class between `OOF` and
`STREAM`/`CORE`:

```text
OOF > TEMPORAL > STREAM > CORE
```

This slice implements the first compiler proof boundary for that model without
adding parser syntax and without touching RuntimeMachine cache semantics.

---

## Decisions

[D] `read History[T]` and `read BiHistory[T]` now classify as temporal nodes:

```text
node_fragment_class  = temporal
value_fragment_class = core
contract fragment    = temporal
```

The classifier registers the bound symbol as a CORE value (`temporal_read`) so
pure downstream output/compute declarations can remain CORE while the contract
records that temporal capability was required.

[D] TypeChecker preserves temporal node/value metadata from ClassifiedProgram
into TypedProgram declarations.

[D] Existing History/BiHistory diagnostics remain the primary compatibility
rules, with PROP-028 OOF-TM aliases attached:

| Primary | Alias | Meaning |
|---------|-------|---------|
| `OOF-H1` | `OOF-TM1` | History read missing `as_of` |
| `OOF-BT1` | `OOF-TM3` | History `as_of` is not `DateTime` |
| `OOF-BT2` | `OOF-TM4` | BiHistory read missing `vt` |
| `OOF-BT3` | `OOF-TM5` | BiHistory read missing `tt` |
| `OOF-BT4` | `OOF-TM6` | BiHistory axis is not `DateTime` |

[D] Stream behavior is preserved. This slice does not rename existing stream
`escape` fixtures to `stream`, and it does not weaken SC-1/2/3 or OOF-S rules.

---

## Shipped

- Classifier temporal type detection for `History` and `BiHistory`.
- Classifier proof fixtures for temporal `History[T]` and `BiHistory[T]` reads.
- TypeChecker propagation of `node_fragment_class`, `value_fragment_class`,
  `required_capability`, and `temporal_axis`.
- TypeChecker proof cases for:
  - valid `History[T]` read with explicit `as_of`
  - missing `as_of`
  - wrong `as_of` type
  - existing BiHistory `vt`/`tt`/axis cases with OOF-TM aliases
- Updated goldens for classifier and typechecker proof boundaries.

---

## Remaining Requirements

[R] SemanticIR still needs first-class temporal lowering:

```text
temporal_access_node
  node_fragment_class: temporal
  value_fragment_class: core
  axis: valid_time | bitemporal
  coordinate refs: as_of | vt/tt
  required_capability: history_read | bihistory_read
```

[R] RuntimeMachine cache is intentionally deferred. A future slice must prove:

```text
CORE     = hash(contract, inputs)
TEMPORAL = hash(contract, inputs, temporal_coordinates)
```

[R] Production parser syntax for explicit temporal read coordinates remains
future work. Current proof fixtures are hand-authored ParsedProgram /
ClassifiedProgram boundaries.

[R] Not implemented here:

- `OOF-TM2` ambient-time misuse.
- `OOF-TM7` temporal read inside CORE-required lambda/body.
- `OOF-TM8` missing TBackend capability check.
- `OOF-TM9` CORE cache key misuse for temporal contracts.
- any `fold_temporal` surface; PROP-028 explicitly rejects it.

---

## Verification

```text
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
  -> PASS classifier_pass_proof

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
  -> PASS typechecker_proof
```

Full golden and integration verification for this slice:

```text
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

---

## Handoff

```text
Card: S3-R2-C2-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/temporal-fragment-classifier-typechecker-v0
Status: done

[D] Decisions:
- Implemented/proved first PROP-028 TEMPORAL classifier/typechecker boundary.
- `History[T]` and `BiHistory[T]` reads are temporal nodes that bind CORE
  values; containing contracts are temporal.
- Existing History/BiHistory primary diagnostics remain stable and now carry
  OOF-TM aliases.
- Stream classifier/typechecker behavior is preserved.

[S] Shipped / Signals:
- Classifier proof has positive History/BiHistory temporal read fixtures.
- TypeChecker proof has positive History plus OOF-TM alias checks for
  missing/wrong temporal coordinates.
- TypedProgram preserves temporal fragment metadata for future SemanticIR.

[T] Tests / Proofs:
- classifier_pass_proof: PASS.
- typechecker_proof: PASS.
- Golden checks and stream/stage1 integration listed above.

[R] Risks / Recommendations:
- Parser coordinate syntax is not implemented; proof fixtures are hand-authored.
- SemanticIR/runtime still need temporal_access_node and temporal cache key
  semantics.
- OOF-TM2/TM7/TM8/TM9 remain future compiler/runtime checks.

[Next] Suggested next slice:
- temporal-semanticir-access-node-v0: lower typed temporal read metadata into
  `temporal_access_node` and carry temporal cache policy metadata without
  enabling RuntimeMachine temporal memoization yet.
```

## Files Changed

```text
igniter-lang/lib/igniter_lang/classifier.rb
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
igniter-lang/experiments/classifier_pass_proof/fixtures/temporal_history_read.parsed_ast.json
igniter-lang/experiments/classifier_pass_proof/fixtures/temporal_bihistory_read.parsed_ast.json
igniter-lang/experiments/classifier_pass_proof/golden/temporal_history_read.classified.json
igniter-lang/experiments/classifier_pass_proof/golden/temporal_bihistory_read.classified.json
igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
igniter-lang/experiments/typechecker_proof/classified/history_valid.classified.json
igniter-lang/experiments/typechecker_proof/classified/negative_history_missing_as_of.classified.json
igniter-lang/experiments/typechecker_proof/classified/negative_history_wrong_as_of_type.classified.json
igniter-lang/experiments/typechecker_proof/classified/bihistory_valid.classified.json
igniter-lang/experiments/typechecker_proof/classified/negative_bihistory_missing_vt.classified.json
igniter-lang/experiments/typechecker_proof/classified/negative_bihistory_missing_tt.classified.json
igniter-lang/experiments/typechecker_proof/classified/negative_bihistory_wrong_axis_type.classified.json
igniter-lang/experiments/typechecker_proof/golden/history_valid.typed.json
igniter-lang/experiments/typechecker_proof/golden/negative_history_missing_as_of.typed.json
igniter-lang/experiments/typechecker_proof/golden/negative_history_wrong_as_of_type.typed.json
igniter-lang/experiments/typechecker_proof/golden/bihistory_valid.typed.json
igniter-lang/experiments/typechecker_proof/golden/negative_bihistory_missing_vt.typed.json
igniter-lang/experiments/typechecker_proof/golden/negative_bihistory_missing_tt.typed.json
igniter-lang/experiments/typechecker_proof/golden/negative_bihistory_wrong_axis_type.typed.json
igniter-lang/docs/tracks/temporal-fragment-classifier-typechecker-v0.md
```
