# Track: PROP-005 Temporal Read Observation v0

Card: S3-R13-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/prop-005-temporal-read-observation-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Define the minimum structured observation emitted by every authorized live
`History[T]` read.

This turns AT-10 from "structured observation" into a concrete proofable
envelope. It does not add live TBackend evaluation.

---

## Current Horizon

Gate 3 is ready for Architect review but remains closed. The Gate 3 decision
record requires a temporal read observation envelope before any Phase 1 live
read executes.

AT-10 is unconditional:

```text
Every authorized live History[T] read emits a structured observation record.
```

Persistence is proof-local until a separate persistence/audit track lands.

---

## Minimum Envelope

[D] The minimum observation kind is:

```text
temporal_read_observation
```

[D] The minimum shape is:

```json
{
  "kind": "temporal_read_observation",
  "format_version": "0.1.0",
  "observation_id": "obs/history-read/<id>",
  "emitted_at": "2026-05-09T12:00:00Z",
  "operation": "history_read_as_of",
  "fragment_class": "TEMPORAL",
  "contract": {
    "contract_id": "TechnicianJobCountAt",
    "contract_ref": "contract/TechnicianJobCountAt/sha256:..."
  },
  "store": {
    "store_ref": "tbackend/memory-history/proof-local",
    "store_kind": "MemoryHistoryBackend",
    "descriptor_ref": "descriptor/tbackend/history-read/proof-local"
  },
  "temporal": {
    "axis": "valid_time",
    "as_of": "2026-05-03T00:00:00Z",
    "valid_time": "2026-05-03T00:00:00Z"
  },
  "authorization": {
    "approval_ref": "approval/2026-05-09/gate3/history-phase1/proof-001",
    "gate_ref": "gate3-decision-record-v0#phase1-history-valid-time",
    "authority_ref": "architect-supervisor/proof-authority"
  },
  "evidence": {
    "compatibility_report_ref": "compatibility-report/history-phase1/proof-001",
    "executor_approval_token_ref": "approval/2026-05-09/gate3/history-phase1/proof-001",
    "cache_key_ref": "cache-key/temporal/history-valid-time/proof-001"
  },
  "result": {
    "status": "selected",
    "value": { "kind": "some", "value": 7 },
    "value_type": "Integer",
    "selected_observation_ref": "append/history/jobs-count/tech-1/2026-05-01"
  },
  "persistence": {
    "mode": "proof_local",
    "persisted": false,
    "audit_receipt_ref": null
  }
}
```

[D] Minimum required paths:

```text
kind
format_version
observation_id
contract.contract_id
contract.contract_ref
store.store_ref
temporal.axis
temporal.as_of
temporal.valid_time
authorization.approval_ref
authorization.gate_ref
evidence.executor_approval_token_ref
result.status
result.value
```

[D] `temporal.axis` is `valid_time` for this Phase 1 envelope. BiHistory is
not included.

[D] `result.status` is one of:

```text
selected | none | refused | error
```

[D] `result.value` uses canonical Option encoding:

```json
{ "kind": "some", "value": 7 }
{ "kind": "none" }
```

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/temporal_read_observation_proof/
  temporal_read_observation_proof.rb
  out/temporal_read_observation_proof_summary.json
```

The proof validates:

- positive `selected` observation;
- positive `none` observation;
- canonical Option encoding;
- proof-local persistence only;
- no live TBackend eval in the proof;
- negative rejection for missing kind, contract ref, store ref, `as_of`,
  approval ref, gate ref, token ref, result status, bad status, and
  non-canonical Option encoding.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/temporal_read_observation_proof/temporal_read_observation_proof.rb
```

Observed output:

```text
PASS temporal_read_observation_proof
positive.selected_read_observation_valid: ok
positive.none_read_observation_valid: ok
positive.option_encoding_canonical: ok
positive.persistence_is_proof_local: ok
positive.no_live_tbackend_eval: ok
negative.required_fields_rejected: ok
summary: igniter-lang/experiments/temporal_read_observation_proof/out/temporal_read_observation_proof_summary.json
```

Syntax check:

```text
ruby -c igniter-lang/experiments/temporal_read_observation_proof/temporal_read_observation_proof.rb -> Syntax OK
```

---

## Remaining Runtime / Audit Gaps

[R] Production RuntimeMachine must emit this envelope before or around every
authorized live `History[T]` read.

[R] The observation must be connected to composed `CompatibilityReport` and
`ExecutorApprovalToken` validation.

[R] Production persistence and audit receipts remain separate from emission and
are not solved here.

[R] A live TBackend adapter must attach the actual store/descriptor reference
and selected append observation.

[R] BiHistory, Ledger replay, writes, streams, OLAP, and invariant persistence
remain out of scope.

---

## Non-Authorization

[X] No live TBackend evaluation.

[X] No Ledger read/write/replay.

[X] No production persistence.

[X] No invariant persistence.

[X] No BiHistory observation shape.

[X] No Gate 3 opening.

---

## Handoff

```text
Card: S3-R13-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop-005-temporal-read-observation-v0
Status: done

[D] Decisions
- `temporal_read_observation` is the minimum AT-10 observation kind.
- Phase 1 shape is History[T] valid_time only.
- Required paths include contract, store, as_of/valid_time, approval, gate,
  token, and result status/value.
- Persistence remains proof-local and separate from emission.

[S] Shipped / Signals
- Added temporal_read_observation_proof experiment and summary JSON.
- Positive selected/none observations pass.
- Missing required fields and non-canonical Option encoding are rejected.

[T] Tests / Proofs
- ruby -c temporal_read_observation_proof.rb -> Syntax OK
- ruby temporal_read_observation_proof.rb -> PASS

[R] Risks / Recommendations
- Production RuntimeMachine must bind this envelope to live History[T] reads
  before Phase 1 live eval.
- CompatibilityReport composition and audit persistence remain separate tracks.

[Next] Suggested next slice
- compatibility-report-composition-v0, or
  runtime-report-enforcement-preflight-v0.
```
