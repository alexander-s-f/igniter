# Source To SemanticIR Canonical Envelope v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/source-to-semanticir-canonical-envelope-v0`
Status: done
Date: 2026-05-06

## Purpose

Align the executable `source_to_semanticir_fixture` outputs with the current
canonical SemanticIR envelope used by `.igapp` fixtures.

This remains a proof fixture. It does not add language syntax and does not
claim real compiler extraction yet.

## Updated Envelope

The regenerated `golden/*.semantic_ir.json` files now use:

- top-level `kind: "semantic_ir"`
- `axiom_version: "1.0.0"`
- `program_id`, `grammar_version`, `source_hash`
- `contracts[]`
- per-contract `contract_id`, `name`, `fragment_class`, `escape_set`
- `input_ports`, `compute_nodes`, `output_ports`
- `dependency_graph`, `evaluation_targets`
- temporal/lifecycle/capability requirement blocks
- empty effect/FFI/projection/boundary arrays
- `oof_log` for fixture negative cases

Compute expressions now use canonical-style expression nodes:

- `kind: "apply"` with `operator` and `operands`
- `kind: "ref"`
- `kind: "field_access"`
- `kind: "literal"`

## Preserved Cases

Positive:

- `Add`
- `ClaimEvidenceBundle`
- `EvidenceLinkedAlertGate`

Negative:

- `OOF-P1` unresolved symbol
- `OOF-OS2` evidence-less alert
- `OOF-CE4` confidence label used as Bool

## Checker Mode

Default mode regenerates golden output and runs semantic checks:

```bash
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
```

Golden checker mode does not rewrite files. It rebuilds fixture output in
memory and verifies:

- semantic checks still pass
- golden AST JSON matches regenerated AST
- golden SemanticIR JSON matches regenerated SemanticIR
- summary JSON matches regenerated summary
- every SemanticIR file uses the canonical envelope
- two independent generations are deterministic

```bash
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
```

## Proof Output

```text
parse.add: ok
semanticir.envelope.add: ok
semanticir.add: ok
parse.claim_evidence: ok
semanticir.envelope.claim_evidence: ok
semanticir.claim_evidence: ok
parse.evidence_linked_alert: ok
semanticir.envelope.evidence_linked_alert: ok
semanticir.evidence_linked_alert: ok
negative.unresolved_symbol: ok
negative.evidence_less_alert: ok
negative.confidence_bool: ok
golden.ast_outputs: ok
golden.semanticir_outputs: ok
check.golden_semanticir_equal: ok
check.golden_ast_equal: ok
check.summary_equal: ok
check.canonical_all: ok
check.deterministic_generation: ok
golden.dir: igniter-lang/experiments/source_to_semanticir_fixture/golden
PASS source_to_semanticir_fixture_golden_check
```

## Gap List For Real Compiler Extraction

[Q] Compiler/Grammar Expert: choose whether `oof_log` belongs in canonical
SemanticIR proper, or whether OOF diagnostics should live in a sibling
CompilationReport while loadable SemanticIR contains only accepted contracts.

[Q] Compiler/Grammar Expert: extract field-access type resolution from this
fixture into a real type environment with declared shape lookup and diagnostics.

[Q] Compiler/Grammar Expert: decide the canonical operator table names for
integer-specific operators (`stdlib.integer.add`) versus generic numeric
operators (`stdlib.numeric.add`).

[Q] Compiler/Grammar Expert: define whether evidence-gate checks that depend on
sample fixture values are classifier checks, evaluator checks, or conformance
fixture checks.

[Q] Bridge Agent: future bridge profiles should preserve the distinction between
evidence admission (`OOF-OS2` / `OOF-CE4`) and normal result evaluation.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/source-to-semanticir-canonical-envelope-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Regenerated SemanticIR golden files now use the canonical semantic_ir envelope.
- Added --check-golden for canonical-shape and deterministic-output checks.
- Preserved existing positive and negative fixture cases.

[R] Recommendations:
- Extract a real source compiler only after OOF diagnostic placement is settled.
- Add a fixture-to-.igapp packaging check once canonical diagnostics are agreed.

[S] Signals:
- Current parser plus tiny lowerer can now emit a `.igapp`-like SemanticIR
  shape for accepted fixtures.
- OOF cases remain visible without weakening positive contract checks.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
  -> PASS source_to_semanticir_fixture
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check

[Files] Changed:
- igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
- igniter-lang/experiments/source_to_semanticir_fixture/golden/*.semantic_ir.json
- igniter-lang/experiments/source_to_semanticir_fixture/golden/summary.json
- igniter-lang/docs/tracks/source-to-semanticir-canonical-envelope-v0.md

[Q] Open Questions:
- Should rejected contracts appear in SemanticIR, or only in CompilationReport?
- Should stdlib operator names be concrete (`stdlib.integer.add`) or generic
  (`stdlib.numeric.add`) after type resolution?

[X] Rejected:
- No new language syntax.
- No RuntimeMachine or package integration claim.

[Next] Proposed next slice:
- source-to-semanticir-compilation-report-v0: split accepted SemanticIR from
  typed OOF diagnostics and compare both against golden fixtures.
```
