# Track: PROP-036 Facade Source Contract Hardening v0

Card: S3-R45-C2-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-facade-source-contract-hardening-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Research Agent]`

---

## Goal

Harden the caller-facing contract language for the Ruby facade
`compiler_profile_source` object and make the transport-only boundary explicit
without changing behavior.

This track answers R44 pressure:

- NB-1: no caller-facing documentation for valid `compiler_profile_source`
  shape;
- NB-2: facade transport-only contract is implicit.

No implementation, parser, assembler, loader, runtime, `.igapp`, `.ilk`, or
golden behavior is changed here.

---

## Inputs Read

- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/gates/prop036-cli-api-exposure-authorization-review-v0.md`
- `docs/tracks/minimal-compiler-profile-finalization-proof-v0.md`
- `docs/tracks/prop036-ruby-facade-profile-source-exposure-v0.md`
- `docs/discussions/prop036-cli-api-profile-source-pressure-v0.md`
- `lib/igniter_lang.rb`

---

## Current Facade Surface

Current public Ruby facade:

```ruby
IgniterLang.compile(
  source_path: source_path,
  out_path: out_path,
  compiler_profile_source: compiler_profile_source
)
```

Observed implementation:

```text
IgniterLang.compile forwards compiler_profile_source unchanged to
CompilerOrchestrator#compile.
```

The facade does not validate, finalize, discover, infer, load from a path, parse
JSON, default, normalize, or authorize a compiler profile source.

Nil remains the legacy path:

```text
compiler_profile_source: nil
```

and preserves `legacy_optional` manifest behavior.

---

## What A Finalized Source Is In The Current Proof Model

In the current PROP-036 proof model, a finalized `compiler_profile_source` is a
Hash-like object produced by the minimal CompilerProfile finalization proof.

Required caller-facing shape:

```json
{
  "kind": "compiler_profile_id_source",
  "format_version": "0.1.0",
  "status": "finalized",
  "profile_namespace": "compiler_profile_unified",
  "compiler_profile_id": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
  "descriptor_digest": "compiler_profile_descriptor/sha256:<24 lowercase hex chars>",
  "finalization_payload_digest": "sha256:<64 lowercase hex chars>",
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
  "slot_assignments": {
    "core": {
      "implementation_id": "core_language.proof_compiler_adapter.v0",
      "pack_name": "CoreLanguagePack"
    }
  },
  "dispatch_migration_authorized": false,
  "runtime_authority_granted": false
}
```

The example truncates `slot_assignments` for readability. A valid source must
carry the finalized slot assignments needed for digest validation.

Important: this object is not the profile descriptor itself. It is the finalized
source object derived from descriptor/finalization material.

---

## What Callers Must Not Assume

Callers must not assume:

- `compiler_profile_source` may be a file path;
- the facade will read JSON from disk;
- the facade will parse inline JSON strings;
- the facade will finalize a descriptor;
- the facade will discover, infer, or default a profile;
- a raw `compiler_profile_id` string is enough;
- `compiler_profile_source: nil` means profile-required mode;
- `compiler_profile_id` grants runtime readiness;
- `compiler_profile_id` grants Gate 3, Ledger, TBackend, stream/OLAP executor,
  BiHistory, production cache, or production execution authority;
- loader/report status values are produced by the facade;
- future orchestrator acceptance changes are automatically public API policy
  without a review gate.

The only caller-facing supported shape is currently:

```text
nil
or
already-finalized compiler_profile_id_source Hash-like object
```

---

## Why The Facade Is Transport-Only

The Ruby facade is transport-only because it exists to expose a narrow
programmatic pass-through after assembler/orchestrator validation already owns
the safety boundary.

Transport-only means:

```text
the facade forwards the object unchanged
the facade preserves nil legacy behavior
the facade does not validate or reinterpret the object
the facade does not widen accepted source shapes
the facade does not own refusal vocabulary
```

The validation/refusal owner is:

```text
Assembler / orchestrator compiler-profile-source validation path
```

The facade owner is:

```text
Ruby API transport from caller to orchestrator
```

If a future card changes which source shapes the orchestrator accepts, the public
facade contract must be reviewed again before that wider acceptance is treated as
caller-facing API policy.

---

## Validation And Refusal Ownership

Current source validation/refusal reason codes are owned by the
assembler/orchestrator profile-source path, not by the facade:

| Condition | Reason code |
| --- | --- |
| descriptor/source missing | `compiler_profile_source.missing` |
| descriptor/source malformed | `compiler_profile_source.malformed` |
| wrong kind | `compiler_profile_source.wrong_kind` |
| unfinalized source | `compiler_profile_source.unfinalized` |
| unsupported namespace | `compiler_profile_source.unsupported_namespace` |
| malformed id | `compiler_profile_source.malformed_id` |
| digest mismatch | `compiler_profile_source.id_digest_mismatch` |
| slot order mismatch | `compiler_profile_source.slot_order_mismatch` |
| runtime authority flag present/true | `compiler_profile_source.runtime_authority_forbidden` |
| dispatch migration flag present/true | `compiler_profile_source.dispatch_migration_forbidden` |
| embedded profile id in finalization payload | `compiler_profile_source.payload_id_inclusion_forbidden` |

The facade may surface those failures through the compilation result, but it
does not mint the reason codes.

---

## Proposed Caller-Facing Source-Shape Wording

Recommended wording for the next caller-facing docs surface:

```text
`compiler_profile_source:` is an optional Ruby API keyword for advanced
PROP-036 callers. Pass `nil` (the default) to preserve legacy optional behavior
and produce artifacts without `compiler_profile_id`.

To emit `compiler_profile_id`, pass an already-finalized
`compiler_profile_id_source` Hash. The facade does not build this object. In the
current proof model, a finalized source has:

- `kind: "compiler_profile_id_source"`
- `format_version: "0.1.0"`
- `status: "finalized"`
- `profile_namespace: "compiler_profile_unified"`
- `compiler_profile_id: "compiler_profile_unified/sha256:<24+ lowercase hex>"`
- `descriptor_digest: "compiler_profile_descriptor/sha256:<24+ lowercase hex>"`
- `finalization_payload_digest: "sha256:<64 lowercase hex>"`
- `profile_kind: "Stage3ProofCompilerProfileSpec"`
- canonical `slot_order`
- finalized `slot_assignments`
- `dispatch_migration_authorized: false`
- `runtime_authority_granted: false`

Do not pass a file path, raw JSON string, raw `compiler_profile_id` string, or
unfinalized descriptor. Invalid non-nil sources are refused by the existing
compiler-profile-source validation path before profiled artifact output.
```

---

## Proposed Transport-Only Contract Wording

Recommended wording for the facade/API contract:

```text
`IgniterLang.compile` treats `compiler_profile_source:` as transport-only. It
forwards the value unchanged to `CompilerOrchestrator#compile`.

The facade does not validate, finalize, discover, infer, load, parse, normalize,
or default compiler profile sources. Validation and refusal are owned by the
orchestrator/assembler compiler-profile-source path.

Changing accepted source shapes is a public API contract change. A future card
that widens orchestrator/assembler validation must explicitly review whether the
Ruby facade should expose that widened shape to callers.
```

---

## Recommended Destination

| Destination | Recommendation | Reason |
| --- | --- | --- |
| Proposal errata | Not primary | PROP-036 semantics are already correct; this is caller API wording, not semantic errata. |
| Guide/API docs | Yes, next caller-facing destination | The gap is API ergonomics for `IgniterLang.compile`. |
| Dev contract doc | Yes, immediate destination | This track should be treated as the dev contract until guide/API docs are updated. |
| Source comment | Optional later | A short comment in `lib/igniter_lang.rb` would make transport-only visible near the code, but editing implementation/source comments needs a later authorization because this card is doc-only. |

Exact recommendation:

```text
1. Keep this track as the immediate dev contract.
2. Open a docs-only API guide card to add the source-shape and transport-only
   wording to the public Ruby facade docs.
3. Optionally open a tiny implementation-doc card to add a short source comment
   above `compiler_profile_source:` in `lib/igniter_lang.rb`.
4. Do not amend PROP-036 unless a future semantic change is proposed.
```

---

## Non-Authorized

This hardening track does not authorize:

- implementation edits;
- source comments in `lib/igniter_lang.rb`;
- CLI flags;
- CLI path or JSON loading;
- inline JSON parsing;
- profile discovery, inference, finalization, or defaulting in the facade;
- new accepted source shapes;
- loader/report implementation;
- CompatibilityReport compiler-profile section;
- `.igapp` or golden migration;
- `.ilk` changes;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- RuntimeMachine binding;
- Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP production executors;
- production cache;
- production behavior.

---

## Handoff

```text
Card: S3-R45-C2-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop036-facade-source-contract-hardening-v0
Status: done

[D] Decisions
- A finalized compiler_profile_source is the finalized
  compiler_profile_id_source Hash from the minimal finalization proof.
- The Ruby facade is transport-only: it forwards unchanged and owns no
  validation/refusal semantics.
- Validation/refusal belongs to the orchestrator/assembler source path.
- Future accepted source-shape widening needs facade/API review.

[S] Shipped / Signals
- Added compact caller-facing source-shape wording.
- Added transport-only contract wording.
- Recommended destination: dev contract now, guide/API docs next, optional
  source comment later, no PROP errata unless semantics change.

[T] Tests / Proofs
- Documentation-only track; no implementation or artifact changes.

[R] Risks / Recommendations
- NB-1 closes for dev contract wording, but public API docs still need a
  docs-only card.
- NB-2 closes as contract wording, but source-level visibility still needs a
  later authorized comment/doc card if desired.

[Next]
- Open a docs-only API guide card for `IgniterLang.compile`.
- Consider a tiny source-comment card only if Architect authorizes touching
  `lib/igniter_lang.rb`.
```
