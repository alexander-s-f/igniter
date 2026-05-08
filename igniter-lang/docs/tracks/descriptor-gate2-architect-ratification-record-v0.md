# Track: Descriptor Gate 2 Architect Ratification Record v0

Card: S3-R9-C1-G
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `descriptor-gate2-architect-ratification-record-v0`
Status: ratified
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Decision

[D] **Gate 2 is ratified**.

Architect decision recorded:

```text
Gate 2 is ratified for metadata-only package exposure of
Igniter::Store::TBackendAdapterDescriptor, visible through
Igniter::Ledger::TBackendAdapterDescriptor.

The trusted surface is descriptor metadata only: construction from
metadata_snapshot / descriptor_snapshot, canonical descriptor and registry
hashes, derived operation/capability/axis/hook/cursor metadata, explicit
non-authorization flags, and requirement diagnostics.

This ratification authorizes report-only descriptor metadata consumption. It
does not authorize runtime authority, live Ledger operations, temporal reads,
replay, RuntimeMachine execution, production enforcement, migration behavior, or
Gate 3.
```

Decision state:

```text
ratified
```

Not selected:

```text
redirected
blocked
```

Blocking reason:

```text
none for Gate 2 metadata-only exposure
```

---

## What Becomes Trusted Metadata

The following package descriptor fields may now be treated as trusted report
metadata when sourced from the ratified descriptor surface:

- descriptor kind: `ledger_tbackend_adapter_descriptor`
- package class: `Igniter::Store::TBackendAdapterDescriptor`
- package alias: `Igniter::Ledger::TBackendAdapterDescriptor`
- constructor inputs: `metadata_snapshot`, `descriptor_snapshot`,
  `schema_fingerprint`, optional `adapter_ref`, optional `ledger_protocol_ops`
- `descriptor_hash`
- `descriptor_registry_hash`
- `ledger_protocol_ops`
- `supported_tbackend_ops`
- `hook_methods`
- `capabilities`
- `history_axes`
- `cursor_policy`
- `diagnostics(requirement)`
- `non_authorization`

Trusted metadata means:

```text
usable as evidence in report-only CompatibilityReport sections
```

It does not mean:

```text
runtime execution authority
```

---

## Report-Only Consumption Allowed

After this ratification, a future package-consumption slice may consume
descriptor metadata into:

```text
CompatibilityReport.backend_check.temporal_backend_descriptor
```

Allowed report decisions remain:

```text
trusted_metadata
provisional_metadata
blocked
```

Required report flags:

```json
{
  "report_only": true,
  "runtime_enforced": false
}
```

`schema_check` remains independent. Descriptor diagnostics may report schema
fingerprint match or mismatch, but schema compatibility remains owned by the
schema compatibility path.

---

## Gate 2 Still Does Not Allow

Gate 2 does not allow:

- live Ledger-backed TBackend adapter construction;
- `read_as_of`;
- `bihistory_at`;
- Ledger `read`, `write`, `append`, `replay`, `compact`, or `subscribe`;
- temporal reads from RuntimeMachine;
- RuntimeMachine TEMPORAL evaluation;
- production checkpoint/resume proof;
- production CompatibilityReport enforcement;
- `runtime_enforced: true`;
- migration execution;
- Ledger history rewrite;
- replacement SemanticImage production migration behavior;
- Ledger-as-core language semantics.

Gate 3 remains closed and requires a separate Architect approval naming live
operations explicitly.

---

## BiHistory Warning Preserved

[D] Preserve this warning across all package-consumption work:

```text
Descriptor bihistory_read is metadata evidence only.
It does not prove the native data plane physically serves BiHistory at(vt:, tt:).
```

Ratified Gate 2 can trust the descriptor's metadata claim that a capability is
advertised. It cannot infer indexed valid-time access, bitemporal serving,
replay fidelity, or physical data-plane correctness.

---

## Ratification Checklist

| Check | Evidence | Status |
|---|---|---|
| Gate 1 report-only consumption fixture | `compatibility-report-descriptor-consumption-fixture-v0` | PASS |
| Package descriptor exposure evidence | `descriptor-package-exposure-gate2-ratification-v0` | PASS |
| Formal Gate 2 decision recommendation | `descriptor-gate2-ratification-decision-v0` | PASS |
| Package descriptor mapping to reports | `descriptor-compatibility-package-consumption-v0` | PASS |
| Alias visibility evidence | prior package spec confirms `Igniter::Ledger::TBackendAdapterDescriptor` | PASS |
| Descriptor is non-operational | no temporal read/write/replay methods | PASS |
| Non-authorization flags are explicit | runtime/Ledger/migration flags false | PASS |
| BiHistory warning preserved | `value-index.md` + package-consumption track | PASS |
| Gate 3 closed | `agent-context.md` / `current-status.md` | PASS |

---

## Status Map Updates

This slice updates the active maps because the decision changes the gate state:

- `agent-context.md`: TBackend Gate 2 state becomes `RATIFIED`.
- `current-status.md`: TBackend lane and horizon now say Gate 2 is ratified.

`value-index.md` did not require an update: its durable boundary rule already
states that Gate 2 and Gate 3 stay separate, and the BiHistory warning remains
current.

---

## Next Safe Slice

The next safe package-facing slice is:

```text
compatibility-report-package-descriptor-consumption-v0
```

Allowed scope for that slice:

- consume ratified descriptor metadata;
- emit report-only `backend_check.temporal_backend_descriptor`;
- preserve evidence links;
- preserve `non_authorization`;
- keep `report_only: true`;
- keep `runtime_enforced: false`;
- test blocked cases for missing metadata and attempted operational use.

Still not allowed:

- live Ledger binding;
- temporal reads;
- replay;
- execution;
- Gate 3.

---

## Verification

Docs-only decision record. No package tests were rerun in this slice.

Prior Gate 2 evidence remains:

```text
packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
-> 9 examples, 0 failures
```

---

## Handoff

```text
Card: S3-R9-C1-G
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: descriptor-gate2-architect-ratification-record-v0
Status: ratified

[D] Decisions
- Gate 2 is ratified for metadata-only descriptor exposure.
- Trusted descriptor metadata may feed report-only CompatibilityReport sections.
- Gate 3 remains closed.

[S] Signals
- Gate 1, Gate 2 exposure, decision recommendation, and package-consumption
  mapping are aligned.
- Descriptor metadata remains non-authorizing runtime evidence.
- BiHistory capability remains metadata only, not physical serving proof.

[T] Tests / Proofs
- Docs-only slice; no package tests rerun.
- Prior targeted package descriptor spec evidence remains 9 examples,
  0 failures.

[R] Risks / Recommendations
- Do not treat trusted_metadata as runtime authority.
- Open compatibility-report-package-descriptor-consumption-v0 next.
- Any live Ledger or RuntimeMachine binding remains Gate 3 and needs a separate
  Architect approval.

[Next] Suggested next slice
- compatibility-report-package-descriptor-consumption-v0
```
