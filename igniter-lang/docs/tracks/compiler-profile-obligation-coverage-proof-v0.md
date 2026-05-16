# Compiler Profile Obligation Coverage Proof v0

Card: S3-R56-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/compiler-profile-obligation-coverage-proof-v0
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - owns formal surface/slot semantics and future diagnostic vocabulary.
- [Igniter-Lang Bridge Agent] - future loader/report or package-facing pressure only; no bridge request in this slice.

---

## Scope

Build the proof-local, report-only `CompilerProfileObligationReport`
authorized by `S3-R55-C4-A`.

Read:

- `docs/gates/compiler-profile-next-axis-decision-v0.md`
- `docs/tracks/language-profile-compiler-obligation-map-v0.md`
- `docs/tracks/compiler-profile-contract-formalization-options-v0.md`
- `docs/discussions/compiler-profile-contract-pressure-v0.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/tracks/minimal-compiler-profile-finalization-proof-v0.md`
- `experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json`
- selected existing artifacts for core, temporal, stream, OLAP, invariant,
  assumptions, contract modifiers, and PROP-037 progression descriptors

No production compiler code changed. No existing goldens were mutated.

---

## Produced

```text
igniter-lang/experiments/compiler_profile_obligation_coverage_proof/
  compiler_profile_obligation_coverage_proof.rb
  out/compiler_profile_obligation_coverage_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_obligation_coverage_proof/compiler_profile_obligation_coverage_proof.rb
```

Observed output:

```text
PASS compiler_profile_obligation_coverage_proof
```

Syntax check:

```bash
ruby -c igniter-lang/experiments/compiler_profile_obligation_coverage_proof/compiler_profile_obligation_coverage_proof.rb
```

Observed output:

```text
Syntax OK
```

---

## Report Shape

The proof emits `CompilerProfileObligationReport` objects:

```json
{
  "kind": "compiler_profile_obligation_report",
  "format_version": "0.1.0",
  "case": "covered.full_finalized_source",
  "status": "covered",
  "profile_ref": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
  "profile_authority": {
    "compiler_understanding_only": true,
    "runtime_authority_granted": false,
    "dispatch_migration_authorized": false
  },
  "artifacts": [],
  "output_only": {
    "gates_igapp_emission": false,
    "changes_cli_exit_status": false,
    "changes_assembler_output": false,
    "touches_loader_report": false,
    "touches_compatibility_report": false,
    "touches_dispatch": false,
    "touches_runtime_machine": false,
    "touches_production_behavior": false
  }
}
```

Status vocabulary:

```text
covered
missing_slot
unsupported_surface
profile_not_supplied
```

This vocabulary is intentionally not loader/report vocabulary and not
`compiler_profile_source.*` assembler refusal vocabulary.

---

## Surface -> Slot Rules

Proof-local v0 mapping:

| Surface | Required profile slots |
| --- | --- |
| `core` | `core`, `oof_registry`, `fragment_registry`, `pipeline` |
| `escape_boundary` | `escape_boundary`, `fragment_registry`, `oof_registry` |
| `contract_modifiers` | `contract_modifiers`, `oof_registry`, `fragment_registry`, `escape_boundary` |
| `temporal` | `temporal`, `fragment_registry`, `escape_boundary`, `oof_registry`, `pipeline` |
| `stream` | `stream`, `fragment_registry`, `escape_boundary`, `oof_registry` |
| `olap` | `olap`, `fragment_registry`, `oof_registry` |
| `invariant` | `invariant`, `oof_registry`, `evidence_observation` |
| `assumptions` | `assumptions`, `fragment_registry`, `oof_registry`, `evidence_observation`, `pipeline` |
| `progression_descriptor` | `pipeline`, `stream`, `evidence_observation`, `oof_registry` |

PROP-037 progression metadata remains under `pipeline` for v0. No new
`progression` slot was introduced.

---

## Evidence Table

Covered case uses the current finalized source:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json
```

| Fixture / artifact | Detected surfaces | Required slots | Status |
| --- | --- | --- | --- |
| `runtime_smoke_post_switch_full_coverage/out/core_add_compute.igapp/semantic_ir_program.json` | `contract_modifiers`, `core` | `contract_modifiers`, `core`, `escape_boundary`, `fragment_registry`, `oof_registry`, `pipeline` | `covered` |
| `contract_modifiers_proof/golden/observed_contract_basic.semantic_ir.json` | `contract_modifiers`, `core`, `escape_boundary` | `contract_modifiers`, `core`, `escape_boundary`, `fragment_registry`, `oof_registry`, `pipeline` | `covered` |
| `runtime_smoke_post_switch_full_coverage/out/history_single_axis.igapp/semantic_ir_program.json` | `contract_modifiers`, `core`, `escape_boundary`, `temporal` | `contract_modifiers`, `core`, `escape_boundary`, `fragment_registry`, `oof_registry`, `pipeline`, `temporal` | `covered` |
| `runtime_smoke_post_switch_full_coverage/out/stream_fold.igapp/semantic_ir_program.json` | `contract_modifiers`, `core`, `escape_boundary`, `stream` | `contract_modifiers`, `core`, `escape_boundary`, `fragment_registry`, `oof_registry`, `pipeline`, `stream` | `covered` |
| `runtime_smoke_post_switch_full_coverage/out/olap_point.igapp/semantic_ir_program.json` | `contract_modifiers`, `core`, `olap` | `contract_modifiers`, `core`, `escape_boundary`, `fragment_registry`, `olap`, `oof_registry`, `pipeline` | `covered` |
| `runtime_smoke_post_switch_full_coverage/out/invariant_severity.igapp/semantic_ir_program.json` | `contract_modifiers`, `core`, `invariant` | `contract_modifiers`, `core`, `escape_boundary`, `evidence_observation`, `fragment_registry`, `invariant`, `oof_registry`, `pipeline` | `covered` |
| `assumptions_proof/golden/assumption_basic.semantic_ir.json` | `assumptions`, `contract_modifiers`, `core`, `escape_boundary` | `assumptions`, `contract_modifiers`, `core`, `escape_boundary`, `evidence_observation`, `fragment_registry`, `oof_registry`, `pipeline` | `covered` |
| `prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof_summary.json` | `progression_descriptor` | `evidence_observation`, `oof_registry`, `pipeline`, `stream` | `covered` |

Guard cases:

| Case | Input | Expected / observed status |
| --- | --- | --- |
| `covered.full_finalized_source` | full finalized source + selected artifacts above | `covered` |
| `missing_slot.temporal_removed` | synthetic copy of finalized source with `temporal` removed + History artifact | `missing_slot` |
| `profile_not_supplied.core_add` | nil profile + CORE Add artifact | `profile_not_supplied` |
| `unsupported_surface.synthetic_unknown_node` | synthetic `future_surface_node` guard artifact | `unsupported_surface` |

The unsupported case is a detector guard only. It does not define or propose a
new language surface.

---

## Checks

The summary records these checks as PASS:

```text
covered.case_status
covered.includes_core
covered.includes_contract_modifiers
covered.includes_temporal
covered.includes_stream
covered.includes_olap
covered.includes_invariant
covered.includes_assumptions
covered.includes_progression_descriptor
missing_slot.case_status
missing_slot.names_temporal
profile_not_supplied.case_status
unsupported_surface.case_status
unsupported_surface.names_node_kind
output_only.no_runtime_authority
output_only.no_dispatch_migration
output_only.flags_all_false
output_only.selected_artifact_digests_unchanged
```

The digest check covers selected existing artifacts read by the proof. The proof
writes only its own summary under its `out/` directory.

---

## Output-Only Behavior

Proved in this slice:

- `.igapp` emission is not gated.
- CLI exit status is not changed.
- assembler output is not changed.
- loader/report is untouched.
- CompatibilityReport is untouched.
- compiler dispatch is untouched.
- RuntimeMachine is untouched.
- production behavior is untouched.

The proof is a reporting artifact over existing outputs, not a compiler pass.

---

## Remaining Blockers Before Implementation Authorization

1. Pressure review of report shape and status vocabulary.
2. Formal owner decision for whether obligation coverage belongs before compile,
   after emit, or before assembly.
3. Stable diagnostic namespace for future implementation, likely
   `compiler_profile_obligation.*`, distinct from:
   - `compiler_profile_source.*`
   - loader/report status vocabulary
   - future `compiler_profile_contract.*`
4. Decision on whether PROP-037 progression remains under `pipeline` or gets a
   future explicit `progression` slot.
5. Exact implementation write-scope authorization from Architect.
6. Golden/fixture mutation policy if obligation reports become persisted
   compiler artifacts.
7. Explicit statement that obligation coverage does not grant runtime readiness.

---

## Non-Authorizations Preserved

This proof does not authorize:

- compile refusal based on obligation coverage;
- `.igapp` emission changes;
- CLI behavior changes or widening;
- profile discovery/defaulting/finalization in public surfaces;
- golden migration;
- loader/report implementation;
- CompatibilityReport compiler-profile section;
- `.ilk`;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- pack loading;
- RuntimeMachine / Gate 3 widening;
- Ledger/TBackend;
- BiHistory live execution;
- stream/OLAP production execution;
- cache;
- production behavior.

---

## Handoff

```text
Card: S3-R56-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/compiler-profile-obligation-coverage-proof-v0
Status: done

[D] Decisions
- Implemented obligation coverage as proof-local/report-only Ruby experiment.
- Used selected existing SemanticIR/progression artifacts; no goldens mutated.
- Kept PROP-037 progression descriptor metadata under `pipeline` for v0.
- Used a synthetic unknown-node artifact only to prove `unsupported_surface`.

[S] Signals
- Full finalized profile source covers selected current Stage 2/3 surfaces.
- Removing `temporal` from a synthetic source produces `missing_slot`.
- Missing profile source produces `profile_not_supplied`.
- Unknown future node produces `unsupported_surface`.
- Output-only flags and artifact digest checks stayed clean.

[T] Tests / Checks
- `ruby igniter-lang/experiments/compiler_profile_obligation_coverage_proof/compiler_profile_obligation_coverage_proof.rb` -> PASS
- `ruby -c igniter-lang/experiments/compiler_profile_obligation_coverage_proof/compiler_profile_obligation_coverage_proof.rb` -> Syntax OK
- Summary:
  `igniter-lang/experiments/compiler_profile_obligation_coverage_proof/out/compiler_profile_obligation_coverage_summary.json`

[R] Risks / Recommendations
- Run pressure review before implementation authorization.
- Decide eventual placement: pre-compile, post-emit, or pre-assembly.
- Keep report vocabulary separate from loader/report and assembler source
  refusal vocabulary.

[Next]
- Candidate next review: `compiler-profile-obligation-coverage-pressure-v0`.
- Candidate later design: `compiler-profile-contract-boundary-v0`, informed by
  this proof's surface/slot evidence.
```
