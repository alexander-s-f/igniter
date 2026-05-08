# Compiler Packaging Skeleton v0

Card: S2-R13-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `compiler-packaging-skeleton-v0`
Status: done
Date: 2026-05-07

## Goal

Add the minimal Ruby packaging skeleton needed for Stage 2 close without
releasing Igniter-Lang to RubyGems.

This slice is package plumbing only. It adds no new language semantics, no CI/CD,
no docs generation, no multi-gem split, and no broad package refactor.

## Horizon

`compiler-package-boundary-v0` proved the package-shaped facade:

```text
require "igniter_lang"
  -> IgniterLang.compile(...)
  -> CompilerOrchestrator
  -> Parser / Classifier / TypeChecker / SemanticIREmitter / Assembler
```

This card makes that shape buildable as a prerelease gem artifact and adds a
thin installed compiler executable.

## Added Package Surface

Files:

```text
igniter_lang.gemspec
lib/igniter_lang/version.rb
lib/igniter_lang/cli.rb
bin/igc
```

Public package surfaces:

```ruby
require "igniter_lang"

IgniterLang::VERSION
IgniterLang.compile(source_path: "source.ig", out_path: "app.igapp")
```

CLI:

```text
igc compile path/to/source.ig --out path/to/app.igapp
```

The CLI is intentionally thin. It delegates to `IgniterLang.compile`, prints the
canonical `CompilerResult.public_result`, and exits non-zero when compilation
status is not `ok`.

## Runtime Smoke Boundary

`IgniterLang::RuntimeSmoke` remains optional and proof-backed. The package can
load `igniter_lang` without importing experiment runtime files. Calling runtime
smoke still requires the proof runtime to be available.

This preserves the packageable compiler API while keeping production
RuntimeMachine extraction out of this card.

## Proof Output

Gem build:

```text
Successfully built RubyGem
Name: igniter_lang
Version: 0.1.0.pre.stage2
File: igniter_lang-0.1.0.pre.stage2.gem
```

Installed gem load-path smoke:

```text
0.1.0.pre.stage2
true
```

Installed `igc` smoke:

```text
status: ok
igapp_path: /private/tmp/igniter_lang_stage2_installed_bin_add.igapp
contracts: ["Add"]
runtime_smoke: null
```

Production compiler CLI proof:

```text
PASS production_compiler_cli_proof
compile.add_exit_zero: ok
runtime.load_output_trusted: ok
runtime.evaluate_add_42: ok
compile.oof_exit_nonzero: ok
package_boundary.direct_api_compile_ok: ok
package_boundary.cli_and_api_same_facade_shape: ok
package_boundary.lib_load_path_facade: ok
```

Stage 1 close candidate:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
```

## Packaging Checklist

[D] Done for Stage 2 close:

- Prerelease version constant exists.
- Gem builds locally.
- Installed gem can `require "igniter_lang"`.
- Installed `igc` can compile `add.ig` to `.igapp`.
- CLI delegates to the same `IgniterLang.compile` facade as the API.
- Runtime smoke is optional and does not block package load.

[R] Remains before real release:

- Replace placeholder gem metadata with final project URLs/contact policy.
- Add package-level tests outside experiments.
- Decide whether `igc` or a longer executable name is final.
- Decide whether `ProductionCompilerCLI` graduates from experiment code or stays
  as proof harness around the package API.
- Extract production RuntimeMachine smoke or document it as intentionally
  external.
- Add release process, signing/checksums if needed, CI, and RubyGems publishing
  policy.

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R13-C1-P
Track: compiler-packaging-skeleton-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Added the smallest gem skeleton: gemspec, prerelease version, package CLI, and executable bin.
- Kept `igc` as a thin wrapper over `IgniterLang.compile`.
- Kept runtime smoke optional/proof-backed so package load does not depend on experiment runtime files.
- Did not release, add CI/CD, split gems, or broaden compiler/runtime semantics.

[S] Signals:
- Built gem installs into an isolated `/private/tmp` gem home.
- Installed `require "igniter_lang"` exposes `IgniterLang::VERSION` and `IgniterLang.compile`.
- Installed `igc compile ...` emits an `.igapp` through the package facade.

[T] Tests / Proofs:
- `gem build igniter_lang.gemspec --output /private/tmp/igniter_lang-0.1.0.pre.stage2.gem` -> PASS
- `gem install --local --force --no-document --install-dir /private/tmp/igniter_lang_stage2_gem_home --bindir /private/tmp/igniter_lang_stage2_bin /private/tmp/igniter_lang-0.1.0.pre.stage2.gem` -> PASS
- `env GEM_HOME=/private/tmp/igniter_lang_stage2_gem_home GEM_PATH=/private/tmp/igniter_lang_stage2_gem_home ruby -e 'require "igniter_lang"; puts IgniterLang::VERSION; puts IgniterLang.respond_to?(:compile)'` -> PASS
- `env GEM_HOME=/private/tmp/igniter_lang_stage2_gem_home GEM_PATH=/private/tmp/igniter_lang_stage2_gem_home /private/tmp/igniter_lang_stage2_bin/igc compile ...` -> PASS
- `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` -> PASS
- `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` -> PASS

[R] Risks:
- Gem metadata uses placeholder project URLs and is not release-ready.
- Runtime smoke remains proof-backed, not a production RuntimeMachine package boundary.
- Package tests are still proof/experiment-driven rather than gem-native.

[Files] Changed:
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/bin/igc`
- `igniter-lang/lib/igniter_lang.rb`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/docs/tracks/compiler-packaging-skeleton-v0.md`

[Q] Open Questions:
- Should the final installed executable remain `igc`, or use a longer `igniter-lang` command?
- Should runtime smoke be packaged as an optional adapter or left to application/runtime packages?

[Next] Proposed next slice:
- Add gem-native package boundary specs that exercise `require "igniter_lang"`, `IgniterLang.compile`, and installed `igc` without relying on experiment proof harnesses.
```
