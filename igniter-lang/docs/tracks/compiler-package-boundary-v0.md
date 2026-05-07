# Track: Compiler Package Boundary v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/compiler-package-boundary-v0`
Card: S2-R12-C2-P
Status: done
Date: 2026-05-07

---

## Goal

Prove that the Ruby API facade, CLI entrypoint, and compiler internals share one
packageable compiler boundary without creating a gem release package yet.

---

## Boundary

The shared compiler spine is:

```text
require "igniter_lang"
  -> IgniterLang.compile(...)
  -> IgniterLang::CompilerOrchestrator#compile
  -> Parser / Classifier / TypeChecker / SemanticIREmitter / Assembler
  -> CompilerResult + CompilationReport
```

The production CLI path is:

```text
igniter-lang/bin/igniter-lang
  -> experiments/production_compiler_cli/production_compiler_cli.rb
  -> ProductionCompilerCLI::Compiler#compile
  -> IgniterLang.compile(...)
```

The CLI still owns argv parsing, proof-local sample input resolution, proof-local
runtime smoke, and public stdout formatting. The compiler facade owns the packageable
compile API.

---

## Proof Update

`production_compiler_cli_proof.rb` now checks three package-boundary facts:

1. Direct Ruby API compile works through `IgniterLang.compile`.
2. CLI compile and direct API compile produce the same compiler identity shape:
   - `program_id`
   - `source_hash`
   - `contracts`
   - assemble stage
3. Load-path smoke works with:

```text
ruby -I igniter-lang/lib -e 'require "igniter_lang"'
```

and confirms:

```text
IgniterLang.respond_to?(:compile) == true
IgniterLang::CompilerOrchestrator is defined
```

The direct API smoke writes to `/private/tmp/igniter_lang_compiler_package_boundary_direct_api.igapp`
so it does not add repo-local proof artifacts.

---

## Load-Path Shape

Current packageable load path:

```text
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/*.rb
```

`igniter_lang.rb` is the facade. It requires `igniter_lang/compiler_orchestrator`,
and the orchestrator requires the compiler internals:

```text
assembler.rb
classifier.rb
compilation_report.rb
compiler_result.rb
parser.rb
semanticir_emitter.rb
typechecker.rb
```

This is package-shaped but not yet gem-packaged.

---

## Remaining Packaging Checklist

Before calling this a distributable compiler package:

- Add `igniter-lang.gemspec` or package-local gemspec equivalent.
- Add package version file, e.g. `lib/igniter_lang/version.rb`.
- Move the CLI entrypoint behind a package load path instead of requiring the experiment CLI directly.
- Decide final bin name and executable install path.
- Add a package-level test for `require "igniter_lang"` without repo-relative paths.
- Extract or explicitly mark proof-local runtime smoke so the facade remains production-minimal.
- Decide whether `ProductionCompilerCLI` becomes package code or remains an experiment wrapper.

---

## Acceptance Status

| Check | Status |
|-------|--------|
| `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` | PASS |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R12-C2-P
Track: compiler-package-boundary-v0
Status: done

[D] Decisions:
- IgniterLang.compile is the minimal packageable Ruby facade.
- CompilerOrchestrator remains the internal compiler boundary behind the facade.
- The experiment CLI is proven to call the same facade, but is not promoted to package code.
- No gemspec/bin/version release packaging was added.

[S] Signals:
- Direct Ruby API and CLI compile share program_id/source_hash/contracts/stage shape.
- `ruby -I igniter-lang/lib -e 'require "igniter_lang"'` resolves facade + orchestrator.
- CLI stdout/result behavior remains green.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks:
- CLI bin still requires experiment code directly.
- Runtime smoke is still proof-local and callback-injected.
- No gemspec/version/install path exists yet.

[Next] Packaging skeleton:
- Add version + gemspec/bin load-path proof, then decide whether ProductionCompilerCLI graduates from experiment to package entrypoint.
```
