# Practical RC, Ledger Stress, Spark Cross-Lane Decision v0

Card: S3-R166-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: practical-rc-ledger-spark-crosslane-decision-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R166-C1-A
- S3-R166-C2-P1
- S3-R166-C3-P1

---

## Inputs Read

Lang:

- `igniter-lang/docs/tracks/compiler-release-scope-aware-harness-update-acceptance-prep-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-scope-aware-update-v0.md`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round165-status-curation-v0.md`

Ruby Framework / Igniter Ledger:

- `.agents/ruby-framework/reports/s3-r166-c2-p1-igniter-ledger-server-stress-boundary-probe.md`
- `.agents/ruby-framework/tracks/igniter-ledger-server-stress-boundary-probe-v0.md`

Spark CRM:

- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-24-SPARK-SHADOW-SCHEDULER-AVAILABILITY-BOUNDARY.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/docs/domains/operator-search-shadow-flow.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/docs/domains/ledger-service-facade-vision.md`
- `/Users/alex/dev/projects/sparkcrm/app/services/spark/ledgers/availability/facade.rb`
- `/Users/alex/dev/projects/sparkcrm/app/services/spark/ledgers/backends/active_record/availability.rb`
- `/Users/alex/dev/projects/sparkcrm/app/services/spark/ledgers/availability/schedule_grid.rb`
- `/Users/alex/dev/projects/sparkcrm/app/services/operators/dashboard/shadow_scheduler.rb`
- `/Users/alex/dev/projects/sparkcrm/spec/services/spark/ledgers/availability_facade_spec.rb`
- `/Users/alex/dev/projects/sparkcrm/spec/services/spark/ledgers/backends/active_record/availability_spec.rb`

---

## Decision

Decision:

```text
accept Lang scope-aware harness update
authorize next official first-RC evidence-gathering authorization review
accept Ruby Ledger bounded local stress probe as local evidence
open Ruby Ledger state-plane/concurrency hardening design/proof next
accept Spark schedule_grid facade direction as the correct compatibility path
require Spark traceability/report/observe follow-up before broader expansion
```

This decision does not authorize official RC evidence gathering itself. It only
authorizes the next authorization-review card that may decide whether official
first-RC evidence gathering can begin.

This decision does not authorize release execution, public release/demo claims,
Spark production integration, Spark authority switch, or Igniter Ledger
production binding.

---

## Lang Disposition

Disposition:

```text
accepted
```

The scope-aware compiler release harness update is accepted at Portfolio level.

Accepted evidence:

- top-level harness status: `PASS`;
- command matrix: `14/14 PASS`;
- failed checks: `0`;
- hold reasons: `0`;
- `branch_conditional_if_expr.status`: `out_of_scope`;
- `release_scope.excluded_features`: includes `branch_conditional_if_expr`;
- `release_scope.exclusion_basis`: references S3-R164-C4-A;
- `no_branch_conditional_claim`: present;
- no compiler/library behavior widened;
- no official RC evidence label claimed by the R165 output.

Next Lang route may open:

```text
compiler-release-official-first-rc-evidence-gathering-authorization-review-v0
Mode: authorization review only
```

The next review must define exact official evidence output scope, labels,
command matrix, proof artifacts, and release/public non-claim preservation.

---

## Ruby Ledger Disposition

Disposition:

```text
accepted_as_bounded_local_probe
follow_up_hardening_required_before_spark_server_adoption_pressure
```

Accepted evidence:

- bounded local stress probe completed;
- focused server/transport specs: `80 examples, 0 failures`;
- legacy `StoreServer` + `NetworkBackend` mixed load: `550` writes and `150`
  replay calls with `0` errors;
- file-backed legacy server replayed `160` concurrent writes after restart;
- direct Rack dispatch and TCP envelope dispatch survived bounded mixed local
  probes;
- no package code, public API, release artifact, or production claim was
  changed.

Key accepted caveat:

```text
StoreServer#protocol currently creates a fresh independent store for HTTP/TCP
envelope adapters. Spark must not assume all server transports share one fact
plane.
```

Next Ruby route should open:

```text
ledger-server-envelope-state-plane-and-concurrency-contract-v0
Mode: design/proof hardening
```

Required questions:

- should legacy NetworkBackend and HTTP/TCP WireEnvelope adapters share one
  store/fact plane, or remain intentionally separate;
- what serialization/concurrency contract applies to envelope dispatch;
- what bounded local stress smoke should become repeatable package evidence;
- what Spark may safely assume from a client/adapter boundary.

No production benchmark, production readiness claim, or Spark source-of-truth
claim is accepted.

---

## Spark Disposition

Disposition:

```text
accept_schedule_grid_facade_direction
accept_first_slice_as_compatibility_aligned_if_formal_report_is_backfilled
```

The Spark direction is accepted:

- `Spark::Ledgers.availability.schedule_grid(...)` belongs under the Spark
  ledger facade umbrella;
- ActiveRecord backend is the correct current backend;
- result shape must remain DTO/reference-based;
- booking links must stay outside the ledger facade, with only bounded
  `booking_evidence` returned;
- authority remains `:observational`;
- legacy scheduler and production authority remain unchanged.

Observed implementation evidence:

- `Spark::Ledgers::Availability::Facade#schedule_grid` delegates to backend;
- ActiveRecord backend builds DTO/reference `ScheduleGrid` results;
- `Operators::Dashboard::ShadowScheduler` delegates through
  `Spark::Ledgers.availability.schedule_grid`;
- specs exist for facade delegation and ActiveRecord DTO/aggregate observed
  summary;
- Spark git status was clean when checked from Portfolio.

Traceability note:

```text
No separate S3-R166-C3-P1 report packet was found under the expected schedule
grid report name. The implementation and docs are visible, but the next Spark
card should backfill/report the slice explicitly before broader expansion.
```

Next Spark route should open:

```text
availability-schedule-grid-facade-report-and-shadow-observe-p2
Mode: report/observe/hardening, no authority switch
```

Required boundary:

- formal report packet with changed files, commands, specs, and result shape;
- run/record Shadow Scheduler behavior evidence;
- confirm no raw ActiveRecord objects cross the facade result contract;
- confirm `booking_evidence` remains bounded and Rails route generation remains
  in UI/component layer;
- keep legacy scheduler authority unchanged;
- no Igniter backend yet;
- no Spark production integration or source-of-truth switch.

---

## Cross-Lane Compatibility Pressure

Accepted pressure routing:

```text
Spark schedule_grid pressure feeds Ruby Ledger state-plane/concurrency design.
Lang RC remains first priority and should not be delayed by Spark/Ruby hardening.
```

Near-term ordering:

1. Lang: open official first-RC evidence-gathering authorization review.
2. Ruby: harden Ledger server state-plane/concurrency contract.
3. Spark: backfill/report and observe `schedule_grid` facade slice.

Spark/Igniter fixture or adapter design should wait until:

- Lang RC evidence authorization path is decided; and
- Spark schedule_grid report/observe packet is formal enough to sanitize.

The likely future fixture family is:

```text
spark_availability_schedule_grid_observation
```

but this decision does not open that fixture route yet.

---

## Closed Surfaces

This decision does not authorize:

- official first-RC evidence gathering;
- release execution;
- public release or demo claims;
- branch/conditional implementation;
- parser, TypeChecker, SemanticIR, assembler, compiler, runtime, or public
  API/CLI widening in Igniter-Lang;
- Spark production integration;
- Spark production authority switch;
- Igniter Ledger production binding;
- Igniter Ledger production benchmark or source-of-truth claim;
- direct Spark code/data access for Igniter-Lang agents;
- RuntimeMachine/Gate 3 widening;
- Ledger/TBackend production binding;
- BiHistory, stream/OLAP, cache, signing, or deployment.

---

## Exact Next Dispatch Recommendation

```text
R167 = [C1-A, C2-P1, C3-P1] -> C4-S
```

```text
Card: S3-R167-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-official-first-rc-evidence-gathering-authorization-review-v0
Route: UPDATE

Goal:
Decide whether official first-RC evidence gathering may open under the narrowed
scope-aware PASS harness.

Scope:
- Read R166 Lang packet and this Portfolio decision.
- Define exact official evidence-gathering scope if authorizing.
- Preserve release execution and public claims closed.

Do not gather RC evidence in this card.
Do not authorize release execution or public claims.
```

```text
Card: S3-R167-C2-P1
Agent: [Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Track: ledger-server-envelope-state-plane-and-concurrency-contract-v0
Route: UPDATE

Goal:
Design/prove the Ledger server state-plane and envelope concurrency contract
needed before Spark-style server adoption pressure grows.

Scope:
- Decide whether legacy NetworkBackend and HTTP/TCP WireEnvelope adapters share
  one fact plane or remain intentionally separate.
- Define/document envelope dispatch concurrency policy.
- Add or propose focused specs/proofs for the chosen boundary.
- Keep evidence local and non-production.

Do not release gems.
Do not make production readiness claims.
Do not authorize Spark production binding.
```

```text
Card: S3-R167-C3-P1
Agent: [Spark CRM App Supervisor]
Role: spark-app-supervisor
Route: FAST_LANE
Track: availability-schedule-grid-facade-report-and-shadow-observe-p2

Goal:
Backfill/report the `Spark::Ledgers.availability.schedule_grid` facade slice
and run bounded Shadow Scheduler observation/hardening without authority switch.

Scope:
- Produce a formal report packet for the C3 slice.
- Record changed files, commands, specs, DTO/result shape, and known caveats.
- Confirm Shadow Scheduler behavior remains preserved.
- Confirm no raw ActiveRecord objects cross the facade result contract.
- Confirm booking links remain UI-owned and facade returns only bounded
  `booking_evidence`.

Do not introduce Igniter backend.
Do not switch production authority.
Do not broaden beyond Shadow Scheduler/facade observation.
```

```text
Card: S3-R167-C4-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round167-status-curation-v0
Route: UPDATE

Goal:
Curate R167 status after Portfolio/Ruby/Spark packets land.
```

---

## Compact Receipt

```text
card: S3-R166-C4-A
track: practical-rc-ledger-spark-crosslane-decision-v0
status: done
lang_scope_aware_harness_update: accepted
lang_harness_status: PASS
official_first_rc_evidence_gathering_authorization_review: may_open_next
official_rc_evidence_gathering: still_closed
ruby_ledger_stress_probe: accepted_local_only
ruby_next: ledger-server-envelope-state-plane-and-concurrency-contract-v0
spark_schedule_grid_facade_direction: accepted
spark_first_slice: compatibility_aligned_needs_formal_report_backfill
spark_next: availability-schedule-grid-facade-report-and-shadow-observe-p2
compiler_release_priority: preserved
release_execution_authorized: no
public_claims_authorized: no
spark_production_integration_authorized: no
igniter_ledger_production_binding_authorized: no
```
