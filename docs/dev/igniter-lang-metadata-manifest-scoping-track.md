# Igniter Lang Metadata Manifest Scoping Track

This track scopes the next Igniter-Lang step after the additive foundation pack.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Contracts / Codex]
[Research Horizon / Codex]
```

Inputs:

- [Igniter Lang Foundation Pack Track](./igniter-lang-foundation-pack-track.md)
- [Igniter-Lang Implementation Delta Report](../research-horizon/igniter-lang-implementation-delta-report.md)
- [Igniter-Lang Implementation Strategy](../experts/igniter-lang/igniter-lang-implementation.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the additive
Igniter-Lang foundation pack.

The next candidate is metadata/report-only language support. This is a scoping
track, not approval to implement runtime semantics.

## Goal

Define the smallest useful metadata manifest slice that can build on
`Igniter::Lang` without changing contract execution.

The result should answer:

- which metadata declarations are safe now
- how metadata appears in `VerificationReport`
- what wording prevents users from assuming runtime enforcement
- whether implementation should proceed next or wait for more pressure

Candidate metadata, if safely scoped:

- `store` declarations as manifest/report only
- `deadline` / `wcet` declarations as budget metadata only
- invariant metadata for existing external invariant suites
- optional `return_type:` reporting only, not enforcement

## Scope

In scope:

- design/scoping only
- report shape proposal for metadata manifests
- API sketch for Ruby DSL usage
- explicit non-enforcement language
- package ownership recommendation
- acceptance criteria for a later implementation track

Out of scope:

- implementing DSL keywords
- changing compiler/runtime behavior
- adding stores, adapters, OLAP handlers, time-machine behavior, warning
  channels, deadline monitoring, unit algebra, Rust, parser, or grammar
- claiming metadata is enforced
- public onboarding docs that imply the language is production-ready

## Task 1: Contracts Metadata Scoping

Owner: `[Agent Contracts / Codex]`

Acceptance:

- Propose the smallest metadata manifest model compatible with current
  contracts/profile/operation APIs.
- Identify which declarations can be represented without runtime behavior and
  which would require compiler/runtime changes.
- Sketch how `VerificationReport` would expose stores, deadlines, WCET,
  invariant metadata, or return-type metadata.
- Recommend whether the next step should be implementation, docs-only, or
  defer.

## Task 2: Research Boundary Scoping

Owner: `[Research Horizon / Codex]`

Acceptance:

- Reconcile the metadata manifest slice with the broader Igniter-Lang research.
- Keep `store`, `deadline`, `olap`, `rule`, `time_machine`, physical units,
  grammar, Rust, and export phases separated by actual semantic depth.
- Provide exact language for "metadata/report-only, not runtime enforcement".
- Identify the first real pressure test that would justify moving from metadata
  to runtime semantics.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is about truth in labeling. Metadata declarations are useful only if the
  docs and report shape do not overpromise.
- Do not sneak in runtime behavior because the DSL shape looks convenient.
- Prefer boring manifests over clever language constructs.
- If the scoping cannot make enforcement boundaries obvious, defer the feature.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes unexpectedly, run the relevant specs/smoke/lint for the touched
area.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Contracts / Codex]` scopes metadata manifest support over the current
   Lang foundation.
2. `[Research Horizon / Codex]` scopes the research boundary and non-enforcement
   wording.
3. `[Architect Supervisor / Codex]` decides whether to implement, document, or
   defer metadata manifests.

## Contracts Scoping Proposal

[Agent Contracts / Codex] Proposal for review.

### Recommendation

Proceed next with a narrow implementation only if it stays report-only.

Recommended next slice:

- add `Igniter::Lang::MetadataManifest` as a read-only value object
- extend `VerificationReport#to_h` with `metadata_manifest:`
- collect metadata already present on operations, such as `type:`,
  `return_type:`, `deadline:`, and `wcet:`
- optionally support manifest-only declaration records through existing
  operation attributes or explicit wrapper calls in `Igniter::Lang`, not through
  new runtime node handlers

Do not add `store`, `deadline`, `wcet`, `invariant`, or `return_type` as
enforced semantics in this slice.

### Smallest Manifest Model

The manifest should be boring and serializable:

```ruby
{
  stores: [],
  budgets: [
    {
      node: :price_quote,
      deadline: 50,
      wcet: 20,
      units: :ms,
      enforced: false
    }
  ],
  invariants: [],
  return_types: [
    {
      node: :gross_total,
      return_type: "Numeric",
      enforced: false
    }
  ],
  descriptors: [
    {
      node: :price_history,
      type: {
        kind: :history,
        of: "Numeric",
        dimensions: {},
        metadata: {}
      }
    }
  ],
  semantics: {
    runtime_enforced: false,
    report_only: true
  }
}
```

Every entry that looks like a requirement should carry `enforced: false` until
real compiler/runtime behavior exists.

### Safe Now

Safe metadata/report-only declarations:

- `type:` with `Igniter::Lang` descriptors, already proven by the foundation
  pack
- `return_type:` as declared metadata only
- `deadline:` and `wcet:` as declared budget metadata only
- store declarations as manifest records only if they are clearly not runtime
  stores
- invariant metadata as references to external invariant suites only

These are compatible with current `Operation#attributes`,
`CompiledGraph#operations`, and `VerificationReport`.

### Requires Later Compiler/Runtime Work

Do not implement as part of the metadata manifest slice:

- actual storage adapters or store reads/writes
- OLAP runtime nodes or slice objects
- temporal rule application
- runtime deadline monitoring
- warning channels in `ExecutionResult`
- physical unit algebra or dimensional checking
- return type inference or enforcement
- inline contract invariant execution
- grammar, parser, AST, Rust backend, or exports

### Suggested Ruby DSL Surface

Prefer wrapper-level declaration methods before new baseline DSL keywords:

```ruby
backend = Igniter::Lang.ruby_backend

compiled = backend.compile do
  input :price_history, type: Igniter::Lang::History[Numeric]

  compute :gross_total,
          depends_on: [:price_history],
          return_type: Numeric,
          wcet: 20 do |price_history:|
    price_history.fetch(:latest)
  end

  output :gross_total
end

report = backend.verify(compiled)
report.metadata_manifest.to_h
```

For store declarations, prefer explicit Lang wrapper objects first:

```ruby
manifest = Igniter::Lang.metadata do |m|
  m.store :price_history,
          type: Igniter::Lang::History[Numeric],
          backend: :timeseries,
          enforced: false
end
```

Only promote `store` into a DSL keyword after a later track decides how
declaration-only DSL should be represented in compiled artifacts.

### VerificationReport Shape

`VerificationReport` should remain read-only and non-enforcing:

```ruby
report.ok?
report.findings
report.descriptors
report.metadata_manifest
report.to_h
```

`ok?` should continue to reflect current compilation findings only. Metadata
manifest warnings such as "declared budget exceeds deadline" should not become
runtime enforcement without a later warning/finding policy track.

### Ownership

Recommended package placement:

- `igniter-contracts`
  owns `MetadataManifest`, `VerificationReport` serialization, and descriptor
  metadata extraction.
- `igniter-extensions`
  may later own optional invariant/report packs if they become reusable beyond
  Lang.
- `igniter-embed`, `igniter-application`, and `igniter-cluster`
  must not own Lang metadata semantics; they may display or persist reports.

### Recommendation For Next Step

Open a narrow implementation track for `MetadataManifest` if
`[Research Horizon / Codex]` agrees the non-enforcement wording is clear.

Acceptance for that later implementation should require:

- no new runtime handlers
- no `ExecutionResult` changes
- no warning channel
- no store adapters
- no new dependencies
- `metadata_manifest.to_h` contains `report_only: true` or equivalent
- specs prove metadata appears in reports but does not affect execution
- docs/examples say "declared, not enforced"

If the non-enforcement wording cannot be made obvious, defer metadata manifests
and keep the current foundation pack only.
