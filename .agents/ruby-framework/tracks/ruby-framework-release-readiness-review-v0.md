# Ruby Framework Release Readiness Review v0

Status: HOLD for release execution
Date: 2026-05-20
Card: RUBY-REL-P2
Route: UPDATE
Track: ruby-framework-release-readiness-review-v0
Guidance: PG-2026-05-20-01

## Purpose

Run the formal release-readiness review for Ruby Framework packages without
releasing, tagging, publishing, widening Ruby API, or claiming Spark production
readiness.

## Review Status

```text
HOLD
```

The technical gates passed, but release execution remains blocked by release
authorization/version-tag hygiene and one working-tree hygiene item.

This review did not tag, publish, or widen API.

## Package Release vs Spark Adoption

Package release readiness is separate from Spark adoption readiness.

Package review result:

```text
technical gates passed; release execution held
```

Spark adoption result:

```text
not a Spark production-readiness claim
```

Spark remains app-local and primary-observed-only. No shadow candidate
implementation, package-level Spark adapter, Ledger source-of-truth path, or
Spark production rollout is authorized by this review.

## Gates Run

### Root Gate

Command:

```bash
bundle exec rake
```

Result:

```text
686 examples, 0 failures
558 files inspected, no offenses detected
```

### Ledger Package Specs

Command:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec
```

Result:

```text
1254 examples, 0 failures
```

### Rails Proof Path-Gem Test

Command:

```bash
cd examples/rails_contracts_ledger
bin/rails test
```

Result:

```text
1 runs, 24 assertions, 0 failures, 0 errors, 0 skips
```

Bundler warning:

```text
/Users/alex is not writable; Bundler used a temporary home directory
```

This warning did not fail the test.

### Gem Build Smoke

Built successfully:

- `igniter-0.5.1.gem`
- `igniter-contracts-0.5.1.gem`
- `igniter-embed-0.5.1.gem`
- `igniter-extensions-0.5.1.gem`
- `igniter-ledger-client-0.5.1.gem`
- `igniter-ledger-0.5.1.gem`

Root gem warning:

```text
homepage_uri and source_code_uri both point to the same GitHub URL; Rubygems
will show only the first one
```

This is a release polish warning, not a build failure.

### Clean Installed-Gem Rails Proof Smoke

First attempt without network failed while installing `igniter-ledger` because
Cargo could not resolve crates.io for native extension dependency `blake3`.

Network-enabled retry passed:

```text
Successfully installed igniter-ledger-0.5.1
Bundle complete! 10 Gemfile dependencies, 76 gems now installed.
1 runs, 24 assertions, 0 failures, 0 errors, 0 skips
```

Release note to preserve:

```text
igniter-ledger clean install currently needs crates.io/network access unless
dependencies are vendored or prebuilt native artifacts are introduced
```

## Docs Boundary Review

Reviewed package docs for Spark production-readiness and receipt vocabulary
drift.

Confirmed:

- `packages/igniter-embed/README.md` says the availability aggregate payload
  is a sanitized normalizer example under `receipt[:primary][:outputs]`.
- `availability_slot_map_summary` is explicitly not presented as an
  `igniter-embed` receipt kind.
- Embed observation receipt vocabulary remains `:contractable_observation`.
- Embed event receipt vocabulary remains `:contractable_event`.
- Ledger sinks are described as optional adapters, not source of truth.
- Package docs say not to infer release readiness or public schema from the
  synthetic aggregate example.

No package docs claim Spark production readiness.

## Artifact / Ignore Review

Gem artifacts exist locally after build smoke:

- `igniter-0.5.1.gem`
- package-local `*-0.5.1.gem`
- `pkg/igniter-0.5.1.gem`

They are ignored:

```text
.gitignore: *.gem
.gitignore: /pkg/
```

No `.gem` artifacts are tracked by git.

Rails proof generated logs:

- `log/test.log` is ignored.
- `log/development.log` is ignored or absent.
- `log/.DS_Store` is ignored.
- `log/.keep` is untracked because the app `.gitignore` explicitly unignores
  it.

Executable bits:

```text
755 packages/igniter-ledger/exe/igniter-ledger-server
755 packages/igniter-ledger/exe/igniter-store-server
```

## Release Execution Blockers

Release execution remains blocked until:

- [ ] Explicit user/Portfolio release authorization is granted.
- [ ] Existing local tag/version conflict is resolved:

  ```text
  current package version: 0.5.1
  existing local tag: v0.5.1
  ```

  Choose one route explicitly:

  - bump version before release; or
  - confirm that `v0.5.1` is the intended existing release tag and no new tag is
    needed; or
  - explicitly authorize a tag strategy. Do not retag implicitly.

- [ ] Working tree hygiene is resolved:

  ```text
  ?? examples/rails_contracts_ledger/log/
  ```

  Current cause is `examples/rails_contracts_ledger/log/.keep`; either track it,
  ignore it, or remove it under explicit cleanup policy.

- [ ] Intentional docs/reports/package changes are committed before release.
- [ ] Confirm whether ignored local gem artifacts should be removed before
  release execution. They are ignored and untracked, but present.
- [ ] Preserve the `igniter-ledger` native extension network dependency release
  note.
- [ ] Do not publish until Rubygems credentials/MFA/ownership are checked inside
  an authorized release route.

## Non-Blockers / Warnings

- Root gem duplicate URI warning is not a build failure.
- Bundler temporary-home warning in Rails proof is not a test failure.
- Ignored `.DS_Store`, `.gem`, `pkg/`, Ledger `target/`, and temp files are not
  tracked by git.

## Final Review Recommendation

```text
HOLD for release execution
```

The package set is technically close: tests, lint, gem builds, and clean
installed-gem smoke passed. Release execution should wait for explicit
authorization, version/tag decision, working-tree cleanup, and final commit.
