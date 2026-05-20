# Track: Compiler Mainline Next Axis Options v0

Card: S3-R89-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `compiler-mainline-next-axis-options-v0`
Route: UPDATE
Status: done
Date: 2026-05-20

Depends on:

- `S3-R89-C0-O`

Affected neighbor roles: `[Igniter-Lang Architect Supervisor]`,
`[Igniter-Lang Implementation Agent]`, `[Igniter-Lang Research Agent]`

---

## Goal

Evaluate the next main compiler/profile development axis after R84-R86
PROP-038 closure and recommend one bounded route for Architect decision.

This track is design/options-only. It does not edit code, update specs or
proposals, authorize public API/CLI, loader/report, CompatibilityReport,
dispatch, runtime, `.igapp`, signing, Ledger/TBackend, cache, or production.

---

## Inputs Read

- `docs/org/tracks/compiler-mainline-reentry-boundary-map-v0.md`
- `docs/current-status.md`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md`
- `docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`
- `docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`

---

## Current Boundary Summary

R84-R86 leave the compiler/profile lane in this state:

```text
compiler_profile_id transport exists in bounded PROP-036 surfaces
compiler_profile_contract vocabulary exists in PROP-038
contract validator exists internally
report-only validation evidence exists internally
contract_digest validation exists internally
internal-only strict terminal foundation exists
PROP-038 canon/spec sync is accepted
```

Still closed:

```text
public strict source
profile discovery/defaulting/finalization
loader/report compiler-profile status
CompatibilityReport compiler-profile section
dispatch migration
profile-assembled compiler rewrite
runtime/production authority
```

The C0-O boundary map separates this compiler mainline from Spark applied
pressure. Spark may inform future fixture/spec pressure, but it must not become
compiler authority in this route.

---

## Candidate Axis Comparison

| Axis | Authority required | Kind | Blocked surfaces touched | Likely files / areas | Proof or pressure required | Why now | Why not now |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A. Public API/CLI design route for strict source / profile contract inputs | Public API/CLI design authority; later Ruby facade/CLI implementation authority if opened. | Design first; implementation later only by separate gate. | Public API, CLI, `IgniterLang.compile`, env/path/input parsing, possibly error wording. | `docs/ruby-api.md`, CLI docs, future `lib/igniter_lang.rb`, `lib/igniter_lang/cli.rb`, proof fixtures. | API/CLI pressure, key-set stability proof, existing production compiler CLI regression. | Users eventually need a controlled way to supply profile/contract intent. | Too soon after R84: strict source is intentionally internal-only; public exposure would stress source-shape, security, and refusal UX before main compiler architecture is mapped. |
| B. Loader/report or CompatibilityReport design route for compiler-profile contract evidence | Loader/report design authority; CompatibilityReport authority if it names runtime-readiness fields. | Design only at first. | Loader/report status, manifest interpretation, CompatibilityReport schema, possible `.igapp` semantics. | `docs/spec/ch7-runtime.md`, loader/report docs, future compatibility report fixtures, possible manifest examples. | Loader/report pressure, status vocabulary proof, no-runtime-authority review. | It connects compiler profile evidence to artifact inspection. | Risky now: PROP-038 explicitly keeps loader/report and CompatibilityReport closed; design would be better after pack/slot boundaries clarify what evidence should be reported. |
| C. Ch6 / CompilationReport documentation sync for nested `compiler_profile_contract_validation` evidence | Spec/docs authority only. | Docs-only. | No blocked implementation surface if kept descriptive. | `docs/spec/ch6-semanticir.md`, possibly `docs/spec/README.md`, track doc. | Lightweight spec pressure only. | R86 named it as an optional spec gap. | Too small to be the main compiler/profile development axis; useful cleanup, not strategic selection. |
| D. Proof/regression hardening for PROP-038 strict terminal and ordinary success-path instrumentation | Proof experiment authority only; no live behavior authority. | Proof-only / instrumentation if bounded to experiment. | Could touch proof outputs; must not alter compiler behavior unless separately authorized. | `experiments/prop038_strict_refusal_live_implementation_proof/`, maybe summary JSON. | Regression reruns, pressure on assembler-call counters and ordinary path preservation. | It closes the known non-blocking instrumentation asymmetry from R83/R84. | It hardens evidence but does not advance the next architecture axis; best as backup or sidecar. |
| E. Compiler pack boundary report / profile-assembled compiler migration map | Docs/design authority only. No implementation authority. | No-code design/report. | Must avoid dispatch migration, pack registry implementation, parser/pass rewrites, `.igapp` mutation. | `docs/tracks/compiler-pack-boundary-report-v0.md`, possibly read-only code/proof map across parser/classifier/typechecker/SemanticIR/assembler and PROPs. | Architecture pressure review; no proof commands required unless the track chooses read-only evidence checks. | Best matches compiler-profile architecture direction and C0-O recommendation; advances Profile/Baseline/Pack while preserving current proof compiler. | Must stay descriptive. If it starts assigning live pack handlers or migration steps as authority, it must stop and route to Architect. |
| F. Other evidence-backed compiler/profile axis: slot contract map, ordered-rule proof, mandatory profile-id transition, shadow pack manifest proof, or POC close delta | Varies by sub-axis; all should begin design/proof-only. | Design or proof-only. | Slot enforcement, ordered pass semantics, `.igapp` transition, dispatch migration risk depending sub-axis. | New track(s), possible proof-local experiments for ordered rules or shadow manifest. | Dedicated pressure for chosen sub-axis. | C0-O identifies credible alternatives if Architect wants narrower formalization than E. | Less integrative than E. Most become better after a pack boundary report clarifies the target decomposition. |

---

## Recommended Next Route

Recommendation:

```text
compiler-pack-boundary-report-v0
```

Route type:

```text
docs/design report only
no implementation
no proof-local behavior unless separately requested
```

Recommended card owner:

```text
[Igniter-Lang Compiler/Grammar Expert]
```

Recommended goal:

```text
Map the current proof compiler, accepted PROPs, OOF registries, fragment
classes, pass responsibilities, SemanticIR/assembler surfaces, and proof
fixtures into candidate Profile/Baseline/Pack boundaries without moving code.
```

Recommended deliverables:

- pack boundary table:
  `CoreLanguagePack`, `TemporalPack`, `StreamPack`, `OLAPPack`,
  `InvariantPack`, `ContractModifiersPack`, `AssumptionsPack`,
  `EvidenceObservationPack`, `Pipeline/ProfilePack`;
- current owner map for parser/classifier/TypeChecker/SemanticIR/assembler
  responsibilities;
- OOF ownership map aligned with PROP-038 strict registries;
- fragment-class owner map;
- proof/golden fixture map per candidate pack;
- migration risk table;
- "must not migrate yet" list;
- recommended later proof slices.

Why this route:

- It directly follows `docs/dev/compiler-profile-architecture-direction.md`.
- It follows the C0-O preferred conservative route.
- It advances compiler/profile architecture without code churn.
- It keeps Spark applied pressure separate from compiler authority.
- It creates the missing map needed before loader/report, CompatibilityReport,
  public API/CLI, or dispatch-migration design can be safely scoped.

Suggested acceptance bar:

```text
proceed if the report is descriptive, maps current evidence accurately, and
preserves all closed surfaces;
hold if it implies live pack dispatch, public profile input, `.igapp` migration,
or runtime authority.
```

---

## Backup Route

Backup recommendation:

```text
prop038-strict-terminal-regression-hardening-v0
```

Route type:

```text
proof-only / regression hardening
```

Recommended goal:

```text
Close the R83/R84 non-blocking instrumentation asymmetry by proving explicit
ordinary success-path assembler-call evidence alongside strict terminal
assembler_calls: 0, while preserving the accepted public key-set and
non-persisting terminal behavior.
```

Why backup:

- It is bounded and low-risk.
- It strengthens the accepted R84 foundation before any public/loader/report
  expansion.
- It should remain inside the existing PROP-038 proof lane and avoid API,
  loader/report, CompatibilityReport, runtime, or production surfaces.

Why not primary:

- It hardens evidence but does not choose the next architecture direction.
- It does not answer Profile/Baseline/Pack decomposition questions.

---

## Candidate F Decomposition Notes

If Architect rejects route E, the strongest evidence-backed F sub-routes are:

| Sub-route | Best use |
| --- | --- |
| `compiler-profile-slot-contract-map-v0` | Clarify slot lifecycle, owners, and report-only missing-slot behavior before enforcement. |
| `ordered-rule-contract-proof-v0` | Test PROP-038 ordered-rule graph semantics against classifier/typechecker precedence pressure. |
| `compiler-profile-id-mandatory-transition-design-v0` | Design optional-to-required `.igapp` `compiler_profile_id` transition without changing manifests. |
| `profile-pack-manifest-shadow-proof-v0` | Proof-local shadow manifest for Profile/Baseline/Pack without current compiler dispatch. |
| `poc-compiler-close-delta-report-v0` | Summarize what remains before a current proof-compiler POC close. |

These are credible, but the pack boundary report should make them easier to
scope and prioritize.

---

## Closed-Surface List

This track and the recommended route do not authorize:

- code edits;
- compiler implementation;
- public API/CLI widening;
- `IgniterLang.compile` signature changes;
- strict source outside internal constructor/test seam;
- profile discovery/defaulting/finalization in public surfaces;
- loader/report compiler-profile status;
- CompatibilityReport compiler-profile section;
- persisted reports or sidecars;
- `.igapp` or golden migration;
- `.ilk`;
- CompilationReceipt links;
- signing or production verification;
- compiler dispatch migration;
- profile-assembled compiler rewrite;
- parser/classifier/TypeChecker/SemanticIR/assembler rewrites;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP production executors;
- cache;
- production behavior;
- Spark fixtures/specs or Spark implementation;
- treating Spark applied pressure as compiler authority.

---

## Recommendation For C4-A

Recommendation:

```text
accept E as next route
```

Open only:

```text
compiler-pack-boundary-report-v0
```

Keep backup visible:

```text
prop038-strict-terminal-regression-hardening-v0
```

Do not open public API/CLI, loader/report, CompatibilityReport, dispatch,
runtime, `.igapp`, signing, Ledger/TBackend, cache, or production behavior.
