# Experimental igc run Slice 1 Quickstart Docs Authorization Review v0

Card: S3-R244-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-quickstart-docs-authorization-review-v0
Route: UPDATE
Status: authorized / bounded-docs-sync-next
Date: 2026-06-03

Depends on:
- S3-R243-C4-A
- S3-R243-C5-S

---

## Decision

Authorize a bounded internal quickstart/docs sync for the accepted
experimental `igc run` Slice 1 VM candidate Path C behavior.

This is documentation exposure only. It may describe the accepted Slice 1
selector as pre-v1 experimental delegated-runtime evidence, with explicit
machine-readable fail-closed behavior for the current `integer_add` /
`stdlib_integer_add` capability gap.

It does not authorize positive Add.igapp integer execution, `igc run` widening,
runtime/API/package changes, `.igbin` execution, compiler passport emission,
RuntimeSmoke productization, public runtime support, Reference Runtime support,
stable API, production readiness, Spark integration, release evidence, public
demo claims, public performance claims, alternative certification, portability
guarantees, or adjacent source/conformance artifact authority.

Decision:

```text
authorized
```

Next docs-sync route:

```text
Card: S3-R244-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice1-quickstart-docs-v0
```

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round243-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice1-vm-candidate-implementation-pressure-v0.md`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/summary.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice1_integer_add_blocked.result.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice0_compat.result.json`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/experimental_igc_run.rb`
- `igniter-lang/lib/igniter_lang/experimental_igc_run_vm_candidate.rb`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/README.md`
- `igniter-lang/docs/ruby-api.md`

---

## Basis

R243 is accepted enough for bounded internal documentation exposure because the
status curation closed the C4-A condition:

```text
R243 Slice 1 VM candidate implementation/proof: conditionally accepted
condition: satisfied by adjacent-artifact exclusion in C5-S
selected AN-1 path: Path C fail-closed
IGR-S1: 18/18 PASS
Slice 0 compatibility: PASS, sum=42
claim scan: 0 hits
positive Add.igapp integer_add execution: not accepted
```

Accepted Slice 1 selector:

```text
delegated-experimental:igniter-vm-candidate
```

Accepted Slice 1 `runtime_implementation_id`:

```text
igniter.delegated.experimental.vm.rust-tokio.v0
```

Accepted Path C blocked packet:

```text
kind: experimental_igc_run_slice1_result
status: blocked
runtime_selector: delegated-experimental:igniter-vm-candidate
runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
selected_an1_path: Path C fail-closed
diagnostics:
  unsupported_capability_integer_add
  unsupported_capability_stdlib_integer_add
outputs: {}
stable_api: false
pre_v1: true
experimental: true
not_runtime_smoke: true
not_compiler_passport_emission: true
```

Accepted Slice 0 compatibility packet:

```text
runtime_selector: delegated-experimental:ivm-proof
status: ok
outputs.sum: 42
```

The docs-sync is justified because it makes the current experimental behavior
usable and legible while preserving the core limitation: Slice 1 currently
demonstrates selector/binding/passport validation and fail-closed diagnostics,
not positive integer execution through the VM candidate.

---

## Authorized Write Scope

Allowed files:

```text
igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-v0.md
igniter-lang/docs/current-status.md
igniter-lang/docs/README.md
```

Allowed purpose per file:

```text
experimental-igc-run-slice1-quickstart-docs-v0.md
  Main bounded internal quickstart doc. May include command shape,
  prerequisites, evidence refs, blocked result packet shape, Slice 0
  compatibility note, failure-mode examples, and non-claims.

docs/current-status.md
  Compact breadcrumb only. May record that R244 docs exposure was authorized
  and/or completed, and must preserve all R243 closed surfaces.

docs/README.md
  One narrow navigation pointer only. May link to the Slice 1 quickstart track
  beside the existing Slice 0 pointer, and must label it as pre-v1
  experimental delegated-runtime Slice 1 Path C fail-closed evidence only.
```

Forbidden files:

```text
igniter-lang/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/igniter_lang.gemspec
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/experiments/**
igniter-lang/examples/**
playgrounds/**
```

Root README and Ruby API docs remain closed because they are higher-authority
caller/public-facing surfaces. This route may not present `igc run` Slice 1 as
a stable user-facing runtime API.

---

## Required Wording

The docs-sync must say, in substance:

```text
This is pre-v1 experimental `igc run` Slice 1 evidence.
It requires --experimental.
It accepts .igapp directories only.
It requires an explicit proof-local passport/binding validation path.
It requires explicit input JSON.
It requires explicit delegated runtime selector:
  delegated-experimental:igniter-vm-candidate
It names runtime_implementation_id only as evidence-facing metadata:
  igniter.delegated.experimental.vm.rust-tokio.v0
It currently uses Path C fail-closed behavior for integer_add /
stdlib_integer_add.
It writes a machine-readable blocked result packet for this capability gap.
It is subject to change before v1.
It is not public runtime support.
It is not Reference Runtime support.
It is not production-ready.
It is not stable API.
It is not release evidence.
It is not Spark integration.
It is not public performance evidence.
```

The docs-sync must include the exact blocked diagnostics:

```text
unsupported_capability_integer_add
unsupported_capability_stdlib_integer_add
```

The docs-sync must keep Slice 0 compatibility separate:

```text
Slice 0 delegated-experimental:ivm-proof compatibility remains a separate
selector sanity check. Its `outputs.sum == 42` result must not be described as
Slice 1 VM candidate success.
```

The docs-sync must include adjacent artifact exclusion wording:

```text
Adjacent source/conformance artifacts excluded by R243-C5-S are not accepted
as Slice 1 docs evidence, runtime authority, conformance authority,
portability evidence, public claim support, release evidence, or alternative
certification.
```

---

## Accepted Evidence Citation Policy

May cite:

```text
S3-R243-C4-A acceptance decision
S3-R243-C5-S status curation
S3-R243-C2-I proof track
S3-R243-C3-X pressure verdict
summary.json: 18/18 IGR-S1 PASS
slice1_integer_add_blocked.result.json: status=blocked and two diagnostics
slice0_compat.result.json: status=ok and outputs.sum=42
```

Must not cite evidence as:

```text
public runtime support
Reference Runtime support
positive Add.igapp integer execution
production support
stable API
portability guarantee
alternative certification
release readiness
public performance evidence
```

---

## Forbidden Wording Scan Set

C2-I must scan touched docs for these forbidden or authority-risk phrases
unless they appear inside an explicit "not ..." non-claim:

```text
stable run command
stable runtime API
production runtime
production-ready runtime
Reference Runtime support
public runtime support
certified runtime
certified compiler
portable artifact guarantee
release-ready runtime
Spark integration
public performance benchmark
public runtime demo
positive Slice 1 execution
Slice 1 integer execution
```

---

## Required Proof Matrix for C2-I

```text
QD-S1-1   authorized write scope followed
QD-S1-2   command shape matches accepted Slice 1 selector
QD-S1-3   Path C fail-closed behavior described clearly
QD-S1-4   integer-add blocked diagnostics named exactly
QD-S1-5   Slice 0 compatibility kept separate from Slice 1 evidence
QD-S1-6   runtime_implementation_id remains evidence-facing metadata
QD-S1-7   positive Add.igapp integer execution is not claimed
QD-S1-8   .igbin remains excluded
QD-S1-9   compiler passport emission remains closed
QD-S1-10  RuntimeSmoke productization remains closed
QD-S1-11  public/runtime/reference/stable/production/release/performance/
           portability claims remain closed
QD-S1-12  adjacent source/conformance artifacts remain excluded
QD-S1-13  forbidden wording scan passes
QD-S1-14  closed-surface scan passes
```

Suggested command / scan matrix:

```text
rg -n "stable run command|stable runtime API|production runtime|production-ready runtime|Reference Runtime support|public runtime support|certified runtime|certified compiler|portable artifact guarantee|release-ready runtime|Spark integration|public performance benchmark|public runtime demo|positive Slice 1 execution|Slice 1 integer execution" <touched docs>
git diff --name-only
git status --short
```

---

## Exact C2-I Boundary

```text
Card: S3-R244-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice1-quickstart-docs-v0

Route: UPDATE
Depends on:
- S3-R244-C1-A

Goal:
Write bounded internal quickstart/docs exposure for accepted experimental
`igc run` Slice 1 VM candidate Path C fail-closed behavior, without creating
public runtime support, Reference Runtime support, stable API, production
readiness, release evidence, public performance claims, portability guarantees,
or adjacent conformance authority.

Allowed write scope:
- igniter-lang/docs/tracks/
  experimental-igc-run-slice1-quickstart-docs-v0.md
- igniter-lang/docs/current-status.md
- igniter-lang/docs/README.md
  only one narrow navigation pointer

Read-only / closed unless explicitly authorized:
- igniter-lang/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/igniter_lang.gemspec
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/experiments/**
- igniter-lang/examples/**
- playgrounds/**

Required output:
- quickstart/docs track
- compact QD-S1 proof matrix
- changed-file list
- forbidden wording scan result
- exact C4-A recommendation or blocker list
```

---

## Explicit Answers

Whether quickstart/docs exposure may begin:

```text
Yes. Authorize bounded internal docs exposure.
```

Whether docs edits may touch docs README or only track/current-status surfaces:

```text
Docs edits may touch the track doc, current-status, and one narrow
docs/README.md navigation pointer. Root README and ruby-api remain closed.
```

Whether generated docs may describe experimental delegated-runtime Slice 1 Path
C evidence only:

```text
Yes. They must describe Slice 1 as pre-v1 experimental delegated-runtime
Path C fail-closed evidence only.
```

Whether the docs may show the blocked Slice 1 result packet:

```text
Yes. They should show the blocked packet as the honest accepted behavior.
```

Whether the docs may show Slice 0 compatibility as a separate selector sanity
check:

```text
Yes. It must stay separate from Slice 1 VM candidate evidence and must not be
presented as Slice 1 success.
```

Whether this creates public runtime support:

```text
No.
```

Whether this creates Reference Runtime support:

```text
No.
```

Whether stable API remains unpromised before v1:

```text
Yes.
```

Whether positive Add.igapp integer execution, `.igbin`, compiler passport
emission, RuntimeSmoke productization, Spark, release, production, public demo,
public performance, alternative certification, and portability claims remain
closed:

```text
Yes. All remain closed.
```

---

## Decision Summary

```text
authorize C2-I bounded internal quickstart/docs sync
allow docs/tracks quickstart doc
allow current-status compact breadcrumb
allow docs/README one narrow navigation pointer
keep root README and ruby-api closed
require Path C blocked behavior as the central Slice 1 docs truth
require Slice 0 compatibility to stay separate
keep all public/runtime/reference/stable/release/performance claims closed
```
