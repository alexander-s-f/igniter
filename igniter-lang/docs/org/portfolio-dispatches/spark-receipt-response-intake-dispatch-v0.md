# Portfolio Dispatch: Spark Receipt Response Intake v0

Status: ready-to-dispatch
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-20
Guidance: `PG-2026-05-20-01`

---

## Dispatch

```text
Portfolio Dispatch PD-2026-05-20-01 =
  [SPARK-P1, RUBY-P1] -> LANG-P2 -> PORT-S
```

Pattern:

- Run `SPARK-P1` and `RUBY-P1` in parallel.
- Run `LANG-P2` only after both response packets exist.
- Run `PORT-S` after `LANG-P2` closes.
- Local supervisors self-plan their own local cards/agents.
- Portfolio reads only final report packets unless a report names a blocker,
  conflict, or decision request.

This dispatch does not authorize shadow candidate implementation, public
Spark-Igniter integration, Igniter-Lang fixtures, Ledger sidecar implementation,
release, production behavior, or broad API generalization.

---

## Card SPARK-P1

```text
Card: PORT-2026-05-20-SPARK-P1
Agent: [Spark CRM App Supervisor]
Role: spark-crm-app-supervisor
Route: FAST_LANE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/sparkcrm
Guidance: PG-2026-05-20-01

Goal:
Close the Spark-side response to the active Portfolio guidance question:
"Can Spark emit useful why-not availability summaries without raw slot payloads?"

Scope:
- Read:
  - /Users/alex/dev/projects/igniter/igniter-lang/roles/base-role.md
  - /Users/alex/dev/projects/igniter/igniter-lang/docs/org/portfolio-guidance-log-v0.md
  - /Users/alex/dev/projects/igniter/igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
  - /Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/2026-05-20-spark-availability-receipt-feasibility.md
  - current Spark `.agents` status/fast-lane docs
- Confirm whether the current Spark observed availability receipt path is:
  - primary_observed_only;
  - fail-open;
  - aggregate/redacted enough for cross-lane vocabulary pressure;
  - non-authoritative for business decisions;
  - safe to use as sanitized fixture pressure after redaction.
- If you do local work, keep it Spark-owned and fast-lane:
  - no shadow candidate;
  - no production authority change;
  - no raw payloads in reports;
  - no cross-lane implementation promises.
- Prefer a compact report packet over raw track sprawl.

Deliver:
- Spark report packet under:
  `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/`
- Explicit answer:
  `useful_without_raw_slot_payloads = yes/no/partial`
- Redaction allow-list / deny-list summary.
- Current persisted/read surface status.
- Next Spark recommendation:
  hold / metrics-read-surface / deploy-observe / request Portfolio decision.
```

---

## Card RUBY-P1

```text
Card: PORT-2026-05-20-RUBY-P1
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/igniter
Guidance: PG-2026-05-20-01

Goal:
Close the Ruby Framework-side response to the active Portfolio guidance
question: "What is the minimal receipt shape Ruby can support without new
package generalization?"

Scope:
- Read:
  - igniter-lang/roles/base-role.md
  - igniter-lang/docs/org/portfolio-guidance-log-v0.md
  - igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
  - .agents/ruby-framework/reports/ruby-framework-current-state-analysis-round-v0.md
  - .agents/ruby-framework/reports/ruby-framework-rails-contracts-ledger-proof-round-v0.md
  - /Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/2026-05-20-spark-availability-receipt-feasibility.md
- Define the minimum observed-service wrapper / receipt API for one app-local
  Spark pilot.
- Distinguish:
  - package surface already available;
  - app-local adapter/wrapper expected from Spark;
  - proof-only or example-only material;
  - broad package API generalization that remains closed.
- If running proof work, prefer a clean install/use smoke against the Rails
  proof app or temp app.
- Do not publish gems.
- Do not open shadow candidate implementation.
- Do not require Ledger sidecar as source of truth.

Deliver:
- Ruby Framework report packet under `.agents/ruby-framework/reports/`.
- Minimal receipt shape Ruby can support now.
- Required proof before any release/pilot recommendation.
- Clear answer on whether new package code is needed for the first pilot.
- Next Ruby recommendation:
  hold / clean-install-smoke / recipe-doc / release-readiness-review.
```

---

## Card LANG-P2

```text
Card: PORT-2026-05-20-LANG-P2
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/igniter
Depends on:
- PORT-2026-05-20-SPARK-P1
- PORT-2026-05-20-RUBY-P1
Guidance: PG-2026-05-20-01

Goal:
Create the Igniter-Lang intake map for sanitized Spark availability receipt
vocabulary, without opening fixtures/spec/compiler work yet.

Scope:
- Read:
  - igniter-lang/roles/base-role.md
  - igniter-lang/docs/org/portfolio-guidance-log-v0.md
  - igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
  - igniter-lang/docs/tracks/stage3-round88-status-curation-v0.md
  - Spark P1 report packet
  - Ruby P1 report packet
- Extract only sanitized candidate vocabulary:
  - abstract service ref;
  - observation id shape;
  - input/output digest shape;
  - reason-count vocabulary;
  - sampling / fail-open receipt status;
  - idempotency key policy placeholder if available.
- Mark each item:
  - stable;
  - candidate;
  - Spark-owned;
  - Ruby-owned;
  - forbidden/private;
  - not ready for fixtures.
- Do not create fixtures.
- Do not update spec/proposals.
- Do not edit compiler/runtime code.
- Do not treat Spark class names/raw ids as public Igniter-Lang vocabulary.

Deliver:
- Intake/map doc under `igniter-lang/docs/org/indexes/` or
  `igniter-lang/docs/tracks/`.
- Compact report/status packet for Portfolio.
- Recommendation:
  hold / open sanitized fixture design / ask Spark/Ruby follow-up.
```

---

## Card PORT-S

```text
Card: PORT-2026-05-20-PORT-S
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Route: UPDATE
Parent: [User]
Workspace: /Users/alex/dev/projects/igniter
Depends on:
- PORT-2026-05-20-LANG-P2

Goal:
Accept the supervisor response packets, update Portfolio guidance if needed,
and choose the next cross-lane vector.

Scope:
- Read:
  - Spark P1 report packet
  - Ruby P1 report packet
  - Lang P2 intake/report packet
  - igniter-lang/docs/org/portfolio-guidance-log-v0.md
- Decide whether `PG-2026-05-20-01` remains active, is amended, or is closed.
- Decide whether one redacted receipt path is sufficiently proven to open:
  - Spark metrics-read/deploy-observe continuation;
  - Ruby clean-install smoke / recipe-doc / release-readiness review;
  - Igniter-Lang sanitized fixture design;
  - or hold all cross-lane widening.
- Do not authorize implementation unless a separate explicit card says so.

Deliver:
- Compact Portfolio summary to user.
- Recommended next dispatch pattern.
- Guidance log update recommendation.
- Any exact supervisor cards for the next wave.
```
