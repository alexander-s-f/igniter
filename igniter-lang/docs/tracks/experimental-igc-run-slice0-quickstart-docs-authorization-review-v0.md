# Experimental igc run Slice 0 Quickstart Docs Authorization Review v0

Card: S3-R235-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-quickstart-docs-authorization-review-v0
Route: UPDATE
Status: authorized / bounded-docs-sync-next
Date: 2026-06-02

Depends on:
- S3-R234-C5-S

---

## Decision

Authorize a bounded pre-v1 quickstart/docs sync for the accepted experimental
`igc run` Slice 0 command.

This is docs exposure only. It may describe the accepted command as
experimental delegated-runtime Slice 0 evidence, with mandatory non-claims. It
does not authorize runtime/API/package changes, `.igbin` execution, compiler
passport emission, RuntimeSmoke productization, public runtime support,
Reference Runtime support, stable API, production readiness, Spark integration,
release evidence, public demo claims, or public performance claims.

Decision:

```text
authorized
```

Next implementation/docs-sync route:

```text
Card: S3-R235-C3-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice0-quickstart-docs-v0
```

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round234-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice0-implementation-pressure-v0.md`
- `igniter-lang/experiments/experimental_igc_run_v0/out/summary.json`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/experimental_igc_run.rb`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`

---

## Basis

R234 accepted a real bounded command:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Accepted evidence:

```text
IGR-1..IGR-20 PASS
checks_total: 20
checks_pass: 20
checks_fail: 0
positive output: outputs.sum == 42
compile regression: PASS / runtime_smoke null
```

Pressure result:

```text
PASS - accept unconditionally
no blockers
CF-1 / CF-2 informational only
```

The accepted implementation is useful enough to expose as a pre-v1 internal
quickstart. The exposure must remain narrow because the command is still
evidence-only and delegated-runtime-backed.

---

## Authorized Write Scope

Allowed files:

```text
igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md
igniter-lang/docs/README.md
igniter-lang/docs/current-status.md
```

Allowed purpose per file:

```text
experimental-igc-run-slice0-quickstart-docs-v0.md
  Main bounded quickstart doc. May include exact command shape, prerequisites,
  evidence refs, expected result packet shape, failure-mode examples, and
  non-claims.

docs/README.md
  One navigation pointer only. May link to the quickstart track and must label
  it as pre-v1 experimental delegated-runtime Slice 0 evidence only.

docs/current-status.md
  Compact status breadcrumb only. May record that docs exposure was authorized
  and/or completed after C3-I. Must preserve all R234 closed surfaces.
```

Forbidden files:

```text
igniter-lang/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/igniter_lang.gemspec
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/experiments/**
igniter-lang/examples/**
playgrounds/**
```

Root README and Ruby API docs remain closed because they are higher-authority
public/caller-facing surfaces. This route may not present `igc run` as a stable
user-facing API.

---

## Required Wording

The docs-sync must say, in substance:

```text
This is pre-v1 experimental `igc run` Slice 0 evidence.
It requires --experimental.
It accepts .igapp directories only.
It requires an explicit proof-local passport.
It requires explicit input JSON.
It requires explicit delegated runtime selector:
  delegated-experimental:ivm-proof
It writes a machine-readable local experimental result packet.
It is subject to change before v1.
It is not public runtime support.
It is not Reference Runtime support.
It is not production-ready.
It is not stable API.
It is not release evidence.
It is not Spark integration.
It is not public performance evidence.
```

Accepted result packet wording:

```text
experimental_igc_run_v0_result
pre_v1: true
stable_api: false
runtime_authority: non-canonical / delegated experimental
not CompilerResult
not CompilationReport
not CompatibilityReport
not receipt sidecar
not release evidence
not public API response contract
```

Accepted evidence citation policy:

```text
May cite:
- S3-R234-C4-A acceptance decision
- S3-R234-C5-S status curation
- C2-I proof track
- proof summary JSON, including 20/20 PASS and outputs.sum == 42

Must not cite evidence as certification, public support, production support,
stable API, portability guarantee, or release readiness.
```

---

## Forbidden Wording Scan Set

C3-I must scan touched docs for these forbidden or authority-risk phrases unless
they appear inside an explicit "not ..." non-claim:

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
all grammar support
```

Also scan for these older risky labels:

```text
production-compiler-cli
RuntimeSmoke support
```

---

## Proof / Docs Matrix For C3-I

Required checks:

```text
QSD-1  quickstart doc created in allowed track path
QSD-2  docs/README pointer, if edited, is navigation-only and low-authority
QSD-3  current-status breadcrumb, if edited, preserves R234 closures
QSD-4  exact Slice 0 command shape is present
QSD-5  --experimental requirement is explicit
QSD-6  .igapp-only scope is explicit
QSD-7  passport/input/runtime/out requirements are explicit
QSD-8  delegated-experimental:ivm-proof remains named as non-canonical
QSD-9  result packet is described as experimental_igc_run_v0_result only
QSD-10 no public runtime / Reference Runtime / stable API / production claim
QSD-11 .igbin, compiler passport emission, RuntimeSmoke remain closed
QSD-12 Spark/release/public demo/public performance claims remain closed
QSD-13 root README and docs/ruby-api remain unchanged
QSD-14 forbidden wording scan passes
QSD-15 accepted evidence citations point to R234 only
```

Suggested command matrix:

```text
ruby -e 'ARGV.each { |p| abort("#{p} missing") unless File.file?(p) }' \
  igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md

rg -n "stable run command|stable runtime API|production runtime|production-ready runtime|Reference Runtime support|public runtime support|certified runtime|certified compiler|portable artifact guarantee|release-ready runtime|Spark integration|public performance benchmark|all grammar support|production-compiler-cli|RuntimeSmoke support" \
  igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md \
  igniter-lang/docs/README.md \
  igniter-lang/docs/current-status.md

git diff --name-only
```

The forbidden phrase scan may pass with no matches, or with matches only inside
explicit non-claim/closed-surface text.

---

## Explicit Answers

Whether quickstart/docs exposure may begin:

```text
Yes. A bounded docs-sync may begin as S3-R235-C3-I.
```

Whether docs edits may touch README, docs README, docs ruby-api, or only
internal track/current-status surfaces:

```text
Root README remains closed.
docs/ruby-api.md remains closed.
docs/README.md may be narrowly touched as a navigation pointer only.
The main docs body must live in a track doc.
docs/current-status.md may be touched only as a compact status breadcrumb.
```

Whether generated docs may describe experimental delegated-runtime Slice 0
evidence only:

```text
Yes. That label is binding.
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

Whether `.igbin`, compiler passport emission, RuntimeSmoke productization,
Spark, release, production, public demo, and public performance claims remain
closed:

```text
Yes.
```

---

## Exact C3-I Boundary

```text
Card: S3-R235-C3-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice0-quickstart-docs-v0

Route: UPDATE
Depends on:
- S3-R235-C1-A
- S3-R235-C2-P1 if available before dispatch; otherwise optional sidecar input

Goal:
Write bounded pre-v1 quickstart/docs exposure for the accepted experimental
`igc run` Slice 0 command, using only accepted R234 evidence and preserving
all non-claims and closed surfaces.

Allowed write scope:
- igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md
- igniter-lang/docs/README.md
- igniter-lang/docs/current-status.md

Forbidden write scope:
- igniter-lang/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/igniter_lang.gemspec
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/experiments/**
- igniter-lang/examples/**
- playgrounds/**

Required content:
- exact `igc run` Slice 0 command shape;
- required artifacts and flags;
- accepted R234 proof summary: 20/20 PASS and outputs.sum == 42;
- result packet shape as experimental_igc_run_v0_result only;
- pre-v1 / no-stable-API wording;
- delegated experimental / non-canonical runtime wording;
- explicit non-claims for public runtime, Reference Runtime, production,
  Spark, release, public demo, public performance, RuntimeSmoke, `.igbin`,
  compiler passport emission, CompilerResult, CompilationReport, and
  CompatibilityReport.

Required proof matrix:
- QSD-1..QSD-15 from C1-A.

Do not:
- edit code;
- edit root README;
- edit docs/ruby-api.md;
- authorize or imply runtime/API/package changes;
- imply stable API, production, public runtime, Reference Runtime, Spark,
  release, public demo, public performance, RuntimeSmoke, `.igbin`, or
  compiler passport authority.

Deliver:
- Docs-sync track doc
- Compact summary
- Proof/scan result matrix
- Exact changed files
```
