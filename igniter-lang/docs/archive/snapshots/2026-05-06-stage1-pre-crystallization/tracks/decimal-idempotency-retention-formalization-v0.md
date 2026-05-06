# Track: Decimal Idempotency Retention Formalization v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/decimal-idempotency-retention-formalization-v0
Status: done
Date: 2026-05-06
Resolves: CG-2 (Decimal), CG-3 (idempotency), CG-5 (retention)
Pressure sources: spark-crm-real-business-candidate-map-v0, spark-crm-applied-language-pressure-v0

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — receives fixture acceptance criteria for
  lead-signal boundary proof (RA-2 from candidate-map), idempotency proof,
  and RetentionReceipt proof.
- `[Igniter-Lang Bridge Agent]` — receives Decimal serialization shape and
  IdempotencyKey evidence link shape for metadata-only adapter maps.

---

## Part 1: Decimal / Money Value Semantics

### Decision

**`[D] Decimal is a v0 base type: `Decimal[scale: Integer]`.**

It is not a trait-bound numeric type. It is not Float. It is not a host-policy escape. It is a first-class value type with explicit scale.

### Rationale

Spark CRM bid amounts, thresholds, and lead aggregates are compared in business-critical decisions. Float arithmetic introduces rounding drift that changes acceptance outcomes (e.g. `0.1 + 0.2 != 0.3`). Decimal with explicit scale is the correct model.

```text
Decimal[scale: Integer] = {
  coefficient: Integer   -- unscaled integer value
  scale:       Integer   -- number of decimal places (>= 0)
  -- value = coefficient / 10^scale
  -- Example: Decimal[scale:2] representing $12.50 -> coefficient=1250, scale=2
}
```

### Arithmetic axioms

```text
-- Addition/subtraction: require same scale (compile-time check)
add(Decimal[scale:S], Decimal[scale:S]) -> Decimal[scale:S]
sub(Decimal[scale:S], Decimal[scale:S]) -> Decimal[scale:S]

-- Multiplication: output scale = left_scale + right_scale
mul(Decimal[scale:A], Decimal[scale:B]) -> Decimal[scale: A+B]

-- Division: prohibited in CORE without explicit scale declaration
--   division may produce infinite decimal expansion
--   div(Decimal[scale:A], Decimal[scale:B]) is ESCAPE unless
--   the caller declares: result_scale and rounding_mode

-- Comparison: same scale only
lt(Decimal[scale:S], Decimal[scale:S]) -> Bool   -- CORE
eq(Decimal[scale:S], Decimal[scale:S]) -> Bool   -- CORE
```

### Scale coercion

```text
rescale(d: Decimal[scale:A], target_scale: Integer, rounding: RoundingMode)
  -> Decimal[scale: target_scale]

-- CORE if rounding_mode is a literal (declared at call site).
-- ESCAPE if rounding_mode comes from a TBackend read.
-- OOF if rounding_mode is ambient or missing.

RoundingMode = :half_up | :half_even | :floor | :ceiling | :truncate
```

**[D] Comparing Decimal values of different scales is OOF-DM1 (scale mismatch).** The compiler rejects `Decimal[scale:2] == Decimal[scale:4]` without an explicit `rescale` call.

### Serialization

```text
-- Canonical serialization form:
Decimal.to_string(d: Decimal[scale:S]) -> String
  -- "coefficient.scaled" format: e.g. "12.50", "0.30"
  -- always emits exactly S decimal digits (no stripping trailing zeros)
  -- CORE-safe: pure function

-- JSON wire form for observations and packets:
{
  "kind": "decimal",
  "coefficient": 1250,
  "scale": 2,
  "display": "12.50"   -- informational; not authoritative for comparison
}
```

**[D] Float is prohibited as a Decimal proxy.** `Float(12.50)` is OOF-DM2 when used in a Decimal comparison or business-evidence context. The compiler rejects implicit Float-to-Decimal coercion.

### OOF Rules (Decimal)

```text
OOF-DM1: Decimal scale mismatch in comparison or arithmetic.
  Decimal[scale:A] op Decimal[scale:B] where A != B and no rescale.
  -> compile error (Pass 1 type check).

OOF-DM2: Float used as Decimal proxy.
  A Float value appearing in a compute node whose output type is Decimal.
  -> compile error (Pass 1 type check).

OOF-DM3: Division without declared result_scale.
  div(Decimal, Decimal) without result_scale and rounding_mode literals.
  -> compile error (Pass 0 OOF detection).

OOF-DM4: Ambient rounding mode.
  RoundingMode sourced from TBackend or host global without explicit declaration.
  -> ESCAPE escalation + warning (not a compile error; rounding policy is a valid
     runtime input, but must be explicit).
```

---

## Part 2: IdempotencyKey Semantics

### Decision

**`[D] IdempotencyKey is a deterministic CORE value computed over a bounded, canonicalized input record.**

It is NOT a random token. It is NOT host-generated. It is a content-addressed hash of canonical input fields.

```text
IdempotencyKey = {
  value:     String          -- hex or base64 hash
  algorithm: :sha256 | :sha3_256
  input_ref: ObsId           -- the observation whose payload was hashed
  fields:    Collection[String]  -- field names that were included in the hash
  canonical_form: String     -- the serialized input used to compute the hash
}
```

### Canonicalization rules

```text
canonical_form(record: R, fields: Collection[String]) -> String

Rules:
  1. Extract only the listed fields from record.
  2. Sort fields alphabetically.
  3. Serialize each field value in canonical form:
     - String: UTF-8, no surrounding quotes
     - Integer: decimal representation, no leading zeros
     - Decimal[scale:S]: "coefficient/scale" form (unambiguous)
     - Symbol: ":<name>" form
     - nil: empty string (not "null" or "nil")
  4. Join as "field1=value1\nfield2=value2\n..." (sorted by field name)
  5. Hash the UTF-8 bytes.

-- CORE-safe: pure function, deterministic, no ambient IO.
```

**[D] `Random.alphanumeric(8)` (from Spark marketing executor) is OOF-IK1** unless explicitly modeled as an ESCAPE effect with a receipt and idempotency policy (e.g. retry returns the same token).

### IdempotencyKey computation

```text
def compute_idempotency_key(
  record: R,
  fields: Collection[String],
  algorithm: :sha256 | :sha3_256
) -> IdempotencyKey
  canonical = canonical_form(record, fields)
  hash_value = hash(canonical, algorithm)   -- stdlib.hash; CORE
  IdempotencyKey {
    value:          hash_value,
    algorithm:      algorithm,
    input_ref:      current_observation_ref,   -- set by runtime
    fields:         fields,
    canonical_form: canonical
  }
}
-- Fragment: CORE if record is CORE; ESCAPE if record came from ESCAPE read.
```

### Evidence link

```text
An observation that carries an IdempotencyKey must include:
  links:
    { rel: "identified_by",  ref: idempotency_key.value }
    { rel: "derived_from",   ref: idempotency_key.input_ref }
    { rel: "observed_under", ref: runtime_contract_ref }
```

**[D] `identified_by` is the canonical link relation for idempotency keys.** It differs from `produced_by` (provenance) and `caused_by` (migration). A store or dedup layer uses `identified_by` to detect duplicate observations.

### OOF Rules (IdempotencyKey)

```text
OOF-IK1: Ambient random token used as idempotency key.
  Random.alphanumeric or similar undeclared entropy in a CORE context.
  -> OOF at Pass 0 (Law 6: ambient IO).
  -> To use random tokens: declare as ESCAPE with idempotency receipt policy.

OOF-IK2: Empty fields list for canonical_form.
  canonical_form(record, []) -> empty string -> hash collision risk.
  -> compile error (Pass 1: fields must be non-empty Collection[String]).

OOF-IK3: IdempotencyKey used without identified_by link.
  An observation claiming dedup semantics but no identified_by link.
  -> compile warning (not a hard error; idempotency is advisory in v0).
  -> Future: will become OOF when dedup store integration is active.

OOF-IK4: IdempotencyKey algorithm undeclared.
  compute_idempotency_key called without explicit algorithm literal.
  -> compile error (Pass 0): algorithm must be a declared literal symbol.
```

---

## Part 3: Duplicate Suppression Semantics

### Decision

**`[D] Three distinct suppression outcomes exist. They are not interchangeable.**

```text
1. Non-admission:
   The incoming record is identical to a previously admitted record
   (same IdempotencyKey.value in the store).
   -> The new record is NOT stored.
   -> A DuplicateNonAdmissionReceipt is emitted.
   -> No mutation occurs. No error.

2. Rejection:
   The incoming record has a valid IdempotencyKey but violates a
   business rule (e.g. closes a boundary already closed, duplicate
   pending request).
   -> The record is NOT stored.
   -> A DuplicateRejectionReceipt is emitted with failure_kind.
   -> The failure_kind is queryable for diagnostics.

3. No-op receipt:
   The incoming record is a retry of a known-idempotent ESCAPE effect
   (e.g. external API call). The effect was already executed.
   -> No new effect is triggered.
   -> An IdempotentNoOpReceipt is emitted linking to the original receipt.
```

### Receipt shapes

```text
DuplicateNonAdmissionReceipt = Obs[:platform_observation, NonAdmissionRecord]
NonAdmissionRecord = {
  kind:               :non_admission
  input_key:          IdempotencyKey
  matched_key:        String               -- the existing key that matched
  matched_obs_ref:    ObsId                -- the original observation
  temporal:           TemporalCtx
}
lifecycle: :session
links:
  { rel: "identified_by",  ref: input_key.value }
  { rel: "duplicates",     ref: matched_obs_ref }

DuplicateRejectionReceipt = Obs[:failure_observation, RejectionRecord]
RejectionRecord = {
  kind:         :duplicate_rejection
  input_key:    IdempotencyKey
  failure_kind: String    -- e.g. "boundary.already_closed", "request.already_pending"
  temporal:     TemporalCtx
}
lifecycle: :session

IdempotentNoOpReceipt = Obs[:platform_observation, NoOpRecord]
NoOpRecord = {
  kind:             :idempotent_no_op
  effect_key:       IdempotencyKey
  original_receipt: ObsId
  temporal:         TemporalCtx
}
lifecycle: :session
links:
  { rel: "replaces_effect", ref: original_receipt }
  { rel: "identified_by",   ref: effect_key.value }
```

**[D] Non-admission and rejection are CORE-observable.** They do not require ESCAPE FFI. They are the output of a CORE dedup check over a bounded store view.

**[D] No-op receipt is ESCAPE.** It requires checking the external effect store, which is a TBackend read.

---

## Part 4: RetentionReceipt Semantics

### Decision

**`[D] Retention is a semantic operation with two mandatory phases: dry-run and execution. The dry-run must produce a RetentionReceipt before execution may proceed.**

```text
RetentionDryRunReceipt = Obs[:platform_observation, DryRunRecord]
DryRunRecord = {
  kind:             :retention_dry_run
  policy_ref:       String           -- identifier of the retention policy
  policy_version:   String
  subject_pattern:  String           -- what will be deleted/compacted
  as_of:            Timestamp        -- retention applies to data before this point
  candidate_count:  Integer          -- how many records would be affected
  boundary_refs:    Collection[ObsId]  -- boundaries/snapshots that cover the data
  uncovered_refs:   Collection[ObsId]  -- data not covered by any boundary
  temporal:         TemporalCtx
}
lifecycle: :audit  (evidence of intent; irreversible)
links:
  { rel: "observed_under", ref: policy_ref }

RetentionExecutionReceipt = Obs[:platform_observation, ExecutionRecord]
ExecutionRecord = {
  kind:             :retention_execution
  dry_run_ref:      ObsId              -- mandatory; links to dry-run
  policy_ref:       String
  policy_version:   String
  subject_pattern:  String
  as_of:            Timestamp
  deleted_count:    Integer
  compacted_count:  Integer
  preserved_refs:   Collection[ObsId]  -- refs explicitly preserved by policy
  temporal:         TemporalCtx
}
lifecycle: :audit
links:
  { rel: "caused_by",      ref: dry_run_ref }
  { rel: "observed_under", ref: policy_ref }
```

### Coverage rule

**[D] `RetentionDryRunReceipt.uncovered_refs` must be empty before execution proceeds.** If any candidate records are not covered by a boundary or snapshot, the dry-run is `status: :blocked` and the execution must not be triggered.

```text
RetentionCoverageCheck:
  covered     = candidate_records ∩ union(boundary_refs.covers)
  uncovered   = candidate_records - covered
  status =
    if uncovered.empty?       then :safe_to_execute
    else                           :blocked (uncovered_refs non-empty)

OOF-RT1: Retention executed without dry-run.
  RetentionExecutionReceipt.dry_run_ref is nil.
  -> OOF (runtime machine: execution without evidence of intent).
  -> Blocked.

OOF-RT2: Retention executed when dry-run is :blocked.
  dry_run_ref resolves to a DryRunReceipt with uncovered_refs non-empty.
  -> OOF (blocked at execution gate).

OOF-RT3: Retention dry-run as_of is in the future.
  DryRunRecord.as_of > TemporalCtx.as_of.
  -> OOF-RT3: retention cannot be computed for future data.
  -> compile warning (if as_of is a literal); runtime rejection.

OOF-RT4: Boundary refs in dry-run are not T.compacted or T.audit.
  A boundary_ref pointing to a T.session or T.window observation.
  -> OOF-RT4: only compacted or audit observations provide permanent coverage.
  -> compile warning.
```

### Preserved refs semantics

**[D] `preserved_refs` are ObsIds explicitly named by the policy as must-survive.** They are NOT deleted or compacted. They appear in the execution receipt so an auditor can verify what was kept.

---

## Part 5: Late Boundary Reopen Semantics

### Decision

**`[D] Three and only three responses to a late arrival at a closed boundary exist in v0:**

```text
1. Blocked (default):
   The late signal/record is rejected.
   A LateBoundaryRejectionReceipt is emitted.
   The boundary is NOT reopened.
   The existing BoundaryReceipt is NOT modified.

2. BoundaryReopenReceipt (explicit reopen):
   A privileged actor explicitly requests a reopen.
   A BoundaryReopenReceipt is emitted BEFORE any late data is admitted.
   The reopen is policy-gated: requires capability declaration.
   The BoundaryReopenReceipt links to the original BoundaryReceipt.
   The late record is admitted under the reopened boundary.
   A new BoundaryCloseReceipt is emitted after reopen window closes.

3. Migration-style replacement (for schema-driven late arrivals):
   Used when the late arrival exists because of a schema change, not
   because the signal was delayed.
   Governed by PROP-017 migration receipts and replacement SemanticImage.
   This is the "correction" path, not the "late signal" path.
```

### Receipt shapes

```text
LateBoundaryRejectionReceipt = Obs[:platform_observation, LateRejectRecord]
LateRejectRecord = {
  kind:              :late_boundary_rejection
  boundary_ref:      ObsId      -- the closed boundary
  arrival_as_of:     Timestamp  -- when the late record arrived
  boundary_closed_at: Timestamp
  lateness_seconds:  Integer    -- arrival_as_of - boundary_closed_at
  signal_ref:        ObsId | nil  -- the late signal, if identifiable
}
lifecycle: :audit   (permanent evidence of rejection)
links:
  { rel: "caused_by", ref: signal_ref } | nil
  { rel: "blocked_by", ref: boundary_ref }

BoundaryReopenReceipt = Obs[:platform_observation, ReopenRecord]
ReopenRecord = {
  kind:               :boundary_reopen
  original_boundary:  ObsId      -- the boundary being reopened
  policy_ref:         String     -- the reopen policy authorization
  capability_ref:     ObsId      -- capability that granted the reopen
  reopen_window_end:  Timestamp  -- new deadline for late admissions
  reason:             String
  actor_ref:          ObsId | nil
  temporal:           TemporalCtx
}
lifecycle: :audit
links:
  { rel: "caused_by",    ref: original_boundary }
  { rel: "authorized_by", ref: capability_ref }
```

### OOF Rules (Late Boundary)

```text
OOF-LB1: Late record admitted to closed boundary without BoundaryReopenReceipt.
  -> OOF: data admitted outside boundary semantics.
  -> Blocked at store write gate.

OOF-LB2: BoundaryReopenReceipt emitted without capability_ref.
  -> compile error: reopen requires declared capability gate.

OOF-LB3: BoundaryReopenReceipt.reopen_window_end in the past.
  A reopen receipt with a deadline that has already passed.
  -> runtime rejection: no late records may be admitted.

OOF-LB4: Migration-style replacement used for a genuinely late signal.
  A replacement SemanticImage (PROP-017) used for a signal that is late
  due to network delay, not schema change.
  -> OOF-LB4: misuse of migration path.
  -> compile warning when static analysis can detect; runtime advisory otherwise.
```

---

## Part 6: What Must Be Resolved Before SemanticIR

```text
[GATE] The following must be resolved at TypedProgram (Pass 1) before
       a contract lowers to SemanticIR:

G-1: All Decimal types in compute nodes must have explicit scale.
     A Decimal without declared scale is a type error.

G-2: All IdempotencyKey computations must have:
     (a) a non-empty fields list (statically known), and
     (b) a declared algorithm literal.

G-3: All RetentionReceipt emissions must reference a DryRunReceipt
     (dry_run_ref must be a statically-known ref, not nil).

G-4: All BoundaryReopenReceipt emissions must reference a capability_ref.

G-5: Decimal comparisons must have matching scales.
     Rescale calls must declare rounding_mode as a literal.

G-6: Float-to-Decimal coercion is prohibited in compute nodes.
     A Float literal or Float-typed input used where Decimal is required
     is a type error at Pass 1.
```

---

## Part 7: Research Agent Fixture Acceptance Criteria

### Lead Signal Boundary Fixture (`spark-lead-signal-boundary-fixture-v0`)

Minimum required observations:

```text
1. Three LeadSignalObservation records with Decimal bid amounts (Decimal[scale:2]).
2. Two IdempotencyKey values (two duplicate-deduplicated signals).
3. One HourlyLeadSignalRollup with:
   - total_accepted_count: Integer
   - total_bid_sum: Decimal[scale:2]   -- NOT Float
   - aggregated_from links to all three source observations
4. One RetentionDryRunReceipt:
   - candidate_count: 3
   - boundary_refs: [rollup_obs.id]
   - uncovered_refs: []   (all covered by rollup boundary)
   - status: :safe_to_execute
5. One RetentionExecutionReceipt:
   - dry_run_ref: dry_run_obs.id
   - deleted_count: 3 (the raw signals)
   - preserved_refs: [rollup_obs.id]
6. One DuplicateNonAdmissionReceipt for the duplicate signal.
```

Failure cases:

```text
F-1: Decimal[scale:4] bid compared to Decimal[scale:2] threshold -> OOF-DM1.
F-2: Float bid amount in compute node -> OOF-DM2.
F-3: RetentionExecution without DryRun -> OOF-RT1.
F-4: RetentionExecution when uncovered_refs non-empty -> OOF-RT2.
F-5: Duplicate signal with nil fields list -> OOF-IK2.
```

### Idempotency Negative Fixture

```text
1. Random token (string "abc12345") used as idempotency key -> OOF-IK1.
2. Empty fields list -> OOF-IK2.
3. Two signals with same canonical_form -> one NonAdmissionReceipt.
4. Two signals with different canonical_form but same display -> two separate admissions.
```

---

## Part 8: Bridge / Package Implications

**Bridge Agent:**

```text
BR-Decimal: Decimal[scale:S] serialization shape for metadata-only adapter maps.
  Use: { "kind": "decimal", "coefficient": Integer, "scale": Integer, "display": String }
  Do NOT use Float as a Decimal proxy in adapter maps.

BR-IdempotencyKey: identified_by link relation in observation packets.
  Bridge adapters should emit identified_by links when wrapping Spark lead signals.

BR-RetentionReceipt: dry_run_ref and preserved_refs are mandatory in execution receipts.
  Bridge metadata for retention events must include both receipt types.
```

**Package implications (informational; no package changes in this slice):**

```text
- igniter-embed: ObservationPacket should accept "decimal" as a payload value type.
  Currently may serialize Decimal as Float. This must be corrected before
  Decimal comparisons can be trusted in emission.
- igniter-ledger (or TBackend adapter): dedup store must use identified_by
  links for duplicate detection, not payload hash equality.
- No package changes in this slice. These are noted as future pressure points.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/decimal-idempotency-retention-formalization-v0.md
Status: done

Neighbors:
- [Igniter-Lang Research Agent]: lead-signal-boundary fixture criteria in §Part 7.
- [Igniter-Lang Bridge Agent]: Decimal serialization, identified_by link, and
  RetentionReceipt shapes in §Part 8.

[D] Decisions:
- Decimal[scale:S] is a v0 base type. Not Float. Not host-policy escape.
  coefficient + scale is the canonical representation.
- Add/sub require matching scales. Mul produces scale = A+B.
  Div is ESCAPE without explicit result_scale + rounding_mode literals.
- Decimal comparison of mismatched scales -> OOF-DM1 (compile error).
- Float-as-Decimal-proxy -> OOF-DM2 (compile error).
- IdempotencyKey is a content-addressed CORE value.
  fields list + algorithm must both be statically declared.
- canonical_form: alphabetically sorted field=value pairs, newline-separated.
- Duplicate suppression: three distinct outcomes:
    non-admission (same key, no mutation, NonAdmissionReceipt),
    rejection (business rule violation, RejectionReceipt),
    no-op (ESCAPE retry, NoOpReceipt with original_receipt link).
- RetentionReceipt: two phases required: DryRun before Execution.
  DryRun with uncovered_refs non-empty blocks execution (OOF-RT2).
  DryRunReceipt and ExecutionReceipt are both lifecycle :audit.
- Late boundary: three responses: Blocked (default), BoundaryReopenReceipt
  (capability-gated), migration-style replacement (schema-driven only).
- BoundaryReopenReceipt requires capability_ref (OOF-LB2 if absent).
- Misuse of migration path for genuinely late signals -> OOF-LB4.
- 6 SemanticIR gates defined (G-1 through G-6): all must pass before lowering.

[R] Recommendations:
- Research Agent: implement lead-signal fixture with Decimal[scale:2] for bid amounts,
  explicit IdempotencyKey with sha256, and the two-phase retention receipts.
  Do NOT use Float for any bid/threshold value in the fixture.
- Bridge Agent: update metadata-only adapter maps to use the Decimal wire shape
  from §Part 8. Do not propagate Float values through observation packets.
- Future: Decimal[scale:S] may be promoted to a generic trait-bound numeric type
  once polymorphism (PROP-016) is stable. For v0, it is a named base type.
- Future: a RoundingPolicy TypeDecl may consolidate rounding_mode + result_scale
  into a single input port for Decimal-heavy contracts.

[S] Signals:
- Spark lead signals already have bid amounts as Float in the Ruby layer. This is
  the primary pressure point: the language must make Float-as-Decimal an OOF, not
  a silent coercion.
- The two-phase retention model (dry-run + execution) is already present in Spark
  cleanup services but without formal receipt evidence. Igniter-Lang makes it explicit.
- IdempotencyKey as content-addressed value is already the intent in Spark's
  idempotency_key field computations. The canonical_form rule formalizes it.
- BoundaryReopenReceipt is new; Spark currently has no formal reopen mechanism.
  The blocked-by-default behavior matches the strictest interpretation of boundary
  semantics and can be relaxed per-policy with the reopen receipt.

[T] Tests / Proofs:
- Research Agent fixture: see §Part 7.
- OOF-DM1: Decimal scale mismatch -> compile error at Pass 1.
- OOF-DM2: Float as Decimal -> compile error at Pass 1.
- OOF-RT1: execution without dry-run -> OOF at runtime gate.
- OOF-RT2: execution when dry-run blocked -> OOF at execution gate.
- OOF-IK2: empty fields -> compile error at Pass 1.
- OOF-LB1: late record without reopen -> blocked at store write.

[Files] Changed:
- igniter-lang/docs/tracks/decimal-idempotency-retention-formalization-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Q] Open Questions (not blocking v0 fixture):
- Q-1: Should Decimal[scale:S] be a parameterized type in the grammar
  (e.g. Decimal[2]) or a type alias (e.g. type BidAmount = Decimal[scale:2])?
  Recommendation: type alias is cleaner for contracts. Decimal[S] as a
  base type with type aliases in the contract. Grammar support for type
  alias with Decimal[scale:N] parameter deferred to next grammar slice.
- Q-2: Should canonical_form use "coefficient/scale" or "coefficient.scaled_display"
  for Decimal values? Recommendation: "coefficient/scale" (e.g. "1250/2") is
  unambiguous and avoids locale-sensitive decimal point issues.
- Q-3: Should BoundaryReopenReceipt allow partial reopen (only specific
  signal types admitted)? Recommendation: no in v0. All-or-nothing reopen
  under the declared reopen policy. Partial reopen needs a FilteredReopenPolicy
  type (future).

[X] Rejected:
- Float as Decimal proxy. OOF-DM2. No exceptions.
- Decimal without explicit scale. Scale must be declared at type annotation.
- Random ambient entropy as IdempotencyKey. OOF-IK1. Must be ESCAPE with receipt.
- Single-phase retention (execution without dry-run). OOF-RT1.
- Silent reopen of closed boundaries. Must use BoundaryReopenReceipt with capability.
- Migration-style replacement for genuine late signals. OOF-LB4.
- Suppressing duplicate suppression receipt. All three suppression outcomes must emit
  a receipt. Silent suppression is OOF (no evidence of dedup).

[Next] Proposed next slices:
1. [Research Agent]: spark-lead-signal-boundary-fixture-v0
   Build the lead-signal fixture from §Part 7 criteria:
   Decimal[scale:2] bid amounts, IdempotencyKey, HourlyRollup,
   two-phase RetentionReceipts, DuplicateNonAdmissionReceipt.

2. [Research Agent]: spark-technician-availability-fixture-v0
   Independent track; use tenant_availability_projection.ig as source fixture.

3. [Compiler/Grammar Expert]: decimal-grammar-v0
   Add Decimal[scale:N] to the grammar (type annotation with integer parameter).
   Extend type system (PROP-004) with Decimal as a base type.
   Define arithmetic operator signatures for Pass 1 type inference.
```
