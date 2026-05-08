# Track: Descriptor Compatibility Package Consumption v0

Card: S3-R7-C5-G
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `descriptor-compatibility-package-consumption-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Context Update

`agent-context.md` is treated as the trusted current map for this slice.

Current horizon:

- Gate 1 descriptor consumption fixture: PASS, proof-local, report-only.
- Gate 2 package descriptor exposure: ratification recommended.
- Gate 3 Ledger/runtime execution: closed.
- RuntimeMachine may load TEMPORAL `.igapp/` for inspection, but evaluation
  remains refused until approved executor/TBackend work.
- Package descriptor metadata can inform compatibility reasoning; it cannot
  authorize live reads, replay, or execution.

---

## Scope

This track connects existing package descriptor metadata to report-only
`RuntimeMachine` / `CompatibilityReport` reasoning.

It does not edit packages, instantiate a live Ledger adapter, perform temporal
reads, call Ledger, replay state, or execute TEMPORAL contracts.

---

## Package Surface Inspected

Read-only package files inspected:

```text
packages/igniter-ledger/lib/igniter/store/tbackend_adapter_descriptor.rb
packages/igniter-ledger/lib/igniter/store.rb
packages/igniter-ledger/lib/igniter/ledger.rb
packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
packages/igniter-ledger/docs/tracks/ledger-tbackend-adapter-descriptor-package-v0.md
packages/igniter-ledger/docs/reviews/2026-05-07-native-tbackend-gap-review.md
```

Observed package class:

```ruby
Igniter::Store::TBackendAdapterDescriptor
Igniter::Ledger::TBackendAdapterDescriptor
```

The `Igniter::Ledger` name is currently an alias of `Igniter::Store`, so Gate 2
visibility is alias-based rather than a separate deep namespace.

Observed constructor:

```ruby
.build(
  metadata_snapshot:,
  descriptor_snapshot:,
  schema_fingerprint:,
  adapter_ref: nil,
  ledger_protocol_ops: nil
)
```

Observed metadata methods:

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

Observed non-operational boundary:

- no `read_as_of`
- no `bihistory_at`
- no `read`, `write`, `append`, `replay`, `compact`, or `subscribe`
- `non_authorization` flags keep runtime binding and Ledger operations false

---

## Compatibility Descriptor Mapping

The package descriptor should be consumed as a value packet, not as an adapter.

```text
compiled temporal requirements
  + package descriptor.to_h
  + package descriptor.diagnostics(requirement)
  -> CompatibilityReport.backend_check.temporal_backend_descriptor
```

| Requirement / evidence | Package descriptor field | CompatibilityReport placement | Decision pressure |
|---|---|---|---|
| Descriptor identity | `descriptor_hash` | `evidence_links[].rel = "described_by"` | missing hash blocks |
| Registry identity | `descriptor_registry_hash` | `evidence_links[].rel = "registry_snapshot"` | missing hash blocks |
| Required TBackend ops | `supported_tbackend_ops` | `required_ops` vs `supported_tbackend_ops` | missing required op blocks |
| Point history access metadata | `hook_methods` includes `read_as_of` | `required_hook_methods` vs `hook_methods` | missing hook blocks |
| Bitemporal access metadata | `hook_methods` includes `bihistory_at` | `required_hook_methods` vs `hook_methods` | missing hook blocks |
| History capability | `capabilities` includes `history_read` | `required_capabilities` vs `capabilities` | missing capability blocks |
| BiHistory capability | `capabilities` includes `bihistory_read` | `required_capabilities` vs `capabilities` | missing capability blocks |
| Valid-time axis | `history_axes` includes `valid_time` | `required_axes` vs `history_axes` | missing axis blocks |
| Transaction-time axis | `history_axes` includes `transaction_time` | `required_axes` vs `history_axes` | missing axis blocks |
| Cursor metadata | `cursor_policy` | `cursor_policy` summary | can be provisional for exact replay/resume |
| Schema anchor | `schema_fingerprint` via `diagnostics` | backend record plus independent `schema_check` | mismatch blocks schema compatibility |
| Non-authorization | `non_authorization` | copied under descriptor section | any operational true value blocks Gate 2 use |

Important package-review pressure:

```text
Descriptor bihistory_read is metadata evidence only.
It does not prove the native data plane physically serves BiHistory at(vt:, tt:).
```

That distinction must stay visible in `CompatibilityReport`; descriptor
capability is not production serving proof.

---

## Report-Only Payload Shape

Recommended `CompatibilityReport` section:

```json
{
  "backend_check": {
    "decision": "trusted_metadata",
    "report_only": true,
    "runtime_enforced": false,
    "temporal_backend_descriptor": {
      "source": "package_descriptor",
      "package_class": "Igniter::Store::TBackendAdapterDescriptor",
      "package_alias": "Igniter::Ledger::TBackendAdapterDescriptor",
      "descriptor_kind": "ledger_tbackend_adapter_descriptor",
      "adapter_kind": "ledger_open_protocol",
      "descriptor_hash": "sha256:<descriptor>",
      "descriptor_registry_hash": "sha256:<registry>",
      "required_ops": ["read", "append", "replay", "snapshot"],
      "supported_tbackend_ops": ["read", "append", "replay", "snapshot"],
      "required_hook_methods": ["read_as_of", "bihistory_at"],
      "hook_methods": ["read_as_of", "bihistory_at"],
      "required_capabilities": ["history_read", "bihistory_read"],
      "capabilities": ["history_read", "bihistory_read"],
      "required_axes": ["valid_time", "transaction_time"],
      "history_axes": ["valid_time", "transaction_time"],
      "cursor_policy": {
        "ordered": "forward",
        "cursor_kinds": ["timestamp"],
        "truncation_reported": true,
        "tie_breaker": "timestamp_then_fact_id_required"
      },
      "diagnostics": {
        "kind": "ledger_tbackend_adapter_descriptor_diagnostics",
        "status": "ok",
        "missing_ops": [],
        "missing_hook_methods": [],
        "missing_capabilities": [],
        "missing_axes": [],
        "schema_fingerprint_match": true
      },
      "evidence_links": [
        { "rel": "described_by", "to": "sha256:<descriptor>" },
        { "rel": "registry_snapshot", "to": "sha256:<registry>" }
      ],
      "non_authorization": {
        "runtime_binding": false,
        "ledger_reads": false,
        "ledger_writes": false,
        "ledger_append": false,
        "ledger_replay": false,
        "ledger_compact": false,
        "ledger_subscribe": false,
        "migration_execution": false
      }
    }
  }
}
```

`schema_check` remains independent. A descriptor schema fingerprint mismatch can
be recorded in `backend_check`, but compatibility schema decisions must still be
made by the schema compatibility path.

---

## Decision Rules

`trusted_metadata` is allowed only when:

- Gate 2 is formally ratified by Architect Supervisor;
- descriptor and registry hashes are present;
- package diagnostics status is `ok`;
- required ops, hook methods, capabilities, and axes are satisfied;
- TEMPORAL cache policy remains temporal, not CORE-cacheable;
- non-authorization flags remain false for runtime and Ledger operations.

`provisional_metadata` is appropriate when:

- Gate 2 has not yet been formally ratified but the package surface matches the
  ratification recommendation;
- descriptor metadata is present but cursor/snapshot evidence is insufficient
  for exact replay or resume claims;
- package review pressure shows metadata capability before physical serving
  proof, especially for BiHistory.

`blocked` is required when:

- descriptor hash or registry hash is missing;
- a required op, hook method, capability, or axis is missing;
- schema fingerprint does not match the compiled requirement;
- TEMPORAL contract uses a CORE cache policy;
- descriptor non-authorization flags imply live binding or Ledger operations;
- any consumer tries to treat the descriptor as an executable adapter.

---

## Gate 2 / Gate 3 Boundary

Gate 2, once ratified, allows only:

- package descriptor construction from metadata snapshots;
- stable descriptor and registry hashes;
- derived capability, axis, hook, cursor, and operation metadata;
- requirement diagnostics;
- report-only `CompatibilityReport` consumption with `runtime_enforced: false`.

Gate 2 does not allow:

- live Ledger-backed TBackend adapter construction;
- `read_as_of` or `bihistory_at`;
- Ledger read, write, append, replay, compact, or subscribe;
- RuntimeMachine TEMPORAL evaluation;
- production checkpoint/resume proof;
- migration execution;
- Ledger-as-core semantics.

Gate 3 remains closed and must be opened by a separate Architect approval that
names live operations explicitly.

---

## Recommendation

Recommended next package-facing slice after Gate 2 is formally ratified:

```text
compatibility-report-package-descriptor-consumption-v0
```

Acceptance for that future slice should be metadata-only:

- accept a `TBackendAdapterDescriptor` value packet or `to_h` payload;
- call `diagnostics(requirement)` or consume equivalent diagnostics;
- emit `backend_check.temporal_backend_descriptor`;
- keep `report_only: true` and `runtime_enforced: false`;
- preserve evidence links and non-authorization flags;
- include blocked cases for missing hash, capability, axis, hook, op, schema
  mismatch, bad cache policy, and attempted operational use.

Do not start Gate 3 runtime binding from this recommendation.

---

## Verification

Targeted package spec rerun:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec \
  packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
```

Observed result:

```text
9 examples, 0 failures
```

No package files were edited.

---

## Handoff

```text
Card: S3-R7-C5-G
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: descriptor-compatibility-package-consumption-v0
Status: done

[D] Decisions
- RuntimeMachine/CompatibilityReport may consume package descriptor metadata
  only as report-only compatibility evidence.
- Gate 2 package exposure still requires formal Architect ratification before
  trusted_metadata is used for package-backed reports.
- Gate 3 remains closed for all live Ledger/runtime operations.

[S] Shipped / Signals
- Added compatibility descriptor mapping from package fields to
  backend_check.temporal_backend_descriptor.
- Preserved distinction between metadata capability and physical serving proof.
- Named package class, alias, constructor, metadata methods, diagnostics, and
  non-operational boundary.

[T] Tests / Proofs
- BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec
  packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
  -> 9 examples, 0 failures

[R] Risks / Recommendations
- Do not infer production BiHistory support from descriptor capability alone.
- Next slice may plan package-level CompatibilityReport descriptor consumption
  only after Gate 2 is formally ratified.
- Gate 3 needs a separate approval naming live reads/writes/replay/runtime
  binding.

[Next] Suggested next slice
- Architect Supervisor records Gate 2 ratification or redirects it; then a
  metadata-only package CompatibilityReport consumption slice may be opened.
```
