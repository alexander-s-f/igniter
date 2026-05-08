# Track: Invariant Source Metadata Preservation v0

Card: S3-R10-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `invariant-source-metadata-preservation-v0`
Status: done
Date: 2026-05-08

---

## Goal

Preserve invariant source metadata across parser, classifier, typechecker, and
SemanticIR emission so runtime/report layers can explain invariant outcomes
without losing author intent.

---

## Decision

[D] Invariant metadata remains descriptive only.

The slice does not add invariant semantics, new enforcement, new OOFs, runtime
persistence, or parser syntax.

[D] The metadata shape preserved across compiler stages is:

```text
source_metadata.kind
source_metadata.source_path
source_metadata.source_span
source_metadata.name
source_metadata.severity
source_metadata.label
source_metadata.message
```

[D] Parser span is currently start-only:

```text
{ "line": <line>, "col": <col> }
```

That matches the "where currently available" scope. End spans remain a future
parser-location improvement.

---

## Implementation

[S] Parser:

- `parse_invariant_decl` now attaches `source_span` to invariant declarations.

[S] Classifier:

- preserves invariant author fields:
  `predicate_ref`, `severity`, `label`, `message`, `overridable_with`,
  `source_span`, `threshold`, `threshold_ms`
- adds `source_metadata` with `source_path` from ParsedProgram.

[S] TypeChecker:

- preserves `source_span` and `source_metadata` on typed invariant declarations.
- preserves existing threshold fields when present.

[S] SemanticIREmitter:

- carries `source_span` and `source_metadata` into `invariant_node`.
- includes invariant `message` and optional `source_metadata` in
  `compilation_report.invariant_coverage`.

[S] Proof:

- `invariant_severity_proof` now includes a real
  Parser -> Classifier -> TypeChecker -> SemanticIREmitter path check for
  invariant metadata preservation.

---

## Spec Note

[R] Ch6 SemanticIR should be synced later to document optional
`source_metadata` / `source_span` on `invariant_node` and optional
`source_metadata` on `compilation_report.invariant_coverage`.

[R] Ch7 Runtime does not need immediate sync from this slice. Runtime behavior
did not change; the runtime/report layer now receives better descriptive
metadata when it chooses to surface invariant outcomes.

---

## Remaining Gaps

[R] Parser spans are start-only. A future parser-location slice can add
`end_line` / `end_col` consistently across all declarations.

[R] Runtime invariant observation persistence remains open. This slice only
preserves metadata into SemanticIR/report coverage.

[R] Existing proof-local typed fixtures may not carry source metadata unless
they are regenerated from source. The real source pipeline is covered by the
new invariant proof checks.

---

## Verification

```text
ruby -c igniter-lang/lib/igniter_lang/parser.rb
ruby -c igniter-lang/lib/igniter_lang/classifier.rb
ruby -c igniter-lang/lib/igniter_lang/typechecker.rb
ruby -c igniter-lang/lib/igniter_lang/semanticir_emitter.rb
ruby -c igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

---

## Handoff

```text
Card: S3-R10-C4-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: invariant-source-metadata-preservation-v0
Status: done

[D] Decisions:
- Invariant source metadata is descriptive only.
- Parser attaches start span to invariant declarations.
- Classifier/typechecker/SemanticIR preserve invariant name/severity/message
  and source metadata.
- No new invariant semantics or enforcement expansion added.

[S] Shipped / Signals:
- Parser, classifier, typechecker, and SemanticIREmitter now preserve invariant
  source metadata where available.
- invariant_severity_proof covers the real source pipeline preservation path.

[T] Tests / Proofs:
- invariant_severity_proof PASS.
- classifier_pass_proof PASS.
- source_to_semanticir_fixture --check-golden PASS.
- typechecker_proof --check-golden PASS.
- stage1_close_candidate PASS.

[R] Risks / Recommendations:
- Ch6 should document optional invariant source_metadata/source_span.
- Runtime invariant persistence remains separate future work.

[Next] Suggested next slice:
- spec-ch6-invariant-source-metadata-sync-v0, if spec lag needs to be closed
  before the next docs round.
```

## Files Changed

```text
igniter-lang/lib/igniter_lang/parser.rb
igniter-lang/lib/igniter_lang/classifier.rb
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
igniter-lang/experiments/invariant_severity_proof/summary.json
igniter-lang/experiments/invariant_severity_proof/golden/compilation_report.json
igniter-lang/docs/tracks/invariant-source-metadata-preservation-v0.md
```
