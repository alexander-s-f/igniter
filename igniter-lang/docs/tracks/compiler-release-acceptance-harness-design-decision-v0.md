# Compiler Release Acceptance Harness Design Decision v0

Card: S3-R160-C3-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `compiler-release-acceptance-harness-design-decision-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md`
- `igniter-lang/docs/discussions/compiler-release-acceptance-harness-design-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-and-ruby-hygiene-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round159-status-curation-v0.md`

---

## Portfolio Decision

Decision:

```text
accept compiler-release-acceptance-harness-design-v0
accept compiler-release-acceptance-harness-design-pressure-v0
do not open RC evidence gathering yet
do not open release execution
open bounded implementation-authorization review next
```

No implementation is authorized by this decision.

---

## Harness Design Status

Portfolio accepts the harness design.

The design is sufficiently specific as a first release-candidate acceptance
harness boundary because it defines:

- accepted harness inputs;
- stable artifact fields;
- normalized artifact fields;
- excluded/non-blocking artifact fields;
- positive RC corpus requirements;
- negative/refusal RC corpus requirements;
- command matrix;
- package/install/load-path stance;
- PASS/HOLD/FAIL result packet shape;
- closed-surface scan policy;
- release documentation non-claims template;
- analyzer/tracer/visualizer disposition.

The design remains a design boundary. It does not itself produce RC evidence.

---

## R159 NB-1..NB-5 Status

Portfolio accepts that the five mandatory R159 notes were answered sufficiently
for design closure.

| Note | Status | Accepted answer |
| --- | --- | --- |
| NB-1 | accepted | RC corpus must include feature diversity beyond module count; branch/conditional coverage is required if supported by already accepted behavior, otherwise first RC is HOLD unless Portfolio accepts narrower scope. |
| NB-2 | accepted | `production_compiler_cli_proof` is provenance only; RC CLI/API/load-path checks must rerun in harness or same-round RC smoke. |
| NB-3 | accepted | Normative non-claims template is included and must be copied or equivalently preserved in future RC docs. |
| NB-4 | accepted | Warnings arrays/counts are in scope as present/empty result-shape fields; warning-producing positive behavior is deferred; unexpected warnings produce HOLD. |
| NB-5 | accepted | RC-wide negative scan token list is declared with narrow allowed-context exceptions. |

---

## Pressure Notes Carried Forward

The pressure review proceeds with no blockers and 10/10 challenge checks clean.

The following non-blocking notes become mandatory inputs for the next
implementation-authorization review:

| ID | Required answer before implementation authorization |
| --- | --- |
| NB-1 | Clarify that the multi-input corpus case must exercise input-diversity, not merely three summed integers. |
| NB-2 | Pin the normalization failure specimen interpretation: fixture-based normalization test, two-run stability test, or both. |
| NB-3 | Confirm whether current assembler output includes `compatibility_metadata.json`; if absent, classify it as HOLD-if-absent or optional/future-only, not accidental FAIL. |
| NB-4 | Add `claimed_surfaces` to the machine-readable `release_scope` packet shape. |
| NB-5 | Declare FAIL-over-HOLD precedence when both trigger in one run. |

These notes are not blockers for accepting the design. They are blockers for
authorizing implementation unless explicitly answered in the next review.

---

## Next Route

Portfolio opens a bounded implementation-authorization review, not
implementation.

Exact next card boundary:

```text
Card: S3-R161-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-acceptance-harness-implementation-authorization-review-v0
Route: UPDATE
```

Goal:

```text
Decide whether a bounded proof-local compiler release acceptance harness runner
implementation may begin.
```

Required scope:

- read this decision;
- read `compiler-release-acceptance-harness-design-v0`;
- read `compiler-release-acceptance-harness-design-pressure-v0`;
- answer the five carried-forward pressure notes;
- survey the exact code/artifact touchpoints needed for a local proof harness;
- define write scope, runner shape, summary shape, command matrix, output
  directory, no-mutation policy, and closed surfaces;
- decide authorize / hold / redirect / reject.

Default candidate write scope for review only:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-proof-v0.md
```

The authorization review may refine or reject this scope. It must not authorize
anything outside an explicitly named proof-local harness boundary.

---

## RC Evidence Gathering Status

RC evidence gathering remains closed.

Reason:

- the harness design is accepted;
- the harness runner is not implemented or authorized yet;
- no fresh RC matrix has run under accepted harness rules;
- release-candidate evidence must be produced by a later accepted harness
  implementation/proof route.

---

## Analyzer / Tracer / Visualizer

Disposition:

```text
design vocabulary accepted
proof-local harness summary/artifact linkage may be designed into the runner
public analyzer/tracer/visualizer implementation held
public command/UI held
```

The next authorization review may include machine-readable artifact-trace
linkage and summary fields, but it must not authorize an interactive visualizer,
public command, report/loader route, or UI.

---

## Spark And Ruby Disposition

Spark:

- remains sanitized fixture/design pressure only;
- no Spark fixture creation opens in the next route;
- no direct Spark code/data access, integration, production behavior, or
  primary-ledger replacement is authorized.

Ruby Framework:

- remains held until Igniter-Lang declares a stable release-candidate export
  fixture;
- no Ruby docs sync, release, tag, package change, public API widening, or
  compiler-compatibility claim is authorized.

---

## Closed Surfaces

This decision does not authorize:

- harness implementation;
- release evidence gathering or RC execution;
- mutation of POC outputs or `.igapp` artifacts;
- release execution;
- public release or public demo claims;
- analyzer/tracer/visualizer implementation or public command;
- public API/CLI widening;
- root require or compiler pipeline changes;
- parser, classifier, TypeChecker, SemanticIR, or assembler changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or `CompatibilityReport` widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.
