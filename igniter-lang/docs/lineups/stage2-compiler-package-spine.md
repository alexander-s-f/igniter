# Line Up: Stage 2 Compiler Package Spine

Status: active memory card
Source:
- `igniter-lang/docs/tracks/extract-classifier-module-v0.md`
- `igniter-lang/docs/tracks/extract-typechecker-module-v0.md`
- `igniter-lang/docs/tracks/extract-semanticir-emitter-module-v0.md`
- `igniter-lang/docs/tracks/extract-assembler-module-v0.md`
- `igniter-lang/docs/tracks/compiler-orchestrator-v0.md`
- `igniter-lang/docs/tracks/packageable-compiler-api-v0.md`
- `igniter-lang/docs/tracks/compiler-package-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-packaging-skeleton-v0.md`
- `igniter-lang/docs/tracks/gem-native-package-boundary-specs-v0.md`
Prepared by: `[Igniter-Lang Line Up Summarizer]`
Date: 2026-05-12
Disposition input: `active_reference -> public_archive candidate`
Current route: Line Up complete; Archive/Form verification, then History
Curator movement/link planning before any archive grouping.

## One-Line Claim

Stage 2 moved the compiler from proof-local pass scripts toward a package-shaped
Ruby compiler boundary, ending with a local gem-native proof but not a release.

## Why It Matters

This cluster is useful implementation archaeology: it explains why current
compiler truth lives in `igniter-lang/lib/`, `IgniterLang.compile`, and current
compiler-profile tracks rather than in old extraction notes. In short: source remains authoritative for exact proof logs.

## Key Signals

| Area | Signal |
| --- | --- |
| Pass extraction | Classifier, TypeChecker, SemanticIR emitter, and Assembler were extracted into reusable `lib/igniter_lang/` modules while preserving proof goldens. |
| Orchestration | `CompilerOrchestrator` connected parser/classifier/typechecker/emitter/assembler behind the production compiler path. |
| Facade | `IgniterLang.compile(...)` became the stable Ruby-facing API; CLI and direct API were proven to share facade shape. |
| Package boundary | `require "igniter_lang"` and API/CLI package boundary were proven without calling it release readiness. |
| Gem skeleton | `igniter_lang.gemspec`, prerelease version, and `igc` executable were build/install smoke-tested in isolated gem homes. |
| Gem-native proof | Installed gem checks passed without repo `-I`, with seven PASS checks and release-readiness gaps still explicit. |

## Canon / History / Research / Value

- Canon/current truth: `igniter-lang/lib/`, `IgniterLang.compile`,
  `agent-context.md`, current compiler-profile tracks, and accepted proposals.
- Historical value: extraction order, package boundary rationale, CLI/API proof
  evolution, and release-readiness exclusions.
- Not promoted here: final release metadata, CI, RubyGems publish, production
  RuntimeMachine packaging, or TBackend binding.

## Current Home

All source tracks remain in `igniter-lang/docs/tracks/`. No source file moved,
deleted, or redirected.

## Links To Keep

- `igniter-lang/lib/igniter_lang.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/bin/igc`
- `igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.json`

## Safe To Archive?

Recommended disposition: `active_reference` now; `public_archive` candidate
after implementation agents confirm they no longer need exact extraction docs
by default.

Public/private risk: no private material observed in the assigned source
documents. Paths under `/private/tmp` are proof-local artifact locations, not
project secrets.

## Open Questions

- Should `docs/tracks/README.md` eventually group old extraction tracks under
  this Line Up once current implementation agents rely on `lib/` first?
- Should package skeleton and gem-native proof stay warm until release policy
  and final metadata land?

## Next Route

- Archive/Form Expert: verify no release or runtime authority is implied.
- History Curator: plan grouped index rows only after redirect/no-zombie checks.
