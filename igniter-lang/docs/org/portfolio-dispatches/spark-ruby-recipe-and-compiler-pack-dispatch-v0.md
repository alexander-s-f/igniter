# Portfolio Dispatch: Spark/Ruby Recipe + Compiler Pack Boundary v0

Status: ready-to-dispatch
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-20
Guidance: `PG-2026-05-20-01`

---

## Dispatch

```text
Portfolio Dispatch PD-2026-05-20-02 =
  [SPARK-P2, RUBY-P2, LANG-COMPILER-P1] -> LANG-SPARK-P2 -> PORT-S
```

Pattern:

- Run `SPARK-P2`, `RUBY-P2`, and `LANG-COMPILER-P1` in parallel.
- Run `LANG-SPARK-P2` only after both Spark and Ruby response packets exist.
- Run `PORT-S` after `LANG-SPARK-P2` and `LANG-COMPILER-P1` close.
- Local supervisors self-plan local cards and agents.
- Portfolio reads final report packets first, then deep-dives only if a report
  names a blocker, conflict, or decision request.

This dispatch deliberately keeps two lanes separate:

```text
Spark/Ruby applied adoption pressure != compiler mainline authority
```

This dispatch does not authorize shadow candidate implementation, public
Spark-Igniter integration, Igniter-Lang fixtures, Ledger sidecar implementation,
release, production behavior, compiler implementation, pack registry
implementation, public API/CLI widening, or broad API generalization.

---

## Card SPARK-P2

```text
Card: PORT-2026-05-20-SPARK-P2
Agent: [Spark CRM App Supervisor]
Role: spark-crm-app-supervisor
Route: FAST_LANE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/sparkcrm
Guidance: PG-2026-05-20-01

Goal:
Run the next Spark-side deploy-observe / read-surface slice for the observed
availability receipt path.

Scope:
- Read:
  - /Users/alex/dev/projects/igniter/igniter-lang/roles/base-role.md
  - /Users/alex/dev/projects/igniter/igniter-lang/docs/org/portfolio-guidance-log-v0.md
  - /Users/alex/dev/projects/igniter/igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
  - /Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-P1.md
  - current Spark `.agents` fast-lane docs
- Confirm whether the current generic metrics/MCP read surface is enough for
  deploy-observe, or whether a small dedicated receipt read surface is needed.
- Produce one sanitized persisted receipt example if available from local,
  staging, or safe synthetic persisted metrics.
- Keep the example redacted:
  - no raw slot payloads;
  - no real customer/provider/technician/company/user/contact data;
  - no raw production dates/times unless deliberately synthetic;
  - no endpoints, credentials, tokens, or infrastructure details.
- Preserve:
  - primary_observed_only;
  - fail-open receipt behavior;
  - original Spark business result unchanged;
  - no shadow candidate;
  - no production authority change.

Deliver:
- Spark report packet under:
  `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/`
- Answer:
  `read_surface_status = generic_metrics_enough / dedicated_read_needed / hold`
- Sanitized persisted receipt example or exact reason it is not available yet.
- Recommendation:
  hold / deploy-observe / dedicated-read-surface / request Portfolio decision.
```

---

## Card RUBY-P2

```text
Card: PORT-2026-05-20-RUBY-P2
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/igniter
Guidance: PG-2026-05-20-01

Goal:
Create the concise Ruby Framework observed-service recipe doc from the Rails
proof and minimal receipt shape.

Scope:
- Read:
  - igniter-lang/roles/base-role.md
  - igniter-lang/docs/org/portfolio-guidance-log-v0.md
  - igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
  - .agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md
  - .agents/ruby-framework/reports/ruby-framework-rails-contracts-ledger-proof-round-v0.md
  - relevant Rails proof app docs/files only as needed
- Write a recipe that explains:
  - primary-only observed-service setup;
  - normalizer and redaction hook expectations;
  - store adapter protocol;
  - fail-open behavior;
  - event/observation receipt shape;
  - how Spark should stay app-local for the first pilot;
  - what remains closed before broad package API generalization.
- Keep it recipe/docs-only unless the local supervisor needs a tiny doc index
  update.
- Do not publish gems.
- Do not open release.
- Do not open shadow candidate implementation.
- Do not require Ledger sidecar as source of truth.

Deliver:
- Recipe doc under the Ruby Framework `.agents` surface or a suitable
  docs/examples location chosen by the Ruby Framework Supervisor.
- Ruby Framework report packet under `.agents/ruby-framework/reports/`.
- Recommendation:
  hold / release-readiness-review / Spark follow-up / package-doc sync.
```

---

## Card LANG-COMPILER-P1

```text
Card: S3-R90-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: compiler-pack-boundary-report-v0
Route: UPDATE
Parent: [Igniter-Lang Supervisor]
Workspace: /Users/alex/dev/projects/igniter

Goal:
Produce the no-code compiler pack boundary report authorized by
`compiler-mainline-next-axis-decision-v0`.

Scope:
- Read:
  - igniter-lang/docs/gates/compiler-mainline-next-axis-decision-v0.md
  - igniter-lang/docs/tracks/stage3-round89-status-curation-v0.md
  - R89 C0/C1/C2/C3/C4 outputs named in the status packet
  - current compiler/profile architecture direction and accepted PROP-036 /
    PROP-038 decisions as needed
- Map current compiler files, proof fixtures, OOF registries, fragment classes,
  report-only evidence, and strict terminal behavior into candidate
  Profile/Baseline/Pack boundaries.
- Include Ch6 / CompilationReport spec-lag disposition.
- Do not edit code.
- Do not edit Ch6 or other specs.
- Do not authorize implementation.
- Do not use Spark applied-pressure material as compiler authority.

Deliver:
- Track doc in `igniter-lang/docs/tracks/`
- Pack boundary table
- Pass/owner map
- OOF and fragment ownership map
- Proof fixture map
- Migration risk table
- `must_not_migrate_yet` list
- Recommended later proof/design slices
- Closed-surface list
```

---

## Card LANG-SPARK-P2

```text
Card: PORT-2026-05-20-LANG-SPARK-P2
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Workspace: /Users/alex/dev/projects/igniter
Depends on:
- PORT-2026-05-20-SPARK-P2
- PORT-2026-05-20-RUBY-P2
Guidance: PG-2026-05-20-01

Goal:
Recheck the Spark availability receipt vocabulary after Spark deploy-observe /
read-surface work and Ruby recipe-doc, without opening fixtures/spec/compiler
work unless a later Portfolio decision explicitly does so.

Scope:
- Read:
  - igniter-lang/roles/base-role.md
  - igniter-lang/docs/org/portfolio-guidance-log-v0.md
  - igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md
  - Spark P2 report packet
  - Ruby P2 report packet
- Update or supersede the intake map only if new evidence changes the
  classification.
- Explicitly answer:
  - is there one persisted redacted receipt example?
  - is `observation_id` stable or still absent?
  - are input/output digest envelopes stable?
  - are reason-count names stable?
  - is `available_ratio` vs `availability_ratio` resolved?
  - is idempotency policy still placeholder?
  - is fixture design ready or still held?
- Do not create fixtures.
- Do not update spec/proposals.
- Do not edit compiler/runtime code.
- Do not use Spark class names/raw ids as public Igniter-Lang vocabulary.

Deliver:
- Updated intake/map doc or a short hold report.
- Compact report/status packet for Portfolio.
- Recommendation:
  open sanitized fixture design / hold / ask Spark-Ruby follow-up.
```

---

## Card PORT-S

```text
Card: PORT-2026-05-20-PORT-S2
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Route: UPDATE
Parent: [User]
Workspace: /Users/alex/dev/projects/igniter
Depends on:
- PORT-2026-05-20-LANG-SPARK-P2
- S3-R90-C1-P1

Goal:
Accept the supervisor response packets, decide whether `PG-2026-05-20-01`
should remain active/amended/closed, and choose the next Portfolio vector.

Scope:
- Read:
  - Spark P2 report packet
  - Ruby P2 report packet
  - Lang Spark P2 intake/report packet
  - S3-R90-C1-P1 compiler pack boundary report
  - igniter-lang/docs/org/portfolio-guidance-log-v0.md
- Decide:
  - whether one redacted receipt path is proven enough for fixture design;
  - whether Spark should continue deploy-observe or add a dedicated read
    surface;
  - whether Ruby should move to release-readiness review;
  - whether compiler mainline can open pressure/review on the pack boundary
    report;
  - whether the next Portfolio dispatch should keep applied and compiler lanes
    parallel or temporarily focus one lane.
- Do not authorize implementation unless a separate explicit card says so.

Deliver:
- Compact Portfolio summary to user.
- Recommended next dispatch pattern.
- Guidance log update recommendation.
- Any exact supervisor cards for the next wave.
```
