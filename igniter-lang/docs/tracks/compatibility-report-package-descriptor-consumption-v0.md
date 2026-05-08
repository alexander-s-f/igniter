# Track: CompatibilityReport Package Descriptor Consumption v0

Card: S3-R10-C3-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `compatibility-report-package-descriptor-consumption-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Gate Authority

Source authority:

```text
descriptor-gate2-architect-ratification-record-v0
```

Gate 2 is ratified for metadata-only package descriptor exposure. The trusted
surface is descriptor metadata only, not runtime authority.

This track consumes ratified package descriptor-shaped metadata into a
`CompatibilityReport`-shaped payload as report-only evidence.

---

## Implemented Proof

Added proof-local fixture:

```text
igniter-lang/experiments/compatibility_report_package_descriptor_consumption/
  compatibility_report_package_descriptor_consumption.rb
  compatibility_report_package_descriptor_consumption_summary.json
```

The fixture does not require or instantiate `packages/igniter-ledger` code. It
uses a package-shaped descriptor payload matching the ratified Gate 2 surface.
It makes no Ledger call, performs no temporal read, creates no live adapter, and
does not open Gate 3.

---

## Report Shape

The proof emits:

```json
{
  "kind": "proof_local_compatibility_report",
  "card": "S3-R10-C3-P",
  "gate": "gate_2_ratified_metadata_only",
  "status": "report_only",
  "schema_check": {
    "decision": "not_evaluated_here",
    "independent_from_backend_descriptor": true
  },
  "backend_check": {
    "decision": "trusted_metadata",
    "report_only": true,
    "runtime_enforced": false,
    "temporal_backend_descriptor": {}
  },
  "non_authorization": {
    "live_package_binding": false,
    "runtime_binding": false,
    "ledger_calls": false,
    "ledger_reads": false,
    "ledger_writes": false,
    "ledger_replay": false,
    "temporal_reads": false,
    "live_adapter": false,
    "gate_3_opened": false
  }
}
```

`schema_check` remains independent. Descriptor diagnostics may record schema
fingerprint match/mismatch, but schema compatibility remains owned by the schema
compatibility path.

---

## Preserved Descriptor Evidence

`backend_check.temporal_backend_descriptor` preserves:

- `source: ratified_package_descriptor_metadata`
- `package_class: Igniter::Store::TBackendAdapterDescriptor`
- `package_alias: Igniter::Ledger::TBackendAdapterDescriptor`
- descriptor kind and adapter kind
- `descriptor_hash`
- `descriptor_registry_hash`
- required and supported TBackend ops
- required and present hook methods
- required and present capabilities
- required and present axes
- `cursor_policy`
- package descriptor diagnostics
- descriptor shape diagnostics
- diagnostics shape diagnostics
- TEMPORAL cache policy diagnostics
- non-authorization diagnostics
- evidence links for descriptor and registry hashes
- package `non_authorization` flags

Required flags are forced on every report:

```json
{
  "report_only": true,
  "runtime_enforced": false
}
```

---

## Decision Rules

`trusted_metadata` requires:

- ratified Gate 2 descriptor shape;
- `descriptor_hash`;
- `descriptor_registry_hash`;
- valid package descriptor diagnostics;
- diagnostics status `ok`;
- required ops, hooks, capabilities, and axes;
- valid cursor policy;
- TEMPORAL cache policy for TEMPORAL contracts;
- all package `non_authorization` flags false.

`blocked` is emitted when metadata is missing or malformed.

The fixture blocks:

- missing `descriptor_hash`;
- missing `descriptor_registry_hash`;
- missing `bihistory_read`;
- missing `transaction_time`;
- missing `cursor_policy`;
- missing package diagnostics;
- malformed package diagnostics;
- non-authorization violation;
- CORE cache policy for TEMPORAL contract (`OOF-TM9`);
- malformed descriptor kind.

---

## BiHistory Warning

Every report carries this warning:

```text
descriptor bihistory_read is metadata evidence only; it does not prove physical BiHistory at(vt:, tt:) serving
```

This preserves the required distinction:

```text
descriptor claim != physical at(vt:, tt:) proof
```

Gate 2 ratification makes the descriptor claim trusted report metadata. It does
not prove the native data plane can serve bitemporal reads.

---

## Non-Authorization

This proof does not authorize:

- live package binding;
- live Ledger-backed adapter;
- Ledger read, write, append, replay, compact, or subscribe;
- temporal reads;
- RuntimeMachine TEMPORAL evaluation;
- production CompatibilityReport enforcement;
- `runtime_enforced: true`;
- migration execution;
- Gate 3.

Gate 3 remains closed.

---

## Proof Results

Command:

```bash
ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb
```

Observed result:

```text
PASS trusted package descriptor is trusted_metadata
PASS descriptor hashes are preserved
PASS capabilities axes cursor policy diagnostics are preserved
PASS non_authorization flags are preserved
PASS BiHistory warning is present
PASS missing_descriptor_hash is blocked
PASS missing_registry_hash is blocked
PASS missing_capability is blocked
PASS missing_axis is blocked
PASS missing_cursor_policy is blocked
PASS missing_package_diagnostics is blocked
PASS malformed_package_diagnostics is blocked
PASS non_authorization_violation is blocked
PASS bad_cache_policy is blocked
PASS malformed_descriptor_kind is blocked
PASS all reports are report-only and not runtime-enforced
PASS proof does not authorize package binding, ledger calls, temporal reads, or Gate 3
PASS summary written igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption_summary.json
```

Syntax check:

```text
ruby -c igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb
-> Syntax OK
```

---

## Handoff

```text
Card: S3-R10-C3-P
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: compatibility-report-package-descriptor-consumption-v0
Status: done

[D] Decisions
- Consumed ratified Gate 2 descriptor metadata into report-only
  backend_check.temporal_backend_descriptor.
- Forced report_only: true and runtime_enforced: false.
- Missing or malformed descriptor metadata blocks.
- Descriptor BiHistory capability remains metadata, not physical serving proof.

[S] Signals
- Trusted package-shaped descriptor payload becomes trusted_metadata.
- Hashes, capabilities, axes, cursor policy, diagnostics, evidence links, and
  non_authorization flags are preserved.
- No package binding, Ledger call, temporal read, or Gate 3 behavior occurs.

[T] Tests / Proofs
- ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb -> PASS
- ruby -c igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb -> Syntax OK

[R] Risks / Recommendations
- Do not treat trusted_metadata as runtime authority.
- Do not infer physical BiHistory serving from descriptor capability.
- Any live adapter or temporal execution remains a separate Gate 3 approval.

[Next] Suggested next slice
- Package Agent may adopt the report-only shape only if it preserves
  runtime_enforced: false and no live Ledger/runtime binding.
```
