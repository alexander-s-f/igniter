# Portfolio Guidance Log v0

Status: active
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-20

---

## Purpose

This is the Portfolio guidance channel.

Local supervisors read this channel to receive high-level direction without
waiting for Portfolio to cut their local rounds.

Guidance is not a card and does not authorize implementation by itself.

---

## Types

| Type | Meaning |
| --- | --- |
| `directive` | high-level direction; local supervisors self-plan around it |
| `nudge` | soft correction; consider in next local planning |
| `constraint` | guardrail; do not cross without Portfolio decision |
| `question` | information request; answer in report/letter/track |

---

## PG-2026-05-20-01

Type: directive
Status: active
Lanes: Spark CRM, Igniter Ruby Framework, Igniter-Lang, Igniter Ledger sidecar
Source: R86/R87 Spark x Igniter applied-pressure chain

### Signal

Keep the Spark x Igniter adoption path in `primary_observed_only` mode until
one redacted receipt path is proven end-to-end.

### Direction

- Spark chooses operational target and confirms redaction feasibility.
- Ruby Framework defines the minimal observed-service wrapper and receipt API.
- Igniter-Lang waits for stable receipt vocabulary before opening fixtures.
- Igniter Ledger sidecar remains optional/later.

### Do Not

- Do not open shadow candidate implementation yet.
- Do not generalize the Ruby Framework API before one pilot works.
- Do not encode real Spark class names, raw identifiers, or private data in
  public/shared Igniter-Lang fixtures.
- Do not treat sidecar receipts as source of truth.
- Do not treat cross-lane letters as decisions or implementation authority.

### Expected Response

Next relevant reports should answer:

1. Can Spark emit useful why-not availability summaries without raw slot
   payloads?
2. What is the minimal receipt shape Ruby can support without new package code?
3. Which sanitized fixture vocabulary should Igniter-Lang wait for?

### Review Trigger

Review this directive after:

- Spark confirms or rejects `AvailabilityLedger::SlotMap` as operational pilot
  target;
- Ruby Framework reports the minimum observed-service wrapper/receipt API;
- Spark produces a redaction feasibility packet or fast-lane receipt.
