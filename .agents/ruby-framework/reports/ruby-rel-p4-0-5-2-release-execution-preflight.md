# Round Report: ruby-framework RUBY-REL-P4 0.5.2 release execution preflight

Status: done
Date: 2026-05-21
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ruby-0-5-2-release-execution-preflight-v0
Guidance: PG-2026-05-20-01
Scope: Prepare exact `0.5.2` release execution preflight without release actions.

## Executive Summary

- Prepared exact `0.5.2` release execution preflight.
- No version bump, tag, publish, cleanup, or API widening was performed.
- Proposed route: track Rails proof `log/.keep`, bump `lib/igniter/version.rb`
  to `0.5.2`, remove stale ignored `.gem` artifacts, rerun gates, rebuild gems,
  run clean installed-gem smoke, commit, tag `v0.5.2`, and publish only after
  explicit user authorization.
- Preserved native extension note: `igniter-ledger` clean install currently
  needs crates.io/network access unless dependencies are vendored or prebuilt.
- Spark production-readiness remains out of scope.

## Decisions Needed From User / Portfolio

- [ ] Authorize or reject `0.5.2` release execution preflight.
- [ ] Confirm version bump to `0.5.2`.
- [ ] Confirm tracking `examples/rails_contracts_ledger/log/.keep`.
- [ ] Confirm stale ignored `.gem` artifacts should be removed before final
  build.
- [ ] Confirm network-enabled clean installed-gem smoke is allowed for
  `igniter-ledger`.
- [ ] Confirm publish remains a second explicit authorization after final gates.
- [ ] Confirm whether git push/tag push is part of release execution or a
  separate route.

## Proposed Actions

1. Track `examples/rails_contracts_ledger/log/.keep`.
2. Change `lib/igniter/version.rb` to `0.5.2`.
3. Remove stale ignored `0.5.1` gem artifacts.
4. Run `bundle exec rake`.
5. Run Ledger package specs.
6. Run Rails proof path-gem test.
7. Build six `0.5.2` gems.
8. Run network-enabled clean installed-gem Rails proof smoke.
9. Confirm docs boundaries and git hygiene.
10. Commit release execution changes.
11. Tag `v0.5.2`.
12. Publish only after explicit user authorization.

## Evidence Read

- `.agents/ruby-framework/tracks/ruby-release-execution-blocker-closure-plan-v0.md`
- `.agents/ruby-framework/reports/ruby-rel-p3-blocker-closure-plan.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `git status --short`
- `git tag -l 'v0.5.2'`
- `git tag -l 'v0.5.1'`

## Non-Actions Confirmed

- Did not edit `lib/igniter/version.rb`.
- Did not remove `.gem` artifacts.
- Did not stage `log/.keep`.
- Did not run release gates.
- Did not build `0.5.2` gems.
- Did not tag.
- Did not publish.
- Did not change Ruby API.

## Recommended Next

Ask user/Portfolio for the exact decisions listed above. If approved, open the
release execution route and run the preflight commands in order. Keep publish as
a separate explicit authorization unless user instructs otherwise.
