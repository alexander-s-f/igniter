# Spark CRM Letter Guidance Alignment v0

Card: S3-R88-C0-O
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: sparkcrm-letter-guidance-alignment-v0
Route: UPDATE
Status: done
Date: 2026-05-20
Authority: org-sidecar guidance alignment / non-canon / non-implementation

---

## Goal

Align the R88 cross-lane letter route with the Base Role, Portfolio guidance
log, Portfolio reporting protocol, R87 status curation, and the accepted R87
pilot-scope decision before the Bridge Agent writes the letter packet.

This track does not create cross-lane commitments and does not authorize
implementation.

---

## Read Set

```text
igniter-lang/roles/base-role.md
igniter-lang/docs/org/portfolio-guidance-log-v0.md
igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md
igniter-lang/docs/gates/sparkcrm-contractable-shadowing-pilot-scope-decision-v0.md
```

---

## Active Guidance

Active guidance id:

```text
PG-2026-05-20-01
```

Type:

```text
directive
```

Status:

```text
active
```

Affected lanes:

```text
Spark CRM
Igniter Ruby Framework
Igniter-Lang
Igniter Ledger sidecar
```

Important authority boundary:

```text
Guidance is not a code card.
Guidance does not authorize implementation by itself.
```

---

## Guidance Checklist For The Letter

The C1-P1 letter should preserve these active constraints:

- Keep the Spark x Igniter adoption path in `primary_observed_only` until one
  redacted receipt path is proven end-to-end.
- Spark chooses or confirms the operational target and redaction feasibility.
- Ruby Framework defines the minimal observed-service wrapper and receipt API.
- Igniter-Lang waits for stable receipt vocabulary before opening fixtures.
- Igniter Ledger sidecar remains optional/later and must not be treated as
  source of truth.

The letter should explicitly avoid:

- opening shadow candidate implementation;
- generalizing the Ruby Framework API before one pilot works;
- encoding real Spark class names, raw identifiers, or private data in
  public/shared Igniter-Lang fixtures;
- treating sidecar receipts as source of truth;
- treating the cross-lane letter as a decision or implementation authority.

The letter should ask or preserve these expected response questions:

1. Can Spark emit useful why-not availability summaries without raw slot
   payloads?
2. What is the minimal receipt shape Ruby can support without new package code?
3. Which sanitized fixture vocabulary should Igniter-Lang wait for?

---

## R87 Alignment

R87 accepted:

```text
target: AvailabilityLedger::SlotMap
theme: why-not availability diagnostics
mode: primary_observed_only
status: accepted-scope-letter-next-implementation-held
```

The R88 letter route should keep the R87 decision boundary intact:

```text
letter = communication / handoff / request
letter != decision
letter != Portfolio close report
letter != implementation authorization
letter != canon
```

The R87 decision also requires future implementation authorization to define:

- `service_ref` abstraction convention;
- idempotency key generation;
- low-volume storage behavior;
- Spark CRM lane confirmation;
- proof/parity evidence;
- redaction and fail-open behavior.

Those items may be referenced as future preconditions, not as completed work.

---

## R88 Portfolio Closure Packet

Confirmed default R88 Portfolio closure packet:

```text
igniter-lang/docs/tracks/stage3-round88-status-curation-v0.md
```

Use it as the Portfolio report packet if it includes:

```text
status
executive summary
completed cards
changed files
evidence
risks / drift
cross-lane requests
recommended next route
decisions needed from Portfolio, if any
```

Fallback packet, only if status curation cannot satisfy the reporting fields:

```text
igniter-lang/docs/reports/s3-r88-round-report.md
```

Decision rule:

```text
stage3-round88-status-curation-v0 sufficient -> no extra report file
stage3-round88-status-curation-v0 insufficient -> add s3-r88-round-report.md
```

---

## Letter Directory Check

Observed org-sidecar directories:

```text
igniter-lang/docs/org/
igniter-lang/docs/org/memory-contracts/
igniter-lang/docs/org/tracks/
igniter-lang/docs/org/reports/
igniter-lang/docs/org/indexes/
```

`igniter-lang/docs/org/letters/` does not currently exist.

If C1-P1 writes the letter, it may create:

```text
igniter-lang/docs/org/letters/
igniter-lang/docs/org/letters/sparkcrm-contractable-shadowing-pilot-scope-letter-v0.md
```

---

## Letter Status Recommendation

Recommended C1-P1 letter status:

```text
draft
```

Rationale:

- the letter is a cross-lane request/handoff, not a decision;
- Spark still needs to choose or confirm the operational target and redaction
  feasibility;
- Ruby Framework still needs to answer the minimal wrapper/receipt API question;
- Igniter-Lang should wait for stable receipt vocabulary before fixture work;
- Portfolio guidance is active and expects responses in later reports/letters.

Suggested later transition:

```text
draft -> sent
```

Only after the Bridge Agent has produced a complete packet and the local
supervisor/user chooses to route it across lanes.

---

## Closed Surfaces

This org-sidecar alignment track does not authorize:

- cross-lane commitments;
- pilot implementation;
- shadow candidate implementation;
- Spark CRM code inspection;
- Spark CRM code edits;
- Spark production integration;
- Spark production behavior changes;
- real Spark data, raw identifiers, endpoints, credentials, provider payloads,
  customer records, technician/user raw records, phone/email data, or
  infrastructure details in public/shared docs or fixtures;
- Igniter Ruby Framework code edits;
- Ruby Framework API generalization before one pilot works;
- Igniter Ledger sidecar implementation;
- treating sidecar receipts as source of truth;
- Igniter-Lang compiler/runtime code edits;
- Igniter-Lang fixtures before stable receipt vocabulary;
- canon/spec/proposal mutation;
- public API or CLI widening;
- loader/report or CompatibilityReport behavior;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`, signing,
  dispatch, RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP,
  cache, or production widening;
- treating a cross-lane letter as a decision, report packet, canon, or
  implementation authorization.

---

## Disposition

Recommendation:

```text
continue with C1-P1 as a draft cross-lane letter packet
preserve PG-2026-05-20-01 as active guidance
close R88 for Portfolio via stage3-round88-status-curation-v0.md
add s3-r88-round-report.md only if status curation is insufficient
```

No implementation is authorized by this track.
