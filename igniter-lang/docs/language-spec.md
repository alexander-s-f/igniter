# Igniter-Lang Language Specification (Index)

Version: 0.3 — crystallized from Stage 1 PROPs
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-06

> **The spec is now structured as chapters in `docs/spec/`.**
> This file is the entry-point index.

---

## Chapters

| # | Chapter | PROP Sources | Status |
|---|---------|-------------|--------|
| [Ch1](spec/ch1-identity.md) | Identity and Semantic Model | PROP-001 | accepted |
| [Ch2](spec/ch2-source-surface.md) | Source Surface and Grammar | PROP-014, 015 | accepted / OOF gap |
| [Ch3](spec/ch3-type-system.md) | Type System | PROP-004, 021 | ✅ PASS ⚠️ self-contained gap |
| [Ch4](spec/ch4-fragment-classification.md) | Fragment Classification | PROP-003, 020 | ✅ PASS |
| [Ch5](spec/ch5-compiler-pipeline.md) | Compiler Pipeline | PROP-018, 019.1 | accepted / assembler blocked |
| [Ch6](spec/ch6-semanticir.md) | SemanticIR and CompilationReport | PROP-019.1 | ✅ PASS ⚠️ migration needed |
| [Ch7](spec/ch7-runtime.md) | RuntimeMachine | PROP-006, 009, 011 | accepted + proven ✅ |
| [Ch8](spec/ch8-stdlib.md) | Stdlib | PROP-013 | accepted / proof pending |
| [Ch9](spec/ch9-stage2-reserved.md) | Stage 2 Reserved Primitives | PROP-022–025 | deferred |

---

## Coverage Summary

```
accepted + PASS           Ch4 (classifier), Ch7 (RuntimeMachine), Ch8 (stdlib kernel)
accepted + PASS ⚠️ gap   Ch3 (TypeChecker PASS — Slice B closes boundary gap),
                          Ch6 (SemanticIR + golden check PASS)
accepted / partial        Ch2 (OOF parse gap), Ch5 (assembler — Slice A unblocked)
deferred                  Ch9 (Stage 2: History, stream, OLAPPoint, severity)
```

---

## Stage 1 Implementation Gaps

```
1.  OOF rejection at parse time (Ch2)    — parser gap (no slice assigned)
2.  TypeChecker boundary fixture (Ch3)   — Slice B: standalone ClassifiedProgram → TypedProgram
                                           (proof exists; gap = uses classifier_pass_proof/golden)
3.  .igapp/ Assembler (Ch6)              — Slice A (Slice 0 complete; now unblocked)
```

→ See `docs/current-status.md` for scoreboard and next slices.
→ See `docs/proposals/` for canonical PROP decision records.
→ See `docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/` for full history.
