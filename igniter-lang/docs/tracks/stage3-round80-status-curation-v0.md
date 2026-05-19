# S3 Round 80 Status Curation

Card: S3-R80-C5-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round80-status-curation-v0
Status: done
Date: 2026-05-19

---

## Evidence Read

- `igniter-lang/docs/cards/S3/S3-R80.md`
- `igniter-lang/docs/org/indexes/prop038-strict-refusal-result-shape-orientation-map-v0.md`
- `igniter-lang/docs/tracks/strict-refusal-result-shape-and-nonpersisting-path-design-v0.md`
- `igniter-lang/docs/tracks/prop038-public-result-and-diagnostics-proof-surface-survey-v0.md`
- `igniter-lang/docs/discussions/prop038-strict-refusal-result-shape-pressure-v0.md`
- `igniter-lang/docs/gates/prop038-strict-refusal-result-shape-decision-v0.md`

---

## R80 Result

R80 closes the PROP-038 strict-refusal result-shape and non-persisting path
design lane.

S3-R80-C4-A accepts
`strict-refusal-result-shape-and-nonpersisting-path-design-v0` with status
`accepted-design-proof-local-next-implementation-held`.

Accepted state:

- future `refused` status is accepted as design vocabulary and proof-local
  target shape only;
- malformed strict requirement policy is accepted at design/proof-local level as
  `configuration_error`;
- the strict-refusal public result key-set allowlist is accepted as design
  vocabulary;
- `compilation_report_path: null` is accepted as the non-persisting target shape
  convention;
- nested diagnostics isolation is accepted as design/proof-local policy;
- public wrapper diagnostic
  `compiler_profile_contract_refusal.contract_digest_mismatch` is accepted as
  design/proof-local vocabulary;
- the first future implementation candidate remains a non-persisting path, but
  implementation is not authorized.

Current live behavior remains report-only. Live compile refusal remains closed.

---

## Pressure Notes

C3-X verdict: `proceed`.

- 11/11 scope checks pass.
- No blockers.
- NB-1 resolved by C4-A: the future strict-refusal proof owns the
  strict-refusal public key-set assertion.
- NB-2 resolved by C4-A: `compilation_report_path` is present with `null` in
  the target non-persisting shape.
- C4-A carries forward that the malformed `configuration_error` target shape
  must be specified as concretely as the `refused` target before any live
  implementation authorization.

---

## Preserved Closed Surfaces

R80 does not authorize:

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
- `IgniterLang::Diagnostics` centralization;
- `.ilk`, receipts, or signing;
- dispatch migration;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, runtime, or production
  behavior.

No live implementation card may open directly from R80.

---

## Updated Maps

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/gates/README.md`
- `igniter-lang/docs/discussions/README.md`
- `igniter-lang/docs/cards/S3/S3-R80.md`
- `igniter-lang/docs/cards/S3/S3.md`
- `igniter-lang/docs/proposals/README.md`

---

## R81 Recommendation

Open only the proof-local route authorized by S3-R80-C4-A:

```text
Card: S3-R81-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: prop038-strict-refusal-result-shape-proof-local-v0
```

Recommended goal: build a proof-local strict-refusal result-shape experiment
that verifies the accepted R80 target shape without changing live
compiler/orchestrator behavior.

Allowed:

- work only under a new proof-local experiment directory;
- model strict-refusal target result shape;
- model malformed strict requirement `configuration_error` target shape;
- assert strict-refusal public key-set allowlist;
- assert `compilation_report_path` is present and null for the non-persisting
  target shape;
- assert nested diagnostics isolation;
- assert public wrapper diagnostic shape;
- assert no sidecar/report/artifact path is produced by the proof-local target;
- produce a JSON summary with pass/fail, cases, and command matrix.

Not allowed:

- live compiler/orchestrator code changes;
- live compile refusal;
- `CompilerResult` code changes;
- public API/CLI widening;
- persisted reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`;
- loader/report, CompatibilityReport, diagnostics centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.
