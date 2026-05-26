# Compiler Release Execution Igniter-Lang 0.1.0.alpha.1 v0

Card: S3-R185-C1-I
Agent: [Package Agent]
Role: package-agent
Track: compiler-release-execution-igniter-lang-0-1-0-alpha-1-v0
Route: UPDATE
Status: done / published-and-verified
Date: 2026-05-26

Depends on:
- S3-R184-C4-A

---

## Purpose

Execute the bounded RubyGems alpha prerelease for `igniter_lang 0.1.0.alpha.1`
after exact user approval, immediate collision re-checks, artifact rebuild, and
SHA match with accepted R183 smoke evidence.

This card does not edit version files, gemspec, README, RELEASE_NOTES, compiler
code, or runtime code. It does not authorize stable, production, demo,
all-grammar, Spark, runtime, branch/conditional, or profile-finalization claims.

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-execution-final-authorization-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-boundary-and-approval-plan-v0.md`
- `igniter-lang/docs/tracks/compiler-release-target-collision-and-git-state-preflight-v0.md`
- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`

---

## Authorization Basis

- C4-A (S3-R184-C4-A): `authorized-next-execution-card`
- User approval: provided — "I approve — proceed" (equivalent to required C2-P1 wording)
- Accepted R183 smoke run: `S3R183C2I_20260526T143139Z`
- Accepted SHA256: `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6`

---

## Environment (NB-2)

```text
ruby_version:  ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin25]
gem_version:   4.0.10
execution_date: 2026-05-26T17:39:20Z
```

---

## Preflight Matrix

| Gate | Check | Result |
| --- | --- | --- |
| PF-1 | `IgniterLang::VERSION == "0.1.0.alpha.1"` | PASS |
| PF-2 | Gemspec name `igniter_lang` | PASS |
| PF-3 | Gemspec includes `README.md` and `RELEASE_NOTES.md` | PASS |
| PF-4 | Scoped git status (release files) — clean | PASS |
| PF-5 | Full git status — no release-relevant changes | PASS |
| PF-6 | Local tag `igniter-lang-v0.1.0.alpha.1` — not found | PASS |
| PF-7 | Remote tag `igniter-lang-v0.1.0.alpha.1` — not found | PASS |
| PF-8 | RubyGems exact version collision — no listing | PASS |

All 8 preflight gates: **PASS**. No abort triggered.

---

## Artifact Rebuild

```text
build_dir:    /private/tmp/igniter_lang_release_0_1_0_alpha_1/
artifact:     igniter_lang-0.1.0.alpha.1.gem
gem_build_cwd: igniter-lang/  (required for gemspec Dir.chdir(__dir__) validation)
```

Build command (from `igniter-lang/` directory):

```bash
gem build igniter_lang.gemspec --output /private/tmp/igniter_lang_release_0_1_0_alpha_1/igniter_lang-0.1.0.alpha.1.gem
```

Result: `Successfully built RubyGem igniter_lang 0.1.0.alpha.1`

---

## SHA256 Gate

```text
rebuilt_sha256:  sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
accepted_sha256: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
match:           true
```

SHA gate: **PASS**. Proceed authorized.

---

## User Approval

Approval obtained before any irreversible command (local tag, gem push, tag push).

Approval equivalent: "I approve — proceed"

Interpreted as equivalent to the C2-P1 required approval text covering:
rebuild, SHA match requirement, annotated tag creation, `gem push`, RubyGems
MFA/2FA as human owner, post-publish verification, and exact tag push only.

---

## Execution Sequence

| Step | Action | Result |
| --- | --- | --- |
| E-1 | Create local annotated tag `igniter-lang-v0.1.0.alpha.1` | OK |
| E-2 | `gem push /private/tmp/.../igniter_lang-0.1.0.alpha.1.gem` (human completed MFA/2FA) | OK |
| E-3 | Verify RubyGems listing `igniter_lang (0.1.0.alpha.1)` | PASS |
| E-4 | Isolated install from RubyGems | PASS |
| E-5 | `require "igniter_lang"` → `0.1.0.alpha.1` (isolated GEM_HOME) | PASS |
| E-6 | `igc` executable present | PASS |
| E-7 | Optional post-publish CLI smoke (`add_baseline.ig`) | PASS |
| E-8 | `git push origin refs/tags/igniter-lang-v0.1.0.alpha.1` | OK |

---

## Tag Annotation

```text
igniter-lang 0.1.0.alpha.1 alpha prerelease

Evidence:
- R183 combined post-prep smoke PASS
- run: S3R183C2I_20260526T143139Z
- artifact_sha256: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6

Scope:
- alpha prerelease compiler package
- installed executable: igc
- branch/conditional if_expr excluded
- profile finalization/discovery/defaulting excluded
- not stable, not production-ready, not public demo-ready
```

---

## Post-Publish Verification Detail

### RubyGems Listing (E-3)

```text
command: gem list --remote --all --exact igniter_lang --pre
result:  igniter_lang (0.1.0.alpha.1)
status:  PASS
```

### Isolated Install (E-4)

```text
command: gem install igniter_lang -v 0.1.0.alpha.1 --no-document
         --install-dir /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home
         --bindir /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/bin
result:  Successfully installed igniter_lang-0.1.0.alpha.1 / 1 gem installed
status:  PASS
```

### Require Verification (E-5)

```text
GEM_HOME: /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home (isolated)
GEM_PATH: /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home (isolated)
output:   load OK 0.1.0.alpha.1
status:   PASS
```

### igc Executable (E-6)

```text
path:   /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/bin/igc
check:  test -x
result: OK
status: PASS
```

### Optional CLI Smoke (E-7)

```text
source:  add_baseline.ig (absolute path, NB-1 compliant)
out:     /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/add_baseline.igapp
status:  ok
stages:  parse=ok, classify=ok, typecheck=ok, emit=ok, assemble=ok
exit:    0
status:  PASS
```

### Tag Push (E-8)

```text
command: git push origin refs/tags/igniter-lang-v0.1.0.alpha.1
result:  [new tag] igniter-lang-v0.1.0.alpha.1 -> igniter-lang-v0.1.0.alpha.1
status:  OK
```

---

## Non-Blocking Note Disposition

| Note | Handling |
| --- | --- |
| NB-1: CLI smoke must use repo root cwd or absolute corpus path | Complied — absolute source path used |
| NB-2: Record Ruby and gem versions beside rebuilt SHA | Recorded in Environment section above |
| NB-3: Pre-publish packaged docs say "not yet published"; post-publish docs/status sync required | Accepted for this alpha artifact; sync route open per C4-A |

---

## Pending Follow-Up (NB-3)

A narrow post-publish docs/status sync is required to replace "not yet published"
wording in `README.md` and `RELEASE_NOTES.md` with the exact allowed alpha
availability wording. That follow-up is docs/status only and does not alter the
already-published gem artifact.

Allowed post-verification availability wording:

```text
igniter_lang 0.1.0.alpha.1 is available on RubyGems as an alpha prerelease
compiler package. It provides the installed igc CLI for bounded contract
compilation and the accepted --compiler-profile-source PATH.json transport.
```

Must remain attached:

```text
not stable
not production-ready
not public demo-ready
not all grammar support
branch/conditional if_expr excluded
profile finalization/discovery/defaulting closed
Spark out of scope
runtime/Ledger/TBackend/BiHistory not claimed
```

---

## Non-Claims

All non-claims maintained throughout execution:

```text
no_version_file_edited:              true
no_gemspec_edited:                   true
no_readme_edited:                    true
no_release_notes_edited:             true
no_compiler_code_edited:             true
no_runtime_code_edited:              true
no_git_push_tags:                    true  (only exact tag ref pushed)
no_force_push:                       true
no_tag_deletion:                     true
no_gem_yank:                         true
no_signing:                          true
no_deployment:                       true
no_production_readiness_claim:       true
no_stable_release_claim:             true
no_public_demo_readiness_claim:      true
no_all_grammar_claim:                true
no_branch_conditional_claim:         true
no_profile_finalization_claim:       true
no_profile_discovery_claim:          true
no_profile_defaulting_claim:         true
no_spark_claim:                      true
no_runtime_claim:                    true
no_credentials_in_transcript:        true
```

---

## Compact Receipt

```text
card:                     S3-R185-C1-I
track:                    compiler-release-execution-igniter-lang-0-1-0-alpha-1-v0
status:                   done / published-and-verified
execution_date:           2026-05-26T17:39:20Z
ruby_version:             ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin25]
gem_version:              4.0.10
gem_name:                 igniter_lang
version:                  0.1.0.alpha.1
tag:                      igniter-lang-v0.1.0.alpha.1
rebuilt_sha256:           sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
sha_match:                true
preflight_gates:          8/8 PASS
gem_push:                 OK (human MFA completed)
rubygems_listing:         igniter_lang (0.1.0.alpha.1) — PASS
isolated_install:         PASS
require_version_check:    PASS (load OK 0.1.0.alpha.1)
igc_executable:           PASS
cli_smoke:                PASS (add_baseline.ig, status=ok, exit=0)
tag_push:                 OK (refs/tags/igniter-lang-v0.1.0.alpha.1)
rubygems_url:             https://rubygems.org/gems/igniter_lang
no_git_push_tags:         true
no_force_push:            true
no_gem_yank:              true
no_credentials_in_docs:   true
follow_up_required:       NB-3 post-publish docs/status sync (README + RELEASE_NOTES)
```
