# Round Report: ruby-framework PORT-2026-05-20-RUBY-P2 observed-service-recipe

Status: done
Date: 2026-05-20
Supervisor: [Igniter Ruby Framework Supervisor]
Parent: [Portfolio Architect Supervisor]
Guidance: PG-2026-05-20-01
Scope: Create concise Ruby Framework observed-service recipe from Rails proof and minimal receipt shape.

## Executive Summary

- Created the Ruby Framework observed-service receipt recipe for the first
  Spark `primary_observed_only` pilot.
- The recipe keeps Spark app-local: service target, normalizer, redaction,
  persistence, admin lookup, monitoring, and rollout flag stay in Spark.
- The recipe documents the minimal wrapper, normalizer/redaction expectations,
  store adapter protocol, fail-open behavior, and observation/event receipt
  shapes Ruby supports now.
- Broad package API generalization remains closed; no new package code is
  required for the first Spark pilot.
- No gems were published, no release was opened, and no shadow candidate
  implementation was opened.

## Decisions Needed From Portfolio

- [ ] None required to close this Ruby P2 round.
- [ ] Optional: confirm `Spark follow-up` as the next cross-lane route so Spark
  can prove one persisted redacted receipt path end-to-end.

## Completed

- Rechecked Base Role, active Portfolio guidance, and reporting protocol before
  closing the round.
- Read the P1 minimal receipt shape report and Rails contracts/ledger proof
  report.
- Read the Rails proof README and the relevant proof wrapper/store/normalizer
  files.
- Created a concise recipe under the Ruby Framework `.agents` surface.
- Added the `recipes/` surface to the Ruby Framework lane README.

## Changed Files

- `.agents/ruby-framework/README.md`
- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/recipes/observed-service-receipt-recipe-v0.md`
- `.agents/ruby-framework/reports/port-2026-05-20-ruby-p2-observed-service-recipe.md`

## Evidence

- guidance:
  - `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
  - active guidance `PG-2026-05-20-01`
- protocols:
  - `igniter-lang/roles/base-role.md`
  - `igniter-lang/docs/org/portfolio-reporting-protocol-v0.md`
- source reports:
  - `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`
  - `.agents/ruby-framework/reports/ruby-framework-rails-contracts-ledger-proof-round-v0.md`
- proof references:
  - `examples/rails_contracts_ledger/README.md`
  - `examples/rails_contracts_ledger/config/initializers/igniter_contracts.rb`
  - `examples/rails_contracts_ledger/app/services/availability_slot_map_normalizer.rb`
  - `examples/rails_contracts_ledger/app/services/spark_contractable_receipt_store.rb`

## Risks / Drift

- The recipe is documentation-only; it does not itself prove Spark persistence.
- Spark's first feasible local path may be metrics-backed, but a durable
  receipt table or outbox is still expected before broader rollout.
- `igniter-ledger` clean install still has the known native extension network
  dependency unless vendored or prebuilt artifacts are introduced.
- Receipt vocabulary should stay narrow until Spark shows one sanitized example
  from a real app-local target.

## Cross-Lane Requests

To Spark CRM:

- Use the recipe for one app-local `primary_observed_only` pilot.
- Provide one persisted redacted observation receipt and one event receipt.
- Confirm redaction allow-list, digest/version vocabulary, and read-only
  admin/MCP lookup behavior.

To Portfolio:

- Keep Ruby package API generalization closed until Spark proves one real
  redacted receipt path end-to-end.

To Igniter-Lang:

- No new language/runtime gate is requested from this recipe round.

## Recommended Next

`Spark follow-up`.

Spark should now map this recipe onto the selected availability target and
return a concrete persisted receipt example. After that, Ruby can do
`package-doc sync`; `release-readiness-review` should wait until Spark validates
the recipe against one app-local receipt path.
