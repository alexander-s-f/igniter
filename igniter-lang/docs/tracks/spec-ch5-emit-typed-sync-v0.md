# Track: Spec Ch5 Emit Typed Sync v0

Card: S3-R6-C6-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/spec-ch5-emit-typed-sync-v0`
Status: done
Date: 2026-05-08

---

## Goal

Update the compiler pipeline spec after the S3-R5-C4 orchestrator switch from
parsed SemanticIR emission to typed SemanticIR emission.

---

## Updated File

```text
igniter-lang/docs/spec/ch5-compiler-pipeline.md
```

---

## Decisions

[D] Updated the pipeline so Stage 3 Emit takes `TypedProgram` as production
input:

```text
Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed(typed)
```

[D] Marked `SemanticIREmitter#emit_typed(typed_program)` as the production path
since S3-R5-C4.

[D] Marked `SemanticIREmitter#emit(parsed_program, sample_input:)` as the Stage
1 legacy/internal comparison path.

[D] Documented the public behavior delta: valid Stage 2 surfaces now lower into
SemanticIR instead of hitting parsed-path OOF / missing-node behavior.

[D] Preserved no-runtime-execution/no-cache/no-Ledger caveats for TEMPORAL
surfaces.

---

## Evidence References

- `docs/tracks/typed-emission-stage2-source-lowering-parity-v0.md`
- `docs/tracks/bihistory-source-fixture-parity-gate-v0.md`
- `docs/tracks/orchestrator-emit-typed-switch-v0.md`
- `experiments/production_compiler_cli/`
- `experiments/stage1_close_candidate/`
- `experiments/stage2_close_candidate/`

---

## Non-Goals

[X] No compiler code changed.

[X] No proof fixtures changed.

[X] No current-status update; round-close maps remain Meta Expert ownership.

---

## Verification

Docs-only sync. Sanity checks:

```text
rg "emit_typed" docs/spec/ch5-compiler-pipeline.md
rg "legacy" docs/spec/ch5-compiler-pipeline.md
rg "Stage 2" docs/spec/ch5-compiler-pipeline.md
git diff --check -- docs/spec/ch5-compiler-pipeline.md docs/tracks/spec-ch5-emit-typed-sync-v0.md
```

---

## Handoff

```text
Card: S3-R6-C6-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/spec-ch5-emit-typed-sync-v0
Status: done

[D] Decisions:
- Stage 3 Emit production input is now TypedProgram.
- emit_typed is the production path since S3-R5-C4.
- emit(parsed) is Stage 1 legacy/comparison behavior.
- Valid Stage 2 surfaces now lower instead of OOFing through parsed legacy
  limitations.

[S] Shipped / Signals:
- ch5 now matches current CompilerOrchestrator behavior.
- Public behavior delta is documented explicitly.

[T] Tests / Proofs:
- Docs-only; no code proof required.

[R] Risks / Recommendations:
- Future spec sync should ensure CLI/package docs do not still imply parsed
  emission is the main path.

[Next] Suggested next slice:
- spec-cli-compiler-entrypoint-sync-v0 if CLI docs still describe the old
  parsed-emitter path.
```

## Files Changed

```text
igniter-lang/docs/spec/ch5-compiler-pipeline.md
igniter-lang/docs/tracks/spec-ch5-emit-typed-sync-v0.md
```
