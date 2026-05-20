# Letter: Spark CRM Contractable Shadowing Pilot Scope v0

Card: S3-R88-C1-P1
Agent: `[Igniter-Lang Bridge Agent]`
Role: bridge-agent
Track: `sparkcrm-contractable-shadowing-pilot-scope-letter-v0`
Depends on: S3-R88-C0-O
Status: draft
Date: 2026-05-20
Guidance: `PG-2026-05-20-01`

---

## From

`[Igniter-Lang Bridge Agent]`

---

## To

- Spark CRM lane / project owner or delegated Spark app reviewer
- Igniter Ruby Framework supervisor / package reviewer
- Igniter Ledger sidecar research owner
- Igniter-Lang Architect Supervisor / future fixture owner
- Portfolio Architect Supervisor, as context receiver

---

## Subject

Spark CRM contractable shadowing pilot scope: review/confirmation request only

---

## Status

```text
draft
```

This letter is a communication packet. It is not sent, received, answered, or
accepted until a later lane/supervisor action records that transition.

---

## Decision Requested

No implementation decision is requested by this letter.

Requested responses are review/confirmation only:

- Spark CRM: confirm or reject whether the accepted target is operationally
  acceptable for a low-volume, fail-open, `primary_observed_only` pilot.
- Igniter Ruby Framework: review the minimum observed-service wrapper and
  receipt API needs without broad package generalization.
- Igniter Ledger sidecar: confirm the sidecar remains optional/later and never
  source of truth for this pilot.
- Igniter-Lang: confirm it will wait for stable redacted receipt vocabulary
  before opening fixture/spec work.
- Portfolio: receive this as context/request material only, not a decision ask.

---

## Context Links

- `igniter-lang/docs/org/tracks/sparkcrm-letter-guidance-alignment-v0.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md`
- `igniter-lang/docs/gates/sparkcrm-contractable-shadowing-pilot-scope-decision-v0.md`
- `igniter-lang/docs/tracks/sparkcrm-contractable-shadowing-pilot-scope-v0.md`
- `igniter-lang/docs/discussions/sparkcrm-contractable-shadowing-pilot-scope-pressure-v0.md`

---

## Compact Payload

R87 accepted the Spark CRM contractable shadowing pilot scope as design/scope
only.

Accepted target:

```text
AvailabilityLedger::SlotMap
```

Recommended implementation-facing abstract service ref, to be confirmed later:

```text
availability_slotmap_v0
```

Accepted theme:

```text
why-not availability diagnostics
```

Accepted first mode:

```text
primary_observed_only
```

This means the existing Spark service remains the only authoritative decision
source. The pilot may observe and emit redacted diagnostics if later
implemented, but it must not change production output, user-visible behavior, or
Spark source-of-truth state.

Portfolio guidance `PG-2026-05-20-01` keeps the adoption path in
`primary_observed_only` until one redacted receipt path is proven end-to-end.

---

## Request To Spark CRM

Please review and answer:

1. Is `AvailabilityLedger::SlotMap` acceptable as the first operational target
   for a low-volume, fail-open, `primary_observed_only` pilot?
2. Can Spark emit useful why-not availability summaries without raw slot
   payloads?
3. Can those summaries be limited to redacted/digest-addressed data such as:
   reason counts, abstract service ref, observation id, input/output digests,
   evidence ref digests, sampling status, and fail-open write status?
4. Are there Spark-owned constraints around business date, technician/provider
   references, company/tenant references, schedule/off-schedule refs, or debug
   lookup that must be reflected before any implementation card?

Please do not implement from this letter.

---

## Request To Igniter Ruby Framework

Please review and answer:

1. What is the minimal observed-service wrapper needed for a single
   `primary_observed_only` Spark pilot?
2. What minimal receipt API can support one pilot without generalizing the
   package surface prematurely?
3. Can the first shape support:
   - abstract `service_ref`, not private class/file names;
   - redaction policy ref;
   - input/output digest fields;
   - reason count payload;
   - sampling decision;
   - fail-open receipt status;
   - idempotency key placeholder;
   - no raw customer/provider/technician/company/user/schedule/contact payloads?
4. Which parts must be app-local for the first pilot rather than package-level?
5. What proof would show that the wrapper preserves primary service output and
   does not block business flow when receipt construction or writing fails?

Please do not implement from this letter.

---

## Request To Igniter Ledger Sidecar

Please confirm:

- the sidecar receipt sink remains optional/later;
- no Ledger sidecar is required for the first low-volume pilot;
- sidecar receipts must not become Spark source of truth;
- no production TBackend/Ledger binding, replay, read-through, or Spark state
  reconstruction is opened by this letter.

Potential later sidecar review can focus on redacted receipt append, observation
lookup by id, idempotent append, and retention/compaction explanation research.

Please do not implement from this letter.

---

## Request To Igniter-Lang

Igniter-Lang should wait.

Known from Lang side:

- accepted pilot target is `AvailabilityLedger::SlotMap`;
- accepted mode is `primary_observed_only`;
- accepted pilot theme is why-not availability diagnostics;
- only sanitized synthetic fixture/spec pressure is allowed later;
- `sparkcrm-availability-ledger-why-not-fixture-v0` is a candidate only, not
  authorized fixture work.

Igniter-Lang must wait for:

- Spark confirmation that useful why-not summaries can be emitted without raw
  slot payloads;
- Ruby Framework answer on the minimal observed-service wrapper and receipt API;
- stable redacted receipt vocabulary;
- confirmation of abstract service ref and idempotency key policy;
- a separate Architect route before opening any fixture/spec work.

Igniter-Lang must not open fixtures from this letter.

---

## Active Guidance Answers

### What Is Known Now

- R87 accepted the pilot scope and selected `AvailabilityLedger::SlotMap`.
- First mode is `primary_observed_only`; shadow candidate implementation is not
  open.
- Primary Spark service remains authoritative.
- Receipts, if later implemented, must be redacted/digest-addressed and
  fail-open.
- Durable adapter is required before high-volume or production-adjacent rollout.
- Igniter Ledger sidecar is optional/later and not source of truth.

### What Must Be Answered By Spark

- Whether `AvailabilityLedger::SlotMap` is operationally acceptable as a pilot
  target.
- Whether useful why-not summaries can be emitted without raw slot payloads.
- Which availability summary fields are safe enough for redacted receipt
  vocabulary.
- Whether any Spark-owned operational constraints block or reshape the pilot.

### What Must Be Answered By Ruby Framework

- The minimal observed-service wrapper shape for one app-local pilot.
- The minimal receipt API that avoids broad package generalization.
- Which redaction, digest, sampling, fail-open, and idempotency helpers belong
  app-local first.
- What tests/proofs are required before implementation authorization.

### What Igniter-Lang Must Wait For

- Stable redacted receipt vocabulary.
- Spark redaction feasibility confirmation.
- Ruby Framework minimal wrapper/receipt API answer.
- A separate fixture/spec route if the sanitized vocabulary becomes stable.

---

## Requested Next Action

Recommended response owners:

| Lane | Requested owner | Response requested |
| --- | --- | --- |
| Spark CRM | Spark app owner or delegated Spark reviewer | Confirm/reject target and redaction feasibility. |
| Igniter Ruby Framework | Ruby Framework supervisor/package reviewer | Review minimal observed wrapper and receipt API needs. |
| Igniter Ledger sidecar | Ledger sidecar research owner | Confirm optional/later, not source-of-truth. |
| Igniter-Lang | Architect Supervisor / future fixture owner | Hold fixture work until receipt vocabulary stabilizes. |
| Portfolio | Portfolio Architect Supervisor | Receive as context; no decision requested unless later response creates a cross-lane conflict. |

Recommended next route after responses:

```text
sparkcrm-contractable-shadowing-letter-response-intake-v0
```

or equivalent lane-specific response packets, followed by an Architect decision
only if implementation or fixture work is proposed.

---

## Explicit Non-Authorization

This letter does not authorize:

- pilot implementation;
- shadow candidate implementation;
- Spark CRM code inspection;
- Spark CRM code edits;
- Spark production integration;
- Spark production behavior changes;
- real Spark data, raw identifiers, endpoints, credentials, provider payloads,
  customer records, technician/user raw records, phone/email data, or
  infrastructure details in public/shared docs, fixtures, receipts, reports, or
  sidecar examples;
- Igniter Ruby Framework code edits;
- Ruby Framework API generalization before one pilot works;
- Igniter Ledger sidecar implementation;
- treating sidecar receipts as source of truth;
- Igniter-Lang compiler/runtime code edits;
- Igniter-Lang fixtures before stable receipt vocabulary and a separate route;
- canon/spec/proposal mutation;
- public API or CLI widening;
- loader/report or CompatibilityReport behavior;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`, signing,
  dispatch, RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP,
  cache, or production widening;
- treating this letter as a decision, report packet, canon, implementation
  authority, or Portfolio closure packet.
