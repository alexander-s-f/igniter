# Source To SemanticIR Executable Fixture v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/source-to-semanticir-executable-fixture-v0`
Status: done
Date: 2026-05-06

## Purpose

Prove the smallest executable path from current `.ig` source syntax through
`ParsedProgram` into a SemanticIR-like fixture shape.

This is a proof fixture, not the full compiler. It uses the current parser and
a tiny stdlib-only classifier/type/lowering runner under:

`igniter-lang/experiments/source_to_semanticir_fixture/`

## Current Horizon

- Current parser accepts the fixture source subset: `module`, `type`,
  `contract`, `input`, `compute`, `output`, binary ops, refs, and field access.
- The fixture emits SemanticIR-like JSON for CORE contracts only.
- OOF-P1, OOF-OS2, and OOF-CE4 are proven before RuntimeMachine/package work.
- Domain-specific claim/evidence/alert syntax is not available yet; the proof
  models those concepts through current `type` + `contract` syntax.
- This does not claim `.igapp` packaging, RuntimeMachine load, or general
  SemanticIR emitter completeness.

## Fixture Map

Positive sources:

- `add.ig` -> `Add`: `Integer + Integer -> Integer`
- `claim_evidence.ig` -> `ClaimEvidenceBundle`: synthetic `Claim` +
  `EvidenceLink` field projection
- `evidence_linked_alert.ig` -> `EvidenceLinkedAlertGate`: synthetic alert gate
  that passes with non-empty signal/claim counts

Negative sources:

- `negative_unresolved_symbol.ig` -> `OOF-P1`
- `negative_evidence_less_alert.ig` -> `OOF-OS2`
- `negative_confidence_bool.ig` -> `OOF-CE4`

Golden outputs:

- `golden/*.parsed_ast.json`
- `golden/*.semantic_ir.json`
- `golden/summary.json`

## What Is Proven

[D] Parsed source can be consumed directly through
`IgniterLang::ParsedProgram.parse`.

[D] The fixture lowerer produces SemanticIR-like JSON with:

- `contract_ref`
- `fragment_class`
- typed `inputs` / `outputs`
- typed compute `nodes`
- lowered stdlib operators:
  - `stdlib.integer.add`
  - `stdlib.integer.gt`
  - `stdlib.bool.and`
- `oof_log`

[D] `EvidenceLinkedAlertGate` is trusted only when the fixture evidence gate
sees non-empty synthetic signal/claim evidence. The negative case is
non-admitted with `OOF-OS2`.

[D] `ConfidenceLabel` is preserved as a distinct type and is rejected when used
as `Bool` (`OOF-CE4`).

## Proof Output

Run:

```bash
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
```

Output:

```text
parse.add: ok
semanticir.add: ok
parse.claim_evidence: ok
semanticir.claim_evidence: ok
parse.evidence_linked_alert: ok
semanticir.evidence_linked_alert: ok
negative.unresolved_symbol: ok
negative.evidence_less_alert: ok
negative.confidence_bool: ok
golden.ast_outputs: ok
golden.semanticir_outputs: ok
golden.dir: igniter-lang/experiments/source_to_semanticir_fixture/golden
PASS source_to_semanticir_fixture
```

## Compiler Gap List

[Q] Compiler/Grammar Expert: decide whether `Claim`, `EvidenceLink`,
`ConfidenceLabel`, and `EvidenceLinkedAlert` become stdlib type names only or
receive first-class source syntax.

[Q] Compiler/Grammar Expert: formalize the minimal typechecker boundary for:

- field access against declared `type` shapes
- boolean position checks
- evidence gate checks that depend on fixture/sample values

[Q] Compiler/Grammar Expert: decide whether this SemanticIR-like JSON should
converge on PROP-018's single-contract shape or the broader `.igapp`
`semantic_ir.json` program shape.

[Q] Bridge Agent: when approved, bridge profiles should preserve the difference
between source observations/evidence links and result values. The fixture keeps
evidence as a gate, not as ambient prose.

## Rejected

[X] No general migration DSL, RuntimeMachine load, `.igapp` fixture, or package
integration in this slice.

[X] No domain-specific parser keywords were added for claim/evidence/alert.

[X] No claim that confidence means truth or actionability.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/source-to-semanticir-executable-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Use current parser syntax for all source examples.
- Keep domain trust concepts as typed fixture contracts, not new grammar.
- Emit SemanticIR-like JSON and OOF logs from a tiny proof compiler only.

[R] Recommendations:
- Compiler/Grammar Expert should turn this into a formal compiler conformance
  suite once the SemanticIR output shape is settled.
- Bridge Agent should preserve evidence-link admission semantics in future
  bridge profiles.

[S] Signals:
- Current parser is enough for a small source -> AST -> SemanticIR proof.
- Field access, stdlib operator lowering, evidence gates, and confidence
  non-Bool typing are the next useful compiler boundary tests.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
  -> PASS source_to_semanticir_fixture

[Files] Changed:
- igniter-lang/experiments/source_to_semanticir_fixture/add.ig
- igniter-lang/experiments/source_to_semanticir_fixture/claim_evidence.ig
- igniter-lang/experiments/source_to_semanticir_fixture/evidence_linked_alert.ig
- igniter-lang/experiments/source_to_semanticir_fixture/negative_unresolved_symbol.ig
- igniter-lang/experiments/source_to_semanticir_fixture/negative_evidence_less_alert.ig
- igniter-lang/experiments/source_to_semanticir_fixture/negative_confidence_bool.ig
- igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
- igniter-lang/experiments/source_to_semanticir_fixture/golden/*.parsed_ast.json
- igniter-lang/experiments/source_to_semanticir_fixture/golden/*.semantic_ir.json
- igniter-lang/experiments/source_to_semanticir_fixture/golden/summary.json
- igniter-lang/docs/tracks/source-to-semanticir-executable-fixture-v0.md

[Q] Open Questions:
- Should evidence-gated checks live in classifier Pass 1, evaluator fixtures,
  or both?
- Which SemanticIR JSON envelope is canonical for source compiler proofs?

[X] Rejected:
- No RuntimeMachine/package claims.
- No domain-specific grammar additions.

[Next] Proposed next slice:
- source-to-semanticir-conformance-shape-v0: align this fixture's emitted JSON
  with the canonical SemanticIR/.igapp envelope and add a stable checker mode.
```
