# Compiler Release Profile-Source Installed Readiness Marker Acceptance Decision v0

Card: S3-R177-C3-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0  
Route: UPDATE  
Status: done  
Date: 2026-05-25

Depends on:
- S3-R177-C1-S
- S3-R177-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-v0.md`
- `igniter-lang/docs/discussions/compiler-release-profile-source-installed-readiness-marker-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round176-status-curation-v0.md`
- `igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json`

---

## Decision

Decision:

```text
accept profile-source installed readiness marker
recognize marker only as bounded local installed-package profile-source smoke readiness
carry NB-1 temp cleanup as non-blocking hygiene
open public release/docs non-claims planning next
keep release execution closed
keep public release/demo claims closed
keep RubyGems publish closed
keep version/tag/push/publish/sign/deploy closed
keep profile finalization/discovery/defaulting closed
keep branch/conditional if_expr excluded
keep Spark out of scope
```

The S3-R177-C1-S marker is accepted as an accurate bounded record of the S3-R176
accepted smoke evidence.

Accepted marker:

```text
marker: bounded_profile_source_installed_smoke_readiness
scope: bounded_installed_package_profile_source_smoke
accepted_by: S3-R176-C3-A
run_id: S3R176C1I_20260525T101425Z
package: igniter_lang
version: 0.1.0.pre.stage2
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
status: PASS
failed_checks: 0
hold_reasons: 0
```

This acceptance does not authorize release execution, RubyGems publish, public
release/demo claims, version changes, tags, push, signing, deployment, public
API/CLI widening, or additional compiler behavior.

---

## Accepted Wording

The accepted marker wording is:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI preserves the
accepted --compiler-profile-source PATH.json transport for one valid finalized
profile-source case, one malformed JSON preflight refusal, and one semantic
wrong-kind refusal.
```

This is the full marker scope.

It is not:

- public release readiness;
- public docs readiness;
- RubyGems availability;
- production readiness;
- demo readiness;
- all-grammar support;
- branch/conditional `if_expr` support;
- profile finalization/discovery/defaulting support;
- Spark integration;
- Ruby Framework compatibility.

---

## Evidence Accepted

Accepted proof state:

```text
PSS-0: PASS - isolated build/install/require; no repo path leak
PSS-1: PASS - installed $BIN_DIR/igc and explicit --compiler-profile-source PATH.json
PSS-2: PASS - valid finalized profile source; .igapp; manifest profile id matches
PSS-3: PASS - malformed JSON preflight refusal; stderr-only; no .igapp; no report
PSS-4: PASS - wrong-kind semantic refusal; compiler_result JSON; report; qualified diagnostic
PSS-5: PASS - no finalization/discovery/defaulting
PSS-6: PASS - refusal-kind labels match behavior
PSS-7: PASS - all non-claims true
PSS-8: PASS - no repo artifact leak beyond authorized script and summary
```

Accepted case behavior:

- PSS-2 success writes `.igapp` and records expected
  `manifest.compiler_profile_id`:
  `compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7`.
- PSS-3 malformed JSON preflight refusal exits non-zero, writes stderr only,
  writes no `.igapp`, and writes no compilation report.
- PSS-4 semantic wrong-kind refusal exits non-zero, writes compiler result JSON,
  writes a compilation report, writes no `.igapp`, and includes qualified
  `compiler_profile_source.wrong_kind`.

---

## Pressure Verdict

S3-R177-C2-X verdict:

```text
proceed - no blockers; 14/14 checks PASS
```

Accepted pressure conclusions:

- Marker fields match R176 accepted evidence: run id, package, version, SHA256,
  scope, and accepting card.
- Marker wording is bounded and verbatim from R176 accepted scope.
- PSS-0..PSS-8 are accurately recorded.
- Success, preflight refusal, and semantic refusal behaviors are accurately
  recorded.
- NB-1 temp cleanup remains a non-blocking hygiene note.
- Public release/demo claims remain closed.
- Release execution remains closed.
- RubyGems publish remains closed.
- Version/tag/push/publish/sign/deploy remain closed.
- Profile finalization/discovery/defaulting remains closed.
- Public API/CLI widening remains closed beyond
  `--compiler-profile-source PATH.json`.
- Branch/conditional `if_expr` remains excluded.
- Spark remains absent.
- R176/R177 status/index updates do not overclaim.

---

## NB-1 Disposition

NB-1 from R176 remains:

```text
partial_temp_out_cleanup_non_blocking
```

It does not require immediate follow-up.

Reason:

- The remaining temp `out/` directory is under `/private/tmp`.
- No generated `.igapp`, `.gem`, compilation report, fixture copy, gem home, or
  bindir was retained in the repo.
- Future smoke scripts should fully remove temp `out/` after durable summary
  capture or explicitly record partial cleanup.

This note should be carried into future smoke-hygiene design, but it does not
block the marker or the next planning route.

---

## Closed Surfaces

Remain closed:

```text
public release/demo claims
public release/docs readiness claims
release execution
RubyGems publish
version edits
gemspec/package metadata edits
git tag creation
git push
publishing
signing
deployment
profile finalization/discovery/defaulting
named/generated profile lookup
inline JSON profile input
env/config/sidecar profile lookup
public API/CLI widening beyond --compiler-profile-source PATH.json
loader/report or CompatibilityReport claim
runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache/production behavior
branch/conditional if_expr support
Spark integration or production pressure
Ruby Framework compatibility claim
runtime, production, deployment, signing, or demo work
```

---

## Next Route Decision

Next route:

```text
public release/docs non-claims planning
```

Rationale:

- The repo-local RC marker, local package/install smoke, and profile-source
  installed smoke are accepted.
- The project now needs controlled public-facing wording before any release
  execution discussion can be meaningful.
- Public communication must state the bounded release scope, exclusions, and
  non-claims without implying production readiness or broad language coverage.
- Release execution remains closed until a separate authorization review.

Do not open release execution immediately from this card.

---

## Recommended Next Dispatch

```text
R178 = C1-P1 -> C2-P1 -> C3-X -> C4-A -> C5-S
```

Suggested cards:

```text
S3-R178-C1-P1
Track: compiler-release-public-nonclaims-docs-scope-v0
Agent: [Release Target Analyst or Research Agent]
Goal: Draft the public release/docs non-claims boundary for the accepted
repo-local compiler RC and installed-package smoke evidence.
```

```text
S3-R178-C2-P1
Track: compiler-release-public-readme-and-demo-claim-risk-survey-v0
Agent: [Evidence Hygiene Agent or External Pressure Reviewer]
Goal: Survey current README/docs/demo wording for phrases that could overclaim
release readiness, production readiness, all-grammar support, RubyGems
availability, Spark integration, or branch/conditional support.
```

```text
S3-R178-C3-X
Track: compiler-release-public-nonclaims-pressure-v0
Agent: [External Pressure Reviewer]
Goal: Pressure-review C1/C2 for public-claim safety and exact exclusions.
```

```text
S3-R178-C4-A
Track: compiler-release-public-nonclaims-planning-decision-v0
Agent: [Portfolio Architect Supervisor]
Goal: Decide whether public release/docs non-claims planning is accepted and
whether a bounded docs polish or release-execution authorization review may
open later.
```

```text
S3-R178-C5-S
Track: stage3-round178-status-curation-v0
Agent: [Status Curator]
Goal: Curate R178 status and preserve all non-authorizations.
```

---

## Compact Summary

```text
S3-R177-C3-A accepts the profile-source installed readiness marker.
The marker is bounded to local installed-package profile-source smoke evidence
from run S3R176C1I_20260525T101425Z.
Pressure review passes 14/14 with no blockers.
NB-1 temp cleanup remains non-blocking hygiene.
Release execution, public claims, RubyGems publish, version/tag/push/sign/deploy,
profile finalization/discovery/defaulting, if_expr, Spark, runtime, and
production remain closed.
Next recommended route: public release/docs non-claims planning.
```
