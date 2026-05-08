# Gem Release Policy v0

Card: S3-R2-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/gem-release-policy-v0
Status: done
Date: 2026-05-08

## Goal

Resolve `igniter_lang` gem release readiness policy without publishing to
RubyGems.

This slice reviews the package skeleton, closes safe metadata placeholders, and
defines the release checklist, CI gate, approval rule, artifacts, command shape,
and rollback notes. It does not change `IgniterLang::VERSION`.

## Package Skeleton Review

Current package surface:

```text
igniter-lang/igniter_lang.gemspec
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/*.rb
igniter-lang/bin/igc
igniter-lang/README.md
```

Current installed executable:

```text
igc compile SOURCE --out OUT.igapp
```

`bin/igniter-lang` still exists as a repo-local compatibility wrapper that
requires the experiment CLI. It is not listed as a gem executable. The
releaseable gem executable is `igc`.

Current version:

```text
IgniterLang::VERSION = "0.1.0.pre.stage2"
```

[D] This track does not change the version. A future release approval must
decide whether to publish the existing prerelease version or bump to a Stage 3
prerelease.

## Metadata Checklist

Safe cleanup applied to `igniter_lang.gemspec`:

| Field | Policy value | Status |
|-------|--------------|--------|
| `name` | `igniter_lang` | ready |
| `summary` | `Contract-native language compiler for Igniter` | ready |
| `description` | Packageable compiler facade and CLI for the Igniter-Lang workspace | ready |
| `authors` | `["Alexander"]` | ready |
| `email` | `["alexander.s.fokin@gmail.com"]` | ready |
| `homepage` | `https://github.com/alexander-s-f/igniter` | ready |
| `license` | `MIT` | ready |
| `metadata.homepage_uri` | same as homepage | ready |
| `metadata.source_code_uri` | `https://github.com/alexander-s-f/igniter/tree/main/igniter-lang` | ready |
| `metadata.rubygems_mfa_required` | `true` | ready |

[R] Before a stable `1.0` release, consider adding a package-local
`LICENSE.txt` to the gem files. The current RubyGems license field is set, and
the repository root license is MIT, but the gem payload does not include a
license artifact today.

## CI Gate

[D] A release candidate is not releasable unless all gates pass from the repo
root:

```text
ruby -c igniter-lang/igniter_lang.gemspec
ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

The gem-native boundary spec is the release lane's package proof. It must prove:

```text
gem_build
gemspec_release_metadata
gem_install_isolated_home
require_igniter_lang_from_installed_gem
direct_compile_package_boundary
igc_package_executable
direct_api_and_igc_same_facade_shape
installed_gem_no_repo_load_path
```

[R] CI automation is still open. A future CI job should run the gate above on
Ruby `>= 3.1`, with at least the minimum supported Ruby and the current
maintainer Ruby. Until that exists, local PASS is evidence, not automated
release authorization.

## Release Approval Policy

[D] RubyGems publication requires explicit `[Architect Supervisor / Codex]`
approval after the CI gate passes.

[D] Agents may prepare proof artifacts and policy docs. Agents must not publish
to RubyGems.

[D] The human RubyGems owner performs the final publish with MFA enabled.

[D] Version changes are a separate approval. Do not bump
`IgniterLang::VERSION` as part of release prep unless the card explicitly says
to choose and apply the release version.

## Release Command Shape

Preferred future automation:

```text
cd igniter-lang
rake release
```

That task does not exist yet. The task should run:

```text
metadata check -> stage close gate -> gem-native boundary spec -> gem build
-> checksum -> publish
```

Until `rake release` exists, the only approved manual publish sequence is:

```text
ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb
shasum -a 256 /private/tmp/igniter_lang_gem_native_package_boundary_specs/igniter_lang-<VERSION>.gem
gem push /private/tmp/igniter_lang_gem_native_package_boundary_specs/igniter_lang-<VERSION>.gem
```

The `gem push` step is forbidden without explicit Architect approval and human
RubyGems owner action.

## Release Artifacts

A release candidate should retain:

```text
igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.json
igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json
igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
/private/tmp/igniter_lang_gem_native_package_boundary_specs/igniter_lang-<VERSION>.gem
sha256 checksum for the .gem
git tag for the exact release commit
release notes naming the version, proof gate, and deferred gaps
```

[R] Do not treat `/private/tmp` as durable storage. The `.gem` and checksum
should be copied into the release workflow or rebuilt from the tagged commit.

## Rollback Notes

Before publish:

```text
delete local .gem artifact
do not reuse failed release notes/checksum
fix and rerun the full gate
```

After publish:

```text
do not reuse the same version for a different artifact
prefer a new patch/prerelease version with a fix
use `gem yank igniter_lang -v <VERSION>` only for severe broken or unsafe releases
record the yank/fix reason in release notes and the next policy/status update
```

`gem yank` also requires Architect approval and human RubyGems owner action.

## Verification

```text
ruby -c igniter-lang/igniter_lang.gemspec
  -> Syntax OK

ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb
  -> PASS gem_native_package_boundary_specs
```

## Changed Files

```text
igniter-lang/docs/tracks/gem-release-policy-v0.md
igniter-lang/igniter_lang.gemspec
igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb
igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.json
```

## Handoff

```text
Card: S3-R2-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/gem-release-policy-v0
Status: done

[D] Decisions
- RubyGems publish requires explicit Architect approval and human RubyGems owner action.
- Agents may prepare gates/artifacts but must not publish.
- `igc` is the releaseable gem executable; `bin/igniter-lang` remains repo-local compatibility.
- Version stays `0.1.0.pre.stage2` in this slice.
- Final metadata placeholders are replaced with repository/author/license metadata.

[S] Shipped / Signals
- Gemspec metadata now has non-placeholder homepage, source, authors, email, license, and summary.
- Gem-native package boundary proof now includes `gemspec_release_metadata`.
- Release checklist defines CI gate, artifacts, publish command shape, and rollback/yank policy.

[T] Tests / Proofs
- ruby -c igniter-lang/igniter_lang.gemspec -> Syntax OK
- ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb -> PASS

[R] Risks / Recommendations
- CI automation is still open; local proof is not release automation.
- `rake release` does not exist yet and should be added before routine releases.
- Decide version bump policy before any real publish.
- Consider adding package-local LICENSE.txt before stable release.

[Next] Suggested next slice
- gem-release-automation-v0: add package-local release task that runs the gate, builds the gem, writes checksum, and stops before publish unless Architect approval is present.
```
