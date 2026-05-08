# Track: Descriptor Gate 2 Ratification Decision v0

Card: S3-R8-C3-G
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `descriptor-gate2-ratification-decision-v0`
Status: ratify-recommended
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Recommended Architect Decision

[R] Ratify **TBackend Gate 2** for metadata-only Ledger/TBackend descriptor
exposure.

Recommended decision text:

```text
Gate 2 is ratified for metadata-only package exposure of
Igniter::Store::TBackendAdapterDescriptor, visible through
Igniter::Ledger::TBackendAdapterDescriptor.

The ratified surface is limited to descriptor construction from
metadata_snapshot / descriptor_snapshot, canonical descriptor and registry
hashes, derived operation/capability/axis/hook/cursor metadata, non-authorization
flags, and requirement diagnostics.

Descriptor metadata may be trusted only as report metadata. It may feed
report-only CompatibilityReport backend_check.temporal_backend_descriptor
sections with runtime_enforced: false. It does not authorize live Ledger
operations, temporal reads, replay, RuntimeMachine execution, production
enforcement, or migration behavior.
```

This track prepares the formal decision. It does not itself edit packages or
open Gate 3.

---

## Gate 2 Allows

If ratified, Gate 2 allows:

- exposing the package descriptor value object:
  `Igniter::Store::TBackendAdapterDescriptor`;
- preserving alias visibility through:
  `Igniter::Ledger::TBackendAdapterDescriptor`;
- constructing a descriptor from `metadata_snapshot`, `descriptor_snapshot`,
  `schema_fingerprint`, optional `adapter_ref`, and optional
  `ledger_protocol_ops`;
- producing stable `descriptor_hash` and `descriptor_registry_hash` values;
- deriving metadata-only `supported_tbackend_ops`, `hook_methods`,
  `capabilities`, `history_axes`, and `cursor_policy`;
- returning `diagnostics(requirement)` for missing ops, hooks, capabilities,
  axes, and schema fingerprint mismatch;
- carrying explicit `non_authorization` flags;
- feeding report-only CompatibilityReport metadata after a separate
  package-consumption slice is opened.

Allowed trust level:

```text
trusted report metadata
```

Not allowed trust level:

```text
runtime authority
```

---

## Gate 2 Does Not Allow

Gate 2 does not allow:

- a live Ledger-backed TBackend adapter;
- `read_as_of` implementation;
- `bihistory_at` implementation;
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

Gate 3 remains closed. Any work involving live reads, writes, replay, runtime
binding, or temporal execution requires a new Architect approval that names those
operations explicitly.

---

## Ratification Checklist

| Check | Evidence | Status |
|---|---|---|
| Gate 1 proof-local consumption exists | `compatibility-report-descriptor-consumption-fixture-v0` | PASS |
| Package descriptor exposure exists | `descriptor-package-exposure-gate2-ratification-v0` | PASS |
| Package alias is visible | `Igniter::Ledger::TBackendAdapterDescriptor` alias confirmed by package spec | PASS |
| Descriptor is metadata-only | constructor consumes snapshots and schema fingerprint | PASS |
| Hash evidence is addressable | `descriptor_hash` and `descriptor_registry_hash` | PASS |
| Diagnostics exist | `diagnostics(requirement)` returns ok/blocked metadata | PASS |
| Non-authorization is explicit | runtime/Ledger operation flags remain false | PASS |
| Operational methods are absent | no `read_as_of`, `bihistory_at`, `read`, `write`, `append`, `replay`, `compact`, `subscribe` | PASS |
| Targeted package spec evidence exists | 9 examples, 0 failures in prior Gate 2 ratification track | PASS |
| Report-only package mapping exists | `descriptor-compatibility-package-consumption-v0` | PASS |
| BiHistory warning is preserved | value index + package-consumption track | PASS |
| Gate 3 remains closed | agent context/current status | PASS |

No new package code is required for ratification.

---

## Report Metadata Semantics

Descriptor metadata may contribute to:

```text
CompatibilityReport.backend_check.temporal_backend_descriptor
```

It may support report decisions such as:

```text
trusted_metadata
provisional_metadata
blocked
```

Those decisions remain report-only. They are not equivalent to:

```text
CompatibilityReport.overall: trusted for execution
RuntimeMachine.evaluate(...)
Ledger temporal read success
checkpoint/resume correctness
physical BiHistory serving
```

`schema_check` remains independent from descriptor metadata. A schema
fingerprint mismatch can be recorded by descriptor diagnostics, but schema
compatibility decisions still belong to the schema compatibility path.

---

## BiHistory Warning

[D] Preserve this warning in any downstream package-consumption slice:

```text
Descriptor bihistory_read is metadata evidence only.
It does not prove the native data plane physically serves BiHistory at(vt:, tt:).
```

The descriptor can say a package has metadata shape compatible with
`bihistory_read`; it cannot prove indexed valid-time access, bitemporal
`at(vt:, tt:)`, replay fidelity, or transaction/valid-time serving behavior.

---

## Next Safe Slice If Ratified

If Architect Supervisor later records Gate 2 as ratified, the next safe
package-consumption slice is:

```text
compatibility-report-package-descriptor-consumption-v0
```

Safe scope for that slice:

- consume `TBackendAdapterDescriptor#to_h` and/or
  `TBackendAdapterDescriptor#diagnostics(requirement)`;
- write report-only `backend_check.temporal_backend_descriptor`;
- keep `report_only: true`;
- keep `runtime_enforced: false`;
- preserve evidence links and non-authorization flags;
- include blocked diagnostics for missing hash, op, hook, capability, axis,
  schema mismatch, bad TEMPORAL cache policy, and attempted operational use.

Unsafe scope for that slice:

- no Ledger read/write/replay;
- no live adapter;
- no RuntimeMachine TEMPORAL evaluation;
- no Gate 3 runtime binding.

---

## Verification

This is a docs-only decision track. No package specs were rerun in this slice;
the ratification evidence references the prior targeted package result:

```text
packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
-> 9 examples, 0 failures
```

---

## Handoff

```text
Card: S3-R8-C3-G
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: descriptor-gate2-ratification-decision-v0
Status: ratify-recommended

[D] Decisions
- Recommend formal Gate 2 ratification for metadata-only descriptor exposure.
- Descriptor metadata can be trusted only as report metadata.
- Gate 3 remains closed for live Ledger/runtime operations.

[S] Signals
- Gate 1 proof-local consumption PASS and Gate 2 package exposure evidence are
  sufficient for ratification.
- Package-consumption mapping is already defined as report-only.
- BiHistory capability remains metadata evidence, not physical serving proof.

[T] Tests / Proofs
- Docs-only slice; no package tests rerun.
- Prior Gate 2 evidence: targeted package descriptor spec -> 9 examples,
  0 failures.

[R] Risks / Recommendations
- Do not allow `trusted_metadata` to become runtime authority.
- Do not infer physical BiHistory serving from descriptor capability.
- If Architect ratifies Gate 2, open
  compatibility-report-package-descriptor-consumption-v0 as the next safe
  metadata-only slice.

[Next] Suggested next slice
- Architect Supervisor records Gate 2 as ratified or redirects the decision.
```
