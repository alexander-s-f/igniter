# Compiler Release Target Versioning And Package Boundary v0

Card: S3-R180-C1-P1
Agent: [Package Agent]
Role: package-agent
Track: compiler-release-target-versioning-and-package-boundary-v0
Route: UPDATE
Status: done
Date: 2026-05-26

Depends on:
- S3-R179-C4-A

---

## Purpose

Prepare a release target, versioning, and package-boundary packet for the
compiler release-execution authorization review.

This card does not execute a release, build a release artifact, publish a gem,
create or push tags, edit versions, edit package metadata, or make public
release/demo claims.

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-polish-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/official-first-rc-evidence-acceptance-and-next-release-vector-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R180.md`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/bin/release-gate`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/package_install_smoke_v0.rb`
- `igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/profile_source_install_smoke_v0.rb`
- `rg "VERSION|Gem::Specification|gemspec|rake release|rake build" igniter-lang`
- `git tag --list '*0.1.0*'`
- `git tag --list '*igniter*lang*'`
- `git remote -v`
- `git ls-remote --tags origin '*0.1.0*'`
- `git ls-remote --tags origin '*igniter*lang*'`

---

## Accepted Evidence State

Accepted evidence now supports bounded local installed-package readiness only.

| Evidence | Accepted status |
| --- | --- |
| Official first-RC evidence | PASS for `repo_local_compiler_rc` |
| Package/install smoke | PASS for `igniter_lang 0.1.0.pre.stage2` |
| Profile-source installed smoke | PASS for bounded `--compiler-profile-source PATH.json` transport |
| Public non-claims docs polish | accepted |
| Release execution | closed |
| RubyGems publish | closed |
| Version/tag/push/sign/deploy | closed |
| Public release/demo claims | closed |
| Branch/conditional `if_expr` | excluded |
| Profile finalization/discovery/defaulting | closed |
| Spark | out of scope |

The evidence chain is strong enough to discuss a release-execution boundary.
It is not, by itself, an authorization to publish.

---

## Current Package Facts

| Surface | Current fact |
| --- | --- |
| Gem name | `igniter_lang` |
| Version source | `igniter-lang/lib/igniter_lang/version.rb` |
| Current version | `0.1.0.pre.stage2` |
| Gemspec version source | `IgniterLang::VERSION` |
| Required Ruby | `>= 3.1.0` |
| Packaged files | `lib/**/*.rb`, `bin/igc`, `README.md` |
| Installed executable | `igc` |
| Package require path | `lib` |
| MFA metadata | `rubygems_mfa_required: true` |
| Release gate | `igniter-lang/bin/release-gate` |
| `rake build` / `rake release` | no package-local Rake route discovered |
| Publish automation | no `gem push` automation; `release-gate` stops before publish |

Current gemspec metadata:

```text
summary: Contract-native language compiler for Igniter
description: Igniter-Lang provides the packageable compiler facade and CLI for
  the Igniter contract-native language research workspace.
homepage: https://github.com/alexander-s-f/igniter
source_code_uri: https://github.com/alexander-s-f/igniter/tree/main/igniter-lang
```

---

## Version And Tag Check

Local tag checks:

```text
git tag --list '*0.1.0*'       -> no matching local tags
git tag --list '*igniter*lang*' -> no matching local tags
```

Remote tag checks against `origin`:

```text
git ls-remote --tags origin '*0.1.0*'       -> no matching remote tags
git ls-remote --tags origin '*igniter*lang*' -> no matching remote tags
```

This checks git tags only. It does not prove that `igniter_lang` version
`0.1.0.pre.stage2` is absent from RubyGems. A future publish execution boundary
must include a read-only RubyGems version-collision check before `gem push`.

---

## Exact Release Target Recommendation

Recommended target for R180 C4-A:

```text
authorize release prep first, not release execution
```

Recommended next concrete target:

```text
compiler_release_version_metadata_and_notes_prep
```

Reason:

- accepted evidence is local and bounded;
- current version `0.1.0.pre.stage2` is the smoke-proven version, but it reads
  as an internal stage marker rather than an intentional public prerelease;
- no release notes or package metadata prep decision has been accepted;
- RubyGems publish would be public and effectively irreversible for that
  version;
- changing the version before publish would invalidate the accepted smoke
  artifact hash and require fresh package/profile-source smoke.

If C4-A later decides to authorize an execution card after prep, the exact
execution target should be:

```text
public_rubygems_prerelease_candidate_for_igniter_lang
```

and not a stable release, production release, public demo, all-grammar release,
Spark release, or branch/conditional `if_expr` release.

Not recommended:

```text
immediate gem push of igniter_lang 0.1.0.pre.stage2
```

This should be held until version/tag/package metadata/release notes are
explicitly accepted.

---

## Version Boundary

Current version source:

```ruby
module IgniterLang
  VERSION = "0.1.0.pre.stage2"
end
```

Boundary:

- the currently accepted smoke evidence applies to `0.1.0.pre.stage2`;
- any version edit creates a new package target and requires fresh package
  build/install smoke;
- a public publish should not silently reuse the internal `pre.stage2` marker
  without an explicit C4-A version decision;
- tag name must be selected before any execution card.

Candidate tag family, review-only:

```text
igniter-lang-v<VERSION>
```

For the current version this would be:

```text
igniter-lang-v0.1.0.pre.stage2
```

This tag does not currently exist locally or remotely by the checks above, but
the tag should not be created until a separate execution card authorizes it.

---

## Package Artifact / Build Route

Primary package artifact route:

```text
gem build igniter-lang/igniter_lang.gemspec --output /private/tmp/<release-root>/igniter_lang-<VERSION>.gem
```

Package-local release gate route:

```text
igniter-lang/bin/release-gate --out /private/tmp/<release-root>
```

Important behavior:

- `release-gate` runs package-local checks and builds a local gem artifact and
  checksum;
- `release-gate` writes `igniter-lang/experiments/release_gate/release_gate.json`;
- `release-gate` records publish status as `not_attempted`;
- `release-gate` does not push to RubyGems.

Publish remains a separate command and must require explicit user approval,
RubyGems credentials, and MFA/human owner action.

---

## Package Metadata Surfaces

Surfaces that package execution reads:

- `igniter-lang/igniter_lang.gemspec`;
- `igniter-lang/lib/igniter_lang/version.rb`;
- `igniter-lang/README.md`;
- `igniter-lang/bin/igc`;
- `igniter-lang/lib/**/*.rb`.

Surfaces a prep card may need to touch before public publish:

- `igniter-lang/lib/igniter_lang/version.rb` if selecting a public prerelease
  version different from `0.1.0.pre.stage2`;
- `igniter-lang/igniter_lang.gemspec` if summary/description/homepage/source
  metadata need release wording adjustment;
- `igniter-lang/README.md` because it is packaged into the gem;
- optional `igniter-lang/RELEASE_NOTES.md` or `igniter-lang/CHANGELOG.md` if
  Portfolio wants public release notes before publish;
- `igniter-lang/docs/README.md` and `igniter-lang/docs/ruby-api.md` only if a
  later docs card authorizes post-publish wording changes.

Surfaces a future execution card may create or update:

- `/private/tmp/<release-root>/igniter_lang-<VERSION>.gem`;
- `/private/tmp/<release-root>/igniter_lang-<VERSION>.gem.sha256`;
- `igniter-lang/experiments/release_gate/release_gate.json` if using
  `release-gate`;
- git tag only if explicitly authorized;
- RubyGems remote state only if `gem push` is explicitly authorized.

---

## Candidate Command Matrix - Review Only

These commands are candidates for review. They are not authorized or run by this
card.

| Phase | Candidate command | Notes |
| --- | --- | --- |
| Version read | `ruby -I igniter-lang/lib -e 'require "igniter_lang/version"; puts IgniterLang::VERSION'` | Read-only, but repo-local load path |
| Gemspec syntax | `ruby -c igniter-lang/igniter_lang.gemspec` | Package syntax preflight |
| Local tag check | `git tag --list '*0.1.0*'` | Read-only local check |
| Remote tag check | `git ls-remote --tags origin 'igniter-lang-v<VERSION>'` | Read-only network check |
| RubyGems collision check | `gem list -r -e igniter_lang` | Read-only network check, required before publish |
| Package smoke | `ruby igniter-lang/experiments/compiler_release_package_install_smoke_v0/package_install_smoke_v0.rb` | Re-run if version/package metadata changes |
| Profile-source smoke | `ruby igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/profile_source_install_smoke_v0.rb` | Re-run if version/package metadata changes |
| Release gate | `igniter-lang/bin/release-gate --out /private/tmp/<release-root>` | Builds artifact/checksum, no publish |
| Manual build | `gem build igniter-lang/igniter_lang.gemspec --output /private/tmp/<release-root>/igniter_lang-<VERSION>.gem` | Direct build alternative |
| Checksum | `shasum -a 256 /private/tmp/<release-root>/igniter_lang-<VERSION>.gem` | Artifact traceability |
| Tag create | `git tag -a igniter-lang-v<VERSION> -m "igniter-lang <VERSION>"` | Requires explicit authorization |
| Tag push | `git push origin refs/tags/igniter-lang-v<VERSION>` | Requires explicit authorization |
| Publish | `gem push /private/tmp/<release-root>/igniter_lang-<VERSION>.gem` | Requires explicit authorization, credentials, MFA |
| Post-publish install check | `gem install igniter_lang -v <VERSION> --no-document` in isolated temp gem home | Only after publish succeeds |

No candidate above is authorized by this card.

---

## Preconditions Before Any Execution Card

Minimum preconditions before a release execution card may open:

1. C4-A explicitly chooses the release target.
2. C4-A explicitly chooses version/tag stance.
3. A prep card decides whether to change `0.1.0.pre.stage2` before publish.
4. A prep card accepts release notes and package metadata wording, or records a
   deliberate no-change decision.
5. Read-only RubyGems version-collision check is run and recorded.
6. Read-only remote tag collision check is run for the exact tag.
7. If version/package metadata changes, package/install smoke is rerun and
   accepted for the new artifact.
8. If version/package metadata changes, profile-source installed smoke is rerun
   and accepted for the new artifact.
9. Exact command log capture paths are selected.
10. Explicit user approval is obtained for any tag, push, publish, signing, or
    deployment step.
11. RubyGems credentials and MFA/human owner boundary are confirmed.
12. Abort criteria are defined before `gem push`.

---

## Release Notes / Metadata Prep Need

Release notes/package metadata need a prep card before public execution.

Recommended prep target:

```text
compiler_release_version_metadata_and_notes_prep
```

Prep card should decide:

- whether `0.1.0.pre.stage2` is acceptable as the public prerelease version;
- if not, the exact new version string;
- exact git tag name;
- whether gemspec summary/description/homepage/source metadata need edits;
- whether `README.md` packaged in the gem needs post-publish wording changes;
- whether to add `RELEASE_NOTES.md` or `CHANGELOG.md`;
- whether accepted public non-claims docs remain sufficient after publish;
- whether fresh package/profile-source smoke is required after any edit.

---

## Risks / Blockers

| ID | Risk / blocker | Disposition |
| --- | --- | --- |
| RB-1 | Current version `0.1.0.pre.stage2` reads as internal stage evidence | Blocks immediate public publish unless C4-A explicitly accepts it |
| RB-2 | No accepted release notes/package metadata prep | Blocks immediate public publish |
| RB-3 | Changing version invalidates accepted package artifact hash | Requires fresh smoke evidence for new version |
| RB-4 | RubyGems version collision not checked in this card | Must be checked before publish |
| RB-5 | `release-gate` does not publish | Publish command must be separately authorized |
| RB-6 | `gem push` is irreversible for a version in practice | Requires explicit user approval and abort criteria |
| RB-7 | Public docs still preserve non-claims | Post-publish wording must avoid production/demo/all-grammar claims |
| RB-8 | Branch/conditional `if_expr` remains excluded | Must stay visible in release notes/non-claims |
| RB-9 | Profile finalization/discovery/defaulting remains closed | Must not be implied by profile-source transport wording |
| RB-10 | Spark remains out of scope | Must not be used as release authority |

---

## Recommendation For C4-A

Recommended decision:

```text
do not authorize release execution yet
authorize release version/package metadata/release notes prep next
```

If C4-A wants to name the future release target now, name it as:

```text
public_rubygems_prerelease_candidate_for_igniter_lang
```

with these constraints:

```text
stable_release: no
production_readiness_claim: no
public_demo_claim: no
all_grammar_claim: no
branch_conditional_if_expr: excluded
profile_finalization_discovery_defaulting: closed
spark: out_of_scope
version_tag_publish: held until prep and explicit execution authorization
```

---

## Compact Boundary Packet

```text
card: S3-R180-C1-P1
track: compiler-release-target-versioning-and-package-boundary-v0
status: done

release_target_recommendation:
  immediate_execution: hold
  next_target: compiler_release_version_metadata_and_notes_prep
  future_execution_target: public_rubygems_prerelease_candidate_for_igniter_lang

current_package:
  gem_name: igniter_lang
  version: 0.1.0.pre.stage2
  version_source: igniter-lang/lib/igniter_lang/version.rb
  gemspec: igniter-lang/igniter_lang.gemspec
  executable: igc
  build_route: gem build or igniter-lang/bin/release-gate
  publish_route: manual gem push only after explicit approval

tag_status:
  local_0_1_0_tags: none
  local_igniter_lang_tags: none
  remote_0_1_0_tags: none
  remote_igniter_lang_tags: none
  rubygems_version_collision: not checked; required before publish

metadata_boundary:
  prep_needed: yes
  likely_surfaces: version.rb, igniter_lang.gemspec, README.md,
    optional RELEASE_NOTES.md or CHANGELOG.md
  smoke_rerun_needed_if_changed: yes

candidate_commands:
  review_only: true
  build: gem build igniter-lang/igniter_lang.gemspec --output /private/tmp/<release-root>/igniter_lang-<VERSION>.gem
  release_gate: igniter-lang/bin/release-gate --out /private/tmp/<release-root>
  publish: gem push /private/tmp/<release-root>/igniter_lang-<VERSION>.gem

closed:
  release_execution: not authorized by this card
  public_demo_claim: closed
  production_claim: closed
  version_tag_push_publish_sign_deploy: closed until explicit execution auth
```

---

## Closed Surfaces

This card does not authorize:

- release execution;
- gem build as a release artifact;
- RubyGems publish;
- git tag creation;
- git push;
- signing or deployment;
- version edits;
- gemspec/package metadata edits;
- release notes edits;
- public release/demo claims;
- public API/CLI widening;
- profile finalization/discovery/defaulting;
- branch/conditional `if_expr`;
- compiler/parser/TypeChecker/SemanticIR/assembler/runtime behavior changes;
- Spark release authority;
- Ruby Framework release authority.
