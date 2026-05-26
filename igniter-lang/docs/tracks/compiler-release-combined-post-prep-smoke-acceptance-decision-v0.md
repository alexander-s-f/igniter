# Compiler Release Combined Post-Prep Smoke Acceptance Decision v0

Card: S3-R183-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-combined-post-prep-smoke-acceptance-decision-v0
Route: UPDATE
Status: done / accepted
Date: 2026-05-26

Depends on:
- S3-R183-C2-I
- S3-R183-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md`
- `igniter-lang/docs/discussions/compiler-release-combined-post-prep-smoke-pressure-v0.md`
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`
- `igniter-lang/docs/tracks/stage3-round182-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-acceptance-decision-v0.md`

---

## Decision

Decision:

```text
accept combined post-prep smoke evidence
recognize bounded local package/install smoke readiness for 0.1.0.alpha.1
recognize bounded installed profile-source smoke readiness for 0.1.0.alpha.1
supersede invalidated 0.1.0.pre.stage2 package/profile-source smoke evidence
open release-execution authorization review next
do not authorize release execution in this card
do not authorize RubyGems publish in this card
do not authorize public release/demo claims in this card
keep version/tag/push/publish/sign/deploy closed
keep branch/conditional if_expr excluded
keep profile finalization/discovery/defaulting closed
keep Spark out of scope
keep compiler/runtime behavior changes closed
```

S3-R183-C2-I is accepted as the fresh local post-prep smoke packet for the
current public prerelease candidate:

```text
igniter_lang 0.1.0.alpha.1
```

---

## Acceptance Basis

C2-I top-level result:

```text
status:        PASS
failed_checks: 0
hold_reasons:  0
```

C3-X pressure verdict:

```text
verdict:            proceed with non-blocking notes
checks:             16/16 PASS
blockers:           none
non-blocking notes: 3
```

The non-blocking notes are accepted as hygiene-only:

- NB-1: CM-0 uses repo-relative `-I` as a pre-build source version probe only;
  installed package isolation is proven separately by CM-7.
- NB-2: SHA256 is self-attested via `Digest::SHA256`; acceptable for this
  smoke and consistent with prior accepted smoke precedent.
- NB-3: commit message hygiene issue; no scope, order, or safety impact.

No follow-up is required before release-execution authorization review may
open.

---

## Accepted Smoke Record

| Field | Accepted value |
| --- | --- |
| card | `S3-R183-C2-I` |
| track | `compiler-release-combined-post-prep-smoke-v0` |
| run id | `S3R183C2I_20260526T143139Z` |
| package | `igniter_lang` |
| version | `0.1.0.alpha.1` |
| status | `PASS` |
| artifact SHA256 | `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6` |
| failed checks | `0` |
| hold reasons | `0` |
| temp cleanup | `complete` |

Durable summary:

```text
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json
```

---

## Evidence Accepted

### Artifact / Package

Accepted:

- version observed: `0.1.0.alpha.1`;
- local gem build succeeded;
- fresh artifact SHA256 captured:
  `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6`;
- packaged file proof includes:
  - `README.md`;
  - `RELEASE_NOTES.md`;
  - `bin/igc`;
  - `lib/igniter_lang/version.rb`;
- no `.gem` artifact retained in the repo.

### Package / Install Smoke

Accepted:

```text
package_install.status: PASS
positive corpus: 5/5 PASS
refusal corpus:  3/3 PASS
```

Positive corpus:

- `add_baseline.ig`;
- `boolean_gate.ig`;
- `integer_arithmetic.ig`;
- `multi_input_diverse.ig`;
- `poc_derived.ig`.

Refusal corpus:

- `parse_refusal.ig` -> `parse_refusal`;
- `type_mismatch.ig` -> `oof`;
- `unresolved_symbol.ig` -> `oof`.

The R173 refusal-kind hygiene note is closed for this smoke because
`type_mismatch.ig` and `unresolved_symbol.ig` are now labeled `oof`.

### Profile-Source Installed Smoke

Accepted:

```text
profile_source.status: PASS
expected profile id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
```

Accepted cases:

- valid finalized profile-source success:
  - `result_status: ok`;
  - `.igapp` written;
  - manifest `compiler_profile_id` matches expected profile id.
- malformed JSON preflight refusal:
  - `refusal_kind: profile_source_preflight`;
  - stderr-only;
  - no `.igapp`;
  - no compilation report.
- semantic wrong-kind refusal:
  - `refusal_kind: profile_source_semantic_refusal`;
  - stdout compiler result JSON;
  - compilation report present;
  - no `.igapp`;
  - qualified diagnostic under `compiler_profile_source.*`.

### Isolation / Leak Safety

Accepted:

- installed `igc` was invoked from isolated temp `$BIN_DIR`;
- `require "igniter_lang"` loaded from isolated temp gem home;
- no repo-relative `-I` was used for installed-package proof;
- no repo `RUBYLIB`;
- repo path leak scan clean;
- temp cleanup complete, retained paths empty.

---

## Superseded Evidence

The prior `0.1.0.pre.stage2` local smoke evidence is superseded for the bounded
local smoke scope:

| Prior evidence | Prior version | Prior SHA256 | Superseded by |
| --- | --- | --- | --- |
| package/install smoke | `0.1.0.pre.stage2` | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` | R183 `0.1.0.alpha.1` combined smoke |
| profile-source installed smoke | `0.1.0.pre.stage2` | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` | R183 `0.1.0.alpha.1` combined smoke |

Allowed recognition:

```text
bounded local package/install and profile-source installed smoke readiness for
igniter_lang 0.1.0.alpha.1
```

Not authorized:

```text
RubyGems readiness
public release readiness
production readiness
demo readiness
stable release
all grammar support
```

---

## Required Questions

### Is combined post-prep smoke accepted?

Yes.

### Run id?

```text
S3R183C2I_20260526T143139Z
```

### Version?

```text
0.1.0.alpha.1
```

### Artifact SHA256?

```text
sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
```

### Packaged file inclusion status?

Accepted:

```text
README.md: true
RELEASE_NOTES.md: true
bin/igc: true
lib/igniter_lang/version.rb: true
```

### Package/install smoke status?

```text
PASS
```

### Profile-source smoke status?

```text
PASS
```

### Refusal behavior status?

Accepted:

```text
basic refusal corpus: 3/3 PASS
profile-source preflight refusal: PASS
profile-source semantic refusal: PASS
```

### No repo path leak status?

```text
PASS / no leak
```

### Does fresh smoke supersede invalidated `0.1.0.pre.stage2` evidence?

Yes, for bounded local package/install and profile-source installed smoke
readiness only.

### May release-execution authorization review open next?

Yes.

Release execution itself remains closed until that later review explicitly
authorizes it.

---

## Next Route

Open:

```text
compiler-release-execution-final-authorization-review-v0
```

Purpose:

- decide whether `igniter_lang 0.1.0.alpha.1` may be published/released;
- require explicit user approval before any execution card can run release
  commands;
- define exact version/tag/push/publish/sign/deploy boundary;
- define credential and 2FA handling;
- define post-publish verification;
- preserve public claim discipline.

This acceptance does not itself authorize release execution.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R184-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-execution-final-authorization-review-v0

Route: UPDATE

Goal:
Decide whether a bounded release execution card may open for
`igniter_lang 0.1.0.alpha.1`, using the accepted R183 combined post-prep smoke
evidence.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md
  - igniter-lang/docs/discussions/compiler-release-combined-post-prep-smoke-pressure-v0.md
  - igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json
  - igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-acceptance-decision-v0.md
  - igniter-lang/README.md
  - igniter-lang/RELEASE_NOTES.md
  - igniter-lang/igniter_lang.gemspec
  - igniter-lang/lib/igniter_lang/version.rb
- Decide:
  - authorize bounded release execution card;
  - require explicit user approval before execution;
  - authorize release prep only;
  - hold;
  - redirect.
- If authorizing a future execution card, define exact:
  - target package/version;
  - artifact SHA256 to publish or rebuild policy;
  - tag naming stance;
  - git state requirements;
  - required explicit user approval wording;
  - credential/2FA boundary;
  - allowed release commands;
  - abort criteria;
  - post-execution verification;
  - public non-claims after publish;
  - closed surfaces.
- Explicitly answer:
  - whether release execution is authorized now or only in a later card;
  - whether RubyGems publish may open;
  - whether tag/push/sign/deploy may open;
  - whether public release/demo claims remain closed or receive exact
    allowed wording;
  - whether branch/conditional `if_expr` remains excluded;
  - whether profile finalization/discovery/defaulting remains closed;
  - whether Spark remains out of scope.

Do not:
- execute release commands in this card;
- publish gems in this card;
- create tags/push/sign/deploy in this card;
- authorize public release/demo claims unless explicitly and narrowly stated.

Deliver:
- Decision doc in `igniter-lang/docs/tracks/` or `igniter-lang/docs/gates/`
- Compact decision summary
- Exact release execution card boundary or hold reasons
```

---

## Remaining Closed Surfaces

Remain closed:

```text
release execution
RubyGems publish
git tag creation
git push
version/tag/push/publish/sign/deploy
public release/demo claims unless later explicitly narrowed
production readiness claims
stable release claims
all grammar support claims
branch/conditional if_expr support
profile finalization/discovery/defaulting
named/generated profile lookup
inline JSON profile input
env/config/sidecar profile lookup
public API/CLI widening
loader/report or CompatibilityReport readiness
runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache behavior
Spark integration or Spark public evidence claims
Ruby Framework compatibility claims
compiler/runtime behavior changes
```

---

## Compact Summary

```text
S3-R183-C4-A: accepted.

Accepted:
- combined post-prep smoke PASS
- run id: S3R183C2I_20260526T143139Z
- version: 0.1.0.alpha.1
- artifact SHA256: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
- packaged README.md + RELEASE_NOTES.md
- package/install smoke PASS
- profile-source installed smoke PASS
- basic refusal corpus PASS
- no repo path leak
- temp cleanup complete

Pressure:
- 16/16 PASS
- blockers: none
- non-blocking notes: 3 hygiene-only

Supersedes:
- invalidated 0.1.0.pre.stage2 package/profile-source smoke evidence
  for bounded local smoke readiness only.

Next:
- release-execution final authorization review may open.

Still closed:
- release execution
- RubyGems publish
- tag/push/sign/deploy
- public release/demo claims
- branch/conditional if_expr
- profile finalization/discovery/defaulting
- Spark
- compiler/runtime behavior changes
```

