# Igniter Lang Repository Split Dry-Run File-Map Pressure v0

Card: `S3-R256-C3-X`  
Skill: IDD Agent Protocol  
Agent: External Pressure Reviewer  
Role: external-pressure-reviewer  
Track: `igniter-lang-repository-split-dry-run-file-map-pressure-v0`  
Route: UPDATE  
Status: done / conditional-accept  
Date: 2026-06-06

Depends on:
- `S3-R256-C1-D`
- `S3-R256-C2-P1`

## Pressure Verdict

CONDITIONAL ACCEPT with exact blockers.

The dry-run file-map proof is acceptable as split-map evidence. It correctly
keeps physical migration, history rewrite, target population, remote push,
package/CI/release changes, public claims, framework-to-language authority
transfer, lab canon, and archive repo creation closed.

It is not acceptable as migration-authorization evidence yet. C4-A should route
support-file / path-hygiene / link-rewrite prep next, not migration
authorization. The blockers are explicit and bounded: refresh the file-map,
make final buckets mutually exclusive, clean or quarantine path-heavy material,
settle support files, and decide target-repo baseline.

## Inputs Reviewed

- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-proof-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-current-target-facts-v0.md`
- `igniter-lang/docs/tracks/stage3-round255-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R256.md`

## Pressure Checks

| Check | Verdict | Notes |
| --- | --- | --- |
| Bucket completeness | CONDITIONAL PASS | The five buckets cover the split shape, but final migration buckets are not complete because generated/path-heavy material still needs exclude/quarantine/whitelist decisions. |
| Bucket non-overlap | CONDITIONAL PASS | Initial counts partition tracked files, but `language-root` still contains surfaces later described as exclude/quarantine candidates, especially `igniter-lang/out/**`. Final file-map must make those dispositions mutually exclusive. |
| `language-root` critical surfaces | PASS | Core language README, AGENTS, release notes, gemspec, bin, lib, source, fixtures, tests, roles, handoff, specs, proposals, cards, tracks, gates, and discussions are included as candidate language-root surfaces. |
| `ruby-framework` leakage control | PASS | Root docs, root framework code, packages, examples, specs, sigs, root Gemfile/Rakefile/gemspec, and framework support files remain framework-owned or cross-link-only. |
| `lab-frontier` evidence-only status | PASS | Lab remains nested/frontier and is not initial language split content; `target:igniter-lab` remains planning-only. |
| `archive-quarantine` usage | PASS with guard | Used for stale/mixed/generated/path-heavy evidence, not as an accepted migration bucket. Must remain non-public until sanitized or explicitly accepted. |
| Absolute path / `file://` hygiene | PASS for proof docs, BLOCKER for migration | R256 docs use repo/target labels rather than local absolute paths. Source scan still finds hundreds of path/file-link hits, so public migration is blocked. |
| Generated artifact drift | BLOCKER for migration | `out/**`, `.igapp`, JSON summaries, logs, archive snapshots, and proof outputs require exclude/quarantine/whitelist decisions before migration. |
| Migration-method risk | PASS | Copy-first, subtree split, filter-repo, archive/quarantine, and hold are treated as later options; no method is chosen in R256. |
| Physical migration over-authorization | PASS | No migration, target copy, history rewrite, remote push, package/CI/release, public claim, or archive repo creation is authorized. |
| Post-R256 sequencing | PASS | Split prep is recommended next; forms import hiding/overriding remains valid after split prep or if migration work pauses; PROP-039 remains later. |

## Compact Risk List

1. Final bucket overlap risk: medium. The dry-run count is useful, but
   migration authorization needs a refreshed mutually exclusive file map where
   generated/path-heavy language-root items are moved to explicit
   exclude/quarantine/whitelist outcomes.
2. Path leakage risk: high. C2-P1 reports 485 current local-path/file-link hit
   files. This blocks public migration until rewritten, excluded, or explicitly
   quarantined as historical evidence.
3. Generated artifact drift: high. `out/**`, `.igapp`, logs, JSON summaries,
   archives, and proof outputs must not become living public source by copy.
4. Support-file gap: medium. License, code of conduct, language `.gitignore`,
   task/dependency files, CI policy, and `igniter_lang.gemspec` metadata need
   explicit prep before migration auth.
5. Target baseline drift: medium. The three local target repos are ahead of
   origin by one `.gitignore` commit; C4-A must not treat them as push-ready
   migration targets without baseline decision.
6. Lab canon risk: low if current stance holds. Lab remains frontier only and
   requires a separate lab route.
7. Route sequencing risk: low. R255 already superseded the old R256 forms card;
   C4-A should keep R257 split-prep vs forms fallback explicit.

## Exact Recommendation To C4-A

Accept the proof evidence, but do not authorize migration:

```text
ACCEPT R256 dry-run file-map proof as split-map evidence.
ACCEPT C2-P1 current-target facts as verified evidence.
HOLD physical migration, history rewrite, target population, remote push,
package/CI/release changes, archive repo creation, public claims,
framework-to-language authority transfer, and lab canon.
REQUIRE a refreshed tracked-file count before any migration authorization review.
REQUIRE final mutually exclusive bucket dispositions for language-root,
ruby-framework, lab-frontier, archive-quarantine, and exclude.
REQUIRE path-hygiene handling for local absolute paths and file-link hits.
REQUIRE generated-artifact disposition for out/**, .igapp, logs, JSON summaries,
archives, proof outputs, and local metadata.
REQUIRE support-file decisions for license, code of conduct, language .gitignore,
task/dependency files, CI policy, and package metadata.
REQUIRE target baseline decision for the local ahead .gitignore commits before
any remote push or target population.
KEEP candidate:igniter-archive as archive-quarantine bucket, not a public repo.
KEEP lab-frontier outside language split.
KEEP public/stable/production/release/performance/certification/portability
claims closed.
```

Recommended next Main Line route if migration preparation continues:

```text
Card: S3-R257-C1-D
Track: igniter-lang-repository-split-support-file-path-hygiene-prep-v0
Route type: design/docs-prep/proof-local hygiene prep
```

Required boundary for that route:
- edit only authorized prep docs/proof artifacts;
- no migration/history rewrite/target population/remote push;
- no package/CI/release changes;
- no public/stable/runtime/release/performance/certification/portability
  claims;
- no framework-to-language authority transfer;
- no lab canon.

Fallback if C4-A pauses migration preparation:

```text
Card: S3-R257-C1-A
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route type: proof-local lab compiler authorization review
```

Do not route physical migration authorization review yet. Redirect to
support-file/link rewrite prep is preferred over migration auth. Pause is not
needed unless C4-A refuses both split prep and technical-lane continuation.
