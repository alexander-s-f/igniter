# S3-R257-C3-X External Pressure Verdict

Track: igniter-lang-repository-split-support-file-path-hygiene-pressure-v0  
Role: external-pressure-reviewer  
Route: UPDATE  
Date: 2026-06-06  
Depends on: S3-R257-C1-D, S3-R257-C2-P1

## Pressure Verdict

Verdict: CONDITIONAL ACCEPT, as support-file/path-hygiene prep evidence only.

R257 is complete enough to open a future physical-migration authorization review as a gate, but it is not complete enough to authorize migration, history rewrite, target population, remote push, package/CI/release changes, archive repo creation, public/stable claims, or lab canon.

C1-D stayed in prep/design territory and repeatedly held migration authority closed. C2-P1 correctly converted the prep into blocker evidence rather than execution permission. The strongest pressure risk is not overclaim inside R257; it is a later C4-A or R258 route reading "future migration authorization review" as permission to run migration commands. That reading must be blocked explicitly.

## Claim-Risk Notes

- Migration over-authorization: controlled in C1-D/C2-P1, but C4-A must state that R258, if opened, is authorization review only and no live migration by default.
- Support-file completeness: not yet migration-ready. License, code of conduct, `.gitignore`, task/dependency files, CI posture, and `igniter_lang.gemspec` URL/source/files/release wording still need explicit accept/copy/synthesize/defer decisions.
- Bucket exclusivity: C1-D gives a mutually exclusive planning model, but C2-P1 shows tracked counts moved from 5464 to 5466 and requires a regenerated current-index per-file map before migration authorization.
- Local path/link leakage: remains a public blocker. C2-P1 reports 487 broad public-migration hit files and 132 local absolute path/local file-link candidates; these need rewrite, quarantine, or explicit non-public disposition before public repo population.
- Generated artifact drift: `out/**`, logs, `.igapp`, generated JSON/summaries, and archive snapshots are correctly treated as exclude/quarantine/whitelist candidates, but the whitelist remains empty and must not be implied.
- Target baseline risk: target repos each have a local ahead `.gitignore` commit. This is a planning fact only, not push authority or a baseline selection.
- Archive/quarantine misuse: `candidate:igniter-archive` remains a bucket label only. It does not authorize archive repo creation or population.
- Framework-to-language transfer: root Ruby framework support files and package/task surfaces remain unresolved or framework-owned unless explicitly accepted into the language repo by a later gate.
- Lab-canon drift: lab/frontier material remains evidence only and outside language authority.
- Physical migration: still closed, including copy, subtree, filter-repo, history rewrite, target population, remote push, package, CI, release, and public claims.
- Post-R257 sequencing: clear enough if C4-A names the route order. If R258 is consumed by split migration authorization review, carry forms import hiding/overriding proof to R259 or next available and PROP-039 to R260 or later.

## Pressure Checks

- Prep complete enough for a future migration authorization review: yes, conditionally, only as a review gate.
- Final bucket dispositions mutually exclusive: acceptable as a planning model, but stale counts require regeneration before any migration decision.
- Support-file decisions explicit and bounded: partially. The unresolved set is named, but final dispositions are not yet accepted.
- Local path/file-link leakage: blocker remains live and correctly identified.
- Generated artifacts: safely categorized as exclude/quarantine/whitelist candidates; no generated artifact should become living source by default.
- Target baselines: treated as facts, not push authority.
- Archive/quarantine: correctly a bucket, not hidden repo creation.
- Lab: remains frontier evidence only.
- Framework surfaces: remain outside language authority unless later accepted.
- Forms and PROP-039: separable, but route numbering must be explicit after R257.

## Exact Recommendation To C4-A

Accept R257-C1-D and R257-C2-P1 as conditional prep/facts evidence.

Open next route only as:

`S3-R258-C1-A igniter-lang-repository-split-physical-migration-authorization-review-v0`

Required C4-A wording:

> R258 is an authorization review gate only. It does not authorize physical migration, history rewrite, target population, remote push, package/CI/release changes, archive repo creation, public/stable/runtime claims, or lab canon.

R258 must require, before any later execution route:

- regenerated current-index per-file disposition map;
- final mutually exclusive buckets, with whitelist explicitly empty or accepted;
- support-file decisions for license, code of conduct, `.gitignore`, task/dependency files, CI, and gemspec/package metadata;
- path/link rewrite or quarantine plan for local absolute paths, local file links, monorepo-relative links, and `igniter-lang/`-prefixed references;
- generated artifact exclude/quarantine/whitelist policy;
- target baseline decision for the ahead `.gitignore` commits;
- migration-method comparison without live commands;
- archive/quarantine as bucket only;
- lab-frontier and Ruby framework surfaces held outside language authority.

If C4-A does not want to open the migration authorization gate yet, redirect to:

`S3-R258-C1-D igniter-lang-repository-split-additional-file-map-hygiene-prep-v0`

If split work pauses instead, route forms next:

`S3-R258-C1-A contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0`

Default sequencing if split continues:

- R258: split physical-migration authorization review gate only;
- R259 or next available: forms import hiding/overriding proof authorization review;
- R260 or later: PROP-039 continuation.
