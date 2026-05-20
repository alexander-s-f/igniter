# Compiler Pack Shadow Profile Proof v1

Card: LANG-R91 / S3-R91-C1-P1
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Track: compiler-pack-shadow-profile-proof-v1
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Status: done
Date: 2026-05-20
Authority: proof-only / non-implementation / non-dispatch / non-production

---

## Goal

Refresh the existing shadow compiler profile proof against the R90 boundary map,
accepted PROP-032 assumptions state, PROP-036 bounded optional profile source
transport, and R84/R86 PROP-038 strict-terminal/spec-sync state, without
dispatching compiler passes through packs.

This track does not authorize implementation.

---

## Read Set

- `igniter-lang/docs/tracks/stage3-round90-status-curation-v0.md`
- `igniter-lang/docs/gates/compiler-pack-boundary-report-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-pack-boundary-report-v0.md`
- `igniter-lang/docs/tracks/compiler-pack-boundary-proof-fixture-and-oof-survey-v0.md`
- `igniter-lang/docs/tracks/compiler-pack-shadow-profile-proof-v0.md`
- `igniter-lang/experiments/compiler_pack_shadow_profile_proof/compiler_pack_shadow_profile_proof.rb`
- `igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json`

---

## Proof Work

Added a separate v1 proof-local experiment:

```text
igniter-lang/experiments/compiler_pack_shadow_profile_proof_v1/compiler_pack_shadow_profile_proof_v1.rb
igniter-lang/experiments/compiler_pack_shadow_profile_proof_v1/out/compiler_pack_shadow_profile_proof_v1_summary.json
```

The v1 proof preserves the v0 shadow intent but updates the model for current
R90 state:

- `AssumptionsPack` is now modeled as current compiler surface shadow, with
  PROP-033 evidence validation still closed.
- `compiler_profile_id` is modeled as optional when explicit
  `compiler_profile_source` is supplied; mandatory transition, discovery,
  defaulting, and golden migration remain closed.
- `CompilerProfileContractPack` is modeled as support-boundary evidence only,
  not a language pack and not refusal authority.
- PROP-038 strict terminal is modeled as internal-only, non-persisting,
  no-sidecar, no-`.igapp`, and public API/CLI closed.
- `compiler_profile_contract.*` and `compiler_profile_contract_refusal.*` are
  explicitly not OOF namespaces.
- Spark is recorded as applied-pressure only, not compiler authority.

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_pack_shadow_profile_proof_v1/compiler_pack_shadow_profile_proof_v1.rb
```

Result:

```text
PASS compiler_pack_shadow_profile_proof_v1
checks: 18/18 PASS
profile_id: compiler_profile_shadow_v1/sha256:34db3eb4dbe36e18f8e6dd73
summary: igniter-lang/experiments/compiler_pack_shadow_profile_proof_v1/out/compiler_pack_shadow_profile_proof_v1_summary.json
```

Checks:

| Check | Result |
| --- | --- |
| `profile.kind` | PASS |
| `profile.dispatch_mode_shadow` | PASS |
| `profile.id_deterministic` | PASS |
| `r90.proof_only_boundary_preserved` | PASS |
| `prop032.assumptions_current_surface` | PASS |
| `prop036.optional_profile_id_reality_recorded` | PASS |
| `prop038.strict_terminal_internal_only` | PASS |
| `packs.unique_names` | PASS |
| `packs.dependencies_satisfied` | PASS |
| `packs.implementation_ids_present` | PASS |
| `oof.codes_unique` | PASS |
| `oof.required_codes_owned` | PASS |
| `oof.profile_contract_diagnostics_not_oof` | PASS |
| `fragments.required_classes_owned` | PASS |
| `fragments.precedence_candidate_complete` | PASS |
| `igapp.no_manifest_or_golden_mutation` | PASS |
| `shadow.no_runtime_authorization` | PASS |
| `closed_surfaces.all_preserved` | PASS |

---

## PASS Summary

The v1 proof demonstrates that the current monolithic compiler can be described
as a deterministic shadow profile with:

- `dispatch_mode: shadow_no_dispatch`;
- 13 pack/support-boundary units;
- deterministic profile id;
- unique pack names and satisfied dependencies;
- OOF ownership coverage for the required R90 OOF set;
- fragment ownership coverage for `core`, `escape`, `stream`, `temporal`,
  `epistemic`, and `oof`;
- no `.igapp` manifest or golden mutation;
- no runtime authorization;
- all R90 closed surfaces preserved.

---

## Blockers Before Future Pack Design / Implementation

Implementation remains blocked.

Before any pack design becomes implementation-oriented, the lane needs:

1. Pressure review / Architect acceptance of this v1 proof.
2. A richer OOF descriptor schema beyond ownership-only data:
   stage, severity, public message stability, aliases, deprecation policy.
3. A resolved fragment registry model:
   whether `oof` is a fragment, status, or both; and whether the candidate
   precedence is acceptable.
4. A decision whether `OOFRegistry`, `FragmentRegistry`, and
   `CompilerProfileContractPack` are kernel services, installed packs, or
   support metadata.
5. A separate proof/design route for ordered rule conflicts before any parser or
   classifier dispatch migration.
6. A separate Architect implementation authorization with exact write scope
   before any code changes.

---

## Recommended Next Compiler Route

Recommendation:

```text
oof-fragment-registry-shadow-proof-v0
```

Route type:

```text
proof-only
```

Why:

- v1 proves ownership coverage, but only at registry-owner level.
- The next risk is not pack list completeness; it is registry semantics:
  descriptor shape, aliases, public-code stability, and fragment/status
  precedence.
- This route should precede any `ContractModifiersPack` adapter proof or native
  pack-shaped migration slice.

Backup:

```text
prop038-strict-terminal-regression-hardening-v0
```

Use the backup only if the team wants to harden accepted strict-terminal
success/no-assembly/no-persistence invariants before continuing pack registry
work.

---

## Preserved Closed Surfaces

This proof does not authorize:

- code implementation;
- compiler implementation;
- `CompilerKernel` implementation;
- pack registry implementation;
- live pack dispatch;
- profile-assembled compiler migration;
- parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator rewrites;
- public API/CLI widening;
- public strict source;
- `IgniterLang.compile` signature changes;
- profile discovery/defaulting/finalization;
- mandatory `compiler_profile_id` transition;
- `.igapp` golden or manifest migration;
- `.ilk` profile references;
- CompilationReceipt links;
- loader/report compiler-profile status;
- CompatibilityReport compiler-profile section;
- compile refusal beyond the accepted internal-only strict terminal foundation;
- persisted strict terminal reports or sidecars;
- `CompilerResult` public shape changes;
- Ch6 or other spec edits;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend binding;
- BiHistory production evaluation;
- stream/OLAP production executors;
- production cache;
- signing or production verification;
- production deployment;
- progression scheduler/materializer/durable queue/checkpoint;
- Spark fixture/spec work;
- Spark production integration;
- treating Spark applied pressure as compiler authority.

---

## Handoff

```text
Status: done / PASS
Claim: compiler-pack-shadow-profile-proof-v1 passes as proof-only shadow profile
  refresh and preserves all R90 closed surfaces.
Evidence: v1 proof runner, summary JSON, this track.
Changed files: v1 experiment script, v1 summary JSON, this track, Portfolio
  report packet.
Risks / drift: ownership proof is not descriptor schema proof; fragment
  precedence is candidate-only; no implementation can be inferred.
Cross-lane requests: none; Spark remains separate applied-pressure.
Next: oof-fragment-registry-shadow-proof-v0 as proof-only route.
```
