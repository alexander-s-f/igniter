# Schema Compatibility Diagnostics igniter-contracts Plan v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/schema-compatibility-diagnostics-igniter-contracts-plan-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Purpose

Prepare the Architect-approved implementation plan for
`SchemaCompatibilityDiagnostic` v0 under `packages/igniter-contracts`.

This document is a bridge implementation plan only. It does not edit package
files.

## Source Signals

[S] `schema-compatibility-diagnostics-bridge-v0.md` limits the bridge to
metadata-only schema compatibility diagnostics with required evidence links.

[S] `schema-compatibility-diagnostics-package-touchpoint-map-v0.md` recommends
`packages/igniter-contracts` Lang/reporting as the first package target.

[S] `packages/igniter-contracts` already exposes a report-only Lang foundation:

```text
Igniter::Lang::VerificationReport
Igniter::Lang::MetadataManifest
```

`MetadataManifest` serializes `semantics: { report_only: true,
runtime_enforced: false }`.

## Decision

[D] First implementation should be both:

1. A standalone immutable `SchemaCompatibilityDiagnostic` value object.
2. An optional `VerificationReport` section that carries zero or more serialized
   schema diagnostics.

Why both:

- the standalone class owns validation, normalization, freezing, and `to_h`
  shape
- `VerificationReport` becomes the package report surface without duplicating
  payload rules
- callers can construct diagnostics independently before attaching them to a
  report
- the section remains optional, so existing verification behavior is unchanged

[D] `MetadataManifest` should not own schema compatibility v0. Schema
diagnostics require compatibility report and evidence-link context, while
`MetadataManifest` is currently declaration metadata over operations.

## Exact Package Touch Points

Planned package files:

```text
packages/igniter-contracts/lib/igniter/lang/schema_compatibility_diagnostic.rb
packages/igniter-contracts/lib/igniter/lang/verification_report.rb
packages/igniter-contracts/lib/igniter/lang.rb
packages/igniter-contracts/spec/igniter/lang_schema_compatibility_diagnostic_spec.rb
packages/igniter-contracts/spec/igniter/lang_spec.rb
packages/igniter-contracts/README.md
docs/guide/igniter-lang-foundation.md
```

Optional if the package slice wants smaller spec churn:

```text
packages/igniter-contracts/spec/igniter/lang_spec.rb
```

may cover the `VerificationReport` integration, while the new spec file covers
the standalone class.

## Proposed Modules

```ruby
module Igniter
  module Lang
    class SchemaCompatibilityDiagnostic
    end
  end
end
```

`lib/igniter/lang.rb` should require it before `verification_report.rb`:

```ruby
require_relative "lang/schema_compatibility_diagnostic"
require_relative "lang/verification_report"
```

`VerificationReport` should add:

```ruby
attr_reader :schema_compatibility_diagnostics
```

and accept:

```ruby
schema_compatibility_diagnostics: []
```

It should serialize:

```text
schema_compatibility_diagnostics: diagnostics.map(&:to_h)
```

## Minimal Payload Fields

`SchemaCompatibilityDiagnostic` should require:

```text
diagnostic_id
contract_ref
old_schema_version
new_schema_version
old_schema_fingerprint
new_schema_fingerprint
schema_check_outcome
migration_available
compatibility_decision
evidence_links.compatibility_report_ref
evidence_links.semantic_image_ref
evidence_links.loaded_schema_descriptor_ref
```

Optional fields:

```text
migration_ref
evidence_links.migration_descriptor_ref
evidence_links.migration_intent_ref
evidence_links.migration_receipt_ref
evidence_links.replacement_semantic_image_ref
metadata
```

Fixed semantics:

```text
semantics.report_only: true
semantics.runtime_enforced: false
semantics.migration_execution_authorized: false
semantics.ledger_core: false
```

Allowed decisions:

```text
trusted
provisional
migrating
blocked
```

## Normalization Rules

- Store decision/outcome values as symbols internally.
- Serialize decision/outcome values as symbols if that matches local package
  report style; do not introduce string-only wire semantics in v0.
- Deep-freeze payload, evidence links, metadata, and semantics.
- Normalize evidence link keys to symbols.
- Reject missing required evidence links with `ArgumentError`.
- Reject unknown `schema_check_outcome` or `compatibility_decision`.
- `migration_available: true` requires `migration_ref` or
  `evidence_links.migration_descriptor_ref`.
- `schema_check_outcome: :migrating` does not authorize execution; it only
  reports state.

## VerificationReport Integration

`VerificationReport.from_compilation_report` and `.from_artifact` should keep
their current behavior and default to no schema diagnostics.

The constructor should accept prebuilt diagnostics:

```ruby
VerificationReport.new(
  profile_fingerprint: profile_fingerprint,
  operations: operations,
  findings: findings,
  metadata: metadata,
  schema_compatibility_diagnostics: [diagnostic]
)
```

The report should normalize hash inputs too:

```ruby
SchemaCompatibilityDiagnostic.new(**entry)
```

This keeps tests ergonomic and allows future adapter-generated diagnostics
without requiring callers to instantiate the class first.

## Package-Local Specs

Add `packages/igniter-contracts/spec/igniter/lang_schema_compatibility_diagnostic_spec.rb`:

- builds an immutable diagnostic with required fields
- serializes minimal payload and fixed semantics
- requires `compatibility_report_ref`, `semantic_image_ref`, and
  `loaded_schema_descriptor_ref`
- rejects unknown `schema_check_outcome`
- rejects unknown `compatibility_decision`
- enforces `migration_available` evidence requirement
- serializes optional migration refs without executing anything
- keeps `report_only: true` and `runtime_enforced: false`

Extend `packages/igniter-contracts/spec/igniter/lang_spec.rb`:

- `require "igniter/lang"` loads `SchemaCompatibilityDiagnostic`
- `VerificationReport` defaults to an empty
  `schema_compatibility_diagnostics` array
- `VerificationReport#to_h` includes serialized schema diagnostics when
  supplied
- existing metadata manifest and execution specs remain unchanged

Run after package implementation:

```bash
bundle exec rspec packages/igniter-contracts/spec/igniter/lang_schema_compatibility_diagnostic_spec.rb packages/igniter-contracts/spec/igniter/lang_spec.rb
```

Optional broader package check:

```bash
bundle exec rspec packages/igniter-contracts/spec
```

## Documentation Updates For Package Slice

Update `packages/igniter-contracts/README.md`:

- mention `SchemaCompatibilityDiagnostic` under Igniter Lang Foundation
- state it is report-only and not runtime-enforced
- state it does not execute migrations

Update `docs/guide/igniter-lang-foundation.md`:

- add a short schema compatibility diagnostic example
- state required evidence links
- repeat `report_only: true` and `runtime_enforced: false`

## Explicitly Unauthorized

[X] No package edits in this bridge-plan slice.

[X] No production migration engine.

[X] No general `MigrationDecl` executor.

[X] No TBackend history rewrite.

[X] No Ledger-as-core semantics.

[X] No application boot/resume enforcement.

[X] No full parser -> classifier -> typechecker -> SemanticIR compiler claim.

[X] No package-derived language evidence claim until selected-profile or
equivalent admission is approved.

## Architect Approval Required

[Q] Approve this exact first package slice: standalone
`Igniter::Lang::SchemaCompatibilityDiagnostic` plus optional
`VerificationReport` section?

[Q] Should diagnostics serialize symbols, matching current package report style,
or should the implementation introduce string wire values immediately?

[Q] Should package docs include a synthetic example now, or wait until a
selected-profile fixture can drive the example?

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/schema-compatibility-diagnostics-igniter-contracts-plan-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Recommended both a standalone SchemaCompatibilityDiagnostic value object and an optional VerificationReport section.
- Kept MetadataManifest out of v0 ownership because schema compatibility needs report/evidence context.
- Named exact package files/modules/specs for a future approved package slice.
- Preserved report_only/runtime_enforced false and required evidence links.

[R] Recommendations:
- Implement the standalone class first, then wire VerificationReport to accept and serialize diagnostics.
- Keep from_compilation_report/from_artifact defaults unchanged.
- Add focused lang diagnostic specs plus a small lang_spec integration check.

[S] Signals:
- igniter-contracts already has the right report-only Lang surface.
- A package diagnostic can expose schema compatibility state without app runtime, Ledger, or migration execution behavior.

[T] Tests / Proofs:
- Not run. Documentation-only bridge implementation plan.

[Files] Changed:
- igniter-lang/docs/bridge/schema-compatibility-diagnostics-igniter-contracts-plan-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should serialized decision values remain symbols in v0 or become strings now?
- Should package docs use a synthetic example or wait for selected-profile fixture evidence?

[X] Rejected:
- Package edits in this slice.
- Putting schema compatibility v0 into MetadataManifest only.
- Production migration engine, general MigrationDecl executor, TBackend history rewrite, application enforcement, and Ledger-as-core semantics.

[Next] Proposed next slice:
- Architect-approved package implementation of SchemaCompatibilityDiagnostic v0 in packages/igniter-contracts.
```
