# Schema Migration Bridge Profile v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/schema-migration-bridge-profile-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Purpose

Carry replacement `SemanticImage` and migration evidence semantics into the
package bridge profile for `SchemaCompatibilityDiagnostic` v0.

This is a profile note only. It does not edit packages and does not authorize
multi-hop migration or TBackend history rewrite.

## Source Signals

[S] `migration-replacement-image-formalization-v0` settles replacement image
field semantics, link rels, lifecycle, trust rules, and OOF-MR rules.

[S] `migration-replacement-image-checker-v0` stabilizes the executable
single-hop checker rules P-1 through P-10.

[S] `schema-compatibility-diagnostics-igniter-contracts-plan-v0` already
selects `packages/igniter-contracts` and recommends a standalone
`Igniter::Lang::SchemaCompatibilityDiagnostic` plus optional
`VerificationReport` section.

## Bridge Claim

[D] `SchemaCompatibilityDiagnostic` v0 may carry a migration bridge profile as
metadata-only evidence. The package surface may report replacement image
continuity and wrong-fingerprint blocking, but must not execute migrations,
rewrite TBackend history, or select multi-hop migration paths.

[D] The profile is single-hop only in v0:

```text
old SemanticImage
  -> schema_check:migrating
  -> migration intent
  -> audit migration receipt
  -> replacement SemanticImage
  -> trusted CompatibilityReport
```

[D] The bridge profile preserves `migration_chain`, `replaces`, `caused_by`,
`produced_by`, and `produced_in`. It explicitly forbids `supersedes` on
replacement image packets.

## Migration Bridge Profile Payload

Add an optional nested profile to `SchemaCompatibilityDiagnostic`:

```text
migration_profile: {
  migration_receipt_ref,
  replaces_image_id,
  replacement_semantic_image_ref,
  replacement_schema_fingerprint,
  loaded_schema_fingerprint,
  migration_chain,                 # [] for the current single-hop profile
  replacement_image_lifecycle,      # session
  migration_receipt_lifecycle,      # audit
  packet_links: {
    replaces,
    caused_by,
    produced_by,
    produced_in,
    has_supersedes
  },
  post_migration_report_ref,
  post_migration_schema_decision,
  post_migration_compatibility_decision,
  oof_code
}
```

The base diagnostic still owns:

```text
schema_check_outcome
migration_available
migration_ref
compatibility_decision
evidence_links
semantics.report_only: true
semantics.runtime_enforced: false
semantics.migration_execution_authorized: false
semantics.ledger_core: false
```

## P-1 Through P-10 Profile Rules

The package bridge profile should be able to represent these checker results:

| Rule | Package Profile Meaning |
|------|-------------------------|
| P-1 | `migration_receipt_ref` is present and matches evidence links |
| P-2 | `replaces_image_id` points to the old image |
| P-3 | packet links include `replaces -> old image` |
| P-4 | packet links include `caused_by -> migration receipt` |
| P-5 | packet links do not include `supersedes` |
| P-6 | replacement fingerprint matches loaded schema descriptor |
| P-7 | second `CompatibilityReport.schema_check.decision == trusted` |
| P-8 | second `CompatibilityReport.overall/resume_status == trusted` |
| P-9 | single-hop `migration_chain == []` |
| P-10 | forged wrong-fingerprint replacement image is blocked as `OOF-MR3` |

## OOF-MR3 Requirement

[D] Wrong-fingerprint replacement images must be represented as blocked, not
provisional:

```text
schema_check_outcome: blocked
compatibility_decision: blocked
post_migration_schema_decision: blocked
oof_code: OOF-MR3
```

Meaning:

```text
replacement SemanticImage.schema_fingerprint
  != loaded_schema_descriptor.schema_fingerprint
```

This is a migration contract defect, not a normal schema drift. The package
diagnostic must not turn OOF-MR3 into a warning or provisional state.

## Package Touchpoints

Primary target remains:

```text
packages/igniter-contracts/lib/igniter/lang/schema_compatibility_diagnostic.rb
packages/igniter-contracts/lib/igniter/lang/verification_report.rb
packages/igniter-contracts/spec/igniter/lang_schema_compatibility_diagnostic_spec.rb
packages/igniter-contracts/spec/igniter/lang_spec.rb
```

Profile-specific additions for the future package slice:

- `SchemaCompatibilityDiagnostic` accepts optional `migration_profile`.
- `SchemaCompatibilityDiagnostic#to_h` serializes the profile without changing
  decisions.
- `VerificationReport#to_h` includes the serialized diagnostic/profile when
  supplied.
- Specs cover P-1 through P-10 as metadata/profile cases, not runtime
  execution cases.
- README/docs state the profile is evidence reporting only.

Package-local spec cases to add:

- serializes replacement image profile with `migration_chain: []`
- requires `replaces`, `caused_by`, `produced_by`, and `produced_in` refs when
  `migration_profile` is present
- rejects or marks invalid `has_supersedes: true`
- represents OOF-MR3 wrong-fingerprint as blocked with `oof_code: "OOF-MR3"`
- keeps `report_only: true` and `runtime_enforced: false`
- does not call any migration executor or TBackend API

## Recommendation To Package Agent

[R] Package Agent can start `SchemaCompatibilityDiagnostic v0` now, if and
only if the first package slice stays within these bounds:

- implement the standalone diagnostic value object and optional
  `VerificationReport` section from the igniter-contracts plan
- include optional `migration_profile` fields for P-1 through P-10 evidence
- treat P-10 / OOF-MR3 as a blocked diagnostic state
- keep all migration profile behavior report-only
- do not implement migration execution, multi-hop migration, path selection,
  TBackend rewrite, Ledger integration, or application boot/resume enforcement

[R] The package slice does not need to wait for multi-hop migration proof or
TBackend compaction proof, because this profile is single-hop metadata only.

## Explicitly Unauthorized

[X] No package edits in this bridge-profile slice.

[X] No production migration engine.

[X] No general `MigrationDecl` executor.

[X] No multi-hop migration.

[X] No migration path selection.

[X] No TBackend history rewrite or compaction proof.

[X] No Ledger-as-core semantics.

[X] No `supersedes` on replacement image packets.

[X] No treating OOF-MR3 as provisional.

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/schema-migration-bridge-profile-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Carried replacement SemanticImage migration evidence into a single-hop package bridge profile.
- Preserved migration_chain, replaces, caused_by, produced_by, and produced_in.
- Explicitly rejected supersedes on replacement image packets.
- Required OOF-MR3 wrong-fingerprint replacement images to remain blocked.

[R] Recommendations:
- Package Agent can start SchemaCompatibilityDiagnostic v0 now, constrained to report-only metadata/profile behavior.
- Add optional migration_profile fields to the diagnostic shape while keeping migration execution, multi-hop, and TBackend rewrite out of scope.
- Treat P-1 through P-10 as package-local metadata/profile spec cases.

[S] Signals:
- The checker now stabilizes P-1 through P-10, including migration_chain [] and OOF-MR3.
- The profile is ready for igniter-contracts reporting because it does not require runtime migration behavior.

[T] Tests / Proofs:
- Not run. Documentation-only bridge profile.

[Files] Changed:
- igniter-lang/docs/bridge/schema-migration-bridge-profile-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should Package Agent reject invalid migration_profile input with ArgumentError, or serialize an invalid profile with status blocked?
- Should OOF-MR3 use string "OOF-MR3" or symbol :OOF_MR3 in package serialization?

[X] Rejected:
- Package edits in this slice.
- Multi-hop migration, path selection, TBackend rewrite, Ledger-as-core, supersedes links, and provisional OOF-MR3.

[Next] Proposed next slice:
- Package Agent implements SchemaCompatibilityDiagnostic v0 in packages/igniter-contracts with optional migration_profile support.
```
