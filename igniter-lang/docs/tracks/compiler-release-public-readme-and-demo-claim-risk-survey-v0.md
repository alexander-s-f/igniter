# Compiler Release Public README And Demo Claim Risk Survey v0

Card: S3-R178-C2-P1  
Agent: `[Evidence Hygiene Agent]`  
Role: `research-agent`  
Track: `compiler-release-public-readme-and-demo-claim-risk-survey-v0`  
Route: UPDATE  
Depends on: S3-R177-C3-A  
Status: done / survey-only  
Date: 2026-05-25

---

## Purpose

Survey current README/docs/demo-facing text for wording that could overclaim
public release readiness, production readiness, RubyGems availability, all
grammar support, branch/conditional `if_expr` support, profile
finalization/discovery/defaulting, Spark integration, runtime/production
behavior, or release execution.

This is a read-only survey except for this track document. It does not edit
README/docs/demo files, execute release, publish gems, authorize public claims,
or authorize docs polish.

---

## Inputs Read

Required inputs:

```text
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0.md
```

The required paths below are not present in this checkout:

```text
igniter-lang/docs/guide/README.md
igniter-lang/docs/dev/README.md
```

Related current boundary input read because it is the C1 companion for this
round:

```text
igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-scope-v0.md
```

Survey commands used:

```text
rg -n "demo|release|ready|production|RubyGems|if_expr|branch|conditional|profile source|compiler profile" igniter-lang/README.md igniter-lang/docs igniter-lang/experiments
rg -n "RubyGems|public release|production readiness|production-ready|release ready|release-ready|demo ready|demo-ready|if_expr|branch/conditional|profile finalization|profile discovery|defaulting|Spark integration|production behavior|publish not attempted|public demo|release execution|ready" igniter-lang/README.md igniter-lang/docs/README.md igniter-lang/docs/ruby-api.md igniter-lang/docs/language-spec.md igniter-lang/docs/spec igniter-lang/experiments --glob '!**/out/**' --glob '!**/*.json' --glob '!**/*.rb' --glob '!**/*.ig' --glob '!docs/archive/**'
```

The broad `rg` output includes many historical/internal tracks and archives.
Findings below focus on current README/API/spec indexes and demo/POC-facing
experiment docs or specimen files.

---

## Accepted Baseline

S3-R177-C3-A accepts only this bounded marker:

```text
bounded_profile_source_installed_smoke_readiness
```

Accepted safe marker wording:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI preserves the
accepted --compiler-profile-source PATH.json transport for one valid finalized
profile-source case, one malformed JSON preflight refusal, and one semantic
wrong-kind refusal.
```

It is explicitly not:

```text
public release readiness
public docs readiness
RubyGems availability
production readiness
demo readiness
all-grammar support
branch/conditional if_expr support
profile finalization/discovery/defaulting support
Spark integration
Ruby Framework compatibility
```

---

## Claim-Risk Table

| ID | File / line | Observed wording | Risk class | Risk | Suggested correction if docs polish opens |
| --- | --- | --- | --- | --- | --- |
| CR-1 | `experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig:27` | `Status: production-ready library skeleton` | blocker before public docs polish | The phrase is a direct production-readiness claim inside a demo/specimen source file and lacks the local disclaimer present in the Contextizer specimen. It could be copied into public docs as project authority. | Replace with `Status: external pressure specimen / not production-ready / non-canonical` or add a header matching the Contextizer disposition before the feature prose. |
| CR-2 | `experiments/pressure-specimens/mundane-application-pressure-v0/igniter-document-contextizer.ig:34-35` | `External claim: production-ready` plus `Project status: active pressure specimen only` | docs-polish candidate | The file already disarms the claim, but the words `production-ready` remain searchable and quoteable. | Prefer `External wording under test: production-ready; project status: pressure specimen only, not production deployment authority.` |
| CR-3 | `experiments/pressure-specimens/mundane-application-pressure-v0/README.md:65-75` | Notes external `production-ready` wording and says active disposition is non-canonical / not production deployment authority. | harmless historical/internal note | This is a good guardrail and should stay unless the specimen is rewritten. | No correction required; if public docs link this directory, keep this disclaimer near the top. |
| CR-4 | `docs/ruby-api.md:6-16` | `current public Ruby facade for the proof compiler`; `R52 adds one bounded caller-facing CLI exception...` | docs-polish candidate | Semantically safe because it closes other profile-source shapes, but `public` and round-id phrasing are internal/governance flavored. For public polish, it should not sound like a public release announcement. | Reword to `caller-facing local proof compiler API` and replace `R52 adds` with `Currently supported bounded CLI transport:`. |
| CR-5 | `docs/ruby-api.md:136-144` and `264-286` | Only authorized CLI shape and non-authorized surfaces are explicit. | harmless current guardrail | This is strong non-claim wording: no discovery/defaulting/finalization and no production behavior. | Preserve this section in any public docs polish; do not weaken it. |
| CR-6 | `docs/README.md:18-21` | Bounded CLI profile-source transport points to Ruby API and says `only ...` plus `no production/runtime authority`. | harmless current guardrail | This is safe and aligns with R177/R178 C1. | Preserve; optional polish can add `not RubyGems/public release readiness` if this index becomes public-facing. |
| CR-7 | `experiments/compiler_release_acceptance_harness_v0/README.md:7-9` | Proof-local harness; not official RC evidence; not public release claim. | harmless historical/internal note | The release non-claim is explicit and safe. | No correction required for claim hygiene. |
| CR-8 | `experiments/compiler_release_acceptance_harness_v0/README.md:32-36` | `Expected Status HOLD` because branch/conditional `if_expr` is unsupported. | docs-polish candidate | The branch/conditional exclusion is safe, but the README status is stale relative to later scope-aware accepted evidence. It may confuse readers during public docs polish. | Reword to `Historical harness note: branch/conditional if_expr is out of scope, not a release hold in later scope-aware evidence.` |
| CR-9 | `experiments/poc_mvp_live_touch_v0/README.md:15-16` | Not a public demo, release claim, production runtime, or language semantics route. | harmless current guardrail | This is exactly the needed non-claim for POC/demo-facing material. | Preserve. |
| CR-10 | `experiments/pressure-specimens/README.md:6` and `23-26` | Not production-ready; no production capability binding. | harmless current guardrail | Strong pressure-specimen disclaimer. | Preserve. |
| CR-11 | `experiments/external_pressure_specimens/README.md:8-13` and `31-47` | Proposed constructs beyond Stage 1-2; do not compile; proposed/not-yet-proposed feature list. | harmless current guardrail | It avoids all-grammar support claims and makes specimen status clear. | Preserve; if public, add a one-line `not demo/release evidence` near the top. |
| CR-12 | `docs/spec/ch5-compiler-pipeline.md:298` | `release-gate: PASS, publish not attempted` | harmless historical/internal note | The line explicitly says publish was not attempted. It is not a public release claim. | No correction required; if surfaced publicly, keep `publish not attempted` with the proof context. |
| CR-13 | `docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md:24-34` | Spark has production metrics-backed receipt evidence; Lang may open only synthetic fixture design; no Spark integration or production behavior. | needs Portfolio decision if public-facing | It references Spark production evidence. Safe internally because it explicitly forbids Spark production integration, but public docs should not cite this as Igniter-Lang/Spark integration. | Keep internal. If public mention is required, ask Portfolio for approved wording and use `Spark pressure signal only; no Igniter-Lang integration claim`. |
| CR-14 | `igniter-lang/README.md:17-18` | The language and platform should not share release pressure, package boundaries, or premature syntax/runtime commitments. | harmless current guardrail | Strong top-level separation note; no overclaim. | Preserve. |
| CR-15 | `igniter-lang/README.md:39-42` | `Current Source Horizon` references old `/docs/guide/...` and `/playgrounds/...` paths. | docs-polish candidate | Not an overclaim, but it is a stale navigation smell in a public-facing README. | Replace with current `docs/README.md`, `docs/current-status.md`, `docs/ruby-api.md`, and accepted local RC evidence page if one is later authorized. |

---

## Missing Required Paths

The card asked to read:

```text
igniter-lang/docs/guide/README.md
igniter-lang/docs/dev/README.md
```

Both are absent. This is not itself a public-claim blocker, but it is a docs
structure signal: public docs polish should not assume guide/dev index pages
exist until a docs-routing card creates or intentionally replaces them.

---

## Risk Classification Summary

| Class | Count | Items |
| --- | ---: | --- |
| Blocker before public docs polish | 1 | CR-1 |
| Docs-polish candidate | 4 | CR-2, CR-4, CR-8, CR-15 |
| Harmless historical/internal note | 9 | CR-3, CR-5, CR-6, CR-7, CR-9, CR-10, CR-11, CR-12, CR-14 |
| Needs Portfolio decision | 1 | CR-13 |

No current root README, docs index, proposals index, or Ruby API text was found
claiming RubyGems availability, completed release execution, production
runtime/deployment readiness, all-grammar support, branch/conditional support,
profile discovery/defaulting/finalization support, or Spark integration as an
Igniter-Lang public claim.

The main public-polish risk is specimen prose, especially CR-1.

---

## Suggested Wording Corrections

These are recommendations only; this card makes no edits.

### CR-1 Replacement

Replace:

```text
Status:  production-ready library skeleton
```

with:

```text
Status: external pressure specimen / non-canonical / not production-ready
```

or add a file header:

```text
# Project disposition:
#   active pressure specimen
#   non-canonical
#   not parser authority
#   not runtime authority
#   not production deployment authority
```

### CR-4 Replacement

Replace:

```text
This page documents the current public Ruby facade for the proof compiler.

R52 adds one bounded caller-facing CLI exception...
```

with:

```text
This page documents the current caller-facing local proof compiler API.

Currently supported bounded CLI profile-source transport:
```

### CR-8 Replacement

Replace the stale hold block with:

```text
Historical note: branch/conditional if_expr remains out of scope for the
accepted first-RC evidence chain. Later scope-aware evidence treats this as an
explicit exclusion, not as a current release hold.
```

### CR-13 Public Wording Guard

Do not write:

```text
Spark integration is ready.
```

Use only if Portfolio authorizes public mention:

```text
Spark supplied pressure evidence for future fixture design. This is not an
Igniter-Lang integration, production behavior, or public release claim.
```

---

## Public Docs Polish Blockers

Before public docs polish:

1. Fix or fence CR-1 so no current specimen source says
   `production-ready library skeleton` as project status.
2. Decide whether public docs should expose pressure-specimen directories at
   all. If yes, require a standard top-of-file non-canon header for specimen
   files with production/demo/ledger/LLM phrasing.
3. Ask Portfolio before public wording mentions Spark production evidence.

These blockers do not block internal research or release-readiness planning.
They block public-facing docs polish that links or quotes demo/specimen text.

---

## Risk Verdict For C3-X

Recommended C3-X verdict:

```text
proceed-with-blocker
```

Reason:

```text
No root README/docs index/API overclaim was found, and the accepted release
evidence remains bounded. However, CR-1 is a direct production-ready claim in a
demo/specimen source file and should be fixed or fenced before public docs
polish links or quotes pressure specimens.
```

Recommended C3-X checks:

| Check | Expected |
| --- | --- |
| Root README overclaims public release/RubyGems/production | false |
| Docs README overclaims public release/RubyGems/production | false |
| Ruby API overclaims profile discovery/defaulting/finalization | false |
| Ruby API weakens bounded `--compiler-profile-source PATH.json` shape | false |
| Experiment/demo source contains direct production-ready status | true, CR-1 |
| Branch/conditional `if_expr` support claimed | false |
| Spark integration claimed by Igniter-Lang public docs | false |
| Public docs polish blocker exists | true, CR-1 |

---

## Non-Authorization

This survey does not authorize:

```text
docs edits outside this track
public docs polish
release execution
RubyGems publish
version/tag/push/publish/sign/deploy
public release/demo claims
production readiness claims
all-grammar support claims
branch/conditional if_expr support claims
profile finalization/discovery/defaulting
Spark integration
runtime/production behavior
```

---

## Handoff

[D] Current public-facing indexes and Ruby API mostly preserve the required
non-claims.  
[S] CR-1 is the only blocker-level claim-risk finding: a pressure-specimen
source says `production-ready library skeleton`.  
[T] This track is survey-only; no docs/code/release edits were made.  
[R] C3-X should proceed with a blocker: fix/fence CR-1 before public docs
polish links or quotes pressure specimens.  
[Next] Public non-claims pressure can use this table plus
`compiler-release-public-nonclaims-docs-scope-v0.md` as the evidence bundle.
