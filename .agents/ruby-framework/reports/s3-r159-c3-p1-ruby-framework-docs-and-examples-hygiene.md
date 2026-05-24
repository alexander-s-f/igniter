# Round Report: ruby-framework S3-R159-C3-P1 docs and examples hygiene

Status: PASS - focused docs-only cleanup accepted
Date: 2026-05-24
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ruby-framework-docs-and-examples-hygiene-v0
Guidance: PG-2026-05-20-01
Scope: Audit and clean Ruby Framework documentation/examples for stale release
claims, outdated package status, confusing Igniter-Lang readiness language, and
examples that no longer represent intended package boundaries.

## Executive Summary

- Audited requested Ruby Framework docs, package READMEs, and example READMEs.
- Applied a focused docs-only cleanup; no Ruby code or example architecture was
  changed.
- Fixed stale Ruby lane status wording from `0.5.1` gem build smoke to `0.5.2`
  and removed old publish-next-route language.
- Clarified that `0.5.2` published gems are the release surface; other package
  directories may be active source/proof lanes.
- Strengthened Igniter-Lang wording: additive/report-only/metadata-only, not a
  compiler/parser/runtime compatibility promise.
- Marked Rails proof and two prototype example folders as proof/prototype
  evidence rather than production/release support surfaces.

## Decisions Needed From Portfolio

- [ ] Confirm `hold-for-lang-release-candidate-export-fixture` as the next
  boundary before any Ruby package-doc sync about compiler release
  compatibility.

## Completed

- Read R158 compiler-alignment packets and current Ruby lane status.
- Audited top-level, guide, dev, package, and example docs for stale claims.
- Applied small markdown-only clarifications.
- Updated Ruby Framework current status and filed this track/report.

## Changed Files

- `README.md`
- `docs/guide/igniter-lang-foundation.md`
- `packages/README.md`
- `packages/igniter-contracts/README.md`
- `examples/README.md`
- `examples/rails_contracts_ledger/README.md`
- `examples/lineup/README.md`
- `examples/semantic_gateway/README.md`
- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/tracks/ruby-framework-docs-and-examples-hygiene-v0.md`
- `.agents/ruby-framework/reports/s3-r159-c3-p1-ruby-framework-docs-and-examples-hygiene.md`

## Accepted Cleanup

- Top-level README now separates released gems from active/local/proof lanes.
- Lang Foundation guide and `igniter-contracts` README now explicitly avoid
  next-compiler-release compatibility promises.
- Package index now lists the `0.5.2` released gem set:
  `igniter`, `igniter-contracts`, `igniter-extensions`, `igniter-embed`,
  `igniter-ledger-client`, and `igniter-ledger`.
- Examples index now says non-catalog prototype folders are outside the current
  release/support example surface.
- Rails contracts/ledger proof now says it is not a production Rails kit or
  Spark production adoption recipe.
- `examples/lineup` and `examples/semantic_gateway` now say they are local
  research/prototype evidence, not active release-surface examples.

## Remaining Stale Docs

No blocking stale doc remains from this audit.

Watch only:

- Keep release docs explicit that source package lanes are not automatically
  included in the `0.5.2` published gem set.
- Keep `Igniter Lang Foundation` paired with additive/report-only language.
- Do not copy Ledger research compiler/language ideas into public release
  promises.

## Example Health

- Active examples were preserved.
- No runnable example architecture was changed.
- `examples/contracts/lang_foundation.rb` remains a report-only metadata proof
  over the current contracts runtime.
- Rails proof remains `primary_observed_only` and not Ledger source-of-truth.
- Prototype folders are labeled as outside the active release/support surface.

## Evidence

Reviewed:

- R158 track/report and Ruby current status.
- Top-level README, guide/dev docs, package READMEs, and example READMEs named
  in S3-R159-C3-P1.

Validation:

- `git diff --check` passed for changed files.

## Risks / Drift

- The package map is broader than the published `0.5.2` gem set. Future release
  packets should keep those two concepts separate.
- Compiler compatibility pressure should stay docs/evidence-only until
  Igniter-Lang freezes a release-candidate export fixture.
- Spark production adoption remains unauthorized.

## Cross-Lane Requests

To Igniter-Lang:

- Provide a stable release-candidate export fixture before Ruby documents
  compiler release compatibility.

To Portfolio:

- Keep Ruby docs/examples hygiene accepted as cleanup only; it should not imply
  a new release route or production-readiness change.

To Spark CRM:

- No new request. Spark remains primary-observed-only and not production
  adopted by this cleanup.

## Recommended Next

```text
hold-for-lang-release-candidate-export-fixture
```

Optional support-only follow-up:

```text
post-release-public-rubygems-install-smoke
```

## Explicit Non-Authorizations

- No gem release.
- No tag or branch push.
- No Ruby public API widening.
- No example architecture rewrite.
- No Igniter-Lang compiler release compatibility claim.
- No Spark production adoption.
- No production promise changes.
