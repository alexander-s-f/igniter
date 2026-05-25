# Compiler Release Public Nonclaims Pressure v0

Card: S3-R178-C3-X
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: `external-pressure-reviewer`
Mode: discussion
Initiator: architect-supervisor
Track: `compiler-release-public-nonclaims-pressure-v0`
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R178-C1-P1 (`compiler-release-public-nonclaims-docs-scope-v0`)
- S3-R178-C2-P1 (`compiler-release-public-readme-and-demo-claim-risk-survey-v0`)

---

## Question

Do the R178 public release/docs non-claims planning cards (C1-P1 and C2-P1)
together provide a sound basis for Portfolio to accept the planning boundary — with
safe wording labeled as proposals only, correct coverage of all closed surfaces,
docs-risk findings appropriately classified, and no public release/demo/publish/
release-execution/profile-finalization/branch-conditional/Spark/runtime authority
implied?

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-scope-v0.md`
  (S3-R178-C1-P1)
- `igniter-lang/docs/tracks/compiler-release-public-readme-and-demo-claim-risk-survey-v0.md`
  (S3-R178-C2-P1)
- `igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0.md`
  (S3-R177-C3-A)
- `igniter-lang/docs/tracks/stage3-round177-status-curation-v0.md`
  (S3-R177-C4-S)

---

## Checks

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| CHK-1 | C1-P1 safe wording is labeled as a proposal for future authorization, not current public copy | true | PASS — all three wording forms carry explicit "not currently authorized as public release copy" or equivalent label |
| CHK-2 | C1-P1 non-claims table covers all surfaces closed by R177-C3-A | true | PASS — 19-row non-claims table matches R177-C3-A closed-surfaces list: release execution, public release/demo claims, RubyGems publish, version/tag/push/sign/deploy, production readiness, runtime, profile finalization/discovery/defaulting, named/generated profile lookup, inline JSON profile source, env/config/sidecar profile lookup, public API/CLI widening, loader/report/CompatibilityReport, branch/conditional if_expr, all grammar support, Spark integration, Ruby Framework compatibility |
| CHK-3 | C1-P1 excluded feature table provides safe alternative wording for each excluded surface | true | PASS — 12-row table with explicit "safe alternative" column for every excluded surface including branch/conditional if_expr, full grammar support, profile finalization/discovery/defaulting, inline JSON, named/generated profile lookup, RubyGems publish, public release, public demo, runtime/Ledger/TBackend/stream/OLAP/cache, loader/report, Spark, Ruby Framework |
| CHK-4 | C1-P1 forbidden phrase list prohibits all surfaces that R177-C3-A keeps closed | true | PASS — 13 forbidden phrases explicitly prohibit RubyGems availability, production readiness, public demo, release-ready without qualifier, all-grammar support, branch/conditional if_expr, profile discovery/defaulting/finalization, automatic profile lookup, runtime/CompatibilityReport readiness, Spark integration, Ruby Framework compatibility, published package/install from RubyGems |
| CHK-5 | C1-P1 docs-polish boundary limits later route to bounded and authorized-only work | true | PASS — later docs polish route named (`compiler-release-public-nonclaims-docs-polish-v0`), allowed work enumerated with 5 explicit items, placement order restricts README changes to separate card, release execution/RubyGems/tags/signing/deployment/demo/production/Spark/if_expr remain closed |
| CHK-6 | C2-P1 blocker classification is accurate: CR-1 is a blocker before public docs polish, not a blocker for planning cards or C4-A acceptance | true | PASS — C2-P1 uses phrase "Blocker before public docs polish" and recommendation to C3-X is "proceed-with-blocker", correctly bounding the blocker to the docs-polish gate, not the current planning acceptance |
| CHK-7 | C2-P1 survey coverage is sufficient: root README, docs README, Ruby API, experiment/demo sources, POC READMEs | true | PASS — survey covers igniter-lang/README.md, docs/README.md, docs/proposals/README.md, docs/ruby-api.md, docs/language-spec.md, docs/spec, experiments/, docs/reports/; absent docs/guide/README.md and docs/dev/README.md noted as missing, not a public-claim blocker |
| CHK-8 | C2-P1 CR-1 finding is factual and the severity is correctly graded | true | PASS — `experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig:27` contains `Status: production-ready library skeleton`; graded blocker-before-public-docs-polish because specimen file lacks the Contextizer-style non-canon header present in adjacent files; severity grading is accurate |
| CHK-9 | C2-P1 harmless findings are not inflated to blockers | true | PASS — 9 items (CR-3, CR-5, CR-6, CR-7, CR-9, CR-10, CR-11, CR-12, CR-14) correctly classified as harmless historical/internal guardrails; each includes explicit "preserve" or "no correction required" disposition; none elevated above their evidence |
| CHK-10 | C2-P1 docs-polish candidates (CR-2, CR-4, CR-8, CR-15) carry actionable corrections and do not imply current public overclaim | true | PASS — all four carry specific suggested wording replacements; none are current root-README public claims; CR-4 and CR-8 are docs/ internal wording; CR-2 disarms its own claim; CR-15 is stale navigation (no overclaim) |
| CHK-11 | CR-13 (Spark production report) correctly requires Portfolio decision before public mention | true | PASS — `docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md` references Spark production evidence; C2-P1 classifies as "Needs Portfolio decision" and specifies "Keep internal" as baseline with explicit guard wording if public mention is ever authorized |
| CHK-12 | Release execution, public release/demo claims, RubyGems publish, version/tag/push/sign/deploy, profile finalization/discovery/defaulting, branch/conditional if_expr, and Spark remain closed in both C1-P1 and C2-P1 | true | PASS — C1-P1 non-authorization section and non-claims table close all named surfaces; C2-P1 non-authorization section mirrors the same list; no card opens, implies, or conditions on any of these surfaces |

**Verdict: proceed — no blockers on C4-A planning acceptance; 12/12 checks PASS**

---

## Non-Blocking Notes For C4-A

### NB-1 (important): CR-1 blocks any public docs polish card that links or quotes pressure specimens

`experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig:27`
currently reads:

```text
Status:  production-ready library skeleton
```

This is the only current source in the surveyed set that makes a direct
production-readiness claim without a non-canon header. CR-2 in the adjacent
Contextizer file disarms its own claim, CR-3 in the pressure-specimens README
provides a top-level non-canon disclaimer, and CR-7/CR-9/CR-10 in other
experiment READMEs carry strong guardrails. Only `igniter-text-engine.ig` is
missing the required disposition header.

This does not block C4-A planning acceptance or any current planning card.
It is a gating condition: **any future docs-polish card that links or quotes
pressure-specimen text must first resolve CR-1** by either fixing the header in
`igniter-text-engine.ig` or fencing the specimen directory from public-facing
docs navigation.

C4-A should name CR-1 resolution as a required precondition when authorizing a
later `compiler-release-public-nonclaims-docs-polish-v0` card.

### NB-2: CR-13 (Spark production report) requires explicit Portfolio decision before public mention

`docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md`
references Spark production metrics-backed receipt evidence. The report is
internally safe — it explicitly forbids Spark production integration — but it
should not be quoted in public docs without a Portfolio authorization.

C4-A should carry this constraint into any later docs-publication card:
use the C2-P1 guard wording ("Spark supplied pressure evidence for future
fixture design; not an integration, production behavior, or public release
claim") only if Portfolio explicitly authorizes mention.

---

## [Agree]

- C1-P1 safe wording is correctly labeled as a future-authorized proposal and
  not current public release copy. All three wording forms (short, evidence-
  specific, longer release-note candidate) are accurate, bounded, and
  non-authorizing.
- C1-P1 non-claims table (19 rows) and excluded-feature table (12 rows) are
  materially complete against the closed-surfaces list from R177-C3-A.
- C1-P1 forbidden phrase shapes (13 entries) and preferred phrase shapes
  (6 entries) provide concrete guardrails for future docs-polish authors.
- C2-P1 survey coverage is appropriate for a planning-round survey. The absence
  of `docs/guide/README.md` and `docs/dev/README.md` is noted and is not a
  public-claim blocker.
- C2-P1 classification is accurate: CR-1 is correctly graded blocker-before-
  public-docs-polish; docs-polish candidates are actionable; harmless findings
  are not inflated.
- No root README, docs index, proposals index, or Ruby API was found claiming
  RubyGems availability, completed release execution, production runtime,
  all-grammar support, branch/conditional support, profile discovery/defaulting/
  finalization, or Spark integration as an Igniter-Lang public claim.

## [Challenge]

- No material challenge. The planning boundary is sound for C4-A acceptance.
- Minor observation: C1-P1's label candidates (`repo_local_compiler_rc_evidence`,
  `local_package_install_smoke_readiness`, `bounded_profile_source_installed_smoke_readiness`,
  `local_compiler_rc_readiness_evidence`) do not carry an explicit
  "avoid" annotation in the docs-polish boundary section that refers back to the
  avoid-labels block. This is cosmetic — the avoid-labels block (`public_release_ready`,
  `rubygems_ready`, `production_ready`, `demo_ready`, `full_compiler_support`,
  `spark_ready`) is present in the document — but a docs-polish card template
  should pull both blocks into a single reference table to prevent drift.

## [Missing]

- CR-1 resolution mechanism is not specified in either C1-P1 or C2-P1. Both
  correctly defer it ("this card makes no edits"), but C4-A should assign a
  lightweight fix card or condition authorization on the fix landing before
  any public-facing docs work opens.
- C1-P1 docs-polish placement order (section "Later Docs Polish Boundary")
  recommends starting with "another track doc or release-note draft" before
  README, but does not specify which track doc or who may authorize that first
  placement. C4-A should name the minimum authorization step.

## [Sharper Question]

Does C4-A accept the R178 planning boundary and, if so, what are the exact
preconditions for opening a later `compiler-release-public-nonclaims-docs-polish-v0`
card — specifically: is CR-1 resolution required before docs-polish authorization,
and does CR-13 (Spark mention) require an explicit Portfolio statement at that
point?

## [Route]

```text
proceed — accept C1-P1 and C2-P1 as the R178 public non-claims planning bundle;
open compiler-release-public-nonclaims-planning-decision-v0 (C4-A) next;
carry NB-1 (CR-1 resolution precondition for docs-polish) and NB-2 (CR-13
Portfolio-gated) as binding notes into C4-A acceptance record.
```

---

## Compact Pressure Verdict

```text
S3-R178-C3-X: proceed — 12/12 checks PASS, no blockers.

C1-P1 safe wording is correctly proposals-only and covers all R177-C3-A closed
surfaces. C1-P1 non-claims table (19 rows), excluded-feature table (12 rows),
and forbidden-phrase list (13 entries) are materially complete.

C2-P1 survey finds no root README/API overclaim. CR-1 (igniter-text-engine.ig
"production-ready library skeleton") is a blocker-before-public-docs-polish only.
CR-13 (Spark production report) requires Portfolio decision before public mention.

Release execution, public release/demo claims, RubyGems publish, version/tag/push/
sign/deploy, profile finalization/discovery/defaulting, branch/conditional if_expr,
Spark, runtime, and production remain closed.

NB-1: CR-1 must be fixed/fenced before any docs-polish card links or quotes
pressure specimens. C4-A should name this as a docs-polish precondition.
NB-2: CR-13 requires explicit Portfolio authorization before any public mention
of Spark production evidence.

Recommended next: compiler-release-public-nonclaims-planning-decision-v0 (C4-A).
```
