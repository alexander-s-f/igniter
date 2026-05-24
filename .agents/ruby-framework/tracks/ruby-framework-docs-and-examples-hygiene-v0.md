# Ruby Framework Docs And Examples Hygiene v0

Status: PASS - focused docs-only cleanup accepted
Date: 2026-05-24
Card: S3-R159-C3-P1
Route: UPDATE
Track: ruby-framework-docs-and-examples-hygiene-v0
Guidance: PG-2026-05-20-01

## Purpose

Audit and clean Ruby Framework documentation/examples for stale claims,
outdated release notes, confusing Igniter-Lang readiness language, and examples
that no longer represent intended package boundaries.

## Audit Inputs

Read:

- `.agents/ruby-framework/reports/s3-r158-c2-p1-ruby-framework-compiler-release-alignment.md`
- `.agents/ruby-framework/tracks/ruby-framework-compiler-release-alignment-fractal-seed-v0.md`
- `.agents/ruby-framework/current-status.md`
- `README.md`
- `docs/guide/README.md`
- `docs/guide/api-and-runtime.md`
- `docs/guide/igniter-lang-foundation.md`
- `docs/dev/README.md`
- `docs/dev/architecture.md`
- `packages/README.md`
- `packages/*/README.md`
- `examples/README.md`
- `examples/**/README.md`
- `examples/contracts/lang_foundation.rb`
- `examples/rails_contracts_ledger/README.md`

## Accepted Cleanup

Docs-only cleanup was applied in a small focused patch.

Changed files and rationale:

- `README.md` - clarified that published Ruby gems are the released package
  surface, while other lanes may be active/local/proof-only; added explicit
  non-promise for Igniter-Lang compiler/parser/runtime compatibility beyond the
  additive report-only Lang foundation.
- `docs/guide/igniter-lang-foundation.md` - added release-candidate fixture
  caveat and clarified future compiler POC output should remain redacted
  report-only metadata/receipt payloads.
- `packages/README.md` - clarified the `0.5.2` released gem set and separated
  it from other active source/proof package lanes.
- `packages/igniter-contracts/README.md` - added explicit note that
  `require "igniter/lang"` is not a compatibility promise for the next compiler
  release.
- `examples/README.md` - clarified that non-catalog prototype folders are not
  part of the current release/support example surface and that
  `contracts/lang_foundation` is report-only metadata proof.
- `examples/rails_contracts_ledger/README.md` - marked the Rails proof as
  supporting evidence, not a production Rails integration kit or Spark
  production adoption recipe.
- `examples/lineup/README.md` - marked the prototype as outside the current
  released Ruby Framework package surface and active examples catalog.
- `examples/semantic_gateway/README.md` - marked the prototype as outside the
  current released Ruby Framework package surface and active examples catalog.
- `.agents/ruby-framework/current-status.md` - updated stale `0.5.1` gem build
  wording to `0.5.2`, added this hygiene track/report, and replaced old publish
  next-route language with the current post-release boundary.

## Findings

No blocking stale doc remained after the focused patch.

Confirmed good existing boundaries:

- `docs/guide/README.md` already says public docs describe current direction,
  not a compatibility contract.
- `docs/guide/api-and-runtime.md` is an index and does not overclaim Lang
  compiler/runtime compatibility.
- `docs/dev/README.md` and `docs/dev/architecture.md` keep architecture
  guidance compact and point historical/private material away from public docs.
- `packages/igniter-embed/README.md` keeps observed-service examples host-local
  and warns not to infer release readiness/public schema from synthetic
  aggregate examples.
- `packages/igniter-ledger-client/README.md` excludes Spark-specific code from
  the client package.
- `packages/igniter-ledger/README.md` marks the package active POC/pre-v1 and
  avoids stable contract persistence DSL promises.
- Main application POC READMEs generally say runnable example / app-local POC /
  no production server behavior.

Remaining watch items:

- Some package lanes such as `igniter-application`, `igniter-web`,
  `igniter-ai`, `igniter-agents`, `igniter-cluster`, `igniter-hub`,
  `igniter-mcp-adapter`, and `igniter-durable-model` are active in source but
  are not part of the Ruby Framework `0.5.2` published gem set recorded in this
  lane. The package map now states that boundary, but future release docs should
  keep it explicit.
- `Igniter Lang Foundation` remains a strong label. Continue pairing it with
  "additive", "contracts-facing", "report-only", "metadata-only", and "not a
  compiler/runtime compatibility promise".
- Research/prototype examples remain in `examples/lineup` and
  `examples/semantic_gateway`. They are now marked outside the active release
  surface; no architecture rewrite or relocation was done in this round.

## Example Health

- Active examples remain preserved; no example architecture was rewritten.
- `examples/contracts/lang_foundation.rb` remains unchanged and continues to
  assert metadata is declared/not enforced.
- `examples/rails_contracts_ledger/README.md` now carries stronger proof-only
  wording while keeping its existing primary-observed-only boundary.
- Prototype examples are labeled as local research/prototype evidence, not
  released package examples.

## Requested Next Boundary

```text
Hold Ruby compiler compatibility package-doc sync until Igniter-Lang provides a
stable release-candidate export fixture. Keep any future sync docs-only unless a
separate route authorizes code/API work.
```

## Explicit Non-Authorizations

- No gem release.
- No tag or branch push.
- No Ruby public API widening.
- No example architecture rewrite.
- No Igniter-Lang compiler release compatibility claim.
- No Spark production adoption.
- No production promise changes.
