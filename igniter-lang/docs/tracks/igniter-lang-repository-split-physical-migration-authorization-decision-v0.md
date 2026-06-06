# Igniter Lang Repository Split Physical-Migration Authorization Decision v0

Card: `S3-R258-C4-A`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-physical-migration-authorization-decision-v0`  
Route: `UPDATE`  
Status: `conditional-accept / migration-held / route-additional-prep-next`  
Date: 2026-06-06

Depends on:

- `S3-R258-C1-A`
- `S3-R258-C2-P1`
- `S3-R258-C3-X`

---

## Decision

Decision:

```text
conditionally accept the R258 physical-migration authorization review as
blocker evidence and route-control evidence;
accept the C2-P1 facts packet as current-index blocker evidence;
accept the C3-X pressure verdict;
hold physical migration execution authorization;
hold target repository population;
hold remote push and target baseline push;
route additional current-index file-map and support-policy prep next;
do not open a migration execution authorization route yet.
```

The repository split direction remains accepted. `igniter-lang/**` remains the
candidate future language repository root. R258 proves that migration execution
is not ready: the current tracked index drifted, no final per-file disposition
artifact exists, support-file policy remains unresolved, path/link hygiene is
still a public blocker, generated artifacts remain exclude/quarantine by
default, and the target repository baselines remain planning facts only.

No live migration, target population, history rewrite, remote push, package,
CI, release, archive-repo, public-claim, framework-to-language authority
transfer, or lab-canon authority is authorized by this decision.

---

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-physical-migration-authorization-review-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-physical-migration-authorization-facts-v0.md`
- `igniter-lang/docs/discussions/igniter-lang-repository-split-physical-migration-authorization-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round257-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R258.md`

No migration, history rewrite, target population, remote push, package, CI,
release, archive-repo, or public-claim command was run for this decision.

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Authorization review status | Conditional accept as blocker evidence and route-control evidence only. |
| C2-P1 facts packet | Accepted; proves execution blockers remain. |
| C3-X pressure verdict | Accepted; requires R259 prep, not execution authorization. |
| Final per-file disposition status | Absent / blocker. No final current-index disposition artifact is accepted. |
| `language-root` status | `igniter-lang/**` remains candidate future language root, subject to exclude/quarantine/whitelist disposition. |
| `ruby-framework` status | Root framework docs, packages, examples, specs, and support files remain outside language authority. |
| `lab-frontier` status | Lab remains frontier evidence only and outside initial language split execution. |
| `archive-quarantine` status | Bucket only; archive repo creation remains closed. |
| `exclude` / whitelist status | Default exclude/quarantine accepted; explicit whitelist remains empty / not accepted. |
| Support-file status | Unresolved; license, conduct, language `.gitignore`, task/dependency files, CI posture, `.rubocop.yml`, README/AGENTS, and package metadata need disposition. |
| Generated artifact status | Unresolved; `out/**`, `.igapp`, logs, generated JSON, archives, and local metadata require exclude/quarantine/whitelist policy. |
| Local path / local file-link hygiene | Unresolved public blocker; C2-P1 reports broad local path/file-link and monorepo-link risks. |
| Target baseline status | Planning facts only; all three targets remain local-ahead planning containers with baseline decision unresolved. |
| Migration-method status | No method selected; copy-first, subtree split, filter-repo, archive/quarantine, and hold remain comparison candidates only. |
| Later execution route status | Held. May be reconsidered only after R259-style prep is accepted. |
| Physical migration status now | Closed. |
| Target population status now | Closed. |
| Remote push status now | Closed. |
| Forms post-R258 status | Deferred while split prep continues; carry to `S3-R260-C1-A` or next available. |
| PROP-039 post-R258 status | Deferred behind split/forms sequencing; carry to `S3-R261-C1-A` or later. |
| Public/stable/production/release claims | Closed. |
| Performance/certification/portability claims | Closed. |

---

## Blocker Matrix

| Blocker | Evidence | Decision |
| --- | --- | --- |
| Current-index drift | C1-A snapshot `5471` total / `3987` under `igniter-lang/**`; C2-P1 snapshot `5472` / `3988`. | Require regenerated current-index file map. |
| Missing final per-file map | C2-P1 found no final disposition artifact. | Block execution authorization. |
| Support-file policy unresolved | Language root lacks accepted policy for license, conduct, ignore, tasks, dependencies, CI, lint, and package metadata. | Route support-policy prep. |
| Path/link hygiene unresolved | C2-P1 records broad local path/file-link and monorepo-link risks. | Route rewrite/quarantine/exclude/non-public disposition plan. |
| Generated artifacts unresolved | Output, `.igapp`, JSON, archive, and local metadata signals remain high. | Keep default exclude/quarantine; require explicit whitelist if any. |
| Target baseline unresolved | Target repos are planning containers with local `.gitignore` commits ahead of origin. | Require preserve/replace/push-later/regenerate/discard proposal. |
| Package metadata unresolved | `igniter_lang.gemspec` remains monorepo-oriented. | Keep package/CI/release closed. |
| Archive repo risk | Archive candidates remain path-heavy and authority-mixed. | Keep `candidate:igniter-archive` as bucket only. |

---

## Next Route

Open next:

```text
Card: S3-R259-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: igniter-lang-repository-split-current-index-file-map-and-support-policy-prep-v0
Route: UPDATE
Depends on:
- S3-R258-C4-A
```

Route type:

```text
additional prep / current-index file-map materialization /
support-policy decision prep / no live migration
```

Allowed read scope:

- R255-R258 split boundary, dry-run, hygiene, authorization, facts, pressure,
  decision, and status artifacts;
- source tracked-file inventory;
- source root support files and `.gitignore`;
- source `igniter-lang/**`;
- source root Ruby Framework surfaces as read-only ownership context;
- source `packages/**` as read-only framework context;
- source `playgrounds/igniter-lab/**` as read-only frontier signal;
- target repositories as read-only baseline facts.

Allowed write scope:

- `igniter-lang/docs/tracks/igniter-lang-repository-split-current-index-file-map-and-support-policy-prep-v0.md`
- optional bounded artifacts under:
  `igniter-lang/docs/tracks/repository-split-current-index-file-map-and-support-policy-prep-v0/`

Permitted commands for R259:

- read-only inventory and hygiene commands such as `git ls-files`, `git status`,
  `git diff --name-only`, `rg`, `find`, `wc`, `sort`, and file reads;
- no copy/populate, no history rewrite, no push, no package, no CI, no release.

Required R259 outputs:

- regenerated current-index per-file disposition artifact;
- mutually exclusive buckets:
  - `language-root`;
  - `ruby-framework`;
  - `lab-frontier`;
  - `archive-quarantine`;
  - `exclude`;
  - explicit whitelist, empty or accepted;
- support-file copy/synthesize/rewrite/defer policy;
- path/link rewrite, quarantine, exclude, or non-public disposition plan;
- generated-artifact exclude/quarantine/whitelist policy;
- target baseline proposal for all three target repositories;
- migration-method comparison with exact future command boundaries;
- rollback/audit receipt shape for any later execution route;
- post-prep C4/C5 decision before execution authorization is reconsidered.

Forbidden commands and actions in R259:

- physical migration;
- target repository population;
- target baseline push;
- remote push;
- `git subtree split`;
- `git filter-repo`;
- history rewrite;
- package rename;
- gemspec/package/CI changes;
- release, version, tag, sign, or deploy commands;
- archive repo creation;
- public claims;
- framework-to-language authority transfer;
- lab canon.

---

## Deferred Routes

If split prep continues:

```text
S3-R259: repository split current-index file-map/support-policy prep
S3-R260 or next available: forms import hiding/overriding proof authorization review
S3-R261 or later: PROP-039 proof-local fixture continuation
```

If split work pauses instead, forms may open next as:

```text
Card: S3-R259-C1-A
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route type: proof-local technical authorization review
```

This decision does not choose that pause path.

---

## Explicit Answers

### Is the physical-migration authorization review accepted?

Yes, conditionally. It is accepted as blocker evidence and route-control
evidence only.

### May a later migration execution route open next?

No. A later execution authorization route remains held. R259 should be
additional current-index file-map and support-policy prep, not execution
authorization.

### Is physical migration authorized now?

No.

### Is remote push authorized now?

No.

### Is target population authorized now?

No.

### Does archive repo creation remain closed?

Yes. `candidate:igniter-archive` remains an archive-quarantine bucket only.

### Do package / CI / release changes remain closed?

Yes.

### Do target local baselines remain closed?

Yes. They may be analyzed and dispositioned in R259, but not pushed or used as
accepted target baselines in this card.

### Does forms import hiding/overriding open next?

No. It remains deferred while split prep continues. Carry forms to `S3-R260-C1-A`
or the next available technical route.

### Do PROP-039 proof fixtures remain deferred?

Yes. Carry PROP-039 proof-local fixtures to `S3-R261-C1-A` or later.

### Are public/stable/production/release/performance/certification/portability claims closed?

Yes. They remain closed.

---

## Compact Decision Summary

```text
CONDITIONAL ACCEPT: R258 physical-migration authorization review.
ACCEPT: C2 facts and C3 pressure as blocker evidence.
HOLD: migration execution authorization.
HOLD: target population and remote push.
HOLD: package/CI/release and archive repo creation.
OPEN NEXT: S3-R259-C1-D current-index file-map/support-policy prep.
DEFER: forms import hiding/overriding to R260 or next available.
DEFER: PROP-039 proof-local fixtures to R261 or later.
KEEP: framework outside language authority; lab frontier only.
KEEP CLOSED: public/stable/production/release/performance/certification/portability claims.
```
