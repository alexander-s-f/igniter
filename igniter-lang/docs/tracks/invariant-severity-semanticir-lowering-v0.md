# Track: Invariant Severity SemanticIR Lowering v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: `igniter-lang/invariant-severity-semanticir-lowering-v0`
Card: S2-R11-C2-P
Status: done
Date: 2026-05-07
Depends on: S2-R10-C4-P, S2-R9-C2-P

---

## Context

`invariant-severity-parser-impl-v0` completed the parser and TypeChecker boundary:

- PINV-1..4 implemented in the parser.
- TINV-1..3 implemented in the TypeChecker.
- Typed invariant declarations now carry `predicate_ref`, `predicate_type`,
  `severity`, `label`, `message`, `overridable_with`, and `output_effect`.
- Typed output declarations propagate `warnings_from`, `uncertain_from`, and
  `metrics_from`.

S2-R9 introduced `SemanticIREmitter#emit_typed` for Stage 2 surfaces. This slice
lowers the typed invariant boundary into SemanticIR.

---

## Implemented Boundary

[D] `SemanticIREmitter#emit_typed` now lowers typed `kind: "invariant"`
declarations into `invariant_node` entries:

```json
{
  "kind": "invariant_node",
  "name": "major_interaction_acknowledgement",
  "predicate": "major_interactions_acknowledged",
  "predicate_ref": "major_interactions_acknowledged",
  "predicate_type": { "name": "Bool", "params": [] },
  "severity": "warn",
  "label": "CG-INTERACTION-02",
  "message": "Major drug interaction requires acknowledgement",
  "overridable_with": "documented_justification",
  "output_effect": "warns",
  "deps": ["major_interactions_acknowledged"],
  "fragment": "core"
}
```

[D] Compile-time lowering emits `invariant_node`, not
`invariant_violation_node`. Violation nodes are runtime observations and remain
outside the compiler boundary for this slice.

[D] The typed emitter preserves output effect propagation on SemanticIR outputs:

```json
{
  "name": "approved_dose",
  "warnings_from": ["major_interaction_acknowledgement"],
  "uncertain_from": ["renal_confidence_gate"],
  "metrics_from": ["latency_metric"]
}
```

[D] Typed SemanticIR programs now include top-level `invariants` when invariant
nodes are present. The typed compilation report includes `invariant_coverage`
with severity, label, output policy, and output effect.

[D] The parsed-source `emit(parsed_program, sample_input:)` path is unchanged.
`source_to_semanticir_fixture --check-golden` remains stable.

---

## Proof Updates

[S] `invariant_severity_proof` now builds a proof-local `TypedProgram` and calls:

```ruby
IgniterLang::SemanticIREmitter.new.emit_typed(invariant_typed_program)
```

The runtime proof consumes emitted SemanticIR instead of a hand-authored
SemanticIR program.

New proof signals:

```text
semanticir.emitter_typed_program_ref: ok
semanticir.invariant_nodes_from_typed: ok
semanticir.output_effect_preserved: ok
```

[S] Existing PINV/TINV diagnostics remain owned by parser/typechecker. This
slice does not implement OOF-I1, OOF-I3, or OOF-I5.

---

## Invariant Matrix

| Item | Owner | Status | Notes |
|------|-------|--------|-------|
| PINV-1 | Parser | done | `invariant` keyword |
| PINV-2 | Parser | done | invariant attribute keywords |
| PINV-3 | Parser | done | `parse_invariant_decl`, OOF-IV1/IV2/I4 static cases |
| PINV-4 | Parser | done | body dispatcher |
| TINV-1 | TypeChecker | done | handles `kind: invariant` |
| TINV-2 | TypeChecker | done | predicate Bool check, override semantics, effect mapping |
| TINV-3 | TypeChecker | done | OOF-IV3 blocks downstream cascades |
| SemanticIR invariant_node | Emitter | done | this slice |
| SemanticIR output propagation | Emitter | done | `warnings_from`/`uncertain_from`/`metrics_from` |
| SemanticIR invariant coverage | Emitter | done | typed compilation report |
| OOF-I1 | Deferred | open | requires `@bitemporal` surface |
| OOF-I2 | Advisory | open | caller ignores warnings; cross-contract analysis |
| OOF-I3 | Deferred | open | `~T` probabilistic type enforcement absent |
| OOF-I4 | Parser/TypeChecker | done | `overridable_with` on error invariant |
| OOF-I5 | Deferred | open | requirements DB lookup belongs later |
| invariant_violation_node | Runtime | open | runtime observation/lowering, not compiler compile-time IR |

---

## Verification

```text
ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
  -> PASS invariant_severity_proof

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS typechecker_golden_check

ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate

ruby -c igniter-lang/lib/igniter_lang/semanticir_emitter.rb
  -> Syntax OK

ruby -c igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
  -> Syntax OK
```

---

## Handoff

```text
Card: S2-R11-C2-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/invariant-severity-semanticir-lowering-v0
Status: done

[D] Decisions:
- Lowered typed invariant declarations to invariant_node.
- Preserved output effect propagation on output ports.
- Added invariant_coverage to typed compilation reports.
- Kept invariant_violation_node as runtime/future work.
- Did not implement deferred OOF-I1, OOF-I3, or OOF-I5.

[S] Shipped / Signals:
- invariant_severity_proof now consumes SemanticIREmitter#emit_typed output.
- SemanticIR carries severity, label, message, overridable_with, predicate, predicate_type, deps, fragment, and output_effect.
- Parsed-source SemanticIR fixture remains unchanged and PASS.

[T] Tests / Proofs:
- invariant_severity_proof: PASS.
- typechecker_proof --check-golden: PASS.
- source_to_semanticir_fixture --check-golden: PASS.
- stage1_close_candidate: PASS.

[R] Risks / Residuals:
- Runtime invariant violation node emission remains future runtime work.
- OOF-I1/I3/I5 remain intentionally deferred.
- OOF-I2 caller-warning analysis remains advisory/open.

[Next]
- Bridge Agent can wire production TypedProgram orchestration through the typed emitter.
- Future runtime track can turn violated invariant_node results into invariant_violation_node observations.
```
