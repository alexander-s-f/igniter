# Track: Compiler Profile Contract Schema And Rule Ownership Pressure v0

Card: S3-R59-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `compiler-profile-contract-schema-and-rule-ownership-pressure-v0`
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Meta Expert]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Decide whether the R58 `compiler_profile_contract` proof shape is formal enough
to open new PROP authoring, and identify exact formal blockers if not.

This is a pressure/design review only. It does not author a PROP and does not
authorize implementation.

---

## Inputs Read

- `docs/gates/compiler-profile-contract-proof-decision-v0.md`
- `docs/tracks/compiler-profile-contract-proof-v0.md`
- `docs/discussions/compiler-profile-contract-proof-pressure-v0.md`
- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `docs/gates/compiler-profile-contract-boundary-decision-v0.md`
- `docs/tracks/stage3-round58-status-curation-v0.md`

---

## Verdict

```text
PROP authoring: hold
Recommended next route: more proof, narrow proof-evolution card
Implementation authorization: held
```

The R58 proof shape is strong enough to treat `compiler_profile_contract` as a
real behavioral contract object, not merely prose. It is not yet formal enough
to open new PROP authoring because several validator branches are part of the
proof validator but have no proof cases.

The largest formal blocker is:

```text
compiler_profile_contract.missing_rule_reference
```

Reason: ordered-rule graph references are central to the proposed contract. A
PROP should not freeze ordered-rule semantics while the missing-reference path
is unexercised.

The shape/digest validator paths are smaller but still should be covered before
PROP authoring because they define the front door of the contract object:

```text
wrong_kind
unsupported_format_version
descriptor_digest_invalid
finalization_payload_digest_invalid
```

`profile_not_supplied.required_slots` positional derivation does not block PROP
authoring if it is explicitly recorded as proof-evolution debt and not used as
normative semantics.

---

## Formal Clearance / Blocker Table

| Area | R58 evidence | Formal ownership decision | Clearance for PROP authoring | Blocker / next action |
| --- | --- | --- | --- | --- |
| Required slot schema | Canonical object includes `required_slot_schema` with required `core`, `oof_registry`, `fragment_registry`, `escape_boundary`; missing required slot case passes | Compiler/Grammar owns schema semantics; Research may prove coverage; Architect authorizes changes | Mostly clear | PROP text can use this schema after validator front-door paths are covered. |
| Slot order | Canonical object includes 12-slot `slot_order` matching PROP-036 baseline | Compiler/Grammar owns normative order; later dispatch migration remains separate | Clear | State order is identity/validation order, not live dispatch. |
| Slot assignments | Canonical object includes implementation id and pack name per slot; source projection matches current finalized source | Compiler/Grammar owns meaning as declared compiler-understanding ownership; Implementation owns any later runtime code path only if authorized | Clear with scope | PROP must say assignment is not handler execution or dispatch authority. |
| Strict registries | Canonical object includes `oof_descriptors` and `fragment_class_owners` | Compiler/Grammar owns registry key space and owner-slot semantics | Clear enough for PROP after one-owner wording | Need PROP wording that registries are closed within the contract object, not globally closed forever. |
| One-owner registry semantics | `duplicate_strict_key` case passes for `oof_descriptors`; missing slot case exercises `unknown_owner_slot` | Compiler/Grammar owns one key / one owner invariant | Mostly clear | Optional proof extension may duplicate a `fragment_class_owners` key, but not required before PROP if invariant is stated registry-general. |
| Ordered rule graph | Canonical object includes parse/classify/typecheck/emit rules with `before` and `after` refs | Compiler/Grammar owns graph well-formedness and stage vocabulary; Implementation owns later dispatcher if authorized | Not fully clear | Need `missing_rule_reference` proof case before PROP authoring. |
| Rule cycle semantics | `rule_cycle` case passes and pressure review confirms DFS-detected cycle | Compiler/Grammar owns acyclicity requirement | Clear | PROP can state ordered graph must be acyclic. |
| Rule reference semantics | Validator branch exists for missing `before`/`after` refs; no proof case | Compiler/Grammar owns reference validity | Blocked | Add proof case for missing `before` or `after` target and expected diagnostic. |
| Non-authority flags | Runtime and dispatch migration forbidden cases pass | Compiler/Grammar owns language/compiler meaning; Architect owns authorization gates | Clear | PROP must preserve no runtime authority and no dispatch migration. |
| Diagnostic namespace separation | R58 checks prove loader/source terms absent and `missing_required_slot != missing_slot != missing_required` | Compiler/Grammar owns contract diagnostic vocabulary | Clear | Keep `compiler_profile_contract.*` distinct from all other namespaces. |
| Future `profile_not_supplied` shape | R58 proves `required_slots` populated and `missing_slots` empty | Compiler/Grammar owns design meaning; Research owns proof evolution mechanics | Clear for PROP semantics | Positional derivation is proof-only debt; fix before implementation, not before PROP. |

---

## Ownership Decisions

### Required Slot Schema

Decision:

```text
Compiler/Grammar owns the formal required slot schema.
```

The current required slots are:

```text
core
oof_registry
fragment_registry
escape_boundary
```

They are required because a compiler profile without them cannot claim even
baseline compiler understanding. Optional slots remain surface-specific:

```text
contract_modifiers
temporal
stream
olap
invariant
assumptions
evidence_observation
pipeline
```

PROP text should say `missing_required_slot` means the contract object is not
well-formed. It is not the same as an obligation coverage failure.

### Slot Order

Decision:

```text
Compiler/Grammar owns slot order as canonical profile contract order.
```

Slot order remains identity/validation material and future dispatch-order
material. It does not migrate current compiler dispatch.

### Slot Assignments

Decision:

```text
Slot assignments are declared compiler-understanding ownership, not execution
authority.
```

Each assignment may carry an `implementation_id` and `pack_name`, but in this
contract stage that means "the profile claims this slot is understood by this
declared owner." It does not mean the compiler is dynamically loading or calling
that pack.

### Strict Registries

Decision:

```text
Compiler/Grammar owns strict registry semantics.
```

Strict registry means:

```text
within one registry, one key must have exactly one owner entry
```

Examples:

- one OOF descriptor key has one owner slot;
- one fragment class key has one owner slot.

The strict registry is closed within the contract object being validated. This
does not claim the global language can never add new keys in later proposals.

### One-Owner Registry Semantics

Decision:

```text
one-owner is a contract invariant, not a dispatch rule.
```

The invariant prevents a profile from claiming two owners for the same OOF code
or fragment class. It does not decide which handler runs at runtime.

### Ordered Rule Graph

Decision:

```text
Compiler/Grammar owns ordered-rule graph well-formedness.
```

The graph vocabulary in the proof is:

```text
rule_id
stage
owner_slot
before
after
```

The PROP should not require a live dispatcher. It should require graph
well-formedness: known rule references, owner slot present in `slot_order`, and
acyclic ordering.

### Rule Cycle Semantics

Decision:

```text
rule_cycle means the directed ordering graph is cyclic.
```

Both `before` and `after` create directed edges:

```text
rule.before target  => rule must run before target
rule.after source   => source must run before rule
```

The accepted R58 proof validates this with a concrete cycle.

### Rule Reference Semantics

Decision:

```text
missing_rule_reference must be proof-covered before PROP authoring.
```

This branch is too central to ordered-rule semantics to defer. A missing
`before` or `after` target changes the meaning of the graph itself.

---

## Untested Validator Paths

| Validator path | Layer | Need proof before PROP authoring? | Reason |
| --- | --- | --- | --- |
| `compiler_profile_contract.wrong_kind` | Contract object front door | Yes | PROP should not define a contract object without proving wrong-kind refusal shape. |
| `compiler_profile_contract.unsupported_format_version` | Contract object versioning | Yes | Version support is normative schema surface. |
| `compiler_profile_contract.descriptor_digest_invalid` | Descriptor identity | Yes | Digest validity is part of the contract's identity bridge. |
| `compiler_profile_contract.finalization_payload_digest_invalid` | Source projection / finalization bridge | Yes | Finalization digest validates the bridge to `compiler_profile_id_source`. |
| `compiler_profile_contract.missing_rule_reference` | Ordered-rule graph | Yes, highest priority | Rule references are core formal graph semantics. |

Recommendation:

```text
Open a narrow proof-evolution card that adds five cases and no new semantics.
```

Suggested case names:

```text
wrong_kind
unsupported_format_version
descriptor_digest_invalid
finalization_payload_digest_invalid
missing_rule_reference
```

Expected effect:

```text
R58 proof shape remains unchanged.
Only proof coverage becomes complete enough for PROP authoring review.
```

---

## `profile_not_supplied.required_slots` Derivation

R58 semantic design is correct:

```text
status: profile_not_supplied
required_slots: populated
missing_slots: []
```

The proof implementation derives `required_slots` through a positional reference
into the R56 obligation summary. That is fragile under proof evolution, but it
is not a language semantic.

Decision:

```text
This does not block PROP authoring if explicitly recorded as proof-only debt.
```

Required future cleanup:

```text
Select the obligation report by case/status, not array position.
```

Recommended timing:

```text
Fix in the same narrow proof-evolution card as the untested validator paths if
convenient; otherwise fix before implementation authorization.
```

Do not make PROP authoring depend on this specific proof-script cleanup unless
the future PROP intends to cite the derivation mechanism, which it should not.

---

## PROP-037 Progression Slot

This track preserves the current v0 decision:

```text
progression_descriptor remains under pipeline
```

No new `progression` slot is authorized or implied.

The future dedicated `progression` slot question remains separate and should not
block compiler-profile contract PROP authoring if the PROP states that v0 uses
the existing `pipeline` slot.

---

## Recommended Next Route

Recommended route:

```text
more proof
```

Specific next card:

```text
compiler-profile-contract-validator-coverage-proof-v0
```

Scope:

- add proof cases for the five untested validator paths;
- optionally replace positional `profile_not_supplied.required_slots` lookup
  with named/status lookup;
- preserve all existing R58 diagnostics and namespace separation;
- do not add implementation behavior;
- do not author PROP text.

After that proof lands and is accepted:

```text
new PROP authoring can be opened by a separate Architect decision
```

The PROP route should be a new PROP, not a PROP-036 errata. PROP-036 owns
manifest identity and finalized source transport. `compiler_profile_contract`
owns contract object schema, strict registries, ordered rules, and validation
order.

---

## Blockers Before PROP Authoring

| Blocker | Severity | Closure condition |
| --- | --- | --- |
| Untested `missing_rule_reference` | blocking | Add proof case showing missing `before` or `after` target emits `compiler_profile_contract.missing_rule_reference`. |
| Untested front-door schema paths | blocking | Add proof cases for wrong kind, unsupported format version, invalid descriptor digest, and invalid finalization payload digest. |
| Formal ordered-rule reference semantics | blocking until covered | State and prove that every `before` / `after` target must resolve to a declared rule id. |
| Required slot schema ownership | clear | Already assigned to Compiler/Grammar; include in future PROP. |
| Strict registry one-owner semantics | clear | Already formal enough; optional duplicate fragment-owner case may improve confidence but is not required before PROP. |
| Rule cycle semantics | clear | R58 proof case covers cycle detection. |
| Positional `required_slots` derivation | non-blocking proof debt | Record as proof-only debt; fix before implementation or in the next proof if convenient. |
| PROP-037 progression slot | non-blocking for this PROP | Keep progression descriptor under `pipeline` in v0; dedicated slot requires later Architect decision. |
| Architect PROP-authoring authorization | blocking governance | A later Architect decision must open PROP authoring after validator coverage proof lands. |

---

## Non-Authorization

This track does not authorize:

- PROP authoring;
- implementation in production compiler paths;
- compile refusal based on obligation coverage or contract validation;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` changes;
- CLI/API widening;
- profile discovery/defaulting/finalization in public surfaces;
- golden migration;
- loader/report implementation or schema;
- CompatibilityReport implementation or schema;
- `.ilk`;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- pack loading;
- RuntimeMachine / Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP production execution;
- cache;
- production behavior.

---

## Handoff

```text
Card: S3-R59-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: compiler-profile-contract-schema-and-rule-ownership-pressure-v0
Status: done

[D] Decisions
- New PROP authoring should remain held for now.
- Compiler/Grammar owns required slot schema, slot order, slot assignments as
  declared ownership, strict registries, one-owner semantics, ordered-rule graph
  well-formedness, rule cycle semantics, and rule reference semantics.
- `missing_rule_reference` needs proof coverage before PROP authoring.
- Wrong kind, unsupported format version, invalid descriptor digest, and invalid
  finalization payload digest also need proof cases before PROP authoring.
- Positional `profile_not_supplied.required_slots` derivation is proof-only
  debt, not a PROP-authoring blocker.

[S] Signals
- R58 proof shape is behavioral and close to PROP-ready.
- The remaining blockers are narrow validator coverage gaps, not broad design
  confusion.
- PROP-037 progression remains under pipeline for v0.

[T] Tests / Proofs
- Documentation-only pressure track.
- No code or artifact checks required beyond doc validation.

[R] Recommendation
- Open `compiler-profile-contract-validator-coverage-proof-v0` next.
- After that proof lands and is accepted, request separate Architect
  authorization for new PROP authoring.

[Next]
- Add proof cases for the five untested validator paths and keep all
  implementation, loader/report, dispatch, and production surfaces closed.
```
