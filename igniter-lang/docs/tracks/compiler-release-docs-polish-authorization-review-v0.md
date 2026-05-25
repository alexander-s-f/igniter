# Compiler Release Docs Polish Authorization Review v0

Card: S3-R179-C1-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: compiler-release-docs-polish-authorization-review-v0  
Route: UPDATE  
Status: done / authorized bounded docs polish  
Date: 2026-05-25

Depends on:
- S3-R178-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-planning-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-scope-v0.md`
- `igniter-lang/docs/tracks/compiler-release-public-readme-and-demo-claim-risk-survey-v0.md`
- `igniter-lang/docs/discussions/compiler-release-public-nonclaims-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round178-status-curation-v0.md`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- `igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig`

---

## Decision

Decision:

```text
authorize bounded docs polish implementation
authorize CR-1 in-place fix/fence
authorize limited README source-horizon cleanup
authorize limited docs index non-claims note
authorize limited ruby-api wording cleanup
do not authorize release-note draft
do not authorize package metadata/gemspec/version edits
keep CR-13 Spark production evidence internal-only
keep public release/demo claims closed
keep release execution closed
keep RubyGems publish closed
keep version/tag/push/publish/sign/deploy closed
keep profile finalization/discovery/defaulting closed
keep branch/conditional if_expr excluded
keep compiler/runtime behavior closed
```

A bounded implementation may begin in S3-R179-C2-I.

This authorization is for documentation hygiene and non-claim preservation only.
It does not authorize release execution, public release/demo claims, publication,
RubyGems availability claims, tags, push, signing, deployment, package metadata,
gemspec edits, compiler/runtime changes, or Spark integration wording.

---

## Authorized Write Scope

Only these files may be edited:

```text
igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-polish-v0.md
```

No other files are authorized.

---

## Required CR-1 Handling

CR-1 must be fixed in-place in:

```text
igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig
```

Current risky wording:

```text
Status:  production-ready library skeleton
```

Required replacement or equivalent:

```text
Status: external pressure specimen / non-canonical / not production-ready
```

The implementation may also add a short disposition header near the file top,
but only if it remains concise and does not alter language-spec content outside
the specimen header/status block.

Required meaning:

```text
active pressure specimen
non-canonical
not parser authority
not runtime authority
not production deployment authority
not public demo/release evidence
```

---

## README Boundary

README edit is authorized only for:

- replacing stale `Current Source Horizon` links that point to absent old paths;
- adding current internal navigation to:
  - `docs/README.md`;
  - `docs/current-status.md`;
  - `docs/ruby-api.md`;
  - accepted local release evidence/status if phrased as local evidence only;
- preserving the separation between Igniter platform and Igniter-Lang research.

README must not claim:

- public release readiness;
- RubyGems availability;
- production readiness;
- public demo readiness;
- all grammar support;
- branch/conditional `if_expr` support;
- profile finalization/discovery/defaulting support;
- Spark integration;
- Ruby Framework compatibility.

---

## Docs Index Boundary

`igniter-lang/docs/README.md` edit is authorized only for:

- adding a brief non-claims/current release-evidence note near the existing
  profile-source transport/navigation area;
- preserving the existing bounded CLI profile-source wording;
- avoiding public release/demo/production/RubyGems claims.

Do not restructure the index.
Do not create `docs/guide/README.md` or `docs/dev/README.md` in this card.
Do not edit Stage 1/Stage 2 historical sections except for a small navigation
note if absolutely necessary.

---

## Ruby API Boundary

`igniter-lang/docs/ruby-api.md` edit is authorized only for CR-4 wording cleanup:

Allowed changes:

- replace "current public Ruby facade for the proof compiler" with a bounded
  phrase such as "current caller-facing local proof compiler API";
- replace round-governance phrasing such as "R52 adds" with public-safe wording
  such as "Currently supported bounded CLI profile-source transport:";
- preserve all existing non-authorized profile-source shapes and production
  behavior exclusions.

Do not change API behavior descriptions beyond wording safety.
Do not remove the existing closed-surface/non-authority sections.

---

## Release-Note Draft

Release-note draft creation is not authorized in this round.

Reason:

```text
CR-1 should be fixed/fenced and pressure-reviewed first.
Public copy placement remains closed.
```

---

## CR-13 Spark Handling

CR-13 remains internal-only.

Do not add public wording about Spark production evidence.

Do not write:

```text
Spark integrated
Spark production evidence
Spark readiness
```

If a file already references Spark internally, preserve internal-only status and
do not surface it in public-facing README/docs index copy.

---

## Required Non-Claims Block

If the implementation adds or edits a release-evidence note, it must include or
preserve a nearby non-claims statement with this meaning:

```text
Local compiler/package evidence only.
Not a release, publish, production, or public demo claim.
RubyGems publish, release execution, version/tag/push/sign/deploy,
profile finalization/discovery/defaulting, branch/conditional if_expr,
Spark integration, runtime, and production behavior remain out of scope.
```

Exact wording may be compact, but the meaning must be preserved.

---

## Forbidden Phrase Scan Set

After edits, C2-I must run or otherwise report a search for these phrase
families in changed files:

```text
production-ready
production ready
public release ready
release ready
demo ready
RubyGems available
available on RubyGems
published package
install from RubyGems
supports all grammar
supports branch
supports conditional
supports if_expr
profile discovery
profile defaulting
profile finalization
Spark integrated
Spark ready
Ruby Framework compatible
```

Expected result:

- no forbidden phrase appears as an active public/project claim in changed files;
- historical/exclusion wording is allowed only when it clearly negates or fences
  the claim.

---

## Proof Matrix For C2-I

C2-I must prove:

```text
P1: changed files are exactly within authorized write scope
P2: CR-1 risky status line is removed or fenced
P3: README stale source-horizon paths are either removed or replaced safely
P4: docs index preserves bounded CLI/profile-source non-claims
P5: ruby-api wording no longer implies a public release announcement
P6: CR-13 remains internal-only; no public Spark production evidence wording
P7: forbidden phrase scan completed
P8: release execution/public claims/RubyGems/version/tag/push/sign/deploy remain closed
P9: no compiler/runtime/package metadata/gemspec code changed
```

---

## Excluded Surfaces

Closed unless explicitly authorized by a later card:

```text
release execution
RubyGems publish
version/tag/push/publish/sign/deploy
public release/demo claims
production readiness claims
all-grammar support claims
branch/conditional if_expr support claims
profile finalization/discovery/defaulting
Spark integration
runtime/production behavior
package metadata
gemspec
compiler/runtime code
README release announcement
release-note draft
website copy
external announcement text
```

---

## Exact C2-I Boundary

```text
Card: S3-R179-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: compiler-release-public-nonclaims-docs-polish-v0

Route: UPDATE
Depends on:
- S3-R179-C1-A

Goal:
Perform the bounded docs polish authorized by S3-R179-C1-A.

Allowed writes:
- igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig
- igniter-lang/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-polish-v0.md

Required:
- fix/fence CR-1;
- clean stale README source horizon safely;
- keep docs index/ruby-api non-claims explicit;
- keep CR-13 internal-only;
- run/report forbidden phrase scan on changed files;
- produce track doc with proof matrix P1-P9.

Not authorized:
- release execution;
- public release/demo claims;
- RubyGems publish;
- version/tag/push/publish/sign/deploy;
- package metadata/gemspec;
- compiler/runtime code;
- release-note draft;
- Spark public wording.
```

---

## Compact Summary

```text
S3-R179-C1-A authorizes a bounded docs polish implementation.
Allowed writes are limited to CR-1 specimen, README, docs README, ruby-api, and
the implementation proof track.
CR-1 must be fixed/fenced.
CR-13 remains internal-only.
No release-note draft, release execution, public release/demo claim, RubyGems
publish, version/tag/push/sign/deploy, package metadata, gemspec, compiler code,
runtime code, Spark public wording, or production claim is authorized.
```
