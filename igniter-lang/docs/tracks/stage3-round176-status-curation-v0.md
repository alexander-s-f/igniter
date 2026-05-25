# Stage 3 Round 176 Status Curation v0

Card: S3-R176-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round176-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R176-C3-A

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-v0.md`
- `igniter-lang/docs/discussions/compiler-release-profile-source-install-smoke-pressure-v0.md`
- `igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json`
- `igniter-lang/docs/cards/S3/S3-R176.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/cards/S3/S3.md`

---

## C3-A Decision

S3-R176-C3-A accepts the bounded installed-package profile-source install smoke
closure:

```text
decision: accept_smoke_closure
scope: bounded_installed_package_profile_source_smoke
run_id: S3R176C1I_20260525T101425Z
status: PASS
pressure: proceed_19_of_19_no_blockers
next_route: profile_source_installed_readiness_marker
```

The accepted evidence proves only this bounded package-readiness point:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI preserves the
accepted --compiler-profile-source PATH.json transport for one valid finalized
profile-source case, one malformed JSON preflight refusal, and one semantic
wrong-kind refusal.
```

---

## Accepted Smoke State

```text
card: S3-R176-C1-I
track: compiler-release-profile-source-install-smoke-v0
summary:
  igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
package: igniter_lang
version: 0.1.0.pre.stage2
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
installed_command: igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
refusal_kind_hygiene: pass
failed_checks: 0
hold_reasons: 0
```

Accepted PSS status:

```text
PSS-0 PASS - isolated build/install/require; no repo path leak
PSS-1 PASS - installed $BIN_DIR/igc and explicit --compiler-profile-source PATH.json
PSS-2 PASS - valid finalized profile source; .igapp; manifest profile id matches
PSS-3 PASS - malformed JSON preflight refusal; stderr-only; no .igapp; no report
PSS-4 PASS - wrong-kind semantic refusal; compiler_result JSON; report; qualified diagnostic
PSS-5 PASS - no finalization/discovery/defaulting
PSS-6 PASS - refusal-kind labels match behavior
PSS-7 PASS - all non-claims true
PSS-8 PASS - no repo artifact leak beyond authorized script and summary
```

Accepted non-blocking note:

```text
NB-1: partial temp out cleanup is non-blocking hygiene.
```

The temp `out/` directory remained under `/private/tmp`, but no generated
`.igapp`, `.gem`, compilation report, fixture copy, gem home, or bindir was
retained in the repo. Future smoke scripts should either fully remove temp
`out/` after writing the durable summary or record partial cleanup precisely.

---

## Preserved Non-Authorizations

Remain closed:

```text
public release/demo claims
release execution
RubyGems publish
version/tag/push/publish/sign/deploy
public availability claim
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

R176 does not authorize a release, RubyGems publish, public claims, new
implementation, or production behavior.

---

## Held By Write Scope

`igniter-lang/docs/cards/S3/S3-R176.md` still says `Status: planned`. This
card was read as required evidence, but it was not in the allowed write list for
S3-R176-C4-S, so the status-curation slice leaves it unchanged and records the
closed round in the standard indexes instead.

---

## Round Receipt

```text
round: S3-R176
status: closed_by_status_curation
closed_by: S3-R176-C4-S
date: 2026-05-25
completed_cards:
  S3-R176-C1-I: compiler-release-profile-source-install-smoke-v0
  S3-R176-C2-X: compiler-release-profile-source-install-smoke-pressure-v0
  S3-R176-C3-A: compiler-release-profile-source-install-smoke-acceptance-decision-v0
  S3-R176-C4-S: stage3-round176-status-curation-v0
accepted_state:
  profile_source_install_smoke: PASS
  run_id: S3R176C1I_20260525T101425Z
  readiness_marker_route: profile_source_installed_readiness_marker
next_route:
  compiler-release-profile-source-installed-readiness-marker-v0
non_authorizations_preserved:
  public_release_demo_claims
  release_execution
  RubyGems_publish
  version_tag_push_publish_sign_deploy
  runtime_production
  Spark
```
