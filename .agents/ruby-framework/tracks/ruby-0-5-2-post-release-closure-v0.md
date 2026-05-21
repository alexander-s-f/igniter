# Ruby 0.5.2 Post-Release Closure v0

Status: PASS - release corridor closed
Date: 2026-05-21
Card: RUBY-REL-P6
Route: UPDATE
Track: ruby-0-5-2-post-release-closure-v0
Guidance: PG-2026-05-20-01

## Purpose

Record Ruby Framework `0.5.2` publish completion and close the release corridor.

## Completion Record

User reported publishing all approved `0.5.2` gems to Rubygems.

Published set:

- `igniter-contracts` `0.5.2`
- `igniter-extensions` `0.5.2`
- `igniter-embed` `0.5.2`
- `igniter-ledger-client` `0.5.2`
- `igniter-ledger` `0.5.2`
- `igniter` `0.5.2`

## Rubygems Verification

Rubygems remote index verification confirms `0.5.2` is available for all six
release artifacts:

```text
igniter-contracts (0.5.2)
igniter-extensions (0.5.2)
igniter-embed (0.5.2)
igniter-ledger-client (0.5.2)
igniter-ledger (0.5.2)
igniter (0.5.2, 0.5.1, 0.5.0, 0.4.5, 0.4.3, 0.4.0, 0.3.1, 0.3.0, 0.2.0)
```

## Boundaries

- No git branch push was requested or performed in this closure round.
- No git tag push was requested or performed in this closure round.
- No code/version changes were made in this closure round.
- No Spark production-readiness claim is made.
- Spark adoption readiness remains separate from Ruby package release
  availability.

## Native Extension Note

Preserve for release/support notes:

```text
igniter-ledger clean install currently needs crates.io/network access unless
Rust dependencies are vendored or prebuilt native artifacts are introduced.
```

## Recommended Observation / Support Steps

- Monitor first install reports for `igniter-ledger`, especially Rust/native
  extension build behavior on fresh machines.
- Run one clean consumer install smoke from Rubygems after index propagation is
  considered stable.
- Keep Spark pilot support in primary-observed-only mode until one redacted
  receipt path is proven end-to-end.
- Do not widen the Ruby API or claim Spark production readiness from this
  package release alone.
