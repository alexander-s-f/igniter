# Portfolio Supervisor Additional Init Cards v0

Status: active packet
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-20

Use these cards to update local supervisors with the Portfolio reporting
protocol.

---

## Igniter-Lang Supervisor

```text
Card: LANG-PORT-REPORTING-INIT
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/igniter

Goal:
Adopt the Portfolio reporting protocol for Igniter-Lang lane closure.

Read:
- /Users/alex/dev/projects/igniter/igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
- /Users/alex/dev/projects/igniter/igniter-lang/docs/reports/README.md
- /Users/alex/dev/projects/igniter/igniter-lang/roles/portfolio-architect-supervisor.md
- current active Igniter-Lang status-curation track, if one exists

Rules:
- Existing `stage*-round*-status-curation` tracks may serve as report packets
  if they contain summary, evidence, blockers, cross-lane requests, and next
  route.
- If status curation is not enough for Portfolio review, create a compact
  report under `igniter-lang/docs/reports/`.
- Do not ask Portfolio to rediscover round state from all raw tracks.

Deliver:
- Confirm reporting protocol adopted.
- Name the report packet or status-curation equivalent that will close the next
  Igniter-Lang round for Portfolio.
```

---

## Igniter Ruby Framework Supervisor

```text
Card: RUBY-PORT-REPORTING-INIT
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/igniter

Goal:
Adopt the Portfolio reporting protocol for the Ruby Framework lane.

Read:
- /Users/alex/dev/projects/igniter/.agents/ruby-framework/README.md
- /Users/alex/dev/projects/igniter/.agents/ruby-framework/reports/README.md
- /Users/alex/dev/projects/igniter/igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
- /Users/alex/dev/projects/igniter/igniter-lang/roles/portfolio-architect-supervisor.md

Rules:
- At the end of every Ruby Framework lane round, write one compact report packet
  under `.agents/ruby-framework/reports/`.
- The report must surface decisions needed from Portfolio, changed files,
  evidence, risks/drift, cross-lane requests, and recommended next route.
- Do not require Portfolio to read every local track unless the report points to
  a blocker or decision.

Deliver:
- Confirm reporting protocol adopted.
- Create the next report filename you will use, or state that no round is open
  yet.
```

---

## Spark CRM App Supervisor

```text
Card: SPARK-PORT-REPORTING-INIT
Agent: [Spark CRM App Supervisor]
Role: spark-crm-app-supervisor
Route: FAST_LANE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/sparkcrm

Goal:
Adopt Portfolio report packets while preserving Spark's lightweight fast-lane
style.

Read:
- /Users/alex/dev/projects/sparkcrm/.agents/FAST_LANE.md
- /Users/alex/dev/projects/sparkcrm/.agents/operating-model.md
- /Users/alex/dev/projects/sparkcrm/.agents/spark-app/letters/outgoing/ if it exists
- /Users/alex/dev/projects/igniter/igniter-lang/docs/org/portfolio-reporting-protocol-v0.md

Rules:
- Fast-lane work may still close with a short Fast Lane Receipt.
- A Portfolio report packet is required only when asking Portfolio to accept a
  completed lane round, make a cross-lane decision, route work to another
  supervisor, update shared roadmap, or authorize higher-risk work.
- Put reports under `.agents/spark-app/reports/` if using the spark-app surface,
  otherwise `.agents/reports/`.
- Letters are requests/handoffs. Reports are closure packets.

Deliver:
- Confirm reporting protocol adopted.
- Create or name the Spark reports directory.
- State when you will use a fast-lane receipt vs a Portfolio report packet.
```
