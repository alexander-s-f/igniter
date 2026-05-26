# Compiler Release Execution Authorization Boundary Pressure v0

Card: S3-R180-C3-X
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: `external-pressure-reviewer`
Mode: discussion
Initiator: architect-supervisor
Track: `compiler-release-execution-authorization-pressure-v0`
Route: UPDATE
Status: done
Date: 2026-05-26

Depends on:
- S3-R180-C1-P1 (`compiler-release-target-versioning-and-package-boundary-v0`)
- S3-R180-C2-P1 (`compiler-release-execution-evidence-and-approval-boundary-v0`)

---

## Question

Do the R180 release-execution authorization planning packets (C1-P1 and C2-P1)
together provide a sound, unambiguous basis for Portfolio to decide whether a
release-execution card may open — with a bounded and explicit release target,
sound and consistent evidence chain, non-ambiguous version/tag/command boundary,
explicit user-approval and credential/2FA boundary, release notes/metadata prep
need addressed, all closed surfaces preserved, and no execution performed in
either planning card?

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-package-boundary-v0.md`
  (S3-R180-C1-P1)
- `igniter-lang/docs/tracks/compiler-release-execution-evidence-and-approval-boundary-v0.md`
  (S3-R180-C2-P1)
- `igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-polish-acceptance-decision-v0.md`
  (S3-R179-C4-A)
- `igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0.md`
  (S3-R177-C3-A)

---

## Checks

| # | Check | Expected | Result |
| --- | --- | --- | --- |
| CHK-1 | Release target is explicit and bounded — not stable, not production, not demo | true | PASS — C1-P1 names future target `public_rubygems_prerelease_candidate_for_igniter_lang` with explicit constraints: `stable_release: no`, `production_readiness_claim: no`, `public_demo_claim: no`, `all_grammar_claim: no`; C1-P1 primary recommendation is "authorize release prep first, not release execution" |
| CHK-2 | Evidence chain supports the proposed target and is internally consistent | true | PASS — C2-P1 evidence table covers the full chain: first-RC evidence (S3-R167-C1-A / S3-R168-C4-A), repo-local marker (S3-R171-C3-A, independent hash PASS), package/install smoke (S3-R173-C3-A, run `S3R173C1I_20260525T063543Z`), installed readiness marker (S3-R174-C4-A), profile-source smoke (S3-R176-C3-A, marker accepted S3-R177-C3-A, run `S3R176C1I_20260525T101425Z`), docs polish (S3-R179-C4-A). SHA256 values are correctly attributed to distinct artifacts: `sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b` for the harness summary (first-RC evidence); `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` for the built `igniter_lang 0.1.0.pre.stage2` gem (package smoke + profile-source smoke — same artifact, consistent) |
| CHK-3 | Version/tag/publish command boundary is not ambiguous — exact version, tag format, and publish command identified | true | PASS — C1-P1: current version `0.1.0.pre.stage2` from `lib/igniter_lang/version.rb`; candidate tag `igniter-lang-v0.1.0.pre.stage2`; publish command `gem push /private/tmp/<release-root>/igniter_lang-<VERSION>.gem`; version change invalidates accepted artifact SHA256 and requires fresh smoke (RB-3); placeholders `<release-root>` and `<VERSION>` correctly left for the execution card to pin |
| CHK-4 | Local and remote tag collision checks confirmed no existing tags | true | PASS — C1-P1 records: `git tag --list '*0.1.0*'` → no matching local tags; `git tag --list '*igniter*lang*'` → no matching local tags; `git ls-remote --tags origin '*0.1.0*'` → no matching remote tags; `git ls-remote --tags origin '*igniter*lang*'` → no matching remote tags. All four checks read-only; no tags created |
| CHK-5 | RubyGems remote version-collision check status is honestly stated | true | PASS — C1-P1 compact boundary packet records `rubygems_version_collision: not checked; required before publish` (RB-4); it is named in the 12-step preconditions list (step 5) as required-before-publish; C2-P1 "Allowed before execution authorization" lists read-only remote/tag existence checks |
| CHK-6 | User approval boundary is explicit for every release-affecting action | true | PASS — C2-P1 "Approval And Credential Boundary" section explicitly enumerates 9 individual approval gates: (1) exact package target, (2) exact version, (3) artifact build, (4) git tag creation + name, (5) push commits or tags, (6) publish to RubyGems, (7) signing/deployment, (8) post-publish verification, (9) post-publish public availability wording |
| CHK-7 | Credential/2FA boundary is explicit and no credential value may enter docs/logs | true | PASS — C2-P1: 2FA/OTP handled by user or local tooling; no token/password/OTP/API key/signing key may be written into docs, logs, summaries, stdout excerpts, or track files; credential prompt → record prompt occurred and whether user approved/provided locally (not the value); credential absence/failure/2FA failure = immediate HOLD/ABORT |
| CHK-8 | Release notes and package metadata prep need is not skipped | true | PASS — C1-P1 identifies RB-1 (`0.1.0.pre.stage2` reads as internal stage marker, blocks immediate publish) and RB-2 (no accepted release notes/package metadata prep, blocks immediate publish) as explicit blockers; dedicated "Release Notes / Metadata Prep Need" section recommends `compiler_release_version_metadata_and_notes_prep` card; C2-P1 frames metadata as an open question to be resolved before any execution card |
| CHK-9 | Public release/demo claims remain closed; 14-surface non-claims list must survive even if publish succeeds | true | PASS — C1-P1 compact boundary packet: `public_demo_claim: closed`, `production_claim: closed`; C2-P1 "Non-Claims That Must Survive Execution" section lists 14 forbidden claim surfaces: production readiness, public demo readiness, broad runtime authority, all grammar support, branch/conditional if_expr, profile finalization/discovery/defaulting, named/generated profile lookup, inline JSON profile input, env/config/sidecar profile lookup, public API/CLI widening, loader/report, CompatibilityReport, runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache, Spark integration, Ruby Framework compatibility, deployment/signing/production operations |
| CHK-10 | Branch/conditional `if_expr` exclusion remains visible in both packets and in abort criteria | true | PASS — C1-P1 risks table RB-8: "Must stay visible in release notes/non-claims"; C2-P1 abort criteria: "branch/conditional if_expr exclusion is not visible in release notes or release packet boundaries" = HOLD; C2-P1 non-claims survival list includes it |
| CHK-11 | Profile finalization/discovery/defaulting and Spark/Ruby Framework non-authority preserved | true | PASS — C1-P1: RB-9 (profile finalization closed, must not be implied), RB-10 (Spark must not be used as release authority); C2-P1 abort criteria: "profile finalization/discovery/defaulting appears as a claim" = HOLD; "Spark/Ruby Framework evidence is used as release authority" = HOLD; both surfaces in C2-P1 non-claims survival list |
| CHK-12 | No execution happened in C1-P1 or C2-P1 | true | PASS — C1-P1: "This card does not execute a release, build a release artifact, publish a gem, create or push tags, edit versions, edit package metadata, or make public release/demo claims"; candidate command matrix labeled "review only" with explicit "No candidate above is authorized by this card"; C2-P1: "This packet does not execute a release, publish gems, create tags, push, sign, deploy, edit versions, or authorize implementation" |

**Verdict: proceed with non-blocking notes — 12/12 checks PASS, no blockers on C4-A planning acceptance**

---

## Non-Blocking Notes For C4-A

### NB-1 (important): RubyGems version-collision check must be a hard abort gate in the execution card boundary, not a checklist item

C1-P1 correctly did not run `gem list -r -e igniter_lang` (this is a planning
card). However, the precondition list presents it as step 5 of 12. When C4-A
authorizes a future execution card, the version-collision check must be named
as a **blocking abort condition**: if `igniter_lang 0.1.0.pre.stage2` already
exists on RubyGems, the execution card must HOLD immediately — before `gem build`
or `gem push`.

Reason: RubyGems publish is effectively irreversible for a given version string.
A prior test publish, partial upload, or naming collision could cause silent
failure or version-data clobbering. The read-only check is cheap; the consequence
of skipping it is not.

Recommended language for the execution card boundary:

```text
Version-collision gate: run `gem list -r -e igniter_lang` before gem build;
if igniter_lang <VERSION> appears in remote output, HOLD immediately and
do not proceed to publish without an explicit Portfolio decision.
```

### NB-2 (important for the C4-A decision itself): Explicit version/tag stance required before any execution card opens

C1-P1 correctly identifies RB-1: `0.1.0.pre.stage2` may read as an internal
evidence staging marker to public RubyGems consumers. C4-A must choose one of
two paths:

**Path A — publish `0.1.0.pre.stage2` as-is:**
- No version.rb edit required.
- Accepted gem artifact SHA256 (`sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a`)
  remains valid.
- Execution card may proceed directly to prep-card decisions on release notes
  and metadata, then to `release-gate` / `gem push`.
- Tag would be `igniter-lang-v0.1.0.pre.stage2`.

**Path B — change version before publish (e.g. `0.1.0.alpha.1`, `0.1.0.pre.rc1`):**
- Requires version.rb edit.
- Accepted gem artifact SHA256 is invalidated (new gem, new SHA256).
- Fresh package/install smoke (`S3R173`-equivalent) and profile-source installed
  smoke (`S3R176`-equivalent) must both be rerun and accepted for the new artifact
  before any publish authorization.
- C4-A planning acceptance + a separate smoke-acceptance card must precede any
  publish.

C4-A must state the choice explicitly. An unanswered RB-1 is the most likely
source of scope drift between a planning card and a future execution card.

### NB-3 (informational): `rake release` listed in C2-P1 commands vs. "no package-local Rake route" in C1-P1

C1-P1 records "no package-local Rake route discovered" in the package artifact/
build route section. C2-P1 nonetheless lists `rake release` in the
commands-requiring-explicit-approval list. This is not a contradiction: C2-P1
is being correctly conservative by capturing the command family even when it is
not currently wired. If later confirmed absent, the execution card may note it
as not applicable. No correction required now.

---

## [Agree]

- C1-P1's recommendation to NOT authorize immediate execution and require a
  prep card first is the correct conservative path. Immediate `gem push` of
  `0.1.0.pre.stage2` without explicit version/notes/metadata decisions would
  produce an irreversible public artifact from a version string that reads as
  internal evidence staging. C4-A should follow this recommendation.
- C2-P1's credential/2FA boundary is the strongest in the release chain to date.
  The explicit prohibition against recording any credential value in docs, logs,
  summaries, or stdout excerpts is clear, correct, and should become the standard
  for all future execution cards in this project.
- Both packets accurately represent the accepted evidence chain. SHA256 values
  are correctly attributed to distinct artifacts (harness summary vs. built gem);
  the same gem SHA256 appearing in both package smoke and profile-source smoke
  is correct and expected because both runs built from the same `0.1.0.pre.stage2`
  version.
- C2-P1 abort criteria are comprehensive and layered: pre-build (worktree state,
  version mismatch), post-build pre-publish (artifact hash capture, isolated
  install smoke), and post-publish (no automatic rollback/yank, separate
  Architect decision required). The 13-condition abort matrix is sufficient for a
  first public prerelease gate.
- C2-P1's post-publish stance ("do not attempt destructive rollback/yank
  automatically; record exact remote mutation; open a separate Architect/user
  decision for yank/corrective release/tag correction/public notice") is correct
  and should be stated verbatim in the execution card boundary.

## [Challenge]

- No material challenge to the planning boundary.
- Minor wording observation only (not a blocker): C1-P1 preconditions list item
  10 says "Explicit user approval is obtained for any tag, push, publish, signing,
  or deployment step." The word "obtained" is temporally ambiguous — it should
  require approval **before** each mutating command runs, not as a general prior
  disposition. C4-A should specify the sequencing rule in the execution card
  boundary: user approval must be confirmed immediately before each release-
  affecting command, not retrospectively collected after the round completes.

## [Missing]

- Neither C1-P1 nor C2-P1 specifies what a **partial publish** recovery plan
  looks like: if `gem push` completes but the post-publish install check fails,
  or if `gem push` times out mid-transfer. C2-P1's "do not attempt destructive
  rollback/yank automatically" is the correct base stance, but the execution card
  boundary should add explicit HOLD wording for the partial-push ambiguous case
  (connection drop after ACK but before version confirmation, etc.) rather than
  inheriting it only implicitly from C2-P1's no-auto-yank rule.
- No `gem yank` authority or policy is stated for post-publish corrections.
  C4-A may optionally note that yank authority, if ever needed, requires a
  separate Architect/user decision. This is low-urgency for a planning card but
  should appear in the execution card boundary.

## [Sharper Question]

Does C4-A: (a) accept the R180 planning boundary as sound for a release-execution
authorization decision; (b) explicitly choose between Path A (publish
`0.1.0.pre.stage2` as-is) and Path B (prep a new version + fresh smoke); and
(c) name the RubyGems version-collision check as a hard abort gate rather than
a checklist item in the eventual execution card boundary?

## [Route]

```text
proceed with non-blocking notes — accept C1-P1 and C2-P1 as the R180
release-execution authorization planning bundle;
open compiler-release-execution-authorization-decision-v0 (C4-A) next;
carry NB-1 (RubyGems collision = hard abort gate) and NB-2 (version/tag
stance decision required) as binding inputs into C4-A.
```

---

## Compact Pressure Verdict

```text
S3-R180-C3-X: proceed with non-blocking notes — 12/12 checks PASS, no blockers.

C1-P1 bounds the release target as
public_rubygems_prerelease_candidate_for_igniter_lang (not stable/production/demo),
recommends NOT authorizing immediate execution, and names 12 explicit preconditions
+ 10 risk/blocker items before any execution card may open.

C2-P1 provides a complete, layered approval/credential boundary (9 explicit user-
approval gates; no credential values in docs/logs; credential failure = HOLD/ABORT),
a 13-condition abort matrix, command traceability requirements, and a 14-surface
non-claims survival list.

Evidence chain: correct, complete, internally consistent. Harness SHA256
(bc8d69f6…) and gem artifact SHA256 (dba3f004…) correctly attributed to distinct
artifacts. Package smoke and profile-source smoke share the same gem SHA256 — correct.

Tag collision checks: local + remote tag absence confirmed by read-only git
commands. RubyGems version-collision NOT checked in planning cards — correctly
deferred; must become a hard abort gate in the execution card boundary (NB-1).

NB-1 (important): RubyGems version-collision check must be a blocking abort gate
in the execution card boundary, not a checklist step.
NB-2 (important): C4-A must choose between Path A (accept 0.1.0.pre.stage2 as-is)
and Path B (prep new version + fresh smoke) before any execution card opens.
NB-3 (informational): rake release in C2-P1 commands list vs. "no Rake route
discovered" in C1-P1 — conservative coverage, no correction required.

No execution occurred in either planning card.
All closed surfaces preserved: release execution, public release/demo claims,
RubyGems publish, version/tag/push/sign/deploy, profile finalization/discovery/
defaulting, branch/conditional if_expr, Spark, runtime, and production.

Recommended next: compiler-release-execution-authorization-decision-v0 (C4-A).
```
