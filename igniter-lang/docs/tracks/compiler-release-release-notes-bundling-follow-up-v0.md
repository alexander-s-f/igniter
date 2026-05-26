# Compiler Release Release Notes Bundling Follow-Up v0

Card: S3-R182-C2-I
Agent: [Package Agent / Implementation Agent]
Role: package-agent
Track: compiler-release-release-notes-bundling-follow-up-v0
Route: UPDATE
Status: done
Date: 2026-05-26

Depends on:
- S3-R182-C1-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md` (via C1-A reference)
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`

---

## Authorized Write Scope

Files edited (exactly matching C1-A authorized set):

```text
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-v0.md  (this file)
```

`RELEASE_NOTES.md` was **not** edited (not authorized).
No other files were edited.

---

## Packaging Change Summary

### `igniter_lang.gemspec` — `RELEASE_NOTES.md` added to packaged files

Before:

```ruby
Dir["lib/**/*.rb", "bin/igc", "README.md"].select { |path| File.file?(path) }
```

After:

```ruby
Dir["lib/**/*.rb", "bin/igc", "README.md", "RELEASE_NOTES.md"].select { |path| File.file?(path) }
```

Rationale (from C1-A):

- `README.md` is packaged and links to `RELEASE_NOTES.md`.
- A packaged README must not point at a missing packaged file.
- `RELEASE_NOTES.md` is the package-local non-claims and exclusions record for `0.1.0.alpha.1`.

No other gemspec fields were changed. Version, summary, description, homepage,
source_code_uri, rubygems_mfa_required, executables, require_paths — all
preserved from R181-C2-I.

### `README.md` — narrow version qualifier added

Before:

```text
Accepted local evidence (repo-local; release execution and public release/demo claims remain closed):

- Repo-local compiler RC evidence: PASS
- Local package install smoke: PASS
- Bounded installed profile-source smoke: PASS
```

After:

```text
Accepted local evidence (for `0.1.0.pre.stage2`; repo-local; fresh smoke required
for `0.1.0.alpha.1`; release execution and public release/demo claims remain closed):

- Repo-local compiler RC evidence: PASS
- Local package install smoke: PASS
- Bounded installed profile-source smoke: PASS
```

Change: added `for \`0.1.0.pre.stage2\`; ... fresh smoke required for \`0.1.0.alpha.1\`` to the
parenthetical. Meaning: the prior evidence applies to the pre-stage2 version; fresh
smoke is required for the current alpha candidate. No other README wording changed.

---

## Forbidden Phrase Scan

Scan executed on changed files only (`igniter_lang.gemspec`, `README.md`).

```text
Phrase families scanned (per C1-A required set):
  production-ready | production ready | stable release | public release ready
  release ready | demo ready | available on RubyGems | RubyGems available
  published package | install from RubyGems | supports all grammar
  supports branch | supports conditional | supports if_expr | profile discovery
  profile defaulting | profile finalization | Spark integrated | Spark ready
  Ruby Framework compatible
```

Hits found:

| File | Hit | Disposition |
| --- | --- | --- |
| `igniter_lang.gemspec:9` | "Not production-ready. Not stable. …profile discovery/defaulting/finalization are excluded" | Negation — required alpha/bounded stance from R181-C2-I; unchanged in this card |

Result:

```text
SCAN CLEAN: no forbidden phrase appears as an active public/project claim.
Single hit is unchanged negation wording carried from R181-C2-I.
```

---

## Non-Claims Preservation Checklist

| Surface | Status |
| --- | --- |
| Stable release | Not claimed — gemspec negation; unchanged |
| Production-ready | Not claimed — gemspec negation; unchanged |
| Public demo-ready | Not claimed — not present as active claim |
| All grammar support | Not claimed |
| Branch/conditional `if_expr` | Excluded — gemspec negation; unchanged |
| Profile finalization / discovery / defaulting | Closed — gemspec negation; unchanged |
| Spark integration | Out of scope — not mentioned in changed files |
| Ruby Framework compatibility | Not claimed |
| RubyGems availability | Not claimed — README "Not yet published"; unchanged |
| Release execution | Closed — README Package Status; unchanged |
| Tag/push/sign/deploy | Closed — README Package Status; unchanged |
| Prior evidence version qualifier | Added — clearly labels evidence as `0.1.0.pre.stage2` with fresh smoke required for `0.1.0.alpha.1` |

---

## Whether Post-Prep Smoke May Be Requested Next

Per C1-A:

```text
If this follow-up is accepted, the next route may open:
  combined post-prep package/install + profile-source smoke authorization review

Target:
  package: igniter_lang
  version: 0.1.0.alpha.1

Smoke must verify the final package artifact includes both:
  README.md
  RELEASE_NOTES.md
```

Post-prep smoke does **not** run in this card. Once C2-I is accepted, the next
authorized route is a combined smoke authorization review for:

- Post-prep package/install smoke for `igniter_lang 0.1.0.alpha.1`
- Post-prep profile-source installed smoke for `igniter_lang 0.1.0.alpha.1`

Both smokes must confirm the new gem artifact includes `README.md` and
`RELEASE_NOTES.md` in the packaged file list, and must capture a fresh artifact
SHA256 for the `0.1.0.alpha.1` gem.

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
Spark integration
Ruby Framework compatibility claims
compiler/runtime behavior changes
```

---

## Compact Receipt

```text
card:                           S3-R182-C2-I
track:                          compiler-release-release-notes-bundling-follow-up-v0
status:                         done
authorized_by:                  S3-R182-C1-A
files_changed:                  2 + this track doc = 3
gemspec_packaged_files_updated: yes (RELEASE_NOTES.md added)
readme_version_qualifier_added: yes (for 0.1.0.pre.stage2; fresh smoke required for 0.1.0.alpha.1)
release_notes_edited:           no (not authorized)
version_changed:                no
forbidden_phrase_scan:          CLEAN (single hit is unchanged negation from R181-C2-I)
non_claims_preserved:           yes
tag_created:                    no
push_performed:                 no
gem_published:                  no
post_prep_smoke_run:            no (not authorized in this card)
next_route_available:           combined post-prep package/install + profile-source smoke authorization review
```
