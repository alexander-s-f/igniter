# Igniter Lang Repository Split Dry-Run File-Map Proof v0

Card: `S3-R256-C1-D`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-dry-run-file-map-proof-v0`  
Route: `UPDATE`  
Status: `dry-run-complete / migration-held / prep-required`  
Date: 2026-06-06

Depends on:

- `S3-R255-C5-S`

---

## Decision Frame

R255 accepted the repository split boundary as design-ready and
migration-held. R256 performs the next non-migrating proof step: classify the
current tracked source tree into destination buckets and identify blockers
before any physical migration, history rewrite, target-repo copy, remote push,
package/CI change, release, public claim, framework-to-language authority
transfer, or lab canon.

Repository labels used in this proof:

```text
source:igniter
target:alexander-s-f/igniter-lang
target:alexander-s-f/igniter-ruby
target:alexander-s-f/igniter-lab
candidate:igniter-archive
```

No migration, copy, history rewrite, remote, package, CI, or release command
was run. Target repositories were read only as readiness facts.

---

## Dry-Run Verdict

The dry-run file-map proof is complete enough to identify the split shape and
blockers. It is not complete enough to authorize physical migration.

Recommendation to C4-A:

```text
accept the dry-run file-map proof as evidence
hold physical migration and remote push
open split support-file / path-hygiene / link-rewrite prep next
keep candidate:igniter-archive as an archive-quarantine bucket for now
defer forms import hiding/overriding until after split prep unless C4-A pauses migration work
defer PROP-039 proof fixtures behind the split-prep decision
```

The blocker is not ownership ambiguity. The ownership split is clear. The
blocker is public-repo hygiene: tracked proof/archive/output surfaces contain
many local path references, and the future language root needs support-file and
metadata policy before migration execution.

---

## Evidence Commands

Evidence was gathered with read-only inventory commands:

```text
git ls-files
git grep for local absolute path and file-link patterns
git status --short
git -C target repos status / ls-files
support-file existence checks
tracked generated-artifact classification
```

Commands intentionally not run:

```text
git subtree split
git filter-repo
remote push
package / CI / release commands
copy into target repos as accepted migration
```

---

## Tracked Inventory Summary

Tracked files in `source:igniter`:

```text
total tracked files: 5459
```

Initial dry-run bucket counts:

| Bucket | Count | Stance |
| --- | ---: | --- |
| `language-root` | 3975 | Candidate future `target:alexander-s-f/igniter-lang` content, subject to generated/path/support-file cleanup. |
| `ruby-framework` | 1436 | Candidate future `target:alexander-s-f/igniter-ruby` / current framework retention. |
| `archive-quarantine` | 48 | Root-side mixed/local/history surfaces needing later decision. |
| `lab-frontier` | 0 tracked in source root | Lab exists as nested/frontier working tree, not tracked split content from source root. |
| `exclude` | 0 counted in tracked split map | Exclusion candidates are mostly generated/path/local patterns inside other buckets; see matrices below. |

Top language-root groups:

| Surface | Count | Stance |
| --- | ---: | --- |
| `igniter-lang/docs/**` | 2199 | Include as governance/history, with archive quarantine review. |
| `igniter-lang/experiments/**` | 1274 | Include proof source selectively; generated outputs need quarantine/exclude policy. |
| `igniter-lang/out/**` | 386 | Exclude or quarantine by default; not public canon. |
| `igniter-lang/lib/**` | 24 | Include. |
| `igniter-lang/fixtures/**` | 23 | Include. |
| `igniter-lang/source/**` | 18 | Include. |
| `igniter-lang/roles/**` | 15 | Include. |
| `igniter-lang/handoff/**` | 15 | Include. |
| `igniter-lang/examples/**` | 12 | Include source/example intent; generated outputs need classification. |
| `igniter-lang/bin/**` | 3 | Include, with path-hygiene review. |

Top framework groups:

| Surface | Count | Stance |
| --- | ---: | --- |
| `packages/**` | 833 | Ruby framework / umbrella package retention. |
| `examples/**` | 339 | Ruby framework examples, not language authority. |
| `spec/**` | 175 | Ruby framework tests. |
| root `docs/**` | 59 | Framework docs / cross-link context. |
| `.agents/**` | 47 | Framework/Ruby-lane operating evidence; not language repo authority. |
| root `lib/**` | 13 | Ruby framework implementation. |
| root files | 12 | Framework/support-file policy needed. |

---

## Destination Bucket Matrix

| Bucket | Include now as candidate | Hold / classify before migration |
| --- | --- | --- |
| `language-root` | `igniter-lang/README.md`, `AGENTS.md`, `RELEASE_NOTES.md`, `igniter_lang.gemspec`, `bin/**`, `lib/**`, `source/**`, `fixtures/**`, `tests/**`, `roles/**`, `handoff/**`, `docs/spec/**`, `docs/proposals/**`, `docs/cards/**`, `docs/tracks/**`, `docs/gates/**`, `docs/discussions/**` | `docs/archive/**`, `docs/reports/**`, `docs/reviews/**`, `experiments/**`, `examples/**` generated outputs, all local path hits, package metadata URLs. |
| `ruby-framework` | root `README.md`, `AGENTS.md`, `CHANGELOG.md`, root `docs/**`, root `lib/**`, `packages/**`, `examples/**`, `spec/**`, `sig/**`, root `Gemfile`, `Rakefile`, `igniter.gemspec` | Framework docs with language references need cross-link review after split. |
| `lab-frontier` | no initial language split content | `playgrounds/igniter-lab/**` remains frontier and requires later bounded intake or its own lab migration route. |
| `archive-quarantine` | historical route evidence, stale mixed-authority packets, local path-heavy archive snapshots, generated proof summaries whose provenance matters but source status is unclear | Use as bucket now; do not create a public `igniter-archive` repo from R256 alone. |
| `exclude` | local/editor/build/release artifacts and generated products not needed as source/audit | `out/**`, `.igapp`, logs, local metadata, gem artifacts, build dirs, node/rust targets, unless a later route whitelists specific evidence. |

---

## Generated Artifact Classification

Tracked generated/proof artifact signals:

| Signal | Count | Recommended stance |
| --- | ---: | --- |
| `out/**` or log paths | 1162 | Exclude/quarantine by default; whitelist only referenced durable evidence. |
| `.igapp` paths | 895 | Quarantine/exclude as generated compiler artifacts, not source authority. |
| JSON files | 1420 | Mixed: specs/proofs/manifests; classify by path and citation. |
| Archive paths | 752 | Keep audit value, but quarantine path-heavy snapshots before public migration. |
| Language log file | 1 | Exclude. |
| Root gem artifacts | 0 tracked | No tracked root gem artifact in current file map. |
| Local metadata | 1 tracked | Exclude or move to archive-quarantine only if intentionally retained. |

Interpretation:

- `igniter-lang/out/**` should not move as living language repo source.
- `.igapp` directories should not become public canon through a repository
  copy.
- Proof summaries and historical JSON can be valuable, but the dry-run found
  enough local path references that they need a path-hygiene pass before public
  migration.
- `docs/archive/**` should be treated as audit history, not current authority.

---

## Support-File Matrix

Root support files present in `source:igniter`:

| File | Status | Language split stance |
| --- | --- | --- |
| `LICENSE.txt` | Present at root | Copy or synthesize for language repo in a later support-file prep route. |
| `CODE_OF_CONDUCT.md` | Present at root | Copy or synthesize after ownership review. |
| `.gitignore` | Present at root | Rewrite for language repo; do not copy blindly because root ignores playgrounds and framework artifacts. |
| `Gemfile`, `Gemfile.lock`, `Rakefile` | Present at root | Framework-owned; language repo needs its own task/dependency policy. |
| `igniter.gemspec` | Present at root | Framework-owned. |
| `.rubocop.yml` | Present at root | Framework-owned or rewrite if language repo needs Ruby lint config. |
| root `README.md`, `AGENTS.md`, `CHANGELOG.md`, `CLAUDE.md` | Present | Framework-owned/cross-link surfaces. |

Language-root support files currently missing under `igniter-lang/**`:

| File | Status | Required before migration? |
| --- | --- | --- |
| `igniter-lang/Gemfile` | Missing | Needed or intentionally omitted by migration authorization. |
| `igniter-lang/Rakefile` | Missing | Needed or intentionally omitted by migration authorization. |
| `igniter-lang/.gitignore` | Missing | Needed before public target is populated. |
| `igniter-lang/LICENSE.txt` | Missing | Required unless inherited by another explicit license policy. |
| `igniter-lang/CODE_OF_CONDUCT.md` | Missing | Required or explicitly deferred. |
| `igniter-lang/.github/**` | Missing | CI absent; CI migration remains closed. |

---

## Link And Path Hygiene Summary

The path-hygiene scan found tracked files containing local absolute path or file
link patterns:

```text
hit files: 499
```

Hit distribution:

| Category | Files | Stance |
| --- | ---: | --- |
| generated or proof output | 341 | Quarantine/exclude or regenerate with relative paths. |
| language-root review | 115 | Requires cleanup or explicit archive exception before public migration. |
| archive-quarantine | 29 | Keep as historical if needed, but do not expose as current docs. |
| root support / other | 11 | Keep out of language split or clean separately. |
| ruby-framework review | 3 | Framework-side cleanup/cross-link issue, not language authority. |

Important interpretation:

- This is a public-repo blocker for physical migration.
- Many hits are historical/proof records rather than active source.
- The correct response is not to delete evidence in R256. It is to classify
  affected files into `archive-quarantine`, `exclude`, or `needs-rewrite`
  before any public migration.
- The R256 proof doc itself avoids local absolute paths and file links.

---

## Target Repository Readiness Facts

Target repository read-only checks:

| Target label | Branch | Tracked files | Worktree status | Readiness |
| --- | --- | ---: | --- | --- |
| `target:alexander-s-f/igniter-lang` | `main` | 2 | clean | Ready as empty target container, not migration authority. |
| `target:alexander-s-f/igniter-ruby` | `main` | 2 | clean | Ready as empty target container, not migration authority. |
| `target:alexander-s-f/igniter-lab` | `main` | 2 | clean | Ready as empty target container, not lab canon authority. |

Observed tracked files in each target:

```text
.gitignore
README.md
```

No target repo was modified.

---

## Lab / Frontier Facts

`playgrounds/igniter-lab/**` exists as a nested/frontier working tree with many
candidate implementation surfaces:

- `.agents/**`;
- `lab-docs/**`;
- `igniter-compiler/**`;
- `igniter-vm/**`;
- `igniter-runtime/**`;
- `igniter-stdlib/**`;
- `igniter-tbackend/**`;
- `igniter-machine/**`;
- `igniter-view-engine/**`;
- `igniter-ide/**`;
- `igniter-design-system/**`;
- `igniter-apps/**`;
- build outputs such as Rust targets, web build outputs, node modules, and
  proof `out/**` directories.

Decision:

```text
lab content remains frontier only
lab content does not move through the language split
target:alexander-s-f/igniter-lab needs its own bounded lab migration route
```

---

## History Preservation Options

| Option | Status | Risk |
| --- | --- | --- |
| Copy-first import | Possible later | Fast and clean but loses detailed file history unless paired with archive strategy. |
| Subtree split | Possible later | Preserves path history for `igniter-lang/**`, but risks carrying generated/path-heavy artifacts unless pruned first. |
| Filter-repo | Possible later only from temp clone | Most flexible, but highest operational risk and requires explicit authorization. |
| Archive/quarantine | Required now | Keeps historical/proof evidence from becoming living public authority. |
| Hold | Valid | Preferred if path/support-file cleanup is not authorized next. |

Recommended migration-method posture:

```text
do not choose migration method in R256
perform support-file/path/link/generated-artifact prep first
then open migration authorization review with method comparison
```

---

## Archive Recommendation

`candidate:igniter-archive` should remain a bucket, not a new repository, for
now.

Rationale:

- The dry-run found meaningful archive/quarantine need.
- Creating a public archive repo now would widen migration surface and public
claim surface.
- Many archive candidates contain local path/proof-output history and need
sanitization or explicit historical-evidence wording before public exposure.

Recommended stance:

```text
archive-quarantine bucket now
separate igniter-archive repo decision later if C4-A wants it
```

---

## Explicit Answers

### Is the dry-run file-map proof complete enough for migration authorization review?

No. It is complete enough to identify the split map and blockers, but not
complete enough to open live physical migration. A support-file/path-hygiene
prep route should come first.

### Can `igniter-lang/**` become the future language repo root without stranded critical language surfaces?

Yes, structurally. Critical language surfaces are inside `igniter-lang/**`.
However, generated artifacts, path-heavy proof outputs, and missing support
files must be handled before migration.

### Must any root support files be copied, synthesized, linked, or rewritten?

Yes. License, code of conduct, `.gitignore`, task/dependency files, and possibly
lint/CI surfaces require explicit copy/synthesis/rewrite decisions. Root
framework task files should not be copied blindly.

### Are target repos empty/ready enough for later migration planning?

Yes. They are clean target containers with only minimal tracked files. That is
readiness for planning, not migration authority.

### Would absolute local paths or file links leak into public repos?

Yes, if migration copied tracked files without hygiene. The scan found 499
tracked files with local path or file-link patterns, mostly generated/proof
output and language-history surfaces.

### Should generated proof artifacts move, be archived, be quarantined, or be excluded?

Mixed. Source/proof scripts and referenced durable summaries may move after
review. Generated `out/**`, `.igapp`, logs, and path-heavy JSON should be
excluded or quarantine by default unless a later route whitelists them.

### Should `candidate:igniter-archive` become a future repo?

Not yet. It should remain an archive/quarantine bucket for now. A future repo
decision may open after sanitization and public-history wording are designed.

### Does lab content remain frontier only?

Yes. Lab content remains frontier only and needs a separate lab migration/intake
route.

### Should forms import hiding/overriding remain sequenced after split dry-run?

Yes. If C4-A chooses to continue migration preparation, forms should remain
deferred behind split prep. If C4-A pauses migration work, forms may open as the
next technical route.

### May physical migration open next?

No. Physical migration must wait.

---

## Exact C4-A Recommendation

Recommend that C4-A:

```text
ACCEPT: R256 dry-run file-map proof as sufficient split-map evidence
HOLD: physical migration, history rewrite, remote push, package/CI/release
OPEN NEXT: split support-file / path-hygiene / link-rewrite prep route
KEEP: candidate:igniter-archive as archive-quarantine bucket, not repo
KEEP: lab-frontier outside language split
DEFER: forms import hiding/overriding to next available after split prep, unless migration work pauses
DEFER: PROP-039 proof-local fixtures behind forms or later
CLOSED: public/stable/production/release/performance/certification/portability claims
```

Suggested next route if migration preparation continues:

```text
Card: S3-R257-C1-D
Track: igniter-lang-repository-split-support-file-path-hygiene-prep-v0
Route type: design/docs-prep/proof-local hygiene prep
```

Suggested route if migration preparation pauses:

```text
Card: S3-R257-C1-A
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route type: proof-local lab compiler authorization review
```

No R256 decision should authorize live migration.
