# compiler-mainline-next-axis-pressure-v0

Card: S3-R89-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: compiler-authority-pressure
Track: compiler-mainline-next-axis-pressure-v0
Route: UPDATE
Status: complete

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-mainline-next-axis-options-v0.md` (C1-P1)
- `igniter-lang/docs/tracks/compiler-mainline-touchpoint-and-proof-gap-survey-v0.md` (C2-P1)
- `igniter-lang/docs/org/tracks/compiler-mainline-reentry-boundary-map-v0.md` (C0-O)
- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md` (R84-C1-A)
- `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md` (R86-C4-A)
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `igniter-lang/docs/cards/S3/S3.md`
- `igniter-lang/docs/current-status.md`

---

## Scope Checks

### 1. Recommended compiler route is bounded

C1 recommends `compiler-pack-boundary-report-v0` as the primary next route. The
recommendation is typed as:

> docs/design report only
> no implementation
> no proof-local behavior unless separately requested

The track's "Closed-Surface List" section enumerates 28 explicitly closed items.
The recommendation text holds all blocked surfaces and correctly describes the
goal as mapping without moving code:

> Map the current proof compiler, accepted PROPs, OOF registries, fragment
> classes, pass responsibilities, SemanticIR/assembler surfaces, and proof
> fixtures into candidate Profile/Baseline/Pack boundaries without moving code.

C2 independently confirms the same route and adds the same qualification:

> It extends the accepted C0-O direction by mapping the current live compiler,
> profile slots, validator/report evidence, OOF boundaries, proofs, and closed
> surfaces into candidate compiler packs without code churn or authority widening.

C0-O's "Preferred conservative first route" is also `compiler-pack-boundary-report-v0`
with the same rationale. All three cards converge on the same bounded route.

The backup route (`prop038-strict-terminal-regression-hardening-v0`) is proof-only
and explicitly scoped to proof instrumentation without altering compiler behavior.
C1 correctly positions it as "hardens evidence but does not choose the next
architecture direction."

The Candidate F decomposition notes are clearly marked as fallback options if
Architect rejects E, not as parallel work items.

**Result: PASS**

---

### 2. No Spark fixture/spec work opened through compiler lane

C1 explicitly lists in its closed-surface section:

> Spark fixtures/specs or Spark implementation; treating Spark applied pressure
> as compiler authority.

C2 explicitly lists:

> Spark fixtures/specs or Spark implementation from this compiler-lane card.

C0-O establishes the lane boundary in its opening section:

> Spark applied pressure remains active, but it is not the compiler mainline.

The C0-O PG-2026-05-20-01 annotation reads:

> For compiler mainline, `PG-2026-05-20-01` is a separation constraint: do not
> let Spark receipt pressure masquerade as compiler authority.

The recommended route (`compiler-pack-boundary-report-v0`) is entirely a
compiler/profile architecture mapping exercise. No Spark class names, receipt
vocabulary, or pilot scope appear in the route description or deliverables list.

No Spark fixture, receipt, or pilot material appears in either C1 or C2 route
recommendations.

**Result: PASS**

---

### 3. No public API/CLI widening implied without explicit Architect decision

C1 Axis A covers public API/CLI as a candidate but explicitly recommends against
it now:

> Too soon after R84: strict source is intentionally internal-only; public
> exposure would stress source-shape, security, and refusal UX before main
> compiler architecture is mapped.

C1 closed-surface list includes:

> public API/CLI widening; `IgniterLang.compile` signature changes; strict source
> outside internal constructor/test seam; profile discovery/defaulting/finalization
> in public surfaces.

C2 confirms public CLI still exposes only `compiler_profile_source` / 
`--compiler-profile-source PATH.json` (PROP-036 transport) with no strict
contract provider/requirement. The C2 touchpoint map correctly identifies:

> Public CLI widening remains closed.

The C2 "Public strict source is absent" proof gap item correctly states:

> Any public/API strict route needs separate API/CLI design, preflight, docs, and
> release proof.

Neither C1 nor C2 implies that the pack boundary report will open, imply, or
require public API/CLI widening. The route type is `docs/design report only`.

**Result: PASS**

---

### 4. Loader/report, CompatibilityReport, `.igapp`, dispatch, runtime, Gate 3, Ledger/TBackend, cache, signing, and production remain closed unless explicitly routed as design-only

C1 closed-surface list explicitly includes every surface in this check:

- `loader/report compiler-profile status`
- `CompatibilityReport compiler-profile section`
- `.igapp` or golden migration
- compiler dispatch migration
- profile-assembled compiler rewrite
- RuntimeMachine or Gate 3 widening
- Ledger/TBackend
- cache
- signing / production verification
- production behavior

C2 closed-surface list mirrors these and adds the affirmative:

> until a later Architect gate explicitly opens them.

C2's "Loader/report and CompatibilityReport remain proof-local or closed" proof
gap entry correctly states:

> Avoids turning compiler evidence into runtime readiness.

C2's runtime metadata touchpoint notes:

> Loader/report and CompatibilityReport must not infer strict readiness.

The C0-O boundary map established the same blocked surfaces list with 15 named
items. C1 and C2 honor this boundary without exception.

The recommended route (`compiler-pack-boundary-report-v0`) has a `docs/design
report only` type with explicit "must not migrate yet" list as a required
deliverable. Nothing in the recommended deliverables list implies implementation
of loader/report, CompatibilityReport, dispatch, runtime, `.igapp`, Gate 3,
Ledger/TBackend, cache, signing, or production behavior.

**Result: PASS**

---

### 5. Proof/design route has clear next evidence and no hidden implementation

C1 specifies the recommended deliverables at concrete granularity:

- pack boundary table (9 named candidate packs)
- current owner map for parser/classifier/TypeChecker/SemanticIR/assembler
- OOF ownership map aligned with PROP-038 strict registries
- fragment-class owner map
- proof/golden fixture map per candidate pack
- migration risk table
- "must not migrate yet" list
- recommended later proof slices

All deliverables are map/report artifacts, not code outputs. The acceptance bar
is specified as:

> proceed if the report is descriptive, maps current evidence accurately, and
> preserves all closed surfaces; hold if it implies live pack dispatch, public
> profile input, `.igapp` migration, or runtime authority.

This hold criterion is properly pre-emptive: it names the specific hidden
implementation risks before the route runs rather than relying on the
implementing agent to self-apply it.

C2 provides the evidence baseline for the report: 8 proof summaries all PASS,
live file reads across 8 source files, 9 proof gap items each with current
evidence and suggested route owner. This grounds the report work in verified
current state rather than assumptions.

C1's Candidate F sub-route decomposition gives Architect a structured fallback
rather than leaving orphan options floating. Sub-routes are correctly sequenced
as "better after a pack boundary report clarifies the target decomposition."

C2's handoff `[Next]` section explicitly directs:

> Compiler/Grammar Expert: confirm whether Ch6 should be updated now or after
> the compiler-pack boundary report.
> Bridge Agent: hold public/API/CLI, loader/report, CompatibilityReport, and
> package bridge work until Architect opens a specific surface.

No hidden implementation is implied in either track doc.

**Result: PASS**

---

### 6. Portfolio reporting path is clear

C0-O explicitly established the R89 Portfolio closure packet:

```text
igniter-lang/docs/tracks/stage3-round89-status-curation-v0.md
```

The fallback packet if status curation is insufficient:

```text
igniter-lang/docs/reports/s3-r89-round-report.md
```

C0-O includes a 7-field list of what the packet must include (status, executive
summary, completed cards, changed files, evidence, risks/drift, cross-lane
requests, recommended next route, decisions needed from Portfolio). C0-O and C1
both confirm R89 does not require any Portfolio decision for round closure.

Portfolio guidance PG-2026-05-20-01 is acknowledged in C0-O as a lane
separation constraint that does not block compiler mainline planning.

**Result: PASS**

---

## Non-Blocking Notes

### NB-1: Ch6 CompilationReport sync disposition not decided between C1 and C2

C1 lists Axis C ("Ch6 / CompilationReport documentation sync") as too small to
be the main axis but acknowledges it as useful cleanup. C2 identifies the Ch6
staleness in detail (5 specific gaps listed) and recommends it as "a small Ch6
CompilationReport sync, owned by Compiler/Grammar or Meta status/spec
stewardship, before any public compiler-profile result/report expansion."

C2's handoff question asks:

> Compiler/Grammar Expert: confirm whether Ch6 should be updated now or after
> the compiler-pack boundary report.

This remains an open disposition question. Both options are safe, but C4-A
should either:
- explicitly include Ch6 sync as a sidecar deliverable of the pack boundary
  report; or
- explicitly defer it to a separate follow-up card after the report.

Leaving it as an open question in handoff without Architect guidance creates a
gap where C4-A's next implementation card may not know whether to carry Ch6
sync or skip it.

Not a blocker for route acceptance. C4-A should name a clear disposition.

---

### NB-2: Backup route has no acceptance bar equivalent

The primary route (`compiler-pack-boundary-report-v0`) comes with an explicit
acceptance bar and hold criterion. The backup route
(`prop038-strict-terminal-regression-hardening-v0`) does not include an
equivalent hold criterion in C1. C1 correctly says the backup should "remain
inside the existing PROP-038 proof lane and avoid API, loader/report,
CompatibilityReport, runtime, or production surfaces" — but this is stated
as a recommendation rather than a named hold trigger.

Not a blocker: the backup is proof-only and inherits the R84 acceptance
boundary. If C4-A opens the backup as a parallel or sequential route, it may
want to add an explicit hold trigger comparable to the primary's.

---

## Summary

| Check | Result |
| --- | --- |
| 1. Recommended compiler route is bounded (docs/design report only, no code) | PASS |
| 2. No Spark fixture/spec work opened through compiler lane | PASS |
| 3. No public API/CLI widening implied without explicit Architect decision | PASS |
| 4. Loader/report, CompatibilityReport, `.igapp`, dispatch, runtime, Gate 3, Ledger/TBackend, cache, signing, and production remain closed | PASS |
| 5. Proof/design route has clear next evidence and no hidden implementation | PASS |
| 6. Portfolio reporting path is clear | PASS |

```text
checks: 6/6
blockers: 0
non-blocking notes: 2
  NB-1: Ch6 CompilationReport sync disposition unresolved (now vs. after pack report) — C4-A should name an explicit disposition
  NB-2: Backup route lacks an explicit hold criterion — acceptable given proof-only scope and R84 inheritance, but C4-A may want to add one if backup is opened
```

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 2
```

---

## Recommendation For C4-A

The R89 compiler mainline options analysis (C1) and touchpoint/proof gap survey
(C2) are clean, well-grounded, and converge with the C0-O boundary map.

The recommended route (`compiler-pack-boundary-report-v0`) is the right next
move: it advances the architecture direction from `docs/dev/compiler-profile-
architecture-direction.md` without code movement, preserves all accepted closed
surfaces, and creates the missing map needed before any of the more complex
future axes (public API/CLI, loader/report, CompatibilityReport, dispatch
migration) can be safely scoped.

Recommend C4-A:

1. **Accept** `compiler-pack-boundary-report-v0` as the primary next route with
   the C1 acceptance bar:
   - proceed if the report is descriptive, maps current evidence accurately, and
     preserves all closed surfaces;
   - hold if it implies live pack dispatch, public profile input, `.igapp`
     migration, or runtime authority.

2. **Resolve NB-1**: name a Ch6 CompilationReport sync disposition explicitly:
   - include Ch6 sync as a sidecar item in the pack boundary report deliverables;
     OR
   - defer Ch6 sync to a separate follow-up card after the pack report.
   Do not leave it as an open handoff question for the implementing agent.

3. **Keep backup visible** (`prop038-strict-terminal-regression-hardening-v0`)
   but do not open it in parallel unless there is specific pressure to close the
   R83/R84 instrumentation asymmetry before the pack report.

4. **Preserve all blocked surfaces** as listed in C0-O and C1 without exception:
   no Spark fixture/spec work, no public API/CLI, no loader/report or
   CompatibilityReport, no dispatch migration, no `.igapp`, no runtime/production.

No implementation is authorized by this review.
