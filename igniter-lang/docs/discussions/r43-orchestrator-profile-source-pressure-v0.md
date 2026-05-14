# R43 Orchestrator Profile Source Pressure v0

Card: S3-R43-C3-P1
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r43-orchestrator-profile-source-pressure-v0
Verdict: proceed-with-notes
Date: 2026-05-14

---

## Route Check

```text
Route: UPDATE
Card: S3-R43-C3-P1
Role: external-pressure-reviewer
Stage/Round observed: Stage 3 / Round 43 from assigned card; current-status indexed through R41
Previous known card: none in this thread; user assigned UPDATE
Same-role newer work: latest indexed discussion is R41 pressure; no R42/R43 same-role discussion found
Borrowed lens: runtime-pressure
```

## Question

Does the S3-R43-C1-I `CompilerOrchestrator#compile` pass-through for
`compiler_profile_source:` hide authority widening into profile finalization,
profile discovery/defaulting, loader/report status, runtime/dispatch behavior,
or production readiness?

## Context Read

- `handoff/onboarding-external-pressure-reviewer-v0.md`
- `roles/external-pressure-reviewer.md`
- `docs/discussions/README.md`
- `docs/gates/prop036-orchestrator-wiring-authorization-review-v0.md`
- `docs/tracks/prop036-orchestrator-profile-source-pass-through-v0.md`
- `docs/tracks/assembler-compiler-profile-id-field-v0.md`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/assembler.rb`
- `experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb`
- `experiments/prop036_orchestrator_profile_source_pass_through/out/prop036_orchestrator_profile_source_pass_through_summary.json`
- `experiments/prop036_orchestrator_profile_source_pass_through/out/refused_compile.compilation_report.json`

Commands run:

```text
ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb
test ! -d igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/refused_compile.igapp
```

Observed:

```text
Syntax OK
Prop036OrchestratorProfileSourcePassThrough: PASS (11/11)
no refused igapp directory
```

## Pressure Matrix

| Check | Pressure result |
| --- | --- |
| Orchestrator must not become profile finalizer | Pass. `CompilerOrchestrator#compile` adds only a keyword and forwards it. No finalization, derivation, validation, cache, or loader methods are present. |
| No env/config/default profile path appears | Pass. Code reads `source_path` only for program source and has no `ENV`, config path, registry, sidecar, default profile, or discovery branch for compiler profiles. |
| Invalid source refuses before producing profiled artifact | Pass. Invalid source returns `assembler_refused`; refusal report contains `compiler_profile_source.unfinalized`; no `refused_compile.igapp` directory exists after proof run. |
| Nil source preserves legacy behavior | Pass. Legacy compile omits `manifest.compiler_profile_id`; profiled compile emits it; hashes differ only when a valid source is supplied. |
| No loader/report status leakage | Pass with note. The profiled manifest proof checks for `absent_legacy`, `present_verified`, `mismatch`, `malformed`, `missing_required`. Refusal report uses `compiler_profile_source.*` assembler refusal text, not loader status. |
| No runtime/dispatch/production implication | Pass with note. Manifest proof checks absence of runtime authority keys; assembler refuses source objects with `runtime_authority_granted: true` or `dispatch_migration_authorized: true`; no runtime binding or dispatch migration code changed. |

## Blockers

No blockers found for the S3-R43-C1-I pass-through as implemented.

## Non-Blockers

- The proof's loader-status leakage check is manifest-focused for the profiled
  artifact. The invalid-source refusal report was manually inspected and uses
  `compiler_profile_source.unfinalized`, not loader status vocabulary. A future
  regression chain could make refusal-output status absence explicit.
- The proof checks runtime authority by selected manifest keys
  (`runtime_authority`, `gate3_authorized`, `runtime_ready`,
  `evaluation_ready`). This is adequate for C1-I, but future CLI/API exposure
  should broaden the negative scan to all written JSON artifacts before any
  public caller surface exists.
- The experiment contains inline finalization helper code to produce a valid
  source object. That is acceptable inside proof code, but should not be used
  as precedent for `CompilerOrchestrator` owning finalization.
- Current status is indexed through R41 and still says PROP-036 implementation
  is blocked. That is stale relative to the assigned R42/R43 docs, but it did
  not affect this pressure slice because the assigned gate and track are the
  controlling sources.

## [Agree]

- The C10 authorization boundary is reflected in code: the orchestrator is a
  transport boundary only.
- The C1-I implementation did not widen production code beyond
  `lib/igniter_lang/compiler_orchestrator.rb`.
- Assembler validation remains the only source-object authority in this slice.
- Nil source preserves the legacy optional path and does not inject a default
  profile.
- Invalid source refuses through the existing `assembler_refused` path before a
  profiled artifact is written.

## [Challenge]

- "No loader status leakage" should not become satisfied only by scanning a
  successful manifest. The refusal path is where `malformed` and `mismatch`
  vocabulary is most likely to leak by accident. It did not leak here, but the
  next regression should encode that explicitly.
- "No runtime authority" is currently proven by absence of selected keys in
  the manifest and by assembler-level refusal of two source flags. That is
  enough for pass-through, not enough for any future CLI/API or loader/report
  exposure.

## [Missing]

- No canonical or production CompilerProfile finalization API exists.
- No caller-facing CLI/API/config surface exists for supplying a finalized
  source object.
- No loader/report or CompatibilityReport compiler-profile status section
  exists.
- No golden migration, `.ilk` reference, CompilationReceipt link, signing,
  dispatch migration, runtime binding, production cache, or deployment
  authorization exists.

## [Sharper Question]

- Can the next regression chain prove that every written JSON artifact and
  refusal report remains free of loader status and runtime-readiness vocabulary,
  while keeping `CompilerOrchestrator` as a pure caller-supplied transport?

## [Route]

- review
- Proceed with the current pass-through. Route the notes into the existing
  post-orchestrator regression chain or a small follow-up review, not into new
  implementation authorization.
