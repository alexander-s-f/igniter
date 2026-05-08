# Igniter-Lang — Documentation

Stage 1 status: **CLOSED** (2026-05-06) — [META-EXPERT-007](meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md)
Stage 2 status: **OPEN** (2026-05-06) — [META-EXPERT-008](meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md)
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-07

---

## Navigation

```
Language reference             → language-spec.md
Operating model                → operating-model.md
Stage 1 spec (frozen)          → spec/  (ch1–ch9)
Current scoreboard             → current-status.md
Track index                    → tracks/README.md
Discussion format             → discussions/README.md
Stage 2 active proposals       → proposals/README.md  (PROP-022..027, new from PROP-028)
Accepted Stage 1 PROPs         → proposals/accepted/  (read-only)
Governance                     → meta-proposals/README.md
Human-agent vision            → meta-proposals/META-EXPERT-010-human-agent-symbiosis-vision-v0.md
External/cross-agent reviews   → reviews/README.md
Stage 1 close snapshot         → archive/snapshots/2026-05-06-stage1-close/
Pre-crystallization archive    → archive/snapshots/2026-05-06-stage1-pre-crystallization/
```

---

## Stage 1 — CLOSED

Goal was: `source.ig → parser → classifier → typechecker → SemanticIR → .igapp/ → RuntimeMachine trusted`

```
Pass               Status      Experiment
─────────────────────────────────────────────────────────────────────────────────
Parser             ✅ partial  experiments/parser/ (61 specs; OOF parse gap — non-blocking)
Classifier         ✅ PASS     experiments/classifier_pass_proof/
SemanticIR Emitter ✅ PASS     experiments/source_to_semanticir_fixture/ --check-golden
TypeChecker        ✅ PASS     experiments/typechecker_proof/ (incl. boundary fixture)
.igapp/ Assembler  ✅ PASS     experiments/igapp_assembler_proof/ (A1-A6 + runtime eval)
RuntimeMachine     ✅ proven   experiments/runtime_machine_memory_proof/
Stdlib execution   ✅ PASS     experiments/stdlib_execution_kernel_stage1/
─────────────────────────────────────────────────────────────────────────────────
STAGE 1 CLOSED:   YES — CLOSE WITH DEFERRED GAP (2026-05-06)
Close evidence:   experiments/stage1_close_candidate/stage1_close_candidate.json
Deferred gaps:    production compiler pkg
```

### Run the full Stage 1 proof suite

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

### Run individual experiments

```bash
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
ruby igniter-lang/experiments/stdlib_execution_kernel_stage1/stdlib_execution_kernel_stage1.rb
```

---

## Stage 2 — OPEN

Stage 2 is implementation-oriented. New work should preserve Stage 1 semantics
while moving proofs into reusable production package surfaces.

Active intake baseline (authors of new Stage 2 PROPs start from PROP-028):

| PROP | Topic |
|------|-------|
| [PROP-022](proposals/PROP-022-history-type-constructor-v0.md) | History[T] / BiHistory[T] |
| [PROP-023](proposals/PROP-023-stream-input-surface-v0.md) | stream T / fold_stream |
| [PROP-024](proposals/PROP-024-olap-point-primitive-v0.md) | OLAPPoint[T, Dims] |
| [PROP-025](proposals/PROP-025-invariant-severity-levels-v0.md) | Invariant severity levels |
| [PROP-026](proposals/PROP-026-parser-oof-hardening-spec-v0.md) | Parser OOF hardening (PASS) |
| [PROP-027](proposals/PROP-027-production-compiler-diagnostics-contract-v0.md) | Production compiler diagnostics contract |

Current priority:

```text
Production compiler line
  -> keep IgniterLang.compile(...) as the public facade over CompilerOrchestrator
  -> extract reusable RuntimeSmoke
  -> prove package-level load path + bin/CLI entrypoint

Stage 2 surface line
  -> OLAP/stream/invariant compile-time SemanticIR lowering PASS
  -> preserve proven OOF boundaries and diagnostics
  -> defer runtime invariant_violation_node observations to a runtime slice

Runtime bridge line
  -> start descriptor-first LedgerTBackendAdapterDescriptor metadata work
  -> bind RuntimeMachine temporal access only after adapter evidence is approved
```

Current proof commands:

```bash
igniter-lang/bin/igniter-lang compile igniter-lang/experiments/source_to_semanticir_fixture/add.ig --out /tmp/igniter_lang_cli_report_add.igapp
ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb
ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
```

---

## Governance

| Document | Purpose |
|----------|---------|
| [current-status.md](current-status.md) | Scoreboard (Stage 1 closed state) |
| [operating-model.md](operating-model.md) | Supervisor-owned agent/documentation flow |
| [discussions/README.md](discussions/README.md) | Bounded debate format before proposal/track routing |
| [reviews/README.md](reviews/README.md) | External and cross-agent review signals before proposal/track routing |
| [meta-proposals/META-EXPERT-007](meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md) | Stage 1 close verdict |
| [meta-proposals/META-EXPERT-007.1](meta-proposals/META-EXPERT-007.1-stage1-close-snapshot-plan-v0.md) | Post-close doc transition plan |
| [meta-proposals/META-EXPERT-008](meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md) | Stage 2 implementation governance |
| [meta-proposals/META-EXPERT-003](meta-proposals/META-EXPERT-003-stage1-implementation-governance-v0.md) | Stage 1 policy (historical) |

---

## Archive

```
docs/archive/snapshots/2026-05-06-stage1-close/
  Full documentation state at Stage 1 close (proposals, spec, meta-proposals, status)

docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/
  Pre-crystallization research archive (131 files: tracks, proposals, bridge, meta-proposals)
```
