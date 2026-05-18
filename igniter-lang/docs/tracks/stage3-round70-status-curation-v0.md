# S3 Round 70 Status Curation

Card: S3-R70-C4-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round70-status-curation-v0
Status: done
Date: 2026-05-18

---

## Evidence Read

- `docs/cards/S3/S3-R70.md`
- `docs/org/indexes/prop038-contract-digest-recompute-proof-boundary-map-v0.md`
- `docs/tracks/prop038-contract-digest-recompute-match-proof-v0.md`
- `docs/discussions/prop038-contract-digest-recompute-match-proof-pressure-v0.md`
- `docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md`
- `docs/tracks/stage3-round69-status-curation-v0.md`

---

## R70 Result

R70 accepts the proof-local PROP-038 `contract_digest` recompute-match proof.

Accepted proof result:

- 14 required recompute/canonicalization cases PASS;
- 15 checks PASS;
- failed checks `[]`;
- R69 shape-policy proof remains PASS;
- existing 13-case validator matrix remains PASS;
- R67 report-only integration remains PASS;
- proof-local and live validator paths keep `compile_refusal_authorized=false`;
- no `.igapp` artifact or refusal report is created.

Canonicalization is accepted as stable enough for future design/proof:

- input is the contract object excluding `contract_digest`;
- 13 included fields remain the proof target;
- validation fields, report-only flags, provider metadata, source/out paths,
  parsed program, and compiler profile source transport are excluded;
- `descriptor_digest` is included only as a string field value;
- object keys, registries, rule lists, and edge sets are order-insensitive;
- `slot_order` remains order-sensitive.

The complete four-code `contract_digest_*` candidate set is now proof-covered
across R69/R70:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

The codes are not accepted for live validator implementation.

---

## Pressure Note

R70-C2-X verdict is proceed with one non-blocking note:

```text
NB-1: future proof summaries should restore the non_authorizations_preserved
dictionary for hold-inventory traceability.
```

C3-A accepts NB-1 as a future requirement, not as a blocker for R70 acceptance.

---

## Preserved Boundaries

R70 does not authorize:

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

Shape-policy plus recompute-match proof are enough to consider only a
proof-local report-only integration proof next. They are not implementation
authorization.

---

## Updated Maps

- `docs/current-status.md`
- `docs/tracks/README.md`
- `docs/gates/README.md`
- `docs/cards/S3/S3-R70.md`
- `docs/cards/S3/S3.md`
- `docs/proposals/README.md`

`docs/discussions/README.md` already contained the R70 pressure-review row and
did not require a curation edit.

---

## R71 Recommendation

Route only the proof-local report-only integration proof authorized by C3-A:

```text
Card: S3-R71-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: prop038-contract-digest-report-only-integration-proof-v0
```

Required boundary:

- proof-local integration model only;
- wire shape + recompute diagnostics through an experiment-local report-only
  validation result;
- prove mismatch still returns compile status `ok`;
- prove public result unchanged;
- prove no `.igapp` mutation and no refusal report;
- include `non_authorizations_preserved`;
- do not edit live validator/compiler/orchestrator code;
- do not widen public API/CLI, `CompilerResult`, loader/report,
  CompatibilityReport, RuntimeMachine, Gate 3, runtime, or production.
