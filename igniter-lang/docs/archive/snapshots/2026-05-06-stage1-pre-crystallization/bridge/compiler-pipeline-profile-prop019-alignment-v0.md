# Compiler Pipeline Profile PROP-019 Alignment v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `compiler-pipeline-profile-prop019-alignment-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`, `[Package Agent]`

---

## Purpose

Align the compiler pipeline bridge profile examples with PROP-019 and
PROP-019.1.

This note amends `compiler-pipeline-profile-bridge-v0.md` for package-facing
examples. It keeps `compiler_pipeline_profiles` as the single custom carrier
section and clarifies that older `semanticir_verification_profiles` examples
are historical only.

No package edits are authorized.

---

## Source Signals

Approved source signals:

- `PROP-019-canonical-semanticir-envelope-v0.md`
- `PROP-019.1-semanticir-envelope-errata-v0.md`
- `PROP-020-classifier-pass-v0-formalization.md`
- `PROP-021-typechecker-pass-v0-formalization.md`
- `compiler-pipeline-profile-bridge-v0.md`
- `semanticir-verification-report-bridge-v0.md`

Alignment horizon:

```text
ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> CompilationReport
  -> SemanticIRProgram (only on full success)
  -> RuntimeMachine.load(...)
```

OOF diagnostics live in `CompilationReport` and package-facing
`compiler_oof_diagnostic_profile_v0`, not inside loadable `SemanticIRProgram`.

---

## Alignment Decisions

[D] `semanticir_program_profile_v0` expects a canonical envelope with:

```json
{ "kind": "semantic_ir_program" }
```

Deprecated kinds are not package guidance:

```text
semantic_ir_fixture_program
semantic_ir
```

[D] A loadable `SemanticIRProgram` must not carry top-level `oof_log`,
contract-level `oof_log`, or any contract with `fragment_class: "oof"`.

[D] `typed_program_profile_v0` remains in the package-facing family, but it is
`planned_pending_proof` until a dedicated PROP-021 typechecker proof lands.
Package Agent may manifest the name and carry planned metadata, but must not
claim a trusted typed-program proof without explicit evidence.

[D] Keep exactly one custom carrier section:

```text
metadata[:custom_sections][:compiler_pipeline_profiles]
```

[D] `semanticir_verification_profiles` is historical only. New package work
must not introduce or expand it.

---

## Canonical Carrier Shape

```ruby
metadata: {
  custom_sections: {
    compiler_pipeline_profiles: [
      { profile: "parsed_program_profile_v0" },
      { profile: "classified_program_profile_v0" },
      { profile: "typed_program_profile_v0" },
      { profile: "semanticir_program_profile_v0" },
      { profile: "compiler_oof_diagnostic_profile_v0" },
      { profile: "runtime_load_receipt_profile_v0" }
    ]
  },
  redaction_policy: {
    profile: "compiler_pass_public_metadata_v0",
    raw_ref_export: false,
    hash_source_refs: true,
    redacted_ref_kinds: [
      "source_path",
      "workspace_path",
      "host_path",
      "agent_ref",
      "runtime_ref"
    ]
  },
  semantics: {
    report_only: true,
    runtime_enforced: false,
    execution_authorized: false,
    provider_call_authorized: false,
    real_data_export_authorized: false,
    readiness_enforced: false,
    ledger_core: false
  }
}
```

Expected carrier manifest:

```json
{
  "sections": [
    {
      "section_name": "compiler_pipeline_profiles",
      "count": 6,
      "profile_names": [
        "parsed_program_profile_v0",
        "classified_program_profile_v0",
        "typed_program_profile_v0",
        "semanticir_program_profile_v0",
        "compiler_oof_diagnostic_profile_v0",
        "runtime_load_receipt_profile_v0"
      ],
      "custom": true,
      "report_only": true,
      "runtime_enforced": false,
      "raw_ref_export": false
    }
  ]
}
```

---

## JSON Examples

### ParsedProgramProfile

```json
{
  "profile": "parsed_program_profile_v0",
  "profile_kind": "ParsedProgramProfile",
  "level": "source",
  "parsed_program_ref": "parsed_program/add@v0",
  "source_program_ref": "source/add.ig",
  "source_hash": "sha256:<64-hex>",
  "grammar_version": "0.1.0",
  "parser_status": "accepted",
  "parse_error_count": 0,
  "next_profile_ref": "classified_program/add@v0",
  "evidence_refs": ["proof/source_to_semanticir/parser/add"],
  "report_only": true,
  "runtime_enforced": false
}
```

### ClassifiedProgramProfile

```json
{
  "profile": "classified_program_profile_v0",
  "profile_kind": "ClassifiedProgramProfile",
  "level": "semantic",
  "classified_program_ref": "classified_program/add@v0",
  "parsed_program_ref": "parsed_program/add@v0",
  "classifier_status": "accepted",
  "pass_result": "ok",
  "fragment_classes": ["core"],
  "diagnostics_count": 0,
  "next_profile_ref": "typed_program/add@v0",
  "evidence_refs": ["proof/source_to_semanticir/classifier/add"],
  "report_only": true,
  "runtime_enforced": false
}
```

### TypedProgramProfile Pending

```json
{
  "profile": "typed_program_profile_v0",
  "profile_kind": "TypedProgramProfile",
  "level": "semantic",
  "profile_status": "planned_pending_proof",
  "typed_program_ref": "typed_program/add@v0",
  "classified_program_ref": "classified_program/add@v0",
  "typechecker_status": "pending",
  "formal_source_ref": "PROP-021-typechecker-pass-v0-formalization",
  "proof_ref": null,
  "pending_reason": "Dedicated PROP-021 executable typechecker proof has not landed",
  "must_not_claim_trusted_typecheck": true,
  "next_profile_ref": "semantic_ir/add@v0",
  "evidence_refs": ["proposal/PROP-021-typechecker-pass-v0-formalization"],
  "report_only": true,
  "runtime_enforced": false
}
```

### SemanticIRProgramProfile

```json
{
  "profile": "semanticir_program_profile_v0",
  "profile_kind": "SemanticIRProgramProfile",
  "level": "semantic",
  "semanticir_program_ref": "semanticir/<source_hash_prefix_16>",
  "typed_program_ref": "typed_program/add@v0",
  "compilation_report_ref": "compilation_report/add@v0",
  "artifact_ref": "artifact/semanticir/<source_hash_prefix_16>/0.1.0",
  "artifact_hash": "sha256:<canonical-semanticir-program-json>",
  "semanticir_status": "emitted",
  "semanticir_program": {
    "kind": "semantic_ir_program",
    "format_version": "0.1.0",
    "program_id": "semanticir/<source_hash_prefix_16>",
    "grammar_version": "0.1.0",
    "source_hash": "sha256:<64-hex>",
    "source_path": "source/add.ig",
    "module": null,
    "compilation_report_ref": "compilation_report/add@v0",
    "contracts": [
      {
        "kind": "contract_ir",
        "contract_ref": "contract/Add/sha256:<prefix24>",
        "contract_name": "Add",
        "specialization_of": null,
        "type_args": {},
        "fragment_class": "core",
        "inputs": [
          { "name": "a", "type": { "name": "Integer", "params": [] }, "lifecycle": null },
          { "name": "b", "type": { "name": "Integer", "params": [] }, "lifecycle": null }
        ],
        "outputs": [
          { "name": "sum", "type": { "name": "Integer", "params": [] }, "lifecycle": "session" }
        ],
        "nodes": [
          {
            "kind": "compute",
            "name": "sum",
            "expr": {
              "kind": "call",
              "fn": "stdlib.integer.add",
              "args": [
                { "kind": "ref", "name": "a", "resolved_type": { "name": "Integer", "params": [] } },
                { "kind": "ref", "name": "b", "resolved_type": { "name": "Integer", "params": [] } }
              ],
              "resolved_type": { "name": "Integer", "params": [] }
            },
            "type": { "name": "Integer", "params": [] },
            "deps": ["a", "b"],
            "fragment": "core"
          }
        ],
        "escape_boundaries": []
      }
    ]
  },
  "invariant_summary": {
    "semanticir_kind": "semantic_ir_program",
    "deprecated_kind_used": false,
    "top_level_oof_log_present": false,
    "contract_oof_log_present": false,
    "oof_contract_count": 0,
    "unresolved_type_variables": 0,
    "unresolved_overloads": 0
  },
  "evidence_refs": ["fixture/source_to_semanticir/golden/add.semantic_ir.json"],
  "report_only": true,
  "runtime_enforced": false
}
```

### CompilerOOFDiagnosticProfile

```json
{
  "profile": "compiler_oof_diagnostic_profile_v0",
  "profile_kind": "CompilerOOFDiagnosticProfile",
  "level": "source_or_semantic_diagnostic",
  "diagnostic_ref": "diagnostic/compiler/add/missing-b/OOF-P1",
  "compilation_report_ref": "compilation_report/add-negative@v0",
  "compilation_report": {
    "kind": "compilation_report",
    "format_version": "0.1.0",
    "program_id": "parsed_program/add-negative@v0",
    "grammar_version": "0.1.0",
    "source_hash": "sha256:<64-hex>",
    "source_path": "source/add_negative.ig",
    "pass_result": "oof",
    "stages": {
      "parse": "ok",
      "classify": "oof",
      "typecheck": "skipped",
      "emit": "skipped"
    },
    "diagnostics": [
      {
        "rule": "OOF-P1",
        "severity": "error",
        "message": "Unresolved symbol: missing_b",
        "node": "sum",
        "path": "contracts[0].body[2].expr",
        "line": null
      }
    ],
    "semantic_ir_ref": null
  },
  "semanticir_emitted": false,
  "runtime_load_required": false,
  "evidence_refs": ["fixture/source_to_semanticir/golden/negative_unresolved_symbol.compilation_report.json"],
  "report_only": true,
  "runtime_enforced": false
}
```

### RuntimeLoadReceiptProfile

```json
{
  "profile": "runtime_load_receipt_profile_v0",
  "profile_kind": "RuntimeLoadReceiptProfile",
  "level": "runtime",
  "receipt_ref": "runtime_load/add@v0",
  "runtime_ref": "redacted:runtime/synthetic-fixture",
  "compiled_program_ref": "igapp/add@v0",
  "semanticir_program_ref": "semanticir/<source_hash_prefix_16>",
  "semanticir_kind_checked": "semantic_ir_program",
  "load_status": "loaded",
  "loaded_contract_refs": ["contract/Add/sha256:<prefix24>"],
  "blocked_contract_refs": [],
  "evidence_refs": ["proof/runtime_machine_load/add@v0"],
  "report_only": true,
  "runtime_enforced": false,
  "execution_authorized": false
}
```

---

## Package Agent Checklist

Package Agent may proceed only after Architect approval.

Checklist:

- Keep using `metadata[:custom_sections][:compiler_pipeline_profiles]`.
- Do not create or expand `semanticir_verification_profiles`.
- Treat existing `semanticir_verification_profiles` package coverage, if any,
  as historical/deprecated compatibility only.
- Ensure any `semanticir_program_profile_v0` example uses
  `semanticir_program.kind == "semantic_ir_program"`.
- Ensure `semanticir_program_profile_v0` examples do not include top-level
  `oof_log`, contract-level `oof_log`, or `fragment_class: "oof"` contracts.
- Ensure compiler OOF examples use `compiler_oof_diagnostic_profile_v0` with a
  `compilation_report` payload and `semantic_ir_ref: null`.
- Keep `typed_program_profile_v0` as `planned_pending_proof` until a dedicated
  PROP-021 executable proof exists.
- Keep `runtime_load_receipt_profile_v0` load-only; no evaluate receipts.
- Preserve carrier manifest flags: `custom: true`, `report_only: true`,
  `runtime_enforced: false`, `raw_ref_export: false`.
- Preserve explicit `metadata[:redaction_policy]`.
- Reject raw refs through existing package raw-ref policy.
- Do not add compiler, assembler, runtime, Ledger, readiness, or OOF
  enforcement behavior.

---

## Non-Authorization

[X] No package edits in this bridge slice.

[X] No package compiler/runtime behavior.

[X] No RuntimeMachine load or evaluation invoked by `VerificationReport`.

[X] No OOF enforcement inside package metadata carrier.

[X] No Ledger integration or Ledger-as-core.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/compiler-pipeline-profile-prop019-alignment-v0
Status: done
Neighbors: Compiler/Grammar Expert | Research Agent | Bridge Agent | Package Agent

[D] Decisions:
- Added PROP-019/019.1 alignment guidance for compiler_pipeline_profiles.
- semanticir_program_profile_v0 now explicitly expects kind:
  "semantic_ir_program".
- typed_program_profile_v0 stays in the family but is marked
  planned_pending_proof until the PROP-021 proof lands.
- compiler_oof_diagnostic_profile_v0 carries CompilationReport diagnostics;
  loadable SemanticIRProgram does not carry OOF logs or OOF contracts.
- semanticir_verification_profiles is historical only.

[R] Recommendations:
- Package Agent should use this note as the latest profile-example guidance.
- Existing semanticir_verification_profiles package coverage should be migrated
  or explicitly marked deprecated after Architect review.
- Keep all behavior metadata-only and report-only.

[S] Signals:
- PROP-019.1 cleanly separates accepted SemanticIRProgram from
  CompilationReport diagnostics.
- compiler_pipeline_profiles remains the one carrier section name.

[T] Tests / Proofs:
- Not run; docs-only bridge alignment slice.

[Files] Changed:
- igniter-lang/docs/bridge/compiler-pipeline-profile-prop019-alignment-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should historical semanticir_verification_profiles package coverage be
  migrated immediately or retained as deprecated compatibility coverage for
  one cycle?

[X] Rejected:
- No package edits.
- No package compiler/runtime behavior.
- No RuntimeMachine load from VerificationReport.
- No runtime evaluation receipt profile in this alignment.
- No OOF diagnostics inside loadable SemanticIRProgram.
- No Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed package migration checklist from
  semanticir_verification_profiles to compiler_pipeline_profiles.
```
