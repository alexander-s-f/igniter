# Track: Spec Ch4 Temporal Fragment Sync v0

Card: S3-R6-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/spec-ch4-temporal-fragment-sync-v0`
Status: done
Date: 2026-05-08

---

## Goal

Bring fragment classification spec up to Stage 3 reality after PROP-028 and
the temporal classifier/typechecker/SemanticIR tracks landed.

---

## Updated File

```text
igniter-lang/docs/spec/ch4-fragment-classification.md
```

---

## Decisions

[D] Added TEMPORAL as a first-class fragment:

```text
OOF > TEMPORAL > STREAM > CORE
```

[D] Kept `ESCAPE` as a legacy/coarse compatibility label for external surfaces
not yet refined into STREAM or TEMPORAL.

[D] Added the Stage 3 split:

```text
node_fragment_class
value_fragment_class
contract_fragment_class
```

[D] Added History/BiHistory classification:

```text
History[T]   + as_of: DateTime -> TEMPORAL node, CORE value, history_read
BiHistory[T] + vt/tt: DateTime -> TEMPORAL node, CORE value, bihistory_read
```

[D] Updated construct classification and propagation tables so temporal reads
do not poison downstream pure compute nodes.

[D] Marked parser coordinate syntax as not yet canon. The examples are pressure
spellings until a parser syntax proposal lands.

---

## Evidence References

- `docs/proposals/PROP-028-temporal-fragment-class-v0.md`
- `docs/tracks/temporal-fragment-classifier-typechecker-v0.md`
- `docs/tracks/temporal-semanticir-access-node-v0.md`
- `experiments/classifier_pass_proof/`
- `experiments/typechecker_proof/`
- `experiments/temporal_semanticir_access_node/`

---

## Non-Goals

[X] No parser grammar changes.

[X] No runtime execution/cache changes.

[X] No proof fixtures changed.

[X] No current-status updates; status-map ownership remains Meta Expert in
Status Curator mode.

---

## Verification

Docs-only sync. Sanity checks:

```text
rg "TEMPORAL" docs/spec/ch4-fragment-classification.md
rg "node_fragment_class" docs/spec/ch4-fragment-classification.md
rg "parser coordinate syntax" docs/spec/ch4-fragment-classification.md
git diff --check -- docs/spec/ch4-fragment-classification.md docs/tracks/spec-ch4-temporal-fragment-sync-v0.md
```

---

## Handoff

```text
Card: S3-R6-C4-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/spec-ch4-temporal-fragment-sync-v0
Status: done

[D] Decisions:
- Added TEMPORAL as first-class fragment and documented refined ordering.
- Added node/value/contract fragment split.
- Added History/BiHistory classification and OOF-TM compatibility aliases.
- Updated construct and propagation tables.
- Marked parser coordinate syntax as not canon yet.

[S] Shipped / Signals:
- ch4 now matches PROP-028 and S3-R2/R3 temporal compiler evidence.

[T] Tests / Proofs:
- Docs-only; no code proof required.

[R] Risks / Recommendations:
- Future parser syntax proposal must settle accepted source spelling for
  History/BiHistory temporal coordinates.
- Legacy `escape` serialization for some stream fixtures should not be confused
  with the Stage 3 semantic STREAM class.

[Next] Suggested next slice:
- spec-parser-temporal-coordinate-syntax-v0 after a parser syntax proposal is
  assigned.
```

## Files Changed

```text
igniter-lang/docs/spec/ch4-fragment-classification.md
igniter-lang/docs/tracks/spec-ch4-temporal-fragment-sync-v0.md
```
