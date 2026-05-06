# Igniter-Lang Current Status — Stage 1

Status: active scoreboard
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-06
Policy: `META-EXPERT-003-stage1-implementation-governance-v0.md`

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
(canonical envelope)   PROP-019.1        semanticir_fixture/                  ⚠️  needs
                       (errata)          add, claim_evidence,                PROP-019.1
                                         evidence_linked_alert → PASS        migration

TypeChecker            PROP-021          no proof yet                        🟡 next proof
                                         structural types: partial
                                         trait resolution: missing
                                         monomorphization: missing

.igapp/ Assembler      PROP-012 +        no experiment yet                   🔴 BLOCKED
                       PROP-019.1                                              waiting on
                       (A1-A6 criteria)                                        Slice 0

RuntimeMachine Load    PROP-011          experiments/runtime_machine_        ✅ proven
                                         memory_proof/
                                         load → evaluate → checkpoint →
                                         resume → trusted

Stdlib execution       PROP-013          no experiment yet                   🔴 not started
                                         numeric.add, fold, map,
                                         filter, count, or_else missing
──────────────────────────────────────────────────────────────────────────────────────
STAGE 1 CLOSED:   NO
Active blocker:   PROP-019.1 golden migration → TypeChecker → .igapp/ Assembler
                  Stdlib execution kernel
```

---

## Active Blocker: PROP-019.1 Migration Gate

The `.igapp/` assembler must NOT start until:

```text
1. source_to_semanticir_fixture golden files migrated:
   - oof_log removed from SemanticIRProgram (top-level + ContractIR)
   - compilation_report_ref added to SemanticIRProgram
   - companion *.compilation_report.json created per fixture
   - negative fixtures: *.semantic_ir.json → removed;
     only *.compilation_report.json with pass_result: "oof"

2. source_to_semanticir_fixture.rb PASSES on migrated files.

3. stdlib.numeric.add → stdlib.integer.add resolved in golden SemanticIR.

Gate: source_to_semanticir_fixture.rb PASS on migrated files → Slice A unlocked.
```

---

## Next 3 Slices

```text
Slice 0 — Research Agent [PREREQUISITE]
  Migrate source_to_semanticir_fixture golden files to PROP-019.1 shape.
  Done when: source_to_semanticir_fixture.rb PASS on migrated files.

Slice A — Research Agent [blocked on Slice 0]
  Implement experiments/igapp_assembler_proof/igapp_assembler_proof.rb
  Input:  CompilationReport + SemanticIRProgram (from migrated golden files)
  Output: .igapp/ directory per PROP-019.1 §Part 7 (criteria A1..A6)
  Negative: assembler given pass_result:"oof" → refuses, exit != 0
  Done when: RuntimeMachine.load(assembled_add.igapp) → trusted CompatibilityReport

Slice B — split ownership [parallel with Slice A]
  [Compiler/Grammar Expert]: PROP-021 narrow TypeChecker spec
    Scope: annotation-driven resolution, trait constraint check,
           monomorphization (Add[Integer], Add[Float]), OOF-P1 for
           unresolved overloads. Not full PROP-004.
  [Research Agent]: typechecker_proof.rb after PROP-021
    Input:  ClassifiedProgram JSON (from classifier golden files)
    Output: TypedProgram JSON — resolved types, no unresolved T
    Negatives: Add[String] → OOF-TY1; unresolved overload → OOF-P1
  Done when: TypedProgram matches PROP-021 spec; all negatives blocked.

Slice C — Research Agent [parallel, independent]
  stdlib_execution_proof: numeric.add, fold, map, filter, count, or_else
  Done when: RuntimeMachine evaluates add.igapp with stdlib operators.
```

---

## Agent Routing

```text
[Research Agent]            → Slice 0 (golden migration) → Slice A (assembler) → Slice C (stdlib)
[Compiler/Grammar Expert]  → Slice B TypeChecker spec (PROP-021 refinement)
[Igniter-Lang Meta Expert] → this file, meta-proposals, governance only

Do not start:
  ❌ new theoretical research
  ❌ Stage 2 PROP implementation
  ❌ new speculation tracks
  ❌ playground expansion

Do start:
  ✅ Slice 0 migration (top priority)
  ✅ Slice B TypeChecker (parallel)
  ✅ Slice C stdlib (parallel)
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

# SemanticIR Emitter (after Slice 0 migration)
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
