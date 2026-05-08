# Track: CompatibilityReport Descriptor Consumption Fixture v0

Card: S3-R3-C5-P
Role: `[Igniter-Lang Bridge Agent]`
Track: `compatibility-report-descriptor-consumption-fixture-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Approval Boundary

Architect approval is Gate 1 only:

```text
approved: proof-local CompatibilityReport descriptor-consumption fixture
not approved: package exposure
not approved: production Ledger/runtime binding
```

This track implements only a proof-local fixture in `igniter-lang`.

---

## Current Horizon

- `compatibility-report-descriptor-consumption-v0` defined the report-only bridge.
- `ledger-tbackend-adapter-descriptor-v0` provides descriptor hash, registry hash,
  capabilities, axes, hook methods, cursor policy, diagnostics, and
  non-authorization fields.
- `PROP-028` requires TEMPORAL capability evidence and blocks CORE cache policy
  for TEMPORAL contracts (`OOF-TM9`).
- Stage 3 TBackend lane still does not allow production Ledger read/write/replay
  or runtime binding.

---

## Implemented Fixture

Added:

```text
igniter-lang/experiments/compatibility_report_descriptor_consumption_fixture/
  compatibility_report_descriptor_consumption_fixture.rb
  compatibility_report_descriptor_consumption_summary.json
```

The fixture consumes a descriptor value packet and compiled temporal
requirements into a proof-local `CompatibilityReport`-shaped payload:

```json
{
  "kind": "proof_local_compatibility_report",
  "dimension": "temporal_backend_adapter",
  "schema_check": {
    "decision": "not_evaluated_here",
    "independent_from_backend_descriptor": true
  },
  "backend_check": {
    "decision": "trusted_metadata | provisional_metadata | blocked",
    "runtime_enforced": false,
    "report_only": true,
    "temporal_backend_descriptor": {}
  }
}
```

No live adapter object is created. The fixture imports the existing proof-local
descriptor builder and never calls Ledger or package code.

---

## Consumed Evidence

The fixture consumes:

| Evidence | Report placement |
|---|---|
| `descriptor_hash` | `backend_check.temporal_backend_descriptor.descriptor_hash` |
| `descriptor_registry_hash` | `backend_check.temporal_backend_descriptor.descriptor_registry_hash` |
| `supported_tbackend_ops` | compared to `required_ops` |
| `hook_methods` | compared to `required_hook_methods` |
| `capabilities` | compared to `required_capabilities` |
| `history_axes` | compared to `history_axes` |
| `schema_fingerprint` | compared but recorded separately from `schema_check` |
| `cursor_policy` | drives `trusted_metadata` vs `provisional_metadata` |
| `non_authorization` | must keep runtime/Ledger operation flags false |
| `cache_policy` | TEMPORAL contracts must use temporal cache policy |

Evidence links are emitted only when hashes are present:

```json
[
  { "rel": "described_by", "to": "sha256:<descriptor>" },
  { "rel": "registry_snapshot", "to": "sha256:<registry>" }
]
```

---

## Decision Cases

| Case | Decision | Proof signal |
|---|---|---|
| `trusted_metadata` | `trusted_metadata` | all descriptor requirements satisfied; temporal cache policy present |
| `provisional_metadata` | `provisional_metadata` | descriptor metadata is present, but cursor/snapshot confidence is not enough for exact replay/resume |
| `missing_capability` | `blocked` | missing `bihistory_read` |
| `missing_axis` | `blocked` | missing `transaction_time` |
| `missing_hook` | `blocked` | missing `bihistory_at` |
| `missing_descriptor_hash` | `blocked` | missing `descriptor_hash` |
| `missing_registry_hash` | `blocked` | missing `descriptor_registry_hash` |
| `bad_cache_policy` | `blocked` | `OOF-TM9`; TEMPORAL contract uses CORE cache key |

All reports preserve:

```json
{
  "runtime_enforced": false,
  "report_only": true
}
```

---

## JSON Summary

The fixture writes:

```text
igniter-lang/experiments/compatibility_report_descriptor_consumption_fixture/compatibility_report_descriptor_consumption_summary.json
```

Top-level summary fields:

```json
{
  "kind": "compatibility_report_descriptor_consumption_summary",
  "card": "S3-R3-C5-P",
  "status": "PASS",
  "approved_gate": "gate_1_proof_local_only",
  "runtime_enforced": false,
  "report_only": true,
  "non_authorization": {
    "package_exposure": false,
    "runtime_binding": false,
    "ledger_reads": false,
    "ledger_writes": false,
    "ledger_replay": false,
    "live_adapter": false
  }
}
```

---

## Proof Command

```bash
ruby igniter-lang/experiments/compatibility_report_descriptor_consumption_fixture/compatibility_report_descriptor_consumption_fixture.rb
```

Observed result:

```text
PASS trusted descriptor is trusted_metadata
PASS provisional descriptor is provisional_metadata
PASS missing_capability is blocked
PASS missing_axis is blocked
PASS missing_hook is blocked
PASS missing_descriptor_hash is blocked
PASS missing_registry_hash is blocked
PASS bad_cache_policy is blocked
PASS all reports remain report-only
PASS summary written igniter-lang/experiments/compatibility_report_descriptor_consumption_fixture/compatibility_report_descriptor_consumption_summary.json
```

---

## Non-Authorization Statement

This fixture does not authorize:

- package exposure of `LedgerTBackendAdapterDescriptor`
- package edits
- production `CompatibilityReport` integration
- Ledger reads, writes, append, replay, compact, or subscribe
- live adapter creation
- RuntimeMachine production binding
- `read_as_of` or `bihistory_at` against Ledger
- migration execution, Ledger history rewrite, or replacement SemanticImage
- `CompatibilityReport.overall: trusted` solely from descriptor metadata

Gate 2 and Gate 3 remain closed.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S3-R3-C5-P
Track: compatibility-report-descriptor-consumption-fixture-v0
Status: done

[D] Decisions:
- Implemented proof-local CompatibilityReport descriptor consumption only.
- `backend_check.temporal_backend_descriptor` carries descriptor hashes,
  registry hashes, capabilities, axes, hook methods, diagnostics, and evidence links.
- Decisions are trusted_metadata, provisional_metadata, or blocked.
- `runtime_enforced` remains false for every report.
- `schema_check` remains independent and is not evaluated by this fixture.

[S] Signals:
- Trusted metadata path passes with full descriptor evidence.
- Provisional metadata path records insufficient cursor/snapshot confidence.
- Missing capability, axis, hook, descriptor hash, registry hash, and TEMPORAL
  cache policy all block.
- Non-authorization is explicit in the JSON summary.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compatibility_report_descriptor_consumption_fixture/compatibility_report_descriptor_consumption_fixture.rb -> PASS
- ruby -c igniter-lang/experiments/compatibility_report_descriptor_consumption_fixture/compatibility_report_descriptor_consumption_fixture.rb -> Syntax OK

[R] Risks / Recommendations:
- Package exposure remains unapproved.
- Production Ledger/runtime binding remains unapproved.
- Next approval question should name Gate 2 or Gate 3 explicitly; do not infer it from this fixture.

[Next] Ask Architect Supervisor whether Gate 2 package exposure may be opened
for metadata-only descriptor object work.
```
