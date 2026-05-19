# PROP-038 Live Implementation Scope Pressure v0

Card: S3-R82-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: implementation-pressure
Track: prop038-live-implementation-scope-pressure-v0
Route: UPDATE
Status: complete
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md`

Inputs reviewed:

- `docs/tracks/prop038-strict-refusal-live-implementation-scope-review-v0.md` (S3-R82-C1-P1)
- `docs/tracks/prop038-live-implementation-touchpoint-survey-v0.md` (S3-R82-C2-P1)
- `docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md` (S3-R81-C3-A)
- `docs/tracks/stage3-round81-status-curation-v0.md` (S3-R81-C4-S)

---

## Question

Does the strict-refusal live implementation scope review (C1-P1) provide an exact
enough candidate write scope, decide the two remaining open design questions
(`configuration_error` public surface and `report.pass_result` policy), protect
the non-persisting/no-sidecar stance, and produce a sufficiently complete blocker
list for a future implementation authorization — all without authorizing
implementation? Does the live implementation touchpoint survey (C2-P1) ground the
scope decisions in current code facts and identify all coupling risks?

---

## Scope Checks

[1] Scope review does not authorize implementation.

C1-P1 opens with: "This track is design/review only. It does not edit code,
enable live compile refusal, change compiler/orchestrator behavior, change
`CompilerResult`, widen public API/CLI behavior, write persisted reports or
sidecars, mutate `.igapp`, or open loader/report, CompatibilityReport, diagnostics
centralization, runtime, or production behavior." A full Non-Authorization
Preserved section enumerates these closures. C2-P1 states: "No code was edited.
This survey does not propose implementation code and does not authorize any
surface." [Files] Changed for C2-P1 lists only one doc file. Check: PASS.

[2] Candidate write scope is exact enough for a later implementation card.

C1-P1 provides a 5-row candidate write scope table with exact file paths:
- `lib/igniter_lang/compiler_orchestrator.rb` — internal strict source + non-persisting terminal branch
- `lib/igniter_lang/compiler_result.rb` — strict-refusal/configuration-error result construction
- `experiments/prop038_strict_refusal_live_implementation_proof/` — future proof harness
- rerun of `prop038_report_only_compiler_integration` summary (conditional)
- `docs/tracks/prop038-strict-refusal-live-implementation-v0.md` (conditional)

Non-candidate scope is equally explicit, listing 8 forbidden paths:
`igniter_lang.rb`, `cli.rb`, `bin/igc`, `assembler.rb`, `compilation_report.rb`,
`diagnostics.rb`, `.igapp` artifacts/goldens, loader/report, CompatibilityReport.

A future implementation card that touches a non-candidate path must stop and
route back to design/authority. This is a correct and enforceable constraint.
Check: PASS.

[3] `CompilerResult` authority is named if needed and not smuggled in.

C1-P1 authority table: "Yes — Needed for future `status: "refused"`,
`status: "configuration_error"`, key-set allowlist, and wrapper diagnostics."
Listed as blocker #4. C2-P1 confirms: `CompilerResult.refusal` requires a
`report_path` and cannot directly produce the R81 `compilation_report_path: null`
target without changes; `CompilerResult.ok` must remain stable; `public_result`
is not a whitelist. No authority is granted — the authority requirements are named
as future gate requirements. Check: PASS.

[4] `CompilerOrchestrator` authority is named if needed and not smuggled in.

C1-P1 authority table: "Yes — Needed for internal strict source option, trigger
evaluation point, non-persisting terminal branch, and assembly skip." Listed as
blocker #3. The non-persisting path boundary sketch in C1-P1 is explicitly labeled
"Design-only sketch for future live implementation" and contains no code changes.
C2-P1 maps the exact orchestrator touchpoints (provider entry, main compile
pipeline, report-only attachment, refusal gate, assembly boundary, runtime smoke
boundary, sidecar refusal, report path derivation, write helper) as code facts
only. Check: PASS.

[5] `configuration_error` public surface is decided or explicitly held.

C1-P1 decides: `configuration_error` shares the same strict terminal public
key-set allowlist as `refused` (all 13 keys). Rationale: R81 proof already
modeled `configuration_error` with equal precision; a smaller key-set adds a
second public result surface and more CLI/API risk; shared shape makes proof and
public-result guards simpler. The decision is concrete and justified. This closes
R81-C3-A remaining blocker #5. C4-A confirmation is the remaining step.
Check: PASS.

[6] `report.pass_result` live policy is decided or explicitly held.

C1-P1 decides: `report.pass_result: "ok"` remains invariant for all PROP-038
strict terminal paths in this route. Scope defined precisely: applies to strict
digest mismatch and malformed strict requirement `configuration_error` paths;
does not apply to parse/type/OOF/assembler/runtime-smoke failures or hypothetical
future strict sources evaluated before baseline report exists. Rationale: PROP-038
strict terminal behavior is layered after a successful baseline compiler pipeline;
mutating `pass_result` would accidentally route through existing `#refusal`
mechanics. The decision is scoped and justified. This closes R81-C3-A remaining
blocker #4. C4-A confirmation is the remaining step. Check: PASS.

[7] Non-persisting/no-sidecar/no-report stance remains intact.

C1-P1 non-persisting path boundary sketch lists six explicit prohibitions: do not
call `#refusal`, do not write `.compilation_report.json`, do not write a distinct
PROP-038 report, do not create or mutate `.igapp`, do not call
`Assembler.assemble_artifacts` on strict terminal paths, do not append nested
validation diagnostics to top-level report diagnostics. These are reinforced in
the non-persisting assertions table (6 rows) and in blocker #6. C2-P1 sidecar
leakage risk entry confirms: "`CompilerOrchestrator#refusal` always writes report
JSON; R81 target is non-persisting with `compilation_report_path: null`; current
helper violates that target." Check: PASS.

[8] Existing `CompilerOrchestrator#refusal` is not accidentally reused.

C1-P1 states explicitly: "Do not call `CompilerOrchestrator#refusal` for PROP-038
strict terminal paths." Listed as the first item in the boundary sketch and in
the non-persisting assertions table. Blocker #5 requires explicit confirmation.
C2-P1 coupling risk table flags: "PROP-038 strict refusal should not accidentally
inherit OOF report-write semantics." C2-P1 touchpoint entry for the existing
sidecar refusal confirms the physical coupling: `#refusal` lines 143-158 computes
report path, writes JSON, returns `CompilerResult.refusal`. Check: PASS.

[9] Report-only current live behavior remains unchanged.

C1-P1 preservation assertions table: "current report-only invalid validation —
compiles/assembles unchanged." The boundary sketch preserves `report_for_assembly
= report` and shows the strict terminal branch inserting only after the report-only
provider/validator path with no mutation of assembly behavior for report-only
paths. C2-P1 confirms: "Current live PROP-038 behavior remains report-only."
Must Not Change list covers `CompilationReport` `pass_result` vocabulary,
report-only validation placement, `Diagnostics` extraction rules,
`CompilerProfileContractValidator` authority fields, and `report_for_assembly`
protection. Check: PASS.

[10] Public API/CLI, loader/report, CompatibilityReport, runtime, and production
surfaces remain closed.

C1-P1 authority table: public API authority "No — Must remain closed for first
live boundary"; CLI authority "No — Must remain closed." Non-candidate scope
explicitly lists `cli.rb`, `bin/igc`, loader/report, CompatibilityReport.
Preservation assertions: "public API/CLI — no new parameter, flag, stdout key,
or exit behavior unless separately authorized; loader/report and
CompatibilityReport — untouched; diagnostics centralization — untouched."
C2-P1 Must Not Change list covers `IgniterLang.compile` public Ruby facade
parameters, `CLI.run` flags, `bin/igc` exit mapping. Check: PASS.

[11] Proof/regression requirements are strong enough before any future
implementation authorization.

C1-P1 proof/regression matrix covers four categories:
- Syntax checks: `compiler_orchestrator.rb`, `compiler_result.rb`, new proof script
- Existing proof chain: 7 named proof scripts that must remain PASS
- Live strict terminal cases: 8-row scenario table covering no-strict-source,
  nil, malformed, valid, mismatch, invalid-digest, unsupported-policy, recompute-unavailable
- Assertion tables: result shape (8 rows), non-persisting (6 rows), preservation (7 rows)

C2-P1 regression anchor table provides 9 named anchors with exact commands and
covered risk surfaces. Together these are implementation-review ready.
Check: PASS.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 2
```

All eleven scope checks pass.

---

## Non-Blocking Notes

NB-1: C2-P1 Q4 asks: "What is the exact live authority source that allows invalid
validator output to become compile refusal, given live validator results still say
`compile_refusal_authorized: false`?" C1-P1 names `CompilerOrchestrator` +
`CompilerResult` authority as required but does not explicitly state the mechanism
by which the validator's `compile_refusal_authorized: false` field is superseded
or bypassed in a live implementation.

C4-A should confirm: the live refusal authority comes from the orchestrator-level
strict requirement decision path (a separate decision layer), not from the
validator result field. The `compile_refusal_authorized: false` field in the
validator result is a proof-local/report-only marker that persists nested in the
internal report even for strict-refusal outcomes. A future implementation gate
must make the exact authority chain explicit so no implementation card can treat
a `valid: false` validator result alone as permission to refuse.

NB-2: C2-P1 Q8 asks: "Should CLI/API remain closed for the first live
implementation, with strict behavior only injectable through internal orchestrator
test seams?" C1-P1 says "CLI/API must remain closed for the first live boundary"
and `IgniterLang.compile` is excluded from the candidate write scope. However,
`IgniterLang.compile` currently passes through the compiler result to callers. If
`CompilerOrchestrator` is invoked internally with a strict requirement and produces
`status: "refused"`, any direct Ruby facade caller receiving the result would
observe the new status without an explicit API widening gate.

C4-A should confirm whether the accepted implementation boundary requires that
strict mode be injectable only through internal test seams (not through any public
Ruby call chain), or whether it is acceptable for `IgniterLang.compile` callers
to receive `refused`/`configuration_error` results as a consequence of a strict
requirement they cannot currently supply. If the latter, the C1-P1 non-candidate
scope for `igniter_lang.rb` should be re-examined before implementation
authorization.

---

## [Agree]

- C1-P1 is design-only; no code changes; all closed surfaces enumerated.
- The two-file candidate scope (`compiler_orchestrator.rb` +
  `compiler_result.rb`) is the smallest correct scope for first live
  implementation.
- `configuration_error` sharing the 13-key public allowlist is the right design
  decision: it avoids a second public surface and matches the R81 proof model.
- `report.pass_result: "ok"` invariant for all PROP-038 strict terminal paths is
  the right design decision: it correctly separates the strict-terminal decision
  layer from the baseline compile report.
- The non-persisting path boundary sketch correctly places the strict terminal
  branch after the existing `report["pass_result"] != "ok"` ordinary refusal gate,
  not before it.
- C2-P1 correctly identifies `CompilerResult.refusal` as shape-incompatible with
  the R81 target and flags this as requiring `CompilerResult` authority.
- The 12-item blocker list in C1-P1 is complete and actionable; each item names
  an explicit required decision.
- C2-P1's 10-entry coupling risk table and 9-anchor regression anchor table are
  strong enough to anchor a live implementation review.

## [Challenge]

None. Both cards are internally consistent, consistent with each other and with
the R81-C3-A gate, and introduce no scope leaks or authority smuggling.

## [Missing]

- The exact trigger condition check for the strict terminal path — specifically,
  whether the check examines a strict requirement parameter on the orchestrator
  instance or a property of the validation result — is described in the boundary
  sketch but not reduced to a named check name or assertion. This is a
  pre-implementation design detail that a future implementation gate should
  require as a named assertion before code opens.

## [Sharper Question]

Is the live authority source for strict refusal the orchestrator-level strict
requirement parameter (making refusal a decision of the orchestrator, not the
validator), such that `compile_refusal_authorized: false` in the validator result
remains a read-only nested marker forever? If yes, C4-A should state this
explicitly as part of the accepted implementation boundary to prevent a future
card from treating the validator result field as an authority signal.

## [Route]

route: C4-A decision gate — `prop038-live-implementation-scope-decision-v0`

---

## Handoff

Card: S3-R82-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: prop038-live-implementation-scope-pressure-v0
Status: done

[D] Decisions

- Implementation-pressure review of C1-P1 (live implementation scope review) and
  C2-P1 (live implementation touchpoint survey) completed.
- All 11 scope checks pass.
- No blockers found.
- Two non-blocking notes routed to C4-A: NB-1 (live authority source mechanism
  vs `compile_refusal_authorized: false` field); NB-2 (strict mode
  injectability — internal test seam only vs `IgniterLang.compile` passthrough).

[S] Shipped / Signals

- Added this discussion document.

[T] Tests / Proofs

- Read-only review. No code run or experiments changed.

[R] Risks / Recommendations

- C1-P1 correctly places 12 blockers before live implementation authorization.
  All must remain closed until explicitly addressed.
- `compile_refusal_authorized: false` must be treated as a read-only nested
  marker, not an implementation gate. C4-A should make this explicit.
- If `IgniterLang.compile` callers can currently observe `refused`/`configuration_error`
  results via Ruby passthrough without an explicit API gate, C4-A should decide
  whether this is acceptable or whether the first implementation is restricted to
  internal test seams only.

[Next] Suggested next slice

- C4-A should accept C1-P1 and C2-P1, resolve NB-1 (authority source mechanism)
  and NB-2 (API passthrough question), and decide whether to authorize a bounded
  live implementation card or route to a further design gate first.
  No implementation card may open directly from R82 without explicit
  implementation authorization.
