# Track: Bootstrap Descriptor Kernel v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `bootstrap-descriptor-kernel-v0`
Status: done
Date: 2026-05-10

---

## Goal

Define and prove a minimal trusted seed for the self-assembly profile idea.

The `BootstrapDescriptorKernel` validates profile/pack descriptors and produces
a frozen, fingerprinted compiler profile manifest. It does not parse the full
Igniter-Lang language, typecheck user contracts, run compiler dispatch, touch
`.igapp`/`.ilk`, or authorize runtime execution.

---

## Added Proof

Added:

```text
igniter-lang/experiments/bootstrap_descriptor_kernel/bootstrap_descriptor_kernel.rb
igniter-lang/experiments/bootstrap_descriptor_kernel/out/bootstrap_compiler_profile_manifest.json
igniter-lang/experiments/bootstrap_descriptor_kernel/out/bootstrap_descriptor_kernel_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/bootstrap_descriptor_kernel/bootstrap_descriptor_kernel.rb
```

Result:

```text
PASS bootstrap_descriptor_kernel
```

The runner refreshes:

```text
igniter_lang_self_assembly_profile_sketch
```

then validates its descriptor model with a proof-local seed kernel.

---

## Seed Contract

The bootstrap seed owns only:

```text
descriptor_load
slot_validation
dependency_validation
rule_ownership_validation
profile_freeze
profile_id_digest
```

It explicitly does not own:

```text
full_language_parse
user_contract_typecheck
runtime_evaluate
ledger_or_tbackend_access
self_hosting_claim
```

[D] The seed is trusted and explicit. The architecture does not pretend to
remove its own first validator.

---

## Produced Manifest

The proof emits:

```json
{
  "kind": "bootstrap_compiler_profile_manifest",
  "dispatch_mode": "descriptor_validated_no_compiler_dispatch",
  "frozen": true,
  "authority": {
    "validates_descriptors": true,
    "parses_full_language": false,
    "self_hosted_compiler": false,
    "runtime_execution_authority": false
  }
}
```

Current proof profile id:

```text
bootstrap_compiler_profile/sha256:98222cdd7ce1497c90462165
```

---

## Validation Rules

The seed validates:

| Rule | Purpose |
|---|---|
| profile source must be descriptor-only | avoids full language parser overclaim |
| required slots present | prevents incomplete profiles |
| slot uniqueness | prevents competing packs in the same slot |
| slot dependencies | prevents packs from using absent capabilities |
| capability ownership | rejects helper-only packs |
| rule ownership | keeps rule ids owned by their semantic slot |
| deterministic profile id | stable under descriptor input order |

---

## Negative Cases

| Case | Rejection code |
|---|---|
| missing required core | `bootstrap.missing_required_slot` |
| duplicate temporal slot | `bootstrap.duplicate_slot` |
| helper-only pack | `bootstrap.unknown_slot` |
| missing dependency | `bootstrap.missing_required_slot` |
| rule owner mismatch | `bootstrap.rule_owner_mismatch` |
| full language source | `bootstrap.full_language_source_out_of_scope` |

The helper-only pack is rejected before capability ownership checks because it
uses an unknown slot. That is acceptable for this proof: it still cannot enter
the profile.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.self_assembly_passed` | Upstream self-assembly sketch passed. |
| `manifest.kind_and_frozen` | Output is a frozen bootstrap profile manifest. |
| `manifest.required_slots_present` | Required slots are present. |
| `manifest.seed_scope_explicit` | Seed scope is visible and does not parse full language. |
| `manifest.no_runtime_authority` | Manifest does not grant runtime execution authority. |
| `determinism.input_order_independent_profile_id` | Reordered descriptors produce the same profile id. |
| `negative.missing_required_core_rejected` | Missing core is rejected. |
| `negative.duplicate_temporal_rejected` | Duplicate temporal slot is rejected. |
| `negative.helper_only_pack_rejected` | Helper-only pack is rejected. |
| `negative.missing_dependency_rejected` | Missing dependency is rejected. |
| `negative.rule_owner_mismatch_rejected` | Wrong rule owner is rejected. |
| `negative.full_language_source_rejected` | Full language source demand is rejected. |

---

## Decisions

[D] `BootstrapDescriptorKernel` is the smallest honest seed for self-assembly:
it validates descriptors and computes profile identity, but owns no language
semantics beyond descriptor validation.

[D] Profile descriptors should be data-first before syntax-first. A future
profile source syntax can lower into this descriptor shape after Compiler/Grammar
approval.

[D] Capability ownership is enforced at the seed boundary. File/helper-only packs
must not become compiler packs.

[D] Rule ids belong to semantic slots. A temporal pack cannot register `core.*`
rules and still claim a clean profile.

---

## Open Questions

[Q] Should helper-only packs use an explicit `slot: none` rejection code instead
of falling into `unknown_slot`?

[Q] Should dependency validation report all missing slots at once, or fail at the
first profile-invalid condition?

[Q] Which parts of this seed become production `CompilerProfileSpec` and which
remain only in bootstrap tooling?

[Q] Should the bootstrap profile manifest become an input to
`CompilationReceipt`, or should the receipt embed only its digest/ref?

---

## Recommendation

[R] Treat this proof as the boundary for future self-assembly work:

```text
descriptor profile first
syntax later
self-describing first
self-hosted implementation much later
```

[R] Next formal work should split into two tracks:

```text
Compiler/Grammar: profile descriptor source syntax or descriptor schema
Research/Implementation: production-safe CompilerProfileSpec extraction
```

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: bootstrap-descriptor-kernel-v0
Status: done

[D] Decisions:
- BootstrapDescriptorKernel is an explicit trusted seed, not hidden self-hosting.
- It validates descriptor slots, dependencies, rule ownership, and profile id.
- It does not parse full Igniter-Lang, typecheck contracts, dispatch compiler
  passes, or authorize runtime execution.

[S] Signals:
- Self-assembly can be grounded in descriptor validation without overclaiming.
- Input order independence is proven for profile id.
- Negative cases reject incomplete, duplicate, helper-only, mismatched, and
  full-language-source profiles.

[T] Tests:
- ruby igniter-lang/experiments/bootstrap_descriptor_kernel/bootstrap_descriptor_kernel.rb -> PASS

[R] Risks:
- Descriptor schema is still proof-local.
- Profile source syntax is not authorized.
- Production placement of seed logic is unresolved.

[Next]
- Draft `compiler-profile-descriptor-schema-v0`: machine-readable descriptor
  schema, canonicalization rules, error codes, and relation to future syntax.
```
