# PROP-038 Live Refusal Boundary Design Pressure v0

Card: S3-R78-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: refusal-pressure
Track: prop038-live-refusal-boundary-design-pressure-v0

Question:
Do the live-refusal implementation boundary design (C1-P1) and current pipeline
surface survey (C2-P1) remain design-only, keep `would_refuse` from silently
becoming live `refused`, preserve report-only live behavior, correctly hold
fail-closed and all non-`mismatch` candidates, define strong enough proof
requirements, and close no forbidden surfaces?

Context:
- `docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`
- `docs/tracks/prop038-live-refusal-implementation-boundary-design-v0.md`
- `docs/tracks/prop038-live-refusal-current-pipeline-surface-survey-v0.md`
- `docs/tracks/stage3-round77-status-curation-v0.md`

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md` (S3-R77-C3-A)
- `igniter-lang/docs/tracks/prop038-live-refusal-implementation-boundary-design-v0.md` (S3-R78-C1-P1)
- `igniter-lang/docs/tracks/prop038-live-refusal-current-pipeline-surface-survey-v0.md` (S3-R78-C2-P1)
- `igniter-lang/docs/tracks/stage3-round77-status-curation-v0.md` (S3-R77-C4-S)

---

## Scope Checks

### Check 1: Design does not authorize implementation or live refusal

C1-P1 non-authorization section explicitly lists that this track does not
authorize:

- code implementation;
- live compile refusal;
- proof-local code changes;
- compiler/orchestrator behavior changes;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, loader/report,
  CompatibilityReport, diagnostics centralization, RuntimeMachine, Gate 3,
  Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

C2-P1 header section explicitly states: "No code was edited. No live refusal,
public widening, assembler mutation, loader/report behavior, CompatibilityReport
behavior, RuntimeMachine behavior, or production behavior is authorized by this
survey."

Both tracks are design/survey only. No files under `igniter-lang/lib` were
edited.

**Pass.** Neither card authorizes implementation or live refusal.

---

### Check 2: Live strict source options are explicit; none selected without Architect approval

C1-P1 live strict source option table names 5 options with advantages, risks,
and recommendation columns:

| Source | Recommendation |
| --- | --- |
| Internal orchestrator option | "Design next, not implement." |
| Ruby facade/API option | "Defer." |
| CLI flag | "Defer until API/status model stabilizes." |
| Manifest/profile policy | "Defer; not first." |
| Gate-controlled profile requirement | "Keep as proof/design source, not live source." |

The recommended first live-source candidate is **design next, not implement**.
C1-P1 explicitly adds: "The next step should be a dedicated design/pressure card
for the internal orchestrator source and status boundary."

No live source is selected, implemented, or authorized by C1-P1. The
table is a ranking of design candidates only.

C2-P1 maps the current pipeline and confirms there is no live strict source
anywhere in the current code: no strict-mode flag exists in the CLI, the Ruby
facade, or the orchestrator.

**Pass.** Source options are explicit and enumerated; none is chosen without a
separate Architect decision.

---

### Check 3: `would_refuse` does not silently become live `refused`

C1-P1 graduation rule section states:

```text
R77 proof-local would_refuse can graduate to live refused only behind a separate
implementation gate.
```

Required gate contents are explicitly enumerated (8 items):

- accepted live strict source;
- accepted compiler/orchestrator write scope;
- accepted status/result shape;
- accepted wrapper code shape;
- accepted assembly skip behavior;
- accepted report/refusal-report behavior;
- accepted legacy/no-field/no-refusal preservation proof;
- accepted public/API/CLI non-widening or explicit widening decision.

The graduation rule adds two explicit anti-patterns:

```text
Do not graduate: would_refuse => refused
by renaming proof-local vocabulary or by treating validation["valid"] == false
as a compiler stop condition.
```

These prohibitions cover the two most likely accidental graduation paths:
vocabulary rename and silent diagnostic promotion.

**Pass.** `would_refuse` cannot reach `refused` without an explicit
implementation gate closing all 8 required contents.

---

### Check 4: Report-only behavior remains the current live behavior

C1-P1 proposed pipeline placement shows the current report-only path unchanged:

```text
-> if trigger decision is allow: continue current report-only/success path
```

And explicitly:

> "compile source → ... → optional provider → nested report-only annotation
> may be added → compile status/public result/assembly remain unchanged"

C2-P1 confirms the current live behavior:

- `report_for_assembly = report` captured before contract validation annotation;
- assembler receives pre-annotation report;
- `CompilationReport.with_compiler_profile_contract_validation` does not mutate
  `pass_result`, `stages`, top-level `diagnostics`, `semantic_ir_ref`,
  assembler input, or public CLI result;
- nested validation field not emitted in CLI stdout.

C2-P1 "Must Not Change Without Implementation Gate" list preserves all of these
as closed unless a gate explicitly opens them.

**Pass.** Report-only remains the live behavior. Both cards confirm it consistently.

---

### Check 5: Pipeline placement does not authorize `.igapp`, loader/report, CompatibilityReport, runtime, or production mutation

C1-P1 pipeline placement table row for assembly:

> "Strict refusal, if live, should occur before assembly to avoid producing
> `.igapp` artifacts for a refused compile."

And for `report_for_assembly`:

> "If decision is `allow`, existing pre-annotation assembly behavior may
> continue. If `refused`, assembly should be skipped."

Both stances are conditional on a future implementation gate. The words "if live"
and "if trigger decision graduates" are load-bearing; they do not authorize
current behavior change.

C1-P1 pipeline placement explicitly closes:

- loader/report and CompatibilityReport — not authorized;
- runtime/production readiness — not opened.

C2-P1 "Must Not Change Without Implementation Gate" list explicitly closes the
assembler manifest/material/hash fields, PROP-036 `compiler_profile_source.*`
vocabulary, and loader/report/CompatibilityReport surfaces.

**Pass.** Pipeline placement is conditional future design. No forbidden surfaces
are opened by description of where a future gate would sit.

---

### Check 6: `CompilerResult`, public API/CLI, and refusal-report options remain design options only

C1-P1 status options table presents 4 options and recommends:

```text
new explicit compile status refused, with wrapper evidence, only after
CompilerResult/public result design is accepted.
```

Each option is labeled recommendation-only. The current status model is
unchanged.

C1-P1 refusal report options table presents 4 options and recommends:

```text
no persisted report [for] first live implementation
```

Again, recommendation-only.

The wrapper evidence shape is explicitly labeled:

```text
This shape is design-only. It is not accepted as CompilerResult schema.
```

C2-P1 confirms that `CompilerResult.ok`, `CompilerResult.refusal`, and
`CompilerResult.public_result` must not change without a gate, and that the
CLI has no strict/refusal flags today.

**Pass.** All `CompilerResult`, API/CLI, and refusal-report items are presented
as design options with no implementation authorization.

---

### Check 7: Fail-closed recompute-unavailable remains held

C1-P1 blocker table row:

> "Fail-closed policy for recompute unavailable | Open. | Keep fail-open for
> first live candidate or design operational recovery."

C1-P1 proof requirements row for recompute unavailable:

> "internal strict source + recompute unavailable | Must remain fail-open unless
> a fail-closed policy is separately accepted."

C2-P1 Q7:

> "Does `contract_digest_recompute_unavailable` stay fail-open? The proof-local
> trigger accepts fail-open report-only behavior. Any live strict change requires
> a separate decision."

Both cards hold fail-closed with consistent language. Neither opens the
fail-closed path. The only accepted current policy is `fail_open_report_only`
from R77.

**Pass.** Fail-closed for recompute unavailable remains held.

---

### Check 8: Proof and regression requirements are strong enough before future implementation authorization

C1-P1 defines a proof matrix across 5 categories with explicit cases in each:

1. **Existing proofs must remain PASS** — 6 specific commands enumerated
2. **Live strict source proof** — 6 cases covering no-source, valid, mismatch,
   invalid, unsupported policy, recompute unavailable
3. **Legacy/error path proof** — 6 cases covering no-provider, nil, non-Hash,
   provider raises, validator raises, existing compile failure
4. **Assembly and artifact proof** — 4 cases covering report-only, allow, live
   refused (assembly skipped), live refused (`report_for_assembly` not used)
5. **Result/report proof** — 5 cases covering public result invariants and live
   refused evidence requirements
6. **Boundary guard proof** — 6 guard assertions covering public API, parsers,
   loader/report, runtime, `.igapp` mutation, and wrapper code namespace isolation

Each case includes an explicit "Expected" column. The matrix is more specific
than the R75/R76/R77 matrices because it now includes live behavior cases.

C2-P1 makes the pipeline map concrete enough that the C1-P1 proof matrix can be
executed against real code: the specific methods, insertion points, and
observable behavior are all named.

The proof matrix is notably missing: a command to syntax-check any future live
implementation proof script. This is expected — no such script exists yet. A
future implementation card will need to add `ruby -c` and run commands for new
proof scripts. This is a minor structural note, not a gap in the design.

**Pass.** Proof and regression requirements are well-defined across 5 categories
and 27 explicitly stated cases. They are actionable against named code surfaces
from C2-P1.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 2
```

---

## Non-Blocking Notes

### NB-1: Wrapper evidence shape introduces `compile_refusal_authorized: true` for the first time

C1-P1 shows a proposed future live refused status shape:

```json
{
  "status": "refused",
  "reason_code": "compiler_profile_contract_refusal.contract_digest_mismatch",
  "evidence_code": "compiler_profile_contract.contract_digest_mismatch",
  "strict_validation_source": "internal_orchestrator_option",
  "compile_refusal_authorized": true
}
```

This is the first location in the PROP-038 chain where `compile_refusal_authorized: true`
appears. Every prior card and proof has this flag hardcoded `false`. The design
text correctly labels it "design-only" and "not accepted as `CompilerResult`
schema."

C4-A should acknowledge that this design sketch correctly shows the terminal
state of a live refused shape (where authorization has been explicitly granted)
while confirming that:

1. No current code emits `compile_refusal_authorized: true`.
2. The current live validator, proof-local trigger, and report-only integration
   all hard-code `false`.
3. The flag value will only become `true` when a subsequent implementation gate
   explicitly authorizes a live refused compile.

This is documentation confirmation only. No code change or authorization is
implied by this note.

### NB-2: C1-P1 "no persisted report" recommendation may conflict with the existing `#refusal` path

C2-P1 maps the current refusal infrastructure:

> "All compiler refusals currently pass through `CompilerOrchestrator#refusal`,
> which writes `<out without .igapp>.compilation_report.json` and returns
> `CompilerResult.refusal(...)`."

C1-P1 recommends that the first live implementation should not write persisted
reports or sidecars. These two facts are in tension: if a future live
PROP-038 strict refusal reuses the existing `#refusal` method, it would
automatically write a compilation report. If it avoids `#refusal` to prevent
that write, it would need a new orchestrator code path.

This tension is not a design-card problem — it is a deliberate question for the
future implementation gate. The question should be resolved when the
internal-orchestrator-strict-source implementation boundary is designed:

- Option A: reuse `#refusal`, accept report write, update recommendation.
- Option B: create a new refusal path that returns `CompilerResult.refusal`
  without writing a report file, accepted explicitly as a new code path.
- Option C: write a distinct schema PROP-038 refusal report (different from the
  existing compilation-report schema), authorized separately.

C4-A should note NB-2 as an open design question for the next design route
(`internal-orchestrator-strict-source-and-status-design-v0`), not a blocker for
accepting R78.

---

## Summary

Both C1-P1 and C2-P1 are correctly bounded design documents. C1-P1 defines
a clean blocker/source/placement/status/graduation/proof framework without
implementing or enabling anything. C2-P1 provides an accurate read-only pipeline
map that grounds the C1-P1 design in real code surfaces. All eight check items
pass without exception.

The two non-blocking notes are cross-cutting observations for C4-A: NB-1 is a
first-appearance flag on `compile_refusal_authorized: true` that needs
acknowledgment, and NB-2 flags a tension between C1-P1's "no persisted report"
recommendation and the existing `#refusal` infrastructure that a future
implementation design will need to resolve.

Neither note blocks acceptance of the R78 design tracks.

---

## [Agree]

- Internal orchestrator option as the first live-source design candidate is the
  correct narrowest choice: it keeps public API, CLI, manifest/profile,
  loader/report, and CompatibilityReport all closed.
- Post-validation, pre-assembly as the proposed future refusal point is the
  correct placement: it preserves `.igapp` integrity for non-refused compiles and
  prevents assembly from running on a refused contract.
- The 8-item graduation gate for `would_refuse` → `refused` is the right
  structure: it is specific, enumerable, and non-gameable by vocabulary rename.
- C2-P1's `report_for_assembly = report` capture point is correctly identified
  as a key protected boundary: as long as it stays before contract validation
  annotation, refused compiles cannot accidentally assemble contract-digest
  metadata into `.igapp` artifacts.
- The 27-case proof matrix across 5 categories is strong enough to catch
  accidental refusal promotion, legacy-path regression, assembler mutation,
  public result leakage, and wrapper code namespace drift.

## [Challenge]

None. Both cards are design-only and consistently bounded to R77-C3-A authorized
scope.

## [Missing]

- C4-A should acknowledge NB-1 (first appearance of `compile_refusal_authorized: true`
  in design vocabulary) and confirm that current live behavior and all accepted
  proofs remain hardcoded `false`.
- C4-A should acknowledge NB-2 (tension between C1-P1 "no persisted report"
  recommendation and current `#refusal` path) as an open question for the next
  design route, not blocking R78 acceptance.
- The next design route (`internal-orchestrator-strict-source-and-status-design-v0`)
  should resolve NB-2 before any implementation authorization.

## [Sharper Question]

Does C4-A accept both R78 design cards and direct the next route to design the
internal orchestrator strict source and status boundary (explicitly including
resolution of the `#refusal` path tension from NB-2), with no implementation
authorized until that boundary design is accepted?

## [Route]

```text
track: internal-orchestrator-strict-source-and-status-design-v0
```

Only after C4-A acceptance of R78 C1-P1 and C2-P1. The next design route should
cover: internal orchestrator strict source shape, status vocabulary, `#refusal`
path reuse vs new path decision, `report_for_assembly` movement decision, and
updated proof/regression requirements. No implementation authorized from R78.
