# Extract Parser Module v0

Card: S2-R5-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `extract-parser-module-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R4-C2-P`

## Goal

Move the current parser toward the reusable production compiler package
boundary while preserving existing parser behavior, parser OOF diagnostics, and
production compiler CLI behavior.

This is a Tier 0 package slice. It does not rewrite grammar and does not add
stream parser/classifier support.

## Current Horizon

Production compiler extraction already moved these helpers into `lib/`:

```text
igniter-lang/lib/igniter_lang/diagnostics.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

The CLI still depended on the parser experiment path. This slice removes that
early proof-local dependency by making parser the next library boundary.

## Extracted Boundary

New library file:

```text
igniter-lang/lib/igniter_lang/parser.rb
```

Public API preserved:

```ruby
parsed = IgniterLang::ParsedProgram.parse(source, source_path: path)
parsed.valid?
parsed.errors
parsed.to_h
parsed.to_json
```

The library file now owns:

```text
IgniterLang::Token
IgniterLang::Lexer
IgniterLang::ParseError
IgniterLang::Parser
IgniterLang::ParsedProgram
```

Experiment compatibility shim:

```text
igniter-lang/experiments/parser/igniter_lang_parser.rb
```

The shim keeps the old command path working:

```bash
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
```

Production compiler CLI now requires:

```ruby
require_relative "../../lib/igniter_lang/parser"
```

## Decisions

[D] Kept the parser implementation behavior-preserving. Lexer, recursive
descent parser, OOF parse diagnostics, and `ParsedProgram#to_h` shape were
copied into the library boundary without grammar changes.

[D] Kept experiment parser file as a thin require/script wrapper because
acceptance specs and older proof scripts still reference the experiment path.

[D] Kept the library hash/object boundary, not a value-object rewrite. Later
classifier/typechecker extraction expects the existing ParsedProgram hash shape.

[D] Did not add `stream T` parsing here. `stream_t_proof` remains proof-local;
stream parser/classifier ownership should be a separate slice.

## Proof Output

Parser acceptance:

```text
bundle exec rspec spec/igniter/parser_acceptance_spec.rb
.............................................................

Finished in 0.04645 seconds (files took 0.15205 seconds to load)
61 examples, 0 failures
```

Parser OOF hardening:

```text
PASS parser_oof_hardening_stage2_proof
existing_parser_fixtures_green: ok
syntax_oof_rejected_at_parser: ok
syntax_oof_rules_match: ok
semantic_oof_accepted_by_parser: ok
semantic_oof_blocked_later: ok
oof_p2_pipeline_inside_contract: parser=rejects rule=OOF-P2
oof_dm3_decimal_without_scale: parser=rejects rule=OOF-DM3
oof_pg1_empty_pipeline: parser=rejects rule=OOF-PG1
oof_pg2_step_without_contract_ref: parser=rejects rule=OOF-PG2
oof_pg3_scoped_by_on_compute: parser=rejects rule=OOF-PG3
oof_pg5_tenant_free_on_compute: parser=rejects rule=OOF-PG5
negative_unresolved_symbol: parser=accepts later=oof
negative_evidence_less_alert: parser=accepts later=oof
negative_confidence_bool: parser=accepts later=oof
summary: igniter-lang/experiments/parser_oof_hardening_stage2_proof/parser_oof_hardening_stage2_proof.json
```

Production compiler CLI:

```text
PASS production_compiler_cli_proof
compile.add_exit_zero: ok
compile.add_writes_igapp: ok
compile.add_stdout_shape: ok
runtime.load_output_trusted: ok
runtime.evaluate_add_42: ok
compile.oof_exit_nonzero: ok
compile.oof_writes_report: ok
compile.oof_writes_no_igapp: ok
compile.oof_uses_igapp_path: ok
compile.oof_diagnostics_have_category: ok
compile.oof_stages_and_warnings: ok
positive.igapp_path: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/add.igapp
positive.sum: 42
negative.category: classifier_oof
negative.report: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/negative_unresolved_symbol.compilation_report.json
summary: igniter-lang/experiments/production_compiler_cli/production_compiler_cli_summary.json
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
summary: igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
```

Direct library checks:

```text
ruby -c igniter-lang/lib/igniter_lang/parser.rb -> Syntax OK
ruby -c igniter-lang/experiments/parser/igniter_lang_parser.rb -> Syntax OK
ruby -c igniter-lang/experiments/production_compiler_cli/production_compiler_cli.rb -> Syntax OK
ruby -I igniter-lang/lib -e 'require "igniter_lang/parser"; ...' -> parsed_program
```

## Next Compiler Extraction Unit

Recommended next unit:

```text
extract-classifier-module-v0
```

Reason:

```text
Parser is now a stable library input boundary.
The next proof-local dependency in the package pipeline is classifier logic.
Classifier should expose ParsedProgram hash/object -> ClassifiedProgram hash.
```

Keep out of the classifier extraction:

```text
stream parser/classifier additions
invariant severity parser/typechecker additions
assembler extraction
production RuntimeMachine extraction
```

Those remain separate track lines.

## Changed Files

```text
docs/tracks/extract-parser-module-v0.md
lib/igniter_lang/parser.rb
experiments/parser/igniter_lang_parser.rb
experiments/production_compiler_cli/production_compiler_cli.rb
```

## Handoff

```text
Card: S2-R5-C1-P
[Igniter-Lang Research Agent]
Track: extract-parser-module-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Extracted current parser implementation to igniter-lang/lib/igniter_lang/parser.rb.
- Preserved IgniterLang::ParsedProgram.parse and ParsedProgram JSON shape.
- Kept experiments/parser/igniter_lang_parser.rb as a compatibility CLI shim.
- Updated production compiler CLI to require the library parser.
- Did not rewrite grammar or implement stream parser/classifier behavior.

[S] Signals:
- Parser acceptance remains 61 examples / 0 failures.
- Parser OOF hardening proof remains PASS.
- Production compiler CLI proof remains PASS and still evaluates Add to 42.
- Stage 1 close candidate remains PASS.

[T] Tests / Proofs:
- bundle exec rspec spec/igniter/parser_acceptance_spec.rb -> PASS
- ruby igniter-lang/experiments/parser_oof_hardening_stage2_proof/parser_oof_hardening_stage2_proof.rb -> PASS
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations:
- Keep the parser library hash-based until classifier/typechecker module boundaries are extracted.
- Stream parser/classifier should remain a separate neighboring slice.
- Next package extraction should be extract-classifier-module-v0.

[Next] Suggested next slice:
- extract-classifier-module-v0
```
