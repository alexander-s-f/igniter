# SemanticIR VerificationReport Bridge v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `semanticir-verification-report-bridge-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`, `[Package Agent]`

---

## Purpose

Define how compiled `SemanticIR` proof results should flow into package-level
`Igniter::Lang::VerificationReport` metadata.

This bridge is report-only. It does not add compiler behavior, package runtime
behavior, `RuntimeMachine` execution, Ledger integration, or enforcement.

---

## Source Signals

Approved source signals:

- `current-status.md`: `SemanticIR` is the stable compiler boundary.
- `tracks/polymorphic-add-classifier-proof-v0.md`: classifier/type proof
  accepts `Add[Integer]` and `Add[Float]`; rejects `Add[String]` as `OOF-TY1`
  before `SemanticIR`.
- `tracks/polymorphic-add-semanticir-emission-proof-v0.md`: emits
  monomorphic `ContractIR` for `Add[Integer]` and `Add[Float]`; proves no type
  variables, unresolved trait calls, generic `ContractIR`, or surface `add`
  operator survive.
- `tracks/polymorphic-add-runtime-loader-normalization-v0.md`: proves
  `polymorphic_add.igapp` loads and evaluates monomorphic contracts while
  rejecting generic `Add` and absent `Add[String]`.
- `tracks/runtime-machine-proof-packet-fixtures-v0.md`: runtime proof evidence
  is structural JSON, not PASS-text scraping.
- `packages/igniter-contracts`: `VerificationReport` already exposes
  `metadata_manifest` and `carrier_manifest` with report-only semantics.

Current proof chain:

```text
ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIR
  -> .igapp / CompiledProgram
  -> RuntimeMachine.load(...)
  -> runtime receipts / failures
  -> VerificationReport metadata
```

---

## Bridge Claim

[D] `VerificationReport` may carry compiled `SemanticIR` proof results as
opaque metadata profiles when all entries are evidence-linked, content-addressed
where applicable, redacted, and marked report-only.

[D] `metadata_manifest` remains the operation-declaration manifest owned by
current package operations. It should not become the owner of `SemanticIR`
compiler proof payloads.

[D] `carrier_manifest` is the right package surface for these proof profiles:
it records section names, profile names, counts, and report-only /
runtime-enforced / raw-ref semantics without changing execution.

---

## VerificationReport Carrier Shape

Recommended first package carrier, after Architect approval:

```ruby
metadata: {
  custom_sections: {
    semanticir_verification_profiles: [
      {
        profile: "semanticir_artifact_profile_v0",
        profile_kind: "SemanticIRArtifactProfile",
        payload: { "...": "..." }
      }
    ]
  },
  redaction_policy: {
    profile: "compiler_proof_public_metadata_v0",
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

Expected `carrier_manifest` shape:

```json
{
  "sections": [
    {
      "section_name": "semanticir_verification_profiles",
      "count": 5,
      "profile_names": [
        "semanticir_artifact_profile_v0",
        "classifier_diagnostic_profile_v0",
        "typecheck_diagnostic_profile_v0",
        "oof_finding_profile_v0",
        "runtime_proof_receipt_profile_v0"
      ],
      "custom": true,
      "report_only": true,
      "runtime_enforced": false,
      "raw_ref_export": false
    }
  ]
}
```

[R] Use a custom section first. Do not add
`MetadataCarrierManifest::KNOWN_SECTIONS` entries until the Architect approves
a stable package naming slice.

---

## JSON Profile Examples

### SemanticIRArtifactProfile

```json
{
  "profile": "semanticir_artifact_profile_v0",
  "profile_kind": "SemanticIRArtifactProfile",
  "artifact_ref": "semantic_ir/polymorphic_add@v0",
  "artifact_hash": "sha256:<canonical-semantic-ir-json>",
  "source_program_ref": "source/polymorphic_add.ig",
  "typed_program_ref": "typed_program/polymorphic_add/classifier-proof@v0",
  "compiled_program_ref": "igapp/polymorphic_add@v0",
  "contract_refs": [
    "Lang.Examples.PolymorphicAdd.Add[Integer]",
    "Lang.Examples.PolymorphicAdd.Add[Float]"
  ],
  "semanticir_invariants": {
    "no_type_variables": true,
    "no_unresolved_overloads": true,
    "no_unresolved_trait_calls": true,
    "no_generic_contractir": true,
    "resolved_operator_refs": ["stdlib.numeric.add"]
  },
  "evidence_refs": [
    "proof/polymorphic_add_semanticir_emission",
    "fixture/polymorphic_add.semantic_ir.expected.json"
  ],
  "observed_at": "2026-05-06T00:00:00Z",
  "report_only": true,
  "runtime_enforced": false
}
```

### ClassifierDiagnosticProfile

```json
{
  "profile": "classifier_diagnostic_profile_v0",
  "profile_kind": "ClassifierDiagnosticProfile",
  "diagnostic_ref": "diagnostic/classifier/polymorphic_add@v0",
  "stage": "classifier",
  "status": "passed_with_negative",
  "accepted_contract_refs": [
    "Add[Integer]",
    "Add[Float]"
  ],
  "rejected_contract_refs": [
    "Add[String]"
  ],
  "environment_refs": {
    "trait_env_ref": "trait_env/polymorphic_add/Additive@v0",
    "impl_env_refs": [
      "impl_env/polymorphic_add/Additive[Integer]@v0",
      "impl_env/polymorphic_add/Additive[Float]@v0"
    ],
    "shape_env_ref": "shape_env/polymorphic_add/AddShape@v0"
  },
  "diagnostics": [
    {
      "code": "classifier.envs",
      "severity": "info",
      "decision": "accepted"
    }
  ],
  "evidence_refs": ["proof/polymorphic_add_classifier"],
  "report_only": true,
  "runtime_enforced": false
}
```

### TypecheckDiagnosticProfile

```json
{
  "profile": "typecheck_diagnostic_profile_v0",
  "profile_kind": "TypecheckDiagnosticProfile",
  "diagnostic_ref": "diagnostic/typecheck/polymorphic_add@v0",
  "stage": "typecheck",
  "status": "accepted",
  "typed_contract_refs": [
    "Add[Integer]",
    "Add[Float]"
  ],
  "typecheck_results": [
    {
      "contract_ref": "Add[Integer]",
      "input_types": {
        "left": "Integer",
        "right": "Integer"
      },
      "output_types": {
        "sum": "Integer"
      },
      "resolved_impl": "Additive[Integer]",
      "decision": "accepted"
    },
    {
      "contract_ref": "Add[Float]",
      "input_types": {
        "left": "Float",
        "right": "Float"
      },
      "output_types": {
        "sum": "Float"
      },
      "resolved_impl": "Additive[Float]",
      "decision": "accepted"
    }
  ],
  "evidence_refs": [
    "proof/polymorphic_add_classifier",
    "typed_program/polymorphic_add/classifier-proof@v0"
  ],
  "report_only": true,
  "runtime_enforced": false
}
```

### OOFFindingProfile

```json
{
  "profile": "oof_finding_profile_v0",
  "profile_kind": "OOFFindingProfile",
  "finding_ref": "oof/polymorphic_add/Add[String]/OOF-TY1",
  "stage": "typecheck",
  "oof_code": "OOF-TY1",
  "severity": "error",
  "decision": "rejected_before_semanticir",
  "subject_ref": "Add[String]",
  "reason": "missing ImplEnv[Additive[String]]",
  "semanticir_emitted": false,
  "runtime_rejection_required": false,
  "evidence_refs": [
    "proof/polymorphic_add_classifier",
    "proof/polymorphic_add_semanticir_emission"
  ],
  "report_only": true,
  "runtime_enforced": false
}
```

### RuntimeProofReceiptProfile

```json
{
  "profile": "runtime_proof_receipt_profile_v0",
  "profile_kind": "RuntimeProofReceiptProfile",
  "receipt_ref": "runtime_proof/polymorphic_add/load-evaluate@v0",
  "runtime_ref": "redacted:runtime/synthetic-fixture",
  "compiled_program_ref": "igapp/polymorphic_add@v0",
  "semanticir_artifact_ref": "semantic_ir/polymorphic_add@v0",
  "runtime_steps": [
    {
      "step": "compiled_program.load_igapp",
      "status": "ok",
      "receipt_ref": "receipt/load_igapp/polymorphic_add"
    },
    {
      "step": "runtime.load_program",
      "status": "loaded",
      "receipt_ref": "receipt/runtime_load/polymorphic_add"
    },
    {
      "step": "runtime.evaluate_add_integer",
      "status": "ok",
      "value_hash": "sha256:<integer-result-observation>",
      "result_summary": { "sum": 3 }
    },
    {
      "step": "runtime.evaluate_add_float",
      "status": "ok",
      "value_hash": "sha256:<float-result-observation>",
      "result_summary": { "sum": 3.75 }
    }
  ],
  "blocked_runtime_attempts": [
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
  "evidence_refs": [
    "proof/polymorphic_add_runtime_loader_normalization",
    "receipt/runtime_load/polymorphic_add"
  ],
  "report_only": true,
  "runtime_enforced": false,
  "execution_authorized": false
}
```

---

## MetadataManifest Alignment

`metadata_manifest` should continue to describe package operation metadata
only:

```json
{
  "descriptors": [],
  "return_types": [],
  "budgets": [],
  "stores": [],
  "invariants": [],
  "semantics": {
    "report_only": true,
    "runtime_enforced": false
  }
}
```

[D] SemanticIR artifact hashes, compiler diagnostics, OOF findings, and runtime
receipts should not be squeezed into `descriptors`, `return_types`, or
`budgets`.

[D] Future package adoption may add operation descriptors that point to
compiled artifacts, but v0 should keep the compiled proof profiles in
`carrier_manifest` metadata.

---

## Diagnostic And Receipt Mapping

Recommended v0 mapping:

| Source Proof Result | VerificationReport Location | Profile |
|---------------------|-----------------------------|---------|
| SemanticIR artifact hash | `metadata[:custom_sections][:semanticir_verification_profiles]` | `semanticir_artifact_profile_v0` |
| classifier diagnostics | same custom section | `classifier_diagnostic_profile_v0` |
| typecheck diagnostics | same custom section | `typecheck_diagnostic_profile_v0` |
| OOF findings | same custom section | `oof_finding_profile_v0` |
| runtime proof receipts | same custom section | `runtime_proof_receipt_profile_v0` |

[R] Existing package `diagnostic_payloads` and `receipt_payloads` may later
mirror selected entries, but the first adoption should not split one proof
bundle across multiple public package APIs.

---

## Package Agent Adoption Notes

First package slice, if approved by Architect:

- add docs/spec coverage only for
  `metadata[:custom_sections][:semanticir_verification_profiles]`;
- require explicit `metadata[:redaction_policy]` when carrier sections are
  present;
- assert `carrier_manifest.sections.first.profile_names` includes all five
  profile names;
- assert report `ok?` is not changed by these metadata profiles;
- assert `metadata[:semantics]` includes `report_only: true` and
  `runtime_enforced: false`;
- reject raw refs via existing raw-ref policy;
- do not add new runtime compiler execution or RuntimeMachine calls;
- do not recompute artifact hashes inside package v0;
- do not promote OOF findings into package enforcement yet.

Potential package test shape:

```ruby
report = Igniter::Lang::VerificationReport.new(
  profile_fingerprint: "profile:polymorphic-add",
  operations: [],
  metadata: {
    redaction_policy: {
      profile: "compiler_proof_public_metadata_v0",
      raw_ref_export: false,
      hash_source_refs: true
    },
    custom_sections: {
      semanticir_verification_profiles: [
        { profile: "semanticir_artifact_profile_v0", artifact_hash: "sha256:..." },
        { profile: "classifier_diagnostic_profile_v0", status: "passed_with_negative" },
        { profile: "typecheck_diagnostic_profile_v0", status: "accepted" },
        { profile: "oof_finding_profile_v0", oof_code: "OOF-TY1" },
        { profile: "runtime_proof_receipt_profile_v0", receipt_ref: "runtime_proof/..." }
      ]
    }
  }
)
```

Expected:

```text
report.ok? == true
report.metadata_manifest.to_h[:semantics] == { report_only: true, runtime_enforced: false }
report.carrier_manifest.sections[0].section_name == :semanticir_verification_profiles
report.carrier_manifest.sections[0].custom == true
report.carrier_manifest.sections[0].raw_ref_export == false
```

---

## Non-Authorization

[X] No package runtime behavior.

[X] No compiler implementation or package `SemanticIR` emission.

[X] No `RuntimeMachine.load` or evaluation invoked by `VerificationReport`.

[X] No artifact hash recomputation requirement in package v0.

[X] No OOF enforcement inside package metadata carrier.

[X] No Ledger integration or Ledger-as-core.

[X] No package edits in this bridge slice.

---

## Architect Decision Required

[Q] Should the first package adoption use one custom section
`semanticir_verification_profiles`, or split into known `diagnostics` and
`receipts` sections after a naming review?

[Next] Package Agent may proceed only after explicit Architect approval, and
only on metadata carrier docs/specs for `VerificationReport`; no compiler,
runtime, or Ledger behavior is authorized.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/semanticir-verification-report-bridge-v0
Status: done
Neighbors: Compiler/Grammar Expert | Research Agent | Bridge Agent | Package Agent

[D] Decisions:
- Mapped SemanticIR artifact hash, classifier diagnostics, typecheck
  diagnostics, OOF findings, and runtime proof receipts into
  VerificationReport report-only metadata profiles.
- Recommended one custom carrier section:
  custom_sections.semanticir_verification_profiles.
- Kept metadata_manifest as package operation declaration metadata.
- Kept carrier_manifest as the proof profile index with report-only semantics.

[R] Recommendations:
- First package adoption should add docs/spec coverage for the custom carrier
  section only.
- Keep existing DiagnosticPayload/ReceiptPayload mirroring as a later option.
- Do not add package compiler/runtime behavior, hash recomputation, OOF
  enforcement, or Ledger integration.

[S] Signals:
- Current SemanticIR proofs already provide accepted contracts, rejected OOF
  cases, invariant checks, artifact fixture refs, and runtime proof receipts.
- VerificationReport carrier semantics already match the bridge need:
  report_only, runtime_enforced false, raw_ref_export false, profile names, and
  counts.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb
- ruby igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb
- ruby igniter-lang/experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb

[Files] Changed:
- igniter-lang/docs/bridge/semanticir-verification-report-bridge-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- One custom section first, or split into known diagnostics/receipts after
  package naming review?

[X] Rejected:
- No package edits.
- No package runtime behavior.
- No compiler implementation.
- No RuntimeMachine execution from VerificationReport.
- No OOF enforcement in the package metadata carrier.
- No Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed igniter-contracts metadata carrier adoption test plan for
  custom_sections.semanticir_verification_profiles.
```
