# Igniter-Lang Repository Split Support-File / Path-Hygiene Facts v0

Card: `S3-R257-C2-P1`  
Skill: `IDD Agent Protocol`  
Agent: `[Implementation Surface Surveyor]`  
Role: `implementation-surface-surveyor`  
Track: `igniter-lang-repository-split-support-file-path-hygiene-facts-v0`  
Route: `UPDATE`  
Status: `facts-only / no migration authority`  
Date: 2026-06-06

## Boundary

This packet verifies current support-file, path/link hygiene, generated-artifact,
bucket-readiness, target-baseline, and migration-blocker facts after
`S3-R257-C1-D`.

It does not authorize code edits, repository migration, history rewrite,
`git subtree split`, `git filter-repo`, target population, remote push,
package/CI/release changes, archive repo creation, public claims,
framework-to-language authority transfer, lab canon, or live migration.

Write scope used:

- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-facts-v0.md`

No code, source, package, CI, runtime, root docs, target repos, playgrounds, or
existing split-prep artifacts were edited by this packet.

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-prep-v0.md`
- `igniter-lang/docs/tracks/stage3-round256-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R257.md`
- `igniter-lang/docs/current-status.md`
- source tracked-file inventory from `git ls-files`
- source root support files
- source `.gitignore`
- source `igniter-lang/**`
- source root framework surfaces as read-only context
- source `packages/**` as read-only context
- source `playgrounds/igniter-lab/**` as read-only frontier signal
- local target checkouts:
  - `target:alexander-s-f/igniter-lang`
  - `target:alexander-s-f/igniter-ruby`
  - `target:alexander-s-f/igniter-lab`

Observed pre-existing worktree/index state before this packet:

```text
A  igniter-lang/docs/cards/S3/S3-R257.md
A  igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-prep-v0.md
```

Those files are treated as C1-D/card inputs and were not modified here.

## C1-D Prep Baseline

`S3-R257-C1-D` reports:

- status: `prep-designed / migration-held / facts-review-required`;
- current tracked inventory at C1-D time:
  - total tracked files: `5464`;
  - `igniter-lang/**`: `3980`;
  - `packages/**`: `833`;
  - root examples: `339`;
  - root specs: `175`;
  - root docs: `59`;
  - `.agents/**`: `47`;
  - root `lib/**`: `13`;
  - root files: `12`;
  - tracked `playgrounds/**`: `1`;
- mutually exclusive disposition model:
  - `language-root`: `2777`;
  - `ruby-framework`: `1479`;
  - `lab-frontier`: `1`;
  - `archive-quarantine`: `820`;
  - `exclude`: `387`;
  - `whitelist`: `0`;
- path/link hygiene hit files at C1-D time: `501`;
- recommendation: accept prep only if C2-P1 facts and C3-X pressure agree;
  keep physical migration and remote push closed.

## Refreshed Tracked Counts

Current index snapshot:

| Source group | Current tracked files | R257 stance |
| --- | ---: | --- |
| Total tracked files | 5466 | Current C2-P1 snapshot; requires refresh before any migration review. |
| `igniter-lang/**` | 3982 | Candidate language-root with generated/archive exclusions. |
| `packages/**` | 833 | Ruby framework / umbrella package retention. |
| root `examples/**` | 339 | Ruby framework examples. |
| root `spec/**` | 175 | Ruby framework tests. |
| root `docs/**` | 59 | Framework docs / cross-link context. |
| `.agents/**` | 47 | Framework/Ruby-lane operating evidence, not language authority. |
| root `lib/**` | 13 | Ruby framework implementation. |
| root files | 12 | Support-file classification required. |
| root `sig/**` | 1 | Ruby framework type surface. |
| tracked `playgrounds/**` | 1 | `playgrounds/README.md`; nested lab remains ignored/frontier. |

Current `igniter-lang/**` groups:

| Group | Current tracked files | R257 stance |
| --- | ---: | --- |
| `igniter-lang/docs/**` | 2206 | Candidate governance/history; path/archive review required. |
| `igniter-lang/experiments/**` | 1274 | Candidate proof source/history; generated outputs need disposition. |
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

Interpretation:

- The C1-D model remains structurally valid.
- Counts have moved from `5464` to `5466`, and from `3980` to `3982` under
  `igniter-lang/**`.
- The mutually exclusive bucket model must be regenerated before any migration
  authorization review, because the current index no longer exactly matches the
  C1-D count basis.

## Support-File Facts Matrix

| Surface | Root status | Language-root status | R257 fact |
| --- | --- | --- | --- |
| License | `LICENSE.txt` present | missing | Public language repo needs copy/synthesis/defer policy. |
| Code of conduct | `CODE_OF_CONDUCT.md` present | missing | Public language repo needs copy/synthesis/defer policy. |
| `.gitignore` | present | missing | Target repos have minimal `.gitignore`, but language-specific ignore policy is not reviewed. |
| `Gemfile` | present | missing | Framework-owned root file; language repo task/dependency policy unresolved. |
| `Gemfile.lock` | present | missing | Framework-owned root file; language repo lockfile policy unresolved. |
| `Rakefile` | present | missing | Framework-owned root file; language repo task policy unresolved. |
| `.rubocop.yml` | present | missing | Framework-owned or rewrite candidate; no language lint policy accepted. |
| root gemspec | `igniter.gemspec` present | n/a | Framework package metadata retained outside language authority. |
| language gemspec | n/a | `igniter_lang.gemspec` present | Requires URL/source/package-claim review before split/package action. |
| README | root present | language present | Root README remains framework/cross-link; language README candidate inclusion. |
| AGENTS | root present | language present | Root AGENTS remains framework/cross-project; language AGENTS candidate inclusion. |
| release/status docs | root changelog present | language release notes/current status present | Governance/history only; no release authority. |

## Package Metadata Risks

`igniter-lang/igniter_lang.gemspec` currently contains:

- `spec.homepage = "https://github.com/alexander-s-f/igniter"`;
- `"source_code_uri" => "#{spec.homepage}/tree/main/igniter-lang"`;
- package description with alpha/pre-release/non-production wording;
- file list limited to `lib/**/*.rb`, `bin/igc`, `README.md`, and
  `RELEASE_NOTES.md`.

R257 fact:

- package metadata is not split-ready;
- no package rename, metadata edit, release, CI, or gem publish is authorized;
- future package/metadata route must decide whether URLs point to
  `target:alexander-s-f/igniter-lang` and what support files are packaged.

## Generated Artifact Facts

Current tracked generated/proof signals:

| Signal | Current count | Default disposition |
| --- | ---: | --- |
| `out/**`, log, or `out_run` paths | 1162 | `exclude` by default. |
| `.igapp` paths | 895 | `exclude` or `archive-quarantine`; never living source by default. |
| JSON files | 1420 | path-based; source manifests/specs may stay, generated summaries need review. |
| archive paths | 752 | `archive-quarantine` unless explicitly accepted as public history. |
| tracked root gem artifacts | 0 | no current tracked root gem artifact. |
| tracked local metadata | 1 | exclude or quarantine only by explicit later policy. |

Current ignored/local status facts:

| Status code | Count | Meaning |
| --- | ---: | --- |
| `!!` | 4486 | Ignored local/editor/build/cache/frontier output lines. |
| `A ` | 2 | Pre-existing staged R257 card/prep inputs. |

Ignored/local classes observed through source policy and lab inventory include
`.DS_Store`, `.claude/worktrees/**`, `.idea/**`, `.rubocop_cache/**`, lab
`target/**`, `node_modules/**`, `.svelte-kit`, build outputs, proof `out/**`,
and nested lab git internals.

## Path / Link Hygiene Facts

Broad public-migration scan for local absolute path or local file-link patterns:

| Category | Hit files |
| --- | ---: |
| generated or output | 317 |
| language-root review | 138 |
| archive-quarantine | 29 |
| ruby-framework review | 3 |
| total | 487 |

Markdown-specific link/path risk scan under `igniter-lang/**`:

| Pattern class | Candidate markdown files |
| --- | ---: |
| parent-relative markdown links | 13 |
| monorepo path text such as root `packages/`, `examples/`, `playgrounds/`, `docs/`, or `lib/` | 1283 |
| `igniter-lang/` prefixed path text or links | 1895 |
| local absolute path / local file-link patterns | 132 |
| markdown files scanned | 2246 |

Interpretation:

- Local path/file-link hygiene remains a public migration blocker.
- The C1-D `501` hit count and C2-P1 `487` broad hit count differ because the
  index and scan categories have moved, but both confirm unresolved hygiene.
- Monorepo-relative and `igniter-lang/` prefixed path references are too broad
  to auto-rewrite without a later docs/link policy.

## Mutually Exclusive Bucket Readiness

| Bucket | C1-D count | Current readiness |
| --- | ---: | --- |
| `language-root` | 2777 | Model accepted as planning shape, but count basis is stale after current index delta. |
| `ruby-framework` | 1479 | Framework retention remains clear. |
| `lab-frontier` | 1 | Source-root tracked lab content remains only `playgrounds/README.md`. |
| `archive-quarantine` | 820 | Still required for historical/generated/path-heavy material. |
| `exclude` | 387 | Still required for generated/local output surfaces. |
| `whitelist` | 0 | Empty by default; no explicit durable proof whitelist accepted. |

R257 fact:

- The disposition buckets are mutually exclusive as a design model.
- A final per-file migration authorization review still needs regenerated
  bucket counts and a file-map artifact from the current index.
- No whitelist is ready by default.

## Candidate Exclude / Quarantine / Whitelist Groups

| Group | Candidate disposition | Reason |
| --- | --- | --- |
| `igniter-lang/out/**` | exclude | Generated output, not living source. |
| `igniter-lang/out_run.log` and logs | exclude | Local/proof execution output. |
| generated `.igapp` artifacts | exclude or archive-quarantine | Compiler output; not public canon by copy. |
| generated proof summaries | archive-quarantine or whitelist | Audit value possible only if cited and path-clean. |
| `igniter-lang/docs/archive/**` | archive-quarantine | Historical value, not current authority. |
| path-heavy review/report packets | archive-quarantine or rewrite | Public path hygiene blocker. |
| durable proof scripts and source fixtures | language-root | Source-like evidence if path-clean. |
| root framework packages/docs/examples | ruby-framework | Outside language authority. |
| nested `playgrounds/igniter-lab/**` | lab-frontier | Separate frontier; no lab canon. |

Whitelist readiness:

```text
No explicit whitelist artifact is ready in C2-P1.
Any durable proof whitelist must be accepted by C4-A or a later migration gate.
```

## Target Baseline Facts

Observed local target repositories:

| Target | Origin remote | Branch/status | Tracked files | Current files | Baseline fact |
| --- | --- | --- | ---: | --- | --- |
| `target:alexander-s-f/igniter-lang` | `https://github.com/alexander-s-f/igniter-lang.git` | `main...origin/main [ahead 1]` | 2 | `.gitignore`, `README.md` | Local planning container; one local ignore-file commit ahead. |
| `target:alexander-s-f/igniter-ruby` | `https://github.com/alexander-s-f/igniter-ruby.git` | `main...origin/main [ahead 1]` | 2 | `.gitignore`, `README.md` | Local planning container; one local ignore-file commit ahead. |
| `target:alexander-s-f/igniter-lab` | `https://github.com/alexander-s-f/igniter-lab.git` | `main...origin/main [ahead 1]` | 2 | `.gitignore`, `README.md` | Local planning container; one local ignore-file commit ahead. |

Each target local-ahead diff:

```text
.gitignore | 12 insertions
```

Target baseline facts:

- target worktrees are not dirty;
- targets are not populated with source split content;
- each target has a local commit not present on `origin/main`;
- no target push/population is authorized;
- future migration review must decide whether to preserve, replace, push, or
  discard the local `.gitignore` baseline commits.

## Lab Frontier Facts

`playgrounds/igniter-lab/**` remains read-only frontier signal. Observed lab
surfaces include compiler, VM, runtime, stdlib, TBackend, machine, IDE,
JetBrains plugin, design system, apps, lab docs, `.agents`, and many local build
or generated directories.

Source-root tracked lab fact:

```text
tracked playgrounds files: 1
nested lab tracked by source root: no
```

Lab migration/intake remains separate and closed.

## Compact Support-File / Path-Hygiene Matrix

| Area | Current fact | C4-A implication |
| --- | --- | --- |
| Source counts | `5466` tracked; `3982` under `igniter-lang/**`. | Refresh file map before any migration auth. |
| Support files | Root support exists; language-root support incomplete. | Copy/synthesize/rewrite/defer decisions still needed. |
| Package metadata | language gemspec points at monorepo URL/source path. | Package/release remains closed. |
| Generated artifacts | `1162` output/log, `895` `.igapp`, `1420` JSON, `752` archive. | Exclude/quarantine/whitelist policy required. |
| Broad path hygiene | `487` hit files. | Public migration blocker. |
| Markdown link risks | `13` parent-relative, `132` local absolute/link, many monorepo path refs. | Link rewrite policy required. |
| Buckets | C1-D model is mutually exclusive but count basis is stale. | Regenerate final per-file map. |
| Targets | all three targets are local `ahead 1`. | Baseline decision required before push/population. |
| Lab | frontier only, not source-root tracked. | No lab canon; separate route only. |

## Blockers And Risks For C4-A

| Blocker / risk | Current evidence | Recommendation |
| --- | --- | --- |
| Current file-map drift | C1-D `5464`; C2-P1 current `5466`. | Require regenerated file-map before migration authorization. |
| Support-file gap | Language root lacks license, conduct, `.gitignore`, task files, CI policy. | Resolve support-file policy first. |
| Path leakage | Broad scan still finds `487` hit files. | Rewrite, exclude, quarantine, or explicitly whitelist. |
| Monorepo link drift | Many markdown files mention old root-relative or `igniter-lang/` paths. | Run bounded link-rewrite design/proof before migration. |
| Generated artifact overclaim | High output/log, `.igapp`, JSON, archive counts. | Keep default exclude/quarantine; whitelist only by decision. |
| Target baseline drift | Targets are locally ahead by `.gitignore` commits. | Decide target baseline before any push/population. |
| Package metadata drift | gemspec points to monorepo source URI. | Keep package metadata/release changes closed pending route. |
| Lab canon drift | Lab is nested/frontier/build-heavy. | Keep lab outside language split. |
| Archive repo overreach | Archive-quarantine still contains path-heavy candidates. | Keep `candidate:igniter-archive` as bucket only. |

## Explicit Answers

### Are support-file gaps resolved?

No. Root support files exist, but the future language root still lacks accepted
license, code of conduct, language `.gitignore`, task/dependency files, and CI
policy.

### Are local path and local file-link risks resolved?

No. The broad scan still finds `487` hit files, and markdown-specific scan still
finds `132` local absolute path or local file-link candidates under
`igniter-lang/**`.

### Are monorepo-relative link risks resolved?

No. The scan found many `igniter-lang/` prefixed and monorepo-path references.
They need a separate rewrite/cross-link policy before public migration.

### Are generated artifacts ready to migrate?

No. Default stance remains exclude/quarantine, with an empty whitelist.

### Are mutually exclusive buckets ready for migration authorization?

Not yet. C1-D provides a mutually exclusive model, but the current index count
has changed. A regenerated per-file bucket artifact is required before any
migration authorization review.

### Are target repositories ready?

They are planning containers only. Each target tracks `.gitignore` and
`README.md`, has no dirty worktree changes, and is locally ahead of
`origin/main` by one `.gitignore` commit. Baseline decision is still required.

### Does this packet authorize migration?

No. Migration, history rewrite, target population, remote push, package/CI
changes, release, archive repo creation, public claims, framework-to-language
authority transfer, and lab canon remain closed.

## C4-A Recommendation

Recommend C4-A:

```text
ACCEPT: R257-C2-P1 facts as verified blocker evidence.
ACCEPT: support/path prep direction, but not migration execution.
HOLD: physical migration, history rewrite, target population, remote push.
REQUIRE: regenerated current-index per-file disposition map.
REQUIRE: support-file policy before public repo population.
REQUIRE: path/link rewrite or quarantine plan before public migration.
REQUIRE: target baseline decision for local ahead .gitignore commits.
KEEP: candidate:igniter-archive as archive-quarantine bucket only.
KEEP: lab-frontier separate and non-canonical.
KEEP: package/CI/release/public claims closed.
```

Safe next-route shape:

```text
future migration authorization review as a gate only
or additional file-map/link-hygiene prep if C3-X finds blocker wording drift
```
