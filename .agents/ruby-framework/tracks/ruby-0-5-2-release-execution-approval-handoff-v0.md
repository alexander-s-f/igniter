# Ruby 0.5.2 Release Execution Approval Handoff v0

Status: approved boundary executed locally
Date: 2026-05-21
Card: RUBY-REL-P5
Route: UPDATE
Track: ruby-0-5-2-release-execution-approval-handoff-v0
Guidance: PG-2026-05-20-01

## Approval Captured

User approval:

```text
yes to 0.5.2 preflight
track log/.keep
remove stale gems
allow network smoke
publish requires second approval
push separate
```

Approved execution boundary:

- bump release version to `0.5.2`;
- track `examples/rails_contracts_ledger/log/.keep`;
- remove stale ignored `0.5.1` gem artifacts before final build;
- rerun release gates;
- rebuild `0.5.2` gems;
- run network-enabled clean installed-gem smoke for `igniter-ledger`;
- commit local release execution changes;
- tag `v0.5.2` locally;
- do not publish;
- do not push commit or tag.

## Changes Made

- `lib/igniter/version.rb` bumped from `0.5.1` to `0.5.2`.
- Lockfiles updated by Bundler/path-gem resolution:
  - `Gemfile.lock`;
  - `examples/rails_contracts_ledger/Gemfile.lock`;
  - `packages/igniter-ledger/Gemfile.lock`.
- `examples/rails_contracts_ledger/log/.keep` tracked to satisfy the Rails
  proof app `.gitignore` placeholder policy.
- Stale ignored `0.5.1` gem artifacts removed.
- Fresh ignored `0.5.2` gem artifacts built.

## Gates Run

Root gate:

```text
bundle exec rake
686 examples, 0 failures
558 files inspected, no offenses detected
```

Ledger package specs:

```text
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec
1254 examples, 0 failures
```

Rails proof path-gem test:

```text
bin/rails test
1 runs, 24 assertions, 0 failures, 0 errors, 0 skips
```

Gem build smoke:

```text
igniter-0.5.2.gem
igniter-contracts-0.5.2.gem
igniter-extensions-0.5.2.gem
igniter-embed-0.5.2.gem
igniter-ledger-client-0.5.2.gem
igniter-ledger-0.5.2.gem
```

Clean installed-gem Rails proof smoke:

```text
Successfully installed igniter-ledger-0.5.2
Bundle complete! 10 Gemfile dependencies, 76 gems now installed.
1 runs, 24 assertions, 0 failures, 0 errors, 0 skips
```

Network access was used for this smoke because `igniter-ledger` native extension
installation resolves crates.io dependencies.

## Boundary Checks

- `v0.5.2` was absent before tagging.
- No `.gem` artifacts are tracked by git.
- Package docs do not claim Spark production readiness.
- `availability_slot_map_summary` remains aggregate output vocabulary, not an
  Embed receipt kind.
- Embed receipt kinds remain `:contractable_observation` and
  `:contractable_event`.
- Ledger sinks remain optional and not source of truth.

## Native Extension Release Note

Preserve this note for publish/release notes:

```text
igniter-ledger clean install currently needs crates.io/network access unless
Rust dependencies are vendored or prebuilt native artifacts are introduced.
```

## Held By User Instruction

- Publish is held for second explicit authorization.
- Push commit/tag is held for a separate route.
- Spark production readiness is not claimed.
