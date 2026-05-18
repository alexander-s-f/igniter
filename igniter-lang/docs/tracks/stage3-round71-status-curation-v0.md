# S3 Round 71 Status Curation

Card: S3-R71-C4-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round71-status-curation-v0
Status: done
Date: 2026-05-18

---

## Evidence Read

- `docs/cards/S3/S3-R71.md`
- `docs/org/indexes/prop038-contract-digest-report-only-integration-boundary-map-v0.md`
- `docs/tracks/prop038-contract-digest-report-only-integration-proof-v0.md`
- `docs/discussions/prop038-contract-digest-report-only-integration-proof-pressure-v0.md`
- `docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md`
- `docs/tracks/stage3-round70-status-curation-v0.md`

---

## R71 Result

R71 accepts the proof-local PROP-038 `contract_digest` report-only integration
proof.

Accepted proof result:

- 12 required report-only integration cases PASS;
- 21 checks PASS;
- failed checks `[]`;
- R70 recompute-match proof remains PASS;
- R69 shape-policy proof remains PASS;
- R67 report-only integration remains PASS;
- existing 13-case validator matrix remains PASS;
- live validator still has no `contract_digest_*` behavior;
- `compile_refusal_authorized=false` remains true for proof-local, live
  validator, and report-only integration paths.

All four digest diagnostic candidates flow through nested validation diagnostics:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

The diagnostics remain under:

```text
compiler_profile_contract_validation.diagnostics
```

Top-level diagnostics, `pass_result`, stages, compile status, public result,
assembler execution, `.igapp` manifest, and refusal-report behavior remain
unchanged. Nil and exception provider paths preserve legacy/no-field behavior.

R70 NB-1 is closed: R71 summary restores the structured
`non_authorizations_preserved` block.

---

## Decision State

C3-A accepts the proof-local three-phase digest chain as complete for design
purposes:

| Phase | Round | Result |
| --- | --- | --- |
| Shape policy | R69 | 8 cases / 19 checks PASS |
| Recompute and canonicalization | R70 | 14 cases / 15 checks PASS |
| Report-only integration | R71 | 12 cases / 21 checks PASS |

This chain is sufficient to open PROP-038 errata/design authoring.

This chain is not implementation authorization.

---

## Preserved Boundaries

R71 does not authorize:

- live validator/compiler implementation;
- compiler/orchestrator integration changes;
- compile refusal;
- public API or CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- dispatch migration;
- RuntimeMachine, Gate 3 widening, runtime, or production behavior.

Live implementation design does not open next. It may be considered only after
PROP-038 errata/design text is authored and reviewed.

---

## Updated Maps

- `docs/current-status.md`
- `docs/tracks/README.md`
- `docs/gates/README.md`
- `docs/cards/S3/S3-R71.md`
- `docs/cards/S3/S3.md`
- `docs/proposals/README.md`

`docs/discussions/README.md` already contained the R71 pressure-review row and
did not require a curation edit.

---

## R72 Recommendation

Route only the PROP-038 errata/design authoring track authorized by C3-A:

```text
Card: S3-R72-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop038-contract-digest-errata-authoring-v0
```

Allowed:

- update or draft PROP-038 errata/design text;
- cite R69/R70/R71 proof summaries and gate decisions;
- define diagnostic vocabulary and report-only placement;
- describe canonicalization/recompute policy as design language.

Not allowed:

- code implementation;
- live validator/compiler behavior;
- compile refusal;
- public API/CLI widening;
- `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.
