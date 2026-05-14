# Igniter-Lang — Documentation

Stage 1 status: **CLOSED** (2026-05-06) — [META-EXPERT-007](meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md)
Stage 2 status: **CLOSED** (2026-05-07) — [META-EXPERT-009.1](meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md)
Stage 3 status: **OPEN** (2026-05-08) — [META-EXPERT-011](meta-proposals/META-EXPERT-011-stage3-governance-opening-v0.md)
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-09

---

## Navigation

```
Agent current context       → agent-context.md  (read this first for current horizon + proof budget)
Hoisted value index         → value-index.md  (durable ideas + links back to archaeology)
Language reference             → language-spec.md
Ruby API facade                → ruby-api.md
Operating model                → operating-model.md
Operating scheduler            → operating-scheduler.md
Documentation metabolism       → dev/documentation-metabolism.md
Line Up summaries              → lineups/README.md
Agent orchestra pattern         → agent-orchestra-pattern.md
Language spec (ch1–ch9 accepted, ch10–ch13 proposed) → spec/
Language covenant              → language-covenant.md
Spec extension gap analysis    → spec-extension-gap-analysis.md
External pressure specimens    → experiments/external_pressure_specimens/
Current scoreboard             → current-status.md
Track index                    → tracks/README.md
Inbox / intake queue           → inbox/README.md
Discussion format             → discussions/README.md
Proposal queue                 → proposals/README.md
Accepted Stage 1 PROPs         → proposals/accepted/  (read-only)
Governance                     → meta-proposals/README.md
Human-agent vision            → meta-proposals/META-EXPERT-010-human-agent-symbiosis-vision-v0.md
External/cross-agent reviews   → reviews/README.md
Stage 1 close snapshot         → archive/snapshots/2026-05-06-stage1-close/
Pre-crystallization archive    → archive/snapshots/2026-05-06-stage1-pre-crystallization/
Stage 3 R7 docs snapshot       → archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/
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

## Stage 2 — CLOSED / Stage 3 Intake

Stage 2 closed on 2026-05-07. This section is retained as the Stage 2 baseline
navigation; current work should start from `agent-context.md` and
`current-status.md`.

Active intake baseline (Stage 3 proposal work starts from PROP-028):

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
| [agent-context.md](agent-context.md) | Trusted current-context capsule: current horizon, source-of-truth hierarchy, active gates, proof/test budget |
| [value-index.md](value-index.md) | Hoisted durable ideas by category, with links back to tracks/discussions/archive |
| [current-status.md](current-status.md) | Scoreboard (Stage 1 closed state) |
| [operating-model.md](operating-model.md) | Supervisor-owned agent/documentation flow |
| [operating-scheduler.md](operating-scheduler.md) | Recurring per-round/per-stage checklist and onboarding-card refresh cadence |
| [dev/documentation-metabolism.md](dev/documentation-metabolism.md) | Fate/movement/summary pipeline for bulky docs: Archive/Form, History Curator, Line Up Summarizer |
| [lineups/README.md](lineups/README.md) | Compact memory-card index for bulky documents and pressure/history sources |
| [agent-orchestra-pattern.md](agent-orchestra-pattern.md) | Pattern for bringing agents into the shared work through role, context, card, lens, authority, and route |
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

docs/archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/
  Working-memory safety snapshot after Stage 3 Round 7, before value-hoisting/compaction
```
