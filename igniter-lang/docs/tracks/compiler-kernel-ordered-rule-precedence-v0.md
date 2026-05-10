# Track: Compiler Kernel Ordered Rule Precedence v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-kernel-ordered-rule-precedence-v0`
Status: done
Date: 2026-05-10

---

## Goal

Prove ordered rule registry semantics for a future profile-assembled
`igniter-lang` compiler before any compiler pass dispatch migration.

This slice is proof-local. It does not edit `Parser`, `Classifier`,
`TypeChecker`, `SemanticIREmitter`, `Assembler`, or `CompilerOrchestrator`. It
does not change `.igapp` format.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/compiler_kernel_ordered_rule_precedence.rb
igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json
```

The proof models two registry families:

| Registry kind | Intended use | Policy |
|---|---|---|
| Strict registry | OOF descriptors, fragment class ownership | One key, one owner. Duplicate keys are errors. |
| Ordered rule registry | Parser, Classifier, TypeChecker rule contributors | Multiple packs may contribute rules. Order is computed by `before`, `after`, and `priority`. |

Tie-break rule:

```text
priority, then rule_id
```

Missing references and cycles are errors.

---

## Positive Rule Model

The proof installs four capability packs:

```text
CoreLanguagePack
EscapeBoundaryPack
ContractModifiersPack
TemporalPack
```

It proves this parser order:

```text
contract_modifiers.parse_modifier_prefix
core.parse_contract_decl
```

It proves this classifier order:

```text
core.contract_fragment_default
escape.classify_escape_boundary
contract_modifiers.modifier_fragment_widening
contract_modifiers.oof_m1_pure_escape
temporal.temporal_precedence
```

This explicitly models the key precedence rule from the current modifier/temporal
surface:

```text
observed + temporal read -> temporal
```

It proves this typechecker order:

```text
core.typecheck_contract
contract_modifiers.propagate_oof_m1
temporal.typecheck_temporal_access
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `positive.dispatch_ordered_registry_only` | The profile does not dispatch compiler passes. |
| `positive.parser_modifier_before_contract` | Modifier prefix parsing runs before core contract parsing. |
| `positive.classifier_temporal_after_modifier` | Temporal precedence runs after modifier widening. |
| `positive.typechecker_order` | OOF-M1 propagation occurs before temporal access checking. |
| `positive.strict_oof_ownership` | OOF-M1 is strictly owned by `ContractModifiersPack`. |
| `positive.strict_fragment_ownership` | `temporal` is strictly owned by `TemporalPack`. |
| `positive.no_igapp_manifest_changes` | The proof records no `.igapp` changes. |
| `determinism.install_order_independent` | Reversing manifest install order produces the same ordered registries. |
| `determinism.profile_id_stable_for_same_rules` | Reversing manifest install order produces the same profile id. |
| `negative.missing_reference_rejected` | Missing `before`/`after` targets are rejected. |
| `negative.cycle_rejected` | Cyclic rule constraints are rejected. |
| `negative.duplicate_ordered_rule_rejected` | Duplicate ordered rule ids are rejected. |
| `negative.duplicate_strict_oof_rejected` | Duplicate strict OOF ownership is rejected. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/compiler_kernel_ordered_rule_precedence.rb
```

Result:

```text
PASS compiler_kernel_ordered_rule_precedence
positive.dispatch_ordered_registry_only: ok
positive.parser_modifier_before_contract: ok
positive.classifier_temporal_after_modifier: ok
positive.typechecker_order: ok
positive.strict_oof_ownership: ok
positive.strict_fragment_ownership: ok
positive.no_igapp_manifest_changes: ok
determinism.install_order_independent: ok
determinism.profile_id_stable_for_same_rules: ok
negative.missing_reference_rejected: ok
negative.cycle_rejected: ok
negative.duplicate_ordered_rule_rejected: ok
negative.duplicate_strict_oof_rejected: ok
profile_id: ordered_rule_profile/sha256:674d7b6d7512186d5031555d
summary: igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json
```

---

## Decisions

[D] Ordered rule registries should be deterministic by rule metadata, not pack
install order.

[D] Strict registries remain strict. OOF descriptor ownership and fragment class
ownership must reject duplicate owners.

[D] Ordered registries should support explicit `before`, `after`, and `priority`
metadata. Insertion order is not enough for parser/classifier/typechecker
semantics.

[D] Missing ordering references and cycles should fail at profile finalization
before any source compilation.

[D] Profile fingerprints should be based on normalized ordered registries. The
proof shows reversed install order can produce the same profile id when the rule
graph is equivalent.

---

## Risks

[R] The proof stores rule payloads as metadata. It does not model callable pass
handlers.

[R] The proof models parser/classifier/typechecker registries only. SemanticIR
and assembler hooks may need a mix of strict and ordered policies.

[R] Priority semantics are intentionally small: priority is only a tie-breaker
among currently available topological nodes. It should not override explicit
`before`/`after` edges.

[R] The exact temporal/modifier precedence is modeled from current behavior, but
broader fragment precedence still needs Architect/Compiler-Expert ratification.

---

## Next Recommended Slice

```text
Track: compiler-profile-id-manifest-boundary-plan-v0
Goal:
- Plan, but do not implement, how compiler_profile_id should enter .igapp.
Scope:
- Define manifest field shape candidates.
- Define compatibility behavior when field is absent.
- Define signed artifact / .ilk implications.
- Define how profile fingerprint differs from pack implementation_id.
- No .igapp changes yet.
Acceptance:
- Track doc with manifest field options.
- Recommendation for the first actual manifest PROP.
- Existing proof chain remains PASS.
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-kernel-ordered-rule-precedence-v0
Status: done

[D] Decisions:
- Ordered rule registries need before/after/priority semantics.
- Strict registries remain strict for OOF and fragment ownership.
- Install order must not define compiler semantics.
- Missing references and cycles fail before source compilation.

[S] Signals:
- Modifier parser rule can run before core contract parsing.
- Temporal classifier precedence can run after modifier widening.
- Reversed install order produces the same ordered registries and same profile id.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/compiler_kernel_ordered_rule_precedence.rb -> PASS

[R] Risks:
- Callable handler binding remains unmodeled.
- SemanticIR and assembler hook ordering still need policy.
- Fragment precedence remains a separate ratification question.

[Next]
- Plan compiler_profile_id manifest boundary before implementing .igapp changes.
```
