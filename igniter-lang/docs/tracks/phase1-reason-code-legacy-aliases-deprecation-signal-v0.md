Card: S3-R23-C3-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/phase1-reason-code-legacy-aliases-deprecation-signal-v0
Status: done
Date: 2026-05-09

---

# Track: Phase 1 Reason Code Legacy Aliases Deprecation Signal v0

## Purpose

Prepare the runtime diagnostics surface to move away from `LEGACY_ALIASES` before
Phase 2 / operator tooling by:

1. Proving all three scope-exclusion alias constants now resolve to `SCOPE_EXCLUSION`
2. Proving the executor emits only `runtime.temporal_scope_exclusion` (no legacy strings)
3. Adding an in-code deprecation comment to `LEGACY_ALIASES` naming the migration path
4. Documenting which existing fixtures still hardcode the old strings and why they
   must not be retroactively updated

---

## Source Signals

- `lib/igniter_lang/temporal_executor.rb` (current lib/ boundary)
- `docs/discussions/runtime-temporal-executor-lib-prep-safety-pressure-v0.md` (S3-R17-X1-S, C-2)
- `docs/tracks/temporal-executor-proof-local-docstring-amendment-v0.md` (S3-R18-C2-P)

---

## Findings: Current Reason Code State

### Canonical constants (lib/)

| Constant | Value |
|----------|-------|
| `SCOPE_EXCLUSION` | `"runtime.temporal_scope_exclusion"` (canonical) |
| `NON_TEMPORAL` | alias → `SCOPE_EXCLUSION` |
| `BIHISTORY_EXCLUDED` | alias → `SCOPE_EXCLUSION` |
| `CORE_REFUSAL` | alias → `SCOPE_EXCLUSION` |

### LEGACY_ALIASES map (lib/)

Maps old string literals to `SCOPE_EXCLUSION` for callers that hardcode them:

| Old string | Maps to |
|------------|---------|
| `"runtime.non_temporal_not_covered"` | `"runtime.temporal_scope_exclusion"` |
| `"runtime.temporal_executor_bihistory_excluded"` | `"runtime.temporal_scope_exclusion"` |
| `"runtime.temporal_executor_core_refusal"` | `"runtime.temporal_scope_exclusion"` |

### Files that still hardcode the old strings

These are **sealed proof artifacts** from their respective tracks. They contain
their own inline executor classes (not the lib/ class) that emitted the old codes
at proof time. They must not be retroactively updated — changing them would
falsify the evidence from those tracks.

| File | Old string | Track |
|------|-----------|-------|
| `experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb` | all three | S3-R14-C2-P |
| `experiments/temporal_executor_composition_integration/temporal_executor_composition_integration.rb` | bihistory + core | S3-R15-C2-P |
| `experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb` | non_temporal | earlier |

No non-experiment code outside `lib/` hardcodes the old strings. The lib/ executor
does not emit them — proven by 21/21 checks below.

---

## Decisions

### [D] LEGACY_ALIASES comment added — deprecation signal in-code

Added a deprecation comment directly above `LEGACY_ALIASES` in
`lib/igniter_lang/temporal_executor.rb`:

```ruby
# Deprecated string literals from pre-S3-R18-C2-P experiment fixtures.
# The lib/ executor emits SCOPE_EXCLUSION for all three scenarios — these old
# strings are NOT emitted. S3-R14-C2-P and S3-R15-C2-P experiments that check
# the old strings are sealed proof artifacts; do not retroactively update them.
# Phase 2 migration: remove this constant once all non-experiment callers are
# verified to use ReasonCode::SCOPE_EXCLUSION or "runtime.temporal_scope_exclusion".
LEGACY_ALIASES = { ... }.freeze
```

### [D] Sealed fixtures not modified

The three experiment files that hardcode old strings are proof artifacts for
completed tracks. They use their own inline executor classes, not the lib/ class.
Modifying them would invalidate the evidence from S3-R14-C2-P and S3-R15-C2-P.

### [D] Proof covers all three scenarios explicitly

The new proof (`phase1_reason_code_legacy_aliases_deprecation_signal.rb`) adds
checks that no prior proof covered:
- `executor.non_temporal.no_legacy_string` — confirms old string NOT emitted at scope
- `executor.bihistory.no_legacy_string` — confirms old string NOT emitted at AT-7
- `executor.core_scope.no_legacy_string` — confirms old string NOT emitted at scope/AT-12
- All `LEGACY_ALIASES` map integrity checks (frozen, size, key coverage)

---

## Shipped

- `lib/igniter_lang/temporal_executor.rb` — deprecation comment on `LEGACY_ALIASES`
- `experiments/phase1_reason_code_legacy_aliases_deprecation_signal/phase1_reason_code_legacy_aliases_deprecation_signal.rb`
  — 21-check proof (unit aliases + LEGACY_ALIASES map + executor emission per scenario)

---

## Proof Results

```bash
ruby igniter-lang/experiments/phase1_reason_code_legacy_aliases_deprecation_signal/phase1_reason_code_legacy_aliases_deprecation_signal.rb
```

```text
PASS phase1_reason_code_legacy_aliases_deprecation_signal
  unit.scope_exclusion_is_canonical:   ok
  unit.non_temporal_alias:             ok
  unit.bihistory_excluded_alias:       ok
  unit.core_refusal_alias:             ok
  unit.all_three_identical:            ok
  legacy.frozen:                       ok
  legacy.size:                         ok
  legacy.non_temporal_mapped:          ok
  legacy.bihistory_mapped:             ok
  legacy.core_refusal_mapped:          ok
  legacy.no_stray_keys:                ok
  executor.non_temporal.blocked:       ok
  executor.non_temporal.scope_exclusion: ok
  executor.non_temporal.blocked_at_scope: ok
  executor.non_temporal.no_legacy_string: ok
  executor.bihistory.blocked:          ok
  executor.bihistory.scope_exclusion:  ok
  executor.bihistory.no_legacy_string: ok
  executor.core_scope.blocked:         ok
  executor.core_scope.scope_exclusion: ok
  executor.core_scope.no_legacy_string: ok

21/21 PASS
```

Lib-prep regression unchanged: 17/17 PASS.

---

## Migration Recommendation for Phase 2

### Pre-condition

Before removing `LEGACY_ALIASES`:

1. Run the audit command to find all non-experiment callers:
   ```bash
   grep -r "runtime\.non_temporal_not_covered\|runtime\.temporal_executor_bihistory_excluded\|runtime\.temporal_executor_core_refusal" igniter-lang/
   ```
   Expected result: only sealed experiment fixtures (S3-R14-C2-P, S3-R15-C2-P, load guard).
   Any result outside `experiments/` must be updated before removal.

2. Confirm all live/non-proof callers use `ReasonCode::SCOPE_EXCLUSION` or the
   canonical string `"runtime.temporal_scope_exclusion"` directly.

### Migration steps

1. Audit non-experiment callers (command above).
2. Replace any remaining legacy string literals with `ReasonCode::SCOPE_EXCLUSION`.
3. Remove the `LEGACY_ALIASES` constant (one block deletion in `ReasonCode` module).
4. Re-run the audit command; expect no matches outside sealed fixtures.

### What NOT to do

- Do not update `experiments/temporal_executor_phase1_preflight/*.rb` — sealed proof artifact.
- Do not update `experiments/temporal_executor_composition_integration/*.rb` — sealed proof artifact.
- Do not remove `LEGACY_ALIASES` before the audit confirms no live callers remain.

### Timing

`LEGACY_ALIASES` removal is a Phase 2 housekeeping task. It does not block Phase 1
proof-local use and does not block the live-read decision addendum. Route after
`gate3-live-read-decision-addendum-v0` is issued and before any production deployment
that would surface reason codes to operator tooling.

---

## Handoff

```text
Card: S3-R23-C3-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/phase1-reason-code-legacy-aliases-deprecation-signal-v0
Status: done

[D] Decisions
- LEGACY_ALIASES deprecation comment added in lib/: names sealed fixtures, migration path, Phase 2 timing
- Sealed experiment fixtures (S3-R14-C2-P, S3-R15-C2-P, load guard) not modified
- New proof explicitly verifies no_legacy_string for all three scenarios (first explicit coverage)

[S] Shipped
- lib/igniter_lang/temporal_executor.rb (LEGACY_ALIASES deprecation comment)
- experiments/phase1_reason_code_legacy_aliases_deprecation_signal/phase1_reason_code_legacy_aliases_deprecation_signal.rb

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/phase1_reason_code_legacy_aliases_deprecation_signal/phase1_reason_code_legacy_aliases_deprecation_signal.rb
- result: PASS (21/21)
- command: ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
- result: PASS (17/17 — lib-prep regression unaffected)

[R] Risks
- None introduced — comment-only addition to lib/; new proof file only
- Sealed fixtures are correctly identified; no retroactive modification risk
- LEGACY_ALIASES removal deferred to Phase 2 (after live-read addendum)

[Q] Open questions
- None new

[Next] Suggested next slice
- gate3-live-read-decision-addendum-v0 (R1 — Architect decision for non-proof live reads)
- phase1-backend-identity-guard-v0 (C-1 — backend class constraint, pre-Phase-2)
- compatibility-report-persistence-audit-v0 (R3 — AT-10 persistence gap)
```
