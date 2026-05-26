# Compiler Release Version Metadata And Notes Prep v0

Card: S3-R181-C2-I
Agent: [Package Agent / Implementation Agent]
Role: package-agent
Track: compiler-release-version-metadata-and-notes-prep-v0
Route: UPDATE
Status: done
Date: 2026-05-26

Depends on:
- S3-R181-C1-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-authorization-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-package-boundary-v0.md`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`

---

## Version / Tag Candidate Selected

```text
version:        0.1.0.alpha.1
tag_candidate:  igniter-lang-v0.1.0.alpha.1  (candidate only — no tag created)
previous_smoke_version:     0.1.0.pre.stage2
previous_smoke_gem_sha256:  sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
new_version:                0.1.0.alpha.1
fresh_smoke_required:       yes
```

The prior accepted gem SHA256 is invalidated by this version change. It no
longer applies as evidence for the new artifact.

---

## Authorized Write Scope

Files edited or created (exactly matching C1-A authorized set):

```text
igniter-lang/lib/igniter_lang/version.rb
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/RELEASE_NOTES.md
igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-v0.md  (this file)
```

No other files were edited.

---

## Changed Files — Before / After Summary

### `lib/igniter_lang/version.rb`

Before:

```ruby
VERSION = "0.1.0.pre.stage2"
```

After:

```ruby
VERSION = "0.1.0.alpha.1"
```

### `igniter_lang.gemspec`

Before:

```text
spec.summary     = "Contract-native language compiler for Igniter"
spec.description = "Igniter-Lang provides the packageable compiler facade and CLI
                    for the Igniter contract-native language research workspace."
```

After:

```text
spec.summary     = "Igniter-Lang alpha compiler package for the Igniter contract-native
                    language research workspace"
spec.description = "Igniter-Lang is an alpha prerelease compiler package providing the
                    igc CLI for bounded contract compilation in the Igniter
                    contract-native language research workspace. Not production-ready.
                    Not stable. Branch/conditional if_expr and profile
                    discovery/defaulting/finalization are excluded from this release."
```

All other gemspec fields preserved unchanged: homepage, source_code_uri,
rubygems_mfa_required, executables: ["igc"], require_paths, packaged files.

### `README.md`

Added a new `## Package Status` section before `## Current Navigation`:

```text
## Package Status

`igniter_lang 0.1.0.alpha.1` — alpha prerelease candidate. Not yet published.
See [RELEASE_NOTES.md](RELEASE_NOTES.md) for scope, accepted local evidence,
required fresh smoke, and exclusions.

RubyGems publish, release execution, and tag/push/sign/deploy remain closed
pending fresh package/install smoke and profile-source installed smoke for
this version.
```

No other README wording changed.

### `RELEASE_NOTES.md` (created)

Created at `igniter-lang/RELEASE_NOTES.md`.

Sections:
- Version / status header (`0.1.0.alpha.1`, alpha/prerelease, not yet published)
- What this is (alpha, not stable, not production, not demo)
- Accepted local evidence table (prior version, all PASS but invalidated)
- Required fresh smoke before publish authorization
- Bounded CLI command forms
- Explicit exclusions table (branch/if_expr, profile discovery/defaulting/finalization, Spark, all grammar, etc.)
- What remains closed (release execution, tag/push/sign/deploy, RubyGems publish)
- Non-claims block (all key fields)

---

## Forbidden Phrase Scan

Scan executed on all four changed public/package files.

```text
Files scanned:
  lib/igniter_lang/version.rb
  igniter_lang.gemspec
  README.md
  RELEASE_NOTES.md

Phrase families scanned (per C1-A required set):
  production-ready | production ready | stable release | public release ready
  release ready | demo ready | available on RubyGems | RubyGems available
  published package | install from RubyGems | supports all grammar
  supports branch | supports conditional | supports if_expr | profile discovery
  profile defaulting | profile finalization | Spark integrated | Spark ready
  Ruby Framework compatible
```

Hits and disposition:

| File | Hit | Disposition |
| --- | --- | --- |
| `igniter_lang.gemspec` | "Not production-ready. Not stable. ...profile discovery/defaulting/finalization are excluded" | Negation — required alpha/bounded stance wording |
| `RELEASE_NOTES.md` | "not a stable release, not a production release" | Negation — explicit non-claim |
| `RELEASE_NOTES.md` | Exclusions table rows: "Stable release \| Not this version", "Production-ready \| No claim" | Exclusion table |
| `RELEASE_NOTES.md` | Exclusions table rows: "Profile finalization \| Closed", "Profile discovery \| Closed", "Profile defaulting \| Closed" | Exclusion table |

Result:

```text
SCAN CLEAN: no forbidden phrase appears as an active public/project claim.
All hits are in negation or exclusion context.
```

---

## Non-Claims Preservation Checklist

| Surface | Status |
| --- | --- |
| Stable release | Not claimed — gemspec says "Not stable"; RELEASE_NOTES explicit |
| Production-ready | Not claimed — gemspec says "Not production-ready"; RELEASE_NOTES explicit |
| Public demo-ready | Not claimed — not present in any changed file as a positive claim |
| All grammar support | Not claimed — RELEASE_NOTES exclusions table |
| Branch/conditional `if_expr` | Excluded — gemspec description and RELEASE_NOTES exclusions table |
| Profile finalization | Closed — gemspec description and RELEASE_NOTES |
| Profile discovery | Closed — gemspec description and RELEASE_NOTES |
| Profile defaulting | Closed — gemspec description and RELEASE_NOTES |
| Named/generated profile lookup | Closed — RELEASE_NOTES exclusions table |
| Inline JSON profile source | Closed — RELEASE_NOTES exclusions table |
| Env/config/sidecar profile lookup | Closed — RELEASE_NOTES exclusions table |
| Spark integration | Out of scope — RELEASE_NOTES exclusions table |
| Ruby Framework compatibility | Not claimed — RELEASE_NOTES exclusions table |
| Runtime / Ledger / BiHistory | Not claimed — RELEASE_NOTES exclusions table |
| RubyGems availability | Not claimed — README "Not yet published"; RELEASE_NOTES |
| Release execution | Closed — README and RELEASE_NOTES explicit |
| Tag/push/sign/deploy | Closed — README and RELEASE_NOTES explicit |

---

## Required Post-Prep Smoke Matrix

Because version changed from `0.1.0.pre.stage2` to `0.1.0.alpha.1`, the prior
accepted gem artifact SHA256 is invalid for the new artifact. Fresh smoke is
required before publish authorization may be considered.

| Smoke run | Required | Notes |
| --- | --- | --- |
| Post-prep package/install smoke for `igniter_lang 0.1.0.alpha.1` | **YES** | Rerun PKG-0..PKG-5 checks with new gem |
| Post-prep profile-source installed smoke for `igniter_lang 0.1.0.alpha.1` | **YES** | Rerun PSS-0..PSS-8 checks with new gem |

Minimum checks per smoke run:

```text
gemspec syntax check (ruby -c igniter_lang.gemspec)
gem build → igniter_lang-0.1.0.alpha.1.gem
isolated gem install (no repo-relative -I, no repo RUBYLIB)
installed igc present at $BIN_DIR/igc
require "igniter_lang" without repo path leak
positive corpus compile via installed igc
negative corpus refusal via installed igc
valid finalized profile-source success (PSS-2)
malformed JSON profile-source preflight refusal (PSS-3)
semantic wrong-kind profile-source refusal (PSS-4)
no repo path leak observed
artifact SHA256 captured
```

No publish authorization may open until both post-prep smokes are accepted.

---

## Hard Gates Carried Forward

From S3-R180-C4-A:

```text
RubyGems version-collision gate:
  run read-only `gem list -r -e igniter_lang` before gem build/publish;
  if igniter_lang 0.1.0.alpha.1 exists remotely, HOLD immediately.

Tag collision gate:
  run local `git tag --list 'igniter-lang-v0.1.0.alpha.1'`
  and remote `git ls-remote --tags origin 'igniter-lang-v0.1.0.alpha.1'`;
  if tag exists locally or remotely, HOLD unless Portfolio explicitly accepts.

Approval sequencing gate:
  user approval confirmed before each release-affecting mutating command.

Credential/2FA gate:
  RubyGems credentials and OTP values must not be written into docs, logs,
  summaries, stdout excerpts, or track files.

Partial publish ambiguity gate:
  if gem push times out or returns ambiguous state, HOLD and verify remote;
  do not auto-yank or retry blindly.

No auto-yank gate:
  gem yank or corrective release requires separate Architect/user decision.
```

---

## Remaining Blockers Before Publish Authorization

| Blocker | Status |
| --- | --- |
| Fresh package/install smoke for `0.1.0.alpha.1` | Required — not yet run |
| Fresh profile-source installed smoke for `0.1.0.alpha.1` | Required — not yet run |
| RubyGems version-collision check for `0.1.0.alpha.1` | Required — not yet run |
| Tag collision check for `igniter-lang-v0.1.0.alpha.1` | Required — not yet run |
| Explicit release-execution authorization card | Required — not yet issued |
| Explicit user approval for tag/push/publish/sign/deploy | Required — not yet obtained |

---

## Closed Surfaces (unchanged)

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
Spark integration
Ruby Framework compatibility claims
compiler/runtime behavior changes
```

---

## Compact Receipt

```text
card:                           S3-R181-C2-I
track:                          compiler-release-version-metadata-and-notes-prep-v0
status:                         done
authorized_by:                  S3-R181-C1-A
version_selected:               0.1.0.alpha.1
tag_candidate:                  igniter-lang-v0.1.0.alpha.1 (candidate only)
previous_smoke_version:         0.1.0.pre.stage2
previous_smoke_gem_sha256:      sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
prior_sha256_valid_for_new:     no (invalidated by version change)
fresh_smoke_required:           yes
files_changed:                  5
version_rb_updated:             yes (0.1.0.pre.stage2 → 0.1.0.alpha.1)
gemspec_summary_updated:        yes (alpha/bounded stance)
gemspec_description_updated:    yes (alpha; not production-ready; not stable; exclusions listed)
readme_package_status_added:    yes (0.1.0.alpha.1 + RELEASE_NOTES link + closed-surfaces note)
release_notes_created:          yes (igniter-lang/RELEASE_NOTES.md)
forbidden_phrase_scan:          CLEAN (all hits in negation/exclusion context)
non_claims_preserved:           yes (all surfaces)
tag_created:                    no
push_performed:                 no
gem_published:                  no
release_execution:              closed
rubygems_publish:               closed
public_release_demo_claims:     closed
branch_if_expr:                 excluded
profile_finalization_etc:       closed
spark:                          out_of_scope
compiler_runtime_code_edited:   no
blockers_before_publish:        6 (see smoke matrix + hard gates above)
```
