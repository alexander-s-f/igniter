# Track: Compiler Profile Descriptor Error Taxonomy Sharpening v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-descriptor-error-taxonomy-sharpening-v0`
Status: done
Date: 2026-05-11

---

## Goal

Sharpen the future compiler profile descriptor diagnostic taxonomy so
Implementation Agent has a stable first-failure rule before implementing a real
validator.

This track does not mutate the descriptor schema, does not implement production
validation, does not change compiler dispatch, and does not change `.igapp` or
`.ilk`.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_descriptor_error_taxonomy_sharpening/compiler_profile_descriptor_error_taxonomy_sharpening.rb
igniter-lang/experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out/compiler_profile_descriptor_error_taxonomy.json
igniter-lang/experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out/compiler_profile_descriptor_error_taxonomy_sharpening_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_descriptor_error_taxonomy_sharpening/compiler_profile_descriptor_error_taxonomy_sharpening.rb
```

Result:

```text
PASS compiler_profile_descriptor_error_taxonomy_sharpening
```

The runner refreshes:

```text
compiler_profile_descriptor_schema
compiler_profile_slots_model
compiler_kernel_ordered_rule_precedence
```

and composes their negative-case evidence into one diagnostic precedence model.

---

## Diagnostic Precedence

[D] First failing layer wins:

```text
descriptor_shape
  -> slot_assignment
  -> pack_semantics
  -> registry_ordering
```

### descriptor_shape

Wins before slot, pack, and registry checks:

```text
schema.missing_field
schema.wrong_kind
schema.full_language_source_out_of_scope
```

### slot_assignment

Wins before pack semantics and registry checks:

```text
schema.unknown_slot
schema.duplicate_slot
schema.missing_required_slot
```

[D] A pack cannot be judged semantically until its slot is known, unique, and
required slots are present.

### pack_semantics

Runs after valid slot assignment:

```text
schema.missing_dependency_slot
schema.helper_only_pack_rejected
schema.rule_owner_mismatch
```

[D] `schema.helper_only_pack_rejected` is emitted only for a known,
non-conflicting slot. If the helper pack uses an unknown slot or collides with an
occupied slot, the slot error wins.

### registry_ordering

Runs after descriptor identity and pack ownership are valid:

```text
registry.duplicate_ordered_rule
registry.duplicate_strict_key
registry.missing_rule_reference
registry.rule_cycle
```

---

## Scenario Matrix

| Scenario | Expected diagnostic |
|---|---|
| helper pack asks for an unknown slot | `schema.unknown_slot` |
| helper pack collides with an occupied slot | `schema.duplicate_slot` |
| helper pack is in a known available slot but owns no capability | `schema.helper_only_pack_rejected` |
| assumptions pack appears without contract_modifiers | `schema.missing_dependency_slot` |
| temporal pack registers a core-prefixed rule | `schema.rule_owner_mismatch` |
| ordered rule references a missing rule | `registry.missing_rule_reference` |
| ordered rule graph cycles | `registry.rule_cycle` |

Observed current evidence:

```text
helper-only collision -> schema.duplicate_slot
assumptions without modifiers -> MissingSlotDependencyError
temporal/core rule owner mismatch -> schema.rule_owner_mismatch
missing ordered-rule reference -> MissingRuleReferenceError
ordered-rule cycle -> RuleCycleError
```

---

## Implementation Guidance

```text
first_failure_wins: true
do_not_collapse_slot_errors_into_helper_errors: true
do_not_run_registry_ordering_before_slot_validation: true
helper_only_specific_error_requires_known_non_conflicting_slot: true
future_validator_should_emit_machine_code_and_human_message: true
```

[R] A future production validator should preserve machine codes independently
from human diagnostic text.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.descriptor_schema_passed` | Descriptor schema proof regenerated and passed. |
| `input.slots_model_passed` | Slots model proof regenerated and passed. |
| `input.ordered_rule_precedence_passed` | Ordered rule proof regenerated and passed. |
| `precedence.shape_before_slots_before_semantics_before_registry` | Layer order is explicit. |
| `precedence.duplicate_slot_wins_over_helper_collision` | Helper collision keeps duplicate-slot diagnostic. |
| `precedence.helper_only_specific_case_documented` | Specific helper-only case is defined. |
| `precedence.dependency_before_registry` | Dependency failure wins before registry ordering. |
| `precedence.rule_owner_mismatch_after_slot_checks` | Ownership mismatch runs after slot checks. |
| `registry.missing_reference_and_cycle_documented` | Ordered registry graph failures are documented. |
| `guidance.first_failure_wins` | Future validator guidance is explicit. |
| `scope.no_runtime_authority` | No runtime authority is introduced. |

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-descriptor-error-taxonomy-sharpening-v0
Status: done

[D] Decisions:
- Diagnostic precedence is descriptor_shape -> slot_assignment -> pack_semantics -> registry_ordering.
- Slot errors win over helper-only semantics.
- helper_only_pack_rejected requires a known non-conflicting slot.
- Registry graph diagnostics run only after descriptor/slot/pack ownership checks pass.

[S] Signals:
- Current helper-only collision behavior is justified as duplicate_slot, not a bug.
- Missing dependency, rule owner mismatch, missing reference, and cycle cases have stable routing.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_descriptor_error_taxonomy_sharpening/compiler_profile_descriptor_error_taxonomy_sharpening.rb -> PASS

[R] Risks:
- Production validator still needs implementation later.
- Registry error codes are named here as target machine codes; existing proof uses Ruby class names.

[Next]
- Update closure index and tracks index.
- Continue with profile-source-syntax-compiler-review-v0 or manifest PROP Architect routing.
```
