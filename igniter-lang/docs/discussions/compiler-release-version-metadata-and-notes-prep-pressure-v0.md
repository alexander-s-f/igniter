# Compiler Release Version Metadata And Notes Prep Pressure v0

Card: S3-R181-C3-X
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: `external-pressure-reviewer`
Mode: discussion
Initiator: architect-supervisor
Track: `compiler-release-version-metadata-and-notes-prep-pressure-v0`
Route: UPDATE
Status: done
Date: 2026-05-26

Depends on:
- S3-R181-C2-I (`compiler-release-version-metadata-and-notes-prep-v0`)

---

## Question

Does the bounded version/package metadata/release notes prep (S3-R181-C2-I)
stay within the C1-A authorized write scope, select a valid and intentional
public prerelease version, produce claim-safe metadata and release notes, carry
the fresh-smoke requirement explicitly, preserve all closed surfaces, and leave
no forbidden phrases as active public claims?

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-v0.md`
  (S3-R181-C2-I — read)
- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-authorization-review-v0.md`
  (S3-R181-C1-A — read)
- `igniter-lang/lib/igniter_lang/version.rb`
  (independently read and verified)
- `igniter-lang/igniter_lang.gemspec`
  (independently read and verified)
- `igniter-lang/README.md`
  (independently read and verified)
- `igniter-lang/RELEASE_NOTES.md`
  (independently read and verified)

---

## Checks

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| CHK-1 | Changed files are exactly within C1-A authorized write scope | true | PASS — C2-I names 5 files matching C1-A authorized set exactly: `lib/igniter_lang/version.rb`, `igniter_lang.gemspec`, `README.md`, `RELEASE_NOTES.md`, track doc. All independently verified |
| CHK-2 | Public prerelease version is valid, intentional, and matches C1-A policy | true | PASS — `version.rb` contains `VERSION = "0.1.0.alpha.1"` (independently confirmed). C1-A explicitly authorizes `0.1.0.alpha.1` as the public prerelease candidate with rationale: avoids internal stage vocabulary, not completion-implying, keeps `0.1.0` family |
| CHK-3 | Tag candidate matches version policy and no tag was created | true | PASS — C2-I records `tag_candidate: igniter-lang-v0.1.0.alpha.1 (candidate only — no tag created)`. C1-A authorizes `igniter-lang-v0.1.0.alpha.1` for documentation only. No tag creation command executed; `tag_created: no` in compact receipt |
| CHK-4 | Prior smoke SHA256 correctly invalidated and fresh smoke requirement recorded | true | PASS — C2-I explicitly records `previous_smoke_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a`, `fresh_smoke_required: yes`, and `prior_sha256_valid_for_new: no`. RELEASE_NOTES.md line 35–36 states: "The prior accepted gem SHA256 (sha256:dba3f004…) is **invalidated** by this version change. It no longer applies." |
| CHK-5 | Package metadata (gemspec summary/description) does not overclaim | true | PASS — Summary: "Igniter-Lang alpha compiler package for the Igniter contract-native language research workspace" (no production/stable/demo claim). Description explicitly says: "Not production-ready. Not stable. Branch/conditional if_expr and profile discovery/defaulting/finalization are excluded from this release." Homepage, source_code_uri, `rubygems_mfa_required`, `executables: ["igc"]`, `require_paths`, and packaged files (lib/**/*.rb, bin/igc, README.md) all preserved unchanged |
| CHK-6 | Release notes do not overclaim; required sections present | true | PASS — RELEASE_NOTES.md contains: version/status header (alpha/not yet published), "What This Is" (not stable, not production, not demo), accepted evidence table with explicit prior-version attribution and SHA256 invalidation notice, fresh smoke requirement section with 12-step minimum checklist, bounded CLI section, exclusions table (17 rows), "What Remains Closed" section with 5-step gate, machine-readable non-claims block (13 fields) |
| CHK-7 | README changes are within C1-A authorized boundary and remain claim-safe | true | PASS — Only "Package Status" section added before "Current Navigation": states `0.1.0.alpha.1` is alpha/not yet published, links to RELEASE_NOTES.md, explicitly keeps RubyGems publish/release execution/tag-push-sign-deploy closed pending fresh smoke. All existing "Current Navigation" content from R179 preserved unchanged |
| CHK-8 | Independent forbidden-phrase scan confirms CLEAN | true | PASS — Independent `grep` across all four changed public/package files finds 10 hits. All are in negation or exclusion context: gemspec line 9 ("Not production-ready. Not stable. …profile discovery/defaulting/finalization are excluded" — negation); RELEASE_NOTES.md line 18 ("not a stable release, not a production release" — negation); RELEASE_NOTES.md lines 87–88, 92–94, 98–99 (exclusion table rows); RELEASE_NOTES.md line 125 (`not_production_ready: true` — machine-readable non-claims). No active public claim found |
| CHK-9 | Post-prep smoke matrix is explicit and correctly gates publish authorization | true | PASS — C2-I "Required Post-Prep Smoke Matrix" section: fresh package/install smoke (PKG-0..PKG-5 equivalent) = YES; fresh profile-source installed smoke (PSS-0..PSS-8 equivalent) = YES; 12 minimum checks enumerated for each run; "No publish authorization may open until both post-prep smokes are accepted." Matches C1-A required smoke matrix exactly |
| CHK-10 | Hard gates from R180-C4-A correctly carried forward with new version string | true | PASS — C2-I carries all 6 hard gates: RubyGems version-collision gate (updated to `0.1.0.alpha.1`), tag collision gate (updated to `igniter-lang-v0.1.0.alpha.1`), approval-sequencing gate, credential/2FA gate, partial-publish ambiguity gate, no-auto-yank gate |
| CHK-11 | Release execution, RubyGems publish, and version/tag/push/sign/deploy remain closed | true | PASS — README: "RubyGems publish, release execution, and tag/push/sign/deploy remain closed"; RELEASE_NOTES.md: "Release execution | Closed pending fresh smoke and explicit authorization", "Tag/push/sign/deploy | Closed"; C2-I receipt: `tag_created: no`, `push_performed: no`, `gem_published: no`, `release_execution: closed`, `rubygems_publish: closed` |
| CHK-12 | Branch/conditional `if_expr` remains excluded in package-facing surfaces | true | PASS — Gemspec description: "Branch/conditional if_expr…are excluded from this release." RELEASE_NOTES.md exclusions table: "Branch/conditional `if_expr` | **Excluded** from first RC scope." |
| CHK-13 | Profile finalization/discovery/defaulting remains closed | true | PASS — Gemspec description: "profile discovery/defaulting/finalization are excluded." RELEASE_NOTES.md exclusions table: "Profile finalization | Closed", "Profile discovery | Closed", "Profile defaulting | Closed" |
| CHK-14 | Spark remains out of scope; no Spark integration claim | true | PASS — RELEASE_NOTES.md exclusions table: "Spark integration | Out of scope." No Spark mention in README, gemspec, or version.rb |

**Verdict: proceed with non-blocking notes — 14/14 checks PASS, no blockers on C4-A acceptance**

---

## Non-Blocking Notes For C4-A

### NB-1 (decision required): RELEASE_NOTES.md is not bundled into the distributed gem

The gemspec `spec.files` glob is:

```ruby
Dir["lib/**/*.rb", "bin/igc", "README.md"].select { |f| File.file?(f) }
```

`RELEASE_NOTES.md` is not matched by this glob and will **not** be bundled into
the `igniter_lang-0.1.0.alpha.1.gem` artifact. The file exists in the repo
and is linked from README.md, but a gem consumer who installs the package will
not see it.

C1-A said "preserve packaged files unless release notes are intentionally added
to `spec.files`" — this deferred the decision to C2-I, which neither explicitly
added it nor explicitly recorded a no-bundle decision.

C4-A must choose:

**Option A** — bundle RELEASE_NOTES.md in the gem (add `"RELEASE_NOTES.md"` to
the spec.files glob). This requires a gemspec line change in the execution card,
but no fresh smoke is needed — the gem file list change is minor and the gemspec
is re-read at `gem build` time. The fresh smoke required by the version change
will cover it.

**Option B** — keep RELEASE_NOTES.md as a repo-only planning document. Record the
deliberate choice: gem consumers see README.md only; RELEASE_NOTES.md is
project-internal. No additional file change required.

Both options are valid. C4-A should state the choice explicitly so the execution
card knows whether to add the glob entry.

### NB-2 (minor informational): README "Accepted local evidence: PASS" lines lack version attribution

The README "Current Navigation" section (from R179) retains:

```text
Accepted local evidence (repo-local; release execution and public release/demo claims remain closed):
- Repo-local compiler RC evidence: PASS
- Local package install smoke: PASS
- Bounded installed profile-source smoke: PASS
```

These PASS results apply to `0.1.0.pre.stage2`, not to `0.1.0.alpha.1`. The
"Package Status" section above correctly states fresh smoke is required for the
new version, and RELEASE_NOTES.md explicitly invalidates the prior SHA256. There
is no active overclaim — the Package Status section guards the reader. However,
a reader who lands on the README mid-section could read the PASS lines without
the Package Status context.

No immediate correction is required. C4-A may optionally request that a future
docs card adds a version qualifier such as "(prior version: `0.1.0.pre.stage2`)"
to the PASS lines. This is cosmetic and does not block acceptance or any
subsequent smoke/execution card.

---

## [Agree]

- Version `0.1.0.alpha.1` is the correct public-facing prerelease label. It is
  unambiguously alpha/prerelease, avoids exporting internal `pre.stage2`
  vocabulary, and carries no completion implication. Gemspec description is
  actively conservative — it names the key exclusions directly in the package
  metadata visible to any `gem info` or RubyGems page reader.
- RELEASE_NOTES.md is the strongest non-claims record produced in this chain
  so far: 17-row exclusions table, machine-readable non-claims block, explicit
  SHA256 invalidation notice, 12-step fresh-smoke checklist, and a 5-step gate
  before any publish authorization can reopen. It can serve as the reference
  document for any future execution card's non-claims verification step.
- The version change trigger discipline is correct: C2-I explicitly records prior
  SHA256, states it is invalidated, and makes fresh smoke a hard gate. This is
  exactly the discipline required by C1-A and R180-C4-A.
- Hard gates from R180-C4-A (RubyGems collision, tag collision, approval
  sequencing, credential/2FA, partial-publish ambiguity, no-auto-yank) are all
  carried forward with the new version string substituted.

## [Challenge]

- No material challenge to the prep implementation.
- Minor observation: gemspec `spec.description` is 183 characters, which RubyGems
  truncates in some display contexts. The exclusions list ("Branch/conditional
  if_expr and profile discovery/defaulting/finalization are excluded") may not
  always be visible to gem consumers in truncated views. This is inherent to
  gemspec display constraints and not a blocker — RELEASE_NOTES.md and README.md
  carry the full exclusion record. No correction required.

## [Missing]

- The deliberate RELEASE_NOTES.md non-bundle decision (NB-1). This must be made
  explicit by C4-A before the execution card to avoid scope ambiguity.
- A version qualifier on the README PASS lines (NB-2, optional/cosmetic).

## [Sharper Question]

Does C4-A: (a) accept the R181 prep implementation; (b) decide whether
RELEASE_NOTES.md should be bundled into the gem artifact (Option A) or kept
repo-only (Option B); and (c) confirm that post-prep package/install smoke and
profile-source installed smoke are the only gates remaining before a
release-execution authorization card may open?

## [Route]

```text
proceed with non-blocking notes — accept C2-I bounded prep implementation;
open compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0 (C4-A) next;
carry NB-1 (RELEASE_NOTES.md bundle decision required) as a binding input
into C4-A; NB-2 is optional/cosmetic.
```

---

## Compact Pressure Verdict

```text
S3-R181-C3-X: proceed with non-blocking notes — 14/14 checks PASS, no blockers.

Write scope verified: exactly 5 files matching C1-A authorized set.

Version: VERSION = "0.1.0.alpha.1" confirmed in version.rb. Prior SHA256
(dba3f004…) explicitly invalidated; fresh package/install smoke + profile-source
smoke both required before publish authorization.

Gemspec: summary and description are actively conservative ("alpha prerelease",
"Not production-ready", "Not stable", key exclusions named in description).
All other gemspec fields preserved unchanged.

RELEASE_NOTES.md: created with alpha/not-yet-published header, 17-row exclusions
table, 12-step fresh-smoke checklist, 5-step gate before publish, 13-field
machine-readable non-claims block.

README: "Package Status" section added (alpha/not yet published, fresh smoke
required, closed surfaces stated); existing "Current Navigation" content
preserved unchanged.

Independent forbidden-phrase scan: CLEAN. 10 hits across 4 files, all in
negation or exclusion context.

Hard gates from R180-C4-A: all 6 carried forward with 0.1.0.alpha.1 version
substitution.

NB-1 (decision required): RELEASE_NOTES.md is not bundled in gemspec spec.files.
C4-A must choose Option A (bundle in gem) or Option B (repo-only) explicitly.
NB-2 (informational/cosmetic): README PASS lines lack version qualifier; no
overclaim; no action required for acceptance.

Release execution, RubyGems publish, version/tag/push/sign/deploy,
branch/conditional if_expr, profile finalization/discovery/defaulting,
and Spark remain closed.

Recommended next: compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0 (C4-A).
```
