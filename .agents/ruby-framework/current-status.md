# Igniter Ruby Framework Adoption Lane - Current Status

Route: INIT
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Lane: ruby-framework
Track: spark-contractable-shadowing-adoption-plan-v0
Status: initialized-design-lane
Date: 2026-05-20

---

## Purpose

This lane coordinates Igniter Ruby framework adoption pressure for Spark-compatible
contractable shadowing and receipt infrastructure.

The lane is intentionally separate from Igniter-Lang compiler/spec work and from
Spark CRM implementation work. Its job is to shape the Ruby package adoption path
so Spark can observe current services, compare future candidates, and persist
redacted receipts without changing production authority.

## Source Material Read

- `AGENTS.md`
- `packages/igniter-contracts`
- `packages/igniter-embed`
- `packages/igniter-ledger`
- `packages/igniter-ledger-client`
- `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`
- `/Users/alex/dev/projects/sparkcrm/docs/agents/spark-ledger-igniter-friendly-roadmap.md`

## Adopted Ground Truth

R86 routes Spark CRM material as an active applied-pressure source, not canon and
not implementation authority.

Accepted near-term shape:

```text
existing Spark primary service
  -> observed-service or shadow contractable wrapper
  -> normalized comparison when candidate exists
  -> redacted observation/event receipts
  -> optional durable receipt sink
  -> proof before any production behavior change
```

## Package Boundary Map

`igniter-contracts` owns the embedded kernel and core `Contractable` service
protocol. It validates declared inputs/outputs at the protocol boundary and
normalizes service results into `outputs`, `observations`, `error`, `metadata`,
and `success`.

`igniter-embed` owns host-local contract registration and the contractable
wrapper for migration, observed-service mode, shadow mode, sampling, redaction,
async handoff descriptors, typed events, and canonical observation/event receipt
production.

`igniter-ledger` owns the durable Ledger substrate and
`ContractableReceiptSink`, which accepts Embed receipts via
`record_observation` / `record_event`, registers receipt descriptors, and can
write through either a local Ledger store or a LedgerClient.

`igniter-ledger-client` owns the protocol-first client boundary. Spark-facing or
package-level receipt adapters should prefer `client:` over coupling to Ledger
storage internals once the adoption path leaves local proof mode.

## Current Ruby Framework Readiness

- Core contractable services can declare role, stage, inputs, outputs, and
  metadata.
- Embed contractable wrappers preserve primary return values synchronously.
- Primary-only observed-service mode is supported.
- Shadow candidate mode is supported with normalization, differential reports,
  acceptance policies, sampling, async adapters, and typed events.
- Canonical receipt status values exist: `:ok`, `:diverged`,
  `:candidate_error`, `:acceptance_failed`, `:store_error`, and `:unsampled`.
- Event receipts link to observation receipts by `observation_id`.
- Ledger receipt sink can persist observations as keyed current facts and events
  as append-only history partitioned by `observation_id`.
- LedgerClient can carry the sink through the protocol boundary.

Current analysis:

- `tracks/ruby-framework-current-state-analysis-v0.md`

Analysis verdict:

```text
Ready now:
  app-local primary-only observation design
  existing Embed receipt vocabulary
  app-owned redaction allow-list
  app-owned record_observation / record_event adapter
  optional Ledger sidecar proof

Not ready / not authorized:
  shadow candidate implementation
  high-volume production-adjacent rollout
  generalized Rails adoption kit as public API
  Spark production authority switch
  Ledger source-of-truth usage
```

Verification:

```text
contracts + embed + ledger-client specs: 269 examples, 0 failures
ledger ContractableReceiptSink specs: 27 examples, 0 failures
```

Latest production-prep proof:

- `examples/rails_contracts_ledger/`
- `recipes/observed-service-receipt-recipe-v0.md`
- `reports/ruby-framework-rails-contracts-ledger-proof-round-v0.md`
- `reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`
- `reports/port-2026-05-20-ruby-p2-observed-service-recipe.md`
- `tracks/observed-service-recipe-package-doc-sync-v0.md`
- `reports/ruby-doc-p1-observed-service-package-doc-sync.md`
- `tracks/observed-service-fixture-doc-readiness-v0.md`
- `reports/ruby-fixture-p1-observed-service-doc-readiness.md`
- `tracks/igniter-embed-observed-service-doc-sync-v0.md`
- `reports/ruby-doc-p2-igniter-embed-observed-service-doc-sync.md`
- `tracks/ruby-framework-release-readiness-review-prep-v0.md`
- `reports/ruby-rel-p1-release-readiness-review-prep.md`
- `tracks/ruby-framework-release-readiness-review-v0.md`
- `reports/ruby-rel-p2-release-readiness-review.md`
- `tracks/ruby-release-execution-blocker-closure-plan-v0.md`
- `reports/ruby-rel-p3-blocker-closure-plan.md`
- `tracks/ruby-0-5-2-release-execution-preflight-v0.md`
- `reports/ruby-rel-p4-0-5-2-release-execution-preflight.md`
- `tracks/ruby-0-5-2-release-execution-approval-handoff-v0.md`
- `reports/ruby-rel-p5-0-5-2-release-execution-approval-handoff.md`
- `tracks/ruby-0-5-2-push-readiness-v0.md`
- `reports/ruby-push-p1-0-5-2-push-readiness.md`
- `tracks/ruby-0-5-2-publish-readiness-v0.md`
- `reports/ruby-publish-p1-0-5-2-publish-readiness.md`

Proof status:

```text
examples/contracts/differential.rb syntax/runtime: ok
Rails contracts/ledger example: 1 test, 24 assertions, 0 failures
Rails server smoke: http://127.0.0.1:3042/availability ok
root rake: 686 examples, 0 failures; RuboCop no offenses
ledger package specs: 1254 examples, 0 failures
gem build smoke: igniter, igniter-contracts, igniter-embed,
  igniter-extensions, igniter-ledger-client, igniter-ledger all build 0.5.1
clean installed-gem Rails proof smoke: pass
observed-service receipt recipe: filed
package-doc/release-readiness notes: filed
fixture docs readiness: filed
igniter-embed observed-service doc sync: filed
release-readiness review prep: filed
release-readiness review: HOLD for release execution
release blocker closure plan: filed
0.5.2 release execution preflight: filed
0.5.2 release execution boundary: approved and executed locally
0.5.2 push readiness: PASS, waiting for explicit push approval
0.5.2 publish readiness: PASS, waiting for explicit publish approval phrase
Rubygems publish/release: not run
```

## Active Risks

- Embed's default async adapter is a local Ruby thread. Spark production-adjacent
  volume requires a durable app adapter before rollout beyond very low-volume
  sampling.
- Redaction must be designed per Spark target before any receipt leaves local
  proof fixtures. Raw customer/provider payloads, credentials, and PII are
  closed.
- The current Ruby package APIs are pre-v1 and can change. Adoption cards should
  prefer proofable boundaries over broad compatibility promises.
- Spark target names in this lane are internal applied-pressure material. Public
  docs must abstract or remove those names.

## Closed Surfaces

This lane does not authorize:

- Spark CRM code edits;
- Igniter Ruby framework code edits;
- Spark production behavior changes;
- replacement of Spark primary services;
- real Spark data, credentials, endpoints, provider payloads, customer records,
  phone/email data, or raw infrastructure details in artifacts;
- high-volume receipt rollout without a durable queue/outbox adapter;
- Ledger as Spark source of truth;
- `.igapp` operational deployment for Spark;
- Igniter-Lang runtime execution of Spark decisions;
- compiler, parser, TypeChecker, public CLI/API, or strict-refusal changes.

## R87 Round Context

R87 coordinates Spark CRM contractable shadowing pilot scope across lanes.

| Card | Agent | Status |
| --- | --- | --- |
| S3-R87-C0-O | Org Architect Supervisor | done — reporting/letter boundary confirmed |
| S3-R87-C1-P1 | Igniter-Lang Bridge Agent | done — Igniter-Lang pilot scope track complete |
| S3-R87-C1-RF1 | Ruby Framework Supervisor | done — RF pilot scope card complete |
| S3-R87-C2-X | External Pressure Reviewer | done — 11/11 PASS, verdict: proceed |
| S3-R87-C3-A | Architect Supervisor | **pending** — decision gate not yet run |
| S3-R87-C4-S | Status Curator | pending — awaits C3-A |

Ruby Framework lane contribution to R87 is filed. The lane is waiting for the
Architect decision before opening the next work scope.

## Open Roadmap

Primary roadmap:

- `spark-contractable-shadowing-adoption-plan-v0`

Ruby Framework pilot scope card (R87):

- `cards/s3-r87-c1-rf1-spark-contractable-shadowing-pilot-scope-v0.md`

Ruby Framework design track (R87):

- `tracks/spark-contractable-shadowing-pilot-scope-v0.md`

Next card: none open until C3-A lands and authorizes or redirects scope.

## Portfolio Reporting

Status: adopted.

The lane adopts:

- `igniter-lang/roles/base-role.md`;
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`;
- `igniter-lang/docs/org/portfolio-reporting-protocol-v0.md`.

Before opening or closing Ruby Framework lane rounds, check Portfolio guidance.
At the end of each Ruby Framework lane round, write one compact report packet
under `.agents/ruby-framework/reports/`.

Reports must surface decisions needed from Portfolio, changed files, evidence,
risks/drift, cross-lane requests, and the recommended next route. Portfolio
should not need to read every local track unless the report points to a blocker
or decision.

Active guidance checked:

```text
PG-2026-05-20-01
```

Adopted implication:

```text
Keep Spark x Igniter adoption in primary_observed_only mode until one redacted
receipt path is proven end-to-end.
```

Current round report (filed, awaiting Architect):

```text
.agents/ruby-framework/reports/ruby-framework-spark-contractable-shadowing-adoption-round-v0.md
```

Round status:

```text
Ruby Framework lane contribution: done.
Waiting: S3-R87-C3-A (Architect decision).
Latest analysis/recipe round: done.
Next round: no new implementation round open yet.
Recommended next route: wait for explicit publish approval phrase if the user
wants Rubygems publish. Remote tag `v0.5.2` is present and matches local release
commit; local `master` is ahead of `origin/master` by unrelated Lang commits,
but branch push is not required for publish.
Spark production readiness remains out of scope.
Next report filename: to be determined by publish execution route or the next
Spark/Ruby adoption route.
```
