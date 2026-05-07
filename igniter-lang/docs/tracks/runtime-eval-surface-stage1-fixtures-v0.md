# Runtime Eval Surface Stage 1 Fixtures v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/runtime-eval-surface-stage1-fixtures-v0`
Status: done
Date: 2026-05-06

## Goal

Extend direct RuntimeMachine proof evaluation beyond assembled Add.

## What Changed

[D] The proof RuntimeMachine evaluator now supports the remaining expression
surface needed by current Stage 1 assembled fixtures:

```text
field_access
literal
stdlib.integer.gt
stdlib.bool.and
```

[D] `igapp_assembler_proof` now evaluates all three positive assembled
PROP-019.1 `.igapp/` artifacts:

```text
Add
ClaimEvidenceBundle
EvidenceLinkedAlertGate
```

[D] The direct PROP-019.1 loader path is preserved. The assembled artifacts
still do not write or load from legacy `semantic_ir.json`.

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
```

Relevant output:

```text
runtime.load_direct_prop0191: ok
runtime.evaluate_assembled_add: ok
runtime.evaluate_assembled_claim_evidence: ok
runtime.evaluate_assembled_evidence_linked_alert: ok
runtime.compatibility_report_trusted: ok
runtime.add.output_value: 42
runtime.claim_evidence.output_value: claim/synthetic/vendor-status
runtime.evidence_linked_alert.output_value: true
```

Runtime summary:

```json
{
  "add": { "output_value": 42, "compatibility_report_status": "trusted" },
  "claim_evidence": {
    "output_value": "claim/synthetic/vendor-status",
    "compatibility_report_status": "trusted"
  },
  "evidence_linked_alert": {
    "output_value": true,
    "compatibility_report_status": "trusted"
  }
}
```

## Stage 1 Close Candidate

`stage1_close_candidate.json` now moves `runtime_eval_surface` from remaining
gap to closed signal:

```text
closed: runtime_eval_surface
remaining gaps: parser_oof_rejection_gap, production_compiler_assembly
```

## Follow-Up Closure

[D] Follow-up track `canonical-stdlib-registry-runtime-v0` closed the
historical operator compatibility gap. The RuntimeMachine proof now rejects
`"add"`, `stdlib.numeric.add`, and unknown `stdlib.*` operators.

## Remaining Gaps

[Q] Production compiler assembly is still proof-local.

[Q] Parser OOF hardening remains a governance/grammar decision, not a runtime
eval blocker.

## Rejected

[X] No production package integration.

[X] No Stage 2 primitives.

[X] No new source syntax.

## Changed Files

```text
experiments/runtime_machine_memory_proof/compiled_program.rb
experiments/igapp_assembler_proof/igapp_assembler_proof.rb
experiments/igapp_assembler_proof/out/result_summary.json
experiments/stage1_close_candidate/stage1_close_candidate.rb
experiments/stage1_close_candidate/stage1_close_candidate.json
docs/tracks/runtime-eval-surface-stage1-fixtures-v0.md
```

## Next

[Next] Extract the proof-local canonical stdlib registry into the approved
production RuntimeMachine/package boundary.
