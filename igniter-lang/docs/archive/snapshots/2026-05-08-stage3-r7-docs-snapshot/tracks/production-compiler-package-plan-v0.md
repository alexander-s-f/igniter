# Production Compiler Package Plan v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/production-compiler-package-plan-v0`
Status: done
Date: 2026-05-07

## Goal

Plan the first production-ish Igniter-Lang compiler package without pretending
the proof fixtures are already a complete compiler.

Target command:

```bash
igniter-lang compile path/to/source.ig --out path/to/app.igapp
```

## Neighbor Awareness

- `[Igniter-Lang Compiler/Grammar Expert]`: owns final pass boundaries,
  diagnostic taxonomy, source span rules, and which proof-local checks become
  classifier vs typechecker work.
- `[Igniter-Lang Bridge Agent]`: owns future package/runtime integration once
  this plan becomes an approved bridge request.

## Current Horizon

```text
source.ig
  -> ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIRProgram + CompilationReport
  -> .igapp/
  -> RuntimeMachine.load(...) smoke
```

Stage 1 proves this spine for a small fixture family. The first package should
make that pipeline callable and inspectable, not expand the language.

## Minimal CLI Contract

### Success

```bash
igniter-lang compile path/to/source.ig --out path/to/app.igapp
```

Effects:

```text
path/to/app.igapp/
  manifest.json
  semantic_ir_program.json
  compilation_report.json
  compatibility_metadata.json
  classified_ast.json
  requirements.json
  diagnostics.json
  projections.json
  contracts/*.json
```

Exit:

```text
0
```

Stdout:

```json
{
  "status": "ok",
  "source_path": "path/to/source.ig",
  "out": "path/to/app.igapp",
  "compilation_report_ref": "compilation_report/...",
  "semantic_ir_ref": "semanticir/...",
  "contracts": ["Add"]
}
```

### OOF / Error

Effects:

```text
path/to/app.igapp/             -- not written
path/to/app.compilation_report.json
```

Exit:

```text
non-zero
```

Stdout:

```json
{
  "status": "oof",
  "source_path": "path/to/source.ig",
  "out": null,
  "compilation_report_path": "path/to/app.compilation_report.json",
  "diagnostics": [
    { "rule": "OOF-P1", "severity": "error", "message": "..." }
  ]
}
```

[D] Failure writes a `CompilationReport`/refusal report, not a partial
`.igapp/`.

[D] `SemanticIRProgram` exists only when `CompilationReport.pass_result == "ok"`.

[D] Non-zero exit is required for parser error, OOF, unsupported proof surface,
I/O error, or runtime load smoke failure.

## Proposed Package Shape

First package directory, still inside `igniter-lang/`:

```text
igniter-lang/
  bin/
    igniter-lang
  lib/
    igniter_lang.rb
    igniter_lang/cli.rb
    igniter_lang/compiler.rb
    igniter_lang/compiler/result.rb
    igniter_lang/parser.rb
    igniter_lang/classifier.rb
    igniter_lang/typechecker.rb
    igniter_lang/semantic_ir_emitter.rb
    igniter_lang/assembler.rb
    igniter_lang/runtime_smoke.rb
    igniter_lang/diagnostics.rb
    igniter_lang/canonical_json.rb
```

[D] No root Igniter package edits in the first implementation slice.

[D] Keep the package stdlib-only at first, matching current experiments.

## Proof Chain To Module Map

| Package module | Current proof source | Reuse now | Extract later |
|---|---|---|---|
| `IgniterLang::Parser` | `experiments/parser/igniter_lang_parser.rb` | yes, direct wrapper | split lexer/parser/ParsedProgram classes into `lib/` |
| `IgniterLang::Classifier` | `experiments/classifier_pass_proof/classifier_pass_proof.rb` | yes, but fixture-shaped | expose `ParsedProgram -> ClassifiedProgram`; remove golden-dir assumptions |
| `IgniterLang::TypeChecker` | `experiments/typechecker_proof/typechecker_proof.rb` | yes, boundary logic | consume only ClassifiedProgram object/path; no proof-owned fixture dirs |
| `IgniterLang::SemanticIREmitter` | `experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb` | partial | separate emitter from fixture `CASES` and sample-input gates |
| `IgniterLang::Assembler` | `experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | yes, for artifact writing | accept in-memory `SemanticIRProgram + CompilationReport`; no golden-dir reads |
| `IgniterLang::RuntimeSmoke` | `experiments/runtime_machine_memory_proof/compiled_program.rb` and `igapp_assembler_proof` runtime checks | yes, optional smoke | extract load-only smoke; evaluation smoke only when sample inputs are available |
| `IgniterLang::StdlibRegistry` | `experiments/stdlib_execution_kernel_stage1/` and runtime registry | yes | one canonical registry shared by typechecker/runtime smoke |

## Extraction Boundaries

### Parser

Input:

```text
source string + source_path
```

Output:

```text
ParsedProgram hash/object
```

Must preserve:

- existing accepted fixtures
- syntax-owned parser OOF hardening
- structured `parse_errors[]`

### Classifier

Input:

```text
ParsedProgram
```

Output:

```text
ClassifiedProgram
```

Must extract:

- symbol table construction
- CORE/ESCAPE/OOF propagation
- diagnostics for classifier-owned OOF

Must not do:

- type inference
- SemanticIR emission
- RuntimeMachine assumptions

### TypeChecker

Input:

```text
ClassifiedProgram
```

Output:

```text
TypedProgram
```

Must extract:

- type declarations
- field access typing
- canonical stdlib operator resolution
- OOF diagnostics for type-owned failures

Guarantee:

```text
accepted TypedProgram has no unresolved symbols, unresolved types, or
pre-resolution stdlib.numeric.add in executable positions.
```

### SemanticIR Emitter

Input:

```text
TypedProgram
```

Output:

```text
SemanticIRProgram + CompilationReport
```

Must preserve PROP-019.1:

- `kind: "semantic_ir_program"`
- `format_version: "0.1.0"`
- `compilation_report_ref`
- no `oof_log` inside SemanticIR
- no SemanticIR output for OOF attempts
- monomorphic operators only

Known extraction issue:

[Q] Current `source_to_semanticir_fixture` still compresses classifier,
typechecker, and emitter concerns in a tiny compiler and uses fixture
`sample_input` for some gates. The production-ish emitter must consume
TypedProgram, not sample runtime data.

### Assembler

Input:

```text
CompilationReport
SemanticIRProgram?
out path
```

Behavior:

- if report `pass_result != "ok"`: write refusal report only, non-zero
- if ok: validate report/program refs, split `contracts/*.json`, write `.igapp/`
- never assemble OOF contracts

### Runtime Load Smoke

Input:

```text
.igapp/ path
```

Default smoke:

```text
RuntimeMachine.load(.igapp/) -> trusted CompatibilityReport
```

Optional evaluation smoke:

```text
evaluate only when a fixture/test provides deterministic sample inputs.
```

[D] The compile CLI should not require runtime evaluation to succeed unless
`--smoke evaluate` is added later. Load smoke is enough for the first package
command.

## Slice Plan

### Slice 1: Compile CLI Wrapper Over Experiments

Goal:

```bash
igniter-lang compile SOURCE --out OUT.igapp
```

Implementation shape:

- create `bin/igniter-lang`
- create a tiny CLI dispatcher
- call existing parser and proof compiler/assembler code through wrapper
  functions
- support the current Stage 1 fixture subset first:
  `add`, `claim_evidence`, `evidence_linked_alert`, and their negative cases
- write `.igapp/` on success
- write `OUT.compilation_report.json` on OOF/error
- return non-zero on OOF/error

Acceptance:

```bash
igniter-lang compile igniter-lang/experiments/source_to_semanticir_fixture/add.ig \
  --out /tmp/add.igapp
```

produces a loadable `.igapp/`.

Known limitation:

[Q] Arbitrary source files outside the Stage 1 supported subset may return an
`unsupported_proof_surface` CompilationReport until modules are extracted.

### Slice 2: Extract Library Modules

Goal:

Move stable code from experiments into `lib/igniter_lang/` without changing
behavior.

Order:

1. `canonical_json`
2. parser
3. diagnostics/result objects
4. assembler
5. classifier
6. typechecker
7. semantic_ir_emitter
8. runtime_smoke

Acceptance:

- proof scripts can require library modules
- experiments become thin fixtures/checkers
- golden outputs remain deterministic

### Slice 3: Add Package Tests

Goal:

Create package-level tests for the CLI and library boundaries.

Minimum tests:

- parser accepts known positives
- parser rejects syntax-owned OOF
- classifier/typechecker block semantic OOF
- compile CLI writes `.igapp/` for `add`
- compile CLI refuses negative fixtures with non-zero exit
- assembler refuses `pass_result: "oof"`

Test policy:

- stdlib-only
- no root package integration
- no network

### Slice 4: Runtime Smoke

Goal:

Add package-level RuntimeMachine load smoke after compile.

Minimum smoke:

```text
compile add.ig -> .igapp/
RuntimeMachine.load(.igapp/) -> trusted
```

Optional fixture smoke:

```text
evaluate Add(19, 23) -> 42
```

Acceptance:

- load smoke is deterministic
- smoke failure returns non-zero and writes a report
- no production backend adapters required

## First Implementation Guardrails

[D] Do not implement a new grammar.

[D] Do not add Stage 2 primitives.

[D] Do not integrate with root Igniter packages.

[D] Do not make `.igapp/` on OOF.

[D] Do not let `stdlib.numeric.add` appear in executable SemanticIR or
RuntimeMachine operator calls.

[D] Keep generic polymorphic templates metadata-only; only monomorphic
contracts are loadable.

## Open Questions

[Q] Should the first CLI support only known fixture profiles, or should it emit
`unsupported_proof_surface` for any construct outside the extracted subset?

[Q] Should runtime load smoke be default-on, or should the first CLI provide
`--no-smoke` for faster compiler-only runs?

[Q] Should failure reports be written beside `--out` as
`OUT.compilation_report.json`, or inside a sibling `OUT.failed/` directory?

[Q] Should package tests use Minitest/stdout assertions or a tiny custom Ruby
checker style matching experiments?

## Rejected

[X] No production gem release in this plan.

[X] No root `packages/` edits.

[X] No full arbitrary-language compiler claim in Slice 1.

[X] No RuntimeMachine checkpoint/resume proof inside the compile CLI. Load smoke
is enough for the first package boundary.

## Deliverables Checklist

```text
[x] Track doc
[x] File/module extraction plan
[x] CLI output contract
[x] Slice plan:
    1. compile CLI wrapper over experiments
    2. extract library modules
    3. add package tests
    4. runtime smoke
```

## Next

[Next] `production-compiler-cli-wrapper-v0`: implement the first
`igniter-lang compile SOURCE --out OUT.igapp` wrapper over the current Stage 1
proof chain, with explicit `unsupported_proof_surface` refusal for non-covered
source shapes.
