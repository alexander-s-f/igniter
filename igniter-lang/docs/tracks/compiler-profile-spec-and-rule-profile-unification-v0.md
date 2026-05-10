# Track: Compiler Profile Spec and Rule Profile Unification v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-spec-and-rule-profile-unification-v0`
Status: done
Date: 2026-05-10

---

## Goal

Combine the proof-local `CompilerProfileSpec` slot model with ordered rule
registry output into one unified compiler profile fingerprint.

This slice does not dispatch compiler passes, implement production
`CompilerProfile`, edit compiler implementation, or change `.igapp`.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_profile_spec_and_rule_unification/compiler_profile_spec_and_rule_unification.rb
igniter-lang/experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json
```

The proof reads:

```text
igniter-lang/experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json
igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json
```

and produces:

```text
kind: compiler_profile_unified
profile_id: compiler_profile_unified/sha256:...
```

---

## Unified Profile Inputs

The unified profile includes:

- `profile_spec_name`
- `profile_spec_digest`
- canonical slot assignments
- ordered parser/classifier/typechecker registries
- strict OOF and fragment registries
- source profile ids:
  - `slot_profile_id`
  - `ordered_rule_profile_id`

It validates that:

- strict registry owners have corresponding slots
- ordered rule prefixes map to filled slots
- unknown helper-only rule owners are rejected
- no `.igapp` manifest changes are declared

---

## Why This Matters

Before this slice, the architecture had two separate proof identities:

```text
compiler_profile_slots/sha256:...
ordered_rule_profile/sha256:...
```

That is useful for research, but not sufficient for future artifacts. A real
`.igapp` cannot carry two loosely related identities and expect loaders to infer
the composition.

This slice proves the future target:

```text
compiler_profile_unified/sha256:...
```

One ID changes when either:

- a slot implementation changes, or
- the ordered compiler rule graph changes.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `positive.profile_kind` | The output is a unified compiler profile. |
| `positive.no_validation_errors` | Slot assignments and rule owners agree. |
| `positive.dispatch_unified_profile_only` | The proof does not dispatch compiler passes. |
| `positive.no_igapp_manifest_changes` | The profile declares no `.igapp` changes. |
| `positive.strict_owners_have_slots` | OOF/fragment owners are present in slots. |
| `positive.ordered_rules_have_slots` | Ordered rule prefixes map to filled slots. |
| `fingerprint.slot_implementation_change_changes_profile` | Replacing temporal implementation changes unified ID. |
| `fingerprint.ordered_rule_graph_change_changes_profile` | Changing rule graph changes unified ID. |
| `negative.unknown_rule_owner_rejected_by_validation` | Helper-only rule prefix is rejected. |
| `lineage.source_profile_ids_recorded` | Unified profile records source slot/rule profile ids. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_spec_and_rule_unification/compiler_profile_spec_and_rule_unification.rb
```

Result:

```text
PASS compiler_profile_spec_and_rule_unification
positive.profile_kind: ok
positive.no_validation_errors: ok
positive.dispatch_unified_profile_only: ok
positive.no_igapp_manifest_changes: ok
positive.strict_owners_have_slots: ok
positive.ordered_rules_have_slots: ok
fingerprint.slot_implementation_change_changes_profile: ok
fingerprint.ordered_rule_graph_change_changes_profile: ok
negative.unknown_rule_owner_rejected_by_validation: ok
lineage.source_profile_ids_recorded: ok
profile_id: compiler_profile_unified/sha256:2944e573270aa56fca51cea3
summary: igniter-lang/experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json
```

---

## Decisions

[D] Future `compiler_profile_id` should be the unified profile id, not the slot
profile id alone and not the ordered rule profile id alone.

[D] Slot validation should run before ordered rule profile finalization. A rule
whose owner does not map to an allowed filled slot is invalid.

[D] The unified profile should preserve source IDs for audit/debugging, but
artifact compatibility should key off the unified ID.

[D] Helper-only rule owners remain rejected. A rule contributor must belong to a
semantic capability slot or an explicit kernel service slot.

---

## Risks

[R] Rule owner mapping currently uses rule id prefixes (`temporal.*`,
`contract_modifiers.*`). Production should use explicit owner metadata instead
of parsing rule ids.

[R] The unified profile still stores descriptors, not callable handlers.

[R] SemanticIR and assembler hook registries are not yet part of the ordered
rule proof. They should enter before any profile ID is written to real `.igapp`.

[R] The profile spec and rule graph are proof-local and not canonical docs yet.

---

## Next Recommended Slice

```text
Track: compiler-profile-authority-boundary-v0
Goal:
- Separate compiler understanding authority from runtime execution authority.
Scope:
- Define what compiler_profile_id proves.
- Define what it explicitly does not prove.
- Map compiler profile slots to runtime CompatibilityReport fields.
- Include TEMPORAL profile examples: metadata-only vs Ledger-backed.
- No .igapp changes.
- No runtime executor changes.
Acceptance:
- Track doc + proof-local decision table.
- Existing profile foundation proofs remain PASS.
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-profile-spec-and-rule-profile-unification-v0
Status: done

[D] Decisions:
- Unified compiler profile ID should combine slot assignments and ordered rules.
- Source slot/rule profile IDs remain lineage, not the artifact-facing identity.
- Rule owners must map to filled semantic slots.
- Helper-only rule owners are invalid.

[S] Signals:
- Changing Temporal implementation changes unified profile id.
- Changing ordered classifier rules changes unified profile id.
- Unknown parser helper rule owner is rejected.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_profile_spec_and_rule_unification/compiler_profile_spec_and_rule_unification.rb -> PASS

[R] Risks:
- Rule owner mapping should become explicit metadata.
- Callable handler binding remains unmodeled.
- SemanticIR/assembler hook registries still need inclusion.

[Next]
- Route compiler-profile-authority-boundary-v0.
```
