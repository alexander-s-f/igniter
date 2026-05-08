# Track: Ledger TBackend Adapter Descriptor Package Plan v0

Card: S2-R13-C3-P
Role: `[Igniter-Lang Bridge Agent]`
Track: `ledger-tbackend-adapter-descriptor-package-plan-v0`
Status: done
Date: 2026-05-07

Affected neighbor roles: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Current Horizon

- R12 proved a metadata-only `LedgerTBackendAdapterDescriptor` fixture in `igniter-lang`.
- R11 defined Ledger-backed TBackend conformance without package binding.
- Ledger docs say the public package is `igniter-ledger`, while internal paths/namespaces may still carry `Igniter::Store` during the pre-v1 rename window.
- Ledger Open Protocol exposes `metadata_snapshot`, `descriptor_snapshot`, descriptor packets, fact IO vocabulary, replay, compact, and subscribe.
- This slice prepares package work only; no package files are edited here.

---

## Package-Side Target

First package slice should implement descriptor construction only:

```text
Ledger Open Protocol metadata_snapshot + descriptor_snapshot
  -> LedgerTBackendAdapterDescriptor
  -> descriptor_hash + descriptor_registry_hash
  -> diagnostics(requirement)
```

It must not expose operational adapter methods. In particular, no
`read_as_of`, `bihistory_at`, `read`, `write`, `append`, `replay`, `compact`,
`subscribe`, RuntimeMachine binding, or migration behavior.

---

## Likely Package Files / Classes

Package Agent should confirm exact namespace placement against current package
layout before editing. Based on package docs, the preferred public name is
`Igniter::Ledger`, but internal files may still live under `lib/igniter/store/**`
until the deep rename.

Recommended target if public `Igniter::Ledger` files are available:

```text
packages/igniter-ledger/lib/igniter/ledger/tbackend_adapter_descriptor.rb
packages/igniter-ledger/spec/igniter/ledger/tbackend_adapter_descriptor_spec.rb
```

Fallback target if the package still centralizes implementation under
`Igniter::Store`:

```text
packages/igniter-ledger/lib/igniter/store/tbackend_adapter_descriptor.rb
packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
```

Class/module shape:

```ruby
Igniter::Ledger::TBackendAdapterDescriptor
# or internal:
Igniter::Store::TBackendAdapterDescriptor
```

Minimum public methods:

```ruby
.build(metadata_snapshot:, descriptor_snapshot:, schema_fingerprint:, adapter_ref: nil, ledger_protocol_ops: nil)
# -> descriptor value object or frozen Hash

#descriptor_hash
#descriptor_registry_hash
#to_h
#diagnostics(requirement)
```

Do not add methods that perform package operations. This descriptor reports
capabilities; it is not the adapter.

---

## Descriptor Schema

Package implementation should match the R12 proof shape:

| Field | Requirement |
|---|---|
| `kind` | `"ledger_tbackend_adapter_descriptor"` |
| `adapter_kind` | `"ledger_open_protocol"` |
| `adapter_ref` | caller-supplied or deterministic package default |
| `adapter_version` | package descriptor version, not Ledger package version |
| `contract_version` | `"tbackend.v0"` |
| `protocol` | `"igniter_store"` while protocol token remains pre-v1 |
| `protocol_schema_version` | from snapshot `schema_version` |
| `ledger_protocol_ops` | declared protocol ops considered by the descriptor |
| `supported_tbackend_ops` | derived six-op subset |
| `hook_methods` | metadata claim only: `read_as_of`, `bihistory_at` when derivable |
| `capabilities` | `history_read`, `bihistory_read` when derivable |
| `history_axes` | `valid_time`, and `transaction_time` only when history/BiHistory support is derivable |
| `cursor_policy` | forward timestamp cursor, truncation flag, tie-breaker requirement |
| `schema_fingerprint` | required caller/compiler input |
| `descriptor_registry_hash` | canonical hash of metadata + descriptor snapshots |
| `evidence_mode` | `"receipt_required"` |
| `non_authorization` | all runtime/Ledger operation booleans false |
| `descriptor_hash` | canonical hash of descriptor payload excluding itself |

Mapping rules:

| Ledger source | Descriptor output |
|---|---|
| `read`, `query`, `fact_ref` protocol op | TBackend `read` |
| `write`, `write_fact`, `append` protocol op | TBackend `append` |
| `replay`, `sync_hub_profile` protocol op | TBackend `replay` |
| `metadata_snapshot`, `descriptor_snapshot`, `sync_hub_profile` protocol op | TBackend `snapshot` |
| `compact` protocol op | TBackend `compact` |
| `subscribe` protocol op | TBackend `subscribe` |
| store descriptors with as-of capability | `read_as_of`, `history_read`, `valid_time` |
| history descriptors present | `bihistory_at`, `bihistory_read`, `transaction_time` |

---

## Package Tests

Write focused package specs only. Suggested examples:

| Test | Expected |
|---|---|
| builds descriptor from metadata + descriptor snapshots | `kind`, `adapter_kind`, `contract_version`, protocol version populated |
| computes stable `descriptor_hash` | identical canonical inputs produce same hash |
| ignores key ordering in snapshots | reordered Hash keys do not change hash |
| computes `descriptor_registry_hash` | hash changes when descriptor snapshot content changes |
| maps protocol ops to supported TBackend ops | six-op subset matches docs mapping |
| reports `history_read` from read/as-of metadata | capability and `valid_time` axis present |
| reports `bihistory_read` only with history descriptors | missing history removes `bihistory_at`, `bihistory_read`, `transaction_time` |
| diagnoses missing ops | requirement for absent op returns blocked diagnostic |
| diagnoses missing hook method/capability/axis | missing history case blocks BiHistory requirement |
| diagnoses schema mismatch | `schema_fingerprint_match: false`, `status: blocked` |
| exposes non-authorization flags | runtime binding and Ledger operations are false |
| does not expose runtime methods | `respond_to?(:read_as_of)`, `:bihistory_at`, `:read`, `:write`, `:replay` are false unless deliberately omitted by value-object design |
| reports cursor policy | forward timestamp cursor and tie-breaker requirement present |
| handles optional unknown snapshot keys | optional extension keys do not crash descriptor construction |

Suggested command:

```bash
bundle exec rspec packages/igniter-ledger/spec/igniter/ledger/tbackend_adapter_descriptor_spec.rb
```

If the package uses the internal `Igniter::Store` spec path, adapt only the path:

```bash
bundle exec rspec packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
```

---

## Acceptance Criteria

- Descriptor can be constructed from Open Protocol-shaped `metadata_snapshot`
  and `descriptor_snapshot` hashes.
- Descriptor payload includes all required fields from this plan.
- Hashes are canonical and stable under key reordering.
- Diagnostics report missing ops, hook methods, capabilities, axes, and schema
  mismatch.
- Missing history descriptors block BiHistory claims.
- Descriptor does not call Ledger, create facts, read facts, replay facts,
  subscribe, compact, or bind RuntimeMachine.
- Tests are package-local and pass.
- No production CompatibilityReport integration is added.
- No migration behavior is added.

---

## Package Agent Task Card

```text
Card: package-ledger-tbackend-adapter-descriptor-v0
Agent: [Igniter-Lang Package Agent]
Package: packages/igniter-ledger
Goal:
  Implement metadata-only LedgerTBackendAdapterDescriptor v0.

Read first:
  - igniter-lang/docs/tracks/ledger-tbackend-adapter-descriptor-v0.md
  - igniter-lang/docs/tracks/ledger-tbackend-adapter-descriptor-package-plan-v0.md
  - packages/igniter-ledger/docs/README.md
  - packages/igniter-ledger/docs/progress.md
  - packages/igniter-ledger/docs/open-protocol.md

Scope:
  - Add descriptor value object/builder in the package.
  - Build only from metadata_snapshot / descriptor_snapshot hashes.
  - Compute descriptor_hash and descriptor_registry_hash canonically.
  - Expose diagnostics for requirements.
  - Add package-local specs for construction, hash stability, capabilities,
    missing ops, missing BiHistory, schema mismatch, and non-authorization.

Do not:
  - Add read_as_of / bihistory_at implementations.
  - Add Ledger reads, writes, append, replay, compact, subscribe, or RuntimeMachine binding.
  - Add CompatibilityReport production integration.
  - Add migration behavior or Ledger history rewrite.

Acceptance:
  - Targeted package spec passes.
  - Descriptor remains metadata-only.
  - Public/internal namespace choice is documented in final handoff.
```

---

## Risks

- Namespace drift: docs prefer `Igniter::Ledger`, but internal paths may still
  use `Igniter::Store`. Package Agent must choose the least disruptive current
  convention and document it.
- Overclaiming snapshot semantics: descriptor/metadata snapshots are not
  state-bearing RuntimeMachine checkpoint snapshots.
- Cursor overtrust: timestamp replay cursors need tie-breaking proof before
  exact resume can be trusted.
- Capability leakage: descriptor must report what snapshots justify, not what a
  future adapter might eventually do.
- API ossification: package class should be small and pre-v1; avoid turning the
  descriptor into the production adapter.

---

## Non-Goals

- No package edits in this bridge slice.
- No RuntimeMachine load/evaluate integration.
- No TBackend adapter registry in the package.
- No Ledger operation execution.
- No Durable Model integration.
- No schema migration engine.
- No Ledger-as-core language decision.
- No full production CompatibilityReport wiring.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S2-R13-C3-P
Track: ledger-tbackend-adapter-descriptor-package-plan-v0
Status: done

[D] Decisions:
- First package-side slice should be descriptor-only and diagnostics-only.
- Package Agent should add a value object/builder, not an operational adapter.
- Namespace/file placement must respect the package's pre-v1 Ledger/Store rename state.
- No read/write/replay/runtime binding is authorized.

[S] Signals:
- R12 proof-local fixture provides the exact metadata shape and diagnostics behavior.
- Ledger Open Protocol metadata_snapshot / descriptor_snapshot are sufficient inputs.
- Package docs confirm protocol token and internal namespace carry pre-v1 naming.

[T] Tests / Proofs:
- Docs-only package plan; no tests run.

[R] Risks / Recommendations:
- Keep non_authorization flags in the descriptor payload.
- Treat descriptor snapshots as metadata evidence only, not checkpoint snapshots.
- Require hash stability and missing-capability diagnostics before any later adapter work.

[Next] Package Agent can implement `LedgerTBackendAdapterDescriptor v0` as a
metadata-only package object after Architect Supervisor approval.
```
