# Ruby Framework Reports

Status: active
Owner: [Igniter Ruby Framework Supervisor]
Date: 2026-05-20

Use this directory for compact report packets returned to the Portfolio
Architect Supervisor.

Before writing a report, check:

```text
igniter-lang/docs/org/portfolio-guidance-log-v0.md
```

Core rule:

```text
No report packet -> lane round is not closed for Portfolio.
```

## Template

```text
# Round Report: ruby-framework <round/id>

Status: done | partial | blocked
Date:
Supervisor: [Igniter Ruby Framework Supervisor]
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
- guidance:
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

Do not make Portfolio rediscover local lane state from raw tracks when closing a
round.

Reports must surface decisions needed from Portfolio, changed files, evidence,
risks/drift, cross-lane requests, and the recommended next route. Portfolio
should only need to deep-read local tracks when the report points to a blocker,
decision, or surprising drift.
