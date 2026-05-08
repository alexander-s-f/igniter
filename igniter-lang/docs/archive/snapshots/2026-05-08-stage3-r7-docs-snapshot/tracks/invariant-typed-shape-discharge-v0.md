# Track: Invariant Typed Shape Discharge v0

Card: S3-R7-C2-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/invariant-typed-shape-discharge-v0`
Status: done
Date: 2026-05-08

---

## Goal

Discharge the known `invariant_valid` typed-shape delta after
`SemanticIREmitter#emit_typed(typed)` became the production compiler path.

---

## Context

Current production path:

```text
Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed -> Assembler
```

The legacy parsed emitter remains only as a Stage 1 comparison path. Therefore
strict parsed-vs-typed shape equality is no longer the acceptance criterion for
Stage 2 surfaces that only the typed path can lower.

---

## Comparison

For `invariant_valid`, both paths compile successfully:

```text
legacy parsed emission: pass_result ok
typed emission:         pass_result ok
```

The shape delta is:

```text
SemanticIR:
- parsed path has compute node only
- typed path has compute + 4 invariant_node entries
- typed path adds top-level invariants[]

CompilationReport:
- typed path adds invariant_coverage[]
```

This is the expected public typed-production shape. The parsed emitter omitted
the Stage 2 invariant lowering surface.

---

## Decision

[D] Accepted delta, not a bug.

`invariant_valid` is now marked `PASS` in the typed emission parity proof when
the only differences are:

- `$.invariants` missing from parsed path;
- `$.contracts[0].nodes` length `1 -> 5`;
- `$.invariant_coverage` missing from parsed report.

The proof records these under `accepted_delta_items` with an explicit
acceptance reason.

[D] No rollback to parsed emitter.

[D] Diagnostic category shift is accepted:

```text
before emit_typed switch: classifier_oof
after emit_typed switch:  typechecker_oof
```

This is expected because production compilation now reaches TypeChecker before
producing the unresolved-symbol OOF.

---

## Implementation

Updated:

```text
igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
```

The proof now separates:

- `accepted_deltas`
- `unaccepted_deltas`
- top-level `accepted_delta_items`

`legacy_parity_delta_items` now excludes accepted `invariant_valid` deltas.

Generated evidence:

```text
igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.json
igniter-lang/experiments/typed_emission_main_path_parity/golden/typed_emission_main_path_parity.golden.json
```

---

## Proof Output

```text
ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
```

Result:

```text
PASS typed_emission_main_path_parity
invariant_valid: PASS
typed_source_blocked_items: 0
legacy_parity_delta_items: 12
accepted_delta_items: 2
```

The overall parity verdict remains `blocked` because other Stage 2 surfaces
still intentionally differ from the legacy parsed comparison path. The
`invariant_valid` C-8 debt is discharged.

Additional guards:

```text
PASS invariant_severity_proof
PASS production_compiler_cli_proof
  negative.category: typechecker_oof
PASS stage1_close_candidate
PASS stage2_close_candidate
```

---

## Remaining Gap

No invariant typed-shape gap remains.

The remaining parity proof blockers are legacy parsed-vs-typed deltas for other
Stage 2 surfaces and the metadata-only descriptor case. They are not caused by
`invariant_valid`.

---

## Handoff

```text
Card: S3-R7-C2-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/invariant-typed-shape-discharge-v0
Status: done

[D] Decisions:
- Accepted `invariant_valid` typed shape as the public production shape.
- Classified the delta as expected typed lowering, not a bug.
- Accepted `classifier_oof -> typechecker_oof` as the typed production
  diagnostic category shift.

[S] Shipped / Signals:
- Updated typed emission parity proof to record accepted invariant deltas.
- `invariant_valid` now passes in the parity evidence.

[T] Tests / Proofs:
- typed_emission_main_path_parity PASS runner; `invariant_valid: PASS`.
- invariant_severity_proof PASS.
- production_compiler_cli_proof PASS with `negative.category: typechecker_oof`.
- Stage 1 and Stage 2 close candidates PASS.

[R] Risks / Recommendations:
- Do not restore parsed emitter as production path.
- Future spec/status curation can mark Ch5 C-8 discharged from this track.

[Next] Suggested next slice:
- Discharge remaining legacy parity deltas only if they are still actionable;
  do not treat legacy parsed omissions as typed production blockers.
```
