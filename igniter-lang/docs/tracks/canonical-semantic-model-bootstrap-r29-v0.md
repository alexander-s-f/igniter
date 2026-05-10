# Track: Canonical Semantic Model Bootstrap (R29)

Card: S3-R29-C5-P (Meta Expert)
Agent: `[Igniter-Lang Meta Expert]`
Role: `meta-expert`
Track: `canonical-semantic-model-bootstrap-r29-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Create the first compact CSM entity index as a verifiable cross-reference for
all implemented and proposed language entities in the Igniter-Lang compiler.

This is an index, not a design document. Aspirational entities not backed by
golden files are at most `spec_candidate`.

---

## Deliverables

### File created: `igniter-lang/docs/dev/canonical-semantic-model.md`

The `docs/dev/` directory was created as part of this card (did not previously exist).

**Sections:**

| Section | Content |
|---------|---------|
| Schema | Column definitions + status legend |
| Contract + Modifiers | 6 rows (pure implicit/explicit + observed/effect/privileged/irreversible) |
| Type Declaration | 4 rows (basic, record, History[T], BiHistory[T]) |
| Receipt | 1 row (runtime shape; Effect Surface stub noted) |
| Escape Declaration | 2 rows (body-level + escape_boundaries in SemanticIR) |
| Stream Node | 3 rows (stream, window, fold_stream) |
| Temporal Read | 4 rows (History read, BiHistory read, temporal_input_node, temporal_access_node) |
| Assumption | 2 rows (spec_candidate; no anchor) |
| Form Constructor | 1 row (spec_candidate; no anchor) |
| Loop Class | 4 rows (spec_candidate; no anchor) |
| OOF Code Registry | 9 rows: 6 active (all with anchors), 3 deferred (no anchor) |
| Missing Anchor Log | 8 entries |
| R30 Recommendations | Priority guidance for PROP-032 and OOF-I deferred codes |

### Golden anchor status

All implemented and experiment-pass entities have verified golden files:

| Experiment directory | Entities covered |
|---------------------|-----------------|
| `contract_modifiers_proof/golden/` | Contract (pure impl/expl), observed, effect/privileged/irreversible, OOF-M1 |
| `source_to_semanticir_fixture/golden/` | Type (basic, record), stream node, fold_stream, stream OOF |
| `temporal_semanticir_access_node/golden/` | History[T], BiHistory[T], temporal_input_node, temporal_access_node |
| `classifier_pass_proof/golden/` | OOF-P1, OOF-S2, OOF-S4, OOF-CE4, OOF-OS2 |
| `runtime_machine_memory_proof/ffi_ruby_receipt_fixtures/` | Receipt (FFI shape) |
| `history_type_proof/golden/` | History[T] TypeChecker PASS |
| `typechecker_proof/golden/` | BiHistory[T] negative cases |

### Entities without golden anchors (spec_candidate)

| Entity | Gap | Note |
|--------|-----|------|
| `assumptions {}` | Gap-H | PROP-032 target; HIGH priority |
| `uses assumptions NAME` | Gap-H | Depends on assumptions block |
| `form NAME -> T` | Gap-I | No PROP yet |
| Loop class (all variants) | Stage 3 Language Lane | No PROP yet |
| OOF-I1, I3, I5 | Stage 2 deferred | PROP-025 addendum needed |
| Receipt (production shape) | PROP-035 (Effect Surface) | Runtime only so far |

---

## R30 Recommendations

1. **PROP-032 (Assumptions)**: write the PROP draft (Gap-H HIGH), then route to
   Research Agent for minimum fixture: one positive case + one OOF for undeclared
   assumption in contract body. This unblocks the `spec_candidate → experiment-pass`
   promotion in CSM.

2. **OOF-I deferred codes (I1, I3, I5)**: no new PROP needed. Add an addendum to
   PROP-025 and create targeted fixtures. Three small additions to the classifier
   and a golden check close all three missing anchors.

3. **CSM maintenance**: the maintenance rule is now in the document:
   > If you add a new entity to the compiler, add a row here.
   > If the row has no golden anchor, the status is `spec_candidate`.
   Compiler/Grammar Expert should consult CSM before adding new parser nodes
   or fragment classes.

---

## Handoff

```text
Card: S3-R29-C5-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: canonical-semantic-model-bootstrap-r29-v0
Status: done

[D] Decisions
- docs/dev/ created (new directory). CSM lives at docs/dev/canonical-semantic-model.md.
- All implemented/experiment-pass entities have at least one golden anchor — constraint satisfied.
- Receipt status: implemented (FFI shape in runtime_machine_memory_proof).
  Full production shape (authority, compensation, audit ref) is PROP-035 scope.
- OOF-M1 through OOF-OS2 (6 active codes) all have goldens in classifier_pass_proof/golden/.
  OOF-I1/I3/I5 (3 deferred codes) have no goldens — PROP-025 addendum needed.
- Form constructor and Loop class: spec_candidate, no PROP, no anchor.
  Do not promote until a PROP draft exists.

[S] Shipped / Signals
- igniter-lang/docs/dev/canonical-semantic-model.md: 10 entity groups, 9 OOF codes, 8 missing anchors, R30 guidance.
- All golden paths verified against disk (experiments/ directory structure confirmed).
- OOF code active list confirmed: OOF-M1, OOF-P1, OOF-S2, OOF-S4, OOF-CE4, OOF-OS2.

[T] Tests / Proofs
- Documentation only. No code changes. No proof runner affected.
- Golden file paths were verified by filesystem inspection during card execution.

[R] Risks / Recommendations
- CSM can become stale if compiler work proceeds without updating it.
  The maintenance rule in the document is the guard — it should be cited in PROP templates.
- Receipt production shape is the largest open gap in the CSM: PROP-035 (Effect Surface)
  is the blocking PROP for authority, compensation, audit reference, and proof-of-send
  semantics. Until PROP-035, Receipt remains implemented only at FFI/runtime shape level.
- `form` constructor (V-5 from R28 cross-review) is spec_candidate only. If Gap-I
  does not advance to a PROP in Stage 3, the V-5 principle in Covenant P27 will remain
  aspirational.

[Next] Suggested next slice
- R29/R30: PROP-032 (assumptions block) — bootstrap draft, Research Agent fixture
- R30: OOF-I1/I3/I5 deferred invariant codes — PROP-025 addendum + targeted fixtures
- META-EXPERT reconciliation: PROP Governance Filter → META-EXPERT-013 §VI
- CSM update: add rows as new entities land; update status on PROP-032 close
```
