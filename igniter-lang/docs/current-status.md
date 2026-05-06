# Igniter-Lang Current Status — Stage 1

Status: active scoreboard
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-06
Policy: `META-EXPERT-003-stage1-implementation-governance-v0.md`
Language spec: `docs/language-spec.md` → `docs/spec/ch1..ch9`

> Full historical status preserved in:
> `docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/current-status.md`

---

## Stage 1 Goal

```text
source.ig → Parser → Classifier → TypeChecker → SemanticIR → .igapp/ → RuntimeMachine trusted
```

---

## Scoreboard — 2026-05-06

```text
Pass                   PROP              Experiment                         Status
──────────────────────────────────────────────────────────────────────────────────────
Parser                 PROP-014/015      experiments/parser/                ✅ partial
                                         add.ig, availability.ig,            [gap] OOF
                                         polymorphic_add.ig → PASS           rejection at
                                                                              parse time

Classifier             PROP-018/020      experiments/classifier_pass_proof/  ✅ PASS
(CORE/ESCAPE/OOF)                        add, claim_evidence,
                                         evidence_linked_alert,
                                         OOF negatives → all PASS

SemanticIR Emitter     PROP-019 +        experiments/source_to_              ✅ PASS
(canonical envelope)   PROP-019.1        semanticir_fixture/                  ✅ golden check
                       (errata)          --check-golden PASS:                  PASS
                                         canonical + compilation_reports +     negative
                                         negative_semanticir_absent            .semantic_ir.json
                                         all PASS                              absent ✓

TypeChecker            PROP-021          experiments/typechecker_proof/       ✅ PASS
                                         9 cases: add, claim_evidence,         ⚠️ gap: uses
                                         evidence_linked_alert,                  classifier_pass
                                         OOF negatives blocked                   _proof/golden;
                                                                                no standalone
                                                                                boundary fixture

.igapp/ Assembler      PROP-012 +        no experiment yet                   🔴 BLOCKED
                       PROP-019.1                                              Slice A
                       (A1-A6 criteria)                                        now unblocked

RuntimeMachine Load    PROP-011          experiments/runtime_machine_        ✅ proven
                                         memory_proof/
                                         load → evaluate → checkpoint →
                                         resume → trusted

Stdlib execution       PROP-013          experiments/stdlib_execution_       ✅ PASS
                                         kernel_stage1/
                                         integer/float/decimal.add,
                                         fold, map, filter, count,
                                         or_else; numeric.add rejected
──────────────────────────────────────────────────────────────────────────────────────
STAGE 1 CLOSED:   NO
Active blocker:   .igapp/ Assembler — Slice A (no remaining prerequisite)
Parallel gaps:    TypeChecker standalone boundary fixture — Slice B
```

---

## Active Blocker: .igapp/ Assembler (Slice A)

Slice 0 is complete: `source_to_semanticir_fixture --check-golden PASS`.
The assembler is now the only blocking step.

```text
Slice A requirements:
  Input:  CompilationReport (pass_result: "ok") + SemanticIRProgram
          (from source_to_semanticir_fixture golden files — already migrated)
  Output: .igapp/ directory per PROP-019.1 §Part 7 (A1..A6)
  Negative: assembler given pass_result: "oof" → refuses, exit != 0
  Done when: RuntimeMachine.load(assembled_add.igapp) → trusted CompatibilityReport
```

**TypeChecker standalone boundary gap** (Slice B — does not block assembler):

```text
typechecker_proof.rb reads ClassifiedProgram from classifier_pass_proof/golden/
as an external input. There is no standalone boundary fixture or runner that
accepts only a ClassifiedProgram and produces a TypedProgram independently.

Missing: experiments/typechecker_boundary/ (or equivalent) that proves
ClassifiedProgram → TypedProgram as a self-contained pipeline step.
This must be closed before Stage 1 fully closes.
```

---

## Next 3 Slices

```text
Slice 0 — ✅ CLOSED
  source_to_semanticir_fixture --check-golden PASS.
  Negative cases: *.semantic_ir.json absent. CompilationReport artifacts present.

Slice A — Research Agent [NOW UNBLOCKED — active]
  Implement experiments/igapp_assembler_proof/igapp_assembler_proof.rb
  Input:  CompilationReport + SemanticIRProgram (from golden files — migrated)
  Output: .igapp/ directory per PROP-019.1 §Part 7 (criteria A1..A6)
  Negative: assembler given pass_result:"oof" → refuses, exit != 0
  Done when: RuntimeMachine.load(assembled_add.igapp) → trusted CompatibilityReport

Slice B — Research Agent [parallel with Slice A]
  Standalone TypeChecker boundary fixture.
  Input:  ClassifiedProgram JSON only (from classifier_pass_proof/golden/)
  Output: TypedProgram JSON as a standalone pipeline step
  Closes: TypeChecker standalone boundary gap
  Note:   typechecker_proof.rb is already PASS; Slice B makes it pipeline-proper.
  Done when: ClassifiedProgram → TypedProgram proven without external parsed_ast input.

Slice C — ✅ CLOSED
  stdlib_execution_kernel_stage1 PASS.
  Proven: integer/float/decimal.add, fold, map, filter, count, or_else.
  Proven: stdlib.numeric.add rejected at runtime (pre-resolution boundary enforced).
```

---

## Agent Routing

```text
[Research Agent]            → Slice A (assembler — now unblocked) → Slice B (typechecker boundary)
[Compiler/Grammar Expert]  → spec reviews only (PROP-021 already written)
[Igniter-Lang Meta Expert] → this file, meta-proposals, governance only

Do not start:
  ❌ new theoretical research
  ❌ Stage 2 PROP implementation
  ❌ new speculation tracks
  ❌ playground expansion

Do start:
  ✅ Slice A assembler (top priority — unblocked)
  ✅ Slice B typechecker boundary (parallel)
```

---

## Key Decisions (compact)

```text
[D] CORE/ESCAPE/OOF is the trust boundary (PROP-003)
[D] SemanticIR is the stable compiler boundary (PROP-019.1)
[D] CompilationReport is always written; SemanticIRProgram only on success
[D] oof_log is REMOVED from SemanticIRProgram — OOF lives in CompilationReport only
[D] Assembler reads CompilationReport.semantic_ir_ref to locate artifact
[D] stdlib.numeric.add is a pre-resolution name — must be monomorphic in SemanticIR
[D] TypeChecker is Pass 1; operates on ClassifiedAST from Pass 0 (classifier)
[D] RuntimeMachine.load(path) → trusted CompatibilityReport (proven)
```

---

## Verification Commands

```bash
# Parser
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/availability_projection.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/polymorphic_add.ig

# Classifier
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb

# TypeChecker (PASS)
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb

# SemanticIR Emitter (run after Slice 0 golden file migration)
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
```

---

## Stage 2 Deferred (do not implement)

The following are formally specified but blocked until Stage 1 closes:

```text
History[T] / BiHistory[T]   → PROP-022 authored, implementation deferred
stream T / fold_stream       → PROP-023 authored, implementation deferred
OLAPPoint[T, Dims]           → PROP-024 authored, implementation deferred
Invariant severity levels    → PROP-025 authored, implementation deferred

~T probabilistic types       → PROP-026 queued
Deadline contracts           → PROP-027 queued
Unit algebra                 → PROP-028 queued
Plastic Runtime Cells        → PROP-029 queued
Rule synthesis               → PROP-030 queued
```

Reference: [language-spec.md §12](language-spec.md) for full roadmap.
Reference: [META-EXPERT-006](meta-proposals/META-EXPERT-006-language-model-revision-v0.md) for design decisions.

---

## Proposal Lifecycle

```
proposal (authored in proposals/)
  → verification (experiment proves the spec — reports here)
  → approval (Meta Expert + Architect review)
  → spec chapter (extracted into docs/spec/chN)
  → implementation (compiler pass or RuntimeMachine feature)
```

Current state:
- proposals/ is the **active intake** during Stage 1
- Proposals 001–025 are authored; some proven, some pending
- docs/spec/ chapters extract the accepted decisions in readable form
- proposals/ remain authoritative — spec does not replace them

---

## After Stage 1: Docs Reset Plan

When Stage 1 closes (source.ig → .igapp/ → RuntimeMachine trusted, end-to-end):

```
Step 1: Freeze accepted Stage 1 PROPs
  Move PROP-001..021 + errata to docs/proposals/accepted/
  These are read-only historical decisions.
  New proposals continue from docs/proposals/ (intake for Stage 2+).

Step 2: Take Stage 1 close snapshot
  docs/archive/snapshots/YYYY-MM-DD-stage1-close/
  Same process as 2026-05-06-stage1-pre-crystallization.

Step 3: Update docs/spec/ chapters
  Ch1–Ch8 statuses change from ⊠️ partial / ⚠️ gap to ✅ fully proven.
  Ch9 Stage 2 reserved becomes the new active intake.

Step 4: Open Stage 2 governance
  New meta-proposal: META-EXPERT-007-stage2-implementation-governance-v0
  Stage 2 scoreboard: History[T], stream T, OLAPPoint, invariant severity.
  Same pipeline discipline as META-EXPERT-003.

Step 5: Archive Stage 2 design PROPs
  PROP-022–025 move to docs/proposals/ (active, not yet accepted).
  New Stage 2 implementation PROPs begin from PROP-026+.
```

**Do not do any of this until Stage 1 is closed.**
Stage 1 close criteria: RuntimeMachine.evaluate(assembled_add.igapp, inputs) → correct output, end-to-end.
