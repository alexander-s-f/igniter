# S3 Round 78 Status Curation

Card: S3-R78-C5-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round78-status-curation-v0
Status: done
Date: 2026-05-19

---

## Evidence Read

- `igniter-lang/docs/cards/S3/S3-R78.md`
- `igniter-lang/docs/org/indexes/prop038-live-refusal-boundary-design-orientation-map-v0.md`
- `igniter-lang/docs/tracks/prop038-live-refusal-implementation-boundary-design-v0.md`
- `igniter-lang/docs/tracks/prop038-live-refusal-current-pipeline-surface-survey-v0.md`
- `igniter-lang/docs/discussions/prop038-live-refusal-boundary-design-pressure-v0.md`
- `igniter-lang/docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md`
- `igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round77-status-curation-v0.md`

---

## R78 Result

R78 closes the PROP-038 live-refusal boundary design lane.

S3-R78-C4-A accepts
`prop038-live-refusal-implementation-boundary-design-v0` with status
`accepted-boundary-design-implementation-held`.

Accepted state:

- boundary design accepted;
- implementation held;
- live compile refusal closed;
- report-only remains current live behavior;
- no live strict source implemented or fully chosen;
- internal orchestrator option accepted only as first source candidate to design
  next;
- `would_refuse` may graduate to live `refused` only behind a separate live
  implementation gate.

R78 does not authorize:

- code implementation;
- live compiler/orchestrator behavior changes;
- live compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted reports or sidecars;
- parser, TypeChecker, SemanticIR;
- assembler or `.igapp` mutation;
- loader/report;
- CompatibilityReport;
- diagnostics centralization;
- dispatch migration;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, runtime, or production
  behavior.

---

## Pressure Notes

C3-X verdict: `proceed`.

- 8/8 scope checks pass.
- No blockers.
- NB-1: `compile_refusal_authorized: true` appears for the first time only as a
  future live-refused design sketch. C4-A confirms current code and accepted
  proofs remain `false`.
- NB-2: C1-P1's "no persisted report" recommendation conflicts with the
  existing `CompilerOrchestrator#refusal` path, which writes a compilation
  report. C4-A routes this into the next design card before any implementation
  can be considered.

---

## Current Live Behavior

Current live behavior remains report-only:

- PROP-038 validation evidence is nested in in-memory `CompilationReport`.
- `pass_result`, stages, top-level diagnostics, public result, CLI output, and
  assembler input remain unchanged by contract validation.
- `report_for_assembly` remains a protected boundary.
- CLI has no strict/refusal flag.
- `CompilerResult` remains unchanged.
- Live `refused` status is absent.

---

## Updated Maps

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/gates/README.md`
- `igniter-lang/docs/cards/S3/S3-R78.md`
- `igniter-lang/docs/cards/S3/S3.md`
- `igniter-lang/docs/proposals/README.md`

`igniter-lang/docs/discussions/README.md` already indexed the R78 pressure
discussion and did not require a semantic update.

---

## R79 Recommendation

Open only the design route authorized by S3-R78-C4-A:

```text
Card: S3-R79-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: internal-orchestrator-strict-source-and-status-design-v0
```

Recommended goal: design the internal orchestrator strict source and status
boundary for a possible future PROP-038 live refusal implementation, resolving
the existing `#refusal` report-write tension before any implementation can be
considered.

Allowed:

- design the internal orchestrator strict source shape;
- decide where the source is supplied and validated inside the orchestrator;
- design status/result vocabulary for a possible live refused compile;
- decide whether future live refusal should reuse `CompilerOrchestrator#refusal`,
  use a new non-persisting refusal path, or require a distinct PROP-038 refusal
  report policy;
- preserve report-only behavior as current live behavior;
- preserve `report_for_assembly` and `.igapp` boundaries unless designing a
  future refused path that skips assembly;
- refine implementation proof/regression requirements;
- list exact blockers before implementation authorization.

Not allowed:

- code implementation;
- live compile refusal;
- compiler/orchestrator behavior changes;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`;
- loader/report, CompatibilityReport, diagnostics centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.
