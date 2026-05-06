# Compiler Pipeline Profile Bridge v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `compiler-pipeline-profile-bridge-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`, `[Package Agent]`

---

## Purpose

Unify bridge naming for parser, classifier, typechecker, `SemanticIR`, compiler
OOF, and runtime load proof profiles.

This note supersedes the narrower naming direction in
`semanticir-verification-report-bridge-v0.md` for future package adoption:
use one package-facing family under `compiler_pipeline_profiles`.

No package edits, runtime behavior, compiler implementation, or
`RuntimeMachine` execution are authorized by this bridge.

---

## Source Signals

Approved signals:

- `PROP-018-source-to-semanticir-minimal-pipeline-v0.md`
- `PROP-019-canonical-semanticir-envelope-v0.md`
- `PROP-020-classifier-pass-v0-formalization.md`
- `tracks/source-to-semanticir-canonical-envelope-v0.md`
- `tracks/polymorphic-add-parser-acceptance-v0.md`
- `tracks/polymorphic-add-classifier-proof-v0.md`
- `tracks/polymorphic-add-semanticir-emission-proof-v0.md`
- `tracks/polymorphic-add-runtime-loader-normalization-v0.md`
- `bridge/semanticir-verification-report-bridge-v0.md`

Current pipeline:

```text
source
  -> ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIR / semantic_ir_program
  -> CompiledProgram / .igapp
  -> RuntimeMachine.load(...)
```

---

## Naming Decision

[D] Use one package-facing custom carrier section:

```text
VerificationReport#metadata[:custom_sections][:compiler_pipeline_profiles]
```

[D] Use exactly this v0 profile family:

```text
parsed_program_profile_v0
classified_program_profile_v0
typed_program_profile_v0
semanticir_program_profile_v0
compiler_oof_diagnostic_profile_v0
runtime_load_receipt_profile_v0
```

[D] Retire these earlier bridge names for new package work:

```text
semanticir_artifact_profile_v0       -> semanticir_program_profile_v0
classifier_diagnostic_profile_v0     -> classified_program_profile_v0
typecheck_diagnostic_profile_v0      -> typed_program_profile_v0
oof_finding_profile_v0               -> compiler_oof_diagnostic_profile_v0
runtime_proof_receipt_profile_v0     -> runtime_load_receipt_profile_v0
semanticir_verification_profiles     -> compiler_pipeline_profiles
```

The old names may remain historical bridge notes, but Package Agent should not
start new package tests from them.

---

## Level Boundaries

| Profile | Level | Boundary |
|---------|-------|----------|
| `parsed_program_profile_v0` | source-level | Parser output only; no resolution, typechecking, or lowering |
| `classified_program_profile_v0` | semantic-level | Classifier pass result: fragment classes, symbol/import decisions, classifier diagnostics |
| `typed_program_profile_v0` | semantic-level | Typechecker result: concrete typed contracts, resolved impls/operators, no type variables for accepted specializations |
| `semanticir_program_profile_v0` | semantic-level | Canonical SemanticIR program/artifact hash and lowering invariants |
| `compiler_oof_diagnostic_profile_v0` | source/semantic diagnostic | Rejection evidence from parser/classifier/typechecker/lowering; blocks later stage emission when fatal |
| `runtime_load_receipt_profile_v0` | runtime-level | Load receipt/proof that a compiled artifact was accepted or blocked by `RuntimeMachine.load(...)` |

[D] Evaluation receipts are out of scope for this naming slice. The v0 runtime
profile is load-only.

---

## Carrier Manifest Shape

Recommended `VerificationReport` metadata shape:

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

Expected `carrier_manifest` section:

```json
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
```

---

## JSON Examples

### ParsedProgramProfile

```json
{
  "profile": "parsed_program_profile_v0",
  "profile_kind": "ParsedProgramProfile",
  "level": "source",
  "parsed_program_ref": "parsed_program/polymorphic_add@v0",
  "source_program_ref": "source/polymorphic_add.ig",
  "source_hash": "sha256:<source-bytes>",
  "grammar_version": "polymorphic-v0",
  "parser_status": "accepted",
  "syntax_nodes": ["trait", "impl", "contract_shape", "contract", "input", "compute", "output"],
  "parse_error_count": 0,
  "next_profile_ref": "classified_program/polymorphic_add@v0",
  "evidence_refs": [
    "proof/polymorphic_add_parser_acceptance",
    "fixture/polymorphic_add.parsed_program.expected.json"
  ],
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
  "classified_program_ref": "classified_program/polymorphic_add@v0",
  "parsed_program_ref": "parsed_program/polymorphic_add@v0",
  "classifier_status": "accepted_with_negative",
  "fragment_classes": ["core"],
  "trait_env_refs": ["trait_env/polymorphic_add/Additive@v0"],
  "impl_env_refs": [
    "impl_env/polymorphic_add/Additive[Integer]@v0",
    "impl_env/polymorphic_add/Additive[Float]@v0"
  ],
  "shape_env_refs": ["shape_env/polymorphic_add/AddShape@v0"],
  "classifier_diagnostics": [
    {
      "code": "classifier.envs",
      "severity": "info",
      "decision": "accepted"
    }
  ],
  "next_profile_ref": "typed_program/polymorphic_add@v0",
  "evidence_refs": ["proof/polymorphic_add_classifier"],
  "report_only": true,
  "runtime_enforced": false
}
```

### TypedProgramProfile

```json
{
  "profile": "typed_program_profile_v0",
  "profile_kind": "TypedProgramProfile",
  "level": "semantic",
  "typed_program_ref": "typed_program/polymorphic_add@v0",
  "classified_program_ref": "classified_program/polymorphic_add@v0",
  "typechecker_status": "accepted_with_negative",
  "typed_contract_refs": ["Add[Integer]", "Add[Float]"],
  "rejected_specialization_refs": ["Add[String]"],
  "typecheck_results": [
    {
      "contract_ref": "Add[Integer]",
      "input_types": { "left": "Integer", "right": "Integer" },
      "output_types": { "sum": "Integer" },
      "resolved_impl": "Additive[Integer]",
      "resolved_operator_ref": "stdlib.numeric.add",
      "decision": "accepted"
    },
    {
      "contract_ref": "Add[Float]",
      "input_types": { "left": "Float", "right": "Float" },
      "output_types": { "sum": "Float" },
      "resolved_impl": "Additive[Float]",
      "resolved_operator_ref": "stdlib.numeric.add",
      "decision": "accepted"
    }
  ],
  "invariants": {
    "type_variables_remaining": 0,
    "unresolved_impls": 0
  },
  "next_profile_ref": "semantic_ir/polymorphic_add@v0",
  "evidence_refs": ["proof/polymorphic_add_classifier"],
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
  "semanticir_program_ref": "semantic_ir/polymorphic_add@v0",
  "typed_program_ref": "typed_program/polymorphic_add@v0",
  "artifact_hash": "sha256:<canonical-semanticir-envelope>",
  "semanticir_status": "emitted",
  "contract_refs": [
    "Lang.Examples.PolymorphicAdd.Add[Integer]",
    "Lang.Examples.PolymorphicAdd.Add[Float]"
  ],
  "invariant_summary": {
    "unresolved_symbols": 0,
    "unresolved_type_variables": 0,
    "unresolved_trait_calls": 0,
    "unresolved_overloads": 0,
    "generic_contractir_count": 0,
    "oof_findings": 0
  },
  "resolved_operator_refs": ["stdlib.numeric.add"],
  "compiled_program_ref": "igapp/polymorphic_add@v0",
  "next_profile_ref": "runtime_load/polymorphic_add@v0",
  "evidence_refs": [
    "proof/polymorphic_add_semanticir_emission",
    "fixture/polymorphic_add.semantic_ir.expected.json"
  ],
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
  "diagnostic_ref": "diagnostic/compiler/polymorphic_add/Add[String]/OOF-TY1",
  "pass": "typecheck",
  "oof_code": "OOF-TY1",
  "severity": "error",
  "decision": "rejected_before_semanticir",
  "subject_ref": "Add[String]",
  "reason": "missing ImplEnv[Additive[String]]",
  "parsed_program_ref": "parsed_program/polymorphic_add@v0",
  "classified_program_ref": "classified_program/polymorphic_add@v0",
  "typed_program_ref": "typed_program/polymorphic_add@v0",
  "semanticir_emitted": false,
  "runtime_load_required": false,
  "evidence_refs": [
    "proof/polymorphic_add_classifier",
    "proof/polymorphic_add_semanticir_emission"
  ],
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
  "receipt_ref": "runtime_load/polymorphic_add@v0",
  "runtime_ref": "redacted:runtime/synthetic-fixture",
  "compiled_program_ref": "igapp/polymorphic_add@v0",
  "semanticir_program_ref": "semantic_ir/polymorphic_add@v0",
  "load_status": "loaded",
  "loaded_contract_refs": [
    "Lang.Examples.PolymorphicAdd.Add[Integer]",
    "Lang.Examples.PolymorphicAdd.Add[Float]"
  ],
  "blocked_contract_refs": [
    {
      "contract_ref": "Lang.Examples.PolymorphicAdd.Add",
      "decision": "blocked",
      "reason": "generic template is metadata-only"
    },
    {
      "contract_ref": "Lang.Examples.PolymorphicAdd.Add[String]",
      "decision": "blocked",
      "reason": "contract absent after OOF-TY1"
    }
  ],
  "migration_descriptor_refs": [],
  "schema_check_ref": "compatibility_report/polymorphic_add/schema-trusted@v0",
  "evidence_refs": ["proof/polymorphic_add_runtime_loader_normalization"],
  "report_only": true,
  "runtime_enforced": false,
  "execution_authorized": false
}
```

---

## Adoption Checklist

Package Agent may proceed only after Architect approval.

Checklist for a metadata-only `igniter-contracts` package slice:

- Use `metadata[:custom_sections][:compiler_pipeline_profiles]`.
- Require explicit `metadata[:redaction_policy]`.
- Preserve `metadata[:semantics][:report_only] == true`.
- Preserve `metadata[:semantics][:runtime_enforced] == false`.
- Assert `carrier_manifest.sections` includes `section_name:
  :compiler_pipeline_profiles`.
- Assert the section has `custom: true`, `raw_ref_export: false`, and the six
  profile names listed in this document.
- Assert all entries are hashes and keep opaque payload semantics.
- Reject `raw_ref`, `raw_source_ref`, and string values with `raw:` prefix via
  existing package raw-ref policy.
- Keep `VerificationReport#ok?` unchanged by profile metadata.
- Do not add public profile classes in v0 unless Architect explicitly requests
  them.
- Do not add compiler, parser, typechecker, `SemanticIR`, RuntimeMachine,
  evaluation, Ledger, or readiness behavior.
- Do not recompute `artifact_hash` in package v0; carry it as evidence
  metadata only.

---

## Non-Authorization

[X] No package edits in this bridge slice.

[X] No package runtime behavior, compiler behavior, parser behavior, or
typechecker behavior.

[X] No `RuntimeMachine.load(...)` invoked by `VerificationReport`.

[X] No runtime evaluation receipts in this v0 family; load receipt only.

[X] No OOF enforcement inside package metadata carrier.

[X] No Ledger integration or Ledger-as-core.

---

## Architect Decision Required

[Q] Should Package Agent update existing narrower
`semanticir_verification_profiles` specs to `compiler_pipeline_profiles`, or
keep the older section as deprecated compatibility coverage for one cycle?

[Next] Package Agent may proceed only after explicit Architect approval, and
only on metadata carrier docs/specs for `VerificationReport`.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/compiler-pipeline-profile-bridge-v0
Status: done
Neighbors: Compiler/Grammar Expert | Research Agent | Bridge Agent | Package Agent

[D] Decisions:
- Unified package-facing compiler pipeline naming under
  custom_sections.compiler_pipeline_profiles.
- Defined six v0 profiles: parsed_program, classified_program, typed_program,
  semanticir_program, compiler_oof_diagnostic, and runtime_load_receipt.
- Clarified source-level, semantic-level, diagnostic, and runtime-level
  boundaries.
- Marked earlier semanticir_verification_profiles naming as superseded for new
  package work.

[R] Recommendations:
- Package Agent should adopt compiler_pipeline_profiles as the first stable
  custom section name after Architect approval.
- Keep all profiles opaque metadata in v0; do not add public classes unless
  requested.
- Do not recompute SemanticIR artifact hashes or enforce OOF in package v0.

[S] Signals:
- Existing proof tracks already provide the stage evidence needed for this
  profile family.
- The package carrier_manifest custom-section behavior matches the naming
  unification target.

[T] Tests / Proofs:
- Not run; docs-only bridge slice.
- Read-only inspected source-to-SemanticIR, polymorphic Add, and
  VerificationReport carrier docs/specs for alignment.

[Files] Changed:
- igniter-lang/docs/bridge/compiler-pipeline-profile-bridge-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should old semanticir_verification_profiles package coverage be migrated or
  kept as deprecated compatibility coverage for one cycle?

[X] Rejected:
- No package edits.
- No package compiler/runtime behavior.
- No RuntimeMachine load from VerificationReport.
- No runtime evaluation receipt profile in v0.
- No OOF enforcement in package metadata carrier.
- No Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed igniter-contracts adoption checklist for
  custom_sections.compiler_pipeline_profiles.
```
