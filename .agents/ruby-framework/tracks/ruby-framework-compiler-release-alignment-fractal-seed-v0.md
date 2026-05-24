# Ruby Framework Compiler Release Alignment Fractal Seed v0

Status: PASS - docs boundary holds
Date: 2026-05-24
Card: S3-R158-C2-P1
Route: UPDATE
Track: ruby-framework-compiler-release-alignment-fractal-seed-v0
Guidance: PG-2026-05-20-01

## Purpose

Assess how the released Ruby framework line should prepare for the next
Igniter-Lang compiler release without pulling unfinished compiler surfaces into
Ruby package promises.

Internal mini-round:

```text
RUBY-FR158 = [R1-P, R2-X] -> R3-S
```

## R1-P Inventory

Reviewed local Ruby operating surface and package/example docs that may imply
compiler/lang readiness, local app adoption, Ledger-facing adoption, or Spark
production promises.

Relevant surfaces:

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

Findings:

- `igniter-contracts` exposes `require "igniter/lang"` as an additive
  contracts-facing Lang namespace. It says the Ruby backend wraps current
  compile/execute/diagnose/verify APIs and that future compiler-pipeline proof
  profiles remain metadata-only custom sections.
- `docs/guide/igniter-lang-foundation.md` explicitly says there is no new
  compiler, runtime, scheduler, parser, AST, or `.il` production language
  runtime.
- `examples/contracts/lang_foundation.rb` proves descriptors and manifest
  reporting while checking metadata is declared and not enforced.
- `igniter-embed` docs keep observed-service examples host-local and explicitly
  warn not to infer release readiness or public schema from synthetic aggregate
  examples.
- `examples/rails_contracts_ledger/README.md` stays in
  `primary_observed_only` mode and does not treat Ledger receipts as source of
  truth.
- `igniter-ledger-client` names Spark adapters as host/app-facing users of the
  client boundary, while excluding Spark-specific code from the package.
- `igniter-ledger` remains active but POC/pre-v1. Its future contract DSL
  language is framed as future sugar lowerable to Store/History capability
  manifests, not as current compiler release support.

## R2-X Pressure Review

Verdict: current public Ruby package docs do not overclaim Igniter-Lang compiler
release readiness.

The safe boundary is already present:

```text
Ruby package surface:
  additive Lang foundation
  current contracts runtime wrapper
  report-only metadata and receipts
  redacted opaque custom sections
  no runtime enforcement from future compiler profiles

Not promised:
  standalone grammar/parser/AST
  .il file execution
  compiler pass compatibility guarantee
  TypeChecker enforcement
  production compiler release support
  Spark production adoption
```

Watch item:

- `Igniter Lang Foundation` is a strong label. Future readers may interpret it
  as readiness for the next compiler release unless docs continue to say
  "additive", "contracts-facing", "metadata/report-only", and "not a separate
  production language runtime".

No immediate package doc patch is required. The drift risk is prospective:
when the next Igniter-Lang compiler release candidate lands, Ruby should not
copy unstable compiler vocabulary into gem docs until the compiler lane provides
a stable fixture/export boundary.

## R3-S Local Supervisor Summary

Current package/release status:

- Ruby Framework `0.5.2` is published on Rubygems for:
  - `igniter-contracts`
  - `igniter-extensions`
  - `igniter-embed`
  - `igniter-ledger-client`
  - `igniter-ledger`
  - `igniter`
- Release corridor is closed.
- Native extension note remains active for `igniter-ledger`: clean install may
  require crates.io/network access unless Rust dependencies are vendored or
  prebuilt native artifacts are introduced.

Documentation drift:

- No current blocking drift.
- Prospective drift only: keep Lang compiler bridge language report-only until
  the compiler lane freezes a release candidate export shape.

Safe bridges to compiler release-readiness:

- Accept compiler POC outputs only as redacted, opaque
  `VerificationReport#metadata` / `DiagnosticPayload` / `ReceiptPayload`
  examples.
- Require non-authorization flags such as `report_only: true`,
  `runtime_enforced: false`, and `readiness_enforced: false`.
- Treat compiler fixtures as evidence payloads, not as Ruby execution
  contracts.
- Open a docs-only compatibility note only after Igniter-Lang provides a stable
  fixture/export vocabulary.

Requested next boundary:

```text
Portfolio should keep Ruby compiler-alignment docs-only until Igniter-Lang
declares a stable release-candidate export fixture. Ruby should not release,
generalize API, or promise compiler/runtime compatibility from the current POC.
```

## Explicit Non-Authorizations

- No gem release.
- No tag push.
- No production promise changes.
- No Spark production adoption.
- No Ruby API widening.
- No compiler/parser/TypeChecker compatibility promise.
- No Ledger source-of-truth claim for Spark.
