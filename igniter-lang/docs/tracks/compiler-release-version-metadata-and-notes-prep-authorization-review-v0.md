# Compiler Release Version Metadata And Notes Prep Authorization Review v0

Card: S3-R181-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-version-metadata-and-notes-prep-authorization-review-v0
Route: UPDATE
Status: done / authorized bounded prep implementation
Date: 2026-05-26

Depends on:
- S3-R180-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-execution-authorization-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-package-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-evidence-and-approval-boundary-v0.md`
- `igniter-lang/docs/discussions/compiler-release-execution-authorization-boundary-pressure-v0.md`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`

---

## Decision

Decision:

```text
authorize bounded public-prerelease version/package metadata/release notes prep
authorize version.rb edit
authorize limited gemspec metadata wording edit
authorize RELEASE_NOTES.md creation
authorize limited README packaged wording edit
authorize prep track doc
do not authorize release execution
do not authorize RubyGems publish
do not authorize git tag creation
do not authorize git push
do not authorize signing/deployment
do not authorize public release/demo claims
keep branch/conditional if_expr excluded
keep profile finalization/discovery/defaulting closed
keep Spark out of scope
```

S3-R181-C2-I may perform the bounded prep implementation defined below.

This authorization exists to prepare a public prerelease package stance. It does
not authorize publishing that package, tagging it, pushing it, signing it,
deploying it, or announcing it as release/demo/production-ready.

---

## Version Candidate Policy

`0.1.0.pre.stage2` remains internal evidence only.

Authorized public prerelease candidate:

```text
0.1.0.alpha.1
```

Rationale:

- It is clearly a first public prerelease candidate.
- It avoids exporting internal stage vocabulary.
- It is less completion-implying than `rc.1`.
- It keeps the `0.1.0` family already used by the local evidence chain.

Authorized tag candidate, for documentation only:

```text
igniter-lang-v0.1.0.alpha.1
```

The tag candidate may be recorded in release notes or the prep track as a
future candidate only. No tag may be created in this round.

---

## Authorized Write Scope

Only these files may be edited or created:

```text
igniter-lang/lib/igniter_lang/version.rb
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/RELEASE_NOTES.md
igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-v0.md
```

No other files are authorized.

---

## Required Version Edit

If C2-I proceeds, update:

```ruby
IgniterLang::VERSION = "0.1.0.alpha.1"
```

The prep track must explicitly record that this invalidates the prior smoke
artifact hash:

```text
previous_smoke_version: 0.1.0.pre.stage2
previous_smoke_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
new_version: 0.1.0.alpha.1
fresh_smoke_required: yes
```

---

## Gemspec Metadata Boundary

Gemspec edit is authorized only for package wording safety.

Allowed:

- keep or lightly tighten summary;
- keep or lightly tighten description;
- preserve homepage/source metadata;
- preserve `rubygems_mfa_required`;
- preserve executable `igc`;
- preserve packaged files unless release notes are intentionally added to
  `spec.files`.

Authorized metadata stance:

```text
Igniter-Lang is an alpha compiler package for the Igniter contract-native
language research workspace.
```

Required non-claim meaning:

```text
alpha
bounded compiler/CLI package
not production-ready
not stable
not all grammar support
branch/conditional if_expr excluded
profile finalization/discovery/defaulting closed
```

Do not add:

- production-ready wording;
- stable release wording;
- public demo wording;
- all grammar wording;
- Spark wording;
- Ruby Framework compatibility wording.

---

## Release Notes / Changelog Stance

Authorize creation of:

```text
igniter-lang/RELEASE_NOTES.md
```

Required release notes scope:

```text
version: 0.1.0.alpha.1
status: alpha / prerelease candidate
package: igniter_lang
executable: igc
accepted local evidence:
  - repo-local compiler RC evidence
  - local package install smoke for previous stage marker
  - profile-source install smoke for previous stage marker
required before publish:
  - fresh package/install smoke for 0.1.0.alpha.1
  - fresh profile-source installed smoke for 0.1.0.alpha.1
```

Required exclusions:

```text
not production-ready
not stable
not public demo-ready
does not claim all grammar support
branch/conditional if_expr excluded
profile finalization/discovery/defaulting closed
Spark out of scope
Ruby Framework compatibility not claimed
release execution/publish/tag/push/sign/deploy still closed until later authorization
```

Do not write post-publish availability language.
Do not write "available on RubyGems" in this round.

---

## README Boundary

README edit is authorized only if needed to replace internal stage-marker
wording with the selected public prerelease candidate and to preserve non-claims.

Allowed README changes:

- add or adjust a compact package status line for `0.1.0.alpha.1`;
- link to `RELEASE_NOTES.md` if created;
- keep local evidence phrasing bounded;
- state that publish/release execution remains closed.

Do not turn README into public announcement copy.
Do not add "install from RubyGems" wording.
Do not claim public availability.

---

## Required Forbidden Phrase Scan

C2-I must scan all changed public/package files for these phrase families:

```text
production-ready
production ready
stable release
public release ready
release ready
demo ready
available on RubyGems
RubyGems available
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

- no active claim hit;
- negation/exclusion wording is allowed only if the surrounding sentence clearly
  says the surface is excluded or closed.

---

## Required Post-Prep Smoke Matrix

Because version changes from `0.1.0.pre.stage2` to `0.1.0.alpha.1`, C2-I must
record that the prior smoke artifact hash is no longer sufficient for publish
authorization.

Required next smoke route after prep acceptance:

```text
post-prep package/install smoke for igniter_lang 0.1.0.alpha.1
post-prep profile-source installed smoke for igniter_lang 0.1.0.alpha.1
```

Minimum required checks:

- gemspec syntax;
- gem build;
- isolated install;
- installed `igc` present;
- require `igniter_lang` without repo-relative `-I`;
- positive corpus compile;
- negative corpus refusal;
- valid finalized profile-source success;
- malformed JSON profile-source preflight refusal;
- semantic wrong-kind profile-source refusal;
- no repo path leak;
- artifact SHA256 captured.

No publish authorization may open until post-prep smoke is accepted.

---

## Closed Surfaces

Remain closed:

```text
release execution
RubyGems publish
git tag creation
git push
version/tag/push/publish/sign/deploy authority beyond this local version edit
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

## Exact C2-I Boundary

```text
Card: S3-R181-C2-I
Agent: [Package Agent / Implementation Agent]
Role: package-agent
Track: compiler-release-version-metadata-and-notes-prep-v0

Route: UPDATE
Depends on:
- S3-R181-C1-A

Goal:
Perform the bounded public-prerelease version/package metadata/release notes
prep authorized by S3-R181-C1-A.

Allowed writes:
- igniter-lang/lib/igniter_lang/version.rb
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/RELEASE_NOTES.md
- igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-v0.md

Required implementation:
- set `IgniterLang::VERSION` to `0.1.0.alpha.1`;
- keep gemspec metadata alpha/bounded/non-claiming;
- create `RELEASE_NOTES.md` with alpha scope, accepted local evidence, required
  fresh smoke, and explicit exclusions;
- adjust README only within the authorized boundary if needed;
- record tag candidate `igniter-lang-v0.1.0.alpha.1` as candidate only;
- record fresh package/profile-source smoke requirement;
- run/report forbidden phrase scan over changed public/package files.

Do not:
- publish gems;
- create tags;
- push;
- sign/deploy;
- run `gem push`;
- claim RubyGems availability;
- claim public release/demo readiness;
- change compiler/runtime behavior.

Deliver:
- Track doc in `igniter-lang/docs/tracks/`
- Exact changed files
- Version/tag candidate selected
- Package metadata/release notes summary
- Forbidden phrase scan result
- Non-claims preservation checklist
- Required post-prep smoke matrix
- Any remaining blockers
```

---

## Compact Summary

```text
S3-R181-C1-A: authorize bounded prep implementation.

0.1.0.pre.stage2 remains internal evidence only.
Authorized public prerelease candidate: 0.1.0.alpha.1.
Authorized tag candidate: igniter-lang-v0.1.0.alpha.1, candidate only.

Allowed writes:
- version.rb
- igniter_lang.gemspec
- README.md
- RELEASE_NOTES.md
- prep track doc

No release execution.
No RubyGems publish.
No tag/push/sign/deploy.
No public release/demo claims.

After prep, fresh package/install smoke and profile-source installed smoke are
required before publish authorization can be reconsidered.
```
