# Track: PROP-036 Assembler Implementation Contract v0

Card: S3-R42-C2-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-assembler-implementation-contract-v0`
Route: UPDATE
Status: done
Date: 2026-05-13

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Meta Expert]`,
`[Igniter-Lang Implementation Agent]`

---

## Goal

Crystallize the exact formal contract for the first possible PROP-036
implementation authorization.

This is a contract document only. It does not implement assembler code, loader
code, CompatibilityReport/status code, runtime behavior, `.igapp` manifest
changes, or golden updates.

---

## Inputs Read

- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md`
- `docs/tracks/prop036-loader-status-report-proof-v0.md`
- `docs/tracks/prop036-artifact-hash-ordering-proof-v0.md`
- `docs/tracks/prop036-assembler-field-design-plan-v0.md`
- `docs/current-status.md`
- `docs/agent-context.md`

---

## Contract Decision

[D] The first possible implementation authorization should be named:

```text
assembler-compiler-profile-id-field-v0
```

[D] Its implementation type must be:

```text
assembler-only
```

[D] The only language/artifact surface it may implement is:

```text
.igapp/manifest.json top-level compiler_profile_id
```

[D] The field must use the accepted PROP-036 value shape:

```text
compiler_profile_unified/sha256:<24+ lowercase hex chars>
```

[D] The implementation must preserve the initial rollout policy:

```text
legacy_optional
```

[D] The implementation must preserve the hard invariant:

```text
compiler_profile.status == present_verified
  does not imply
runtime_evaluation_readiness.ready == true
```

[D] The implementation must respect the hash-order dependency:

```text
finalize CompilerProfile
derive compiler_profile_id
assemble manifest material with compiler_profile_id present
compute artifact_hash over profiled artifact material
```

[D] The forbidden order remains:

```text
assemble -> hash/sign -> add compiler_profile_id
```

---

## Allowed C3-A Authorization Boundary

C3-A may authorize an implementation card only if its scope says all of the
following explicitly:

| Required statement | Required value |
| --- | --- |
| Surface | `assembler-compiler-profile-id-field-v0` |
| Type | `assembler-only` |
| Manifest field placement | top-level `compiler_profile_id` |
| Manifest field authority | compiler understanding identity only |
| Initial rollout policy | `legacy_optional` |
| Runtime authority | none |
| Loader/report/status changes | none |
| Compiler dispatch migration | none |
| RuntimeMachine binding | none |
| Artifact hash dependency | field is present before profiled hash material is finalized |
| Golden migration | not bundled unless C3-A names a separate golden-migration surface |
| Receipt/signing links | not bundled |

If C3-A combines assembler field emission with loader/report/status,
CompatibilityReport status, receipt links, signing, compiler dispatch, runtime
binding, or production behavior, then it is not the first PROP-036 implementation
card described by this contract.

---

## Refusal Conditions

The C3-A request should be refused or redirected if it contains any of these
conditions:

| Condition | Refusal / redirect |
| --- | --- |
| It authorizes loader or CompatibilityReport status implementation. | Redirect to a separate loader/report-only card. |
| It treats `present_verified` as runtime ready. | Refuse; violates PROP-036 and C3-A acceptance invariant. |
| It changes rollout from `legacy_optional` to `profile_required`. | Refuse unless a later Architect migration decision exists. |
| It adds `compiler_profile_id` after artifact hash/signature material is finalized. | Refuse; violates hash-order proof. |
| It changes broad `.igapp` goldens without an explicit migration fixture list. | Redirect to `artifact-hash-profile-id-golden-migration-v0`. |
| It routes Parser, Classifier, TypeChecker, SemanticIR, or current compiler dispatch through packs. | Refuse; compiler dispatch migration is out of scope. |
| It adds CompilationReceipt, `.ilk`, or signing linkage. | Redirect to a receipt/signing-specific card. |
| It implies RuntimeMachine, Gate 3, Ledger, TBackend, stream/OLAP executor, BiHistory live execution, or production cache authority. | Refuse; runtime authority is separate. |
| It mutates existing artifacts without deterministic before/after hash evidence. | Hold until hash-delta proof is attached. |

---

## C3-A Implementation Contract Checklist

C3-A is ready to authorize `assembler-compiler-profile-id-field-v0` only when
the request includes this checklist:

- [ ] Cites `PROP-036-compiler-profile-manifest-identity-v0.md`.
- [ ] Cites `prop036-compiler-profile-id-acceptance-decision-v0.md`.
- [ ] Cites `prop036-loader-status-report-proof-v0.md`.
- [ ] Cites `prop036-artifact-hash-ordering-proof-v0.md`.
- [ ] Cites `prop036-assembler-field-design-plan-v0.md`.
- [ ] Names exactly one implementation surface: `assembler-compiler-profile-id-field-v0`.
- [ ] States `assembler-only`.
- [ ] States no loader/report/status implementation.
- [ ] States no CompatibilityReport implementation.
- [ ] States no RuntimeMachine binding or runtime execution authority.
- [ ] States no compiler dispatch migration.
- [ ] States no parser syntax, TypeChecker, or SemanticIR changes.
- [ ] States initial rollout remains `legacy_optional`.
- [ ] States `present_verified != runtime ready`.
- [ ] States top-level `manifest.compiler_profile_id`.
- [ ] States the accepted value format:
      `compiler_profile_unified/sha256:<24+ lowercase hex chars>`.
- [ ] States the field is present before artifact hash material is finalized.
- [ ] States whether the card touches only test/proof-local fixtures or names
      exact `.igapp` fixture outputs to migrate.
- [ ] If any real `.igapp` output changes, lists exact files/fixtures and
      expected hash churn before implementation begins.
- [ ] Defines malformed or unavailable profile-id behavior for assembler field
      construction without implementing loader status semantics.
- [ ] Defines a post-implementation proof matrix.

---

## Minimal Assembler Behavior For C4-I

If C3-A authorizes implementation and all blockers below close, C4-I may
implement only this assembler behavior:

1. Obtain or derive a finalized compiler profile id from the authorized compiler
   profile source.
2. Write it as top-level `compiler_profile_id` in manifest material.
3. Ensure artifact hash material is computed after the field is present.
4. Preserve legacy artifacts without retroactive mutation unless the C4-I card
   names exact migrated fixtures.
5. Emit no loader/report status.
6. Emit no runtime readiness result.
7. Emit no receipt/signature linkage.
8. Migrate no compiler dispatch behavior.

The implementation may expose internal helper structure only if it remains an
assembler implementation detail and does not create a public loader/runtime
contract.

---

## Post-Implementation Proof Expectations

C4-I must include a proof or test matrix with at least:

| Proof case | Expected result |
| --- | --- |
| manifest_field_top_level | `compiler_profile_id` appears at top-level in assembled manifest material. |
| profile_id_format_valid | value matches `compiler_profile_unified/sha256:<24+ lowercase hex chars>`. |
| hash_material_includes_profile | changing only `compiler_profile_id` changes computed artifact hash material. |
| post_hash_annotation_blocked | implementation cannot append `compiler_profile_id` after hash material finalization. |
| legacy_optional_preserved | pre-existing no-profile artifacts remain inspectable by separate loader policy; assembler does not force `profile_required`. |
| present_verified_not_runtime_ready | any proof report keeps compiler profile verification separate from runtime readiness. |
| loader_status_absent | no `absent_legacy`, `present_verified`, `mismatch`, `malformed`, or `missing_required` production status implementation is introduced by assembler-only work. |
| no_dispatch_migration | parser/classifier/typechecker/SemanticIR/compiler dispatch paths are unchanged. |
| no_runtime_authority | RuntimeMachine/Gate 3/Ledger/TBackend/production cache remain untouched. |

If real `.igapp` outputs or goldens are touched, the matrix must also include an
exact fixture list and before/after hash deltas. Without that explicit list, C4-I
must stay on proof-local or narrowly scoped test material.

---

## Exact Blockers Before C4-I May Start

C4-I must not start until all blockers below are closed:

1. C3-A explicitly authorizes implementation, not only design/proof work.
2. C3-A names `assembler-compiler-profile-id-field-v0` as the only
   implementation surface.
3. C3-A states `assembler-only`.
4. C3-A preserves `legacy_optional`.
5. C3-A preserves `present_verified != runtime ready`.
6. C3-A carries the artifact hash ordering proof as a hard implementation
   requirement.
7. C3-A says loader/report/status implementation is out of scope.
8. C3-A says CompatibilityReport implementation is out of scope.
9. C3-A says receipt links, signing, and `.ilk` changes are out of scope.
10. C3-A says compiler dispatch migration is out of scope.
11. C3-A says RuntimeMachine/Gate 3/Ledger/TBackend/runtime execution authority
    are out of scope.
12. C3-A either forbids real `.igapp`/golden mutation or names exact migrated
    fixtures and expected hash churn.
13. The implementation card states how the assembler obtains the finalized
    compiler profile id without inventing a new public runtime/profile API.
14. The implementation card defines refusal behavior for malformed or missing
    assembler-side profile id input without claiming loader status semantics.
15. The implementation card includes the post-implementation proof matrix above.

---

## Remaining Separate Surfaces

These remain separate future cards:

| Surface | Status after this contract |
| --- | --- |
| `loader-compiler-profile-status-report-v0` | Blocked until separately authorized. |
| `artifact-hash-profile-id-golden-migration-v0` | Blocked unless exact fixture list and hash churn are authorized. |
| `compilation-receipt-manifest-link-v0` | Blocked until manifest ordering is stable and separately authorized. |
| production signing | Blocked; synthetic proof only exists. |
| `.ilk` profile linkage | Blocked. |
| compiler dispatch migration | Blocked. |
| `profile_required` rollout | Blocked pending migration evidence and Architect decision. |
| runtime evaluation readiness | Governed by runtime/Gate 3 authority, not PROP-036 assembler field emission. |

---

## Non-Authorization

This card does not authorize:

- assembler implementation;
- loader implementation;
- CompatibilityReport implementation;
- `.igapp` manifest mutation;
- `.igapp` golden migration;
- `.ilk` changes;
- artifact signing;
- CompilationReceipt links;
- parser syntax;
- TypeChecker or SemanticIR changes;
- compiler dispatch migration;
- RuntimeMachine binding;
- RuntimeMachine execution authority;
- Gate 3 widening;
- Ledger or TBackend binding;
- BiHistory live execution;
- stream or OLAP production executors;
- production cache;
- production deployment.

---

## Handoff

```text
Card: S3-R42-C2-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop036-assembler-implementation-contract-v0
Status: done

[D] Decisions
- First possible PROP-036 implementation should be assembler-only:
  assembler-compiler-profile-id-field-v0.
- The only allowed field is top-level manifest.compiler_profile_id.
- legacy_optional remains initial rollout policy.
- present_verified remains separate from runtime readiness.
- compiler_profile_id must enter artifact hash material before hash/signature
  finalization.

[S] Shipped / Signals
- Added this contract track doc.
- Defined C3-A checklist, refusal conditions, post-implementation proof
  expectations, and exact blockers before C4-I.

[T] Tests / Proofs
- Documentation-only contract; no code, manifests, or goldens changed.

[R] Risks / Recommendations
- Refuse any implementation request that bundles loader/report/status,
  CompatibilityReport, receipt/signing, dispatch migration, RuntimeMachine, or
  runtime authority.
- Require exact fixture lists and hash-delta evidence before any real `.igapp`
  or golden migration.

[Next]
- C3-A may review this contract for an assembler-only implementation
  authorization.
- C4-I must wait until every blocker in this track is closed.
```
