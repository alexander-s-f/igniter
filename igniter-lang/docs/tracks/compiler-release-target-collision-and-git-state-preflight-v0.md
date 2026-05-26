# Compiler Release Target Collision And Git State Preflight v0

Card: S3-R184-C1-P1
Agent: [Package Agent]
Role: package-agent
Track: compiler-release-target-collision-and-git-state-preflight-v0
Route: UPDATE
Status: done
Date: 2026-05-26

---

## Purpose

Produce a release target collision and git-state preflight packet for
`igniter_lang 0.1.0.alpha.1` before any release execution authorization.

This card does not build or publish gems, create tags, push, edit release
files, or run release commands.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round183-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-acceptance-decision-v0.md`
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`

Read-only checks run:

- `git status --short -- igniter-lang/igniter_lang.gemspec igniter-lang/lib/igniter_lang/version.rb igniter-lang/README.md igniter-lang/RELEASE_NOTES.md igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`
- `git tag --list 'igniter-lang-v0.1.0.alpha.1'`
- `git ls-remote --tags origin 'igniter-lang-v0.1.0.alpha.1'`
- `gem list -r -e igniter_lang`
- `gem list --remote --all --exact igniter_lang`
- `rg -n "not yet published|RubyGems availability|publish not authorized|Not yet" igniter-lang/README.md igniter-lang/RELEASE_NOTES.md`
- `rg -n '"gem_name"|"version"|"built_gem_sha256"|"readme"|"release_notes"|"status"|"failed_checks"|"hold_reasons"' igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`
- `rg -n 'README.md|RELEASE_NOTES.md|bin/igc|lib/igniter_lang/version.rb' igniter-lang/igniter_lang.gemspec igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`

---

## Target

| Field | Value |
| --- | --- |
| target package name | `igniter_lang` |
| target version | `0.1.0.alpha.1` |
| version source | `igniter-lang/lib/igniter_lang/version.rb` |
| expected tag name | `igniter-lang-v0.1.0.alpha.1` |
| installed executable | `igc` |
| accepted R183 run id | `S3R183C2I_20260526T143139Z` |
| accepted R183 status | `PASS` |
| accepted artifact SHA256 | `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6` |

Current version file:

```ruby
module IgniterLang
  VERSION = "0.1.0.alpha.1"
end
```

---

## Accepted Artifact Evidence

From the accepted R183 combined post-prep smoke summary:

```text
status: PASS
failed_checks: []
hold_reasons: []
package.gem_name: igniter_lang
package.version: 0.1.0.alpha.1
package.built_gem_sha256: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
artifact.packaged_files.readme: true
artifact.packaged_files.release_notes: true
```

Packaged file proof includes:

```text
README.md
RELEASE_NOTES.md
bin/igc
lib/igniter_lang/version.rb
```

The gemspec still includes both docs files:

```ruby
Dir["lib/**/*.rb", "bin/igc", "README.md", "RELEASE_NOTES.md"]
```

---

## Git State Preflight

Relevant release files checked:

```text
igniter-lang/igniter_lang.gemspec
igniter-lang/lib/igniter_lang/version.rb
igniter-lang/README.md
igniter-lang/RELEASE_NOTES.md
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json
```

Result:

```text
no uncommitted relevant release-file changes reported by git status
```

Meaning:

- current package/version/docs/smoke-summary inputs are stable in the local
  worktree for this preflight;
- this does not assert the whole repo is clean;
- C4-A or an execution card should still perform a full `git status --short`
  review before tag/publish.

---

## Collision Checks

| Check | Result | C4-A disposition |
| --- | --- | --- |
| Local tag `igniter-lang-v0.1.0.alpha.1` | not found | no local tag collision found |
| Remote tag `origin/igniter-lang-v0.1.0.alpha.1` | not found | no remote tag collision found |
| RubyGems exact package/version | no `igniter_lang` listing returned | no RubyGems collision found by read-only check |
| Network availability | available for remote git tag and RubyGems checks | no HOLD-if-unknown needed for these fields |

Commands returned no matching output for the tag and RubyGems checks.

---

## Public Docs Preflight

Public/package docs still say "not yet published" before release execution:

```text
igniter-lang/README.md:
  igniter_lang 0.1.0.alpha.1 - alpha prerelease candidate. Not yet published.

igniter-lang/RELEASE_NOTES.md:
  0.1.0.alpha.1 (alpha prerelease candidate - not yet published)
  RubyGems availability: Not yet - publish not authorized
```

This is correct before release execution.

Readiness note for C4-A:

- If C4-A authorizes publish without another docs edit, the packaged
  `README.md` and `RELEASE_NOTES.md` will still contain pre-publish wording.
- C4-A should either accept that as prerelease-candidate wording or authorize a
  narrow post-authorization docs/status update and decide whether that update
  requires a fresh package smoke.

---

## HOLD-If-Unknown Fields

No collision field is unknown in this preflight:

```text
local_tag_collision: known false
remote_tag_collision: known false
rubygems_package_listing_collision: known false
relevant_release_file_git_state: known clean
packaged_readme_release_notes: known true
public_docs_not_yet_published_wording: known true
```

If a future agent cannot access remote git or RubyGems, the following must
become C4-A HOLD fields:

```text
remote_tag_collision_unknown
rubygems_version_collision_unknown
```

---

## Compact Target / Collision Matrix

| Field | Value | Status |
| --- | --- | --- |
| package | `igniter_lang` | ready |
| version | `0.1.0.alpha.1` | ready |
| expected tag | `igniter-lang-v0.1.0.alpha.1` | no collision found |
| R183 artifact SHA256 | `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6` | accepted |
| relevant release files | no git status output | ready |
| local tag | not found | ready |
| remote tag | not found | ready |
| RubyGems exact listing | no listing returned | ready |
| gemspec includes README.md | yes | ready |
| gemspec includes RELEASE_NOTES.md | yes | ready |
| smoke artifact includes README.md | yes | accepted |
| smoke artifact includes RELEASE_NOTES.md | yes | accepted |
| public docs say not yet published | yes | correct pre-execution |

---

## Readiness Notes For C4-A

No collision blocker was found by this preflight.

Readiness notes:

- C4-A may treat target/tag/RubyGems collision preflight as clear for
  `igniter_lang 0.1.0.alpha.1`.
- C4-A must still preserve explicit user approval for any tag, push, publish,
  signing, or deployment step.
- C4-A should decide whether pre-publish wording in packaged docs is acceptable
  for the release artifact or needs a final docs/status adjustment.
- C4-A should require an execution card to re-check collisions immediately
  before `git tag`, `git push`, and `gem push`.
- C4-A should not treat this preflight as release execution.

---

## Closed Surfaces

This card does not authorize:

- gem build;
- RubyGems publish;
- git tag creation;
- git push;
- signing or deployment;
- release command execution;
- version edits;
- gemspec edits;
- README or RELEASE_NOTES edits;
- public release/demo claims;
- production readiness claims;
- stable release claims;
- all grammar support claims;
- branch/conditional `if_expr`;
- profile finalization/discovery/defaulting;
- Spark integration;
- compiler/runtime behavior changes.
