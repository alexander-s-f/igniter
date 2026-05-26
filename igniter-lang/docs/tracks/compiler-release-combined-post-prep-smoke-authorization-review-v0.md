# Compiler Release Combined Post-Prep Smoke Authorization Review v0

Card: S3-R183-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-combined-post-prep-smoke-authorization-review-v0
Route: UPDATE
Status: done / authorized combined smoke execution
Date: 2026-05-26

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round182-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-v0.md`
- `igniter-lang/docs/discussions/compiler-release-release-notes-bundling-follow-up-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`
- `igniter-lang/lib/igniter_lang/version.rb`

---

## Decision

Decision:

```text
authorize bounded combined post-prep smoke execution
target package: igniter_lang
target version: 0.1.0.alpha.1
combine package/install smoke and profile-source installed smoke in one C2-I
require fresh gem artifact SHA256
require packaged README.md and RELEASE_NOTES.md verification
require isolated install with no repo-relative load path
require positive/refusal/profile-source corpus
require no repo path leak checks
do not authorize release execution
do not authorize RubyGems publish
do not authorize public release/demo claims
do not authorize version/tag/push/publish/sign/deploy
do not authorize package metadata edits
do not authorize compiler/runtime behavior changes
keep branch/conditional if_expr excluded
keep profile finalization/discovery/defaulting closed
keep Spark out of scope
```

S3-R183-C2-I may execute the smoke defined below.

---

## Authorization Basis

R182 fully closed the packaging precondition that blocked fresh smoke:

```text
RELEASE_NOTES.md bundled in gemspec spec.files
README prior-evidence qualifier added
0.1.0.alpha.1 remains accepted public prerelease candidate
C3-X pressure: 14/14 PASS, no blockers, no non-blocking notes
```

The live package files now align with the smoke target:

```text
version.rb: 0.1.0.alpha.1
spec.files: lib/**/*.rb, bin/igc, README.md, RELEASE_NOTES.md
README: not yet published; fresh smoke required for 0.1.0.alpha.1
```

Prior accepted smoke evidence remains useful as corpus/reference, but it is
not current for the new candidate artifact:

| Prior evidence | Version | Status for R183 |
| --- | --- | --- |
| Package/install smoke | `0.1.0.pre.stage2` | invalidated for current artifact; use as corpus/reference only |
| Profile-source installed smoke | `0.1.0.pre.stage2` | invalidated for current artifact; use as corpus/reference only |

Therefore a fresh combined smoke is the correct next move.

---

## Explicit Answers

### May smoke execution open next?

Yes.

R183 authorizes one bounded C2-I smoke execution card for combined post-prep
package/install + profile-source installed smoke.

### May generated outputs be called post-prep smoke evidence?

Only after the authorized C2-I run completes.

Allowed label after C2-I:

```text
post-prep local smoke evidence for igniter_lang 0.1.0.alpha.1
```

Not allowed:

```text
release evidence
public release evidence
RubyGems readiness
production readiness
demo readiness
```

### Can fresh smoke supersede the invalidated `0.1.0.pre.stage2` evidence?

Yes, but only after C2-I lands and a later C4-A accepts the smoke evidence.

If accepted later, the fresh smoke may supersede the invalidated package/install
and profile-source installed readiness markers for the bounded local smoke
scope. It still will not authorize release execution, RubyGems publish, public
claims, or production readiness.

### Does release execution remain closed?

Yes.

### Does RubyGems publish remain closed?

Yes.

### Do public release/demo claims remain closed?

Yes.

### Do version/tag/push/publish/sign/deploy remain closed?

Yes.

### Does branch/conditional `if_expr` remain excluded?

Yes.

### Does profile finalization/discovery/defaulting remain closed?

Yes.

### Does Spark remain out of scope?

Yes.

---

## Exact C2-I Write / Output Scope

Allowed repo writes:

```text
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/**
igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md
```

Allowed temp writes:

```text
/private/tmp/igniter_lang_combined_post_prep_smoke_<run_id>/**
```

Required durable output:

```text
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/<run_id>/combined_post_prep_smoke_summary.json
```

Allowed implementation file:

```text
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/combined_post_prep_smoke_v0.rb
```

Do not mutate:

- `igniter-lang/igniter_lang.gemspec`;
- `igniter-lang/README.md`;
- `igniter-lang/RELEASE_NOTES.md`;
- `igniter-lang/lib/igniter_lang/version.rb`;
- prior smoke outputs;
- compiler/runtime/library code;
- public docs outside the C2-I track doc.

---

## Temp Artifact Policy

C2-I must build and install from temp/output locations only.

Required:

- build the `.gem` artifact into a temp or experiment-local output path;
- install into an isolated temp `GEM_HOME`;
- avoid repo-local `RUBYLIB`;
- avoid repo-relative `-I`;
- remove temp roots when practical after durable summary is written;
- if cleanup is partial, record exact retained temp paths and reason.

Forbidden:

- leaving built `.gem` artifacts in the repo root;
- mutating existing `.igapp` artifacts, golden files, POC outputs, or prior
  smoke outputs;
- using local source checkout paths as proof of installed package behavior.

---

## Required Command Matrix

C2-I must record commands and exit statuses for at least:

```text
CM-0: verify version.rb reports 0.1.0.alpha.1
CM-1: validate gemspec syntax/loadability
CM-2: build igniter_lang gem artifact locally
CM-3: capture gem artifact SHA256
CM-4: inspect built gem packaged files include README.md and RELEASE_NOTES.md
CM-5: install built gem into isolated temp GEM_HOME
CM-6: verify installed igc is present and invokable
CM-7: verify require "igniter_lang" without repo-relative -I / RUBYLIB
CM-8: run positive compile corpus through installed igc
CM-9: run basic refusal corpus through installed igc
CM-10: run valid finalized profile-source success through installed igc
CM-11: run malformed JSON profile-source preflight refusal through installed igc
CM-12: run semantic wrong-kind profile-source refusal through installed igc
CM-13: run no repo path leak scan over summaries/stdout/stderr/report surfaces
```

Command names may differ, but evidence must map clearly to these checks.

---

## Required Corpus

Use prior accepted smoke scripts/docs only as reference. C2-I may create
harness-local fixture copies under the new experiment directory.

### Package / Install Corpus

Minimum:

- same positive compile coverage level as R173: at least 5 positive cases;
- same basic refusal coverage level as R173: at least 3 refusal cases;
- installed `igc compile` must be used;
- no repo-relative `-I`;
- no `.igapp` emitted for refusal cases.

Future hygiene:

- type mismatch and unresolved symbol refusal labels should be normalized as
  `oof` if those cases are reused, carrying the R173 NB-1 learning forward.

### Profile-Source Corpus

Minimum:

- one valid finalized profile-source success case;
- one malformed JSON profile-source preflight refusal case;
- one semantic wrong-kind profile-source refusal case.

Required profile-source behavior:

- success uses `--compiler-profile-source PATH.json`;
- success writes `.igapp` and expected manifest `compiler_profile_id`;
- malformed JSON is CLI-owned preflight refusal, writes no `.igapp` and no
  compilation report;
- semantic wrong-kind refusal writes compiler result/report with qualified
  `compiler_profile_source.*` diagnostic and no `.igapp`;
- no profile finalization, discovery, defaulting, named/generated lookup,
  inline JSON, env/config lookup, or sidecar lookup.

---

## Package File Inclusion Checks

C2-I must prove the built gem artifact includes:

```text
README.md
RELEASE_NOTES.md
bin/igc
lib/igniter_lang/version.rb
```

and must record the complete relevant package file list or a filtered file-list
proof sufficient for pressure review.

---

## Result Packet Shape

Required summary JSON shape:

```text
{
  "card": "S3-R183-C2-I",
  "track": "compiler-release-combined-post-prep-smoke-v0",
  "run_id": "...",
  "status": "PASS|HOLD|FAIL",
  "package": "igniter_lang",
  "version": "0.1.0.alpha.1",
  "artifact": {
    "path": "...",
    "sha256": "sha256:...",
    "packaged_files": {
      "readme": true,
      "release_notes": true,
      "bin_igc": true,
      "version_rb": true
    }
  },
  "command_matrix": [...],
  "package_install": {
    "status": "PASS|HOLD|FAIL",
    "positive_corpus": {...},
    "refusal_corpus": {...}
  },
  "profile_source": {
    "status": "PASS|HOLD|FAIL",
    "success_case": {...},
    "preflight_refusal_case": {...},
    "semantic_refusal_case": {...}
  },
  "repo_path_leak": false,
  "temp_artifacts": {
    "cleanup": "complete|partial",
    "retained_paths": []
  },
  "non_claims": {
    "release_execution": false,
    "rubygems_publish": false,
    "public_release_demo_claims": false,
    "version_tag_push_publish_sign_deploy": false,
    "branch_conditional_if_expr": false,
    "profile_finalization_discovery_defaulting": false,
    "spark": false,
    "production": false
  },
  "closed_surfaces": [...]
}
```

Additional fields are allowed if they do not obscure these required fields.

---

## PASS / HOLD / FAIL Criteria

### PASS

All are required:

- version is `0.1.0.alpha.1`;
- gemspec syntax/loadability passes;
- local gem build passes;
- fresh SHA256 captured;
- packaged files include `README.md` and `RELEASE_NOTES.md`;
- isolated install passes;
- installed `igc` command shape passes;
- `require "igniter_lang"` works without repo-relative `-I` / `RUBYLIB`;
- positive compile corpus passes;
- basic refusal corpus passes;
- profile-source success passes;
- profile-source preflight refusal passes;
- profile-source semantic refusal passes;
- no repo path leak;
- non-claims block remains true/closed;
- no forbidden release/tag/push/publish/sign/deploy/public-claim action occurs.

### HOLD

Use HOLD for incomplete evidence where no unsafe action occurred, for example:

- optional fixture/corpus file is missing but no claim was made;
- temp cleanup is partial but accurately reported and outside the repo;
- environment/tooling prevents one check from running without changing package
  state.

HOLD must include exact follow-up blockers.

### FAIL

Use FAIL if any safety or artifact correctness boundary breaks, including:

- version mismatch;
- gem build/install failure;
- package artifact missing `README.md` or `RELEASE_NOTES.md`;
- repo-relative load path used as proof;
- positive/refusal/profile-source behavior regresses;
- repo path leak appears in public/result surfaces;
- package metadata, docs, compiler/runtime, or public API/CLI are modified
  outside the authorization;
- release execution, publish, tag, push, sign, deploy, or public claim occurs.

FAIL takes precedence over HOLD.

---

## Closed Surfaces

Remain closed:

```text
release execution
RubyGems publish
git tag creation
git push
version/tag/push/publish/sign/deploy
public release/demo claims
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

## Exact C2-I Boundary

```text
Card: S3-R183-C2-I
Agent: [Package Agent / Implementation Agent]
Role: package-agent
Track: compiler-release-combined-post-prep-smoke-v0

Route: UPDATE
Depends on:
- S3-R183-C1-A

Goal:
Execute the bounded combined post-prep package/install + profile-source
installed smoke for `igniter_lang 0.1.0.alpha.1`.

Allowed writes:
- igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/**
- igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md
- /private/tmp/igniter_lang_combined_post_prep_smoke_<run_id>/**

Required:
- build a fresh local `igniter_lang 0.1.0.alpha.1` gem artifact;
- capture SHA256;
- prove packaged files include README.md and RELEASE_NOTES.md;
- install into isolated temp GEM_HOME;
- verify installed igc and require behavior without repo-relative load paths;
- run package positive/refusal corpus;
- run profile-source success/preflight-refusal/semantic-refusal corpus;
- scan outputs for repo path leaks;
- write summary JSON and track doc.

Do not:
- publish gems;
- create tags;
- push;
- sign/deploy;
- run release commands;
- edit package metadata;
- edit README/RELEASE_NOTES/version;
- widen CLI/API;
- change compiler/runtime behavior;
- claim public release/demo readiness.

Deliver:
- Track doc in `igniter-lang/docs/tracks/`
- Smoke summary JSON under experiment output
- Command matrix
- Artifact SHA256
- PASS/HOLD/FAIL result packet
- No-claims / closed-surfaces receipt
```

---

## Compact Summary

```text
S3-R183-C1-A: authorized combined post-prep smoke execution.

Target:
- igniter_lang 0.1.0.alpha.1

Authorized next:
- S3-R183-C2-I package/install + profile-source installed smoke

Purpose:
- replace invalidated 0.1.0.pre.stage2 package/profile-source smoke evidence
  with fresh local smoke evidence for 0.1.0.alpha.1, if later accepted.

Required:
- fresh gem build
- fresh SHA256
- README.md + RELEASE_NOTES.md packaged-file proof
- isolated install
- installed igc positive/refusal corpus
- installed profile-source success/preflight/semantic corpus
- no repo path leak
- result summary JSON

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

