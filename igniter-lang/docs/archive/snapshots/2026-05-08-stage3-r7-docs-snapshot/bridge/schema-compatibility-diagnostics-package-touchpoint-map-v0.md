# Schema Compatibility Diagnostics Package Touch-Point Map v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/schema-compatibility-diagnostics-package-touchpoint-map-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Purpose

Prepare an Architect-reviewable package touch-point map for metadata-only
`SchemaCompatibilityDiagnostic` v0.

This map recommends one first package target. It does not authorize package
edits.

## Source Signals

[S] `schema-compatibility-diagnostics-bridge-v0.md` defines a read-only
diagnostic payload over schema versions, schema fingerprints, `schema_check`,
migration availability/ref, compatibility decision, and evidence links.

[S] `runtime-machine-migration-replacement-image-v0.md` proves a toy identity
migration path through:

```text
schema_check:migrating
  -> migration receipt
  -> replacement SemanticImage
  -> second CompatibilityReport: trusted
```

It still rejects general `MigrationDecl` execution, TBackend history rewrite,
and package integration.

[S] `current-status.md` keeps open pressure visible: no full compiler path, no
PROP-016 monomorphization proof, no normalized package-candidate equivalence,
and replacement-image semantics still need formalization.

## Candidate Targets

### 1. Core Diagnostics

Candidate package surface:

```text
packages/igniter-contracts/
  Igniter::Lang::VerificationReport
  Igniter::Lang::MetadataManifest
```

Benefits:

- Lives in the canonical embedded kernel package.
- Already has report-only Lang metadata vocabulary with `runtime_enforced:
  false`.
- Can model `SchemaCompatibilityDiagnostic` as read-only report data without
  granting runtime action rights.
- Avoids app hosting, Ledger transport, and migration execution concerns.

Risks:

- Could be mistaken for compiler enforcement unless every field stays
  explicitly report-only.
- Current `igniter-contracts` Lang surface is additive over the Ruby runtime,
  not the full Igniter-Lang compiler spine.

Required evidence inputs:

- `CompatibilityReport` reference.
- old/new `schema_version`.
- old/new `schema_fingerprint`.
- `schema_check` outcome.
- `compatibility_decision`.
- `SemanticImage` reference.
- loaded schema descriptor reference.
- optional migration descriptor, intent, receipt, and replacement image refs.

Should it be first:

[D] Yes. It is the narrowest target that matches metadata-only diagnostics and
keeps the diagnostic close to contract metadata instead of host runtime or
persistence behavior.

### 2. Contract Metadata

Candidate package surface:

```text
packages/igniter-contracts/
  Igniter::Lang::MetadataManifest
```

Benefits:

- Schema version/fingerprint data are naturally contract metadata.
- Existing manifests already communicate declared-but-not-enforced facts.
- Good eventual home for schema descriptor summaries.

Risks:

- Metadata alone does not carry the compatibility decision; it needs report
  context.
- If chosen first by itself, it may split schema descriptors from the evidence
  links that make diagnostics trustworthy.

Required evidence inputs:

- contract ref.
- schema descriptor ref.
- `schema_version`.
- `schema_fingerprint`.
- descriptor provenance.

Should it be first:

[R] No as a standalone first target. It should be part of the core diagnostics
slice, not the first independent package surface.

### 3. Application Readiness

Candidate package surface:

```text
packages/igniter-application/
  ApplicationLoadReport
  BootReport
  readiness/report objects
```

Benefits:

- Application reports are user-visible during load/boot/readiness.
- Good eventual display surface for blocked/provisional/migrating schema
  states.
- Can help app hosts explain why resume or activation should pause.

Risks:

- Too close to runtime action decisions for the first bridge.
- Could imply app boot/resume enforcement before the language compiler and
  migration semantics are settled.
- Needs a stable lower-level diagnostic model first.

Required evidence inputs:

- a completed `SchemaCompatibilityDiagnostic`.
- app/load subject ref.
- runtime/load context ref.
- compatibility decision and evidence links from the core diagnostic.

Should it be first:

[R] No. It should consume the diagnostic after `igniter-contracts` has a
metadata-only report model.

### 4. Ledger / TBackend Diagnostics

Candidate package surface:

```text
packages/igniter-ledger-client/
packages/igniter-ledger/
future TBackend adapter diagnostics
```

Benefits:

- Future TBackend adapters need to expose evidence availability, replay cursor,
  schema version, and receipt refs.
- Ledger client docs already separate protocol boundary from engine internals.
- Useful later for durable observation lookup and migration receipt transport.

Risks:

- Highest risk of implying Ledger is the language core.
- Pulls the bridge toward persistence and replay before normalized
  package-candidate equivalence is defined.
- Can blur diagnostics with storage authority.

Required evidence inputs:

- observation packet refs.
- schema version/fingerprint refs attached to stored observations.
- replay cursor / TBackend descriptor refs.
- migration receipt refs when present.
- compatibility report ref from the language/runtime layer.

Should it be first:

[R] No. Ledger/TBackend diagnostics should wait until
`SchemaCompatibilityDiagnostic` exists as a package-neutral report model and
adapter admission rules are approved.

## Recommended First Target

[D] Recommend exactly one first target:

```text
packages/igniter-contracts/
  Igniter::Lang::VerificationReport
  Igniter::Lang::MetadataManifest
```

The first approved package slice should add a metadata-only
`SchemaCompatibilityDiagnostic` report model under the `igniter-contracts`
Lang/reporting surface.

Reason:

`igniter-contracts` is already the canonical embedded kernel package and its
Lang metadata reports are explicitly report-only. This gives the Architect the
smallest package change that can carry schema compatibility evidence without
touching app boot, persistence, migration execution, or Ledger internals.

## Minimal Payload v0

```text
SchemaCompatibilityDiagnostic = {
  diagnostic_id,
  contract_ref,
  old_schema_version,
  new_schema_version,
  old_schema_fingerprint,
  new_schema_fingerprint,
  schema_check_outcome,       # trusted | provisional | migrating | blocked
  migration_available,
  migration_ref,
  compatibility_decision,     # trusted | provisional | migrating | blocked
  evidence_links: {
    compatibility_report_ref,
    semantic_image_ref,
    loaded_schema_descriptor_ref,
    migration_descriptor_ref?,
    migration_intent_ref?,
    migration_receipt_ref?,
    replacement_semantic_image_ref?
  },
  semantics: {
    report_only: true,
    runtime_enforced: false,
    migration_execution_authorized: false,
    ledger_core: false
  }
}
```

## Acceptance Criteria For First Package Slice

- Adds a read-only diagnostic/report object or manifest section only.
- Serializes all minimal payload fields.
- Marks semantics as `report_only: true` and `runtime_enforced: false`.
- Requires `compatibility_report_ref`, `semantic_image_ref`, and
  `loaded_schema_descriptor_ref`.
- Allows migration refs only as evidence refs; does not execute migrations.
- Treats `schema_check:migrating` as non-final until replacement image evidence
  exists.
- Does not add dependencies on `igniter-application`, `igniter-ledger`, or
  `igniter-ledger-client`.
- Includes package-local docs/specs only after Architect approval.

## Explicitly Unauthorized

[X] No package edits in this bridge map slice.

[X] No production migration engine.

[X] No general `MigrationDecl` executor.

[X] No TBackend history rewrite.

[X] No Ledger-as-core semantics.

[X] No application boot/resume enforcement.

[X] No full parser -> classifier -> typechecker -> SemanticIR compiler claim.

[X] No claim that package-derived diagnostics are language evidence until
selected-profile or equivalent admission is approved.

## Architect Decision Required

[Q] Approve `packages/igniter-contracts` Lang/reporting as the first package
target for `SchemaCompatibilityDiagnostic` v0?

[Q] Should the approved package slice add a standalone diagnostic class, a
`VerificationReport` section, or both?

[Q] Should selected-profile checker admission be required before the package
diagnostic can be treated as language evidence?

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/schema-compatibility-diagnostics-package-touchpoint-map-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Mapped four possible package targets: core diagnostics, contract metadata, application readiness, and Ledger/TBackend diagnostics.
- Recommended exactly one first target: packages/igniter-contracts Lang/reporting surface.
- Kept the payload metadata-only and report-only.
- Preserved evidence-link semantics and rejected migration execution, app enforcement, and Ledger-as-core.

[R] Recommendations:
- First package slice should add SchemaCompatibilityDiagnostic v0 under igniter-contracts as a read-only report model or VerificationReport section.
- Application readiness and Ledger/TBackend diagnostics should consume this later, not own the first bridge.
- Require selected-profile or equivalent admission before package-derived diagnostics count as language evidence.

[S] Signals:
- Replacement image proof exists for a toy identity migration, but formal replacement-image semantics and package equivalence remain open.
- igniter-contracts already has report-only Lang metadata surfaces, making it the least risky first package target.

[T] Tests / Proofs:
- Not run. Documentation-only bridge map.

[Files] Changed:
- igniter-lang/docs/bridge/schema-compatibility-diagnostics-package-touchpoint-map-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should the first package slice add a standalone diagnostic class, a VerificationReport section, or both?
- Should selected-profile checker admission be mandatory before language-evidence claims?

[X] Rejected:
- Package edits in this slice.
- Production migration engine, general MigrationDecl executor, TBackend history rewrite, application boot enforcement, and Ledger-as-core semantics.

[Next] Proposed next slice:
- Architect-approved igniter-contracts implementation plan for SchemaCompatibilityDiagnostic v0.
```
