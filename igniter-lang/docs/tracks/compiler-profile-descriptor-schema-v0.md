# Track: Compiler Profile Descriptor Schema v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-descriptor-schema-v0`
Status: done
Date: 2026-05-10

---

## Goal

Define a proof-local, machine-readable descriptor contract for compiler profiles
and packs.

This slice does not authorize profile source syntax, does not introduce a JSON
Schema dependency, does not extract production `BootstrapDescriptorKernel`, and
does not change compiler dispatch, `.igapp`, or `.ilk`.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_descriptor_schema/compiler_profile_descriptor_schema.rb
igniter-lang/experiments/compiler_profile_descriptor_schema/out/compiler_profile_descriptor_schema.json
igniter-lang/experiments/compiler_profile_descriptor_schema/out/canonical_profile_descriptor.json
igniter-lang/experiments/compiler_profile_descriptor_schema/out/compiler_profile_descriptor_schema_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_descriptor_schema/compiler_profile_descriptor_schema.rb
```

Result:

```text
PASS compiler_profile_descriptor_schema
```

The runner refreshes:

```text
bootstrap_descriptor_kernel
```

then derives and validates a canonical descriptor from the self-assembly model.

---

## Descriptor Kinds

The schema models four descriptor kinds:

| Descriptor | Required fields |
|---|---|
| `profile_descriptor` | `kind`, `format_version`, `profile_spec`, `profile_source`, `pack_descriptors` |
| `profile_source` | `kind`, `format_version`, `parser_status`, `canonical_source_digest` |
| `profile_spec` | `kind`, `name`, `slot_order`, `required_slots`, `optional_slots` |
| `pack_descriptor` | `slot`, `name`, `implementation_id`, `capability_owner`, `provides_capabilities`, `requires_slots`, `registries` |

The only currently accepted `profile_source.parser_status` is:

```text
not_implemented_descriptor_only
```

That keeps the contract data-first and syntax-neutral.

---

## Canonicalization

[D] Descriptor identity should be deterministic before profile syntax exists.

Current proof rules:

| Surface | Rule |
|---|---|
| hash algorithm | `sha256` |
| object keys | lexicographic |
| pack descriptors | sort by `profile_spec.slot_order`, then pack name |
| `slot_order` | preserve order |
| required/optional slots | sort |
| capabilities/dependencies | sort |
| registry entries | sort |
| digest prefix | `compiler_profile_descriptor/sha256:` |

Current canonical descriptor digest:

```text
compiler_profile_descriptor/sha256:6ee9c9c82ee1604b98a07f75
```

The proof confirms descriptor digest is stable when pack descriptors are input in
reverse order.

---

## Error Taxonomy

| Error code | Meaning |
|---|---|
| `schema.missing_field` | Required field is absent. |
| `schema.wrong_kind` | Descriptor kind does not match schema. |
| `schema.full_language_source_out_of_scope` | Profile source demands full language parser. |
| `schema.unknown_slot` | Pack uses a slot not declared by profile spec. |
| `schema.duplicate_slot` | Two packs fill the same slot. |
| `schema.missing_required_slot` | Required slot has no pack. |
| `schema.missing_dependency_slot` | Pack requires a missing slot. |
| `schema.helper_only_pack_rejected` | Pack has no semantic capability ownership. |
| `schema.rule_owner_mismatch` | Rule id prefix belongs to another semantic slot. |

Observed negative results:

| Case | Code |
|---|---|
| missing profile spec | `schema.missing_field` |
| wrong kind | `schema.wrong_kind` |
| full language source status | `schema.full_language_source_out_of_scope` |
| duplicate slot | `schema.duplicate_slot` |
| helper-only pack in occupied slot | `schema.duplicate_slot` |
| rule owner mismatch | `schema.rule_owner_mismatch` |

The helper-only case currently fails as `duplicate_slot` because it attempts to
occupy `compiler_accountability`. A future formal schema may add `slot: none` or
change validation order if a more precise diagnostic is required.

---

## Bridge To Future Syntax

[D] Future profile source syntax should lower into this descriptor shape.

Current bridge flags:

```json
{
  "profile_source_syntax_authorized": false,
  "descriptor_first": true,
  "future_lowering_target": "compiler_profile_descriptor"
}
```

This gives Compiler/Grammar a clean target without granting syntax authority in
this Research slice.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.bootstrap_passed` | Upstream bootstrap descriptor kernel passed. |
| `schema.has_descriptor_kinds` | All four descriptor kinds are present. |
| `schema.has_error_taxonomy` | Error codes match the expected taxonomy. |
| `descriptor.has_digest_and_schema_ref` | Canonical descriptor has digest and schema ref. |
| `canonicalization.input_order_independent_digest` | Reversed pack input yields same descriptor digest. |
| `canonicalization.pack_order_matches_slot_order` | Canonical pack order follows slot order. |
| `bridge.future_syntax_not_authorized` | Syntax remains unauthorized; descriptor-first is explicit. |
| negative checks | Missing/wrong/full-language/duplicate/helper/rule-mismatch cases reject. |

---

## Decisions

[D] The descriptor schema is a proof-local contract, not a production JSON Schema
claim.

[D] Canonicalization rules belong beside the schema, because descriptor identity
is meaningless without deterministic ordering.

[D] Error codes should be machine-readable and distinct from human message text.

[D] Future profile syntax should target `compiler_profile_descriptor`, not bypass
the descriptor validation path.

---

## Open Questions

[Q] Should this become a real JSON Schema document, a Ruby validator, or an
Igniter-Lang descriptor contract first?

[Q] Should helper-only packs be modeled with `slot: none` to preserve the more
specific `schema.helper_only_pack_rejected` code?

[Q] Should `rule_prefix -> slot` mapping live in the schema, the bootstrap seed,
or `CompilerProfileSpec`?

[Q] Should descriptor digest include the schema digest directly, or should schema
compatibility be checked separately?

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-descriptor-schema-v0
Status: done

[D] Decisions:
- Profile/pack descriptors now have a proof-local machine-readable schema.
- Canonicalization rules are part of the schema contract.
- Future profile syntax remains unauthorized and should lower into descriptors.
- Error taxonomy is machine-readable.

[S] Signals:
- Canonical descriptor digest is stable under pack input reordering.
- Schema refs are hashable.
- Negative cases reject missing fields, wrong kind, full language source demand,
  duplicate slots, helper-only collision, and rule owner mismatch.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_descriptor_schema/compiler_profile_descriptor_schema.rb -> PASS

[R] Risks:
- This is not a production JSON Schema yet.
- Helper-only diagnostics need a sharper formal choice.
- Rule-prefix ownership location is still open.

[Next]
- Draft `profile-source-lowering-target-v0`: define how future profile syntax
  would lower into this descriptor schema without authorizing parser work yet.
```
