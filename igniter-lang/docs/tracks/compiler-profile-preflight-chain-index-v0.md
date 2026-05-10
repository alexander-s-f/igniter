# Track: Compiler Profile Preflight Chain Index v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-preflight-chain-index-v0`
Status: done
Date: 2026-05-10

---

## Goal

Index the proof-local compiler profile / pack architecture chain so future
post-POC migration work has one command that checks the current foundation.

This slice does not implement `CompilerKernel`, `CompilerPack`, production
dispatch, or `.igapp` manifest changes.

---

## Added Proof Index

Added:

```text
igniter-lang/experiments/compiler_profile_preflight_chain_index/compiler_profile_preflight_chain_index.rb
igniter-lang/experiments/compiler_profile_preflight_chain_index/out/compiler_profile_preflight_chain_index_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_preflight_chain_index/compiler_profile_preflight_chain_index.rb
```

Result:

```text
PASS compiler_profile_preflight_chain_index
```

---

## Indexed Proof Matrix

| Proof | Scope | Boundary |
|---|---|---|
| `compiler_pack_shadow_profile_proof` | shadow profile | current monolith described as deterministic profile |
| `contract_modifiers_pack_native_boundary` | pack candidate | first optional semantic pack boundary |
| `compiler_kernel_pack_registry_spike` | kernel model | install/finalize/fingerprint model |
| `compiler_kernel_ordered_rule_precedence` | ordering model | `before` / `after` / `priority` with cycle detection |
| `compiler_profile_id_manifest_boundary` | manifest plan | `compiler_profile_id` before artifact hash/signing |
| `compiler_profile_slots_model` | profile spec | semantic slots and pack cardinality |
| `compiler_profile_spec_and_rule_unification` | unified profile | slots + ordered rules in one fingerprint |
| `compiler_profile_authority_boundary` | authority boundary | understanding authority is not runtime authority |
| `compiler_profile_compatibility_report_fields` | report shape | profile status separate from runtime readiness |

---

## Cross-Checks

The preflight runner verifies:

| Check | Meaning |
|---|---|
| `chain.all_commands_exited_zero` | Every indexed proof command exits successfully. |
| `chain.all_summaries_pass` | Every generated summary reports `PASS`. |
| `chain.required_boundaries_indexed` | No expected foundation slice is missing from the index. |
| `profile.unified_id_reaches_authority_boundary` | The unified profile id is consumed by the authority boundary proof. |
| `profile.manifest_plan_requires_reassembly_before_signing` | Manifest proof keeps hash/signature ordering explicit. |
| `ordering.cycle_and_missing_reference_guards_present` | Rule ordering rejects cycles and missing refs. |
| `authority.compiler_profile_never_authorizes_runtime` | Compiler profile identity never grants runtime execution. |
| `report.profile_status_separate_from_runtime_readiness` | CompatibilityReport fields stay separated. |
| `report.verified_temporal_still_blocked` | Verified temporal metadata-only profile remains blocked. |
| `scope.shadow_and_pack_proofs_present` | The chain includes both monolith-shadow and first-pack candidate evidence. |

---

## Decisions

[D] The profile/pack foundation is now an indexed proof chain, not just a set of
separate background experiments.

[D] `CompilerProfile` should continue to mean signed/fingerprinted compiler
understanding authority, not plugin loading and not runtime execution authority.

[D] Capability-owned packs remain the right decomposition axis. The index keeps
file/helper-only decomposition out of the target path by anchoring pack work to
semantic slots and registered rule ownership.

[D] Ordering semantics are first-class in the target architecture: insertion
order alone is not enough for parser/classifier/typechecker migration.

---

## Migration Blockers

| Blocker | Status | Reason |
|---|---|---|
| `manifest_prop_required` | blocked | `compiler_profile_id` remains proof-local until a manifest PROP and assembler migration are approved. |
| `dispatch_kernel_not_authorized` | blocked | Current compiler dispatch remains monolithic until post-POC migration authorization. |
| `ordered_registry_contract_not_canonical` | open | Ordering semantics are proven, but not yet a production `CompilerKernel` API. |
| `compatibility_report_field_names_not_production` | open | `compiler_profile_status` and `runtime_evaluation_readiness` are proposed proof-local field names. |

---

## Recommendation

[R] Use this preflight runner as the background guard before any future
CompilerKernel / CompilerPack migration slice.

[R] The next useful foundation slice is a manifest PROP draft for
`compiler_profile_id`, because the proof chain now has enough evidence to say
where the field belongs and what it must not authorize.

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-preflight-chain-index-v0
Status: done

[D] Decisions:
- Indexed the compiler profile / pack foundation as one proof chain.
- Kept all outputs proof-local: no dispatch, manifest, runtime, or .igapp changes.
- Preserved the authority split: compiler profile id proves understanding, not execution.

[S] Signals:
- 9/9 indexed proof commands PASS.
- Cross-checks link unified profile id, manifest hash ordering, ordered-rule guards,
  runtime authority boundary, and CompatibilityReport field separation.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_preflight_chain_index/compiler_profile_preflight_chain_index.rb -> PASS

[R] Risks:
- The target architecture is ready for proposal pressure, not implementation migration.
- `compiler_profile_id` still needs a manifest PROP before assembler output changes.

[Next]
- Draft `PROP-033` or equivalent for `compiler_profile_id` manifest semantics:
  field placement, hash/signature ordering, legacy absence policy, and report behavior.
```
