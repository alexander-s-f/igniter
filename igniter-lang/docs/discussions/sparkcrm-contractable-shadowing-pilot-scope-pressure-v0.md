# sparkcrm-contractable-shadowing-pilot-scope-pressure-v0

Card: S3-R87-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: product-pressure
Track: sparkcrm-contractable-shadowing-pilot-scope-pressure-v0
Route: UPDATE
Status: complete
Date: 2026-05-20

---

## Inputs Read

**Primary (C1 output)**:
- `igniter-lang/docs/tracks/sparkcrm-contractable-shadowing-pilot-scope-v0.md` (C1-P1)

**Authority baseline**:
- `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md` (R86-C4-A)
- `igniter-lang/docs/tracks/stage3-round86-status-curation-v0.md` (R86-C5-S)

**Cross-lane / portfolio context**:
- `igniter-lang/docs/org/portfolio-reporting-protocol-v0.md`
- `igniter-lang/docs/org/tracks/sparkcrm-pilot-cross-lane-reporting-and-letter-boundary-v0.md` (C0-O)

---

## Scope Checks

### 1. Pilot is design/scope only — no implementation authorized or implied

**C1 scope statement**: "Design the first bounded Spark CRM contractable shadowing pilot
without implementing it." ✓

**C1 "Scope" section** explicitly excludes: Spark CRM code inspection, Spark CRM
code edits, Igniter Ruby Framework code edits, Igniter-Lang compiler/runtime code
edits, letter file creation, and production behavior authorization. ✓

**C1 "Closed Surfaces"** lists "pilot implementation" as explicitly closed. ✓

**C1 "Files Changed"**: one document only —
`igniter-lang/docs/tracks/sparkcrm-contractable-shadowing-pilot-scope-v0.md`. ✓

**C1 "Pilot Scope Table" "Now" horizon**:

```text
Design-only pilot scope for AvailabilityLedger::SlotMap why-not observations.
Primary-observed-only receipt shape with redacted digests, reason counts, ...
Exact implementation authorization checklist for a later Architect decision.
Cross-lane letter payload recommendation only; no letter file created by this card.
```

All four "Now" items are documentation artifacts, not implementation. ✓

**R86-C4-A authorization baseline**: "does not authorize implementation in this
decision." The authorized next route was `sparkcrm-contractable-shadowing-pilot-scope-v0`
described as "This is design/scope only. Implementation remains held pending a
separate Architect authorization decision." C1 is within that boundary. ✓

**Result: PASS**

---

### 2. Primary Spark service remains authoritative

**C1 "Pilot Contract" required invariants**:

```text
the existing Spark service remains the only authoritative decision source;
shadowing is observation/diagnostics only;
no production output changes;
no user-visible behavior changes unless a later Spark-owned UI/debug card
  explicitly opens it;
```

"Only authoritative decision source" is stronger than "primary" — it forecloses
any interpretation of the shadow candidate as co-authoritative. ✓

**C1 non-authorization flags**:

```text
primary_service_authoritative: true
shadow_observation_only: true
runtime_authority_granted: false
production_behavior_change_authorized: false
```

These are named boolean invariants, machine-checkable in a future proof. ✓

**C1 implementation authorization checklist item 3**: "Primary Spark service
remains authoritative." ✓

**C1 "Option Comparison" table — Option A row**:
"existing service remains primary; candidate contract can run as shadow" ✓

**C1 "Cross-Lane Letter" draft**:
"keep Spark service output authoritative" ✓

The authority statement appears in five separate locations across C1. No
ambiguity. ✓

**Result: PASS**

---

### 3. Shadowing is fail-open and non-production-authoritative

**C1 "Pilot Contract" required invariants**:

```text
missing receipt, failed receipt write, or shadow candidate failure is fail-open;
```

Three distinct failure modes are explicitly covered — receipt missing, receipt write
failure, and shadow candidate failure — each fail-open. ✓

**C1 "Missing-Receipt Fail-Open Behavior" section** decomposes fail-open into four
mechanical properties:

- Spark service returns primary result regardless of receipt status ✓
- Receipt construction failure does not raise into business flow ✓
- Receipt sink failure records only safe local diagnostics if available ✓
- Missing receipt is a pilot observability gap, not a business error ✓

**C1 non-authorization flag**: `missing_receipt_blocks_flow: false` ✓

**C1 implementation authorization checklist items 6 and 11**:

```text
6. Receipt construction and sink failures are fail-open.
11. Missing receipt behavior is tested as non-blocking.
```

Item 11 requires a proof test, not just a design assertion. ✓

**C1 "Cross-Lane Letter" draft**: "missing receipt does not block business flow
in pilot mode" ✓

**Result: PASS**

---

### 4. No real Spark secrets, endpoints, customer payloads, provider payloads, phone/email data, credentials, or infrastructure details are exposed

**C1 "Pilot Contract" required invariants**:

```text
raw customer, provider, technician, company, user-like, schedule, phone/email,
endpoint, credential, and infrastructure payloads are forbidden in receipts;
receipts carry digests and redacted refs, not raw payloads;
```

Ten categories of forbidden payload types named explicitly. ✓

**C1 "Redacted Receipt Shape" table**: Every sensitive field is
digest/HMAC-addressed, not raw:

| Field | Policy |
| --- | --- |
| `tenant_ref_digest` | Digest/HMAC; no raw name/id in public receipt |
| `subject_ref_digest` | Digest/HMAC of technician/provider/user-like subject |
| `business_date_digest` | Digest if date is sensitive |
| `evidence_ref_digests` | Digests for snapshot/live read/source refs; no raw records |

No field in the receipt shape exposes raw identifying data. ✓

**C1 "Digest And Redaction Policy" section**:

```text
never include raw customer, provider, technician, company, schedule, phone,
email, endpoint, credential, or infrastructure payloads in public docs,
fixtures, or sidecar examples.
```

The prohibition covers three artifact classes: public docs, fixtures, and sidecar
examples — not only runtime receipts. ✓

**C1 "Synthetic Igniter-Lang Fixture Pressure" section**: "technician/provider-like
subject as redacted ref" — even synthetic fixtures with fake data must use a
redacted ref for sensitive subject kinds, not a real-named ref. ✓

**C1 implementation authorization checklist items 8 and 10**:

```text
8. Raw customer/provider/technician/company/user/schedule/contact payloads are
   forbidden in public docs, fixtures, and sidecar examples.
10. Redaction policy is tested with negative cases for raw ids/payloads.
```

Item 10 requires negative test cases that would catch a redaction miss — this is a
strong guard that is often absent from naive privacy designs. ✓

**C1 track document itself**: Does not contain any real Spark CRM data, customer
records, phone/email, pricing values, technician names, company names, credentials,
provider endpoint URLs, or infrastructure details. The document contains only class
names, business process descriptions, and design patterns. ✓

**Result: PASS**

---

### 5. Ruby Framework adoption work is not silently assigned to Igniter-Lang

**C1 "Neighbor Roles / Downstream lanes"**:

```text
Downstream lanes named, not assigned: Igniter Ruby Framework, Spark CRM,
Igniter Ledger sidecar research.
```

The phrasing "named, not assigned" is a clear boundary signal. C1 names what
belongs to those lanes but does not pull the work into Igniter-Lang. ✓

**C1 "Redacted Receipt Shape" header**: "This is a design shape, not package/API
schema." — The receipt shape is a conceptual design template for discussion, not
an Igniter Ruby Framework package implementation or Igniter-Lang schema. ✓

**C1 "Cross-Lane Letter" draft — "Request to Igniter Ruby Framework lane"**:

```text
Review future package support needed for contractable observed wrappers,
redaction defaults, digest helpers, sampling gates, fail-open receipts, and
eventual durable observation adapter. Do not implement from this letter.
```

Ruby Framework work (wrappers, redaction, digest helpers, sampling, Sidekiq
adapter) is explicitly routed to the Ruby Framework lane with a "Do not implement"
guard. ✓

**C1 "Synthetic Igniter-Lang Fixture Pressure" section** scopes Igniter-Lang to:
"synthetic only" fixture/spec work — bitemporal modeling, tenant scope, reason
counts. This is language/spec work, not framework implementation. ✓

**C1 "Pilot Scope Table"** — no "Now" entry assigns Ruby Framework package work to
Igniter-Lang. The "Now" items are all design artifacts. ✓

**C1 "Closed Surfaces"**: "Igniter Ruby Framework code edits" ✓

**Traceability check**: The durable observation adapter, Rails initializer,
Sidekiq/ActiveJob, redaction defaults, and admin lookup helper all appear in C1 as
"Request to Igniter Ruby Framework lane" in the letter draft, not as
Igniter-Lang deliverables. ✓

**Result: PASS**

---

### 6. Igniter Ledger remains sidecar/sandbox only unless separately authorized

**C1 "Optional Igniter Ledger Sidecar Boundary" section** opens with:

```text
Igniter Ledger sidecar is optional and later.
```

Both qualifiers matter: "optional" (not required for the pilot) and "later" (not
in current scope). ✓

**C1 "Closed sidecar uses"**:

```text
primary Spark database;
production source of truth;
replaying Spark business state as authority;
live RuntimeMachine/TBackend binding;
raw Spark data sink.
```

Five explicit closed uses. ✓

**C1 non-authorization flag**: `ledger_sidecar_source_of_truth: false` ✓

**C1 implementation authorization checklist item 15**: "Igniter Ledger sidecar is
disabled unless separately authorized." ✓

**C1 "Pilot Scope Table" — "Later"**: "Optional Igniter Ledger sidecar receipt sink
after separate sidecar approval." ✓ — requires its own authorization.

**C1 durable adapter dependency**:

```text
No high-volume or production-adjacent receipt rollout before durable adapter
readiness is approved.
```

This also blocks any attempt to activate the Ledger sidecar as a high-volume sink
before the adapter is ready. The ordering is: durable adapter first, sidecar
receipt sink second, each separately authorized. ✓

**C1 "Closed Surfaces"**: "Igniter Ledger code edits; production TBackend/Ledger
binding for Spark; Igniter Ledger as primary Spark database" ✓

**Result: PASS**

---

### 7. Igniter-Lang receives only sanitized fixture/spec pressure

**C1 "Synthetic Igniter-Lang Fixture Pressure" section** opens with the fixture
being "synthetic only":

```text
Fixture should be synthetic only and model:
- tenant scope;
- technician/provider-like subject as redacted ref;
...
```

"Synthetic only" means no real Spark CRM data or runtime. ✓

The modeled content — tenant scope, redacted refs, reason counts, snapshot
observation, diagnostic categories — is appropriate language/type-system pressure,
not production execution. ✓

**C1 implementation authorization checklist item 16**: "No Igniter-Lang runtime,
`.igapp`, TBackend, Ledger production binding, CompatibilityReport, loader/report,
CLI/API, or compiler changes." ✓

**C1 Cross-Lane Letter draft — "Request to Igniter-Lang lane"**:

```text
Use only sanitized synthetic fixture/spec pressure:
sparkcrm-availability-ledger-why-not-fixture-v0 first, price-chain fixture later.
```

Language is explicitly "sanitized synthetic fixture/spec pressure." ✓

**C1 "Pilot Scope Table"** — Igniter-Lang fixture work is in the "Later" horizon,
not "Now." The current scope does not activate any Igniter-Lang fixture
implementation. ✓

**C1 "Closed Surfaces"**: "Igniter-Lang compiler/runtime code edits" ✓

**Subtle correctness check**: The recommended Igniter-Lang fixture
(`sparkcrm-availability-ledger-why-not-fixture-v0`) is a follow-up
recommendation, not an authorization. It requires its own separate gate before it
can be opened. C1 correctly positions it as "Recommended follow-up fixture." ✓

**Result: PASS**

---

### 8. Implementation authorization checklist is explicit and narrow

**C1 "Implementation Authorization Checklist"** contains 17 items. Testing each
dimension:

**Scope narrowness** — items 1, 2: names exactly one service and one mode. No
scope creep possible if checklist is enforced. ✓

**Authority separation** — item 3 (primary service authoritative), item 16 (no
Igniter-Lang runtime/compiler/`.igapp`). ✓

**Privacy / data safety** — items 7, 8, 9, 10: receipt carries only redacted
digests; raw payloads forbidden across three artifact classes; digest
canonicalization is tested; redaction policy has negative test cases. ✓

**Fail-open correctness** — items 6, 11, 12: sink failures are fail-open; missing
receipt is tested as non-blocking; primary result parity is tested. ✓

**Forward-proofing** — item 13: idempotency key required even before durable
adapter; item 14: durable adapter scope is explicitly declared. ✓

**Ledger isolation** — item 15: Ledger sidecar disabled unless separately
authorized. ✓

**Proof coverage** — item 17: five specific proof test types required (redaction,
digest stability, fail-open, sampling, primary-output parity). ✓

**Forward guard on checklist use**: "A future implementation card must be explicit
and narrow. It should not be approved unless it states all of the following." This
means any implementation card that does not reproduce all 17 items should not be
approved by C3-A. ✓

**Completeness assessment**: The 17-item checklist is comprehensive for a
low-volume primary-observed-only pilot. It covers scope, authority, privacy,
fail-open, proof, and isolation dimensions. One item not made explicit (addressed
as NB below): the checklist does not require Spark lane confirmation before the
implementation card can be authorized. This is a process dependency, not a
technical checklist item, and is appropriately handled at the governance layer.

**Result: PASS**

---

### 9. Cross-lane letter packet is a request/handoff, not a decision

**C1 "Cross-Lane Letter Packet Recommendation" section** states the boundary
verbatim from C0-O:

```text
letter = communication / handoff / request
letter != decision
letter != Portfolio close report
letter != implementation authorization
letter != canon
```

Four explicit negations. ✓

**C1 does not create a letter file**: "This track does not ... create a letter
file." ✓ — The card outputs only the scope track document plus a letter payload
recommendation.

**C0-O independently confirms**: "letter != decision; letter != Portfolio close
report; letter != implementation authorization; letter != canon" — consistent
with C1. ✓

**C1 proposed letter payload content review**: The payload contains four lane
requests, each phrased as a review request, not an instruction:

- "Request to Spark CRM lane: Review whether this target is operationally
  acceptable... Do not implement from this letter." ✓
- "Request to Igniter Ruby Framework lane: Review future package support needed...
  Do not implement from this letter." ✓
- "Request to Igniter Ledger sidecar lane: Treat sidecar receipt sink as
  optional/later. Do not make Ledger source of truth." ✓
- "Request to Igniter-Lang lane: Use only sanitized synthetic fixture/spec
  pressure." ✓

Each request is either a question, a constraint, or a design lane assignment —
none constitutes an implementation authorization or a canon decision. ✓

**Portfolio closure independence**: The letter payload correctly says Portfolio
closes via `stage3-round87-status-curation-v0.md`, not via the letter. ✓

**C1 "Closed Surfaces"**: "turning a cross-lane letter into a decision, report
packet, canon, or implementation authorization" ✓ — a four-way explicit
prohibition.

**Result: PASS**

---

### 10. Portfolio reporting route is correctly established

**C0-O** confirms: "igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md"
as the default Portfolio closure packet, with `s3-r87-round-report.md` as fallback
only if needed. ✓

**C1** references this route: "Portfolio closure: R87 should close through
stage3-round87-status-curation-v0.md unless that packet cannot satisfy the active
reporting protocol." ✓

**S3-R87 Round Receipt**: "Expected close packet:
igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md" ✓

**Portfolio Reporting Protocol rule**: "No report packet → lane round is not closed
for Portfolio." — The default status-curation track satisfies this if it contains
the required reporting fields. The C0-O and C1 agreement on the packet path
maintains this rule. ✓

**Result: PASS**

---

### 11. Option B deferred correctly

C1 recommends Option A (`AvailabilityLedger::SlotMap`) and explicitly defers
Option B (`OrderPriceLedger::Finder`):

"Option B, `OrderPriceLedger::Finder`, should remain next/later. It is valuable
for chain winner explanation and fractal price-ledger fixtures, but it carries
more scope-chain, price-rule, order/customer, and commercial sensitivity. That
is too much for the first shadowing pilot."

The rationale is sound. Order pricing involves:

- commercial pricing rules (commercially sensitive);
- customer/order context (personally sensitive);
- chain resolution complexity (wider scope);

Availability slot reasons involve:

- reason categories (`available`, `scheduled`, `off_schedule`, `day_off`, `past`);
- no commercial pricing or customer order values;
- bounded diagnostic vocabulary.

Option A is the more conservative choice for a first pilot. ✓

**Result: PASS**

---

## Summary

| # | Check | Result |
| --- | --- | --- |
| 1 | Pilot is design/scope only — no implementation authorized or implied | PASS |
| 2 | Primary Spark service remains authoritative | PASS |
| 3 | Shadowing is fail-open and non-production-authoritative | PASS |
| 4 | No real secrets, payloads, credentials, phone/email, or infrastructure data exposed | PASS |
| 5 | Ruby Framework adoption work not silently assigned to Igniter-Lang | PASS |
| 6 | Igniter Ledger remains sidecar/sandbox only unless separately authorized | PASS |
| 7 | Igniter-Lang receives only sanitized fixture/spec pressure | PASS |
| 8 | Implementation authorization checklist is explicit and narrow | PASS |
| 9 | Cross-lane letter packet is a request/handoff, not a decision | PASS |
| 10 | Portfolio reporting route is correctly established | PASS |
| 11 | Option B correctly deferred; Option A rationale is sound | PASS |

```text
checks: 11/11 PASS
blockers: 0
non-blocking notes: 4
```

---

## Non-Blocking Notes

### NB-1: `service_ref` abstraction convention is undefined at design stage

The receipt shape includes `service_ref: "Abstract service ref, not private file
path."` What counts as "abstract" is not defined at the design-scope level.

In implementation, this field must:

- not be a Ruby class name or file path (those are internal implementation
  details);
- be a stable, version-independent identifier for admin/debug lookup;
- not be derivable from raw customer or service provider data.

A future implementation card should define the convention for `service_ref`
explicitly — for example: `"availability_slotmap_v0"` as a stable string constant,
not `"AvailabilityLedger::SlotMap"`.

Not a blocker for design scope acceptance. Must be resolved in the implementation
card.

### NB-2: Idempotency key generation without a durable adapter is underspecified

Checklist item 13 requires: "Receipt idempotency key is defined, even if durable
adapter is not yet implemented." This is a strong forward-proofing guard.

However, without a durable adapter, the idempotency key has nowhere durable to
live. It will be generated but potentially not persisted, which means repeat calls
for the same service invocation could produce new keys.

The implementation card should clarify:

- How the key is generated (e.g., HMAC over `observation_id` + `pilot_id` +
  `sampled_at`);
- Where it lives in the low-volume pilot (app-local log? ephemeral cache?);
- Whether key collision detection is required before the durable adapter lands.

Not a blocker for the design scope. The checklist requirement is correct; the
implementation card must answer these questions before authorization.

### NB-3: Spark lane confirmation is a prerequisite for implementation authorization, but not design acceptance

C1's letter recommends asking the Spark CRM lane: "Review whether this target is
operationally acceptable for a low-volume, fail-open, primary-observed-only pilot."

If the Spark CRM team has not confirmed that `AvailabilityLedger::SlotMap` is an
acceptable pilot target, any future implementation card in the Spark app would be
acting without lane buy-in.

C3-A should decide: does Spark lane confirmation need to arrive before the pilot
scope is formally accepted, or is the scope document accepted provisionally with
the confirmation gate placed at implementation authorization?

The second option (provisional acceptance, confirmation before implementation) is
the lighter-weight path and is consistent with the round pattern, which keeps
implementation authorization in a separate card. Either option is safe — this
note surfaces the gap so C3-A makes a conscious choice.

Not a blocker for accepting the design scope.

### NB-4: `sparkcrm-availability-ledger-why-not-fixture-v0` is recommended but not authorized

C1 recommends a follow-up Igniter-Lang fixture track. This fixture is not
authorized in C1, not authorized in R86, and does not have a separate gate.

C3-A should explicitly note whether:

- the fixture is accepted as an authorized next candidate pending its own gate; or
- the fixture is merely a recommendation that requires a separate round to scope.

If the fixture is accepted as a next candidate, it should appear in the next
allowed route list with the same design-only boundary that C1 used for the pilot
scope. It should not slip into an implementation authorization by being implied
as "the natural follow-up."

Not a blocker for the pilot scope decision.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 4 (all correctly scoped, none require action before C3-A)
```

---

## Recommendation For C3-A

**On C1 (pilot scope)**:

The pilot scope is clean, conservative, and well-guarded. All nine primary safety
checks pass:

- The design/scope boundary is maintained throughout.
- Option A (`AvailabilityLedger::SlotMap`) is the right first target.
- The redacted receipt shape, digest policy, sampling gate, fail-open behavior,
  durable adapter dependency, Ledger sidecar isolation, and 17-item authorization
  checklist together form a strong, internally consistent design.
- The cross-lane letter payload is correctly framed as a request, not a decision.
- Portfolio closure routing is correctly established.

Recommend: **accept pilot scope**.

**If accepting, record explicitly**:

```text
- primary Spark service remains the only authoritative decision source;
- pilot mode is primary_observed_only; shadow candidate requires separate
  authorization;
- receipt data uses redacted refs/digests; raw payloads are forbidden;
- receipt construction and sink failures are fail-open;
- sampling gate is default-off, opt-in, and rate-limited;
- durable adapter gates high-volume and production-adjacent rollout;
- Igniter Ledger sidecar is optional and later; requires separate authorization;
- Igniter-Lang uses only sanitized synthetic fixture/spec pressure;
- a future implementation card must satisfy all 17 checklist items before
  implementation is authorized.
```

**On the four non-blocking notes**:

- NB-1 (`service_ref`): delegate to implementation card.
- NB-2 (idempotency key): delegate to implementation card.
- NB-3 (Spark lane confirmation): decide whether confirmation gates design
  acceptance or implementation authorization. Recommend gating at
  implementation authorization — cleaner boundary.
- NB-4 (fixture track): explicitly state whether the fixture is an authorized
  next candidate or a recommendation requiring its own separate round.

**What C3-A must not authorize**:

```text
- pilot implementation;
- Spark CRM code edits;
- Spark production behavior changes;
- Igniter Ruby Framework implementation;
- Igniter Ledger code edits or production binding;
- Igniter-Lang compiler/runtime implementation;
- real Spark data, credentials, endpoints, payloads, or customer/provider details;
- production TBackend/Ledger binding;
- public API/CLI widening, loader/report, CompatibilityReport, RuntimeMachine,
  Gate 3, or production widening;
- treating the cross-lane letter as a decision, authorization, or canon.
```
