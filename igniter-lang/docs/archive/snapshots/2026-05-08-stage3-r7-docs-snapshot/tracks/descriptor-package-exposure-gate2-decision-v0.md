# Track: Descriptor Package Exposure Gate 2 Decision v0

Card: S3-R4-C6-G
Role: `[Igniter-Lang Bridge Agent]`
Track: `descriptor-package-exposure-gate2-decision-v0`
Status: decision-request
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Gate State

```text
Gate 1  proof-local CompatibilityReport descriptor consumption     approved + proven
Gate 2  metadata-only package exposure                             decision requested here
Gate 3  production Ledger/runtime binding                          closed
```

This track does not implement package code. It prepares the exact Gate 2
decision request and non-authorization boundary.

---

## Gate 1 Evidence Reviewed

Gate 1 fixture:

```text
igniter-lang/experiments/compatibility_report_descriptor_consumption_fixture/
  compatibility_report_descriptor_consumption_fixture.rb
  compatibility_report_descriptor_consumption_summary.json
```

Verified signals from the JSON summary:

| Case | Decision | Runtime enforced |
|---|---|---|
| `trusted_metadata` | `trusted_metadata` | false |
| `provisional_metadata` | `provisional_metadata` | false |
| missing capability | `blocked` | false |
| missing axis | `blocked` | false |
| missing hook | `blocked` | false |
| missing descriptor hash | `blocked` | false |
| missing registry hash | `blocked` | false |
| bad TEMPORAL cache policy | `blocked` | false |

Top-level non-authorization remains:

```json
{
  "package_exposure": false,
  "runtime_binding": false,
  "ledger_reads": false,
  "ledger_writes": false,
  "ledger_replay": false,
  "live_adapter": false
}
```

Gate 1 proves CompatibilityReport can consume descriptor evidence as
report-only metadata. It does not approve package exposure by itself.

---

## What Gate 2 Means

Gate 2 means exposing the descriptor as a package metadata object only:

```text
Ledger Open Protocol metadata_snapshot + descriptor_snapshot
  -> TBackendAdapterDescriptor value object
  -> descriptor packet hash / registry hash
  -> diagnostics(requirement)
```

Gate 2 does not mean:

```text
descriptor -> live adapter
descriptor -> RuntimeMachine binding
descriptor -> Ledger read/write/replay
descriptor -> production CompatibilityReport enforcement
```

---

## Package Exposure Boundary

Observed package-side candidate surface, read-only:

```text
packages/igniter-ledger/lib/igniter/store/tbackend_adapter_descriptor.rb
packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
packages/igniter-ledger/docs/tracks/ledger-tbackend-adapter-descriptor-package-v0.md
```

Class/module exposure:

```ruby
Igniter::Store::TBackendAdapterDescriptor
Igniter::Ledger::TBackendAdapterDescriptor # alias visibility
```

The package docs state `Igniter::Ledger` is currently a pre-v1 alias for
`Igniter::Store`; therefore the internal `Igniter::Store` placement is
compatible with current package layout.

Constructor shape:

```ruby
.build(
  metadata_snapshot:,
  descriptor_snapshot:,
  schema_fingerprint:,
  adapter_ref: nil,
  ledger_protocol_ops: nil
)
```

Minimum value methods:

```ruby
#descriptor_hash
#descriptor_registry_hash
#ledger_protocol_ops
#supported_tbackend_ops
#hook_methods
#capabilities
#history_axes
#cursor_policy
#diagnostics(requirement = {})
#to_h
```

Explicitly absent operational methods:

```ruby
#read_as_of
#bihistory_at
#read
#write
#append
#replay
#compact
#subscribe
```

---

## Descriptor Packet Shape

Gate 2 approval should be limited to a frozen metadata packet shaped like:

```json
{
  "kind": "ledger_tbackend_adapter_descriptor",
  "adapter_kind": "ledger_open_protocol",
  "adapter_ref": "adapter:ledger-open-protocol/package-descriptor-v0",
  "adapter_version": "0.1.0",
  "contract_version": "tbackend.v0",
  "protocol": "igniter_store",
  "protocol_schema_version": 1,
  "ledger_protocol_ops": ["read", "query", "metadata_snapshot"],
  "supported_tbackend_ops": ["read", "snapshot"],
  "hook_methods": ["read_as_of"],
  "capabilities": ["history_read"],
  "history_axes": ["valid_time"],
  "cursor_policy": {
    "ordered": "forward",
    "cursor_kinds": ["timestamp"],
    "truncation_reported": true,
    "tie_breaker": "timestamp_then_fact_id_required"
  },
  "schema_fingerprint": "sha256:<schema>",
  "descriptor_registry_hash": "sha256:<metadata+descriptor-snapshots>",
  "evidence_mode": "receipt_required",
  "source_snapshots": {
    "metadata_snapshot_present": true,
    "descriptor_snapshot_present": true
  },
  "non_authorization": {
    "runtime_binding": false,
    "ledger_reads": false,
    "ledger_writes": false,
    "ledger_append": false,
    "ledger_replay": false,
    "ledger_compact": false,
    "ledger_subscribe": false,
    "migration_execution": false
  },
  "descriptor_hash": "sha256:<canonical-descriptor>"
}
```

`descriptor_hash` and `descriptor_registry_hash` are evidence anchors only.
They do not prove live operation availability.

---

## Diagnostics Shape

Gate 2 diagnostics are requirement-vs-descriptor metadata checks:

```json
{
  "kind": "ledger_tbackend_adapter_descriptor_diagnostics",
  "status": "ok | blocked",
  "missing_ops": [],
  "missing_hook_methods": [],
  "missing_capabilities": [],
  "missing_axes": [],
  "schema_fingerprint_match": true,
  "descriptor_hash": "sha256:<descriptor>",
  "descriptor_registry_hash": "sha256:<registry>"
}
```

Required blocking diagnostics:

| Missing / mismatch | Expected diagnostic |
|---|---|
| required TBackend op | `missing_ops` |
| `read_as_of` or `bihistory_at` | `missing_hook_methods` |
| `history_read` or `bihistory_read` | `missing_capabilities` |
| `valid_time` or `transaction_time` | `missing_axes` |
| schema fingerprint mismatch | `schema_fingerprint_match: false`, `status: blocked` |

---

## Package Files Likely Touched If Approved

If Architect approves Gate 2 and the package surface did not already exist,
Package Agent would touch only:

```text
packages/igniter-ledger/lib/igniter/store/tbackend_adapter_descriptor.rb
packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
packages/igniter-ledger/lib/igniter/store.rb
packages/igniter-ledger/docs/tracks/ledger-tbackend-adapter-descriptor-package-v0.md
packages/igniter-ledger/docs/README.md
```

Current read-only observation: these exact surfaces already appear present.
Therefore the Gate 2 decision can be either:

1. **Approve / ratify existing metadata-only package exposure** as within the
   Gate 2 boundary; or
2. **Hold Gate 2 closed** and treat the existing package surface as provisional
   until Architect review signs off.

No new package edits are requested by this Bridge Agent slice.

---

## Implementation Plan If Approved

If Gate 2 is approved/ratified, the approved package behavior is exactly:

1. Keep `TBackendAdapterDescriptor` as a metadata value object.
2. Build from `metadata_snapshot` and `descriptor_snapshot` hashes only.
3. Compute canonical `descriptor_hash` and `descriptor_registry_hash`.
4. Derive supported TBackend ops from Ledger Open Protocol op names.
5. Derive hook methods, capabilities, and axes from snapshot content.
6. Expose `diagnostics(requirement = {})`.
7. Preserve explicit `non_authorization` flags.
8. Keep targeted package specs for construction, hash stability, requirement
   diagnostics, alias visibility, and absent operational methods.

No additional implementation is needed in this Bridge Agent slice.

---

## Acceptance Criteria For Gate 2

Gate 2 should be considered satisfied only if all are true:

- Descriptor construction is metadata-only.
- Constructor uses snapshots and caller-supplied schema fingerprint.
- Descriptor packet includes hash, registry hash, capabilities, axes, hooks,
  cursor policy, diagnostics, and non-authorization fields.
- Targeted package specs pass.
- `Igniter::Ledger::TBackendAdapterDescriptor` visibility is documented as an
  alias over current `Igniter::Store` internals.
- The descriptor object does not respond to operational adapter methods.
- Package docs explicitly say no reads/writes/replay/runtime binding.
- Gate 3 remains closed.

Observed package track claims:

```text
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec \
  packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
-> 9 examples, 0 failures
```

This Bridge Agent did not rerun package specs.

---

## Gate 2 Decision Request

[Q] Architect Supervisor: approve/ratify Gate 2 for metadata-only package
exposure of `Igniter::Store::TBackendAdapterDescriptor`, visible through
`Igniter::Ledger::TBackendAdapterDescriptor`, with the descriptor packet and
diagnostics shape defined above?

Decision options:

| Decision | Meaning |
|---|---|
| Approve / ratify Gate 2 | Package may expose descriptor metadata object and diagnostics only |
| Hold Gate 2 | Existing or planned package exposure remains provisional and must not be used by CompatibilityReport/package consumers |
| Redirect Gate 2 | Rename, relocate, or reshape descriptor before approval |

Gate 2 approval must not be interpreted as Gate 3 approval.

---

## Gate 3 Non-Authorization

Still not authorized:

- live Ledger-backed adapter
- `read_as_of`
- `bihistory_at`
- Ledger `read`, `write`, `append`, `replay`, `compact`, or `subscribe`
- RuntimeMachine production binding
- production CompatibilityReport enforcement
- migration execution
- Ledger history rewrite
- replacement SemanticImage
- Ledger-as-core language semantics

Any future Gate 3 request must name production operations explicitly and include
new proof evidence.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S3-R4-C6-G
Track: descriptor-package-exposure-gate2-decision-v0
Status: decision-request

[D] Decisions:
- Gate 2 is defined as metadata-only package exposure of a descriptor value
  object plus diagnostics.
- The exact candidate surface is Igniter::Store::TBackendAdapterDescriptor,
  visible through Igniter::Ledger::TBackendAdapterDescriptor.
- Package exposure excludes every live operation and every RuntimeMachine /
  CompatibilityReport production binding.

[S] Signals:
- Gate 1 fixture PASS proves report-only descriptor consumption.
- Read-only package evidence shows a descriptor package track and package files
  already exist with non-operational specs.
- Package docs preserve the Ledger/Store namespace caveat.

[T] Tests / Proofs:
- Docs-only decision request; no tests run.

[R] Risks / Recommendations:
- Architect should approve/ratify or hold Gate 2 explicitly because package
  evidence appears to exist already.
- Do not infer Gate 3 from package descriptor exposure.
- If Gate 2 is approved, next bridge step may plan CompatibilityReport
  package consumption of this descriptor as metadata-only.

[Next] Architect Supervisor decision: approve/ratify, hold, or redirect Gate 2.
```
