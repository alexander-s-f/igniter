# Track: Compiler Profile Validator Implementation Plan v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-validator-implementation-plan-v0`
Status: done
Date: 2026-05-11

---

## Goal

Plan the future compiler profile descriptor validator implementation surface
without writing validator code.

This track turns the descriptor schema, sharpened diagnostic taxonomy, and
profile syntax grammar boundary into an implementation-ready plan for a later
Implementation Agent slice.

It does not create `lib/` files, does not implement a validator, does not
authorize parser syntax, and does not change compiler dispatch, `.igapp`, or
`.ilk`.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_validator_implementation_plan/compiler_profile_validator_implementation_plan.rb
igniter-lang/experiments/compiler_profile_validator_implementation_plan/out/compiler_profile_validator_implementation_plan.json
igniter-lang/experiments/compiler_profile_validator_implementation_plan/out/compiler_profile_validator_implementation_plan_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_validator_implementation_plan/compiler_profile_validator_implementation_plan.rb
```

Result:

```text
PASS compiler_profile_validator_implementation_plan
```

The runner refreshes:

```text
compiler_profile_descriptor_schema
compiler_profile_descriptor_error_taxonomy_sharpening
profile_source_syntax_grammar_boundary
```

and composes them into a no-code implementation plan.

---

## Future Module Candidate

```text
path_candidate: igniter-lang/lib/igniter_lang/compiler_profile_validator.rb
namespace_candidate: IgniterLang::CompilerProfileValidator
owner_role: [Igniter-Lang Implementation Agent]
status: plan_only_not_created
```

[D] The path and namespace are candidates only. This Research slice does not
create the file.

---

## Validator Pipeline

[D] Future validator pipeline should follow the sharpened first-failure order:

```text
descriptor_shape
  -> slot_assignment
  -> pack_semantics
  -> registry_ordering
  -> canonicalize_and_fingerprint
```

### descriptor_shape

Input:

```text
raw descriptor hash
```

Codes:

```text
schema.missing_field
schema.wrong_kind
schema.full_language_source_out_of_scope
```

### slot_assignment

Codes:

```text
schema.unknown_slot
schema.duplicate_slot
schema.missing_required_slot
```

[D] Slot errors win before helper-only checks.

### pack_semantics

Codes:

```text
schema.missing_dependency_slot
schema.helper_only_pack_rejected
schema.rule_owner_mismatch
```

[D] `helper_only_pack_rejected` requires a known non-conflicting slot.

### registry_ordering

Codes:

```text
registry.duplicate_ordered_rule
registry.duplicate_strict_key
registry.missing_rule_reference
registry.rule_cycle
```

### canonicalize_and_fingerprint

Uses schema canonicalization rules and emits:

```text
compiler_profile_descriptor/sha256:<digest>
```

No runtime authority or evaluation readiness belongs in this step.

---

## Diagnostic Contract

Future validator result should include:

```json
{
  "status": "invalid",
  "code": "schema.duplicate_slot",
  "message": "human-readable text",
  "details": {
    "slot": "temporal"
  }
}
```

Rules:

```text
machine_code_required: true
human_message_required: true
details_required: true
first_failure_wins: true
```

Human message text may evolve. Machine codes should be stable.

---

## Public API Candidate

```text
validate(descriptor_hash) -> ValidationResult
canonicalize(valid_descriptor_hash) -> canonical_descriptor_hash
fingerprint(canonical_descriptor_hash) -> compiler_profile_descriptor/sha256:<digest>
```

[R] `validate` should be pure and must not mutate input.

[R] `canonicalize` should require a valid descriptor.

[R] `fingerprint` should require a canonical descriptor.

---

## Implementation Slice Order

Recommended future order:

```text
1. Add proof-local validator class in experiments mirroring this plan.
2. Move validator to lib only after Implementation Agent accepts scope.
3. Wire descriptor schema proof to use validator while preserving outputs.
4. Only later consider manifest/assembler integration after PROP approval.
```

---

## Still Blocked

```text
profile source parser syntax
profile syntax golden fixtures
manifest compiler_profile_id implementation
CompilerKernel dispatch rewrite
runtime profile compatibility enforcement
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.schema_passed` | Descriptor schema proof regenerated and passed. |
| `input.taxonomy_passed` | Diagnostic taxonomy proof regenerated and passed. |
| `input.grammar_boundary_passed` | Grammar boundary proof regenerated and passed. |
| `plan.no_code_status` | This is a no-code implementation plan. |
| `module.path_is_candidate_not_created` | Future module path is candidate only. |
| `pipeline.order_matches_taxonomy` | Pipeline follows first-failure taxonomy. |
| `diagnostics.machine_code_and_first_failure` | Diagnostic contract requires machine code and first failure. |
| `api.pure_validate_no_mutation` | API candidate keeps validation pure. |
| `blocked.manifest_and_parser_remain_blocked` | Parser and manifest implementation remain blocked. |
| `grammar_boundary.syntax_not_accepted` | Syntax is still not accepted. |
| `scope.no_lib_or_runtime_authority` | No lib file or runtime authority is introduced. |

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-validator-implementation-plan-v0
Status: done

[D] Decisions:
- Planned a future CompilerProfileValidator surface without implementing it.
- Validator pipeline follows descriptor_shape -> slot_assignment -> pack_semantics -> registry_ordering -> canonicalize_and_fingerprint.
- Diagnostic contract requires stable machine codes, human messages, details, and first-failure behavior.
- Candidate API is validate/canonicalize/fingerprint.

[S] Signals:
- Implementation Agent can later build a proof-local validator from this plan.
- Parser syntax, manifest compiler_profile_id, dispatch rewrite, and runtime enforcement remain blocked.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_validator_implementation_plan/compiler_profile_validator_implementation_plan.rb -> PASS

[R] Risks:
- Future lib extraction still needs Implementation Agent ownership.
- Registry error codes are target machine codes; current ordered-rule proof still observes Ruby class names.

[Next]
- Update closure index and tracks index.
- Good next Research slice: compiler-profile-manifest-prop-architect-routing-v0.
```
