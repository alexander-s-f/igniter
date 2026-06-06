# Igniter-Lang Repository Split Current Surface Facts v0

Card: S3-R255-C2-P1  
Role: implementation-surface-surveyor  
Track: igniter-lang-repository-split-current-surface-facts-v0  
Route: UPDATE  
Status: facts-only / no migration authority  
Date: 2026-06-06

## Boundary

This packet records current repository split facts for the Igniter-Lang boundary.
It does not authorize migration, subtree/filter-repo work, package changes, CI
changes, releases, remote pushes, public claims, framework-to-language authority
transfer, or lab canon.

Write scope used by this card:

- `igniter-lang/docs/tracks/igniter-lang-repository-split-current-surface-facts-v0.md`

No code, runtime, package, release, CI, public docs, source fixtures, generated
artifacts, or playground files were edited.

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-and-migration-plan-v0.md`
- `igniter-lang/docs/tracks/stage3-round254-status-curation-v0.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/README.md`
- `igniter-lang/AGENTS.md`
- `igniter-lang/igniter_lang.gemspec`
- `README.md`
- `AGENTS.md`
- `Gemfile`, `Gemfile.lock`, `Rakefile`, `igniter.gemspec`
- `.gitignore`
- root `lib/**`, `packages/**`, `examples/**`, `docs/**`, `spec/**`, `sig/**` inventory
- `igniter-lang/**` inventory
- `playgrounds/igniter-lab/**` inventory as read-only frontier/lab signal

## Current Facts

- R254 status curation names S3-R255 as the next Main Line repository split
  boundary route.
- S3-R255 is framed as repository split boundary work before any physical
  migration.
- The C1-D boundary output recommends `design-ready / migration-held`.
- The named future language repository target is `alexander-s-f/igniter-lang`.
- `igniter-lang/**` is the candidate future language root, subject to dry-run
  file-map classification.
- Root Ruby framework/package/runtime/app-facing surfaces remain framework
  territory unless a later route explicitly authorizes relocation.
- `playgrounds/igniter-lab/**` is private frontier/lab evidence and is not
  automatically language-repo canon or split content.
- The root repository currently has no `.github/**` directory.
- `.gitignore` ignores `/playgrounds/*` except `!/playgrounds/README.md`,
  plus common generated/local artifacts such as `.bundle`, `coverage`, `doc`,
  `pkg`, `*.gem`, `tmp`, `.idea`, and `.rubocop-*`.
- `playgrounds/igniter-lab` has its own `.git` directory and substantial build
  output surfaces, so any future intake must be handled as a separate bounded
  decision.

## Compact Ownership Matrix

| Surface | Current location | Split classification fact |
| --- | --- | --- |
| Language README / release notes | `igniter-lang/README.md`, `igniter-lang/RELEASE_NOTES.md` | Candidate language repo inclusion. |
| Language role/onboarding | `igniter-lang/AGENTS.md`, `igniter-lang/roles/**`, `igniter-lang/handoff/**` | Candidate language repo inclusion. |
| Language package metadata | `igniter-lang/igniter_lang.gemspec` | Candidate language repo inclusion with metadata review required. |
| Language CLI/compiler library | `igniter-lang/bin/**`, `igniter-lang/lib/**` | Candidate language repo inclusion. |
| Language source/examples/fixtures/tests | `igniter-lang/source/**`, `igniter-lang/examples/**`, `igniter-lang/fixtures/**`, `igniter-lang/tests/**` | Candidate language repo inclusion after generated-output classification. |
| Language specs/proposals/status | `igniter-lang/docs/spec/**`, `igniter-lang/docs/proposals/**`, `igniter-lang/docs/current-status.md` | Candidate language repo inclusion. |
| Language cards/tracks/gates/discussions | `igniter-lang/docs/cards/**`, `igniter-lang/docs/tracks/**`, `igniter-lang/docs/gates/**`, `igniter-lang/docs/discussions/**` | Candidate language repo inclusion as authority/history surfaces. |
| Language reports/reviews/org/archive | `igniter-lang/docs/reports/**`, `igniter-lang/docs/reviews/**`, `igniter-lang/docs/org/**`, `igniter-lang/docs/archive/**` | Candidate inclusion, but archive/generated status needs dry-run classification. |
| Language experiments | `igniter-lang/experiments/**` | Candidate inclusion for proof source and referenced artifacts; `out/**` needs explicit generated-artifact policy. |
| Language top-level generated output | `igniter-lang/out/**`, `igniter-lang/out_run.log` | Exclude or quarantine unless a later file-map route proves tracked authority. |
| Root framework README / docs | `README.md`, root `docs/**` | Framework retention with cross-links to language repo where needed. |
| Root framework package/runtime code | root `lib/**`, `spec/**`, `sig/**`, `examples/**` | Framework retention. |
| Root gem/package controls | `Gemfile`, `Gemfile.lock`, `Rakefile`, `igniter.gemspec`, `.rubocop.yml`, `.ruby-lsp/**` | Framework retention or future synthesized language-repo equivalents; not automatic language authority. |
| Root packages | `packages/igniter-*` | Framework/package retention. |
| Root release artifact | `igniter-0.5.2.gem` | Generated/release artifact; split should exclude or quarantine. |
| Root legal/community docs | `LICENSE.txt`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md` | Support-file classification required; not automatically copied without dry-run policy. |
| Root local/editor metadata | `.DS_Store`, `.idea/**`, `.claude/**` | Exclude/quarantine. |
| Root CI | `.github/**` | Currently absent; future language CI would need a separate authored surface. |
| Playground overview | `playgrounds/README.md` | Framework/root cross-link surface. |
| Igniter lab frontier | `playgrounds/igniter-lab/**` | Read-only frontier; exclude from initial split unless later bounded intake authorizes it. |

## Package And Framework Retention Facts

Current root package directories observed under `packages/`:

- `igniter-agents`
- `igniter-ai`
- `igniter-application`
- `igniter-cluster`
- `igniter-contracts`
- `igniter-durable-model`
- `igniter-embed`
- `igniter-extensions`
- `igniter-hub`
- `igniter-ledger`
- `igniter-ledger-client`
- `igniter-mcp-adapter`
- `igniter-web`

These are Ruby framework/platform package surfaces. Their docs may mention
Igniter-Lang or the Igniter Lang Foundation, but those mentions are cross-link
or compatibility-context surfaces, not language-repo authority transfer.

## Candidate Future Language Repo Inclusion Set

Candidate inclusion, subject to a later dry-run file-map proof:

- `igniter-lang/README.md`
- `igniter-lang/AGENTS.md`
- `igniter-lang/RELEASE_NOTES.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/bin/**`
- `igniter-lang/lib/**`
- `igniter-lang/source/**`
- `igniter-lang/examples/**` after generated-output classification
- `igniter-lang/fixtures/**`
- `igniter-lang/tests/**`
- `igniter-lang/docs/spec/**`
- `igniter-lang/docs/proposals/**`
- `igniter-lang/docs/cards/**`
- `igniter-lang/docs/tracks/**`
- `igniter-lang/docs/gates/**`
- `igniter-lang/docs/discussions/**`
- `igniter-lang/docs/reports/**`
- `igniter-lang/docs/reviews/**`
- `igniter-lang/docs/org/**`
- `igniter-lang/docs/archive/**` after archive/generated status review
- `igniter-lang/roles/**`
- `igniter-lang/handoff/**`
- `igniter-lang/experiments/**` for proof source and explicitly referenced
  evidence artifacts

Support files likely need either copying, synthesis, or explicit exclusion in a
future dry-run:

- `LICENSE.txt`
- `CODE_OF_CONDUCT.md`
- `.gitignore`
- package/development task files such as `Gemfile`, `Rakefile`, and CI config
  if the future language repo needs them

## Candidate Framework Repo Retention Set

Likely retention in the Ruby framework repository:

- Root `README.md`, `AGENTS.md`, `CHANGELOG.md`, `CLAUDE.md`
- Root `Gemfile`, `Gemfile.lock`, `Rakefile`, `igniter.gemspec`
- Root `lib/**`, `spec/**`, `sig/**`, `examples/**`, `docs/**`
- `packages/**`
- `bin/console`, `bin/setup`, `bin/igniter-stack`
- `playgrounds/README.md`
- Framework release artifacts, if retained at all, under framework release
  policy rather than language split authority
- Local/editor/development metadata remains excluded or quarantined

## Cross-Link-Only Docs

These current surfaces contain language references but should remain
cross-link-only unless a later route authorizes wording changes:

- Root `README.md` names Igniter-Lang compatibility/foundation context while
  defining the root as the Ruby framework/platform repository.
- Root `docs/**` contains framework-facing language foundation references.
- `packages/igniter-contracts/**` contains Igniter Lang Foundation wording in a
  framework package context.
- `packages/igniter-durable-model/**` references Igniter-Lang observation
  packets as non-dependency context.
- `playgrounds/README.md` should remain a root/private-workspace cross-link,
  not language authority.

## Stale Or Mixed-Authority Wording Risks

- `igniter-lang/igniter_lang.gemspec` currently points metadata at the monorepo
  homepage and a `tree/main/igniter-lang` source-code URI. A future split needs
  metadata review before any release or package claim.
- Root framework docs mention Igniter-Lang surfaces; after a split these should
  be checked for link accuracy and authority separation.
- `igniter-lang/docs/archive/**`, `igniter-lang/experiments/**/out/**`, and
  example `out/**` directories may mix proof evidence, generated artifacts, and
  historical artifacts.
- Lab docs and generated lab outputs can be useful evidence, but accepting them
  as language canon would widen authority.
- Local/root files such as `.DS_Store`, `.idea/**`, `.claude/**`, `.ruby-lsp/**`,
  and `igniter-0.5.2.gem` require exclude/quarantine handling in any dry-run.

## Generated And Proof Artifact Facts

- `igniter-lang/experiments/**` is large and proof-heavy; proof source is a
  strong inclusion candidate, while generated `out/**` files need explicit
  classification.
- Existing `.igapp` artifacts and JSON summaries can be evidence artifacts, but
  they should not become release/runtime authority by being copied.
- Root `.gitignore` excludes `*.gem`, `doc`, `pkg`, `tmp`, coverage, and
  playground content except `playgrounds/README.md`.
- Lab build outputs such as Rust `target`, web `node_modules`, generated app
  build directories, and nested repo internals are not language split content.

## Lab Frontier Facts

Observed lab top-level surfaces include:

- `playgrounds/igniter-lab/igniter-compiler`
- `playgrounds/igniter-lab/igniter-vm`
- `playgrounds/igniter-lab/igniter-runtime`
- `playgrounds/igniter-lab/igniter-stdlib`
- `playgrounds/igniter-lab/igniter-tbackend`
- `playgrounds/igniter-lab/igniter-machine`
- `playgrounds/igniter-lab/igniter-apps`
- `playgrounds/igniter-lab/igniter-ide`
- `playgrounds/igniter-lab/igniter-site`
- `playgrounds/igniter-lab/lab-docs`

This is frontier evidence only. It is not part of the initial language repo
candidate inclusion set without a separate intake/authority route.

## CI, Package, And Release Facts

- Root `.github/**` is absent in the current workspace inventory.
- Root Ruby framework tasking is controlled by root `Gemfile`, `Rakefile`,
  `.rubocop.yml`, and `igniter.gemspec`.
- `igniter-lang/igniter_lang.gemspec` exists, but a future split needs a
  package metadata and repository URL review.
- No package rename, CI migration, gem release, or public repository push is
  authorized by this facts packet.

## Git, History, And Audit-Sensitive Facts

- `igniter-lang/docs/tracks/**` contains a long route/gate history and should
  be treated as audit-sensitive split content.
- `igniter-lang/docs/current-status.md` and `igniter-lang/docs/cards/**` encode
  active route authority and should move with language governance if the split
  is later authorized.
- Physical migration method selection is still open; no subtree, filter-repo,
  remote, branch, tag, or push command is authorized here.
- Lab is a nested git repository and should not be assumed to preserve or share
  history with the root repository.
- A future migration proof needs a tracked-file inventory before any history
  rewrite or copy operation.

## Migration Blockers

- No dry-run file-map proof has classified every tracked `igniter-lang/**`
  surface into include, exclude, quarantine, or cross-link.
- No generated-artifact policy has been applied to every `out/**`, `.igapp`,
  JSON summary, log, and archive surface.
- Language repo support-file policy is unresolved for license, code of conduct,
  `.gitignore`, task files, and CI.
- `igniter-lang/igniter_lang.gemspec` still references the monorepo location.
- Root/framework docs need a cross-link wording pass after split ordering is
  decided.
- Lab intake remains separate and closed.
- Release/package/CI/public-claim authority remains closed.
- History-preserving migration method and verification commands are not yet
  selected or authorized.

## Dry-Run Prerequisites

Before any repository migration authorization, a later route should produce:

- tracked-file inventory for `igniter-lang/**`;
- include/exclude/quarantine/cross-link file map;
- generated-artifact classification for `out/**`, `.igapp`, summary JSON, logs,
  archived outputs, and example outputs;
- support-file plan for license, code of conduct, `.gitignore`, task files, CI,
  and package metadata;
- link rewrite report for root/framework docs and language docs;
- gemspec metadata review for the future target repository;
- lab exclusion proof for `playgrounds/igniter-lab/**`;
- history-preservation plan and command matrix, without executing migration
  commands in the design route;
- post-split smoke/check plan that does not release packages or make public
  runtime/stable claims.

## Closed Surfaces

Closed by this facts packet:

- code edits;
- docs edits outside this packet;
- repository migration;
- subtree/filter-repo/history rewrite execution;
- remote creation or push;
- package rename or release;
- CI migration;
- framework-to-language authority transfer;
- lab canon or lab intake;
- public runtime, Reference Runtime, stable API, production, release,
  performance, certification, or portability claims.

## C4-A Risk Notes

| Risk | Current evidence | C4-A note |
| --- | --- | --- |
| Mixed authority | Root docs/packages reference Igniter-Lang concepts. | Accept facts, require later cross-link wording route. |
| Generated artifact drift | `experiments/**/out/**`, examples output, logs, and archives need classification. | Require dry-run file map before migration. |
| Package metadata drift | `igniter_lang.gemspec` still points to monorepo. | Require metadata review before release or split package claim. |
| Lab canon drift | `playgrounds/igniter-lab/**` is nested/private/frontier. | Keep excluded unless later intake route authorizes. |
| History loss | Migration method not selected. | Require history-preservation proof before physical migration. |
| Root support files | License, code of conduct, `.gitignore`, task files, CI policy unresolved. | Require support-file plan before migration. |

## Recommendation

C4-A can accept this facts packet as current-surface evidence for the repository
split boundary. The next safe route is a dry-run/file-map proof, not physical
migration.

Recommended next route shape:

- repository split dry-run / file-map proof;
- no remote push;
- no package release;
- no CI migration;
- no lab intake;
- no public/stable/runtime claims.
