# Ruby Framework Release Readiness Review Prep v0

Status: prepared
Date: 2026-05-20
Card: RUBY-REL-P1
Route: UPDATE
Track: ruby-framework-release-readiness-review-prep-v0
Guidance: PG-2026-05-20-01

## Purpose

Prepare a review-only release-readiness packet after the observed-service docs
sync.

This packet does not publish gems, create tags, widen Ruby API, or claim Spark
production readiness.

## Scope Boundary

Package release readiness answers:

```text
Can the Ruby packages enter an explicit release-readiness review?
```

Spark adoption readiness answers a different question:

```text
Is Spark production adoption ready?
```

Those are separate. Current Ruby package evidence may justify opening a release
readiness review. It does not make Spark production-ready, does not authorize a
Spark rollout, and does not promote receipts to source-of-truth status.

## Current Package Release Surface

Version:

```text
0.5.1
```

Packages reviewed for this prep:

- `igniter`
- `igniter-contracts`
- `igniter-embed`
- `igniter-extensions`
- `igniter-ledger`
- `igniter-ledger-client`

Current observed-service docs surface:

- `packages/igniter-embed/README.md` includes a primary-only observed-service
  example.
- The accepted Lang fixture payload is used only as a sanitized
  `receipt[:primary][:outputs]` normalizer example.
- Embed receipt envelope vocabulary remains separate:
  - `:contractable_observation`;
  - `:contractable_event`.
- The docs explicitly avoid release-readiness and public-schema claims.

Current Ledger stance:

- `igniter-ledger` documents `ContractableReceiptSink` as an optional receipt
  sink.
- Ledger sidecar is not required for the Spark pilot.
- Ledger receipts are not source of truth.

## Known Smoke Evidence

Evidence from the Rails proof and P1 reports:

- `ruby -c examples/contracts/differential.rb` passed.
- `ruby examples/contracts/differential.rb` passed.
- Rails proof app path-gem test passed:

  ```text
  1 runs, 24 assertions, 0 failures, 0 errors, 0 skips
  ```

- root `bundle exec rake` passed:

  ```text
  686 examples, 0 failures; RuboCop no offenses
  ```

- Ledger package specs passed:

  ```text
  1254 examples, 0 failures
  ```

- `gem build` passed for:
  - `igniter`;
  - `igniter-contracts`;
  - `igniter-embed`;
  - `igniter-extensions`;
  - `igniter-ledger-client`;
  - `igniter-ledger`.
- Clean installed-gem Rails proof smoke passed from built gems in a temporary
  gem home after allowing network access for `igniter-ledger` native extension
  dependencies.

Evidence not rerun in this prep:

- no fresh `bundle exec rake`;
- no fresh Ledger spec run;
- no fresh clean installed-gem smoke;
- no fresh gem build after the latest docs-only README changes.

Reason: this card is review prep only, not the release-readiness review itself.

## Release Blocker Checklist

Before any release or tag:

- [ ] Explicit user/Portfolio release authorization exists.
- [ ] Working tree is clean or all intentional changes are committed.
- [ ] Remove or ignore generated Rails proof logs:
  - `examples/rails_contracts_ledger/log/test.log`;
  - `examples/rails_contracts_ledger/log/development.log`.
- [ ] Confirm `.gem` artifacts are absent from git and ignored.
- [ ] Rerun root gate:

  ```bash
  bundle exec rake
  ```

- [ ] Rerun Ledger package specs:

  ```bash
  BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec
  ```

- [ ] Rerun Rails proof path-gem test:

  ```bash
  cd examples/rails_contracts_ledger
  bin/rails test
  ```

- [ ] Rebuild gems after latest docs:
  - `igniter`;
  - `igniter-contracts`;
  - `igniter-embed`;
  - `igniter-extensions`;
  - `igniter-ledger-client`;
  - `igniter-ledger`.
- [ ] Rerun clean installed-gem Rails proof smoke from freshly built gems.
- [ ] Preserve the `igniter-ledger` native extension release note:

  ```text
  clean install currently needs crates.io/network access unless dependencies
  are vendored or prebuilt native artifacts are introduced
  ```

- [ ] Confirm `packages/igniter-ledger/exe/igniter-store-server` remains
  executable.
- [ ] Confirm package READMEs do not claim Spark production readiness.
- [ ] Confirm `packages/igniter-embed/README.md` still separates
  `availability_slot_map_summary` from Embed receipt kinds.
- [ ] Confirm no Spark class names, private IDs, raw slot payloads, or real
  production data entered package docs or examples.
- [ ] Confirm no tag has already been created for the intended version.
- [ ] Confirm Rubygems credentials/MFA/release ownership only inside an
  authorized release route.

## Spark Adoption Readiness

Spark adoption is not release-ready just because package release review may
open.

Spark remains app-local and primary-observed-only:

- Spark owns target selection, rollout flag, sample rate, normalizer,
  redaction, persistence, lookup, monitoring, and fixture sanitization.
- Spark has metrics-backed aggregate evidence, not a dedicated observation/event
  receipt-store proof in the package docs.
- Ruby package docs must not claim Spark production readiness.
- Shadow candidate implementation remains closed.

## Review Recommendation

```text
release-readiness review may open
```

Reason:

- package surfaces and docs are aligned enough for a formal review;
- prior smoke/build evidence is green;
- the known blockers are concrete and reviewable;
- opening the review does not authorize publish, tag, API widening, or Spark
  production adoption.

Release itself remains held until every blocker above is checked in an explicit
release-readiness/release route.
