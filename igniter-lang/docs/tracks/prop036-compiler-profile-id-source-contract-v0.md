# Track: PROP-036 Compiler Profile ID Source Contract v0

Card: S3-R42-C4-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-compiler-profile-id-source-contract-v0`
Route: UPDATE
Status: done
Date: 2026-05-13

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Implementation Agent]`,
`[Architect Supervisor / Codex]`

---

## Goal

Define the authoritative source contract for `compiler_profile_id` before any
PROP-036 assembler implementation is reconsidered.

This is a design/contract track only. It does not implement code and does not
mutate `.igapp`, `.ilk`, loader, assembler, RuntimeMachine, or goldens.

---

## Inputs Read

- `docs/gates/prop036-assembler-field-implementation-authorization-review-v0.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/tracks/prop036-assembler-impact-survey-v0.md`
- `docs/tracks/prop036-assembler-implementation-contract-v0.md`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/tracks/compiler-profile-descriptor-schema-v0.md`
- `docs/tracks/compiler-profile-slots-model-v0.md`
- `docs/tracks/compiler-profile-validator-implementation-plan-v0.md`

---

## Decision

[D] A real assembler implementation must not invent `compiler_profile_id` from a
proof-local constant or accept an unaudited raw string as authority.

[D] The authoritative source is:

```text
frozen CompilerProfile descriptor
  -> minimal CompilerProfile finalization
  -> derived compiler_profile_id
  -> assembler receives finalized source object
```

[D] A keyword parameter may be used only as a transport mechanism after the
caller has produced a finalized source object. It is not an authority source by
itself.

[D] A proof-local constant remains allowed only in proof-local experiments. It
must not be used for production-like assembler output.

[D] Minimal CompilerProfile finalization is the recommended next blocker to
close before `assembler-compiler-profile-id-field-v0` can be authorized.

---

## Source Option Comparison

| Option | Decision | Reason |
| --- | --- | --- |
| Keyword parameter | Transport only | A raw string parameter can carry the id through assembler APIs, but it cannot prove where the value came from. |
| Frozen compiler profile descriptor | Accept as authoritative input | It is descriptor-first, syntax-neutral, deterministic, and matches the profile architecture direction. |
| Minimal CompilerProfile finalization | Recommended source boundary | It turns a valid descriptor into a stable `compiler_profile_unified/sha256:*` identity without migrating compiler dispatch. |
| Proof-local constant | Proof-only | Useful for synthetic tests, but unsafe for real assembler output because it claims compiler understanding without a derived profile. |

---

## Authoritative Source Shape

The assembler implementation should receive a finalized source object, not a
bare string:

```json
{
  "kind": "compiler_profile_id_source",
  "format_version": "0.1.0",
  "status": "finalized",
  "profile_namespace": "compiler_profile_unified",
  "compiler_profile_id": "compiler_profile_unified/sha256:2944e573270aa56fca51cea3",
  "descriptor_digest": "compiler_profile_descriptor/sha256:6ee9c9c82ee1604b98a07f75",
  "finalization_payload_digest": "sha256:2944e573270aa56fca51cea3...",
  "profile_kind": "Stage3ProofCompilerProfileSpec",
  "slot_order": [
    "core",
    "oof_registry",
    "fragment_registry",
    "escape_boundary",
    "contract_modifiers",
    "temporal",
    "stream",
    "olap",
    "invariant",
    "assumptions",
    "evidence_observation",
    "pipeline"
  ],
  "dispatch_migration_authorized": false,
  "runtime_authority_granted": false
}
```

The source object is an assembler input contract. It does not need to be emitted
as a public artifact in the first assembler card.

Required fields:

| Field | Requirement |
| --- | --- |
| `kind` | exactly `compiler_profile_id_source` |
| `format_version` | source contract version |
| `status` | exactly `finalized` before assembler emission |
| `profile_namespace` | exactly `compiler_profile_unified` for PROP-036 v0 |
| `compiler_profile_id` | value to emit in manifest, derived from finalization payload |
| `descriptor_digest` | digest of the canonical frozen descriptor |
| `finalization_payload_digest` | full digest used to derive the manifest id |
| `profile_kind` | profile-spec family used for validation |
| `slot_order` | canonical slot order, not source-surface order |
| `dispatch_migration_authorized` | must be `false` for this implementation line |
| `runtime_authority_granted` | must be `false` |

Optional implementation detail:

```text
descriptor
```

may be present in test/proof material, but production-like assembler invocation
may pass only digest-backed finalized source material once the finalizer is
trusted by tests.

---

## Value Derivation Rule

The accepted value format remains:

```text
compiler_profile_unified/sha256:<24+ lowercase hex chars>
```

The derivation rule is:

1. Validate a frozen profile descriptor using the descriptor-first contract.
2. Validate profile slots against the canonical `CompilerProfileSpec` slot
   model.
3. Canonicalize descriptor/finalization material with lexicographic object keys.
4. Preserve canonical `slot_order` as ordered data.
5. Include pack implementation identities and registry/order fingerprints that
   are part of compiler understanding.
6. Exclude volatile material such as timestamps, local paths, process ids, and
   runtime approval state.
7. Compute SHA-256 over the canonical finalization payload.
8. Emit:

```text
compiler_profile_unified/sha256:<digest prefix or full digest>
```

where the digest fragment must contain at least 24 lowercase hex characters.

The `compiler_profile_id` itself must not be part of the payload it hashes. The
payload may include:

```text
profile_namespace
format_version
descriptor_digest
profile_kind
slot_order
slot assignments
pack implementation ids
registry/order fingerprints
```

The payload must not include:

```text
artifact_hash
manifest path
runtime readiness
approval token
Gate 3 state
loader status
CompilationReceipt signature
```

---

## Refusal Behavior

Assembler-side refusals are source-construction refusals. They are not loader
status values and must not emit `absent_legacy`, `present_verified`, `mismatch`,
`malformed`, or `missing_required`.

| Condition | Assembler-side result | Suggested reason code |
| --- | --- | --- |
| No source object is provided to a profile-aware assembler path. | refuse build | `compiler_profile_source.missing` |
| Source object is not a hash/object. | refuse build | `compiler_profile_source.malformed` |
| `kind` is not `compiler_profile_id_source`. | refuse build | `compiler_profile_source.wrong_kind` |
| `status` is not `finalized`. | refuse build | `compiler_profile_source.unfinalized` |
| Namespace is not `compiler_profile_unified`. | refuse build | `compiler_profile_source.unsupported_namespace` |
| `compiler_profile_id` does not match accepted value format. | refuse build | `compiler_profile_source.malformed_id` |
| `compiler_profile_id` does not derive from payload digest. | refuse build | `compiler_profile_source.id_digest_mismatch` |
| Descriptor digest is missing or malformed. | refuse build | `compiler_profile_source.descriptor_digest_invalid` |
| Slot order differs from canonical `CompilerProfileSpec.slot_order`. | refuse build | `compiler_profile_source.slot_order_mismatch` |
| Source grants runtime authority. | refuse build | `compiler_profile_source.runtime_authority_forbidden` |
| Source authorizes compiler dispatch migration. | refuse build | `compiler_profile_source.dispatch_migration_forbidden` |

If a future implementation needs a legacy assembler mode that omits
`compiler_profile_id`, that mode must be explicit. It must not silently run the
profile-aware path with a missing source.

---

## No-Dispatch-Migration Boundary

The source contract may record canonical slot order and pack implementation
identity. It must not route current compiler execution through packs.

Allowed:

```text
validate descriptor shape
validate slot assignments
canonicalize finalization material
derive compiler_profile_id
pass finalized source to assembler
```

Not allowed:

```text
install compiler packs into live Parser/Classifier/TypeChecker/SemanticIR passes
select pass handlers from profile slots
replace current compiler dispatch with CompilerKernel
change source syntax
change runtime behavior
```

`CompilerProfileSpec.slot_order` remains canonical descriptor/future dispatch
order. It is not current dispatch authority.

---

## No Runtime Authority Boundary

`compiler_profile_id` identifies compiler understanding only.

It does not authorize:

- RuntimeMachine evaluation;
- Gate 3 widening;
- Ledger or TBackend binding;
- temporal live reads;
- BiHistory production execution;
- stream or OLAP executors;
- production cache;
- production deployment.

The source object must carry:

```json
{
  "runtime_authority_granted": false
}
```

or omit runtime authority entirely. It must not contain approval-token,
CompatibilityReport-ready, executor-ready, or TBackend-ready claims.

---

## Recommended Implementation Sequencing

Before assembler implementation is reconsidered, add a design/proof card:

```text
minimal-compiler-profile-finalization-proof-v0
```

Required proof scope:

- use frozen descriptor material;
- validate descriptor shape and canonical slot order;
- derive `compiler_profile_unified/sha256:*`;
- show input-order independence;
- show implementation-id changes change the derived id;
- show malformed/missing/unfinalized source refusals;
- preserve no dispatch migration;
- preserve no runtime authority.

Only after that proof passes should C3-A reconsider:

```text
assembler-compiler-profile-id-field-v0
```

---

## Exact Blockers Before Implementation Authorization Can Be Reconsidered

C3-A must remain on hold until all blockers close:

1. A minimal CompilerProfile finalization proof exists and passes.
2. The proof produces a finalized source object matching this track's
   `compiler_profile_id_source` shape.
3. The proof derives `compiler_profile_unified/sha256:<24+ lowercase hex chars>`
   from canonical finalization material, not a constant.
4. The proof rejects missing, malformed, wrong-kind, unfinalized, namespace,
   malformed-id, digest-mismatch, slot-order-mismatch, runtime-authority, and
   dispatch-migration cases.
5. The proof demonstrates input-order independence.
6. The proof demonstrates implementation identity affects the derived id.
7. The future implementation request states whether a keyword parameter is used
   only to transport the finalized source object or id.
8. The future implementation request does not accept a raw user/CLI string as
   authority.
9. The future implementation request preserves `legacy_optional`.
10. The future implementation request preserves `present_verified != runtime
    ready`.
11. Loader/report/status implementation remains separate.
12. CompatibilityReport implementation remains separate.
13. Receipt links, signing, and `.ilk` changes remain separate.
14. Compiler dispatch migration remains separate.
15. RuntimeMachine/Gate 3/Ledger/TBackend/BiHistory/stream/OLAP/production cache
    authority remains separate.
16. Golden migration remains separate unless an implementation authorization
    names exact fixtures and expected hash churn.

---

## Recommendation

[R] Use the frozen descriptor plus minimal finalization path as the authoritative
source contract.

[R] Do not authorize assembler field emission from a proof-local constant.

[R] Do not authorize a bare `compiler_profile_id:` keyword as the source of
truth. It may be used only after finalization has already produced the id.

[R] Reconsider assembler implementation only after a minimal finalization proof
closes the source-contract blockers.

---

## Non-Authorization

This card does not authorize:

- assembler implementation;
- `.igapp` manifest mutation;
- `.igapp` golden migration;
- `.ilk` changes;
- loader implementation;
- CompatibilityReport production changes;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- parser syntax;
- TypeChecker or SemanticIR changes;
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
Card: S3-R42-C4-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop036-compiler-profile-id-source-contract-v0
Status: done

[D] Decisions
- Authoritative source is frozen CompilerProfile descriptor -> minimal
  finalization -> derived compiler_profile_id.
- Keyword parameter is transport only, not authority.
- Proof-local constant remains proof-only.
- Missing/malformed/unfinalized profile source refuses at assembler source
  boundary without implementing loader status semantics.
- No dispatch migration and no runtime authority are preserved.

[S] Shipped / Signals
- Added source contract track doc.
- Defined source shape, derivation rule, refusal matrix, and blockers.

[T] Tests / Proofs
- Documentation-only contract; no code, manifests, `.ilk`, loader, assembler,
  RuntimeMachine, or goldens changed.

[R] Risks / Recommendations
- C3-A should stay held until minimal CompilerProfile finalization proof exists.
- Do not allow real assembler output to claim a hardcoded profile id.

[Next]
- Open `minimal-compiler-profile-finalization-proof-v0`.
- Reconsider `assembler-compiler-profile-id-field-v0` only after source
  finalization blockers close.
```
