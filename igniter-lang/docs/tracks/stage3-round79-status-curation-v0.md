# S3 Round 79 Status Curation

Card: S3-R79-C5-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round79-status-curation-v0
Status: done
Date: 2026-05-19

---

## Evidence Read

- `igniter-lang/docs/cards/S3/S3-R79.md`
- `igniter-lang/docs/org/indexes/prop038-internal-strict-source-status-orientation-map-v0.md`
- `igniter-lang/docs/tracks/internal-orchestrator-strict-source-and-status-design-v0.md`
- `igniter-lang/docs/tracks/prop038-refusal-report-and-result-surface-survey-v0.md`
- `igniter-lang/docs/discussions/prop038-internal-strict-source-status-pressure-v0.md`
- `igniter-lang/docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md`

---

## R79 Result

R79 closes the PROP-038 internal orchestrator strict-source/status design lane.

S3-R79-C4-A accepts
`internal-orchestrator-strict-source-and-status-design-v0` with status
`accepted-design-implementation-held`.

Accepted state:

- internal orchestrator constructor option is accepted as design vocabulary and
  a future-source candidate only;
- the source is not exposed through `IgniterLang.compile(...)`, CLI, `bin/igc`,
  `.igapp`, manifest, loader/report, CompatibilityReport, environment, config,
  or defaults;
- `refused` remains a future live compiler status candidate only;
- `CompilerResult` remains unchanged;
- public result shape remains unchanged;
- persisted refusal reports and sidecars remain closed;
- new non-persisting strict refusal path is accepted only as the next design
  candidate;
- malformed strict requirement policy remains open before implementation.

Current live behavior remains report-only. Live compile refusal remains closed.

---

## Pressure Notes

C3-X verdict: `proceed`.

- 11/11 scope checks pass.
- No blockers.
- NB-1 routes two proof requirements into the next design route:
  `public_result` key-set assertion and nested-diagnostics isolation assertion.
- C4-A confirms malformed strict requirement policy remains open and must be
  decided before implementation authorization.

---

## Preserved Closed Surfaces

R79 does not authorize:

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

No implementation card may open directly from R79.

---

## Updated Maps

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/gates/README.md`
- `igniter-lang/docs/cards/S3/S3-R79.md`
- `igniter-lang/docs/cards/S3/S3.md`
- `igniter-lang/docs/proposals/README.md`

`igniter-lang/docs/discussions/README.md` already indexed the R79 pressure
discussion and did not require a semantic update.

---

## R80 Recommendation

Open only the design route authorized by S3-R79-C4-A:

```text
Card: S3-R80-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: strict-refusal-result-shape-and-nonpersisting-path-design-v0
```

Recommended goal: design the strict-refusal result shape and non-persisting
orchestrator path for a possible future PROP-038 live refusal implementation,
without authorizing implementation.

Allowed:

- design strict-refusal result/status shape;
- design the non-persisting orchestrator refusal path as a future candidate;
- decide malformed strict requirement policy;
- define public result key-set behavior;
- define nested vs public diagnostic exposure;
- preserve current report-only behavior;
- preserve legacy/no-source/no-refusal behavior;
- preserve `report_for_assembly` and `.igapp` boundaries;
- refine proof/regression requirements, including:
  - `public_result` key-set assertion;
  - nested-diagnostics isolation assertion;
  - existing proof chain;
  - no persisted report/sidecar assertion if non-persisting path remains
    preferred;
  - no public API/CLI widening assertion;
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
