# Spark CRM Inbox Disposition And Pressure Routing v0

Card: S3-R86-C0-O
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: sparkcrm-inbox-disposition-and-pressure-routing-v0
Route: UPDATE
Status: done
Date: 2026-05-20
Authority: org-sidecar routing / non-canon / non-implementation

---

## Goal

Route the Spark CRM Ledger x Igniter applicability inbox document into the
documentation lifecycle so it becomes an active applied-pressure source instead
of a zombie inbox item.

---

## Read Set

```text
igniter-lang/docs/inbox/sparkcrm-ledger-igniter-applicability-analysis-2026-05-20.md
igniter-lang/docs/inbox/README.md
igniter-lang/docs/applied-pressure-directions.md
igniter-lang/docs/value-index.md
```

---

## Disposition

The inbox document is accepted as:

```text
active applied-pressure source
Ruby framework adoption pressure
Igniter-Lang fixture/spec pressure
Igniter Ledger sidecar pressure
not canon
not implementation authority
not Spark CRM production authority
```

Recommended lifecycle status:

```text
promoted-track source / active applied-pressure source
```

The source remains useful because it contains a concrete inventory of Spark CRM
ledger-shaped business processes:

```text
Availability Ledger
Bid Ledger
Order Price Ledger
Service Call Price Ledger
Company Assignment Ledger
Cross-cutting ledger spine
```

It should be read as pressure evidence, not as a specification.

---

## Classification

| Dimension | Disposition |
| --- | --- |
| Ruby framework adoption | Active pressure for `igniter-contracts` / `igniter-embed` contractable shadowing, receipts, redaction, async adapter, and Rails host setup. |
| Igniter Ledger | Active sidecar/receipt pressure; not primary SQL ledger replacement authority. |
| Igniter-Lang | Active fixture/spec pressure for bitemporal availability, fractal price ledgers, active-at assignment, interval validity, and compaction receipts. |
| Spark CRM code | Read-only source context; no code authority. |
| Canon | None. Source can inform tracks/proposals only after separate governance. |
| Implementation | None. Any Spark/Igniter implementation needs separate card and authority. |

---

## Value Signals

The strongest reusable signals:

```text
Spark CRM already contains contract-shaped business truth.
Immediate value is observation, shadowing, receipts, and explanations.
Igniter Ledger is best as sidecar first, not primary database replacement.
Igniter-Lang should absorb Spark as fixture/spec pressure, not production runtime.
The reusable language pressure is interval validity + bitemporal known-time + hierarchical scope-chain explanation.
```

Concrete pressure lanes:

```text
P0 contractable shadowing of existing ledger services
P1 Spark ledger receipt vocabulary
P2 fractal scope ledger fixture
P3 availability bitemporal correction fixture
P4 Igniter Ledger sidecar receipt sink proof
P5 Postgres/TBackend bridge design
```

---

## C4-A Disposition Recommendation

Recommendation:

```text
accept routing as active applied-pressure source
keep source non-canon and non-authoritative
open/allow a long-running applied-pressure lane only if Architect wants it
do not promote to proposal or implementation yet
```

Suggested status wording for inbox:

```text
promoted-track / active-pressure-source
```

Suggested immediate next track:

```text
sparkcrm-igniter-adoption-readiness-map-v0
```

Purpose:

```text
Convert the inbox analysis into a bounded readiness map:
  what can be done now with igniter-contracts/embed,
  what belongs to Igniter Ledger sidecar research,
  what belongs to Igniter-Lang fixtures/spec pressure,
  and what is explicitly not ready for production replacement.
```

---

## Suggested Long-Running Org Lane

Suggested lane:

```text
sparkcrm-applied-pressure-lane-v0
```

Mode:

```text
long-running org/applied-pressure sidecar
```

Responsibilities:

```text
track Spark-derived pressure without interrupting compiler/runtime rounds
maintain a compact Spark pressure index
route Spark signals into one of:
  Ruby framework adoption
  Ledger sidecar research
  Igniter-Lang fixture/spec pressure
  archive/source material
protect privacy and avoid raw production/customer data
return only compact signals that affect active language/compiler/runtime decisions
```

Non-authorizations:

```text
no Spark CRM code edits
no Igniter Ruby framework code edits
no Igniter-Lang implementation edits
no production data usage
no canon promotion
no runtime/Ledger replacement claim
```

---

## Exact Docs That Should Link To The Source

Updated by this card:

```text
igniter-lang/docs/inbox/README.md
igniter-lang/docs/value-index.md
```

Should link when the next lane opens:

```text
igniter-lang/docs/tracks/sparkcrm-igniter-adoption-readiness-map-v0.md
igniter-lang/docs/applied-pressure-directions.md
```

Should link later only if concrete fixtures are opened:

```text
igniter-lang/docs/tracks/sparkcrm-fractal-price-ledger-fixture-v0.md
igniter-lang/docs/tracks/sparkcrm-availability-ledger-why-not-fixture-v0.md
igniter-lang/docs/tracks/sparkcrm-ledger-sidecar-receipt-sink-v0.md
igniter-lang/docs/tracks/sparkcrm-ledger-bitemporal-delta-v0.md
```

Do not link from canon/spec/proposals until a separate governance decision
promotes a specific extracted idea.

---

## Inbox Cleanup Rule

Keep the inbox source visible while it actively feeds the next readiness map.
After the readiness map closes, move or copy the source to archive/history and
leave the active link in the readiness map.

Recommended future disposition after readiness map:

```text
archive as source material
```

---

## Return Summary

The Spark CRM applicability report is routed as active applied pressure, not
canon. It should feed a readiness map and possibly a long-running Spark applied
pressure lane. It should not authorize code, production migration, runtime
replacement, or Ledger/TBackend binding.
