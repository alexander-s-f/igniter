# Gem Native Package Boundary Specs v0

Card: S2-R15-C2-P
Role: `[Igniter-Lang Research Agent]`
Track: `gem-native-package-boundary-specs-v0`
Status: done
Date: 2026-05-07

## Goal

Turn the R13/R14 package skeleton into gem-native confidence.

This slice is package-boundary only. It adds no compiler, parser, typechecker,
SemanticIR, assembler, or RuntimeMachine semantics.

## Proof

New command:

```text
ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb
```

The proof builds the local gem, installs it into an isolated `/private/tmp` gem
home, then runs package-facing checks from `/private/tmp` with only `GEM_HOME`
and `GEM_PATH`. It does not use `-I igniter-lang/lib` for the installed-gem
require/compile/bin checks.

## Checks

| Check | Meaning |
|-------|---------|
| `gem_build` | `gem build igniter_lang.gemspec` produces a local `.gem` |
| `gem_install_isolated_home` | built gem installs into an isolated gem home |
| `require_igniter_lang_from_installed_gem` | `require "igniter_lang"` exposes `VERSION`, `compile`, and orchestrator |
| `direct_compile_package_boundary` | installed gem can call `IgniterLang.compile` on Add source |
| `igc_package_executable` | installed `igc compile ... --out ...` writes an `.igapp` |
| `direct_api_and_igc_same_facade_shape` | direct API and installed `igc` share program/source/contracts/stages |
| `installed_gem_no_repo_load_path` | package checks run without repo-local load-path injection |

## Proof Output

```text
PASS gem_native_package_boundary_specs
gem_build: PASS
gem_install_isolated_home: PASS
require_igniter_lang_from_installed_gem: PASS
direct_compile_package_boundary: PASS
igc_package_executable: PASS
direct_api_and_igc_same_facade_shape: PASS
installed_gem_no_repo_load_path: PASS
summary: igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.json
```

JSON shape smoke:

```text
gem_native_package_boundary_specs PASS
checks=7
version=0.1.0.pre.stage2
gaps=4
```

## Release Readiness Gaps

[R] `final_gem_metadata` is still open: gemspec uses placeholder
homepage/source_code/contact metadata.

[R] `gem_native_ci` is still open: this is a proof-local runner, not CI.

[R] `runtime_smoke_adapter` remains deferred: runtime smoke is optional and
proof-backed.

[R] `release_policy` is still open: no RubyGems publishing, signing/checksum,
or release automation policy exists.

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R15-C2-P
Track: gem-native-package-boundary-specs-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Added a gem-native proof rather than converting the repo to RSpec/package CI.
- Proved installed-gem `require "igniter_lang"` from `/private/tmp` without repo `-I`.
- Proved installed `IgniterLang.compile` and installed `igc` both compile Add to `.igapp`.
- Kept scope package-boundary only; no compiler/runtime semantics changed.

[S] Signals:
- Isolated gem build/install works for `igniter_lang-0.1.0.pre.stage2`.
- Direct API and installed `igc` produce the same program/source/contracts/stages shape.
- Summary JSON records seven PASS checks and four release-readiness gaps.

[T] Tests / Proofs:
- `ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb` -> PASS

[R] Risks:
- Gem metadata and release policy are still placeholders/open.
- The proof is local and deterministic enough for evidence, but not wired into CI.
- Runtime smoke remains proof-backed and optional.

[Files] Changed:
- `igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb`
- `igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.json`
- `igniter-lang/docs/tracks/gem-native-package-boundary-specs-v0.md`

[Next] Proposed next slice:
- Decide release policy and final gem metadata, or wire this proof into a package-native test task before any real release.
```
