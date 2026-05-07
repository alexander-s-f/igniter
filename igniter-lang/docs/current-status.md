# Igniter-Lang Current Status

Stage 1: **CLOSED** (2026-05-06) — META-EXPERT-007
Stage 2: **OPEN** (2026-05-06) — META-EXPERT-008
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-06
Policy: `META-EXPERT-008-stage2-implementation-governance-v0.md`
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
(boundary fixture)                        boundary.classified_program_         ✅ boundary
                                         input_only: ok                         CLOSED
                                         own classified/ dir; no external       (Slice B)
                                         golden dir dependency

.igapp/ Assembler      PROP-012 +        experiments/igapp_assembler_        ✅ PASS
(A1-A6)                PROP-019.1        proof/                               A1-A6 all ok
                       (A1-A6 criteria)  3 positive + 3 negative + runtime    runtime.load:
                                         load/evaluate/trusted                 loaded
                                                                               runtime.evaluate:
                                                                               trusted ✓

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
STAGE 1 CLOSED:   YES — CLOSE WITH DEFERRED GAP
                  Effective: 2026-05-06
                  Verdict: META-EXPERT-007-stage1-close-governance-v0
Deferred gaps:    production compiler pkg
Closed post-close: Parser OOF hardening (Stage 2 proof) | runtime eval surface
All proofs:       Classifier Emitter TypeChecker Assembler RuntimeMachine Stdlib ✅
```

---

## Stage 1 Deferred Gaps Status

All major Stage 1 proofs are PASS. Deferred gaps are now tracked by Stage 2:

```text
OOF rejection at parse time:
  CLOSED in Stage 2 proof.
  Syntax-owned OOF now rejects at parser.
  Semantic OOF remains owned by Classifier / TypeChecker.

Production compiler package:
  OPEN.
  Proof chain exists; CLI/package extraction not yet implemented.
```

---

## Next 3 Slices

```text
Slice 0 — ✅ CLOSED
  source_to_semanticir_fixture --check-golden PASS.
  Negative cases: *.semantic_ir.json absent. CompilationReport artifacts present.

Slice A — ✅ CLOSED
  igapp_assembler_proof PASS.
  3 positive (add, claim_evidence, evidence_linked_alert): assembled → loaded → evaluated → trusted.
  3 negative (OOF inputs): assembler refuses, exit != 0.
  RuntimeMachine.load(assembled_add.igapp) → trusted CompatibilityReport ✓

Slice B — ✅ CLOSED
  typechecker_proof boundary fixture PASS.
  boundary.classified_program_input_only: ok
  TypeChecker now reads from own classified/ dir; no external golden dependency.

Slice C — ✅ CLOSED
  stdlib_execution_kernel_stage1 PASS.
  Proven: integer/float/decimal.add, fold, map, filter, count, or_else.
  Proven: stdlib.numeric.add rejected at runtime (pre-resolution boundary enforced).

Remaining (non-blocking):
  Parser OOF rejection at parse time — will be addressed in grammar hardening pass.
```

---

## Agent Routing

```text
[Research Agent]            → all slices CLOSED; await Stage 2 governance
[Compiler/Grammar Expert]  → spec reviews only (PROP-021 already written)
[Igniter-Lang Meta Expert] → this file, meta-proposals, governance only

Do not start:
  ❌ new theoretical research
  ❌ Stage 2 PROP implementation
  ❌ new speculation tracks
  ❌ playground expansion

Do start:
  ✅ Stage 1 close validation (run all experiments, confirm end-to-end)
  ✅ After Stage 1 close: open Stage 2 governance (META-EXPERT-007)
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

# TypeChecker (PASS — boundary fixture included)
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb

# SemanticIR Emitter + golden check
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden

# .igapp/ Assembler (PASS)
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb

# Stdlib execution kernel (PASS)
ruby igniter-lang/experiments/stdlib_execution_kernel_stage1/stdlib_execution_kernel_stage1.rb
```

---

## Stage 2 Intake

The following are Stage 2 active or queued items:

```text
History[T] / BiHistory[T]   → PROP-022 authored, pending proof
stream T / fold_stream       → PROP-023 authored, pending proof
OLAPPoint[T, Dims]           → PROP-024 authored, pending proof
Invariant severity levels    → PROP-025 authored, pending proof
Parser OOF hardening         → PROP-026 authored, proof PASS

~T probabilistic types       → PROP-027 queued
Deadline contracts           → PROP-028 queued
Unit algebra                 → PROP-029 queued
Plastic Runtime Cells        → PROP-030 queued
Rule synthesis               → PROP-031 queued
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
  New Stage 2 implementation PROPs begin from PROP-027+.
```

**Do not do any of this until Stage 1 is closed.**
Stage 1 close criteria: RuntimeMachine.evaluate(assembled_add.igapp, inputs) → correct output, end-to-end.

---

## Stage 2 Scoreboard — 2026-05-06

```text
Pass/Feature           PROP(s)       Experiment                        Status
──────────────────────────────────────────────────────────────────────────────
Parser OOF hardening   PROP-026      parser_oof_hardening_             ✅ PASS
                                     stage2_proof/
Production compiler    PROP-022A     no package yet                    ⏳ deferred gap
Runtime eval surface   —             igapp_assembler_proof/            ✅ closed_in_proof
                                     evaluates Add, ClaimEvidenceBundle,  (all 3 contracts)
                                     EvidenceLinkedAlertGate → trusted
History[T]             PROP-022      no experiment yet                 🔵 authored
stream T               PROP-023      no experiment yet                 🔵 authored
OLAPPoint[T,Dims]      PROP-024      no experiment yet                 🔵 authored
Invariant severity     PROP-025      no experiment yet                 🔵 authored
──────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  Deferred Gap B (production compiler) → Tier 1 proofs
Governance:       META-EXPERT-008
New PROPs:        start from PROP-027
```

→ See `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md` for
  full dependency order, done criteria, agent routing, and close conditions.
