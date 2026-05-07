# Parser OOF Hardening Stage 2 Proof v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/parser-oof-hardening-stage2-proof-v0`
Status: done
Date: 2026-05-07

## Goal

Implement the parser hardening proof after Compiler/Grammar Expert defined the
parser/classifier/typechecker OOF ownership line in `PROP-024`.

## Decisions

[D] Parser hardening was limited to syntax-owned OOF:

```text
OOF-P2   pipeline/step inside contract body
OOF-DM3  Decimal without scale parameter
OOF-PG1  empty pipeline block
OOF-PG2  step without contract ref
OOF-PG3  scoped_by on non-read node
OOF-PG5  tenant_free on non-read node
```

[D] Semantic OOF remains outside the parser. The proof keeps these accepted by
the parser and blocked by later passes:

```text
OOF-P1   unresolved symbol
OOF-OS2  evidence-less alert
OOF-CE4  ConfidenceLabel used as Bool
```

[D] Parser errors now use structured entries with `rule`, `severity`, `message`,
`token`, `line`, and `col` for the hardened cases.

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/parser_oof_hardening_stage2_proof/parser_oof_hardening_stage2_proof.rb
```

Output:

```text
PASS parser_oof_hardening_stage2_proof
existing_parser_fixtures_green: ok
syntax_oof_rejected_at_parser: ok
syntax_oof_rules_match: ok
semantic_oof_accepted_by_parser: ok
semantic_oof_blocked_later: ok
oof_p2_pipeline_inside_contract: parser=rejects rule=OOF-P2
oof_dm3_decimal_without_scale: parser=rejects rule=OOF-DM3
oof_pg1_empty_pipeline: parser=rejects rule=OOF-PG1
oof_pg2_step_without_contract_ref: parser=rejects rule=OOF-PG2
oof_pg3_scoped_by_on_compute: parser=rejects rule=OOF-PG3
oof_pg5_tenant_free_on_compute: parser=rejects rule=OOF-PG5
negative_unresolved_symbol: parser=accepts later=oof
negative_evidence_less_alert: parser=accepts later=oof
negative_confidence_bool: parser=accepts later=oof
summary: igniter-lang/experiments/parser_oof_hardening_stage2_proof/parser_oof_hardening_stage2_proof.json
```

Stage 1 close candidate remains green:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
```

## Evidence Summary

[S] Machine-readable summary:

```text
experiments/parser_oof_hardening_stage2_proof/parser_oof_hardening_stage2_proof.json
```

[S] Existing parser fixtures remain accepted with `parse_errors: []`:

```text
source/add.ig
source/availability_projection.ig
source/decimal_contract.ig
source/polymorphic_add.ig
source/tenant_availability_projection.ig
source/vendor_lead_pipeline.ig
```

## Remaining Gaps

[Q] Parser warning diagnostics from PROP-024 (`PW-1..PW-3`) are still not
implemented. This proof only hardens syntax-owned OOF errors.

[Q] Classifier skip/forwarding for parser-error contracts is documented in
PROP-024 but not implemented in this slice because this proof does not run a
production classifier over parser-error ASTs.

## Rejected

[X] Did not move semantic OOF into parser.

[X] Did not add symbol table, type environment, evidence policy lookup, or
runtime state to parser.

[X] Did not change Stage 2 primitives.

## Changed Files

```text
experiments/parser/igniter_lang_parser.rb
experiments/parser_oof_hardening_stage2_proof/
docs/tracks/parser-oof-hardening-stage2-proof-v0.md
```

## Next

[Next] Add parser warning diagnostics (`PW-1..PW-3`) only if Compiler/Grammar
Expert wants warning-only developer UX in Stage 2.
