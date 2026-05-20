# Round Report: ruby-framework RUBY-REL-P1 release-readiness review prep

Status: done
Date: 2026-05-20
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ruby-framework-release-readiness-review-prep-v0
Guidance: PG-2026-05-20-01
Scope: Review-only release-readiness packet after observed-service docs sync.

## Executive Summary

- Prepared a review-only release-readiness packet for the Ruby Framework
  packages after the observed-service docs sync.
- Recommendation: `release-readiness review may open`.
- This recommendation is not release authorization and does not authorize tags,
  publishing, API widening, or Spark production-readiness claims.
- Package release readiness is explicitly separated from Spark adoption
  readiness.
- Blockers are concrete: clean tree, fresh gates, fresh gem builds, fresh clean
  installed-gem smoke, native extension release note, docs boundary checks, and
  explicit release authorization.

## Decisions Needed From Portfolio

- [ ] Confirm whether to open a formal release-readiness review route.
- [ ] Do not treat this prep packet as publish/tag authorization.

## Completed

- Checked active Portfolio guidance `PG-2026-05-20-01`.
- Reviewed package docs and observed-service docs sync report.
- Reviewed known smoke/build evidence from Rails proof and minimal receipt
  reports.
- Checked package versions and gemspec release surfaces.
- Checked current working-tree release hygiene signal.
- Wrote release-readiness prep track and blocker checklist.

## Changed Files

- `.agents/ruby-framework/tracks/ruby-framework-release-readiness-review-prep-v0.md`
- `.agents/ruby-framework/reports/ruby-rel-p1-release-readiness-review-prep.md`

## Evidence

- package docs:
  - `packages/igniter-embed/README.md`
  - `packages/igniter-ledger/README.md`
  - `packages/igniter-ledger-client/README.md`
  - `packages/igniter-contracts/README.md`
- release surfaces:
  - `lib/igniter/version.rb`
  - `igniter.gemspec`
  - `packages/igniter-contracts/igniter-contracts.gemspec`
  - `packages/igniter-embed/igniter-embed.gemspec`
  - `packages/igniter-extensions/igniter-extensions.gemspec`
  - `packages/igniter-ledger/igniter-ledger.gemspec`
  - `packages/igniter-ledger-client/igniter-ledger-client.gemspec`
- smoke/build evidence:
  - `.agents/ruby-framework/reports/ruby-framework-rails-contracts-ledger-proof-round-v0.md`
  - `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`
  - `.agents/ruby-framework/reports/ruby-doc-p2-igniter-embed-observed-service-doc-sync.md`

## Readiness Prep Answer

```text
release-readiness review may open
```

Why:

- package docs now include the narrow observed-service guidance;
- existing package surfaces support the recipe without new API;
- previous gates/builds/clean install smoke are green;
- remaining blockers are explicit and testable in the formal review.

## Blocker Checklist Summary

- explicit release authorization;
- clean working tree;
- remove or ignore generated Rails proof logs;
- rerun root `bundle exec rake`;
- rerun Ledger package specs;
- rerun Rails proof app test;
- rebuild gems after latest docs;
- rerun clean installed-gem Rails proof smoke;
- preserve `igniter-ledger` native extension/network release note;
- confirm executable bits for Ledger server executables;
- confirm docs do not claim Spark production readiness;
- confirm docs preserve Embed receipt kind boundary;
- confirm no private Spark vocabulary or raw production data entered docs;
- confirm no tag/publish action occurs outside an authorized release route.

## Spark Adoption Separation

Spark adoption readiness remains separate and more constrained:

- no Spark production readiness claim;
- no shadow candidate implementation;
- no package-level Spark adapter;
- no Ledger sidecar source-of-truth claim;
- Spark app-local receipt persistence and rollout decisions remain Spark-owned.

## Risks / Drift

- Prior smoke evidence is not freshly rerun after the latest docs-only changes.
- Current working-tree check shows generated Rails proof logs under
  `examples/rails_contracts_ledger/log/`.
- `igniter-ledger` clean install still depends on crates.io/network access for
  native extension dependencies unless vendored or prebuilt artifacts are
  introduced.
- The formal review must not slide from package readiness into Spark production
  adoption readiness.

## Cross-Lane Requests

To Portfolio:

- Open release-readiness review only if the blocker checklist will be executed
  explicitly.

To Spark CRM:

- Treat any package release as framework availability only, not Spark
  production-adoption approval.

To Igniter-Lang:

- No new fixture/canon action is requested by package release review prep.

## Recommended Next

`release-readiness review may open`.

Actual release, tag, and publish remain held until the formal review passes and
the user/Portfolio explicitly authorizes release execution.
