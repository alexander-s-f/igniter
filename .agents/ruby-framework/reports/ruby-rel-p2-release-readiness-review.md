# Round Report: ruby-framework RUBY-REL-P2 release-readiness review

Status: HOLD
Date: 2026-05-20
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ruby-framework-release-readiness-review-v0
Guidance: PG-2026-05-20-01
Scope: Formal release-readiness review without release, tag, publish, or API widening.

## Executive Summary

- Formal release-readiness review completed.
- Technical gates passed: root rake, Ledger specs, Rails proof test, gem builds,
  and clean installed-gem Rails proof smoke.
- Status: `HOLD` for release execution.
- Hold reasons: no explicit release authorization, current version `0.5.1`
  already has local tag `v0.5.1`, and working tree has untracked
  `examples/rails_contracts_ledger/log/.keep`.
- No tag, publish, or Ruby API widening was performed.
- Package release readiness remains separate from Spark adoption readiness; no
  Spark production-readiness claim is made.

## Decisions Needed From Portfolio

- [ ] Decide whether release execution should proceed after blockers are
  resolved.
- [ ] Decide version/tag route for current `0.5.1` with existing local
  `v0.5.1` tag.
- [ ] Confirm cleanup policy for Rails proof `log/.keep`.

## Gates / Evidence

- `bundle exec rake`
  - `686 examples, 0 failures`
  - `558 files inspected, no offenses detected`
- `BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec`
  - `1254 examples, 0 failures`
- `bin/rails test` in `examples/rails_contracts_ledger`
  - `1 runs, 24 assertions, 0 failures, 0 errors, 0 skips`
- `gem build`
  - `igniter` 0.5.1 passed
  - `igniter-contracts` 0.5.1 passed
  - `igniter-embed` 0.5.1 passed
  - `igniter-extensions` 0.5.1 passed
  - `igniter-ledger-client` 0.5.1 passed
  - `igniter-ledger` 0.5.1 passed
- clean installed-gem Rails proof smoke
  - first no-network attempt failed on crates.io DNS for Ledger native
    extension dependency `blake3`
  - network-enabled retry passed with `1 runs, 24 assertions, 0 failures`

## Docs / Boundary Checks

- Package docs do not claim Spark production readiness.
- `packages/igniter-embed/README.md` keeps
  `"availability_slot_map_summary"` as sanitized aggregate output vocabulary,
  not an Embed receipt kind.
- Embed observation/event receipt kinds remain separate:
  `:contractable_observation` and `:contractable_event`.
- Ledger sinks remain optional adapters, not source-of-truth claims.
- No Spark adapter, Rails generator, durable queue API, shadow candidate
  implementation, or Ruby API generalization was opened.

## Artifact / Git Hygiene

- `.gem` artifacts were created by build smoke and are ignored by `.gitignore`.
- No `.gem` artifacts are tracked by git.
- `pkg/` is ignored.
- Rails proof `test.log` and `development.log` are ignored or absent.
- Current untracked status:

  ```text
  ?? examples/rails_contracts_ledger/log/
  ```

  Cause: `examples/rails_contracts_ledger/log/.keep` is untracked and explicitly
  unignored by the app `.gitignore`.

- Existing local tag:

  ```text
  v0.5.1
  ```

## Remaining Blockers Before Release Execution

- Explicit release authorization.
- Resolve version/tag conflict for `0.5.1` / `v0.5.1`.
- Resolve untracked `examples/rails_contracts_ledger/log/.keep`.
- Commit intentional docs/reports/package changes.
- Decide whether to remove ignored local gem artifacts before release
  execution.
- Preserve release note: `igniter-ledger` clean install needs crates.io/network
  unless Rust dependencies are vendored or prebuilt native artifacts are used.
- Rubygems credentials/MFA/ownership check inside an authorized release route.

## Spark Adoption Separation

Spark adoption remains app-local and primary-observed-only:

- no Spark production-readiness claim;
- no shadow candidate implementation;
- no package-level Spark adapter;
- no Ledger source-of-truth stance;
- Spark rollout and receipt persistence remain Spark-owned.

## Recommended Next

`HOLD until blockers resolved`.

After release authorization, version/tag decision, tree cleanup, and commit,
release execution can be considered as a separate explicit route. Do not publish
or tag from this review packet.
