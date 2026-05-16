# Track: PROP-038 Compiler Profile Contract Authoring v0

Card: S3-R61-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-compiler-profile-contract-authoring-v0`
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Meta Expert]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Author the new PROP-038 for `compiler_profile_contract` using accepted R57-R60
evidence, and sync the proposal index.

This is authoring-only. It does not edit code or experiments and does not
authorize implementation.

---

## Inputs Read

- `docs/gates/compiler-profile-contract-validator-coverage-decision-v0.md`
- `docs/tracks/compiler-profile-contract-validator-coverage-proof-v0.md`
- `docs/discussions/compiler-profile-contract-validator-coverage-pressure-v0.md`
- `docs/gates/compiler-profile-contract-prop-authoring-decision-v0.md`
- `docs/tracks/compiler-profile-contract-schema-and-rule-ownership-pressure-v0.md`
- `docs/discussions/compiler-profile-contract-schema-ownership-pressure-v0.md`
- `docs/gates/compiler-profile-contract-proof-decision-v0.md`
- `docs/tracks/compiler-profile-contract-proof-v0.md`
- `docs/proposals/README.md`

---

## Created

```text
docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

PROP-038 defines:

- status and scope;
- relationship to PROP-036 and PROP-037;
- `compiler_profile_contract` object schema;
- required and optional slot vocabulary;
- slot assignment semantics as declared compiler-understanding ownership;
- strict registry one-owner invariant;
- ordered-rule graph semantics;
- `stage` as informational metadata in v0;
- descriptor/finalization/contract digest semantics;
- `compiler_profile_contract.*` diagnostic vocabulary;
- separation from source, obligation, and loader/report vocabularies;
- future `profile_not_supplied` shape;
- progression metadata under `pipeline` for v0;
- non-authority language;
- contract refusal rules;
- proof evidence links;
- excluded surfaces;
- open questions and deferred implementation gates.

---

## Updated

```text
docs/proposals/README.md
```

Index changes:

- Added PROP-038 to Stage 3 Active as `authored-pending-review`.
- Assigned PROP-038 to `compiler_profile_contract`.
- Moved managed local recursion / loop-class placeholder to `PROP-039+`.
- Added PROP-038 lifecycle note preserving no implementation authorization.

---

## Authoring Decisions

### Ordered-Rule `stage`

Decision:

```text
stage is informational metadata in PROP-038 v0
```

Reason:

R60 did not validate `stage` values against a closed set. The accepted proof
uses `parse`, `classify`, `typecheck`, and `emit`, but the v0 contract must not
create a new unproven refusal path for unknown stage values.

Future work may promote `stage` to normative validated vocabulary after a
dedicated proof or implementation gate.

### Digest Formats

Decision:

```text
descriptor_digest: compiler_profile_descriptor/sha256:<24+ lowercase hex>
contract_digest:   compiler_profile_contract/sha256:<24+ lowercase hex>
finalization_payload_digest: sha256:<64 lowercase hex>
```

Reason:

This matches the accepted R60 proof and PROP-036 short content-addressed
reference style while making full 64-character SHA-256 references valid and
preferred for durable storage.

### Progression Slot

Decision:

```text
progression_descriptor remains under pipeline for v0
```

No dedicated `progression` slot is introduced or implied by PROP-038.

---

## Proof Evidence Used

PROP-038 cites:

- R57 contract boundary and decision;
- R58 contract proof, pressure, and decision;
- R59 schema/rule ownership pressure and pressure review;
- R60 validator coverage proof, pressure, and decision;
- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`.

Evidence claims are limited to proposal authoring readiness:

```text
PASS proof evidence != implementation readiness
```

---

## Remaining Review / Acceptance Questions

[Q] Should `stage` become normative validated vocabulary in a later version?

[Q] Should a future proof or implementation test add a missing-`after` direction
case for `missing_rule_reference`?

[Q] Should durable storage eventually require full 64-character digest references
for `descriptor_digest` and `contract_digest`?

[Q] If contract validation becomes persisted, where should the contract object
live: sidecar, receipt bundle, `.ilk`, or another artifact?

[Q] When, if ever, should PROP-037 receive a dedicated `progression` slot?

---

## Non-Authorization

This track does not authorize:

- implementation in production compiler paths;
- compile refusal based on contract validation or obligation coverage;
- parser changes;
- TypeChecker changes;
- SemanticIR changes;
- assembler or `.igapp` changes;
- CLI or Ruby API widening;
- profile discovery/defaulting/finalization in public surfaces;
- loader/report implementation or schema;
- CompatibilityReport implementation or schema;
- `.ilk`;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- dynamic pack loading;
- RuntimeMachine / Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP production execution;
- cache;
- production behavior.

---

## Handoff

```text
Card: S3-R61-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop038-compiler-profile-contract-authoring-v0
Status: done

[D] Decisions
- Authored PROP-038 for compiler_profile_contract.
- Indexed PROP-038 as authored-pending-review.
- Moved managed local recursion / loop-class placeholder to PROP-039+.
- Set ordered-rule stage as informational metadata for v0.
- Kept progression_descriptor under pipeline for v0.

[S] Signals
- R60 validator coverage was sufficient for proposal authoring.
- PROP-038 is broader than PROP-036 and therefore belongs as a new PROP, not an
  errata.
- Proof evidence supports authoring, not implementation readiness.

[T] Tests / Proofs
- Documentation-only authoring slice.
- No code or experiments edited.

[R] Recommendation
- Send PROP-038 to review/acceptance.
- Keep implementation held until a separate governance decision accepts the PROP
  and names an exact implementation write scope.

[Next]
- Review PROP-038 for acceptance questions around stage validation, digest
  storage strictness, contract persistence location, and progression slot
  timing.
```
