# Igniter-Lang Repository Split Physical-Migration Authorization Facts v0

Card: `S3-R258-C2-P1`  
Skill: `IDD Agent Protocol`  
Agent: `[Implementation Surface Surveyor]`  
Role: `implementation-surface-surveyor`  
Track: `igniter-lang-repository-split-physical-migration-authorization-facts-v0`  
Route: `UPDATE`  
Status: `facts-only / migration-held`  
Date: 2026-06-06

## Boundary

This packet verifies current facts for the R258 physical-migration
authorization review. It does not authorize physical migration, history rewrite,
`git subtree split`, `git filter-repo`, target repository population, remote
push, package/CI/release changes, archive repo creation, public claims,
framework-to-language authority transfer, lab canon, or live execution.

Write scope used:

- `igniter-lang/docs/tracks/igniter-lang-repository-split-physical-migration-authorization-facts-v0.md`

No code, source, package, CI, runtime, target repository, root doc, playground,
or existing split-review artifact was edited.

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-physical-migration-authorization-review-v0.md`
- `igniter-lang/docs/tracks/stage3-round257-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-decision-v0.md`
- source tracked-file inventory from `git ls-files`
- source root support files and `.gitignore`
- source `igniter-lang/**`
- source root framework surfaces as read-only context
- source `packages/**` as read-only context
- source `playgrounds/igniter-lab/**` as read-only frontier signal
- local target checkouts:
  - `target:alexander-s-f/igniter-lang`
  - `target:alexander-s-f/igniter-ruby`
  - `target:alexander-s-f/igniter-lab`
- local git reflogs for source and target repositories as available evidence

No migration, history rewrite, target population, remote push, package, CI, or
release command was run by this packet.

## R258-C1-A Baseline

`S3-R258-C1-A` reports:

- status: `authorization-review / migration-held / facts-refresh-required`;
- no physical migration, target population, history rewrite, remote push,
  package/CI/release change, archive repo creation, public claim, authority
  transfer, or lab canon authorized;
- current-index snapshot at C1-A time:
  - total tracked files: `5471`;
  - `igniter-lang/**`: `3987`;
  - `packages/**`: `833`;
  - tracked `playgrounds/**`: `1`;
  - `igniter-lang/out/**`: `386`;
  - tracked `.igapp` under `igniter-lang/**`: `894`;
  - tracked JSON under `igniter-lang/**`: `1412`;
  - `igniter-lang/docs/archive/**`: `587`;
- C1-A default recommendation: hold physical migration execution and route
  additional current-index file-map/support-policy prep if split work continues.

## Current-Index Facts Matrix

Fresh C2-P1 snapshot:

| Source group | Current tracked files | Migration authorization fact |
| --- | ---: | --- |
| Total tracked files | 5472 | One more than C1-A; current-index map must be regenerated. |
| `igniter-lang/**` | 3988 | One more than C1-A; language-root candidate remains coherent but stale counts block execution auth. |
| `packages/**` | 833 | Ruby Framework / package retention. |
| root `examples/**` | 339 | Ruby Framework examples. |
| root `spec/**` | 175 | Ruby Framework tests. |
| root `docs/**` | 59 | Framework docs / cross-link context. |
| `.agents/**` | 47 | Framework/Ruby-lane operating evidence, not language authority. |
| root `lib/**` | 13 | Ruby Framework implementation. |
| root `sig/**` | 1 | Ruby Framework type surface. |
| tracked `playgrounds/**` | 1 | `playgrounds/README.md`; nested lab remains frontier. |
| root files | 12 | Support-file classification still required. |

Current `igniter-lang/**` groups:

| Group | Current tracked files | Fact |
| --- | ---: | --- |
| `igniter-lang/docs/**` | 2212 | Governance/history candidate, with path/archive review. |
| `igniter-lang/experiments/**` | 1274 | Proof-source/history candidate; generated outputs need disposition. |
| `igniter-lang/out/**` | 386 | Exclude by default. |
| `igniter-lang/lib/**` | 24 | Candidate language implementation. |
| `igniter-lang/fixtures/**` | 23 | Candidate fixtures after generated-artifact review. |
| `igniter-lang/source/**` | 18 | Candidate language sources. |
| `igniter-lang/handoff/**` | 15 | Candidate governance/handoff. |
| `igniter-lang/roles/**` | 15 | Candidate role/onboarding. |
| `igniter-lang/examples/**` | 12 | Candidate examples; outputs excluded/quarantined. |
| `igniter-lang/bin/**` | 3 | Candidate CLI/package surface, with metadata review. |
| top-level language files | 5 | README, AGENTS, release notes, gemspec, and one log candidate. |
| `igniter-lang/tests/**` | 1 | Candidate test inclusion. |

## Split-Planning Docs Since R257

Compared with the R257 status-curation point, current split-planning changes
are:

| Status | Path |
| --- | --- |
| Added | `igniter-lang/docs/cards/S3/S3-R258.md` |
| Added | `igniter-lang/docs/tracks/igniter-lang-repository-split-physical-migration-authorization-review-v0.md` |

No moved or deleted split-planning doc was observed in the checked diff range.

## Per-File Disposition Readiness

Observed facts:

- no final per-file disposition artifact directory was found under
  `igniter-lang/docs/tracks/repository-split-physical-migration-authorization-review-v0/`;
- no current-index file-map/support-policy artifact directory was found under
  `igniter-lang/docs/tracks/repository-split-current-index-file-map-and-support-policy-prep-v0/`;
- C1-A and C2-P1 tracked counts differ.

Conclusion:

```text
per-file disposition readiness: absent / blocker
explicit whitelist status: empty by default / not accepted
```

## Support-File Facts

| Surface | Source root status | `igniter-lang/**` status | R258 fact |
| --- | --- | --- | --- |
| License | `LICENSE.txt` present | missing | Copy/synthesize/defer policy required. |
| Code of conduct | `CODE_OF_CONDUCT.md` present | missing | Copy/synthesize/defer policy required. |
| `.gitignore` | present | missing | Target baseline exists but language-specific ignore policy not accepted. |
| `Gemfile` | present | missing | Root/framework-owned by default; language task policy unresolved. |
| `Gemfile.lock` | present | missing | Root/framework-owned by default; language dependency policy unresolved. |
| `Rakefile` | present | missing | Root/framework-owned by default; language task policy unresolved. |
| `.rubocop.yml` | present | missing | Rewrite/defer decision required if language repo keeps lint tasks. |
| root gemspec | `igniter.gemspec` present | n/a | Framework package metadata retained outside language authority. |
| language gemspec | n/a | `igniter_lang.gemspec` present | Requires split URL/source/package-claim review. |
| README / AGENTS | root present | language present | Separate framework and language authority surfaces. |

Support-file policy is not execution-ready.

## Package Metadata Risks

`igniter-lang/igniter_lang.gemspec` still points at the monorepo:

- homepage: `https://github.com/alexander-s-f/igniter`;
- source code URI: `#{homepage}/tree/main/igniter-lang`;
- package wording remains alpha/pre-release/non-production;
- packaged files remain limited to `lib/**/*.rb`, `bin/igc`, `README.md`, and
  `RELEASE_NOTES.md`.

No package metadata edit, package rename, release, CI change, or public package
claim is authorized by R258-C2-P1.

## Path / Link Hygiene Facts

Broad public-migration scan for local absolute path or local file-link patterns:

| Category | Hit files |
| --- | ---: |
| generated or output | 317 |
| language-root review | 138 |
| archive-quarantine | 29 |
| ruby-framework review | 3 |
| total source broad scan | 487 |
| `igniter-lang/**` hit files in broad scan | 484 |

Markdown-specific scan under `igniter-lang/**`:

| Pattern class | Candidate markdown files |
| --- | ---: |
| parent-relative markdown links | 13 |
| monorepo path text such as root `packages/`, `examples/`, `playgrounds/`, `docs/`, or `lib/` | 1287 |
| `igniter-lang/` prefixed path text or links | 1901 |
| local absolute path / local file-link patterns | 132 |
| markdown files scanned | 2252 |

Conclusion:

- local path and local file-link risks remain unresolved;
- monorepo-relative link risks remain unresolved;
- path/link hygiene blocks public target population and remote push.

## Generated Artifact Facts

Current generated/artifact signals:

| Signal | Current count | Default disposition |
| --- | ---: | --- |
| `out/**`, log, or `out_run` paths | 1162 | exclude by default. |
| `.igapp` paths | 895 | exclude or archive-quarantine; not living source by copy. |
| JSON files | 1420 | path-based review; generated summaries need disposition. |
| archive paths | 752 | archive-quarantine unless explicitly accepted as public history. |
| tracked root gem artifacts | 0 | no current tracked root gem artifact. |
| tracked local metadata | 1 | exclude or quarantine by explicit policy only. |

`igniter-lang/**` specific:

| Signal | Current count |
| --- | ---: |
| `igniter-lang/out/**` | 386 |
| `.igapp` under `igniter-lang/**` | 895 |
| JSON under `igniter-lang/**` | 1412 |
| `igniter-lang/docs/archive/**` | 587 |

Explicit whitelist status:

```text
empty by default
no accepted whitelist artifact found
```

## Archive / Quarantine Candidates

Archive/quarantine candidates remain:

- `igniter-lang/docs/archive/**`;
- generated proof summaries with audit value but unclear public/source status;
- generated `.igapp` artifacts if retained as historical evidence;
- path-heavy review/report packets;
- local-path or file-link bearing historical materials;
- stale/mixed-authority docs that should not become current public authority.

`candidate:igniter-archive` remains a bucket only. Archive repo creation remains
closed.

## Target Baseline Facts

| Repository | Status | Origin remote | Tracked files | Current files | Baseline fact |
| --- | --- | --- | ---: | --- | --- |
| `source:igniter` | `master...origin/master [ahead 75]` | `https://github.com/alexander-s-f/igniter.git` | 5472 | source repo | Local docs work only in recent reflog; no target population evidence. |
| `target:alexander-s-f/igniter-lang` | `main...origin/main [ahead 1]` | `https://github.com/alexander-s-f/igniter-lang.git` | 2 | `.gitignore`, `README.md` | Planning container; one local `.gitignore` commit ahead. |
| `target:alexander-s-f/igniter-ruby` | `main...origin/main [ahead 1]` | `https://github.com/alexander-s-f/igniter-ruby.git` | 2 | `.gitignore`, `README.md` | Planning container; one local `.gitignore` commit ahead. |
| `target:alexander-s-f/igniter-lab` | `main...origin/main [ahead 1]` | `https://github.com/alexander-s-f/igniter-lab.git` | 2 | `.gitignore`, `README.md` | Planning container; one local `.gitignore` commit ahead. |

Each target local-ahead diff remains:

```text
.gitignore | 12 insertions
```

No target repository is populated with split source content.

## Migration / Population / Push Evidence

Available local evidence:

- source reflog recent entries from R255-R258 are docs commits only;
- target reflogs show only initial repository setup, branch rename, and
  `Add gitignore`;
- target repository status still shows only `.gitignore` and `README.md`;
- target local branches remain ahead of `origin/main` by the same local
  `.gitignore` commit, which is evidence that those local baseline commits have
  not been pushed from these checkouts.

Limitations:

- git reflog does not prove absence of every possible shell command;
- no durable shell-receipt artifact for all previous operator terminals was
  found or relied on;
- this packet can only state that available local git status/reflog evidence
  does not show live migration, target population, or remote push.

## Migration-Method Prerequisites

| Method | Current status | Missing prerequisites |
| --- | --- | --- |
| Copy-first | Not authorized. | Current-index file map, support files, exact copy scope, target baseline, rollback receipt. |
| Subtree split | Not authorized. | Path-clean `igniter-lang/**`, generated disposition, history/audit policy, command plan. |
| Filter-repo | Not authorized. | Temp clone, exact command plan, rollback plan, explicit high-risk approval. |
| Archive/quarantine | Required as disposition only. | Public/private stance and sanitized archive list. |
| Hold | Current safe default. | None; remains valid while blockers persist. |

## Compact Facts Matrix

| Area | Current fact | C4-A implication |
| --- | --- | --- |
| Current index | `5472` tracked; `3988` under `igniter-lang/**`. | C1-A counts stale; regenerate file map. |
| Per-file disposition | No final artifact found. | Execution authorization blocked. |
| Support files | Language root lacks license, conduct, `.gitignore`, task files, CI policy. | Support policy required. |
| Package metadata | language gemspec points at monorepo. | Package/release remains closed. |
| Path/link hygiene | 487 broad hit files; 132 markdown local path/link candidates. | Public migration blocked. |
| Generated artifacts | High output, `.igapp`, JSON, archive counts. | Exclude/quarantine/whitelist policy required. |
| Whitelist | Empty by default; no accepted artifact. | No durable proof whitelist ready. |
| Targets | Three targets are planning containers, all `ahead 1`. | Baseline decision required. |
| Reflog/status | Available evidence shows docs/setup only, no target population. | Negative local signal, not execution authorization. |
| Lab | Nested/frontier, not initial language split content. | Lab canon remains closed. |

## Blockers For C4-A

| Blocker | Evidence | Recommendation |
| --- | --- | --- |
| Count drift | C1-A `5471` / `3987`; C2-P1 `5472` / `3988`. | Require regenerated current-index per-file map. |
| Missing disposition artifact | No final file-map artifact found. | Route file-map materialization before execution auth. |
| Support-file policy unresolved | language root lacks core public repo support files. | Decide copy/synthesize/rewrite/defer. |
| Path/link hygiene unresolved | broad scan `487`; markdown local path/link `132`. | Rewrite, quarantine, exclude, or non-public disposition. |
| Generated artifact disposition unresolved | output/log, `.igapp`, JSON, archive counts remain high. | Keep default exclude/quarantine; whitelist only by decision. |
| Target baseline unresolved | all targets `ahead 1` with `.gitignore`. | Decide preserve/replace/push later/regenerate/discard. |
| Package metadata unresolved | gemspec still monorepo-oriented. | Keep package/CI/release closed. |
| Archive repo overreach | archive candidates still path-heavy. | Keep archive as bucket only. |
| Lab canon risk | lab remains frontier/build-heavy. | Keep lab outside split execution. |

## Explicit Answers

### Is a migration execution route ready?

No. The split direction remains valid, but execution authorization is blocked by
count drift, missing per-file disposition artifact, unresolved support files,
path/link hygiene, generated-artifact disposition, and target baseline status.

### Is physical migration authorized by this facts packet?

No.

### Is remote push or target population authorized?

No.

### Is support-file policy complete?

No. License, code of conduct, language `.gitignore`, task/dependency files, CI
posture, and package metadata remain unresolved.

### Are local path/file-link blockers resolved?

No.

### Is an explicit generated-artifact whitelist accepted?

No. Whitelist remains empty by default and no whitelist artifact was found.

### Do available local reflog/status facts show live migration?

No available local git status/reflog evidence shows live migration, target
population, or remote push. This is a negative local signal, not a global proof.

## C4-A Recommendation

Recommend C4-A:

```text
ACCEPT: R258-C2-P1 facts as blocker evidence.
HOLD: physical migration execution authorization.
HOLD: target population and remote push.
REQUIRE: regenerated current-index per-file disposition artifact.
REQUIRE: support-file copy/synthesize/rewrite/defer policy.
REQUIRE: path/link rewrite, quarantine, exclude, or non-public disposition.
REQUIRE: generated-artifact exclude/quarantine/whitelist decision.
REQUIRE: target baseline decision for all three target repositories.
KEEP: candidate:igniter-archive as bucket only.
KEEP: lab-frontier separate and non-canonical.
KEEP CLOSED: package/CI/release/public/stable/production/performance/certification/portability claims.
```

Recommended next route if split work continues:

```text
S3-R259-C1-D
igniter-lang-repository-split-current-index-file-map-and-support-policy-prep-v0
additional prep / file-map materialization / no live migration
```
