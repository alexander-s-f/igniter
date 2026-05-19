# PROP-038 Internal Strict Source / Status Design Pressure v0

Card: S3-R79-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: refusal-pressure
Track: prop038-internal-strict-source-status-pressure-v0

Question:
Does the internal orchestrator strict-source/status design (C1-P1) keep the
source constructor-only without public API/CLI leakage, correctly hold
`CompilerResult` changes for a later gate, and resolve the `#refusal` tension
by recommending a non-persisting path without authorizing code? Does the
refusal/report/result surface survey (C2-P1) ground the design in code facts
without opening forbidden surfaces?

Context:
- `docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md`
- `docs/tracks/internal-orchestrator-strict-source-and-status-design-v0.md`
- `docs/tracks/prop038-refusal-report-and-result-surface-survey-v0.md`
- `docs/tracks/stage3-round78-status-curation-v0.md`

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md` (S3-R78-C4-A)
- `igniter-lang/docs/tracks/internal-orchestrator-strict-source-and-status-design-v0.md` (S3-R79-C1-P1)
- `igniter-lang/docs/tracks/prop038-refusal-report-and-result-surface-survey-v0.md` (S3-R79-C2-P1)
- `igniter-lang/docs/tracks/stage3-round78-status-curation-v0.md` (S3-R78-C5-S)

---

## Scope Checks

### Check 1: Design does not authorize implementation or live refusal

C1-P1 non-authorization section lists:

- code implementation;
- live compile refusal;
- compiler/orchestrator behavior changes;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, loader/report,
  CompatibilityReport, diagnostics centralization, RuntimeMachine, Gate 3,
  Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

C2-P1 header states: "No code was edited. This survey does not propose code and
does not authorize implementation."

C2-P1 is a read-only code-fact survey. Both `rg` commands ran against `lib/` and
`bin/` only. No artifact writes outside the track document itself.

**Pass.** Neither card authorizes implementation or live refusal.

---

### Check 2: Internal strict source does not become public API/CLI by accident

C1-P1 internal strict source shape proposes constructor injection:

```ruby
CompilerOrchestrator.new(
  compiler_profile_contract_provider: provider,
  compiler_profile_contract_strict_requirement: strict_requirement
)
```

The card immediately names the surfaces where this parameter must NOT appear:

- `IgniterLang.compile(...)`;
- `IgniterLang::CLI`;
- `bin/igc`;
- `.igapp/manifest.json`;
- loader/report;
- CompatibilityReport.

The public shielding section adds:

- no Ruby facade argument;
- no CLI flag;
- no environment discovery;
- no manifest/profile policy;
- no loader/report interpretation;
- no default strict behavior.

C2-P1 confirms the current live code has no strict-mode path in CLI, facade, or
manifest. The CLI surface map shows the only current compiler-profile-related
parameter is `--compiler-profile-source PATH.json`, which is a PROP-036 transport
parameter unrelated to PROP-038 strict mode.

Strict mode cannot reach the CLI or public API by design: it is only injectable
via a constructor option that `IgniterLang.compile` does not expose. The facade
currently accepts an `orchestrator` override, but that is a pre-existing advanced
path, not a public strict-refusal API.

**Pass.** The internal strict source is constructor-only and explicitly shielded
from public API/CLI surfaces.

---

### Check 3: Legacy/no-source/no-refusal behavior remains protected

C1-P1 legacy behavior table covers all fail-open/fail-closed variants:

| Condition | Required behavior |
| --- | --- |
| No strict requirement option | Existing report-only behavior unchanged. |
| Strict requirement nil | Existing report-only behavior unchanged. |
| Strict requirement non-Hash/malformed | Future design must choose config-error or ignored; no accidental refusal. |
| No provider | No validation field and no refusal. |
| Provider nil/non-Hash/error | No validation field and no refusal. |
| Validator error | No validation field and no refusal unless separately authorized. |

C2-P1's coupling risk table includes as item 7: "Provider nil/non-Hash/exception
currently fails open. A strict fail-closed policy would turn provider plumbing
into user-visible compile failures." C1-P1's design preserves fail-open for these
paths.

Malformed strict requirement is correctly left as an open design question in
blocker #2: "Accepted malformed strict requirement policy: ignored vs
configuration error." The legacy behavior table correctly prevents accidental
refusal in this case without choosing the final policy.

C1-P1 also explicitly states: "Do not evaluate strict source when there is no
validation result. Missing provider/validation remains no-field/no-refusal for
this design." This prevents strict-source presence from acting as a provider
absence trigger.

**Pass.** Legacy/no-source/no-refusal paths are protected with explicit stances
for all provider and validator error scenarios.

---

### Check 4: `would_refuse` does not silently become live `refused`

C1-P1 status/result vocabulary section distinguishes explicitly:

| Vocabulary | Layer | Status |
| --- | --- | --- |
| `not_evaluated`, `allow`, `would_refuse`, `configuration_error` | Proof-local trigger model | Accepted by R77 only. |
| `refused` | Future live compiler status | Design-only here. |

The recommended future live status is `refused` but labeled "requires separate
`CompilerResult` authority. This track does not authorize that status."

C1-P1 also contains: "But `refused` requires separate `CompilerResult` authority.
This track does not authorize that status." This is a hard no-op for graduation
in this round.

C1-P1 blocker #3 is: "Accepted live status/result shape, including whether
`refused` is a new status." This is explicitly still open.

C2-P1 confirms: no live `refused` status exists anywhere in `lib/` or `bin/`. The
`rg` scan for `'"refused"|status: "refused"'` found only `Assembler#refuse_case`
(a proof helper summary field) and an unrelated TemporalExecutor comment. No live
compiler/orchestrator path produces a `refused` orchestration status.

**Pass.** `would_refuse` remains proof-local; `refused` is design-only and
requires separate authority.

---

### Check 5: `CompilerResult` changes remain held and routed to a later decision

C1-P1 `CompilerResult` boundary section presents 4 options and recommends:

```text
Design a new strict-refusal result shape first, then request explicit
CompilerResult authority.
```

All 4 options are labeled with whether they need `CompilerResult` authority. None
is authorized here. The current constructor API and public result shape are
unchanged.

C1-P1 blocker #4: "Explicit `CompilerResult` authority if result shape changes."
Still open.

C2-P1 `CompilerResult` surface map reveals a critical coupling: `public_result`
strips only `"report"`. This means any new top-level result field is exposed
publicly by default. C1-P1 acknowledges this: "Wrapper evidence should not appear
in CLI or public API output until public result behavior is separately accepted."

C1-P1 recommended next route is `strict-refusal-result-shape-and-nonpersisting-path-design-v0`.
This keeps `CompilerResult` design in the queue without authorizing it here.

**Pass.** `CompilerResult` changes are held, routed to a subsequent design route,
with C2-P1's `public_result` coupling documented.

---

### Check 6: Report-write strategy does not smuggle in persisted report authorization

C1-P1's refusal report strategy table explicitly evaluates three options:

| Strategy | Recommendation |
| --- | --- |
| Reuse `CompilerOrchestrator#refusal` | Defer unless persisted report policy is accepted. |
| New non-persisting strict refusal path | Recommended first live implementation design candidate. |
| Distinct PROP-038 refusal report policy | Defer. |

The "reuse `#refusal`" option is deferred, not adopted. The persisted report
option is deferred, not adopted. The recommendation is the non-persisting path.

C1-P1 adds an explicit guard:

> "Do not modify `CompilerOrchestrator#refusal` unless a later gate explicitly
> authorizes either: reuse with persisted report, or new no-write mode."

This closes both accidental reuse paths. Modifying `#refusal` without explicit
gate authorization is named as prohibited.

C1-P1 blocker #5: "Accepted non-persisting strict refusal path or accepted
persisted report policy." Still open — the recommendation names the candidate but
does not authorize it.

**Pass.** The report-write tension is resolved by recommending a path that avoids
persisted reports, with the persisted-report option explicitly deferred. No
persisted report authorization is smuggled in.

---

### Check 7: Reusing `CompilerOrchestrator#refusal`, if mentioned, names the report write explicitly

Although C1-P1 does not recommend reusing `#refusal` for the first candidate, it
does evaluate it and explicitly names the write behavior:

> "Reuse existing `#refusal` | Call existing refusal path and accept
> `.compilation_report.json` write."

And in the current pipeline constraints section:

> "`CompilerOrchestrator#refusal` writes `<out without .igapp>.compilation_report.json`
> and returns `CompilerResult.refusal(...)`"

C2-P1's existing report-write behavior section maps the exact mechanics:

- computes `report_path`;
- writes full report JSON via `FileUtils.mkdir_p` + `File.write`;
- returns orchestration output with status, result, compilation_report, and
  report_path.

The report write is not hidden or implied — it is named as the explicit
consequence of any `#refusal` reuse decision.

**Pass.** If `#refusal` reuse is later chosen, both design cards name the
sidecar write explicitly.

---

### Check 8: New non-persisting strict refusal path does not imply code yet

C1-P1 recommends "new non-persisting strict refusal path" as the first live
design candidate. The recommendation section says:

> "Do not modify `CompilerOrchestrator#refusal` unless a later gate explicitly
> authorizes either: reuse with persisted report or new no-write mode. Both are
> implementation choices, not accepted behavior here."

No code path is outlined or prototyped. The recommendation names a design
direction without specifying method names, file paths, or control-flow code.
C1-P1's blocker #5 explicitly leaves this "accepted non-persisting strict refusal
path" as still open.

C1-P1 recommended next route is `strict-refusal-result-shape-and-nonpersisting-path-design-v0`.
This keeps the non-persisting path as a future design target, not current
implementation.

**Pass.** The non-persisting path recommendation is a ranked design option only.
No code is implied.

---

### Check 9: `report_for_assembly` and `.igapp` boundaries remain protected

C1-P1 assembly boundary section states:

> "Preserve current accepted boundary: `report_for_assembly = report` is
> captured before report-only validation annotation, and assembler receives that
> pre-annotation report."

The `.igapp` stance section lists:

- no `.igapp` mutation in report-only path;
- no `.igapp` mutation in future refused path;
- no strict/refusal fields added to `.igapp`;
- no assembler vocabulary change;
- no `compiler_profile_source.*` reuse for PROP-038 strict refusal.

The future assembly stance table shows:
- no strict source → existing assembly unchanged;
- strict source + `allow` → existing assembly unchanged;
- strict source + future `refused` → assembly skipped BEFORE `Assembler.assemble_artifacts`.

This correctly places the refusal gate before the assembler call so the
`report_for_assembly` capture point is never even reached in the refused path.

C2-P1 confirms that the current `.igapp/compilation_report.json` is written from
`report_for_assembly`, captured before PROP-038 annotation. Therefore even today
PROP-038 metadata cannot reach `.igapp` artifacts through the current pipeline.

C2-P1's coupling risk #6 flags `report_for_assembly` movement as a risk. C1-P1's
design explicitly preserves the current capture point.

**Pass.** `report_for_assembly` capture is preserved; `.igapp` mutation is
explicitly closed across all future path variants.

---

### Check 10: Loader/report, CompatibilityReport, runtime, and production remain closed

C1-P1 non-authorization section closes all four surfaces explicitly.

C1-P1 internal strict source shape proposal lists loader/report and
CompatibilityReport in the "not a parameter on" list alongside CLI and facade.

C2-P1's survey did not read loader/report or CompatibilityReport code. The survey
scope is correctly bounded to compiler/orchestrator/result/CLI/assembler surfaces.

Neither card opens a path from strict refusal evidence into loader/report
interpretation, CompatibilityReport status, runtime readiness, or production
behavior.

**Pass.** All four surfaces remain closed in both cards.

---

### Check 11: Future proof/regression matrix is strong enough before implementation authorization

C1-P1 provides a 5-category proof matrix:

1. **Required existing regressions** — 6 commands enumerated by exact path
2. **Future syntax checks** — explicit pattern for new scripts and live files
3. **Strict source cases** — 8 cases with expected column
4. **Legacy and error cases** — 6 cases
5. **Result/report cases** — 5 cases
6. **Assembly cases** — 4 cases
7. **Boundary guards** — 6 guards

Total: 29 explicitly-stated cases plus 6 boundary guards.

C2-P1 surfaces 12 coupling risks and 14 future test surface candidates, all with
reason columns. These grounded observations translate directly into required proof
scenarios. Key additions relative to R78's matrix:

- refusal sidecar path presence/absence test;
- CLI stdout/stderr/exit golden for strict refusal;
- `public_result` key whitelist/diff;
- result identity (`program_id`) shape for strict refusal;
- `.igapp` artifact absence/diff.

C1-P1's result/report case "strict mismatch refused | Result/status matches
accepted strict-refusal shape" is broad enough to cover `program_id`, but a
future implementation review should explicitly add a `program_id` assertion to
the proof. This is addressed in NB-1 below.

**Pass.** The combined matrix is strong enough to enforce all critical invariants.
Two additions are recommended in NB-1 for the next design card.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 1
```

---

## Non-Blocking Note

### NB-1: Two C2-P1 code-fact findings should become explicit proof matrix entries in the next design route

**Finding A — `public_result` strips only `"report"`:**

C2-P1 maps `CompilerResult.public_result` as:

```ruby
result.reject { |key, _| key == "report" }
```

Any future top-level result field (e.g., a strict-refusal status, wrapper
evidence, or refusal decision field) becomes public CLI output by default. C1-P1
acknowledges this ("Wrapper evidence should not appear in CLI or public API output
until public result behavior is separately accepted"), but neither card explicitly
requires a proof assertion that verifies the public result key set remains
unchanged or matches an expected allowlist after a strict-mismatch refused path
runs.

**Finding B — `CompilerResult.refusal` ignores nested validation diagnostics:**

C2-P1 finds that `CompilerResult.refusal` constructs public diagnostics only from
top-level `report["diagnostics"]`. Nested `compiler_profile_contract_validation.diagnostics`
are silently ignored. A future PROP-038 strict refusal may intend to surface
wrapper evidence in the public result, but this requires either:
(a) promoting the evidence to a top-level diagnostic, or
(b) adding a new constructor path.

Neither route is authorized, but the finding means a test "strict refusal result
has no accidental public exposure of nested validation diagnostics" should be
added to the proof matrix.

**Requested resolution:**

The next design route (`strict-refusal-result-shape-and-nonpersisting-path-design-v0`)
should add the following to its proof matrix:

- `public_result` key-set assertion: verify that unexpected fields do not become
  public after strict refusal;
- nested-diagnostics isolation assertion: verify that nested validation
  diagnostics remain nested and are not promoted to `CompilerResult.refusal`
  diagnostics unless separately authorized.

C4-A should acknowledge these as additions to the required proof matrix, not
blockers for R79 acceptance.

---

## Summary

Both C1-P1 and C2-P1 are correctly bounded. C1-P1 makes the internal
strict source explicitly constructor-only, names all excluded public surfaces,
holds `CompilerResult` and `refused` status for later gates, recommends the
non-persisting refusal path without authorizing code, preserves
`report_for_assembly` and `.igapp` boundaries, and lists 12 explicit blockers
before implementation. C2-P1 grounds every key design claim in code-level evidence
with coupling risks and test candidates. The `#refusal` report-write tension
(R78 NB-2) is correctly resolved: reuse is deferred, non-persisting path is the
recommendation, both are held pending a later design decision.

The one non-blocking note flags two C2-P1 code findings (`public_result` key
stripping and nested-diagnostics coupling) that should become explicit proof
assertions in the next design route. Neither is a blocker for R79.

---

## [Agree]

- Constructor-only injection for `compiler_profile_contract_strict_requirement`
  is the correct boundary: it narrows the live source to callers who explicitly
  build their own orchestrator, keeping public API/CLI and facade free from
  implicit strict behavior.
- Recommending a new non-persisting strict refusal path (over `#refusal` reuse)
  is the correct resolution for R78 NB-2: it separates PROP-038 strict policy
  semantics from the existing OOF/parse/assembler refusal infrastructure.
- The 12-blocker list is actionable: source shape, malformed policy, status/result
  authority, assembly skip, report-write strategy, legacy proof, and proof matrix
  are all enumerated. A future implementation gate has a concrete checklist.
- C2-P1's no-live-`refused`-status scan is important independent evidence: the
  design recommendation to introduce a new `refused` status is coherent with the
  current codebase (no existing status would be overloaded).
- Holding `report_for_assembly` at its current capture position and skipping
  assembly for the refused path is the correct stance: `.igapp` artifacts stay
  clean for non-refused compiles, and refused compiles produce nothing downstream.

## [Challenge]

None. Both cards stay design-only, are correctly bounded to R78-C4-A authorized
scope, and are grounded in code facts from the C2-P1 survey.

## [Missing]

- C4-A should direct the next design route to add explicit proof assertions for
  (a) `public_result` key-set after strict refusal, and (b) nested validation
  diagnostics not promoted to `CompilerResult.refusal` diagnostics — NB-1.
- C4-A should confirm that C1-P1 blocker #2 (malformed strict requirement policy:
  ignored vs configuration-error) remains open and must be resolved before
  implementation authorization, not left to implementation discretion.

## [Sharper Question]

Does C4-A accept both R79 design cards and direct the next route to design the
strict-refusal result shape and non-persisting orchestrator path (including
explicit resolution of NB-1 proof gaps and blocker #2 malformed-policy decision),
with no implementation authorized until that shape design is accepted?

## [Route]

```text
track: strict-refusal-result-shape-and-nonpersisting-path-design-v0
```

Only after C4-A acceptance of R79 C1-P1 and C2-P1. The next design route should
resolve: strict-refusal result shape, `public_result` key-set behavior, nested
vs public diagnostic exposure, malformed strict requirement policy, non-persisting
refusal path semantics, and updated proof assertions per NB-1. No implementation
authorized from R79.
