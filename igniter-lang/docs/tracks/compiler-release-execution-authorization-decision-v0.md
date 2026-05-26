# Compiler Release Execution Authorization Decision v0

Card: S3-R180-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-execution-authorization-decision-v0
Route: UPDATE
Status: done / redirect to release prep
Date: 2026-05-26

Depends on:
- S3-R180-C1-P1
- S3-R180-C2-P1
- S3-R180-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-package-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-evidence-and-approval-boundary-v0.md`
- `igniter-lang/docs/discussions/compiler-release-execution-authorization-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-polish-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-installed-readiness-and-next-vector-decision-v0.md`

---

## Decision

Decision:

```text
accept R180 release-execution planning bundle
accept C3-X pressure verdict
do not authorize release execution yet
do not authorize immediate RubyGems publish of 0.1.0.pre.stage2
choose Path B: public prerelease version/metadata/notes prep first
authorize release version/package metadata/release notes prep next
require fresh package/install smoke if version or package metadata changes
require fresh profile-source installed smoke if version or package metadata changes
keep public release/demo claims closed
keep RubyGems publish closed
keep version/tag/push/publish/sign/deploy closed until separate execution authorization
keep profile finalization/discovery/defaulting closed
keep branch/conditional if_expr excluded
keep Spark out of scope
```

R180 proves that the release-execution boundary is now well understood, but it
also exposes one important public-packaging mismatch: the currently smoke-proven
version, `0.1.0.pre.stage2`, reads as an internal stage/evidence marker.

Therefore a release execution card must not open directly from R180. The next
route is a bounded prep card that chooses a public prerelease version/tag,
settles package metadata/release notes, and defines the fresh smoke evidence
needed after any version or metadata change.

---

## Accepted Planning Basis

C1-P1 is accepted as the target/versioning/package-boundary packet.

Accepted facts:

```text
package: igniter_lang
current_version: 0.1.0.pre.stage2
version_source: igniter-lang/lib/igniter_lang/version.rb
gemspec: igniter-lang/igniter_lang.gemspec
executable: igc
current_smoke_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
future_target_family: public_rubygems_prerelease_candidate_for_igniter_lang
```

C2-P1 is accepted as the evidence/approval/credential boundary.

Accepted evidence chain:

```text
official first-RC evidence: PASS
repo-local RC marker: accepted
package/install smoke: PASS
installed readiness marker: accepted
profile-source install smoke: PASS
profile-source installed readiness marker: accepted
public non-claims docs polish: accepted
```

C3-X is accepted:

```text
verdict: proceed with non-blocking notes
checks: 12/12 PASS
blockers: none
binding notes for this decision:
  NB-1: RubyGems version-collision check must be a hard abort gate
  NB-2: explicit version/tag stance required before any execution card opens
```

---

## Version / Tag Stance

Chosen path:

```text
Path B - do not publish 0.1.0.pre.stage2 as-is.
```

Disposition:

- `0.1.0.pre.stage2` remains accepted local evidence and installed-smoke
  version.
- It is not accepted as the public RubyGems prerelease version.
- A prep card must choose the exact public prerelease version and tag.
- Any version edit invalidates the accepted gem artifact SHA256 and requires
  fresh package/install smoke and profile-source installed smoke for the new
  artifact before publish authorization can be reconsidered.

Reason:

```text
0.1.0.pre.stage2 is accurate as an internal evidence/stage marker, but too
internal-looking for a first public package version. Publishing it directly
would export process vocabulary as product vocabulary.
```

Allowed version-prep candidates may include, but are not limited to:

```text
0.1.0.alpha.1
0.1.0.pre.1
0.1.0.rc.1
```

The prep card must verify RubyGems version syntax before selecting a final
candidate.

Candidate tag family:

```text
igniter-lang-v<VERSION>
```

No tag may be created until a later execution card explicitly authorizes it.

---

## Next Authorized Route

Authorize prep only:

```text
track: compiler-release-version-metadata-and-notes-prep-v0
mode: bounded docs/package/version prep design or implementation, as explicitly scoped
```

The next prep card may decide and, if explicitly included, edit:

- `igniter-lang/lib/igniter_lang/version.rb`;
- `igniter-lang/igniter_lang.gemspec`;
- `igniter-lang/README.md` only for packaged public-prerelease wording if
  claim-safe;
- optional `igniter-lang/RELEASE_NOTES.md` or `igniter-lang/CHANGELOG.md`;
- a prep track doc.

The prep card must define:

- final public prerelease version candidate;
- exact git tag name candidate;
- package metadata wording;
- release notes/changelog stance;
- post-prep package/install smoke requirement;
- post-prep profile-source installed smoke requirement;
- public non-claims after release;
- exact forbidden claims scan;
- whether a later publish-execution authorization review may open.

The prep card must not publish, tag, push, sign, deploy, or claim public
release/demo readiness.

---

## Execution Status

Release execution is not authorized by this card.

RubyGems publish is not authorized by this card.

Version/tag/push/publish/sign/deploy are not authorized by this card.

A future execution card may be considered only after:

1. public prerelease version is selected and accepted;
2. package metadata/release notes are accepted or explicitly waived;
3. any version/package metadata edits are landed;
4. fresh package/install smoke passes for the new artifact if version or
   metadata changed;
5. fresh profile-source installed smoke passes for the new artifact if version
   or metadata changed;
6. RubyGems version-collision check for the exact version is recorded;
7. exact tag collision check for the exact tag is recorded;
8. explicit user approval boundary is restated for the execution card.

---

## Hard Gates For Future Execution Card

These must be carried forward as hard gates:

```text
RubyGems version-collision gate:
  run read-only remote version check before gem build/publish;
  if igniter_lang <VERSION> exists remotely, HOLD immediately.

Tag collision gate:
  run local and remote exact tag checks;
  if tag exists locally or remotely, HOLD unless Portfolio explicitly accepts it.

Approval sequencing gate:
  user approval must be confirmed before each release-affecting mutating command,
  not collected retrospectively.

Credential/2FA gate:
  RubyGems credentials and OTP values must not be written into docs, logs,
  summaries, stdout excerpts, or track files.

Partial publish ambiguity gate:
  if gem push times out or returns ambiguous remote state, HOLD and verify remote
  state; do not auto-yank or retry blindly.

No auto-yank gate:
  gem yank or corrective release requires separate Architect/user decision.
```

---

## Closed Surfaces

Remain closed:

```text
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
production deployment
signing/deployment
```

Spark remains out of scope.

Ruby Framework remains independent and non-blocking.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R181-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-version-metadata-and-notes-prep-authorization-review-v0

Route: UPDATE

Goal:
Decide whether a bounded public-prerelease version/package metadata/release
notes prep card may begin before any release execution authorization can open.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-execution-authorization-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-target-versioning-and-package-boundary-v0.md
  - igniter-lang/docs/tracks/compiler-release-execution-evidence-and-approval-boundary-v0.md
  - igniter-lang/docs/discussions/compiler-release-execution-authorization-boundary-pressure-v0.md
  - igniter-lang/lib/igniter_lang/version.rb
  - igniter-lang/igniter_lang.gemspec
  - igniter-lang/README.md
- Decide:
  - authorize bounded prep implementation;
  - authorize design-only prep first;
  - hold;
  - redirect.
- If authorizing prep, define exact:
  - version candidate policy;
  - files allowed to change;
  - release notes/changelog stance;
  - package metadata wording boundary;
  - public non-claims block;
  - required forbidden-phrase scan;
  - required post-prep smoke matrix;
  - closed surfaces.
- Do not publish gems.
- Do not create tags/push/sign/deploy.
- Do not authorize public release/demo claims.

Deliver:
- Decision doc in `igniter-lang/docs/tracks/` or `igniter-lang/docs/gates/`
- Compact decision summary
- Exact prep implementation boundary or hold reasons
```

---

## Compact Summary

```text
S3-R180-C4-A: accepted planning bundle, redirected before execution.

Release execution: not authorized.
Immediate RubyGems publish: not authorized.
Version/tag/push/publish/sign/deploy: closed.

Chosen path: Path B.
Do not publish 0.1.0.pre.stage2 as-is.
Open version/package metadata/release notes prep next.

After version/package metadata prep:
- rerun package/install smoke if artifact changes;
- rerun profile-source installed smoke if artifact changes;
- require RubyGems version-collision hard gate;
- require exact tag collision gate;
- require explicit user approval before each mutating release command.

Public release/demo claims remain closed.
Branch/conditional if_expr remains excluded.
Profile finalization/discovery/defaulting remains closed.
Spark remains out of scope.
```
