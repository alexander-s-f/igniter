# Track: OOF/Fragment Registry Source Authority Design v0

Card: LANG-R116-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R115-P1
Track: `oof-fragment-registry-source-authority-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Design source-authority policy for profile/pack OOF Fragment Registry
provenance after proof-only profile/pack modeling passed.

This track is design-only. It does not authorize implementation and does not
open loader/report, public API/CLI, compiler integration, specs/canon/proposals,
`.igapp`, runtime, production, or Spark surfaces.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns future authority/refinement proofs.
- `[Igniter-Lang Architect Supervisor]`: owns source-authority acceptance and
  any future implementation authorization.
- `[Igniter-Lang Bridge Agent]`: loader/report, CompatibilityReport, public
  API/CLI, runtime, and production surfaces remain closed.

---

## Evidence Read

- `docs/tracks/oof-fragment-registry-profile-pack-source-mode-design-v0.md`
  (LANG-R114-D1)
- `docs/tracks/oof-fragment-registry-profile-pack-source-mode-proof-v0.md`
  (LANG-R115-P1)
- `experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_proof_summary.json`
- `experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_model.json`
- `lib/igniter_lang/oof_fragment_registry.rb`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`

No tests or broad proof commands were run.

---

## Decision

Recommendation:

```text
Use BOTH pack-row-level and profile-level authority, with explicit precedence.
Pack-row authority is primary for ownership of individual OOF/fragment/support rows.
Profile-level authority is secondary/aggregating: it selects the accepted pack row set,
slot order, and conflict policy for the candidate registry.
Keep live helper behavior held.
Do not change SOURCE_ACCEPTED_MODES.
```

Short form:

```text
authority model: both, pack-row primary + profile aggregation
live helper: held_source_mode remains
next route: proof-only authority precedence proof
implementation: held
```

Rationale:

- R115 proves pack descriptors can own rows and a profile candidate can derive a
  registry from those rows.
- OOF/fragment row ownership is naturally per pack: duplicate row ownership
  must be detected at row provenance.
- A profile is still needed to select which pack descriptors participate,
  define slot/order context, and apply conflict policy.
- Profile-only authority would hide row provenance.
- Pack-row-only authority would omit profile selection and aggregation.

---

## Authority Model Options

| Option | Decision | Strength | Risk |
| --- | --- | --- | --- |
| Profile-level only | Reject for now | Simple: one source owns derived registry. | Hides row ownership and makes duplicate/competing pack claims harder to explain. |
| Pack-row-level only | Reject for now | Precise ownership per OOF/fragment/support row. | Does not explain selected pack set, slot context, or aggregate registry validity. |
| Both with explicit precedence | Recommend | Preserves row provenance and profile aggregation. | Needs proof that precedence is deterministic and non-authoritative for live compiler. |
| Still held/no authority model | Reject as next route | Maximum caution. | R115 already shows enough to define the model; holding would stall the useful design question. |

---

## Recommended Authority Semantics

### Pack-Row Authority

Pack-row authority owns row provenance:

```text
pack_descriptor_candidate
  -> declares owned_oof_descriptors
  -> declares owned_fragment_rows
  -> declares owned_support_markers
```

Pack-row authority answers:

- which pack claims a row;
- which slot the pack belongs to;
- whether duplicate ownership exists;
- whether excluded namespaces are incorrectly claimed;
- whether support markers remain support-only.

Pack-row authority does not answer:

- whether the pack is installed;
- whether the compiler dispatches pack rules;
- whether rows are canon/current;
- whether loader/report/runtime may trust the rows.

### Profile-Level Authority

Profile-level authority owns aggregation:

```text
profile_candidate
  -> names selected pack_descriptor_candidate refs
  -> defines candidate slot/pack ordering
  -> aggregates rows into derived registry
  -> applies conflict policy
```

Profile-level authority answers:

- which pack descriptors are in the candidate profile;
- how rows are aggregated;
- whether all required registry sections are present;
- whether aggregate conflict policy passes.

Profile-level authority does not answer:

- live compiler dispatch;
- `.igapp/manifest.json` identity;
- loader/report present_verified state;
- runtime execution readiness;
- canon source status.

### Precedence Rule

Recommended precedence:

```text
row identity/ownership: pack-row authority wins
selected row set/order/conflict policy: profile-level authority wins
conflict between pack row claims: profile rejects aggregate; no override
```

There should be no silent profile override of duplicate row ownership.

---

## Source Envelope Policy

Current live helper remains unchanged:

```text
SOURCE_ACCEPTED_MODES = proof_fixture caller_supplied
SOURCE_HELD_MODES = profile_candidate pack_descriptor_candidate
```

For any future proof-only authority refinement:

| Source mode | Source authority policy | Live helper behavior |
| --- | --- | --- |
| `profile_candidate` | profile-level aggregator authority; non-canon/proof-only | still `held_source_mode` |
| `pack_descriptor_candidate` | pack-row provenance authority; non-canon/proof-only | still `held_source_mode` |

Allowed authority values for next proof:

```json
{
  "authority_kind": "proof_only",
  "canon_status": "non_canon"
}
```

Still forbidden:

- `canon_status: "canon"`;
- profile/pack source accepted by live helper;
- manifest/compiler_profile_id authority;
- loader/report or CompatibilityReport authority;
- runtime/production authority;
- public API/CLI source authority.

---

## Alignment With PROP-036

PROP-036 says a `CompilerProfile` identifies compiler understanding and a
`compiler_profile_id` names the profile that assembled an artifact. It also
keeps expanded profile material out of `manifest.json` unless separately
authorized.

R116 alignment:

- `profile_candidate` may model a non-canon compiler-profile-like aggregate.
- It must not write or require `compiler_profile_id`.
- It must not mutate `.igapp/manifest.json`.
- It must not claim `profile_required` loader/report behavior.
- It must not imply current compiler dispatch order.
- It must not grant runtime execution authority.

Allowed proof wording:

```text
profile_candidate models future CompilerProfile-like registry provenance.
```

Forbidden proof wording:

```text
profile_candidate is the compiler_profile_id source for artifacts.
```

---

## Alignment With PROP-038

PROP-038 defines compiler profile contract object validity, strict registries,
and ordered rules. It explicitly separates `compiler_profile_contract.*`
diagnostics from language OOF diagnostics and says valid profile contract
material is evidence, not dispatch/runtime/loader authority.

R116 alignment:

- Pack-row authority may be checked against a synthetic strict-registry shape.
- Profile-level aggregation may cite a synthetic profile contract ref.
- `compiler_profile_contract.*` and `compiler_profile_contract_refusal.*`
  remain excluded from OOF descriptors and aliases.
- PROP-038 validator/report behavior must not change.
- `compiler_profile_contract_validation.diagnostics` must not be touched.
- Strict-refusal behavior must not change.

Allowed proof wording:

```text
profile/pack source model is compatible with PROP-038 strict-registry ownership.
```

Forbidden proof wording:

```text
PROP-038 contract validity accepts profile_candidate as an OOF source.
```

---

## Pack Descriptor Boundary

Pack descriptors are provenance rows, not live packs.

Proof-only pack descriptor authority may include:

- `pack_ref`;
- `slot_name`;
- row lists for OOF descriptors, fragment rows, and support markers;
- row source refs;
- row authority policy;
- non-authority flags.

It must exclude:

- install hooks;
- parser/classifier/typechecker rule dispatch;
- SemanticIR or assembler hooks;
- dynamic pack loading;
- runtime capabilities;
- package installation;
- production execution.

Pack descriptor authority must be strict-one-owner for row keys:

```text
one row key -> one owning pack descriptor
```

Duplicates should reject the profile aggregate unless a later explicit alias or
deprecation policy handles the conflict.

---

## Blockers Before Changing `SOURCE_ACCEPTED_MODES`

Do not change `SOURCE_ACCEPTED_MODES` until all are complete:

1. Accepted authority-precedence proof for both profile and pack rows.
2. Source-authority design accepted by Architect.
3. Exact accepted source modes and method result shape reviewed.
4. Decision whether `authority_kind` may move beyond `proof_only`.
5. Decision whether `canon_status` may ever be `accepted_design` or `canon`.
6. PROP-036 alignment gate proving no `.igapp` manifest mutation.
7. PROP-038 alignment gate proving no validator/report behavior change.
8. Pack descriptor schema accepted as proof/design, not dispatch.
9. Full parity matrix for compiler/report/`.igapp` surfaces.
10. Bridge review before any loader/report or CompatibilityReport mention
    becomes anything more than a closed future candidate.
11. Explicit Architect implementation authorization naming
    `SOURCE_ACCEPTED_MODES` change.

Until then:

```text
profile_candidate and pack_descriptor_candidate remain held.
```

---

## Recommended Next Route

Recommendation:

```text
Open proof-only source-authority precedence proof.
Do not open implementation authorization yet.
```

Suggested route:

```text
oof-fragment-registry-source-authority-precedence-proof-v0
```

Route type:

```text
proof-only
experiment-local
no library/compiler/public/report/spec/runtime changes
```

Suggested proof questions:

- pack-row authority owns row provenance;
- profile-level authority aggregates selected packs;
- duplicate row ownership rejects aggregate;
- profile cannot silently override row conflict;
- missing selected pack ref rejects aggregate;
- excluded namespace still rejects;
- live helper still returns `held_source_mode`;
- derived registry still validates only after proof model aggregation.

---

## Implementation Posture

Implementation remains held.

Do not authorize:

- changing `SOURCE_ACCEPTED_MODES`;
- accepting `profile_candidate` or `pack_descriptor_candidate` in live helper;
- adding profile/pack source loading;
- compiler integration;
- public API/CLI;
- loader/report or CompatibilityReport;
- `.igapp` or manifest mutation;
- PROP-036 or PROP-038 behavior changes.

The purpose of the next proof is to harden the authority semantics before
considering any live helper acceptance.

---

## Closed Surfaces

This design does not authorize:

- code implementation;
- changing `SOURCE_ACCEPTED_MODES`;
- loader/report behavior;
- public API/CLI input or output;
- compiler integration;
- specs, proposals, or canon edits;
- `lib/igniter_lang/oof_fragment_registry_data.rb`;
- static registry constants;
- `lib/igniter_lang.rb` require changes;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  `CompilationReport`, `CompilerResult`, diagnostics, or CLI changes;
- `.igapp`, `.ilk`, or golden mutation;
- live pack registry or dispatch;
- PROP-036 manifest changes;
- PROP-038 validator/report changes;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production
  executors, cache, signing, deployment, production behavior, or Spark work.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: LANG-R116-D1
Track: oof-fragment-registry-source-authority-design-v0
Status: done

[D]
- Designed source-authority policy after R115 proof-only profile/pack modeling.
- Recommended both authorities with precedence:
  pack-row authority primary for row ownership;
  profile-level authority secondary for selection/aggregation/conflict policy.
- Preserved live helper held behavior.

[S]
- PROP-036 alignment: no `.igapp` mutation, no manifest/profile identity
  authority, no dispatch or runtime authority.
- PROP-038 alignment: strict-registry vocabulary may inform proof modeling, but
  validator/report behavior and `compiler_profile_contract.*` separation remain unchanged.

[T]
- Docs-only design.
- No tests or broad proofs run.

[R]
- Do not change `SOURCE_ACCEPTED_MODES`.
- Next route should be proof-only source-authority precedence proof, not
  implementation authorization.

[Next]
- `oof-fragment-registry-source-authority-precedence-proof-v0`.
```
