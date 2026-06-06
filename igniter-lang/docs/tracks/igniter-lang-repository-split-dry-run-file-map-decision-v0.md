# Igniter Lang Repository Split Dry-Run File-Map Decision v0

Card: `S3-R256-C4-A`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-dry-run-file-map-decision-v0`  
Route: `UPDATE`  
Status: `accepted / route-support-file-path-hygiene-prep-next`  
Date: 2026-06-06

Depends on:

- `S3-R256-C1-D`
- `S3-R256-C2-P1`
- `S3-R256-C3-X`

---

## Decision

Decision:

```text
accept the R256 dry-run file-map proof as split-map evidence
accept the current/target facts packet as verified evidence
accept the pressure verdict blockers
keep physical migration, history rewrite, target population, and remote push closed
route support-file / path-hygiene / link-rewrite prep next
keep candidate:igniter-archive as archive-quarantine bucket for now
keep lab-frontier outside the language split
defer forms import hiding/overriding until after split prep unless migration prep pauses
defer PROP-039 proof-local fixtures behind forms or later
```

The dry-run proves that the ownership split is coherent, but it also proves
that public migration is not ready. The blockers are bounded and actionable:
refresh the file map, make final buckets mutually exclusive, quarantine or
rewrite path-heavy material, settle support files, and decide the target-repo
baseline before any migration authorization review.

This decision does not authorize live migration, `git subtree split`,
`git filter-repo`, history rewrite, target-repo copying, remote push,
package/CI/release changes, public claims, framework-to-language authority
transfer, lab canon, runtime/API/CLI/package changes, or implementation.

---

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-proof-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-current-target-facts-v0.md`
- `igniter-lang/docs/discussions/igniter-lang-repository-split-dry-run-file-map-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round255-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-decision-v0.md`

No migration, target population, history rewrite, remote push, package, CI, or
release command was run for this decision.

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Dry-run file-map proof | Accepted as split-map evidence. |
| Current/target facts packet | Accepted as verified evidence. |
| Pressure verdict | Accepted with exact blockers. |
| `language-root` bucket | Accepted as candidate future language repo content, pending final mutually exclusive dispositions. |
| `ruby-framework` bucket | Accepted as framework-owned retention / future Ruby umbrella content. |
| `lab-frontier` bucket | Accepted as separate frontier content; not initial language split content. |
| `archive-quarantine` bucket | Accepted as bucket only; no archive repo creation. |
| `exclude` bucket | Required for generated, local, build, log, and proof-output surfaces not accepted as source/audit. |
| Support-file status | Incomplete; license, code of conduct, ignore policy, task/dependency files, CI policy, and package metadata require prep. |
| Generated artifact status | Not migration-ready; requires exclude/quarantine/whitelist decisions. |
| Local path / file-link hygiene | Blocking risk remains; hundreds of hit files require rewrite, quarantine, or exclusion before public migration. |
| Target repo readiness | Targets are planning containers only; local target baselines require decision before push/population. |
| Migration-method status | Not selected; copy-first, subtree split, filter-repo, archive/quarantine, and hold remain later options. |
| Physical migration | Closed. |
| Remote push | Closed. |
| Forms post-R256 status | Deferred if split prep continues; may open only if migration prep pauses. |
| PROP-039 post-R256 status | Deferred behind forms or later. |
| Public/stable/production/release claims | Closed. |
| Performance/certification/portability claims | Closed. |

---

## Compact Destination Bucket Matrix

| Bucket | Accepted stance | Required before migration auth |
| --- | --- | --- |
| `language-root` | `igniter-lang/**` remains the candidate future language repo root. | Refresh tracked count, split generated/history material into explicit include, exclude, quarantine, or whitelist outcomes. |
| `ruby-framework` | Root framework docs/code/examples/packages/tests remain outside language authority. | Decide cross-links only; do not copy framework authority into language repo. |
| `lab-frontier` | Lab remains frontier evidence only and separate from initial language split. | Later lab migration/intake route required for any lab repo population. |
| `archive-quarantine` | Valid bucket for historical, generated, path-heavy, mixed-authority, or stale material. | Sanitize or explicitly label before any public exposure; no public archive repo yet. |
| `exclude` | Required bucket for local/editor/build/release/log/generated products not needed as source/audit. | Produce final exclusion list and whitelist exceptions before migration authorization. |

---

## Blockers Before Migration Authorization

| Blocker | Evidence status | Required follow-up |
| --- | --- | --- |
| File-map freshness | C2-P1 observed one tracked-file delta after C1-D. | Refresh tracked inventory in the prep route or before migration review. |
| Bucket non-overlap | Initial map is useful, but `language-root` still includes generated/quarantine candidates. | Produce mutually exclusive final dispositions. |
| Path hygiene | C2-P1 reports hundreds of local path/file-link hit files. | Rewrite, exclude, or archive-quarantine affected files. |
| Generated artifact drift | `out/**`, `.igapp`, logs, JSON summaries, archives, and proof outputs remain high-volume. | Classify by source/audit value and public-safety status. |
| Support files | Future language root lacks reviewed license, conduct, ignore, task/dependency, CI, and package metadata policy. | Decide copy, synthesize, rewrite, link, or defer. |
| Target baseline | Target repos are clean but locally ahead by minimal ignore-file commits. | Decide whether to push, replace, preserve, or ignore target baseline before migration. |
| Migration method | No method is selected or authorized. | Compare copy-first, subtree split, filter-repo, archive/quarantine, and hold after hygiene prep. |

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R257-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: igniter-lang-repository-split-support-file-path-hygiene-prep-v0
Route: UPDATE
Depends on:
- S3-R256-C5-S
```

Route type:

```text
design/docs-prep/proof-local hygiene prep / no live migration
```

Expected write scope:

- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-prep-v0.md`
- optional bounded proof-local machine-readable artifacts under
  `igniter-lang/docs/tracks/repository-split-support-file-path-hygiene-v0/`

Expected read scope:

- R255 and R256 split boundary/proof/facts/pressure/decision artifacts;
- source repository tracked-file inventory;
- `igniter-lang/**` candidate language-root surfaces;
- root framework support files as read-only ownership context;
- target repository local checkouts as read-only baseline facts;
- lab frontier surfaces as read-only exclusion/context facts.

Required output expectations:

- refreshed tracked-file count;
- mutually exclusive destination dispositions;
- support-file copy/synthesize/rewrite/defer matrix;
- path/link hygiene matrix with no local path leakage in new docs;
- generated artifact exclude/quarantine/whitelist matrix;
- target baseline recommendation;
- migration-method prerequisites, still without authorizing migration.

Closed surfaces for `S3-R257-C1-D`:

- live migration;
- `git subtree split`;
- `git filter-repo`;
- history rewrite;
- copying into target repos as accepted migration;
- remote push;
- package rename;
- gemspec/package/CI changes;
- release execution;
- public claims;
- framework-to-language authority transfer;
- lab canon;
- runtime/API/CLI/package widening;
- public runtime support;
- Reference Runtime support;
- stable API;
- production readiness;
- Spark integration;
- public demo;
- public performance claims;
- official/reference status;
- alternative certification;
- portability guarantees.

Fallback if C5-S pauses migration preparation:

```text
Card: S3-R257-C1-A
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route type: proof-local lab compiler authorization review
```

If split prep consumes R257, carry forms to `S3-R258-C1-A` or next available
and carry PROP-039 proof-local fixtures to `S3-R259-C1-A` or later.

---

## Explicit Answers

### Is the dry-run file-map proof accepted?

Yes. It is accepted as split-map evidence.

### Is it sufficient to open a future migration authorization review?

Not directly. It is sufficient to justify a future migration authorization
review after support-file, path-hygiene, generated-artifact, target-baseline,
and mutually exclusive bucket prep.

### May physical migration open next?

No. Physical migration must wait.

### Does remote push remain closed?

Yes. Remote push remains closed.

### Should `candidate:igniter-archive` open as a repo decision?

No. It stays an archive-quarantine bucket for now. A public archive repo
decision may open later only after sanitization and public-history wording are
designed.

### Does forms import hiding/overriding open next?

No, not if migration preparation continues. It remains the fallback technical
route if C5-S pauses split prep, otherwise it moves to the next available
technical slot after split prep.

### Do PROP-039 proof fixtures remain deferred?

Yes. PROP-039 proof fixtures remain deferred behind forms or later.

### Are public/stable/production/release/performance/certification/portability claims closed?

Yes. All remain closed.

---

## Compact Decision Summary

```text
ACCEPT: R256 dry-run file-map proof and current/target facts.
HOLD: physical migration, history rewrite, target population, remote push.
OPEN NEXT: S3-R257-C1-D support-file / path-hygiene / link-rewrite prep.
KEEP: candidate:igniter-archive as archive-quarantine bucket only.
KEEP: lab-frontier separate and non-canonical.
DEFER: forms import hiding/overriding unless split prep pauses.
DEFER: PROP-039 proof-local fixtures behind forms or later.
CLOSED: package/CI/release/public/stable/production/performance/certification/portability claims.
```
