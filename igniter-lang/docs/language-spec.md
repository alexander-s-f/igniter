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
| [Ch3](spec/ch3-type-system.md) | Type System | PROP-004, 021 | accepted / proof pending |
| [Ch4](spec/ch4-fragment-classification.md) | Fragment Classification | PROP-003, 020 | accepted + PASS ✅ |
| [Ch5](spec/ch5-compiler-pipeline.md) | Compiler Pipeline | PROP-018, 019.1 | accepted / partial |
| [Ch6](spec/ch6-semanticir.md) | SemanticIR and CompilationReport | PROP-019.1 | accepted + PASS ✅ ⚠️ |
| [Ch7](spec/ch7-runtime.md) | RuntimeMachine | PROP-006, 009, 011 | accepted + proven ✅ |
| [Ch8](spec/ch8-stdlib.md) | Stdlib | PROP-013 | accepted / proof pending |
| [Ch9](spec/ch9-stage2-reserved.md) | Stage 2 Reserved Primitives | PROP-022–025 | deferred |

---

## Coverage Summary

```
accepted + PASS       Ch4 (classifier), Ch7 (RuntimeMachine load)
accepted + PASS ⚠️   Ch6 (SemanticIR — needs golden migration)
accepted, proof pending  Ch2 (OOF parse gap), Ch3 (typechecker), Ch5 (assembler), Ch8 (stdlib exec)
deferred              Ch9 (Stage 2: History, stream, OLAPPoint, severity)
```

---

## Stage 1 Implementation Gaps

```
1.  OOF rejection at parse time (Ch2)         — known parser gap
2.  TypeChecker proof (Ch3, Ch5)              — Slice B
3.  Golden file migration (Ch6)               — Slice 0 (active blocker)
4.  .igapp/ Assembler proof (Ch6)             — Slice A (blocked on Slice 0)
5.  Stdlib execution proof (Ch8)              — Slice C
```

→ See `docs/current-status.md` for scoreboard and next slices.
→ See `docs/proposals/` for canonical PROP decision records.
→ See `docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/` for full history.
