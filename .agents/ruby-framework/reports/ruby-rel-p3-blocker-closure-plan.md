# Round Report: ruby-framework RUBY-REL-P3 blocker closure plan

Status: done
Date: 2026-05-20
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ruby-release-execution-blocker-closure-plan-v0
Guidance: PG-2026-05-20-01
Scope: Prepare release-execution blocker closure plan without release, tag, publish, version change, or API widening.

## Executive Summary

- Prepared release-execution blocker closure plan.
- Recommended release route: prepare a new `0.5.2` release execution route,
  because current `0.5.1` already has local tag `v0.5.1` on an older commit.
- Recommended `log/.keep` cleanup: track
  `examples/rails_contracts_ledger/log/.keep` because the Rails proof app
  `.gitignore` explicitly unignores it.
- Recommended ignored gem artifact policy: remove stale ignored `.gem`
  artifacts before final release build, then rebuild fresh artifacts in the
  release execution route.
- Preserved the `igniter-ledger` native extension crates.io/network dependency
  release note.
- No tag, publish, version bump, or Ruby API change was performed.

## Decisions Needed From User / Portfolio

- [ ] Proceed with release execution, or hold release.
- [ ] Choose version/tag route:
  - recommended: bump to `0.5.2` and tag `v0.5.2`;
  - alternative: no new release, treat existing `v0.5.1` as the release;
  - not recommended: retag/reuse `v0.5.1` for current HEAD.
- [ ] Choose Rails proof `log/.keep` cleanup:
  - recommended: track `examples/rails_contracts_ledger/log/.keep`;
  - alternative: change ignore policy and remove `.keep`.
- [ ] Confirm stale ignored `.gem` artifacts should be removed before final
  release build.
- [ ] Confirm native extension release note should be included.
- [ ] Authorize publish only after final gates, tag strategy, and Rubygems
  credentials/MFA check pass.

## Evidence

- release review:
  - `.agents/ruby-framework/reports/ruby-rel-p2-release-readiness-review.md`
  - `.agents/ruby-framework/tracks/ruby-framework-release-readiness-review-v0.md`
- git checks:
  - `git tag -l '*0.5.1*'` -> `v0.5.1`
  - `git rev-parse HEAD` -> `926994944fda978f05c72ab63d19079dde1508b1`
  - `git show v0.5.1` -> annotated tag `Version 0.5.1`, tagged commit
    `bd7244d3`
  - `git status --short` -> `?? examples/rails_contracts_ledger/log/`

## Recommended Route

```text
prepare 0.5.2 release execution route
```

Closure sequence:

1. Track `examples/rails_contracts_ledger/log/.keep`.
2. Bump `lib/igniter/version.rb` to `0.5.2`.
3. Remove stale ignored `.gem` artifacts.
4. Rerun release gates.
5. Build fresh gems.
6. Run clean installed-gem smoke.
7. Commit release execution changes.
8. Tag `v0.5.2`.
9. Publish only after explicit authorization.

## Remaining Blockers Before Release Execution

- user/Portfolio release intent decision;
- version/tag route decision;
- `log/.keep` cleanup decision;
- stale ignored gem artifact cleanup decision;
- version bump authorization if `0.5.2` route is accepted;
- final release gates and clean installed-gem smoke after the bump;
- Rubygems credentials/MFA/ownership check;
- explicit publish authorization.

## Spark Adoption Separation

This plan does not change Spark adoption readiness:

- no Spark production-readiness claim;
- no shadow candidate implementation;
- no package-level Spark adapter;
- no Ledger source-of-truth claim;
- no Spark rollout authorization.

## Recommended Next

Ask user/Portfolio to choose the exact decisions above. If approved, open a
separate `0.5.2` release execution route. Do not tag or publish from this plan.
