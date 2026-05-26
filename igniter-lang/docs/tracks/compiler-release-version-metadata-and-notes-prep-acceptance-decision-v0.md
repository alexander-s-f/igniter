# Compiler Release Version Metadata And Notes Prep Acceptance Decision v0

Card: S3-R181-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0
Route: UPDATE
Status: done / conditional accept
Date: 2026-05-26

Depends on:
- S3-R181-C2-I
- S3-R181-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-v0.md`
- `igniter-lang/docs/discussions/compiler-release-version-metadata-and-notes-prep-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-authorization-decision-v0.md`

---

## Decision

Decision:

```text
conditionally accept version/package metadata/release notes prep
accept public prerelease version 0.1.0.alpha.1
accept tag candidate igniter-lang-v0.1.0.alpha.1 as candidate only
accept package metadata wording
accept release notes wording
require release notes packaging follow-up before post-prep smoke
do not open post-prep smoke until follow-up lands
keep release execution closed
keep RubyGems publish closed
keep public release/demo claims closed
keep version/tag/push/publish/sign/deploy closed
keep branch/conditional if_expr excluded
keep profile finalization/discovery/defaulting closed
keep Spark out of scope
```

The prep is materially correct and claim-safe. It is conditionally accepted
because C3-X surfaced one packaging gap: `README.md` is packaged into the gem
and now links to `RELEASE_NOTES.md`, but `RELEASE_NOTES.md` is not currently
included in `spec.files`.

This must be fixed before post-prep package smoke, otherwise the smoke would
validate a gem artifact whose packaged README points at a missing local file.

---

## Accepted Prep Basis

C2-I is accepted on substance:

```text
version_selected: 0.1.0.alpha.1
tag_candidate: igniter-lang-v0.1.0.alpha.1 (candidate only)
previous_smoke_version: 0.1.0.pre.stage2
previous_smoke_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
prior_sha256_valid_for_new: no
fresh_smoke_required: yes
forbidden_phrase_scan: CLEAN
non_claims_preserved: yes
```

C3-X is accepted:

```text
verdict: proceed with non-blocking notes
checks: 14/14 PASS
blockers: none
binding note for this decision:
  NB-1: decide whether RELEASE_NOTES.md is bundled or repo-only
informational note:
  NB-2: README PASS lines could later gain version qualifier
```

---

## Version Acceptance

The new public prerelease version is accepted:

```text
0.1.0.alpha.1
```

This replaces `0.1.0.pre.stage2` as the intended public prerelease candidate.
The previous version remains useful as local evidence history only.

Accepted tag candidate:

```text
igniter-lang-v0.1.0.alpha.1
```

This is accepted as a candidate only. No tag creation is authorized.

---

## Package Metadata / Release Notes Acceptance

Package metadata wording is accepted.

Release notes wording is accepted.

The alpha/non-claim posture is accepted:

- alpha prerelease;
- not stable;
- not production-ready;
- not public demo-ready;
- no all-grammar support claim;
- branch/conditional `if_expr` excluded;
- profile finalization/discovery/defaulting closed;
- Spark out of scope;
- release execution and RubyGems publish closed until later authorization.

---

## RELEASE_NOTES Packaging Decision

C4-A chooses:

```text
Option A - bundle RELEASE_NOTES.md in the gem.
```

Reason:

- `README.md` is included in the gem.
- `README.md` links to `RELEASE_NOTES.md`.
- A public gem artifact should not package a README with a local relative link
  to a missing file.
- `RELEASE_NOTES.md` carries the strongest non-claims record for this alpha
  package and should travel with the packaged artifact.

Required follow-up:

```text
add RELEASE_NOTES.md to igniter-lang/igniter_lang.gemspec spec.files
```

This is a packaging metadata fix, not a release execution step.

---

## Next Route

Do not open post-prep smoke yet.

Open a tiny packaging follow-up first:

```text
compiler-release-release-notes-bundling-follow-up-v0
```

Purpose:

- include `RELEASE_NOTES.md` in gemspec packaged files;
- optionally add a version qualifier to README local evidence PASS lines if
  the implementation can do so without widening wording;
- rerun forbidden phrase scan for changed package/docs files;
- preserve all closed surfaces.

After that follow-up is accepted, open:

```text
combined post-prep package/install + profile-source smoke authorization review
```

The smoke authorization should target:

```text
package: igniter_lang
version: 0.1.0.alpha.1
```

and cover both package/install and profile-source installed behavior for the new
artifact.

---

## Required Post-Follow-Up Smoke

Post-prep smoke remains required before any publish authorization can be
reconsidered:

```text
post-prep package/install smoke for igniter_lang 0.1.0.alpha.1
post-prep profile-source installed smoke for igniter_lang 0.1.0.alpha.1
```

Minimum smoke evidence must include:

- gemspec syntax;
- gem build;
- artifact SHA256;
- packaged files include `README.md` and `RELEASE_NOTES.md`;
- isolated install;
- installed `igc` present;
- require `igniter_lang` without repo-relative `-I`;
- positive corpus compile;
- negative corpus refusal;
- valid finalized profile-source success;
- malformed JSON profile-source preflight refusal;
- semantic wrong-kind profile-source refusal;
- no repo path leak.

---

## Closed Surfaces

Remain closed:

```text
release execution
RubyGems publish
git tag creation
git push
version/tag/push/publish/sign/deploy
public release/demo claims
production readiness claims
stable release claims
all grammar support claims
branch/conditional if_expr support
profile finalization/discovery/defaulting
named/generated profile lookup
inline JSON profile input
env/config/sidecar profile lookup
public API/CLI widening
loader/report or CompatibilityReport readiness
runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache behavior
Spark integration or Spark public evidence claims
Ruby Framework compatibility claims
compiler/runtime behavior changes
```

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R182-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-release-notes-bundling-follow-up-authorization-review-v0

Route: UPDATE

Goal:
Decide whether a tiny release-notes packaging follow-up may begin before
post-prep smoke opens.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md
  - igniter-lang/docs/discussions/compiler-release-version-metadata-and-notes-prep-pressure-v0.md
  - igniter-lang/igniter_lang.gemspec
  - igniter-lang/README.md
  - igniter-lang/RELEASE_NOTES.md
- Decide:
  - authorize tiny packaging follow-up;
  - hold;
  - redirect.
- If authorizing, define exact:
  - allowed files;
  - required gemspec packaged-file edit;
  - optional README version qualifier boundary;
  - forbidden phrase scan;
  - closed surfaces.
- Do not publish gems.
- Do not create tags/push/sign/deploy.
- Do not authorize public release/demo claims.

Deliver:
- Decision doc in `igniter-lang/docs/tracks/` or `igniter-lang/docs/gates/`
- Compact decision summary
- Exact implementation boundary or hold reasons
```

---

## Compact Summary

```text
S3-R181-C4-A: conditional accept.

Accepted:
- public prerelease version: 0.1.0.alpha.1
- tag candidate: igniter-lang-v0.1.0.alpha.1 (candidate only)
- gemspec metadata wording
- RELEASE_NOTES.md wording
- claim-safety / forbidden phrase scan

Condition:
- RELEASE_NOTES.md must be bundled in gemspec spec.files before smoke.

Next:
- tiny release-notes bundling follow-up.
- then combined package/install + profile-source smoke authorization review.

Still closed:
- release execution
- RubyGems publish
- tag/push/sign/deploy
- public release/demo claims
- branch/conditional if_expr
- profile finalization/discovery/defaulting
- Spark
```
