# Compiler Release Release Notes Bundling Follow-Up Acceptance Decision v0

Card: S3-R182-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-release-notes-bundling-follow-up-acceptance-decision-v0
Route: UPDATE
Status: done / accepted
Date: 2026-05-26

Depends on:
- S3-R182-C2-I
- S3-R182-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-v0.md`
- `igniter-lang/docs/discussions/compiler-release-release-notes-bundling-follow-up-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-authorization-review-v0.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`

---

## Decision

Decision:

```text
accept release-notes bundling follow-up
accept RELEASE_NOTES.md bundling in gemspec packaged files
accept README version qualifier
confirm public prerelease candidate 0.1.0.alpha.1 remains accepted
authorize next route: combined post-prep package/install + profile-source smoke authorization review
do not authorize smoke execution in this card
keep release execution closed
keep RubyGems publish closed
keep public release/demo claims closed
keep version/tag/push/publish/sign/deploy closed
keep branch/conditional if_expr excluded
keep profile finalization/discovery/defaulting closed
keep Spark out of scope
```

The R181 conditional acceptance is now fully resolved for the packaging note
that blocked post-prep smoke authorization.

---

## Acceptance Basis

S3-R182-C2-I is accepted:

```text
files_changed:                  igniter_lang.gemspec, README.md, follow-up track doc
gemspec_packaged_files_updated: yes
readme_version_qualifier_added: yes
release_notes_edited:           no
version_changed:                no
forbidden_phrase_scan:          CLEAN
non_claims_preserved:           yes
tag_created:                    no
push_performed:                 no
gem_published:                  no
post_prep_smoke_run:            no
```

S3-R182-C3-X is accepted:

```text
verdict:            proceed
checks:             14/14 PASS
blockers:           none
non-blocking notes: none
```

Key pressure confirmations:

- write scope matched S3-R182-C1-A exactly;
- `RELEASE_NOTES.md` is included in `spec.files`;
- README now labels prior accepted local evidence as `0.1.0.pre.stage2` and
  requires fresh smoke for `0.1.0.alpha.1`;
- forbidden phrase scan is clean: one hit is unchanged negation text;
- no release execution, RubyGems publish, tag, push, sign, deploy, or public
  release/demo claim occurred.

---

## Required Questions

### Is `RELEASE_NOTES.md` bundling accepted?

Yes.

Accepted gemspec packaged file shape:

```ruby
Dir["lib/**/*.rb", "bin/igc", "README.md", "RELEASE_NOTES.md"].select { |path| File.file?(path) }
```

This resolves the R181 package-local README -> RELEASE_NOTES missing-file risk.

### Does public prerelease candidate `0.1.0.alpha.1` remain accepted?

Yes.

`0.1.0.alpha.1` remains the accepted public prerelease candidate. It is not
published, not tagged, and not release-executed.

### May post-prep smoke open next?

Yes, but only as an authorization review.

The next route may decide whether to authorize a combined post-prep smoke:

```text
post-prep package/install smoke
post-prep profile-source installed smoke
target: igniter_lang 0.1.0.alpha.1
```

Smoke execution itself is not authorized by this card.

### Does release execution remain closed?

Yes.

### Does RubyGems publish remain closed?

Yes.

### Do public release/demo claims remain closed?

Yes.

### Does branch/conditional `if_expr` remain excluded?

Yes.

### Does profile finalization/discovery/defaulting remain closed?

Yes.

### Does Spark remain out of scope?

Yes.

---

## Next Route

Open:

```text
compiler-release-combined-post-prep-smoke-authorization-review-v0
```

Purpose:

- decide whether to authorize one combined smoke execution card after release
  notes bundling closure;
- cover both package/install and profile-source installed behavior for
  `igniter_lang 0.1.0.alpha.1`;
- verify the final package artifact includes both `README.md` and
  `RELEASE_NOTES.md`;
- capture fresh artifact SHA256 for the `0.1.0.alpha.1` gem;
- preserve all non-claims and closed surfaces.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R183-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-combined-post-prep-smoke-authorization-review-v0

Route: UPDATE

Goal:
Decide whether a bounded combined post-prep package/install + profile-source
installed smoke execution may begin for `igniter_lang 0.1.0.alpha.1`.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-v0.md
  - igniter-lang/docs/discussions/compiler-release-release-notes-bundling-follow-up-pressure-v0.md
  - igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md
  - igniter-lang/igniter_lang.gemspec
  - igniter-lang/README.md
  - igniter-lang/RELEASE_NOTES.md
- Decide:
  - authorize combined post-prep smoke execution;
  - authorize package-only smoke first;
  - authorize profile-source smoke separately;
  - hold;
  - redirect.
- If authorizing, define exact:
  - write/output scope;
  - temp artifact policy;
  - gem build command matrix;
  - isolated install command matrix;
  - installed `igc` command matrix;
  - package file inclusion checks for README.md and RELEASE_NOTES.md;
  - positive compile corpus;
  - profile-source success corpus;
  - profile-source preflight refusal corpus;
  - profile-source semantic refusal corpus;
  - artifact SHA256 capture;
  - no repo path leak checks;
  - PASS/HOLD/FAIL criteria;
  - result packet shape;
  - non-claims;
  - closed surfaces.
- Explicitly answer:
  - whether smoke execution may open next;
  - whether the generated outputs may be called post-prep smoke evidence only
    after the authorized run completes;
  - whether release execution remains closed;
  - whether RubyGems publish remains closed;
  - whether public release/demo claims remain closed;
  - whether version/tag/push/publish/sign/deploy remain closed;
  - whether branch/conditional `if_expr` remains excluded;
  - whether profile finalization/discovery/defaulting remains closed;
  - whether Spark remains out of scope.

Do not:
- run smoke in this card;
- execute release commands;
- publish gems;
- create tags/push/sign/deploy;
- authorize public release/demo claims.

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/` or
  `igniter-lang/docs/gates/`
- Compact decision summary
- Exact smoke execution card boundary or hold reasons
```

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

## Compact Summary

```text
S3-R182-C4-A: accepted.

Accepted:
- RELEASE_NOTES.md bundled in gemspec spec.files
- README evidence version qualifier
- R181 NB-1 resolved
- R181 NB-2 resolved
- 0.1.0.alpha.1 remains accepted public prerelease candidate

Pressure:
- 14/14 PASS
- no blockers
- no non-blocking notes

Next:
- open combined post-prep package/install + profile-source smoke authorization
  review for igniter_lang 0.1.0.alpha.1

Still closed:
- smoke execution until next authorization
- release execution
- RubyGems publish
- tag/push/sign/deploy
- public release/demo claims
- branch/conditional if_expr
- profile finalization/discovery/defaulting
- Spark
```

