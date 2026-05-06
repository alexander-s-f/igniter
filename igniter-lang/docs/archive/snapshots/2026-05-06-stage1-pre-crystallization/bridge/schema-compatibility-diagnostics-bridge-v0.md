# Schema Compatibility Diagnostics Bridge v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/schema-compatibility-diagnostics-bridge-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Purpose

Prepare the first bridge request from Igniter-Lang into platform/package work:
schema compatibility diagnostics only.

This note does not request compiler integration, production migration behavior,
Ledger-core semantics, or package edits in this slice.

## Source Signals

[S] `current-status.md` fixes schema evolution as part of compatibility.
`CompatibilityReport` includes `schema_check`, and schema migration evidence is
descriptor -> intent -> audit receipt.

[S] `runtime-machine-schema-migration-fixture-v0.md` proves report-side schema
outcomes at proof scale: trusted schema match, provisional schema drift,
blocked resume conditions, and migrating schema drift with `migration_ref` and
`migration_available`.

[S] `PROP-017-schema-evolution-contract-migration-v0.md` defines
`schema_version`, `schema_fingerprint`, `SchemaCheck`, `migration_available`,
`migration_ref`, and `CompatibilityReport.overall`.

[S] `bridge-agent-entry-v0.md` sets metadata-only diagnostics as the low-risk
bridge path before any package integration.

## Bridge Claim

[D] The platform may expose a read-only schema compatibility diagnostic surface
that reports what the language proof already knows:

```text
schema_version
schema_fingerprint
schema_check outcome
migration_available
migration_ref
compatibility decision
evidence links
```

[D] The diagnostic is admissible only when derived from evidence-linked
`CompatibilityReport` and schema descriptor data. It must not infer trust from
raw values or matching hashes alone.

[D] `schema_check:migrating` means "a visible migration path exists and the
report requires migration evidence." It does not mean the platform may execute
a migration or produce a replacement `SemanticImage`.

## Diagnostic Payload v0

The future package-facing shape should be metadata-only:

```text
SchemaCompatibilityDiagnostic = {
  contract_ref,
  old_schema_version,
  new_schema_version,
  old_schema_fingerprint,
  new_schema_fingerprint,
  schema_check_outcome,        # trusted | provisional | migrating | blocked
  migration_available,         # true only when visible migration matches old/new
  migration_ref,               # optional migration descriptor ref
  compatibility_decision,      # CompatibilityReport.overall
  evidence_links: {
    compatibility_report_ref,
    semantic_image_ref,
    loaded_schema_descriptor_ref,
    migration_descriptor_ref?,  # present for migrating
    migration_intent_ref?,      # present only if an intent exists
    migration_receipt_ref?      # present only if an audit receipt exists
  }
}
```

Minimum display/read model:

| Outcome | Diagnostic Meaning | Runtime Right |
|---------|--------------------|---------------|
| `trusted` | schema surface matches or change is non-observable | resume may continue under existing report rules |
| `provisional` | safe drift exists without migration evidence | resume may continue as provisional |
| `migrating` | visible migration path exists | report only; migration execution not authorized here |
| `blocked` | resume cannot proceed under schema rules | report refusal and required fresh boot/migration decision |

## Trust Boundary

[D] CORE remains deterministic and explicit-time. Schema diagnostics over
existing descriptors and reports are metadata reads, not hidden runtime clocks
or ambient package state.

[D] ESCAPE remains capability-gated and receipt/failure-producing. Any future
migration action must enter through declared migration contracts and produce
intent/audit receipt evidence.

[D] OOF includes:

- silent migration or automatic field mapping without a migration declaration
- migration execution without `intent_observation` and audit receipt
- diagnostics that omit evidence links while claiming trusted compatibility
- treating Ledger storage as the language core
- exposing unresolved compiler/type work as runtime schema decisions

## Possible Future Package Touch Points

These are candidate touch points only; this slice does not edit them.

- `lib/igniter/diagnostics/`: report builder/formatter surface for schema
  compatibility summaries.
- `packages/igniter-contracts/`: contract metadata manifest or verification
  report surfaces if schema descriptors move into package vocabulary.
- `packages/igniter-application/`: application load/readiness reports could
  display schema compatibility diagnostics once an approved package slice
  exists.
- `packages/igniter-ledger-client/` or Ledger adapters: possible future
  TBackend diagnostic transport only, not language-core ownership.

## Explicitly Not Authorized

[X] No package edits in this slice.

[X] No production migration engine.

[X] No replacement `SemanticImage` production.

[X] No full parser -> classifier -> typechecker -> SemanticIR compiler claim.

[X] No Ledger-as-core bridge.

[X] No runtime action rights from `schema_check:migrating`; diagnostics may
only report the state and evidence references.

## Architect Approval Required

[Q] May a follow-up package slice add `SchemaCompatibilityDiagnostic` as a
metadata-only diagnostic/report model?

[Q] Should the first package target be core diagnostics, contract metadata, or
application readiness reporting?

[Q] Must package diagnostics require a selected-profile checker fixture before
they are accepted as language evidence?

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/schema-compatibility-diagnostics-bridge-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Prepared the first bridge note for schema compatibility diagnostics only.
- Limited the bridge claim to metadata fields derived from CompatibilityReport and schema descriptor evidence.
- Preserved CORE / ESCAPE / OOF and evidence-link semantics.
- Kept migration execution, replacement SemanticImage production, compiler integration, and Ledger-core semantics out of scope.

[R] Recommendations:
- Ask Architect Supervisor to approve a follow-up package slice before any platform edits.
- Prefer a small diagnostic/report model before touching runtime behavior.
- Require evidence links on every trusted/provisional/migrating/blocking diagnostic.

[S] Signals:
- RuntimeMachine proof already has schema_check outcomes for trusted, provisional, blocked, and migrating cases.
- Migration proof already has descriptor -> intent -> audit receipt evidence.
- Replacement SemanticImage remains open, so production migration behavior should stay blocked.

[T] Tests / Proofs:
- Not run. Documentation-only bridge note.

[Files] Changed:
- igniter-lang/docs/bridge/schema-compatibility-diagnostics-bridge-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Which package surface should own the first metadata-only diagnostic model?
- Should selected-profile checker admission be required before package diagnostics are accepted as language evidence?

[X] Rejected:
- Package edits without Architect approval.
- Production migration engine or replacement SemanticImage production in this bridge.
- Ledger-as-core semantics.

[Next] Proposed next slice:
- Architect-approved package touch-point map for SchemaCompatibilityDiagnostic v0.
```
