# Stage 3 Round 256 Status Curation v0

Card: `S3-R256-C5-S`  
Skill: IDD Agent Protocol  
Agent: Status Curator  
Role: `status-curator`  
Track: `stage3-round256-status-curation-v0`  
Route: SUMMARY  
Status: done / accepted  
Date: 2026-06-06

## Summary

R256 accepts the repository split dry-run file map as split-map evidence only.
It does not authorize physical migration, history rewrite, target repository
population, remote push, package/CI/release changes, archive repo creation,
public claims, framework-to-language authority transfer, or lab canon.

The accepted Main Line route is `S3-R257-C1-D`
`igniter-lang-repository-split-support-file-path-hygiene-prep-v0`: support-file,
path-hygiene, generated-artifact, target-baseline, and link-rewrite prep with no
live migration.

Forms import hiding/overriding remains deferred behind split prep unless that
route pauses. With split prep continuing, carry forms to `S3-R258-C1-A` or next
available, and PROP-039 proof-local fixtures to `S3-R259-C1-A` or later.

## Outcome Table

| Card | Artifact | Status | Notes |
| --- | --- | --- | --- |
| S3-R256-C1-D | `igniter-lang-repository-split-dry-run-file-map-proof-v0.md` | dry-run complete / migration held | Initial tracked split map produced; no migration/copy/history rewrite/remote/package/CI/release commands run. |
| S3-R256-C2-P1 | `igniter-lang-repository-split-dry-run-current-target-facts-v0.md` | facts-only / no migration authority | Current tracked count, generated/path signals, path-hygiene hits, target repo baselines, and support-file gaps verified. |
| S3-R256-C3-X | `igniter-lang-repository-split-dry-run-file-map-pressure-v0.md` | conditional accept | Accepts evidence but blocks migration authorization pending refreshed mutually exclusive buckets and hygiene prep. |
| S3-R256-C4-A | `igniter-lang-repository-split-dry-run-file-map-decision-v0.md` | accepted / route support-file path-hygiene prep next | Accepts C1/C2/C3 evidence, preserves closed surfaces, and opens R257 split-prep route. |
| S3-R256-C5-S | this track | done | Compact route/status delta recorded. |

## Destination Buckets

| Bucket | Status |
| --- | --- |
| `language-root` | Accepted as candidate future language repo content, centered on `igniter-lang/**`, pending final mutually exclusive dispositions. |
| `ruby-framework` | Accepted as framework-owned retention / future Ruby umbrella content. |
| `lab-frontier` | Accepted as separate frontier content; not initial language split content and not canon. |
| `archive-quarantine` | Accepted as a bucket only for historical/generated/path-heavy/mixed/stale material; no archive repo creation. |
| `exclude` | Required for generated/local/build/log/proof-output surfaces not accepted as source or durable audit material. |

## Archive / Quarantine

`candidate:igniter-archive` remains an archive-quarantine bucket, not a public
archive repository. Material in this bucket must be sanitized, labeled, or
explicitly accepted before any public exposure.

Current risk signals accepted by R256:

- `out/**` / log signals: 1162
- generated `.igapp` signals: 895
- JSON summary signals: 1420
- archive signals: 752
- current path/link hygiene hit files: 485

## Migration / Target Status

Closed:

- physical migration;
- history rewrite;
- `git subtree split`;
- `git filter-repo`;
- copying into target repos as accepted migration;
- target repository population;
- remote push;
- package, CI, release, version, tag, sign, or deploy changes;
- public/stable/production/release/performance/certification/portability claims.

Target repos remain planning containers only. The local targets are clean but
each is ahead of origin by one `.gitignore` commit; a target-baseline decision
is required before any push or population. Migration method is not selected.

## Blockers / Prep Requirements

Before any migration authorization review:

- refresh the tracked file-map count;
- make bucket dispositions mutually exclusive;
- resolve path/link hygiene or quarantine historical hits;
- decide generated-artifact exclude/quarantine/whitelist handling;
- settle support files: license, code of conduct, language `.gitignore`, task
  or dependency files, CI policy, and package metadata;
- decide target repo baseline for the local `.gitignore` commits;
- select migration method separately, if migration ever opens.

## Exact Next Route

Open:

```text
Card: S3-R257-C1-D
Track: igniter-lang-repository-split-support-file-path-hygiene-prep-v0
Route: UPDATE
Depends on:
- S3-R256-C5-S
```

Route type:

```text
design/docs-prep/proof-local hygiene prep / no live migration
```

Fallback only if split prep pauses:

```text
Card: S3-R257-C1-A
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route type: proof-local lab compiler authorization review
```

Because split prep continues, carry forms import hiding/overriding proof to
`S3-R258-C1-A` or next available, and PROP-039 proof-local fixtures to
`S3-R259-C1-A` or later.

## Closed Surfaces

Closed:

- code edits and live implementation;
- repository migration;
- history rewrite;
- target population;
- remote push;
- package rename, gemspec/package/CI changes, release execution;
- archive repo creation;
- public claims;
- framework-to-language authority transfer;
- lab canon or lab intake;
- runtime / API / CLI / package widening;
- public runtime support;
- Reference Runtime support;
- stable API;
- production readiness;
- Spark integration;
- public demo or public performance claims;
- official/reference status;
- alternative certification;
- portability guarantees.
