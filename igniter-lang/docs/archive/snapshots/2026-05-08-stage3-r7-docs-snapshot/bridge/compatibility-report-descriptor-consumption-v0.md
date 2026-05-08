# CompatibilityReport Descriptor Consumption Bridge v0

Card: S3-R2-C5-P
Role: `[Igniter-Lang Bridge Agent]`
Track: `compatibility-report-descriptor-consumption-v0`
Status: proposal
Date: 2026-05-08
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Plan how `RuntimeMachine` / `CompatibilityReport` can consume
Ledger/TBackend descriptor evidence without production read/write/replay
binding.

This bridge is metadata-only. It does not select a live Ledger adapter, does not
call Ledger, and does not authorize `read_as_of`, `bihistory_at`, replay,
compaction, subscription, or migration behavior.

---

## Source Signals

[S] `PROP-028-temporal-fragment-class-v0` defines `TEMPORAL` as a first-class
fragment class. Temporal reads require explicit coordinates plus TBackend
capability evidence, but the read result is a CORE-typed value.

[S] `PROP-028` also makes temporal cache policy part of semantic correctness:
a TEMPORAL contract cannot be consumed as CORE-cacheable evidence.

[S] `ledger-tbackend-adapter-descriptor-v0` proves a metadata-only
`ledger_tbackend_adapter_descriptor` with `descriptor_hash`,
`descriptor_registry_hash`, capabilities, axes, cursor policy, and diagnostics.

[S] `ledger-tbackend-adapter-descriptor-package-plan-v0` scopes the first
package slice to descriptor construction and diagnostics only.

[S] Stage 3 current status carries `production_tbackend_adapter_binding` as a
deferred gap. Ledger descriptor evidence is available; production binding still
requires Architect approval.

---

## Bridge Claim

[D] `CompatibilityReport` may consume a `TBackendAdapterDescriptor` as
report-only backend evidence:

```text
compiled temporal requirements
  + descriptor hash / registry hash
  + descriptor diagnostics
  -> CompatibilityReport.backend_check.temporal_backend_descriptor
```

[D] Descriptor consumption can decide whether required metadata is present and
compatible. It cannot prove that Ledger reads, writes, replay, or checkpoint
resume work in production.

[D] A successful descriptor check may be `trusted_metadata`; it must not upgrade
`CompatibilityReport.overall` to production `trusted` for temporal execution
unless a separately approved runtime binding proof exists.

---

## Consumption Point

Proposed RuntimeMachine load shape:

```text
Boot
  -> verify .igapp manifest / SemanticIR / CompilationReport
  -> read ContractIR fragment_class + required_capabilities + cache_policy
  -> receive prebuilt TBackendAdapterDescriptor evidence
  -> run descriptor diagnostics against compiled temporal requirements
  -> write CompatibilityReport backend descriptor section
  -> block or continue according to report-only policy
```

The descriptor input is a value packet, not a live adapter:

```json
{
  "kind": "ledger_tbackend_adapter_descriptor",
  "descriptor_hash": "sha256:<descriptor>",
  "descriptor_registry_hash": "sha256:<ledger-descriptor-snapshot>",
  "supported_tbackend_ops": ["read", "append", "replay", "snapshot"],
  "hook_methods": ["read_as_of", "bihistory_at"],
  "capabilities": ["history_read", "bihistory_read"],
  "history_axes": ["valid_time", "transaction_time"],
  "cursor_policy": {
    "ordered": "forward",
    "cursor_kinds": ["timestamp"],
    "truncation_reported": true,
    "tie_breaker": "timestamp_then_fact_id_required"
  },
  "non_authorization": {
    "runtime_binding": false,
    "ledger_reads": false,
    "ledger_writes": false,
    "ledger_replay": false
  }
}
```

---

## CompatibilityReport Shape

Recommended report-only section:

```json
{
  "backend_check": {
    "decision": "trusted_metadata | provisional_metadata | blocked",
    "runtime_enforced": false,
    "report_only": true,
    "temporal_backend_descriptor": {
      "descriptor_kind": "ledger_tbackend_adapter_descriptor",
      "adapter_kind": "ledger_open_protocol",
      "descriptor_hash": "sha256:<descriptor>",
      "descriptor_registry_hash": "sha256:<registry>",
      "schema_fingerprint_match": true,
      "required_ops": ["read", "append", "replay", "snapshot"],
      "supported_tbackend_ops": ["read", "append", "replay", "snapshot"],
      "required_hook_methods": ["read_as_of", "bihistory_at"],
      "hook_methods": ["read_as_of", "bihistory_at"],
      "required_capabilities": ["history_read", "bihistory_read"],
      "capabilities": ["history_read", "bihistory_read"],
      "required_axes": ["valid_time", "transaction_time"],
      "history_axes": ["valid_time", "transaction_time"],
      "cursor_policy": "forward_timestamp_tie_breaker_required",
      "diagnostics_ref": "diag:<hash>",
      "evidence_links": [
        { "rel": "described_by", "to": "sha256:<descriptor>" },
        { "rel": "registry_snapshot", "to": "sha256:<registry>" }
      ]
    }
  }
}
```

`schema_check` remains independent. Matching descriptor hashes or registry
hashes are backend evidence, not schema migration evidence.

---

## Capability / Diagnostics Mapping

| Compiled requirement | Descriptor field | OK | Diagnostic if missing | Report decision |
|---|---|---|---|---|
| TEMPORAL `History[T]` read | `capabilities` includes `history_read` | consume as metadata evidence | `missing_capabilities: ["history_read"]` | `blocked` |
| TEMPORAL `BiHistory[T]` read | `capabilities` includes `bihistory_read` | consume as metadata evidence | `missing_capabilities: ["bihistory_read"]` | `blocked` |
| legacy bitemporal alias | `capabilities` includes `bihistory_read` or alias map | normalize alias to canonical | `capability_alias_unresolved` | `blocked` |
| valid-time axis | `history_axes` includes `valid_time` | axis satisfied | `missing_axes: ["valid_time"]` | `blocked` |
| bitemporal axis | `history_axes` includes `transaction_time` | axis satisfied | `missing_axes: ["transaction_time"]` | `blocked` |
| point temporal access | `hook_methods` includes `read_as_of` | hook metadata satisfied | `missing_hook_methods: ["read_as_of"]` | `blocked` |
| bitemporal access | `hook_methods` includes `bihistory_at` | hook metadata satisfied | `missing_hook_methods: ["bihistory_at"]` | `blocked` |
| TBackend read | `supported_tbackend_ops` includes `read` | operation claim satisfied | `missing_ops: ["read"]` | `blocked` |
| exact replay/resume metadata | `supported_tbackend_ops` includes `replay` and cursor policy is forward | metadata satisfied for future proof | `cursor_policy_untrusted` | `provisional_metadata` or `blocked` for exact resume |
| checkpoint metadata | `supported_tbackend_ops` includes `snapshot` | descriptor snapshot evidence present | `snapshot_not_state_bearing` | `provisional_metadata` |
| cache safety | ContractIR `cache_policy.kind == "temporal"` when fragment is TEMPORAL | cache evidence satisfied | `OOF-TM9` / `temporal_cache_policy_missing` | `blocked` |
| schema identity | descriptor `schema_fingerprint` matches compiled requirement | schema anchor satisfied | `schema_fingerprint_match: false` | `schema_check: blocked`; backend evidence recorded separately |
| evidence identity | `descriptor_hash` + `descriptor_registry_hash` present | evidence addressable | `descriptor_evidence_missing` | `blocked` |

Future `olap_point_read` should follow the same pattern, but this bridge does
not request OLAP package binding.

---

## Status Rules

`trusted_metadata`:

- descriptor hash present
- registry hash present
- schema fingerprint matches
- required ops/hook methods/capabilities/axes are satisfied
- TEMPORAL cache policy is present when contract fragment is temporal
- non-authorization flags remain false for runtime/Ledger operations

`provisional_metadata`:

- descriptor satisfies basic History/BiHistory metadata, but cursor/snapshot
  evidence is insufficient for exact replay/resume
- descriptor snapshot is descriptor-only, not state-bearing
- protocol cursor policy needs tie-breaker proof

`blocked`:

- missing capability, axis, hook method, required op, descriptor hash, registry
  hash, or schema fingerprint match
- TEMPORAL contract claims CORE cache policy
- descriptor claims runtime authorization in a metadata-only path

---

## Non-Goals

- No package edits.
- No Ledger reads, writes, append, replay, compact, or subscribe.
- No RuntimeMachine production binding.
- No selected live adapter object.
- No `read_as_of` or `bihistory_at` implementation against Ledger.
- No migration execution, Ledger history rewrite, or replacement SemanticImage.
- No Ledger-as-core language decision.
- No claim that descriptor-only snapshots prove checkpoint/resume.
- No change to `CompatibilityReport.schema_check` semantics.
- No `CompatibilityReport.overall: trusted` solely from descriptor metadata.

---

## Architect Approval Gate

Before production binding, require an explicit Architect Supervisor approval
that names all three gates:

1. **Descriptor consumption fixture gate**: may Research Agent add a proof-local
   RuntimeMachine/CompatibilityReport fixture that consumes
   `ledger_tbackend_adapter_descriptor` diagnostics into
   `backend_check.temporal_backend_descriptor` with `runtime_enforced: false`?
2. **Package descriptor gate**: may Package Agent expose
   `LedgerTBackendAdapterDescriptor` as a package metadata object once package
   specs pass?
3. **Production binding gate**: may any Package/Runtime Agent add a live
   Ledger-backed adapter with `read_as_of`, `bihistory_at`, replay, or
   RuntimeMachine binding?

Gate 3 must stay closed until Gate 1 and Gate 2 have evidence and Architect
Supervisor explicitly approves production behavior.

Architect question:

[Q] Approve a proof-local `CompatibilityReport` descriptor-consumption fixture
as the next TBackend lane slice, still report-only and with no Ledger
reads/writes/replay?

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S3-R2-C5-P
Track: compatibility-report-descriptor-consumption-v0
Status: done

[D] Decisions:
- CompatibilityReport may consume Ledger/TBackend descriptor evidence as
  backend_check report-only metadata.
- Descriptor consumption can produce trusted_metadata/provisional_metadata/blocked,
  but cannot authorize production temporal execution.
- PROP-028 TEMPORAL capability and cache-policy requirements must be checked
  before descriptor evidence is considered compatible.
- schema_check remains independent from backend descriptor evidence.

[S] Signals:
- Stage 2 closed TBackend descriptor conformance and fixture evidence.
- R12/R13 define descriptor hashes, registry hashes, capabilities, axes,
  cursor policy, diagnostics, and non-authorization fields.
- PROP-028 introduces TEMPORAL requirements that CompatibilityReport must not
  collapse into generic ESCAPE or CORE cache policy.

[T] Tests / Proofs:
- Docs-only bridge; no tests run.

[R] Risks / Recommendations:
- Treat successful descriptor consumption as trusted metadata only.
- Keep runtime_enforced false until a separate production binding proof exists.
- Ask Architect Supervisor to approve a proof-local descriptor-consumption
  fixture before any package or runtime production binding.

[Next] Research Agent may prepare a proof-local RuntimeMachine/CompatibilityReport
descriptor-consumption fixture only after Architect approval.
```
