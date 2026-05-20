# Track: PROP-038 Strict Refusal Canon Sync v0

Card: S3-R85-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-strict-refusal-canon-sync-v0`
Route: UPDATE
Status: done
Date: 2026-05-20

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Synchronize PROP-038 and nearby compiler-profile canon text with the R84
accepted live internal foundation, without widening behavior.

This is a docs-only canon sync. It does not edit code, authorize public
exposure, widen runtime behavior, create new strict sources, mutate `.igapp`,
or change loader/report, CompatibilityReport, RuntimeMachine, Gate 3, runtime,
or production behavior.

---

## Inputs Read

- `docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md`
- `docs/gates/prop038-strict-refusal-live-implementation-authorization-review-v0.md`
- `docs/tracks/prop038-strict-refusal-live-implementation-v0.md`
- `docs/discussions/prop038-strict-refusal-live-implementation-pressure-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/current-status.md`
- `docs/tracks/README.md`
- `docs/gates/README.md`

---

## Changed Docs

| Path | Change |
| --- | --- |
| `docs/proposals/PROP-038-compiler-profile-contract-v0.md` | Added R84 strict-refusal live internal foundation canon; replaced stale absolute "compile refusal remains closed" language with internal-only/public-closed distinction; added R83/R84 evidence; preserved excluded surfaces. |
| `docs/current-status.md` | Updated last-updated date and added R85 canon-sync note under Compiler Internals and PROP-038 status. |
| `docs/tracks/README.md` | Added Stage 3 Round 85 evidence entry and updated last-updated date. |
| `docs/tracks/prop038-strict-refusal-canon-sync-v0.md` | This handoff track. |

No gate decision document was changed. `docs/gates/README.md` already recorded
the R84 acceptance accurately and did not need a semantic edit.

---

## Drift Points Found And Fixed

### D1. PROP-038 still treated compile refusal as fully closed

Previous PROP text said:

```text
live validator implementation remains held
compile refusal remains closed
```

That was stale after R74 and R84. The sync now states:

```text
live validator diagnostics are implemented inside the internal validator
bounded internal-only strict refusal is accepted as a live internal foundation
public/runtime/production refusal remains closed
```

### D2. Contract digest diagnostics versus strict refusal authority

The sync makes the authority split explicit:

```text
contract_digest diagnostics alone do not authorize refusal
orchestrator-level strict requirement decision path is authority
validator output is evidence, not authority
```

### D3. R84 properties were not canonized in PROP-038

PROP-038 now records:

- strict source is internal constructor/test seam only;
- nested `compile_refusal_authorized: false` remains report-only marker;
- `report.pass_result == "ok"` remains invariant for strict terminal paths;
- `refused` and `configuration_error` share the exact accepted 13-key public
  key-set;
- strict terminal paths are non-persisting/no-sidecar/no-report/no-`.igapp`;
- public API/CLI, loader/report, CompatibilityReport, RuntimeMachine/Gate 3,
  runtime, and production remain closed.

### D4. Proof evidence stopped before live foundation

PROP-038 proof evidence now cites R74 validator implementation and R83/R84
strict-refusal live implementation/acceptance evidence, while preserving that
public exposure and production authority are still closed.

---

## Canon After Sync

Current PROP-038 canon:

```text
compiler_profile_contract validation diagnostics
  -> nested report-only validation evidence
  -> optional internal-only orchestrator strict requirement decision path
  -> non-persisting strict terminal CompilerResult when selected
```

The accepted strict terminal statuses are:

```text
refused
configuration_error
```

Both statuses expose exactly:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
contracts
compilation_report_path
diagnostics
warnings
```

No public strict source exists.

---

## Remaining Doc / Spec Gaps

| Gap | Status |
| --- | --- |
| Public Ruby API / CLI strict source semantics | Closed; needs separate design/gate if ever opened. |
| Loader/report or CompatibilityReport strict status | Closed; needs separate design/gate if ever opened. |
| Persisted refusal report policy | Closed; R84 path is non-persisting. |
| Ch5/Ch7 spec wording for internal strict refusal | Not changed here; optional future spec sync if agents start routing from spec chapters instead of PROP/status. |
| Proposal index status labels | No change; PROP-038 remains proposal canon with accepted bounded internal implementation evidence, not production/runtime authority. |

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
- new live behavior;
- public API/CLI widening;
- env/config/manifest/default/generated strict source lookup;
- loader/report or CompatibilityReport behavior;
- persisted reports or sidecars;
- `.igapp` mutation;
- parser, TypeChecker, SemanticIR, assembler changes;
- `IgniterLang::Diagnostics` centralization;
- RuntimeMachine, Gate 3, runtime, or production behavior.

---

## Recommendation For C4-A

Recommendation:

```text
accept sync
```

Reason:

- R84 accepted live internal foundation is now visible in PROP-038 canon;
- stale absolute "compile refusal closed" language is replaced with the correct
  internal-only/public-closed boundary;
- nearby current-status and track index navigation now point to the sync;
- no behavior, authority, public exposure, or runtime surface was widened.
