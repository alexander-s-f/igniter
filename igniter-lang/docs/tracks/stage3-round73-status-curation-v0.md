# S3 Round 73 Status Curation

Card: S3-R73-C5-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round73-status-curation-v0
Status: done
Date: 2026-05-18

---

## Evidence Read

- `docs/cards/S3/S3-R73.md`
- `docs/org/indexes/prop038-contract-digest-live-design-boundary-map-v0.md`
- `docs/tracks/prop038-contract-digest-live-implementation-design-v0.md`
- `docs/tracks/prop038-contract-digest-live-implementation-surface-survey-v0.md`
- `docs/discussions/prop038-contract-digest-live-implementation-design-pressure-v0.md`
- `docs/gates/prop038-contract-digest-live-implementation-design-decision-v0.md`
- `docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md`
- `docs/tracks/stage3-round72-status-curation-v0.md`

---

## R73 Result

R73 accepts the PROP-038 `contract_digest` live validator implementation design.

Accepted design state:

- implementation shape is one bounded internal validator slice;
- implementation owner is `IgniterLang::CompilerProfileContractValidator`;
- validator API remains `validate(contract, digest_reference_policy:
  :prop038_24_plus)`;
- validator result shape remains existing fields only;
- canonicalization helpers remain private implementation details inside the
  validator;
- report-only/no-refusal behavior remains mandatory.

C3-X verdict is `proceed` with no blockers and two non-blocking notes. C4-A
closes both notes:

- NB-1: helper names are private implementation detail, not authority;
- NB-2: all three digest proof directories are explicitly included in the next
  implementation write scope.

---

## Decision State

C4-A authorizes the next route as one bounded internal validator implementation
card:

```text
prop038-contract-digest-live-validator-implementation-v0
```

This authorization is narrow. It permits implementation of the four accepted
`contract_digest_*` diagnostics inside
`IgniterLang::CompilerProfileContractValidator` only, plus proof updates needed
to verify live parity and report-only invariants.

---

## Preserved Boundaries

R73 does not authorize:

- compiler/orchestrator integration;
- compile refusal;
- public API or CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- dispatch migration;
- RuntimeMachine, Gate 3 widening, runtime, or production behavior.

---

## Updated Maps

- `docs/current-status.md`
- `docs/tracks/README.md`
- `docs/gates/README.md`
- `docs/cards/S3/S3-R73.md`
- `docs/cards/S3/S3.md`
- `docs/proposals/README.md`

`docs/discussions/README.md` already contained the R73 pressure-review row and
did not require a curation edit.

---

## R74 Recommendation

Route only the bounded internal validator implementation authorized by C4-A:

```text
Card: S3-R74-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop038-contract-digest-live-validator-implementation-v0
```

Allowed:

- edit only the C4-A authorized write scope;
- implement all four accepted PROP-038 `contract_digest` diagnostics inside
  `IgniterLang::CompilerProfileContractValidator`;
- keep validator API unchanged;
- keep validator result shape unchanged;
- add private canonicalization helpers;
- add `require "digest"` and `require "json"` if needed;
- update authorized proof scripts and summaries;
- produce a track doc and command matrix.

Not allowed:

- compiler/orchestrator integration;
- compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.
