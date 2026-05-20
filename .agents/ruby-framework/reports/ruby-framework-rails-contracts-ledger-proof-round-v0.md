# Round Report: ruby-framework rails-contracts-ledger-proof-round-v0

Status: done
Date: 2026-05-20
Supervisor: [Igniter Ruby Framework Supervisor]
Scope: Rails example proof, contractable receipt path, tests, lint, and gem build smoke.

## Executive Summary

- Fixed the RubyMine-facing shape in `examples/contracts/differential.rb` by
  moving a block out of string interpolation; syntax and runtime are OK.
- Added `examples/rails_contracts_ledger`, a Rails 8.1 proof app using
  `Igniter::Embed.contractable` in primary-only observed-service mode.
- The Rails example records redacted observation/event receipts into
  `Igniter::Ledger::ContractableReceiptSink` and exposes lookup by
  `observation_id`.
- Fixed two root production-prep issues surfaced by `bundle exec rake`:
  standalone companion load path for `igniter-ledger-client`, and archived
  `igniter/contract` entrypoint messaging.
- Cleaned RuboCop offenses in active Embed and LedgerClient surfaces.
- Tests/lint/build smoke are green; Rubygems publish was not run.
- Rails example server smoke passed on `http://127.0.0.1:3042/availability`
  and `/observations/:observation_id`.

## Decisions Needed From Portfolio

- [ ] None for this proof round. Continue to keep Spark adoption in
  primary-observed-only mode until a real redacted receipt path is proven.

## Completed

- Checked Portfolio guidance `PG-2026-05-20-01`.
- Verified `examples/contracts/differential.rb` with `ruby -c` and runtime run.
- Created a Rails proof app under `examples/rails_contracts_ledger`.
- Wired primary-only availability observation, redaction, notifications,
  receipt storage, and lookup route.
- Ran focused Rails integration test.
- Ran root `bundle exec rake`.
- Ran full Ledger package specs.
- Built key gems locally as release smoke.
- Started the Rails proof server and verified `/availability` plus observation
  lookup over localhost.

## Changed Files

- `.gitignore`
- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/reports/ruby-framework-rails-contracts-ledger-proof-round-v0.md`
- `examples/contracts/differential.rb`
- `examples/application/companion/services/store_convergence_sidecar.rb`
- `examples/rails_contracts_ledger/`
- `lib/igniter/contract.rb`
- `packages/igniter-embed/lib/igniter/embed/contractable/runner.rb`
- `packages/igniter-embed/lib/igniter/embed/contractable/sugar_builder.rb`
- `packages/igniter-embed/spec/igniter/embed/contractable_spec.rb`
- `packages/igniter-ledger-client/lib/igniter/ledger_client/client.rb`
- `packages/igniter-ledger-client/lib/igniter/ledger_client/results.rb`
- `packages/igniter-ledger-client/spec/igniter/ledger_client/transports_spec.rb`
- `packages/igniter-ledger/exe/igniter-store-server`

## Evidence

- tracks:
  - `.agents/ruby-framework/tracks/ruby-framework-current-state-analysis-v0.md`
- gates:
  - none new
- discussions:
  - user request for Rails example and production-prep proof
- guidance:
  - `PG-2026-05-20-01`
- tests/proofs:
  - `ruby -c examples/contracts/differential.rb`
  - `ruby examples/contracts/differential.rb`
  - `bin/rails test` in `examples/rails_contracts_ledger`
  - `bundle exec rake`
  - `BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec`
  - `gem build` for `igniter`, `igniter-contracts`, `igniter-embed`,
    `igniter-extensions`, `igniter-ledger-client`, and `igniter-ledger`
  - `curl -s http://127.0.0.1:3042/availability`
  - `curl -s http://127.0.0.1:3042/observations/:observation_id`

## Risks / Drift

- The Rails proof is intentionally in-memory and primary-only; it is a recipe,
  not a production Spark integration.
- Rails test emits a Bundler warning because `/Users/alex` is not writable in
  this sandbox, but the test passes using a temporary Bundler home.
- Localhost bind/curl required sandbox escalation in this environment.
- Built `.gem` files are ignored and were not published.
- The next production step should prove install/use from built gems in a clean
  temp app or gem home before any real release.

## Cross-Lane Requests

To Ruby Framework:

- Use this Rails example as the first recipe for host-local observed-service
  adoption.

To Igniter-Lang:

- Continue waiting for sanitized receipt vocabulary before fixture expansion.

To Spark CRM:

- Use the Rails example as a reference shape, but confirm redaction feasibility
  before any app-local implementation.

To Portfolio:

- No decision required unless this proof changes R87 routing.

## Recommended Next

- Add a clean install smoke that installs built local gems into a temporary gem
  home and runs the Rails proof against installed gems instead of path gems.
- After that, prepare a release checklist; do not publish without an explicit
  release authorization.
