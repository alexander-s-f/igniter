# Track: Spark CRM Contractable Shadowing Pilot Scope v0

Card: S3-R87-C1-P1
Agent: `[Igniter-Lang Bridge Agent]`
Role: bridge-agent
Track: `sparkcrm-contractable-shadowing-pilot-scope-v0`
Route: UPDATE
Depends on: S3-R87-C0-O
Status: done
Date: 2026-05-20

Affected neighbor roles: `[Igniter-Lang Applied Pressure Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`,
`[Portfolio Architect Supervisor]`

Downstream lanes named, not assigned: Igniter Ruby Framework, Spark CRM,
Igniter Ledger sidecar research.

---

## Scope

Design the first bounded Spark CRM contractable shadowing pilot without
implementing it.

This track does not inspect private Spark CRM code, edit Spark CRM code, edit
Igniter Ruby Framework code, edit Igniter-Lang compiler/runtime code, create a
letter file, or authorize production behavior changes.

---

## Inputs Read

- `igniter-lang/AGENTS.md`
- `igniter-lang/roles/README.md`
- `igniter-lang/roles/bridge-agent.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`
- `igniter-lang/docs/tracks/sparkcrm-igniter-adoption-readiness-map-v0.md`
- `igniter-lang/docs/org/tracks/sparkcrm-inbox-disposition-and-pressure-routing-v0.md`
- `igniter-lang/docs/inbox/sparkcrm-ledger-igniter-applicability-analysis-2026-05-20.md`
- `igniter-lang/docs/applied-pressure-directions.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/org/tracks/sparkcrm-pilot-cross-lane-reporting-and-letter-boundary-v0.md`
- `igniter-lang/docs/org/portfolio-reporting-protocol-v0.md`
- `igniter-lang/docs/reports/README.md`

No private Spark CRM repository files were inspected.

---

## Current Horizon

- R86 routes Spark CRM as active applied-pressure source, not canon or
  implementation authority.
- Accepted near-term posture is observation, shadowing, redacted receipts, and
  optional sidecar sinks.
- First pilot must keep the primary Spark service authoritative and fail open.
- Durable observation adapter is required before high-volume or
  production-adjacent rollout.
- R87-C0 confirms letter packets are communication only; Portfolio closure uses
  `stage3-round87-status-curation-v0.md` unless insufficient.

---

## Target Decision

Recommended first pilot target:

```text
Option A: AvailabilityLedger::SlotMap
```

Pilot theme:

```text
why-not availability diagnostics
```

Rationale:

- It has bounded, user-facing explanation value: available, scheduled,
  off-schedule, day-off, and past.
- The first receipt can avoid raw slot payloads by reporting reason counts,
  input/output digests, and redacted evidence refs.
- It directly pressures existing Igniter-Lang availability fixtures:
  tenant scope, explicit business date, query time, source refs, compaction, and
  observation kind distinction.
- It exposes the important Spark distinction between projected snapshot evidence
  and live operational reads without making Igniter Ledger source of truth.

Option B, `OrderPriceLedger::Finder`, should remain next/later. It is valuable
for chain winner explanation and fractal price-ledger fixtures, but it carries
more scope-chain, price-rule, order/customer, and commercial sensitivity. That is
too much for the first shadowing pilot.

---

## Option Comparison

| Option | Benefits | Risks | First-pilot fit |
| --- | --- | --- | --- |
| A: `AvailabilityLedger::SlotMap` | Bounded reason vocabulary; strong why-not value; maps to existing availability fixture pressure; output can be reduced to counts/digests. | Technician/company/date/time references need redaction; live reads and snapshot evidence must be named distinctly; slot-level details can become sensitive. | **Recommended first.** Start with primary-observed receipt, optional candidate shadow only after redaction/parity proof. |
| B: `OrderPriceLedger::Finder` | High business value for winner explanation; strong future pressure for typed scope chains and fractal ledgers. | Pricing rules, order context, customer/provider relations, and chain details are more sensitive; explanation shape is more complex. | Later. Use after the receipt/digest/redaction pattern proves safe on availability. |

---

## Pilot Contract

The pilot is a contractable observation wrapper around the existing Spark service.

Required invariants:

- the existing Spark service remains the only authoritative decision source;
- shadowing is observation/diagnostics only;
- no production output changes;
- no user-visible behavior changes unless a later Spark-owned UI/debug card
  explicitly opens it;
- missing receipt, failed receipt write, or shadow candidate failure is fail-open;
- raw customer, provider, technician, company, user-like, schedule, phone/email,
  endpoint, credential, and infrastructure payloads are forbidden in receipts;
- receipts carry digests and redacted refs, not raw payloads;
- pilot sampling is opt-in and rate-limited;
- high-volume or production-adjacent rollout requires a durable adapter first.

Recommended first mode:

```text
primary_observed_only
```

Optional later mode:

```text
primary_observed_plus_shadow_candidate
```

The optional shadow candidate is not part of the first implementation
authorization unless the future card explicitly includes it.

---

## Redacted Receipt Shape

This is a design shape, not package/API schema.

| Field | Required | Policy |
| --- | --- | --- |
| `kind` | yes | `sparkcrm_contractable_shadow_receipt` or a later approved package-local equivalent. |
| `receipt_version` | yes | Version the receipt shape independently from Spark models. |
| `pilot_id` | yes | Stable pilot identifier, e.g. `availability_slotmap_why_not_v0`. |
| `mode` | yes | `primary_observed_only` first; `primary_observed_plus_shadow_candidate` later only if authorized. |
| `observation_id` | yes | Opaque id for admin/debug lookup; not derived from raw customer/provider data. |
| `observed_at` | yes | Receipt creation time. |
| `service_ref` | yes | Abstract service ref, not private file path. |
| `tenant_ref_digest` | yes | Digest/HMAC of tenant/company-like scope; no raw name/id in public receipt. |
| `subject_ref_digest` | yes | Digest/HMAC of technician/provider/user-like subject. |
| `business_date_digest` | yes | Digest if date is sensitive; exact date only in private app-local sink if approved. |
| `query_time_policy` | yes | Describes time treatment without exposing raw event timeline publicly. |
| `input_digest` | yes | Canonical digest over redacted input envelope. |
| `primary_output_digest` | yes | Canonical digest over redacted primary output summary. |
| `reason_counts` | yes | Counts for `available`, `scheduled`, `off_schedule`, `day_off`, `past`, plus `unknown` if needed. |
| `evidence_ref_digests` | yes | Digests for snapshot/live read/source refs; no raw records. |
| `redaction_policy_ref` | yes | Names the redaction policy version used. |
| `sampling_decision` | yes | Records sampled-in reason/rate/allowlist class without raw allowlist details. |
| `receipt_write_status` | yes | `written`, `skipped_unsampled`, `failed_open`, or `deferred`. |
| `shadow_candidate_digest` | later | Only when an authorized candidate exists. |
| `divergence_summary` | later | Redacted summary only; no raw slot map or payload. |
| `non_authorization` | yes | Explicitly states report-only, no Spark behavior change, no Ledger source-of-truth claim. |

Minimum non-authorization flags:

```text
primary_service_authoritative: true
shadow_observation_only: true
runtime_authority_granted: false
production_behavior_change_authorized: false
ledger_sidecar_source_of_truth: false
missing_receipt_blocks_flow: false
```

---

## Digest And Redaction Policy

Input digest policy:

- build a canonical redacted input envelope;
- hash tenant/company/technician/provider/user-like refs with app-local keyed
  digest/HMAC in implementation;
- proof-local synthetic fixtures may use plain deterministic hashes only over
  fake data;
- never include raw customer, provider, technician, company, schedule, phone,
  email, endpoint, credential, or infrastructure payloads in public docs,
  fixtures, or sidecar examples.

Output digest policy:

- digest a redacted output summary, not the raw SlotMap;
- preserve reason counts and coarse diagnostic categories;
- do not persist raw slot windows in the cross-lane receipt shape;
- if private app-local debugging needs raw details, keep them inside Spark-owned
  storage and outside Igniter-Lang docs/fixtures unless separately approved.

Evidence link policy:

- use digest refs to snapshot/live read evidence;
- distinguish snapshot/projection evidence from live operational read evidence;
- include compaction boundary refs only as redacted/digest evidence.

---

## Sampling Gate

Initial pilot sampling must be:

```text
default off
explicitly enabled
low volume
rate limited
allowlist or percentage gated
auditable by observation id
```

The sampling gate must be evaluated before receipt construction when possible,
so unsampled calls avoid unnecessary sensitive envelope creation.

Sampling metadata may record:

- gate version;
- sampled-in reason;
- sample rate bucket;
- non-sensitive allowlist class;
- skipped status.

It must not expose raw allowlist identifiers.

---

## Missing-Receipt Fail-Open Behavior

Pilot mode must fail open:

- Spark service returns the primary result regardless of receipt status.
- Receipt construction failure does not raise into business flow.
- Receipt sink failure records only safe local diagnostics if available.
- Missing receipt is a pilot observability gap, not a business error.
- Reconciliation/backfill may be designed later; it is not required for the
  first low-volume pilot.

Before higher-volume rollout, missing receipt behavior must be upgraded with a
durable outbox/ActiveJob/Sidekiq-style adapter, retry policy, idempotency key,
and reconciliation report.

---

## Optional Igniter Ledger Sidecar Boundary

Igniter Ledger sidecar is optional and later.

Allowed later sidecar use:

- append redacted contractable receipts;
- query observations/divergences by observation id;
- store sanitized mirror facts only after separate approval;
- support retention/compaction explanation research.

Closed sidecar uses:

- primary Spark database;
- production source of truth;
- replaying Spark business state as authority;
- live RuntimeMachine/TBackend binding;
- raw Spark data sink.

Durable adapter dependency:

```text
No high-volume or production-adjacent receipt rollout before durable adapter
readiness is approved.
```

---

## Pilot Scope Table

| Horizon | Scope |
| --- | --- |
| Now | Design-only pilot scope for `AvailabilityLedger::SlotMap` why-not observations. |
| Now | Primary-observed-only receipt shape with redacted digests, reason counts, evidence refs, sampling, and fail-open semantics. |
| Now | Exact implementation authorization checklist for a later Architect decision. |
| Now | Cross-lane letter payload recommendation only; no letter file created by this card. |
| Later | Optional shadow candidate comparison after primary-observed receipt proof passes. |
| Later | Durable observation adapter before high-volume or production-adjacent rollout. |
| Later | Optional Igniter Ledger sidecar receipt sink after separate sidecar approval. |
| Later | `OrderPriceLedger::Finder` chain winner pilot or fixture. |
| Later | Synthetic Igniter-Lang fixtures for availability why-not and fractal price winner explanation. |
| Closed | Spark production behavior changes, primary-ledger replacement, raw data exposure, package implementation, RuntimeMachine execution, production Ledger/TBackend binding. |

---

## Synthetic Igniter-Lang Fixture Pressure

Recommended follow-up fixture:

```text
sparkcrm-availability-ledger-why-not-fixture-v0
```

Fixture should be synthetic only and model:

- tenant scope;
- technician/provider-like subject as redacted ref;
- business date and query time;
- snapshot/projection observation;
- live operational read observation;
- reason counts and why-not categories;
- missing snapshot diagnostic;
- live record drift diagnostic;
- compaction boundary receipt;
- fail-open/missing-receipt diagnostic as observation gap.

Later fixture:

```text
sparkcrm-fractal-price-ledger-fixture-v0
```

Use later for `OrderPriceLedger::Finder` / chain winner explanation after the
availability receipt boundary proves safe.

---

## Implementation Authorization Checklist

A future implementation card must be explicit and narrow. It should not be
approved unless it states all of the following:

1. Target is exactly one service: `AvailabilityLedger::SlotMap`.
2. Mode is `primary_observed_only` unless shadow candidate is separately named.
3. Primary Spark service remains authoritative.
4. No production output or user-visible behavior changes.
5. Sampling gate is default-off, opt-in, low-volume, and rate-limited.
6. Receipt construction and sink failures are fail-open.
7. Receipt shape carries redacted refs/digests only.
8. Raw customer/provider/technician/company/user/schedule/contact payloads are
   forbidden in public docs, fixtures, and sidecar examples.
9. Input/output digest canonicalization is tested.
10. Redaction policy is tested with negative cases for raw ids/payloads.
11. Missing receipt behavior is tested as non-blocking.
12. Primary result parity is tested: wrapper does not alter service output.
13. Receipt idempotency key is defined, even if durable adapter is not yet
    implemented.
14. Durable adapter is explicitly out of scope for low-volume pilot or included
    as its own authorized slice.
15. Igniter Ledger sidecar is disabled unless separately authorized.
16. No Igniter-Lang runtime, `.igapp`, TBackend, Ledger production binding,
    CompatibilityReport, loader/report, CLI/API, or compiler changes.
17. Proof evidence includes a redaction test, digest stability test,
    fail-open test, sampling test, and primary-output parity test.

Required proof/parity evidence before widening:

- sampled primary-observed receipts show stable digest behavior;
- redaction scan finds no raw sensitive refs;
- primary service output parity holds;
- receipt failures do not block business flow;
- observation volume and failure rate are understood;
- durable adapter readiness is approved before high-volume or
  production-adjacent rollout.

---

## Cross-Lane Letter Packet Recommendation

R87-C0 recommends a future letter path, but also says this card should not
create the letter file.

Recommended future letter file:

```text
igniter-lang/docs/org/letters/sparkcrm-contractable-shadowing-pilot-scope-letter-v0.md
```

Letter boundary:

```text
letter = communication / handoff / request
letter != decision
letter != Portfolio close report
letter != implementation authorization
letter != canon
```

Proposed payload for the future letter:

```text
Subject: Spark CRM contractable shadowing pilot scope request

Recommended first pilot:
  AvailabilityLedger::SlotMap why-not availability diagnostics.

Request to Spark CRM lane:
  Review whether this target is operationally acceptable for a low-volume,
  fail-open, primary-observed-only pilot. Do not implement from this letter.

Request to Igniter Ruby Framework lane:
  Review future package support needed for contractable observed wrappers,
  redaction defaults, digest helpers, sampling gates, fail-open receipts, and
  eventual durable observation adapter. Do not implement from this letter.

Request to Igniter Ledger sidecar lane:
  Treat sidecar receipt sink as optional/later. Do not make Ledger source of
  truth and do not bind production TBackend.

Request to Igniter-Lang lane:
  Use only sanitized synthetic fixture/spec pressure:
  sparkcrm-availability-ledger-why-not-fixture-v0 first, price-chain fixture
  later.

Non-authorizations:
  no Spark code edits, no Ruby Framework code edits, no production behavior
  changes, no real data exposure, no primary-ledger replacement, no
  RuntimeMachine/Gate 3/Ledger production binding, no public API/CLI/schema
  changes.

Portfolio closure:
  R87 should close through stage3-round87-status-curation-v0.md unless that
  packet cannot satisfy the active reporting protocol.
```

---

## Closed Surfaces

This track does not authorize:

- Spark CRM code edits;
- private Spark CRM code inspection;
- Igniter Ruby Framework code edits;
- Igniter Ledger code edits;
- Igniter-Lang compiler/runtime code edits;
- pilot implementation;
- production behavior changes;
- production data, credentials, endpoints, provider payloads, customer records,
  technician/user raw records, phone/email data, or infrastructure details in
  docs or fixtures;
- Spark primary-ledger replacement;
- Igniter Ledger as primary Spark database;
- production TBackend/Ledger binding for Spark;
- automatic Spark-to-Igniter migration;
- public `.igapp` operational policy deployment for Spark;
- CompatibilityReport, loader/report, CLI/API, parser, TypeChecker,
  SemanticIR, assembler, `.igapp`, `.ilk`, signing, receipt schema, dispatch,
  RuntimeMachine, Gate 3, stream/OLAP, cache, or production widening;
- turning a cross-lane letter into a decision, report packet, canon, or
  implementation authorization.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/sparkcrm-contractable-shadowing-pilot-scope-v0
Status: done
Neighbors: Applied Pressure Agent | Research Agent | Compiler/Grammar Expert | Portfolio Architect Supervisor

[D] Decisions:
- Recommended `AvailabilityLedger::SlotMap` as the first pilot target.
- Kept first pilot mode as `primary_observed_only`; shadow candidate comparison
  is later unless explicitly authorized.
- Defined redacted receipt shape, digest policy, sampling gate, fail-open
  behavior, durable adapter dependency, sidecar boundary, and proof checklist.

[R] Recommendations:
- Ask Architect to accept this as scope only and route pressure review next.
- If accepted later, open a separate, narrow implementation authorization card
  in the correct Spark/Ruby Framework lane.
- Route synthetic Igniter-Lang pressure to
  `sparkcrm-availability-ledger-why-not-fixture-v0`.

[S] Signals:
- Spark CRM pressure is active applied-pressure source material, not canon.
- Availability why-not diagnostics provide strong value with bounded redaction.
- Durable observation adapter is a hard dependency before high-volume or
  production-adjacent receipt rollout.

[T] Tests / Proofs:
- Documentation-only slice.
- No code or package tests run.

[Files] Changed:
- `igniter-lang/docs/tracks/sparkcrm-contractable-shadowing-pilot-scope-v0.md`

[Q] Open Questions:
- Should the future implementation card include only primary-observed receipts,
  or also a named shadow candidate?
- Which lane owns the first redaction/digest helper: Spark app-local code or
  Igniter Ruby Framework package work?
- Should the future cross-lane letter be created before or after C3-A accepts
  the pilot scope?

[X] Rejected:
- Starting with `OrderPriceLedger::Finder` as the first pilot target.
- Treating receipts as source of truth.
- Blocking Spark business flow when a receipt is missing.
- Creating a letter file or package implementation from this card.

[Next] Proposed next slice:
- `sparkcrm-contractable-shadowing-pilot-scope-pressure-v0`
```
