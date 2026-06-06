# Igniter-Lang Repository Split Dry-Run Current Target Facts v0

Card: `S3-R256-C2-P1`  
Skill: `IDD Agent Protocol`  
Agent: `[Implementation Surface Surveyor]`  
Role: `implementation-surface-surveyor`  
Track: `igniter-lang-repository-split-dry-run-current-target-facts-v0`  
Route: `UPDATE`  
Status: `facts-only / no migration authority`  
Date: 2026-06-06

## Boundary

This packet verifies current dry-run and target facts after
`S3-R256-C1-D`. It does not authorize physical repository migration, history
rewrite, `git subtree split`, `git filter-repo`, target-repo copying, remote
push, package/CI/release changes, public claims, framework-to-language
authority transfer, lab canon, or archive repo creation.

Write scope used:

- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-current-target-facts-v0.md`

No code, package, CI, runtime, source, experiment, target-repo, root-doc, or
playground file was edited.

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-proof-v0.md`
- `igniter-lang/docs/tracks/stage3-round255-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R256.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/AGENTS.md`
- `igniter-lang/roles/README.md`
- `igniter-lang/roles/base-role.md`
- `igniter-lang/roles/implementation-agent.md`
- source tracked-file inventory from `git ls-files`
- source `.gitignore`
- source `igniter-lang/**`
- source root framework surfaces
- source `packages/**`
- source `playgrounds/igniter-lab/**` as read-only frontier signal
- local target checkouts:
  - `target:alexander-s-f/igniter-lang`
  - `target:alexander-s-f/igniter-ruby`
  - `target:alexander-s-f/igniter-lab`

Target repositories were observed through local checkouts and configured
`origin` remotes only. No remote fetch, push, copy, history rewrite, migration,
package, CI, or release command was run.

## C1-D Dry-Run Baseline

`S3-R256-C1-D` reports:

- status: `dry-run-complete / migration-held / prep-required`;
- `source:igniter` total tracked files at that time: `5459`;
- initial dry-run buckets:
  - `language-root`: `3975`;
  - `ruby-framework`: `1436`;
  - `archive-quarantine`: `48`;
  - `lab-frontier`: `0 tracked in source root`;
  - `exclude`: `0 counted in tracked split map`;
- generated/proof artifact signals:
  - `out/**` or log paths: `1162`;
  - `.igapp` paths: `895`;
  - JSON files: `1420`;
  - archive paths: `752`;
  - tracked root gem artifacts: `0`;
  - tracked local metadata: `1`;
- path-hygiene hit files reported by C1-D: `499`;
- C1-D recommendation: accept dry-run file-map proof as evidence, hold
  physical migration, and open support-file / path-hygiene / link-rewrite prep.

## Current Verification Delta

The current source checkout now reports:

| Fact | Current value | Note |
| --- | ---: | --- |
| Total tracked files | 5460 | One more than C1-D baseline. |
| Tracked `igniter-lang/**` files | 3976 | One more than C1-D baseline. |
| Tracked `packages/**` files | 833 | Framework/package retention surface. |
| Tracked `playgrounds/**` files | 1 | `playgrounds/README.md`; lab tree remains ignored/nested. |
| Ignored/local status lines | 4486 | Local/editor/build/cache surfaces, not migration input. |

Interpretation:

- The C1-D split shape still holds.
- The current tracked count has moved by one file after R256 documentation
  work. This is a file-map refresh requirement, not migration authority.
- Physical migration still must wait for a later authorization review.

## Current Source Tracked Matrix

| Source group | Tracked files | Split stance |
| --- | ---: | --- |
| `igniter-lang/**` | 3976 | Candidate language-root, pending hygiene/support-file prep. |
| `packages/**` | 833 | Ruby framework/package retention. |
| root `examples/**` | 339 | Ruby framework examples. |
| root `spec/**` | 175 | Ruby framework tests. |
| root `docs/**` | 59 | Framework docs / cross-link context. |
| `.agents/**` | 47 | Framework/Ruby-lane operating evidence, not language authority. |
| root `lib/**` | 13 | Ruby framework implementation. |
| root files | 12 | Support-file classification required. |
| root `sig/**` | 1 | Ruby framework type surface. |
| `playgrounds/**` tracked | 1 | Only `playgrounds/README.md`; lab content not tracked by source root. |

## Current Language-Root Candidate Matrix

| `igniter-lang/**` group | Tracked files | Current stance |
| --- | ---: | --- |
| `igniter-lang/docs/**` | 2200 | Candidate governance/history inclusion; archive/path review required. |
| `igniter-lang/experiments/**` | 1274 | Candidate proof-source inclusion; generated outputs need quarantine/exclude policy. |
| `igniter-lang/out/**` | 386 | Exclude/quarantine by default. |
| `igniter-lang/lib/**` | 24 | Candidate language implementation inclusion. |
| `igniter-lang/fixtures/**` | 23 | Candidate fixture inclusion after generated-artifact review. |
| `igniter-lang/source/**` | 18 | Candidate language source inclusion. |
| `igniter-lang/handoff/**` | 15 | Candidate governance/handoff inclusion. |
| `igniter-lang/roles/**` | 15 | Candidate role/onboarding inclusion. |
| `igniter-lang/examples/**` | 12 | Candidate source/example inclusion; output artifacts need classification. |
| `igniter-lang/bin/**` | 3 | Candidate CLI/package inclusion with path review. |
| `igniter-lang/AGENTS.md` | 1 | Candidate onboarding inclusion. |
| `igniter-lang/README.md` | 1 | Candidate language repo README inclusion. |
| `igniter-lang/RELEASE_NOTES.md` | 1 | Candidate language release-note inclusion, not release authority. |
| `igniter-lang/igniter_lang.gemspec` | 1 | Candidate package metadata inclusion; URL/support review required. |
| `igniter-lang/out_run.log` | 1 | Exclude/quarantine. |
| `igniter-lang/tests/**` | 1 | Candidate test inclusion. |

## Generated / Archive / Quarantine Signals

Current tracked generated/proof signals:

| Signal | Current count | Stance |
| --- | ---: | --- |
| `out/**`, log, or `out_run` paths | 1162 | Exclude/quarantine by default; whitelist only reviewed durable evidence. |
| `.igapp` paths | 895 | Generated compiler artifacts; do not become public canon by copying. |
| JSON files | 1420 | Mixed source/proof/summary/manifest; classify by path and citation. |
| Archive paths | 752 | Audit value possible; quarantine path-heavy history before public migration. |
| Tracked root gem artifacts | 0 | No tracked root gem artifact in current file map. |
| Tracked local metadata | 1 | Exclude or archive-quarantine only by explicit later policy. |

Current ignored/local status facts:

- ignored/local status lines: `4486`;
- observed ignored/local classes include `.DS_Store`, `.claude/worktrees/**`,
  `.idea/**`, `.rubocop_cache/**`, lab build outputs, Rust targets, web build
  outputs, and node modules;
- ignored/local files are not dry-run migration input unless a later route
  explicitly whitelists a surface.

## Path And Link Hygiene Facts

Current scan for local absolute path or file-link patterns found:

| Category | Hit files | Stance |
| --- | ---: | --- |
| generated or proof output | 317 | Exclude/quarantine or regenerate with public-safe paths. |
| language-root review | 136 | Needs cleanup, rewrite, or archive exception before migration. |
| archive-quarantine | 29 | Historical only; not current docs authority. |
| ruby-framework review | 3 | Framework-side cleanup/cross-link issue. |
| total | 485 | Public migration blocker. |

The current hit count differs from the C1-D reported `499`, but both scans
confirm the same blocker: public-repo hygiene must be handled before migration.

## Target Repository State

Observed local target checkouts:

| Target | Origin remote | Branch/status | Tracked files | README | Current readiness fact |
| --- | --- | --- | ---: | --- | --- |
| `target:alexander-s-f/igniter-lang` | `https://github.com/alexander-s-f/igniter-lang.git` | `main...origin/main [ahead 1]` | 2 | `# igniter-lang` | Planning-ready container; local HEAD ahead by `.gitignore` commit. |
| `target:alexander-s-f/igniter-ruby` | `https://github.com/alexander-s-f/igniter-ruby.git` | `main...origin/main [ahead 1]` | 2 | `# igniter-ruby` | Planning-ready container; local HEAD ahead by `.gitignore` commit. |
| `target:alexander-s-f/igniter-lab` | `https://github.com/alexander-s-f/igniter-lab.git` | `main...origin/main [ahead 1]` | 2 | `# igniter-lab` | Planning-ready container; local HEAD ahead by `.gitignore` commit. |

Observed tracked files in each local target:

```text
.gitignore
README.md
```

Observed local-ahead diff in each target:

```text
.gitignore | 12 insertions
```

Interpretation:

- Target worktrees have no dirty file changes.
- Target local branches are ahead of `origin/main` by one `.gitignore` commit.
- This is readiness for planning, not authorization to push or populate target
  repositories.
- A later migration prep route must decide whether local target `.gitignore`
  commits should be pushed, rewritten, replaced, or ignored.

## Support-File Gaps

Root support files currently exist in `source:igniter`, but are framework/root
surfaces unless later classified:

- `LICENSE.txt`
- `CODE_OF_CONDUCT.md`
- `.gitignore`
- `Gemfile`
- `Gemfile.lock`
- `Rakefile`
- `.rubocop.yml`
- `igniter.gemspec`
- root `README.md`, `AGENTS.md`, `CHANGELOG.md`, `CLAUDE.md`

Language-root support gaps remain:

| Needed surface | Current `igniter-lang/**` state | Risk |
| --- | --- | --- |
| license | missing | public repo/package gap unless copied or policy-deferred. |
| code of conduct | missing | public repo governance gap unless copied or policy-deferred. |
| `.gitignore` | missing under `igniter-lang/**` | target has minimal local `.gitignore`, but language-specific ignore policy is not reviewed. |
| task/dependency files | missing `Gemfile` / `Rakefile` under `igniter-lang/**` | language repo development commands need a later task policy. |
| CI | absent | CI migration remains closed; future CI needs separate design. |
| package metadata | `igniter-lang/igniter_lang.gemspec` exists | monorepo URL/source metadata requires review before split/package claim. |

## Docs And Link Rewrite Risks

Current risks before public migration:

- `igniter-lang/**` docs may contain monorepo-relative paths that break when
  `igniter-lang/` becomes repository root.
- root/framework docs reference Igniter-Lang as framework cross-link context and
  must not become language authority by copying.
- package docs reference Igniter-Lang concepts in framework-package context and
  need cross-link hygiene, not automatic migration.
- path-heavy proof/archive/output files need archive-quarantine or rewrite
  policy before public exposure.
- target README files are placeholders and do not yet carry support-file,
  package, or authority wording.

## Lab Frontier Facts

`playgrounds/igniter-lab/**` remains read-only frontier signal. Observed
surfaces include:

- `igniter-compiler/**`;
- `igniter-vm/**`;
- `igniter-runtime/**`;
- `igniter-stdlib/**`;
- `igniter-tbackend/**`;
- `igniter-machine/**`;
- `igniter-ide/**`;
- `igniter-jetbrains-plugin/**`;
- `igniter-design-system/**`;
- `igniter-apps/**`;
- `lab-docs/**`;
- `.agents/**`;
- build/local surfaces including `target/**`, `node_modules/**`, `.svelte-kit`,
  `build/**`, `.gradle/**`, `.idea/**`, and proof `out/**`.

Current source-root tracked lab count is `0` for nested lab content and `1` for
`playgrounds/README.md`. Lab migration/intake remains separate and closed.

## Compact Current / Target Facts Matrix

| Area | Current fact | C4-A implication |
| --- | --- | --- |
| Dry-run proof | C1-D complete enough for split-map evidence, not migration. | Accept evidence only. |
| Source tracked map | `5460` tracked files; `3976` under `igniter-lang/**`. | Refresh file map before any migration auth. |
| Generated artifacts | `1162` output/log, `895` `.igapp`, `1420` JSON, `752` archive. | Require quarantine/exclude/whitelist policy. |
| Path hygiene | Current scan finds `485` hit files. | Public migration blocker. |
| Target repos | All three local targets track only `.gitignore` and `README.md`. | Planning-ready containers, not populated migration targets. |
| Target parity | All three targets are `ahead 1` locally. | Decide target baseline before push/migration. |
| Support files | Language root lacks license, code of conduct, task files, CI policy. | Open support-file prep before migration auth. |
| Lab | Nested/frontier, not source-root tracked. | Keep separate; no lab canon. |
| Framework | Root/packages/framework surfaces remain retained. | No framework-to-language transfer. |

## Blockers And Risks For C4-A

| Risk / blocker | Current evidence | Recommendation |
| --- | --- | --- |
| Public path leakage | 485 current local-path/file-link hit files. | Open path-hygiene/link-rewrite prep. |
| Generated artifact overclaim | `out/**`, `.igapp`, JSON, and archive counts remain high. | Classify exclude/quarantine/whitelist before migration. |
| Support-file incompleteness | Language root lacks license, code of conduct, task files, CI, language `.gitignore`. | Resolve support-file policy before migration. |
| Target baseline drift | Target local branches are ahead of origin by `.gitignore`. | Decide target baseline before any push/copy. |
| Package metadata drift | `igniter_lang.gemspec` still needs split URL/source review. | Keep package/release closed. |
| Lab canon drift | Lab is nested/frontier and build-heavy. | Keep out of language split; separate lab route only. |
| Framework authority leakage | Root docs/packages mention language concepts. | Keep framework surfaces retained/cross-linked. |
| History method undecided | No migration method authorized. | Compare copy/subtree/filter-repo only after hygiene prep. |

## Explicit Answers

### Are target repos ready?

They are ready as minimal planning containers only. Each local target tracks
`.gitignore` and `README.md`; each is locally ahead of `origin/main` by one
`.gitignore` commit. No target repo is ready for accepted migration population
without a later baseline decision.

### Does current source inventory preserve C1-D shape?

Yes. Counts moved by one tracked file, but the ownership split remains the same:
`igniter-lang/**` is the language-root candidate, root/packages are Ruby
framework retention, and lab remains frontier.

### Are generated artifacts safe to migrate as-is?

No. They need quarantine, exclusion, or explicit whitelist policy first.

### Are local absolute path and `file://` risks resolved?

No. Current scan still finds hundreds of hit files.

### Are support files complete for the future language repo?

No. License, code of conduct, ignore policy, task/dependency files, CI policy,
and package metadata all need prep.

### Does this facts packet authorize migration?

No. Migration, history rewrite, remote push, target population, package/CI
changes, release, public claims, authority transfer, and lab canon remain
closed.

## C4-A Recommendation

Recommend C4-A:

```text
ACCEPT: C2-P1 current-target facts packet as verified evidence
ACCEPT: C1-D split-map shape remains valid
HOLD: physical migration, history rewrite, target population, remote push
OPEN NEXT: support-file / path-hygiene / link-rewrite prep route
REQUIRE: refreshed file-map count before any migration authorization
REQUIRE: target baseline decision for local ahead .gitignore commits
KEEP: candidate:igniter-archive as archive-quarantine bucket, not repo
KEEP: lab-frontier outside language split
KEEP: package/CI/release/public claims closed
```

Suggested next route remains:

```text
S3-R257-C1-D
igniter-lang-repository-split-support-file-path-hygiene-prep-v0
```
