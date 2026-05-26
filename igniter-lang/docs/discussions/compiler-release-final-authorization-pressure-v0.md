# Compiler Release Final Authorization Pressure v0

Card: S3-R184-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: compiler-release-final-authorization-pressure-v0

Depends on:
- S3-R184-C1-P1
- S3-R184-C2-P1

---

## Question

Are the release execution authorization planning packets (C1-P1 and C2-P1) safe,
complete, and explicit enough to allow a later C4-A authorization card to open a
bounded `igniter_lang 0.1.0.alpha.1` release execution card — with no blocker
in the target/collision/approval/credential/command/abort/verification chain, and
with all closed surfaces preserved?

---

## Context

Inputs independently read:

- `igniter-lang/docs/tracks/compiler-release-target-collision-and-git-state-preflight-v0.md` (C1-P1)
- `igniter-lang/docs/tracks/compiler-release-execution-boundary-and-approval-plan-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-acceptance-decision-v0.md` (C4-A basis)
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`

Independent environment check: current ruby `3.2.2 [arm64-darwin25]`, gem `4.0.10` —
matches R183 smoke environment exactly. Optional post-publish corpus file
`igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig`
confirmed present.

---

## Evidence Chain

Accepted smoke evidence carried into this authorization package:

```text
run id:       S3R183C2I_20260526T143139Z
status:       PASS
version:      0.1.0.alpha.1
artifact SHA: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
package/install smoke: PASS (5/5 positive, 3/3 refusal)
profile-source smoke:  PASS (success + preflight refusal + semantic refusal)
acceptance decision:   S3-R183-C4-A (accepted, release-execution review opened)
```

---

## Checks

### 1. Release target consistency

C1-P1 and C2-P1 agree on all target fields:

| Field | C1-P1 | C2-P1 |
| --- | --- | --- |
| gem name | `igniter_lang` | `igniter_lang` |
| version | `0.1.0.alpha.1` | `0.1.0.alpha.1` |
| expected tag | `igniter-lang-v0.1.0.alpha.1` | `igniter-lang-v0.1.0.alpha.1` |
| accepted SHA256 | `sha256:749ee789...` | `sha256:749ee789...` |
| accepted smoke run | `S3R183C2I_20260526T143139Z` | `S3R183C2I_20260526T143139Z` |

C2-P1 `release target` field uses the descriptor
`public_rubygems_alpha_prerelease_for_igniter_lang` — a label only, not a
code string. Consistent with Path B (new version + fresh smoke) decided at R180.

Result: **PASS**

### 2. Local tag collision check (C1-P1)

`git tag --list 'igniter-lang-v0.1.0.alpha.1'` → no output (not found).

No local tag collision. Check is directional only; execution card must recheck
immediately before `git tag` per C2-P1 preflight commands.

Result: **PASS**

### 3. Remote tag collision check (C1-P1)

`git ls-remote --tags origin 'igniter-lang-v0.1.0.alpha.1'` → no output (not found).

No remote tag collision. Same note: execution card must recheck before tag push.

Result: **PASS**

### 4. RubyGems version collision check (C1-P1)

`gem list -r -e igniter_lang` and `gem list --remote --all --exact igniter_lang`
→ no listing returned.

Consistent with README "Not yet published" and RELEASE_NOTES "RubyGems
availability: Not yet — publish not authorized." The package is not currently on
RubyGems. Execution card must recheck with `gem list --remote --all --exact igniter_lang`
immediately before `gem push`.

Result: **PASS**

### 5. Git state for relevant release files (C1-P1)

Scoped git status check on:
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`

Result: no uncommitted relevant release-file changes.

C1-P1 correctly notes this is a scoped preflight, not a full worktree status.
C2-P1 requires execution card to run `git status --short` (full worktree) before
any release command, in addition to the scoped check.

Result: **PASS**

### 6. Public docs wording — pre-publish state (C1-P1)

C1-P1 independently verified the current "not yet published" wording:

```text
README.md:        "Not yet published"
RELEASE_NOTES.md: "0.1.0.alpha.1 (alpha prerelease candidate — not yet published)"
                  "RubyGems availability: Not yet — publish not authorized"
```

These are correct for the pre-execution state. C1-P1 correctly flags that if
C4-A authorizes publish without a docs update, the packaged artifact will contain
pre-publish wording. C2-P1 also notes this and defers the decision to C4-A. This
is a C4-A decision item (see NB-3), not a blocker.

Result: **PASS**

### 7. HOLD-if-unknown collision policy (C1-P1)

C1-P1 provides explicit HOLD-if-unknown fields:

```text
remote_tag_collision_unknown  → HOLD
rubygems_version_collision_unknown → HOLD
```

These apply if a future execution card cannot reach remote git or RubyGems. The
policy is correctly specified: unknown means HOLD, not proceed.

Result: **PASS**

### 8. Rebuild policy and SHA256 gate (C2-P1)

R183 temp artifacts were cleaned up (cleanup: complete). C2-P1 correctly requires
rebuilding in the execution card — the R183 artifact cannot be reused.

Hard gate:

```text
rebuilt SHA256 must match sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
abort before tag push or gem push if mismatch
```

SHA verification command in the candidate execution commands uses
`Digest::SHA256.file(path).hexdigest` — the same method used by the R183 smoke
that captured the accepted SHA256. Method consistency ensures apples-to-apples
comparison.

Independent environment check: current machine runs `ruby 3.2.2 [arm64-darwin25]`
and `gem 4.0.10`, identical to the R183 smoke environment. A rebuild on the same
machine/environment has a high probability of producing an identical artifact.

Result: **PASS**

### 9. Required user approval wording (C2-P1)

Required wording names:

```text
- bounded release execution for igniter_lang 0.1.0.alpha.1 (specific version)
- rebuilding the gem (rebuild policy)
- rebuilt SHA256 must match sha256:749ee789... (SHA gate)
- creating annotated tag igniter-lang-v0.1.0.alpha.1 (exact tag)
- gem push (publish command)
- completing RubyGems MFA/2FA as human owner (credential boundary)
- post-publish verification (verification requirement)
- pushing only exact tag after publish verification (tag push order)
- RubyGems publish is public and not practically reversible (informed consent)
- non-authorization: production, stable, demo, all-grammar, if_expr,
  profile finalization/discovery/defaulting, Spark, runtime, signing, deployment
```

This is specific, complete, and testable. The execution card can mechanically
confirm that the user's approval text covers all required elements.

C2-P1 correctly states: partial approval (only preflight or rebuild) is not
enough for publish.

Result: **PASS**

### 10. Partial approval rejection (C2-P1)

> "Partial approval is not enough for publish. If the user approves only preflight
> or rebuild, the execution card must stop before `git tag`, `gem push`, and
> `git push`."

The boundary between "approved" and "not approved" is explicit. An execution card
that gets partial approval has a clear STOP instruction.

Result: **PASS**

### 11. Credential and 2FA handling (C2-P1)

Requirements:

```text
- do not ask user to paste credentials, API keys, OTP seeds, or recovery codes
  into chat, docs, or any surface
- do not write credentials into repo files, temp summaries, logs, shell history,
  or command transcripts
- human RubyGems owner completes MFA/2FA interactively
- abort before treating publish as attempted if MFA/2FA cannot be completed
- abort on authentication, authorization, ownership, MFA, or network failure
- do not retry publish repeatedly without fresh user confirmation
```

These requirements carry R180-C2-P1 credential gate language forward correctly.
No credential value appears in the plan text. No session or token is mentioned
beyond describing that the human owner handles it.

Result: **PASS**

### 12. Tag-then-publish-then-tag-push ordering (C2-P1)

Recommended order:

```
1. Re-run collision checks
2. Rebuild artifact
3. Verify SHA256 matches accepted R183 SHA256
4. Create local annotated tag
5. Publish gem
6. Verify RubyGems availability and isolated install
7. Push only the exact tag
```

Analysis:
- Local tag is created before publish (marks the exact commit at the time of release).
- Remote tag push is held until after publish verification (prevents pushing a tag
  that corresponds to an unverifiable published gem).
- If RubyGems listing or isolated install fails after `gem push`, the plan aborts
  tag push and routes to incident review — correct.
- C2-P1 notes C4-A may reorder to tag after publish if preferred. Either ordering
  is safe if the isolation (no remote tag push before verification) is maintained.

Result: **PASS**

### 13. Exact tag push — no `git push --tags` (C2-P1)

Allowed tag push: `git push origin refs/tags/igniter-lang-v0.1.0.alpha.1`

`git push --tags` is explicitly forbidden. This prevents accidentally pushing any
other local tags that may exist. The `refs/tags/` prefix form is the safest
explicit push syntax.

Result: **PASS**

### 14. Forbidden commands list (C2-P1)

Forbidden list includes:

```text
gem push any gem other than igniter_lang-0.1.0.alpha.1.gem
gem yank
git push --tags
git push --force
git tag -d igniter-lang-v0.1.0.alpha.1
git push origin :refs/tags/igniter-lang-v0.1.0.alpha.1
rake release
version file edits
gemspec edits
README or RELEASE_NOTES edits
signing commands
deployment commands
production runtime commands
```

Also includes: publishing from dirty state, publishing if any collision exists,
broad tag push via `--tags`, forbidden public wording.

This is comprehensive. `rake release` is correctly forbidden (it would run a
superset of the intended commands, including a broad tag push). `gem yank` is
correctly forbidden (yank requires separate authorization).

Result: **PASS**

### 15. Abort criteria — pre-publish (C2-P1)

Pre-`gem push` abort triggers (13 conditions):

```text
- missing or narrow user approval
- dirty relevant release files
- full worktree status reveals unauth ambiguity
- IgniterLang::VERSION ≠ 0.1.0.alpha.1
- gemspec name ≠ igniter_lang
- gemspec missing README.md or RELEASE_NOTES.md
- local tag exists
- remote tag exists
- RubyGems already lists 0.1.0.alpha.1
- gem build fails
- rebuilt SHA256 differs from accepted R183 SHA256
- local annotated tag creation fails
- RubyGems credentials/ownership/MFA unavailable
- network unavailable for collision checks
- any command targets different version
```

All relevant pre-publish failure modes are covered.

Result: **PASS**

### 16. Abort criteria — post-publish, pre-tag-push (C2-P1)

Post-`gem push` abort triggers (4 conditions):

```text
- RubyGems publish success but listing does not show 0.1.0.alpha.1
- isolated install from RubyGems fails
- installed require "igniter_lang" does not report 0.1.0.alpha.1
- installed igc absent or not executable
```

No auto-yank. Route to bounded incident/yank authorization review. Tag push
is held until all four post-publish verifications pass.

Result: **PASS**

### 17. Post-publish verification commands (C2-P1)

Core verification (4 steps — required):

```bash
gem list --remote --all --exact igniter_lang             # listing check
gem install igniter_lang -v 0.1.0.alpha.1 ...           # isolated install from RubyGems
ruby -e '... IgniterLang::VERSION == "0.1.0.alpha.1"'   # require + version check
test -x .../bin/igc                                      # igc executable check
```

Optional CLI smoke (1 step — optional):

```bash
/private/tmp/.../bin/igc compile igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig --out .../add_baseline.igapp
```

The optional corpus file path (`igniter-lang/experiments/...`) is relative and
requires the execution card to run from the repo root or use an absolute path
(see NB-1). The file itself exists on the current machine.

The required 4-step verification is sufficient to confirm the gem is publicly
available, installable, and functional. Optional CLI smoke adds further confidence.

Result: **PASS**

### 18. Public wording after publish — claim safety (C2-P1)

Allowed wording after publish and verification:

```text
igniter_lang 0.1.0.alpha.1 is available on RubyGems as an alpha prerelease
compiler package. It provides the installed igc CLI for bounded contract
compilation and the accepted --compiler-profile-source PATH.json transport.
```

Required attached non-claims (persistent):

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

The allowed wording is factual, bounded, and does not overclaim. The attached
non-claims are complete and match the full exclusion list carried since R170.

Branch/conditional `if_expr` remains excluded. Profile finalization/discovery/
defaulting remains closed. Spark remains out of scope.

Result: **PASS**

---

## Verdict

```text
proceed with non-blocking notes — 18/18 checks PASS
blockers: none
non-blocking notes: 3
```

---

## Non-Blocking Notes

**NB-1: Optional post-publish CLI smoke uses a relative source path**

The optional post-publish CLI smoke command:

```bash
/private/tmp/.../bin/igc compile igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig --out .../add_baseline.igapp
```

The source path `igniter-lang/experiments/...` is relative. The command will
work if the execution card runs from the repo root (`/Users/alex/dev/projects/igniter`),
which is the natural working directory for these commands. The corpus file exists
at the expected path.

The execution card should either:
- document `cwd: /Users/alex/dev/projects/igniter` explicitly, or
- use an absolute source path.

No action required before C4-A authorization. Execution card should clarify.

**NB-2: SHA256 determinism — environment confirmed, record in execution card**

The rebuilt artifact SHA256 must match
`sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6`.

Gem builds can be environment-sensitive. The current machine environment has been
independently confirmed to match R183 exactly (`ruby 3.2.2 [arm64-darwin25]`,
`gem 4.0.10`). A rebuild on the same machine/environment should produce the same
artifact SHA.

The execution card should record its ruby and gem versions in the result packet
alongside the rebuilt artifact SHA, so any future dispute about artifact identity
can be resolved.

C2-P1 already handles the mismatch case correctly (abort before publish). No
action required before C4-A authorization.

**NB-3: Pre-publish packaged docs say "not yet published" — C4-A decision required**

The current `README.md` and `RELEASE_NOTES.md` contain pre-publish wording:

```text
README.md:        "Not yet published"
RELEASE_NOTES.md: "RubyGems availability: Not yet — publish not authorized"
```

These files are included in the packaged gem artifact. If the gem is published
without updating them, the packaged artifact will contain technically stale wording
(accurate at packaging time, inaccurate after publish).

For an alpha prerelease first publish, this may be acceptable — the wording is
conservative and does not mislead about the package's nature. C1-P1 and C2-P1
both flag this decision for C4-A.

C4-A must explicitly decide in the authorization card:
- Option A: Accept pre-publish wording in the packaged artifact (conservative;
  does not require a fresh smoke before publish).
- Option B: Authorize a narrow post-publish docs/status update after verification
  (updates wording; no fresh smoke required if only docs change; C4-A should
  explicitly decide whether the docs-only change requires a new gem build and
  whether the existing accepted SHA256 still applies or is superseded).

This is not a blocker. It is a required explicit decision, not an implicit one.

---

## [Agree]

- C1-P1 and C2-P1 are internally consistent and consistent with each other on
  target, tag, SHA256, and accepted run id.
- All three collision checks (local tag, remote tag, RubyGems listing) returned
  clear at C1-P1 read time, with execution-card re-check required per C2-P1.
- The SHA256 gate (abort if rebuilt ≠ accepted R183 SHA) is the correct approach
  for linking the accepted smoke evidence to the actual published artifact.
- The user approval wording in C2-P1 is specific, complete, and covers all
  irreversible steps and non-authorizations.
- Credential/2FA handling is correctly delegated to the human RubyGems owner
  with no mechanism for secrets to appear in any machine-readable or logged surface.
- The forbidden commands list covers all plausible accidental over-authorization
  paths: `rake release`, `git push --tags`, `gem yank`, force push, version
  edits, docs edits.
- Abort criteria cover every materially dangerous pre- and post-publish failure
  mode, with no auto-yank and explicit incident routing.
- Post-publish verification (listing, isolated install, require, igc executable)
  is sufficient to confirm the published gem is functional before tag push.
- Public wording after publish is claim-safe and correctly attached to a complete
  non-claims list.
- All closed surfaces (release execution in this card, branch/conditional `if_expr`,
  profile finalization/discovery/defaulting, Spark, runtime) are preserved in
  both plan cards.

## [Challenge]

None. The two-card package (C1-P1 collision preflight + C2-P1 execution boundary)
covers all required authorization prerequisites. No unsafe assumption or gap was
found in the collision/approval/credential/command/abort/verification chain.

## [Missing]

None for this card. The three non-blocking notes (NB-1/NB-2/NB-3) are
execution-card-level hygiene items or C4-A decision items, not missing content.

One item that belongs in the C4-A authorization card (not in the plan cards):
the explicit yes/no decision on each of the 13 C2-P1 checklist items. C2-P1
provides the checklist; C4-A must answer it.

## [Sharper Question]

Will C4-A answer the 13-item C2-P1 authorization checklist explicitly in the
authorization card, or will some items be left implicit? Items 13 (docs wording
decision) and 5 (SHA256 match requirement) are the two where implicit acceptance
carries the most risk of future ambiguity.

## [Route]

```text
proceed
```

C4-A may accept C1-P1 and C2-P1 as the release execution authorization basis and
open a bounded release execution card for `igniter_lang 0.1.0.alpha.1`.

The authorization card must:
- answer the C2-P1 13-item checklist explicitly;
- decide NB-3 (pre-publish docs wording) explicitly;
- not itself execute release commands.

The execution card must:
- re-run collision checks immediately before each irreversible command;
- obtain exact user approval before any of: `git tag`, `gem push`, `git push`;
- record rebuilt artifact SHA256 and ruby/gem versions in its result packet;
- clarify cwd or use absolute path for the optional post-publish CLI smoke.

---

## Compact Pressure Verdict

```text
card:               S3-R184-C3-X
track:              compiler-release-final-authorization-pressure-v0
verdict:            proceed with non-blocking notes
checks:             18/18 PASS
blockers:           none
non-blocking notes: 3

key findings:
  - Target consistent across C1-P1 + C2-P1: igniter_lang 0.1.0.alpha.1,
    tag igniter-lang-v0.1.0.alpha.1, SHA sha256:749ee7879...
  - All three collision checks clear (local tag / remote tag / RubyGems)
  - Git state for relevant release files: no uncommitted changes
  - SHA256 gate: hard abort before publish if rebuilt ≠ accepted R183 SHA;
    current ruby 3.2.2 + gem 4.0.10 matches R183 smoke environment exactly
  - User approval wording: specific, complete, names SHA/tag/commands/non-auths
  - Credential/2FA: human owner only; no secrets in any recorded surface
  - No git push --tags; exact refs/tags/ push only after publish verification
  - Forbidden commands comprehensive: rake release, gem yank, force push, docs edits
  - Abort criteria: 13 pre-publish conditions + 4 post-publish conditions; no auto-yank
  - Post-publish verification: RubyGems listing + isolated install + require + igc
  - Public wording after publish: alpha prerelease availability only; non-claims attached
  - branch/conditional if_expr excluded; profile finalization/discovery/defaulting closed;
    Spark out of scope — all preserved in both cards

NB-1: Optional post-publish CLI smoke uses relative path — execution card should
       clarify cwd as repo root or use absolute path (corpus file exists)
NB-2: SHA256 determinism — environment confirmed (same ruby/gem as R183);
       execution card should record ruby/gem versions in result packet
NB-3: Packaged docs still say "not yet published" — C4-A must explicitly decide
       Option A (accept pre-publish wording) or Option B (narrow post-publish
       docs update); this is a required decision, not a blocker

next_route: C4-A release execution authorization card, answering C2-P1
            13-item checklist explicitly and deciding NB-3 before dispatch
```
