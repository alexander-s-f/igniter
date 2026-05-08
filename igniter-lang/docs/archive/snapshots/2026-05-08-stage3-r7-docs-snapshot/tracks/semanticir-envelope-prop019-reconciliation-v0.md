# SemanticIR Envelope PROP-019 Reconciliation v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/semanticir-envelope-prop019-reconciliation-v0`
Status: done
Date: 2026-05-06

## Purpose

Reconcile `source_to_semanticir_fixture` goldens with PROP-019 literally.

The fixture output is now PROP-019 compliant for this proof surface.

## Scope

Updated only the source-to-SemanticIR fixture emitter/checker and its generated
golden outputs. No new source syntax was added. No `.igapp` assembler was
started.

## Envelope Changes

Migrated `golden/*.semantic_ir.json` from the previous `.igapp`-like shape:

- `kind: "semantic_ir"`
- `contract_id`
- `input_ports` / `compute_nodes` / `output_ports`
- `type_tag`
- `expression`

to PROP-019:

- `kind: "semantic_ir_program"`
- `format_version: "0.1.0"`
- `contract_ref`
- `inputs` / `nodes` / `outputs`
- `type: { name, params }`
- `expr`
- `resolved_type` on every ExprIR

`summary.json` now includes:

```json
{ "prop019_compliant": true }
```

## Preserved Cases

Positive:

- `Add`
- `ClaimEvidenceBundle`
- `EvidenceLinkedAlertGate`

Negative:

- `OOF-P1`
- `OOF-OS2`
- `OOF-CE4`

## Proof Output

```text
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
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
golden.dir: igniter-lang/experiments/source_to_semanticir_fixture/golden
PASS source_to_semanticir_fixture
```

```text
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
check.golden_semanticir_equal: ok
check.golden_ast_equal: ok
check.summary_equal: ok
check.canonical_all: ok
check.deterministic_generation: ok
PASS source_to_semanticir_fixture_golden_check
```

## Gap List

[Q] Compiler/Grammar Expert: confirm whether OOF contracts should remain in
`semantic_ir_program.contracts` for proof fixtures or move to a sibling
CompilationReport before any RuntimeMachine load path.

[Q] Compiler/Grammar Expert: formalize `contract_ref` hash input. The fixture
uses deterministic JSON for the contract body excluding `contract_ref` and
`oof_log`.

[Q] Compiler/Grammar Expert: decide the canonical representation for
field-access ExprIR. PROP-019 examples cover `call`, `ref`, `literal`, and
`record`; this fixture uses `field_access` with `resolved_type`.

[Q] Bridge Agent: bridge consumers should reject deprecated keys
`contract_id`, `input_ports`, `compute_nodes`, `output_ports`, `type_tag`, and
`expression` for PROP-019 mode.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/semanticir-envelope-prop019-reconciliation-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- source_to_semanticir_fixture goldens now use PROP-019 semantic_ir_program.
- All ExprIR nodes carry resolved_type.
- summary.json explicitly marks prop019_compliant: true.

[R] Recommendations:
- Do not start .igapp assembler until OOF contract placement is resolved.
- Extract a dedicated PROP-019 validator before wider fixture migration.

[S] Signals:
- The existing positive/negative fixture set survives the PROP-019 envelope.
- Deterministic golden checking still passes.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
  -> PASS source_to_semanticir_fixture
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check

[Files] Changed:
- igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
- igniter-lang/experiments/source_to_semanticir_fixture/golden/*.semantic_ir.json
- igniter-lang/experiments/source_to_semanticir_fixture/golden/summary.json
- igniter-lang/docs/tracks/semanticir-envelope-prop019-reconciliation-v0.md

[Q] Open Questions:
- Should OOF contracts remain in SemanticIR proof goldens?
- Should field_access be explicitly added to PROP-019 ExprIR examples?

[X] Rejected:
- No new source syntax.
- No .igapp assembler.

[Next] Proposed next slice:
- prop019-validator-proof-v0: standalone checker for semantic_ir_program
  goldens, reusable by future fixtures.
```
