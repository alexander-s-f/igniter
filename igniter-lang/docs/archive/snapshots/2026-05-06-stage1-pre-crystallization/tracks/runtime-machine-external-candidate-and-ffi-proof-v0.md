# Track: Runtime Machine External Candidate and FFI Proof v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice connects two next proof surfaces:

1. an external bridge/package candidate that can emit artifacts accepted by
   `packet_builder_check.rb --profile-mode selected_profile`;
2. Ruby host calls treated as declared ESCAPE FFI contracts, not ambient Ruby
   calls.

It is not a package integration and not a production API claim. It defines the
admission contract that future package work must satisfy before touching
package code.

## Source Horizon

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/runtime-machine-proof-sidecar-profile-modes-v0.md`
- `igniter-lang/docs/proposals/PROP-012-compilation-artifact-deployment-model-v0.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/`

## Compact Claim

[D] The next bridge/package proof target is not "call package code". It is:

```text
external candidate output
  -> normalize into selected_profile artifact directory
  -> packet_builder_check.rb --profile-mode selected_profile
  -> admission pass
  -> only then consider package integration
```

[D] Ruby FFI is ESCAPE until proven contractable:

```text
FFIRequirement
  + explicit capabilities
  + declared effects
  + typed inputs/outputs
  + lifecycle
  + receipt_or_failure observation
  + evidence links
  -> usable ESCAPE

ambient Ruby call
  -> OOF
```

## Part 1: External Candidate Adapter v0

### Candidate Directory Shape

An external candidate must emit a directory with the same required artifact
set as the memory proof fixtures:

```text
candidate/
  manifest.json
  obs_packets.golden.json
  semantic_image.golden.json
  compatibility_reports.golden.json
  negative_evidence.golden.json
  result_summary.golden.json

  external_ref_map.json        # optional, non-admission diagnostic
  adapter_diagnostics.json     # optional, non-admission diagnostic
```

The current checker requires the five golden-named artifact files and
`manifest.json`. Extra files may exist, but they are not trusted admission
evidence in v0.

### Required Selected Packets

For `selected_profile`, `obs_packets.golden.json` must have:

```text
payload:
  profile_mode: selected_profile
  selected:
    dispatch_candidate_value
    resumed_dispatch_candidate_value
    semantic_image_packet
    trusted_compatibility_report_packet
```

`sessions.session_a` and `sessions.session_b` are optional. If present, the
checker validates their packet entries. If absent, the selected packet surface
is still mandatory.

### Normalization Rules

[D] v0 normalization happens before writing the required artifact files.
The current checker compares selected packets exactly against the golden
selected surface, so bridge/package-specific fields must not leak into the
canonical artifact payload unless the checker profile is explicitly extended.

Normalize:

- JSON key order and hash inputs through canonical serialization.
- Ruby/package class names into stable `ffi_id` or descriptor refs.
- Host object ids into stable semantic ids such as `order/O-100` or
  `technician/T-7`.
- Wall-clock transaction details into explicit `temporal` fields or optional
  diagnostics, never ambient payload drift.
- External source refs into `external_ref_map.json` when useful for human
  review.

Do not normalize away:

- missing evidence links;
- mismatched result hash meaning;
- failed compatibility dimensions;
- undeclared effects;
- capability denial.

### What May Differ

External raw data may differ before normalization:

- source system ids and host class names;
- raw receipt ids;
- packet capture timestamps in optional session logs;
- adapter diagnostics;
- optional external reference maps;
- absence of full session logs.

External canonical artifacts may differ only where the checker permits it.
In the current v0 checker, `selected_profile` permits a smaller `obs_packets`
payload, but selected packet content and result hash still compare to the
golden fixtures.

### What Must Never Differ

The adapter must never weaken:

- `read_from`, `executed_by`, `produced_in`, and required evidence link
  meanings;
- result hash meaning: same hash means same typed result under the same
  semantic horizon, not merely same display value;
- SemanticImage identity rules: `content_hash` and `image_id` derive from
  canonical image content;
- CompatibilityReport decisions: trusted, downgraded, and blocked outcomes
  must derive from report checks;
- negative evidence: false reproducibility must remain provisional or blocked;
- packet identity rules: packet id derives from kind, subject, payload hash,
  temporal context, and links.

### Admission Criteria

Before any package integration, an external candidate must:

1. produce the required candidate directory without editing package code;
2. pass:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb \
  --profile-mode selected_profile \
  --candidate <candidate-dir>
```

3. include a human-reviewable normalization map if source refs differ from the
   memory proof names;
4. preserve negative evidence fixtures;
5. document every semantic substitution before it reaches the canonical
   artifact files;
6. stay blocked from `full_log` until it can emit complete replay/session logs.

## Part 2: FFI Ruby Contractable Proof v0

### FFI Law

[D] A Ruby host call is not a function call from the language's point of view.
It is an ESCAPE contract boundary:

```text
Typed input
  -> capability gate
  -> declared Ruby host call
  -> typed result | declared failure
  -> receipt/failure observation
  -> value or action evidence links
```

The Runtime Machine owns capability checks, lifecycle, observations, and
evidence. Ruby owns only the host operation behind the declared boundary.

### Read-Only Ruby FFI Example

Informative, non-final syntax:

```text
external ruby SparkCRM::OrderLookup do
  ffi_id "spark.order_lookup.v0"
  input  :order_id, OrderId
  output :order, OrderSnapshot
  effects :read
  capability :orders_read
  lifecycle :session
  failures :not_found, :permission_denied, :timeout
end
```

Successful read evidence shape:

```json
{
  "id": "obs/ffi_order_lookup_fact",
  "kind": "fact_observation",
  "subject": "ffi://ruby/spark.order_lookup.v0/order/O-100",
  "payload": {
    "ffi_id": "spark.order_lookup.v0",
    "effect": "read",
    "result_type": "OrderSnapshot",
    "lifecycle": "session",
    "external_ref": "spark://orders/O-100"
  },
  "payload_hash": "sha256:<canonical-payload>",
  "temporal": {
    "as_of": "2026-05-05T10:00:00Z",
    "rule_version": "rule-v3",
    "fact_scope": "spark/order/O-100"
  },
  "links": [
    { "rel": "executed_by", "ref": "runtime/ffi_executor/ruby", "required": true },
    { "rel": "produced_in", "ref": "execution_environment/dev", "required": true },
    { "rel": "read_from", "ref": "external:spark://orders/O-100", "required": true }
  ]
}
```

The returned contract value links `read_from` this fact observation and
`executed_by` the runtime evaluator. It is not trusted if the external read is
returned as a raw Ruby value without the fact observation.

### Write/Receipt Ruby FFI Example

Informative, non-final syntax:

```text
external ruby SparkCRM::AssignTechnician do
  ffi_id "spark.assign_technician.v0"
  input  :order_id, OrderId
  input  :technician_id, TechnicianId
  output :assignment_receipt, AssignmentReceipt
  effects :write
  capability :dispatch_assign
  lifecycle :durable
  audit true
  failures :conflict, :permission_denied, :timeout
end
```

Successful write receipt shape:

```json
{
  "id": "obs/ffi_assignment_receipt",
  "kind": "receipt_observation",
  "subject": "ffi://ruby/spark.assign_technician.v0/order/O-100",
  "payload": {
    "ffi_id": "spark.assign_technician.v0",
    "effect": "write",
    "receipt_type": "AssignmentReceipt",
    "order_id": "O-100",
    "technician_id": "T-7",
    "idempotency_key": "dispatch/O-100/T-7/rule-v3",
    "lifecycle": "audit",
    "status": "committed"
  },
  "payload_hash": "sha256:<canonical-payload>",
  "temporal": {
    "as_of": "2026-05-05T10:00:00Z",
    "rule_version": "rule-v3",
    "fact_scope": "spark/order/O-100"
  },
  "links": [
    { "rel": "caused_by", "ref": "obs/dispatch_decision_pinned", "required": true },
    { "rel": "read_from", "ref": "obs/resumed_dispatch_candidate_value", "required": true },
    { "rel": "executed_by", "ref": "runtime/ffi_executor/ruby", "required": true },
    { "rel": "produced_in", "ref": "execution_environment/server", "required": true }
  ]
}
```

`audit true` upgrades the receipt lifecycle from durable business fact to
audit-preserved action evidence. The host write is not meaningful unless the
receipt exists and links back to the decision that caused it.

### Capability Checks

FFI capability checks happen at three levels:

1. `CompiledProgram.load` verifies that required capabilities are declared.
2. `RuntimeMachine.evaluate` verifies that the session/request grants them.
3. The FFI executor checks the specific capability immediately before the host
   call.

Missing capability emits `failure_observation` and must not call Ruby.

### Failure Observation Shape

```json
{
  "id": "obs/ffi_capability_denied",
  "kind": "failure_observation",
  "subject": "ffi://ruby/spark.assign_technician.v0/order/O-100",
  "payload": {
    "reason_code": "capability.denied",
    "ffi_id": "spark.assign_technician.v0",
    "effect": "write",
    "required_capability": "dispatch_assign",
    "lifecycle": "session",
    "retryable": false
  },
  "payload_hash": "sha256:<canonical-payload>",
  "temporal": {
    "as_of": "2026-05-05T10:00:00Z",
    "rule_version": "rule-v3",
    "fact_scope": "spark/order/O-100"
  },
  "links": [
    { "rel": "caused_by", "ref": "obs/dispatch_decision_pinned", "required": true },
    { "rel": "read_from", "ref": "descriptor/ffi/spark.assign_technician.v0", "required": true },
    { "rel": "executed_by", "ref": "runtime/ffi_executor/ruby", "required": true },
    { "rel": "produced_in", "ref": "execution_environment/server", "required": true }
  ]
}
```

Failure is part of the contract result, not an ambient exception. A Ruby
exception with no failure observation is OOF.

### Lifecycle Choice

```text
raw Ruby return       -> T.local     until wrapped as observation
read fact/value       -> T.session   by default
write receipt         -> T.durable   by default
audit write receipt   -> T.audit
capability failure    -> T.session   unless policy requires audit
conflict after write  -> T.audit     if it changes action rights
```

### Evidence Links

Minimum links:

- `executed_by`: runtime evaluator or FFI executor.
- `produced_in`: execution environment observation.
- `read_from`: source observation, external fact, selected candidate, or
  descriptor read.
- `caused_by`: command, decision, pinned projection, or prior receipt that
  authorized the FFI call.

Write receipts require `caused_by`. Read-only FFI may omit `caused_by` only
when it is a pure lookup inside an evaluation request; the returned value still
needs `read_from`.

### OOF Cases

[X] Undeclared Ruby host call.

[X] Ruby adapter calls `Time.now`, random, network, filesystem, or global state
without declaring the effect and temporal source.

[X] Read-only FFI performs a write, enqueue, notification, mutation, or cache
invalidation.

[X] Write FFI has no idempotency key or no receipt observation.

[X] Ruby exception is swallowed into `nil` or `false` without a
`failure_observation`.

[X] Capability check happens after the host call.

## Risks

- Current `selected_profile` comparison is intentionally strict. Real package
  candidates may need a future profile that compares normalized equivalence
  instead of exact selected packet equality.
- Optional diagnostic files are human aids only; v0 checker does not trust
  them.
- Ruby FFI receipts can leak PII unless payloads separate semantic refs from
  private raw fields.
- Capability names and lifecycle policy need a shared registry before package
  integration.
- Audit retention can conflict with privacy deletion rules; policy must be
  explicit before durable adapters.

## Rejected Paths

[X] Accept package output because it "looks close" without passing
`selected_profile`.

[X] Let bridge/package candidates skip negative evidence fixtures.

[X] Treat Ruby method calls as implementation details outside the observation
model.

[X] Use `receipt_observation` as a loose log line. A receipt is action evidence
with typed payload, lifecycle, and required links.

[X] Add package integration before admission rules are executable.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-external-candidate-and-ffi-proof-v0.md
Status: done

[D] Decisions:
- External candidates target `selected_profile` first.
- The required artifact directory remains the memory proof artifact set:
  manifest, obs_packets, semantic_image, compatibility_reports,
  negative_evidence, and result_summary.
- v0 normalization must happen before canonical artifact emission.
- Ruby FFI is ESCAPE only when declared, typed, capability-gated,
  lifecycle-scoped, and observation-producing.
- Undeclared or ambient Ruby calls are OOF.

[R] Recommendations:
- Build a standalone external-candidate normalizer fixture before package
  integration.
- Keep optional source maps outside trusted admission evidence until the
  checker consumes them.
- Model Ruby write calls through receipt observations with idempotency keys.
- Require failure observations for denied capabilities and host exceptions.

[S] Signals:
- `selected_profile` is a bridge-admission boundary, not a weaker proof.
- FFI proof and external candidate proof share one rule: no result earns trust
  without evidence links.

[Q] Open Questions:
- Should the next checker profile support normalized equivalence rather than
  exact selected packet equality?
- Should `intent_observation` become a first-class Obs kind, or remain a
  platform/descriptor observation in v0?
- Which capability registry owns names like `orders_read` and
  `dispatch_assign`?

[Next] Proposed next slice:
- `runtime-machine-external-candidate-normalizer-fixtures-v0`
  Add a tiny standalone external candidate directory plus normalizer/check
  fixture that passes `selected_profile` without package edits.
```
