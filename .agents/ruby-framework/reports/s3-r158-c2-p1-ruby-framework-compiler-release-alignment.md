# Round Report: ruby-framework S3-R158-C2-P1 compiler release alignment

Status: PASS - docs boundary holds
Date: 2026-05-24
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: ruby-framework-compiler-release-alignment-fractal-seed-v0
Guidance: PG-2026-05-20-01
Scope: Assess Ruby Framework `0.5.2` alignment with the next Igniter-Lang
compiler release without pulling unfinished compiler surfaces into Ruby package
promises.

## Executive Summary

- Ran internal mini-round `RUBY-FR158 = [R1-P, R2-X] -> R3-S`.
- Ruby Framework `0.5.2` remains published/closed; no release action is needed.
- Current package docs/examples do not overclaim Igniter-Lang compiler
  readiness.
- Safe bridge is docs/evidence only: redacted, report-only metadata and receipt
  payloads carried through `igniter-contracts` Lang foundation surfaces.
- No Spark production-readiness claim is made or authorized.
- Recommended next boundary: wait for a stable Igniter-Lang release-candidate
  export fixture before any Ruby package-doc sync.

## Decisions Needed From Portfolio

- [ ] Confirm whether the next boundary is
  `lang-release-candidate-export-fixture` before Ruby opens any package-doc
  sync about compiler release compatibility.

## Completed

- Inventoried Ruby lane status, release closure, package docs, and examples
  that mention Lang/compiler readiness, app-local adoption, Ledger-facing
  adoption, or Spark-style receipt promises.
- Pressure-reviewed the docs for overclaims against unfinished compiler/lang
  surfaces.
- Identified a safe bridge shape for future compiler release-readiness:
  report-only, redacted metadata/receipt payloads with explicit
  non-authorization flags.

## Changed Files

- `.agents/ruby-framework/tracks/ruby-framework-compiler-release-alignment-fractal-seed-v0.md`
- `.agents/ruby-framework/reports/s3-r158-c2-p1-ruby-framework-compiler-release-alignment.md`
- `.agents/ruby-framework/current-status.md`

## Evidence

Reviewed:

- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/reports/ruby-rel-p6-0-5-2-post-release-closure.md`
- `README.md`
- `packages/README.md`
- `packages/igniter-contracts/README.md`
- `packages/igniter-embed/README.md`
- `packages/igniter-ledger/README.md`
- `packages/igniter-ledger-client/README.md`
- `docs/guide/igniter-lang-foundation.md`
- `examples/README.md`
- `examples/contracts/lang_foundation.rb`
- `examples/rails_contracts_ledger/README.md`

Key evidence:

- `docs/guide/igniter-lang-foundation.md` says Lang Foundation is additive and
  does not introduce a new compiler, runtime, scheduler, parser, or AST.
- `packages/igniter-contracts/README.md` keeps future compiler-pipeline proof
  profiles as metadata-only custom sections rather than public package API.
- `examples/contracts/lang_foundation.rb` checks metadata is declared and not
  enforced.
- `packages/igniter-embed/README.md` keeps observed-service examples
  host-local and warns not to infer release readiness or public schema from
  synthetic aggregate examples.
- `examples/rails_contracts_ledger/README.md` stays
  `primary_observed_only` and does not treat Ledger receipts as source of truth.

## Risks / Drift

- Prospective drift: the name `Igniter Lang Foundation` may be misread as
  compiler release readiness if future docs omit the current "additive /
  report-only / metadata-only / not runtime enforced" language.
- Ledger research docs contain future compiler/language ideas; they remain
  research or POC/pre-v1 material and should not be copied into release
  promises.
- Spark observed-service examples must remain app-local and
  primary-observed-only until one redacted receipt path is proven end-to-end.

## Cross-Lane Requests

To Igniter-Lang:

- Provide a stable release-candidate export fixture before asking Ruby to
  document compiler release compatibility.
- Include explicit non-authorization flags in any fixture intended for Ruby
  docs: `report_only: true`, `runtime_enforced: false`,
  `readiness_enforced: false`, and no raw refs.

To Portfolio:

- Keep Ruby compiler alignment as docs/evidence-only until that fixture exists.

To Spark CRM:

- No new request. Spark remains outside production adoption authority from this
  package release.

## Recommended Next

```text
hold-for-lang-release-candidate-export-fixture
```

Ruby should not release another gem, widen API, or claim compiler/runtime
compatibility until Igniter-Lang freezes the next release-candidate export
shape.

## Explicit Non-Authorizations

- No gem release.
- No tag push.
- No production promise changes.
- No Spark production adoption.
- No Ruby API widening.
- No compiler/parser/TypeChecker compatibility promise.
- No Ledger source-of-truth claim for Spark.
