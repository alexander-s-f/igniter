# Track: Production TBackend Adapter Fixture v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/production-tbackend-adapter-fixture-v0`
Card: S2-R10-C3-P
Status: done
Date: 2026-05-07

---

## Context

R9 (`production-tbackend-adapter-shape-v0`) defined the next runtime bridge:

```text
.igapp runtime metadata
  -> AdapterRegistry selection
  -> selected adapter descriptor / descriptor hash
  -> read_as_of / bihistory_at shim
  -> RuntimeMachineHook load_check
  -> CompatibilityReport evidence
```

This slice turns that shape into a proof-local fixture. It does not bind Ledger,
Durable Model, file storage, package interfaces, or production persistence.

---

## Shipped Fixture

Added:

```text
igniter-lang/experiments/production_tbackend_adapter_fixture/adapter_registry_fixture.rb
```

The fixture provides:

- `.igapp`-style runtime metadata via `igapp_runtime_metadata`
- canonical `tbackend_adapter_descriptor` construction
- `AdapterRegistry#select(metadata, backend:)`
- selected shim object exposing:
  - `supports_capability?`
  - `read_as_of(subject, as_of)`
  - `bihistory_at(history_ref, vt:, tt:, node_name:)`
- proof-local CompatibilityReport payload via `compatibility_report`

The selected adapter records `adapter_ref` and `adapter_descriptor_hash` in temporal
access observations, so RuntimeMachine evidence can point back to the selected backend
contract surface.

---

## RuntimeMachine Proof Wiring

`runtime_machine_memory_proof.rb` now loads `TemporalDispatchContract` through the
registry path:

```text
TemporalDispatchContract#igapp_runtime_metadata
  -> AdapterRegistry selects memory tbackend descriptor
  -> selected shim feeds RuntimeMachineHook
  -> RuntimeMachineHook#load_check passes
  -> proof-local compatibility report packet is appended
  -> RuntimeMachine#evaluate_temporal_access uses selected shim
```

The existing direct shim path remains for negative capability/backend-method checks.

---

## CompatibilityReport Evidence Summary

The proof-local CompatibilityReport packet includes:

```json
{
  "kind": "proof_local_compatibility_report",
  "dimension": "temporal_backend_adapter",
  "status": "trusted",
  "selected_adapter_descriptor_hash": "sha256:...",
  "adapter_selection_check": {
    "kind": "tbackend_adapter_selection_check",
    "status": "ok",
    "missing_ops": [],
    "missing_hook_methods": [],
    "missing_capabilities": [],
    "missing_axes": [],
    "schema_fingerprint_match": true
  },
  "temporal_access_hook_load_check": {
    "kind": "temporal_access_hook_load_check",
    "status": "ok"
  },
  "evidence_summary": {
    "adapter_descriptor_persisted": true,
    "load_check_persisted": true,
    "hook_methods": ["read_as_of", "bihistory_at"],
    "capabilities": ["history_read", "bihistory_read"],
    "history_axes": ["valid_time", "transaction_time"]
  }
}
```

The runtime proof checks:

- selected descriptor is persisted on the loaded unit
- compatibility report packet persists descriptor hash and hook load check
- temporal evaluation value packet carries the selected descriptor hash
- an adapter descriptor missing `bihistory_at` is blocked by registry selection

---

## Acceptance Status

| Check | Status |
|-------|--------|
| `ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb` | PASS |
| `ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb` | PASS |
| `ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb` | PASS |

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R10-C3-P
Track: production-tbackend-adapter-fixture-v0
Status: done

[D] Decisions:
- AdapterRegistry selection is proof-local and metadata-driven.
- The selected shim, not the raw six-op backend, is passed to RuntimeMachineHook.
- CompatibilityReport evidence persists selected adapter descriptor hash plus hook load_check.
- Ledger/Durable binding remains out of scope.

[S] Signals:
- runtime_machine_memory_proof now proves .igapp-style metadata -> adapter descriptor -> hook -> compatibility report.
- Selected adapter exposes both read_as_of and bihistory_at.
- Missing bihistory_at is blocked before hook evaluation.
- History/BiHistory proofs remain unchanged and green.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb -> PASS
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS

[R] Risks:
- CompatibilityReport is still proof-local; production report schema is not finalized.
- Registry descriptor schema is intentionally small and should not be treated as package API yet.
- Ledger/Durable adapters still need explicit package-level design and approval.

[Next] Production adapter package boundary:
- Promote descriptor schema + AdapterRegistry API only after compiler orchestrator/runtime package spine stabilizes.
```
