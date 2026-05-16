# Track: Compiler Profile Contract Boundary v0

Card: S3-R57-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `compiler-profile-contract-boundary-v0`
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Meta Expert]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design the compiler-profile contract boundary after the accepted R56 obligation
coverage proof, without authorizing implementation.

This is a design-only track. It does not implement code, mutate `.igapp`
artifacts or goldens, change CLI/API behavior, add loader/report behavior,
change CompatibilityReport, migrate dispatch, touch RuntimeMachine, or authorize
production behavior.

---

## Inputs Read

- `docs/gates/compiler-profile-obligation-coverage-proof-decision-v0.md`
- `docs/tracks/compiler-profile-obligation-coverage-proof-v0.md`
- `docs/discussions/compiler-profile-obligation-coverage-proof-pressure-v0.md`
- `docs/gates/compiler-profile-next-axis-decision-v0.md`
- `docs/tracks/compiler-profile-contract-formalization-options-v0.md`
- `docs/tracks/language-profile-compiler-obligation-map-v0.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `experiments/compiler_profile_obligation_coverage_proof/out/compiler_profile_obligation_coverage_summary.json`

---

## Accepted Starting Point

R56 accepted `CompilerProfileObligationReport` as proof-local, report-only, and
output-only.

Accepted status vocabulary:

```text
covered
missing_slot
unsupported_surface
profile_not_supplied
```

Accepted non-authority invariant:

```text
profile transport != profile coverage
profile coverage != runtime readiness
```

Accepted PROP-037 treatment:

```text
progression_descriptor remains under pipeline for v0
no progression slot is authorized
```

This track preserves that boundary.

---

## Boundary Diagram

```text
caller/facade/orchestrator input
  |
  | validates finalized source object shape
  v
compiler_profile_source.*
  |
  | provides profile_ref, slot_order, slot_assignments
  v
after SemanticIR emit / before assembly checkpoint
  |
  | compares detected surfaces to profile slots
  v
compiler_profile_obligation.*
  |
  | future proof-only / design-only strengthening
  v
compiler_profile_contract.*
  |
  | manifest/load interpretation, not compiler contract validation
  v
loader/report status vocabulary
```

Short form:

```text
source object validity -> obligation coverage report -> future contract validity
  -> manifest/load status
```

These are four different layers. They must not share refusal/status terms as if
they were the same decision.

---

## Vocabulary Boundary Table

| Vocabulary | Owner / layer | Primary question | Example terms | Current effect | Must not mean |
| --- | --- | --- | --- | --- | --- |
| `compiler_profile_source.*` | Caller/facade/orchestrator/assembler source path | Is the supplied finalized profile source object valid to transport? | `missing`, `malformed`, `wrong_kind`, `unfinalized`, `unsupported_namespace`, `malformed_id`, `id_digest_mismatch`, `slot_order_mismatch`, `runtime_authority_forbidden`, `dispatch_migration_forbidden`, `payload_id_inclusion_forbidden` | Existing assembler/facade path can refuse invalid source transport | Does not prove the profile covers program surfaces |
| `compiler_profile_obligation.*` | Report-only coverage checkpoint | Do detected program surfaces require slots missing from the supplied profile? | `covered`, `missing_slot`, `unsupported_surface`, `profile_not_supplied` | Proof-local report status only; no compile gate | Does not validate full contract schema, load manifests, or grant runtime readiness |
| `compiler_profile_contract.*` | Future semantic profile contract validator | Is the compiler-profile contract object internally valid? | `descriptor_missing`, `schema_mismatch`, `digest_mismatch`, `missing_required_slot`, `duplicate_strict_key`, `missing_rule_reference`, `rule_cycle`, `pack_missing` | Future proof/design vocabulary only | Does not replace source-object transport errors or loader status |
| Loader/report status vocabulary | Future manifest/load/report interpretation | How should a manifest `compiler_profile_id` be interpreted under rollout policy? | `absent_legacy`, `present_verified`, `mismatch`, `malformed`, `missing_required` | PROP-036 future loader/report language; not implemented here | Does not validate compiler slots/rules and does not imply runtime readiness |

---

## Required Near-Collision Comparison

| Term | Namespace | Meaning | Layer | Actionability |
| --- | --- | --- | --- | --- |
| `compiler_profile_obligation.missing_slot` | Obligation report | A program surface requires a slot not present in the supplied finalized profile source. | Post-SemanticIR coverage report | Report-only until a future enforcement card says otherwise. |
| `compiler_profile_contract.missing_required_slot` | Future contract validator | The contract object itself lacks a slot that the contract schema says every valid compiler profile must define. | Contract schema/semantic validation | Future contract refusal, after proof and authorization. |
| `missing_required` | Loader/report status | A manifest lacks `compiler_profile_id` under future `profile_required` policy. | Manifest load/report | Future loader/report refusal/status, not compiler obligation. |
| `compiler_profile_source.*` | Source transport validation | The caller-supplied finalized source object is absent, malformed, wrong kind, unfinalized, has digest mismatch, or attempts forbidden authority. | API/orchestrator/assembler input boundary | Existing/future source transport refusal; not coverage or loader status. |

Design rule:

```text
missing_slot != missing_required_slot != missing_required
```

They are similar words because they all mention absence, but they answer three
different questions:

1. Does this program require a slot the profile did not supply?
2. Is this contract object missing a schema-required slot?
3. Is this manifest missing a required profile id field?

---

## Lifecycle Placement Recommendation

Recommended placement:

```text
after SemanticIR emit, before assembly
```

Name this design position:

```text
SemanticIR profile-obligation checkpoint
```

Rationale:

- Before compile is too early for v0 because surface detection would need to
  re-derive semantics from source syntax and parser/classifier internals.
- After SemanticIR emit is the first stable point where accepted surfaces such
  as temporal, stream, OLAP, invariants, assumptions, contract modifiers, and
  progression descriptors can be observed from normalized compiler output.
- Before assembly is early enough to keep `CompilerProfileObligationReport`
  separate from `manifest.compiler_profile_id`.
- This placement prevents a future reader from treating a manifest profile id as
  proof that every emitted SemanticIR surface was profile-covered.

Design-only sequence:

```text
parse
  -> classify
  -> typecheck
  -> SemanticIR emit
  -> SemanticIR profile-obligation checkpoint
  -> assemble artifacts
```

Current implementation remains unchanged. The checkpoint is a proposed design
position only.

---

## Object Relationship

| Object | Current / future status | Authority source | Relationship |
| --- | --- | --- | --- |
| finalized `compiler_profile_id_source` | Existing bounded transport source | Minimal finalization proof and source-object validation | Supplies `compiler_profile_id`, `slot_order`, `slot_assignments`, and non-authority flags for obligation coverage. |
| `CompilerProfileObligationReport` | Accepted proof-local report-only object | Derived from SemanticIR surfaces plus finalized source slots | Reports `covered`, `missing_slot`, `unsupported_surface`, or `profile_not_supplied`; does not gate compile. |
| future `compiler_profile_contract` | Future design/proof target | Hybrid profile contract: descriptor, slots, strict registries, ordered rules, pack refs, digests, non-authority flags | Would validate the profile definition itself before finalization/coverage, once a proof stabilizes it. |
| manifest `compiler_profile_id` | PROP-036 manifest identity field | Finalized profile source identity | Identifies the compiler profile in artifact metadata; does not carry obligation report details and does not prove runtime readiness. |

Recommended data relationship:

```text
compiler_profile_contract
  -> finalizes to compiler_profile_id_source
  -> participates in SemanticIR profile-obligation checkpoint
  -> may supply manifest compiler_profile_id during assembly
```

This order is conceptual only. Current code only transports
`compiler_profile_id_source` to the assembler and emits `manifest.compiler_profile_id`
when supplied.

---

## `profile_not_supplied.missing_slots`

R56 proof behavior:

```text
status: profile_not_supplied
missing_slots: all slots required by detected surfaces
```

Design recommendation for future implementation:

```text
status: profile_not_supplied
required_slots: populated
missing_slots: []
```

Reason:

- `required_slots` is still useful evidence about the program surfaces.
- `missing_slots` should be reserved for profile-present comparison failures.
- When no profile exists, there is no profile slot set to compare against.
- Keeping `missing_slots` empty makes `profile_not_supplied` the primary signal
  and avoids confusing it with `missing_slot`.

This is a future design recommendation only. It does not invalidate or rewrite
the accepted R56 proof summary.

---

## PROP-037 Progression Treatment

For this boundary:

```text
progression_descriptor -> pipeline, stream, evidence_observation, oof_registry
```

`progression_descriptor` stays under `pipeline` for v0. No new `progression`
slot is introduced by this track.

Future question:

```text
Does PROP-037 need a dedicated progression slot before parser/SemanticIR/runtime
implementation?
```

That question requires a later Architect decision. It must not be silently
encoded in obligation coverage or contract validation.

---

## Governance Route

Recommended route:

```text
1. Keep this track as a design packet.
2. Open a proof-local compiler-profile-contract-proof-v0 experiment next.
3. Promote to a new PROP only if the proof stabilizes a canonical
   compiler_profile_contract object and validation order.
4. Add a PROP-036 addendum only as a cross-reference after the broader contract
   route is accepted.
```

Do not make this a direct PROP-036 addendum as the primary route. PROP-036 owns
manifest identity and source transport. A compiler-profile contract is broader:
it spans descriptor validity, slot obligations, strict ownership, ordered rules,
pack refs, and non-authority flags.

Do not request implementation authorization yet.

---

## Recommended Next Proof Boundary

Next proof-local card should validate the boundary without modifying compiler
behavior:

```text
compiler-profile-contract-proof-v0
```

Suggested proof checks:

- accepts a canonical `compiler_profile_contract` object;
- validates descriptor digest and finalization payload digest;
- validates required slot schema separately from obligation coverage;
- validates strict registry one-owner rules;
- validates ordered rule references and cycle freedom;
- proves `compiler_profile_contract.missing_required_slot` is distinct from
  `compiler_profile_obligation.missing_slot`;
- proves loader/report terms are absent from compiler contract refusals;
- emits a summary only under its own experiment `out/` directory;
- does not change `.igapp`, CLI/API, loader/report, CompatibilityReport,
  dispatch, RuntimeMachine, cache, or production behavior.

---

## Blockers Before Implementation Authorization

- `compiler-profile-contract-proof-v0` has not landed.
- The canonical `compiler_profile_contract` object shape is not proof-stable.
- Validation order is not fixed across source, contract, obligation, and
  loader/report vocabulary.
- `profile_not_supplied.missing_slots` future behavior is not proof-updated.
- No enforcement decision exists for `missing_slot`; it remains report-only.
- No decision exists to introduce a PROP-037 `progression` slot.
- No exact write scope exists for any compiler checkpoint implementation.
- No `.igapp` golden migration policy is open.
- Loader/report and CompatibilityReport remain closed.
- Dispatch migration remains closed.
- Runtime authority remains forbidden.

---

## Non-Authorization

This track does not authorize:

- code changes;
- parser syntax changes;
- TypeChecker or SemanticIR changes;
- `.igapp` artifact or golden mutation;
- CLI/API changes;
- profile discovery/defaulting/finalization in public surfaces;
- inline JSON, named lookup, env/config/sidecar lookup;
- loader/report implementation;
- CompatibilityReport implementation;
- compiler dispatch migration;
- pack loading;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP production execution;
- cache;
- production behavior.

---

## Handoff

```text
Card: S3-R57-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: compiler-profile-contract-boundary-v0
Status: done

[D] Decisions
- Keep four vocabularies separate:
  compiler_profile_source.*, compiler_profile_obligation.*,
  compiler_profile_contract.*, and loader/report status vocabulary.
- Place obligation coverage at the design-only
  SemanticIR profile-obligation checkpoint: after SemanticIR emit, before
  assembly.
- For future implementation, keep required_slots populated but make
  missing_slots empty for profile_not_supplied.
- Preserve PROP-037 v0: progression_descriptor remains under pipeline; no
  progression slot is authorized.

[S] Signals
- R56 proof is accepted as report-only evidence, not enforcement.
- Future compiler_profile_contract should validate contract schema/rules before
  obligation coverage compares program surfaces to profile slots.
- Manifest compiler_profile_id remains identity metadata, not coverage proof.

[T] Tests / Proofs
- Documentation-only design slice.
- No code or artifact checks required beyond doc validation.

[R] Recommendation
- Keep this as a design packet.
- Open proof-local compiler-profile-contract-proof-v0 next.
- Promote to a new PROP only after the proof stabilizes canonical object shape,
  validation order, and vocabulary.

[Next]
- Prove the hybrid compiler_profile_contract object and vocabulary separation
  without touching live compiler dispatch or persisted artifacts.
```
