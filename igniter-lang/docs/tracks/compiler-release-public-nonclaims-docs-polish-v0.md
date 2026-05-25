# Compiler Release Public Nonclaims Docs Polish v0

Card: S3-R179-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: compiler-release-public-nonclaims-docs-polish-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R179-C1-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-docs-polish-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-planning-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-scope-v0.md`
- `igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`

---

## Authorized Write Scope

Files edited (exactly matching C1-A authorized set):

```text
igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-polish-v0.md  (this file)
```

No other files were edited.

---

## CR-1 Fix

File: `igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig`

### Disposition header added (top of file, after module declaration)

```text
# =============================================================================
# DISPOSITION: external pressure specimen / non-canonical
#   Not parser authority. Not runtime authority.
#   Not production deployment authority. Not public demo/release evidence.
#   This file is an active pressure specimen used for bounded compiler testing.
# =============================================================================
```

### Status line changed

Before:

```text
# Status:  production-ready library skeleton
```

After:

```text
# Status:  external pressure specimen / non-canonical / not production-ready
```

No language-spec content outside the header/status block was altered.

---

## README Changes

File: `igniter-lang/README.md`

### Before (stale source horizon)

```text
## Current Source Horizon

Read-only context:

- `/docs/guide/igniter-lang-foundation.md`
- `/docs/research/igniter-lang-convergence-report.md`
- `/docs/research/project-status-horizon-report.md`
- `/playgrounds/docs/experts/igniter-lang`
```

### After (current navigation + local evidence non-claims)

```text
## Current Navigation

Internal read-only context (local evidence only — not a release, publish, or public demo claim):

- [docs/README.md](docs/README.md) — documentation index
- [docs/current-status.md](docs/current-status.md) — stage scoreboard and accepted local evidence
- [docs/ruby-api.md](docs/ruby-api.md) — caller-facing local proof compiler API

Accepted local evidence (repo-local; release execution and public release/demo claims remain closed):

- Repo-local compiler RC evidence: PASS
- Local package install smoke: PASS
- Bounded installed profile-source smoke: PASS

RubyGems publish, release execution, version/tag/push/sign/deploy, profile
finalization/discovery/defaulting, branch/conditional `if_expr`, Spark
integration, runtime, and production behavior remain out of scope.
```

All four stale source-horizon paths replaced with live internal links. Non-claims
block added adjacent to local evidence wording. No public release/demo/RubyGems
claim introduced.

---

## Docs Index Changes

File: `igniter-lang/docs/README.md`

### Added non-claims note near profile-source transport entry

Before (navigation block extract):

```text
Bounded CLI profile-source transport
  → ruby-api.md#cli-compiler-profile-source-transport
    only `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`;
    no production/runtime authority
```

After:

```text
Bounded CLI profile-source transport
  → ruby-api.md#cli-compiler-profile-source-transport
    only `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`;
    no production/runtime authority
Accepted local release evidence (local compiler/package evidence only)
  → current-status.md
    repo-local compiler RC evidence: PASS;
    local package install smoke: PASS;
    bounded installed profile-source smoke: PASS;
    not a release, publish, production, or public demo claim;
    RubyGems publish, release execution, version/tag/push/sign/deploy,
    profile finalization/discovery/defaulting, branch/conditional if_expr,
    Spark integration, runtime, and production behavior remain out of scope
```

Index structure was not reorganized. Stage 1/Stage 2 sections were not altered.

---

## Ruby API Changes

File: `igniter-lang/docs/ruby-api.md`

### CR-4 wording cleanup

Before (lines 6 and 8–12):

```text
This page documents the current public Ruby facade for the proof compiler.

R52 adds one bounded caller-facing CLI exception for transporting an
already-finalized compiler profile source from a JSON file:

[...]

All other CLI profile-source input shapes, inline JSON parsing, profile
discovery, profile defaulting, and profile finalization remain closed.
```

After:

```text
This page documents the current caller-facing local proof compiler API.

Currently supported bounded CLI profile-source transport:

[...]

All other CLI profile-source input shapes, inline JSON parsing, profile
discovery, profile defaulting, and profile finalization remain closed.
```

Changes:
- "current public Ruby facade for the proof compiler" → "current caller-facing local proof compiler API"
- "R52 adds one bounded caller-facing CLI exception for transporting an already-finalized compiler profile source from a JSON file:" → "Currently supported bounded CLI profile-source transport:"

All existing non-authorized surfaces and production exclusion sections were preserved unchanged.

---

## Forbidden Phrase Scan

Scan executed on all four changed files against the C1-A forbidden phrase set.

```text
Files scanned:
  experiments/pressure-specimens/mundane-application-pressure-v0/igniter-text-engine.ig
  README.md
  docs/README.md
  docs/ruby-api.md

Phrases scanned:
  production-ready | production ready | public release ready | release ready
  demo ready | RubyGems available | available on RubyGems | published package
  install from RubyGems | supports all grammar | supports branch
  supports conditional | supports if_expr | profile discovery
  profile defaulting | profile finalization | Spark integrated
  Spark ready | Ruby Framework compatible
```

Hits found and disposition:

| File | Line | Hit | Disposition |
| --- | --- | --- | --- |
| igniter-text-engine.ig | Status line | "not production-ready" | Negation — required CR-1 replacement; fences the claim |
| docs/ruby-api.md | 15 | "profile defaulting ... remain closed" | Negation — exclusion wording |
| docs/ruby-api.md | 271 | "profile discovery, defaulting, or finalization in the CLI" | Negation — non-authorized surfaces list |
| docs/README.md | 29 | "profile finalization/discovery/defaulting ... remain out of scope" | Negation — newly added non-claims block |

Result:

```text
SCAN CLEAN: no forbidden phrase appears as an active public/project claim.
All hits are in negation or exclusion context.
```

---

## Proof Matrix

| Proof | Requirement | Status |
| --- | --- | --- |
| P1 | Changed files are exactly within authorized write scope | ✅ PASS — 5 files: specimen, README, docs/README, ruby-api, this track doc |
| P2 | CR-1 risky status line removed or fenced | ✅ PASS — disposition header added; status line replaced with "external pressure specimen / non-canonical / not production-ready" |
| P3 | README stale source-horizon paths removed or replaced safely | ✅ PASS — all 4 stale paths replaced with live internal links + non-claims block |
| P4 | Docs index preserves bounded CLI/profile-source non-claims | ✅ PASS — note added; existing wording preserved; no restructuring |
| P5 | Ruby-api wording no longer implies a public release announcement | ✅ PASS — "public Ruby facade" → "caller-facing local proof compiler API"; "R52 adds" → "Currently supported" |
| P6 | CR-13 remains internal-only; no public Spark production evidence wording | ✅ PASS — no Spark wording added to any file |
| P7 | Forbidden phrase scan completed | ✅ PASS — scan clean; all hits in negation/exclusion context |
| P8 | Release execution/public claims/RubyGems/version/tag/push/sign/deploy closed | ✅ PASS — no such claims added; non-claims block explicitly lists all as out of scope |
| P9 | No compiler/runtime/package metadata/gemspec code changed | ✅ PASS — only docs and specimen header edited |

---

## Non-Claims Preservation Checklist

| Surface | Status |
| --- | --- |
| Release execution | Closed — stated in README and docs/README non-claims block |
| Public release claims | Closed — README "not a release, publish, or public demo claim" |
| Public demo claims | Closed — README and docs/README non-claims block |
| RubyGems availability | No claim — not present in any changed file |
| RubyGems publish | Closed — docs/README non-claims block |
| Version/tag/push/publish/sign/deploy | Closed — README non-claims block |
| Production readiness | No claim — CR-1 fenced; README "not production-ready" |
| All-grammar support | No claim — not present in any changed file |
| Branch/conditional `if_expr` | Excluded — docs/README non-claims block names it |
| Profile finalization/discovery/defaulting | Closed — docs/README and ruby-api both negate |
| Spark integration | Internal-only — CR-13 not surfaced in any public-facing edited file |
| Ruby Framework compatibility | No claim — not present in any changed file |
| Runtime/production behavior | No claim — stated out of scope in README and docs/README |

---

## Remaining Blockers

None within the authorized scope of this card.

Pending (outside this card's authority):

- Release-note draft: not authorized this round (C1-A explicitly closed)
- Public copy placement: closed
- Release execution authorization: closed pending separate card

---

## Compact Receipt

```text
card:                         S3-R179-C2-I
track:                        compiler-release-public-nonclaims-docs-polish-v0
status:                       done
authorized_by:                S3-R179-C1-A
files_changed:                5 (specimen, README, docs/README, ruby-api, this track doc)
CR-1_status:                  fixed — disposition header added; status line fenced
CR-13_status:                 internal-only preserved; no Spark public wording added
README_stale_paths_replaced:  yes (4 stale paths → current navigation + non-claims)
docs_index_note_added:        yes (local evidence non-claims near profile-source entry)
ruby_api_wording_cleaned:     yes (CR-4 wording: public facade → caller-facing local API; R52 → Currently supported)
forbidden_phrase_scan:        CLEAN (all hits in negation/exclusion context)
proof_matrix:                 P1-P9 all PASS
release_execution:            closed
public_release_demo_claims:   closed
rubygems_publish:             closed
version_tag_push_sign_deploy: closed
profile_finalization_etc:     closed
if_expr:                      excluded
spark:                        internal-only
compiler_runtime_code_edited: no
gemspec_version_edited:       no
```
