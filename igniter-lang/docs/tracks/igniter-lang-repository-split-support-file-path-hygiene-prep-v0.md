# Igniter Lang Repository Split Support-File / Path-Hygiene Prep v0

Card: `S3-R257-C1-D`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-support-file-path-hygiene-prep-v0`  
Route: `UPDATE`  
Status: `prep-designed / migration-held / facts-review-required`  
Date: 2026-06-06

Depends on:

- `S3-R256-C5-S`

---

## Decision Frame

R256 accepted the repository split dry-run file map as split-map evidence only.
It kept physical migration, history rewrite, target repository population,
remote push, package/CI/release changes, archive repo creation, public claims,
framework-to-language authority transfer, and lab canon closed.

R257 converts the R256 blockers into a bounded migration-readiness prep packet.
This document does not rewrite files, copy files into target repositories, run
migration commands, or authorize any public authority. It defines the support
file, path/link hygiene, generated-artifact, archive/quarantine, target
baseline, and migration-method prerequisites that C2-P1 and C3-X should verify
before C4-A chooses the next route.

Repository labels used in this document:

```text
source:igniter
target:alexander-s-f/igniter-lang
target:alexander-s-f/igniter-ruby
target:alexander-s-f/igniter-lab
candidate:igniter-archive
```

No migration, history rewrite, target population, remote, package, CI, release,
or archive-repo command was run.

---

## Prep Verdict

The support-file/path-hygiene prep is design-ready, but not migration authority.

Recommendation to C4-A:

```text
accept this prep packet if C2-P1 confirms the facts and C3-X finds no wording
or authority blockers;
keep physical migration, target population, history rewrite, and remote push
closed now;
allow a future migration authorization review to open next only as a gate,
not as live migration;
keep candidate:igniter-archive as an archive-quarantine bucket;
keep lab-frontier outside the language split;
defer forms import hiding/overriding while split migration prep continues;
defer PROP-039 proof-local fixtures behind the split and forms sequence.
```

The prep can be sufficient to open a future migration authorization review, but
only after C2-P1 validates the current facts and C3-X pressure-review accepts
the bucket, hygiene, support-file, target-baseline, and closed-surface wording.
It is not sufficient to execute migration directly.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round256-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-decision-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-proof-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-current-target-facts-v0.md`
- `igniter-lang/docs/discussions/igniter-lang-repository-split-dry-run-file-map-pressure-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R257.md`
- source tracked-file inventory;
- source root support files;
- source `.gitignore`;
- source `igniter-lang/**`;
- source root Ruby Framework surfaces as read-only ownership context;
- source `packages/**` as read-only framework context;
- source `playgrounds/README.md`;
- source `playgrounds/igniter-lab/**` as read-only frontier signal;
- target repository baselines as read-only planning facts.

---

## Refreshed Inventory Summary

Current tracked inventory:

| Source group | Tracked files | Prep stance |
| --- | ---: | --- |
| Total tracked files | 5464 | Current snapshot for R257 prep only. |
| `igniter-lang/**` | 3980 | Candidate language-root source, with generated/archive exclusions. |
| `packages/**` | 833 | Ruby framework / umbrella package retention. |
| root `examples/**` | 339 | Ruby framework examples. |
| root `spec/**` | 175 | Ruby framework tests. |
| root `docs/**` | 59 | Framework docs / cross-link context. |
| `.agents/**` | 47 | Framework/Ruby-lane operating evidence, not language authority. |
| root `lib/**` | 13 | Ruby framework implementation. |
| root files | 12 | Support-file classification required. |
| `playgrounds/**` tracked | 1 | `playgrounds/README.md`; nested lab remains frontier. |

Current `igniter-lang/**` groups:

| Group | Tracked files | Prep stance |
| --- | ---: | --- |
| `igniter-lang/docs/**` | 2204 | Candidate governance/history, with archive/path review. |
| `igniter-lang/experiments/**` | 1274 | Candidate proof-source/history; generated outputs need disposition. |
| `igniter-lang/out/**` | 386 | Exclude by default. |
| `igniter-lang/lib/**` | 24 | Candidate language implementation. |
| `igniter-lang/fixtures/**` | 23 | Candidate fixtures after generated-artifact review. |
| `igniter-lang/source/**` | 18 | Candidate language sources. |
| `igniter-lang/handoff/**` | 15 | Candidate governance/handoff. |
| `igniter-lang/roles/**` | 15 | Candidate role/onboarding. |
| `igniter-lang/examples/**` | 12 | Candidate examples, outputs excluded/quarantined. |
| `igniter-lang/bin/**` | 3 | Candidate CLI/package surface, with metadata review. |
| root files under `igniter-lang/` | 5 | README, AGENTS, release notes, gemspec, and one log candidate. |

Current generated/proof signals:

| Signal | Current count | Prep stance |
| --- | ---: | --- |
| `out/**`, log, or `out_run` paths | 1162 | Exclude/quarantine by default. |
| `.igapp` paths | 895 | Generated compiler artifacts; do not migrate as living source. |
| JSON files | 1420 | Mixed source/proof/summary/manifest; classify by path and citation. |
| Archive paths | 756 | Quarantine unless explicitly accepted as public history. |
| Tracked root gem artifacts | 0 | No tracked root gem artifact. |
| Tracked local metadata | 0 | No tracked local metadata in current count. |

---

## Mutually Exclusive Destination Disposition Model

This prep model converts R256's overlapping candidate buckets into mutually
exclusive migration dispositions. Counts are a current planning snapshot, not
migration output:

| Disposition | Current count | Rule |
| --- | ---: | --- |
| `language-root` | 2777 | Current language source/docs/governance surfaces after removing default exclude/quarantine candidates. |
| `ruby-framework` | 1479 | Root framework docs/code/examples/packages/tests/support files. |
| `lab-frontier` | 1 | Tracked playground index only; nested lab remains separate frontier. |
| `archive-quarantine` | 820 | Historical, path-heavy, generated-proof, mixed-authority, or review-required material. |
| `exclude` | 387 | Default generated/local output exclusions, especially living output/log surfaces. |
| `whitelist` | 0 | Empty by default; C2-P1 may identify specific durable proof artifacts if needed. |

### Disposition Rules

| Surface | Disposition |
| --- | --- |
| `igniter-lang/lib/**`, `bin/**`, `source/**`, `fixtures/**`, `tests/**` | `language-root`, unless a file is generated/path-heavy. |
| `igniter-lang/docs/spec/**`, `docs/proposals/**`, `docs/cards/**`, `docs/tracks/**`, `docs/gates/**`, `docs/discussions/**` | `language-root`, with link/path hygiene review. |
| `igniter-lang/docs/archive/**`, stale reports/reviews, path-heavy historical packets | `archive-quarantine` by default. |
| `igniter-lang/experiments/**` | split by file: source/proof scripts may be `language-root`; generated output and receipts are `archive-quarantine` or `exclude`. |
| `igniter-lang/out/**`, `out_run`, logs, generated `.igapp` outputs | `exclude` by default unless C4-A whitelists durable evidence. |
| root `packages/**`, root framework `lib/**`, root `examples/**`, `spec/**`, root `docs/**` | `ruby-framework`. |
| `playgrounds/igniter-lab/**` | `lab-frontier`, not initial language split content and not canon. |

---

## Support-File Matrix

| Surface | Current fact | Prep recommendation |
| --- | --- | --- |
| License | Present at source root, absent under `igniter-lang/`. | Copy or synthesize language repo license in a future migration/prep route; do not copy blindly without owner wording. |
| Code of conduct | Present at source root, absent under `igniter-lang/`. | Copy or synthesize for target language repo, or explicitly defer with public-governance rationale. |
| `.gitignore` | Present at source root; absent under `igniter-lang/`; target repos have minimal baselines. | Rewrite language-specific ignore file; do not reuse root ignore wholesale. |
| Task/dependency files | Root `Gemfile`, lockfile, `Rakefile`, and lint config exist; language root lacks them. | Synthesize minimal language repo task policy or defer package/dev commands to a later package route. |
| CI policy | No accepted language CI migration. | Keep CI closed; document whether CI is absent, deferred, or future-route only. |
| Package metadata | `igniter-lang/igniter_lang.gemspec` exists. | Review URLs, paths, files list, release wording, and package claims in a future package/metadata route; no package change in R257. |
| `README.md` | Root README is framework-owned; language README exists. | Keep language README as candidate language root; root README remains framework/cross-link context. |
| `AGENTS.md` | Root and language AGENTS exist. | Keep language AGENTS with language repo; root AGENTS remains framework/cross-project context. |
| Current status / release notes | Language current status and release notes exist. | Keep as governance/history, but release wording remains non-authorizing. |

---

## Path / Link Hygiene Summary

Current local path and local file-link hit scan:

| Category | Hit files | Prep stance |
| --- | ---: | --- |
| generated or output | 317 | Exclude or regenerate with public-safe paths. |
| language-root review | 141 | Rewrite, quarantine, or explicitly label as historical before public migration. |
| archive-quarantine | 29 | Keep historical only; not current authority. |
| root/support/other | 11 | Keep out of language root or clean separately. |
| ruby-framework review | 3 | Framework-side cleanup/cross-link issue. |
| total | 501 | Public migration blocker until dispositioned. |

Markdown link review candidates under `igniter-lang/**`:

| Area | Candidate files |
| --- | ---: |
| total markdown link candidates | 25 |
| `docs/tracks/**` | 14 |
| `docs/archive/**` | 3 |
| `docs/inbox/**` | 2 |
| other language doc areas | 6 |

Prep stance:

- New public-facing docs must avoid local absolute paths and local file links.
- Historical hits should be quarantined or rewritten, not silently copied.
- Monorepo-relative links should be rewritten relative to the future language
  repo root or converted to explicit cross-repo links in a later docs sync.
- Generated receipts that contain local environment details should not migrate
  as living source.

---

## Generated Artifact Disposition Matrix

| Artifact class | Default disposition | Notes |
| --- | --- | --- |
| `out/**` | `exclude` | Generated output, not living source. |
| `.igapp` | `exclude` or `archive-quarantine` | Generated compiler artifacts; may be cited as proof history only after review. |
| Logs | `exclude` | Runtime/local proof logs should not become public source. |
| JSON summaries | path-based | Source manifests/spec examples may stay; generated summaries need whitelist or quarantine. |
| Archive snapshots | `archive-quarantine` | Historical value possible, but not current authority. |
| Local metadata | `exclude` | No default migration. |
| Build outputs | `exclude` | No default migration. |
| Durable proof scripts/fixtures | `language-root` or `whitelist` | Only when source-like, cited, and path-clean. |

Whitelist policy:

```text
Default whitelist is empty.
C2-P1 may propose explicit durable proof artifacts, but C4-A must accept them.
```

---

## Target Baseline Recommendation

Current target repositories are planning containers only:

| Target | Tracked files | Branch status | Prep stance |
| --- | ---: | --- | --- |
| `target:alexander-s-f/igniter-lang` | 2 | local branch ahead by one ignore-file commit | Do not push yet; decide baseline in migration authorization review. |
| `target:alexander-s-f/igniter-ruby` | 2 | local branch ahead by one ignore-file commit | Do not push yet; preserve as planning fact. |
| `target:alexander-s-f/igniter-lab` | 2 | local branch ahead by one ignore-file commit | Do not push yet; lab migration requires separate route. |

Recommendation:

```text
keep local target baselines closed to push;
record them as planning containers;
decide later whether to preserve, replace, or regenerate target ignore files;
do not populate targets from R257.
```

---

## Archive / Quarantine Stance

`candidate:igniter-archive` should remain a bucket, not a repository.

Reasons:

- R257 still sees many path-heavy and generated/history candidates.
- A public archive repo would create public exposure before sanitization.
- Archive material needs explicit historical-evidence wording and path hygiene
  before any public route.

Future archive repo decision may open only after:

- archive candidates are listed;
- local path and local file-link risks are cleaned or intentionally retained
  with private/public stance;
- public history wording is approved;
- migration authority remains separate from archive authority.

---

## Migration-Method Prerequisite Matrix

| Method | Status | Prerequisites |
| --- | --- | --- |
| Copy-first | Possible later | Clean file map, support files, target baseline, explicit exclude/quarantine list. |
| Subtree split | Possible later | Path-clean `igniter-lang/**`, generated output exclusions, history/audit policy. |
| Filter-repo | Possible later from temp clone only | Strongest authorization, exact command plan, rollback plan, no target pollution. |
| Archive/quarantine | Required | Final bucket list and public/private stance. |
| Hold | Valid | Use if path/support-file/generated blockers remain unresolved. |

Recommended method posture:

```text
do not select a method in R257;
allow C4-A to route a future migration authorization review if C2/C3 accept prep;
keep live migration commands closed until that future review explicitly decides.
```

---

## Explicit Answers

### Is support-file/path-hygiene prep complete enough to open a future migration authorization review?

Conditionally yes, if C2-P1 verifies the facts and C3-X accepts the boundary.
It is not complete enough to execute migration.

### Are final bucket dispositions mutually exclusive?

The proposed disposition model is mutually exclusive for planning:
`language-root`, `ruby-framework`, `lab-frontier`, `archive-quarantine`,
`exclude`, and `whitelist`. C2-P1 should verify whether current files fit those
rules without overlap.

### Does `igniter-lang/**` remain the language-root candidate?

Yes. `igniter-lang/**` remains the candidate language root, but generated,
archive, output, and path-heavy subsets must be excluded, quarantined, or
whitelisted before public migration.

### Should root support files be copied, synthesized, linked, rewritten, or deferred?

Mixed:

- license and code of conduct: copy or synthesize after owner wording review;
- `.gitignore`: rewrite for the language repo;
- task/dependency files: synthesize minimally or defer;
- CI: defer unless separately authorized;
- package metadata: review later, no package change in R257;
- root README/AGENTS/docs: keep framework-owned or cross-link-only.

### Should target repo ignore-file baselines be pushed, replaced, preserved, or ignored later?

Do not push in R257. A future migration authorization review should decide
whether to preserve, replace, or regenerate the target baseline files.

### Do local path or local file-link references remain public blockers?

Yes. Current scan still finds 501 hit files. They remain public migration
blockers until rewritten, excluded, quarantined, or explicitly whitelisted.

### Should generated artifacts be excluded, quarantined, or whitelisted?

Exclude by default. Quarantine historical/proof material when audit value is
real. Whitelist only specific durable artifacts accepted by a later decision.

### Does `candidate:igniter-archive` stay a bucket or need a future repo decision?

It stays a bucket now. A future repo decision may open later, but R257 should
not create or authorize an archive repository.

### May physical migration open next?

No. A future migration authorization review may open next if C2/C3/C4 accept
this prep, but live migration must wait.

### Does forms import hiding/overriding remain deferred?

Yes. If split migration prep continues, forms import hiding/overriding remains
deferred to `S3-R259-C1-A` or the next available technical slot. If C4-A pauses
split migration prep, forms may become the next technical route.

---

## Exact C4-A Recommendation

Recommend C4-A:

```text
ACCEPT: R257 support-file/path-hygiene prep if C2-P1 and C3-X confirm facts.
KEEP CLOSED: physical migration, target population, history rewrite, remote push.
OPEN NEXT: future migration authorization review only as a gate, not execution.
KEEP: candidate:igniter-archive as archive-quarantine bucket only.
KEEP: lab-frontier separate and non-canonical.
DEFER: forms import hiding/overriding while split prep continues.
DEFER: PROP-039 proof-local fixtures behind split/forms sequencing.
CLOSED: package/CI/release/public/stable/production/performance/certification/portability claims.
```

Suggested next route if accepted:

```text
Card: S3-R258-C1-A
Track: igniter-lang-repository-split-physical-migration-authorization-review-v0
Route type: future migration authorization review / no live migration by default
```

Fallback if C4-A holds migration readiness:

```text
Card: S3-R258-C1-D
Track: igniter-lang-repository-split-additional-file-map-hygiene-prep-v0
Route type: additional prep / facts-refresh / no live migration
```

Fallback if C4-A pauses split work:

```text
Card: S3-R258-C1-A
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route type: proof-local technical authorization review
```

No R257 decision should authorize live migration.
