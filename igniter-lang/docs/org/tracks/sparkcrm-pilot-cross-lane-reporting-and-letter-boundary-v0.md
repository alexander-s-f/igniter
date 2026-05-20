# Spark CRM Pilot Cross-Lane Reporting And Letter Boundary v0

Card: S3-R87-C0-O
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: sparkcrm-pilot-cross-lane-reporting-and-letter-boundary-v0
Route: UPDATE
Status: done
Date: 2026-05-20
Authority: org-sidecar reporting boundary / non-canon / non-implementation

---

## Goal

Prepare the cross-lane communication and Portfolio reporting boundary for the
Spark CRM contractable shadowing pilot scope round.

This track does not authorize implementation and does not create cross-lane
commitments.

---

## Read Set

```text
igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
igniter-lang/docs/reports/README.md
igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md
igniter-lang/docs/tracks/stage3-round86-status-curation-v0.md
```

---

## Portfolio Closure Packet

Confirmed default R87 Portfolio closure packet:

```text
igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md
```

Use the default status-curation track as the Portfolio report packet if it
contains the reporting fields required by the active protocol:

```text
status
executive summary
decisions needed from Portfolio
completed cards
changed files
evidence
risks / drift
cross-lane requests
recommended next route
```

Fallback packet, only if the R87 status-curation track cannot satisfy those
fields:

```text
igniter-lang/docs/reports/s3-r87-round-report.md
```

Decision rule:

```text
stage3-round87-status-curation-v0 sufficient -> no extra report file
stage3-round87-status-curation-v0 insufficient -> add s3-r87-round-report.md
```

The Portfolio rule remains:

```text
No report packet or status-curation equivalent -> lane round is not closed for Portfolio.
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

Do not create it from this card unless a later cross-lane communication card
explicitly opens letter writing.

---

## Letter Packet Recommendation

Recommended first letter directory:

```text
igniter-lang/docs/org/letters/
```

Recommended first letter packet file:

```text
igniter-lang/docs/org/letters/sparkcrm-contractable-shadowing-pilot-scope-letter-v0.md
```

Intended recipients:

```text
Bridge Agent
Architect Supervisor
Portfolio Architect Supervisor
Igniter Ruby Framework supervisor/implementation lane
Spark CRM project owner/stakeholders
Org Architect Supervisor as observer only
```

Intended purpose:

```text
handoff/request packet for the Spark CRM contractable shadowing pilot scope
```

Required letter boundary:

```text
letter = communication / handoff / request
letter != decision
letter != Portfolio close report
letter != implementation authorization
letter != canon
```

The letter may reference the R87 Portfolio closure packet, but it must not
replace it.

---

## Cross-Lane Boundary

R86 accepted only the next design/scope route:

```text
sparkcrm-contractable-shadowing-pilot-scope-v0
```

R87 cross-lane communication should preserve these invariants:

- existing Spark service remains authoritative;
- pilot scope/design may compare candidate targets;
- redacted receipts, digest policy, sampling, fail-open missing receipt, durable
  adapter dependency, optional sidecar, and proof/parity evidence may be scoped;
- Spark CRM pressure remains applied-pressure source material, not canon;
- implementation remains held pending separate Architect authorization.

---

## Closed Surfaces

This org-sidecar track does not authorize:

- Spark CRM code edits;
- Igniter Ruby Framework code edits;
- Igniter-Lang compiler/runtime/code edits;
- pilot implementation;
- production behavior changes;
- production data, credentials, endpoints, provider payloads, customer records,
  phone/email data, or infrastructure details in docs or fixtures;
- Spark primary-ledger replacement;
- Igniter Ledger as primary Spark database;
- production TBackend/Ledger binding for Spark;
- automatic Spark-to-Igniter migration;
- public `.igapp` operational policy deployment for Spark;
- report packet substitution by letter;
- turning a letter into a decision;
- turning a letter into canon;
- Portfolio round closure without a report packet or status-curation equivalent.

---

## Disposition

Recommendation:

```text
continue with R87 pilot scope/design
use stage3-round87-status-curation-v0.md as default Portfolio close packet
create s3-r87-round-report.md only if status curation is insufficient
prepare a letter packet only through a separate Bridge/cross-lane card
```

No implementation is authorized by this track.
