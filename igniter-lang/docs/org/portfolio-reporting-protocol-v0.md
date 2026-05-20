# Portfolio Reporting Protocol v0

Status: active
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-20

---

## Purpose

This protocol defines how lane supervisors report to the Portfolio Architect
Supervisor without forcing the portfolio layer to reread every track, card, and
discussion after each local round.

The portfolio layer coordinates:

- Igniter-Lang;
- Igniter Ruby Framework;
- Spark CRM;
- cross-lane letters, risks, and decisions.

It should read compact reports first and deep-dive only when a report contains
blockers, requested decisions, unusual drift, or cross-lane conflict.

---

## Rule

```text
No report packet -> lane round is not closed for Portfolio.
```

This is not bureaucracy. It is a context-protection rule.

Supervisors may work in different styles:

- Igniter-Lang may stay formal and use status-curation tracks.
- Igniter Ruby Framework may use lightweight reports under `.agents/`.
- Spark CRM may use fast-lane receipts for quick work and reports for
  medium/long work.

But every lane must return a compact report when asking the Portfolio layer to
accept a completed round or make a cross-lane decision.

---

## Default Report Locations

| Lane | Report location |
| --- | --- |
| Igniter-Lang | `igniter-lang/docs/reports/` or existing `igniter-lang/docs/tracks/stage3-round*-status-curation-v0.md` |
| Igniter Ruby Framework | `.agents/ruby-framework/reports/` |
| Spark CRM | `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/` or `.agents/reports/` if the lane stays in the root fast-lane surface |

If a lane already has a status-curation document with the same fields, it can be
used as the report packet.

---

## Report Packet Template

```text
# Round Report: <lane> <round/id>

Status: done | partial | blocked
Date:
Supervisor:
Scope:

## Executive Summary
- 3-7 bullets only.

## Decisions Needed From Portfolio
- [ ] ...

## Completed
- ...

## Changed Files
- ...

## Evidence
- tracks:
- gates:
- discussions:
- tests/proofs:

## Risks / Drift
- ...

## Cross-Lane Requests
To Ruby Framework:
To Igniter-Lang:
To Spark CRM:
To Portfolio:

## Recommended Next
- ...
```

---

## Portfolio Read Order

When the user says a lane round is complete, the Portfolio Architect Supervisor
should read:

1. the report packet;
2. `Decisions Needed From Portfolio`;
3. `Risks / Drift`;
4. evidence files only when the report points to blockers, requested decisions,
   or surprising claims.

Do not deep-read every track by default.

---

## Cross-Lane Letters

Letters are for requests and handoffs before or between reports.

Reports are for closure.

A report may reference letters, but a letter is not a round-close report unless
it explicitly includes the report packet fields.

---

## Fast Lane Exception

Spark CRM and other operational lanes may run fast experiments without a full
round report.

Fast-lane work needs only a receipt unless it asks Portfolio to:

- accept a lane round as closed;
- make a cross-lane decision;
- route work into another supervisor;
- update the shared roadmap;
- authorize implementation or production-risk work.

In those cases, convert the fast-lane receipt into a report packet.

---

## Anti-Patterns

- Asking Portfolio to "summarize the round" without a report packet.
- Making Portfolio rediscover local lane state from raw tracks every time.
- Treating a local supervisor's recommendation as cross-lane authority.
- Hiding blockers in long track docs instead of surfacing them in the report.
- Using reports as a place to re-litigate every detail.

---

## Compact Mnemonic

```text
Lane closes locally -> Report packet -> Portfolio reads -> Decision or next route.
```
