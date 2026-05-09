# History-S9 Dev Reference Truth Map

Status: archived history report and reference-doc truth map  
Date: 2026-05-09  
Agent: [Igniter-Lang History Curator]  
Role: history-curator  
Stage: History-S9  
Source posture: classify `playgrounds/docs/dev/reference/`; no files moved or deleted

## Compact Claim

`playgrounds/docs/dev/reference/` is a transition layer, not a current-doc
entrypoint.

It captures the Ruby Igniter shift from a legacy `core/server/app/cluster`
shape toward a contracts-first package family:

- `igniter-contracts` as the canonical embedded kernel;
- `igniter-extensions` as packs, tooling, diagnostics, and domain behavior;
- `igniter-application` as the local runtime host;
- `igniter-cluster` as the distributed runtime;
- adapters and frontend packages above those layers;
- `igniter-core` / `igniter-legacy` as temporary reference and compatibility
  material, not the future architecture.

For Igniter-Lang history, the durable value is the same pattern in language
form: keep the semantic core small, make capability/authority explicit, compile
sugar into inspectable lower forms, preserve structured reports, and do not let
legacy implementation shape define the next canon.

## Source Set

- `playgrounds/docs/dev/reference/application-capsule-transfer-finalization-roadmap.md`
- `playgrounds/docs/dev/reference/application-structure-research.md`
- `playgrounds/docs/dev/reference/application-web-integration-tasks.md`
- `playgrounds/docs/dev/reference/architecture-index.md`
- `playgrounds/docs/dev/reference/architecture-reference.md`
- `playgrounds/docs/dev/reference/backlog.md`
- `playgrounds/docs/dev/reference/canonical-runtime-shapes.md`
- `playgrounds/docs/dev/reference/contracts-extensions-stewardship.md`
- `playgrounds/docs/dev/reference/contracts-migration-roadmap.md`
- `playgrounds/docs/dev/reference/core-retirement-inventory.md`
- `playgrounds/docs/dev/reference/credential-distribution.md`
- `playgrounds/docs/dev/reference/debug-pack-spec.md`
- `playgrounds/docs/dev/reference/frontend-packages-idea.md`
- `playgrounds/docs/dev/reference/human-sugar-dsl-doctrine.md`
- `playgrounds/docs/dev/reference/igniter-contracts-spec.md`
- `playgrounds/docs/dev/reference/namespace-migration-plan.md`
- `playgrounds/docs/dev/reference/post-core-target-plan.md`
- `playgrounds/docs/dev/reference/roadmap.md`
- `igniter-lang/docs/archive/history/history-s6-dev-process-tracks-legacy-map.md`
- `igniter-lang/docs/archive/history/history-s8-legacy-v1-value-extraction-map.md`

## Reference Area Classification

| Area | Documents | Category | Current reading |
| --- | --- | --- | --- |
| Post-core architecture reset | `post-core-target-plan`, `canonical-runtime-shapes`, `igniter-contracts-spec`, `contracts-migration-roadmap`, `core-retirement-inventory` | accepted_canon for Ruby Igniter direction, values for Igniter-Lang | Preserve as contracts-first design memory; check current public docs before implementation. |
| Namespace/package migration | `architecture-index`, `architecture-reference`, `namespace-migration-plan` | superseded_history + values | Valuable for layer rationale, but package paths/entrypoints may be stale. |
| Application/capsule/web | `application-structure-research`, `application-web-integration-tasks`, `application-capsule-transfer-finalization-roadmap` | implemented + superseded_history + values | Preserve capsule, mount, explicit export/import, receipt, and stop-line values. |
| Frontend/rendering | `frontend-packages-idea` | implemented + values | Preserves optional frontend/schema package split and Ruby/Arbre authoring rationale. |
| Debug/creator/tooling | `debug-pack-spec` | implemented + values | Preserve report-first debug stack and “protocol later” ordering. |
| Human authoring ergonomics | `human-sugar-dsl-doctrine` | values + research still alive | Preserve dual-form doctrine: agent-clean form and human sugar form compile to the same model. |
| Credentials/trust | `credential-distribution` | values + research still alive | Preserve local-first credentials, routing before replication, and audit-first propagation. |
| Planning/backlog | `roadmap`, `backlog` | parked + research_unrealized + values | Use as pressure inventory only; do not treat as current active plan without checking live tracks/status. |

## Accepted Or Implemented Signals

### Contracts-First Kernel

The strongest accepted direction is that the bottom layer should be a small,
profile-driven, pack-extensible contracts kernel.

Durable parts:

- baseline kernel stays small;
- packs extend DSL/runtime behavior explicitly;
- profiles/fingerprints make runtime semantics inspectable;
- diagnostics and reports are product surfaces;
- host, app, web, cluster, transport, frontend, MCP, and framework plugins stay
  above the kernel.

Igniter-Lang parallel:

- keep core language semantics small;
- keep proposal-only syntax out of canon until parser/typechecker/SemanticIR and
  runtime/report rules are proven;
- treat reports and compatibility surfaces as part of the language ecosystem,
  not as afterthoughts.

### Extension/Packs Before Package Sprawl

The reference docs repeatedly choose packs and manifests before new permanent
packages.

Durable parts:

- hard pack dependencies and semantic capabilities are different concepts;
- default extensions can be recommended without becoming baseline;
- debug, creator, MCP, audit, provenance, content addressing, saga, dataflow,
  incremental, and domain behavior belong in optional packs unless proven
  semantic primitives.

Igniter-Lang parallel:

- language features should not become grammar or runtime canon merely because
  they are ergonomic;
- many future surfaces should begin as proposals, bridge profiles, stdlib, or
  tooling packages.

### Application As Portable Capsule

The application reference line converges on a capsule model:

- app root is the portability boundary;
- web is an optional surface, not a different app type;
- exports/imports are explicit;
- mounting is explicit;
- app-local code stays inside the app;
- host activation and route/runtime mutation remain gated;
- file transfer and runtime activation require separate receipts.

Igniter-Lang parallel:

- compiled artifacts, `.igapp` manifests, and bridge packages should preserve
  explicit import/export/activation boundaries;
- a loaded artifact is not the same thing as an authorized runtime action.

### Debug And Tooling As Structured Reports

`DebugPack`, `CreatorPack`, and `McpPack` preserve a valuable ordering:

1. internal debug reports;
2. authoring workflow;
3. protocol/tool adapter.

This avoids freezing external protocol before internal report shapes are stable.

Igniter-Lang parallel:

- CompatibilityReport, temporal read observation, audit-ready envelope, and
  compiler diagnostics should mature before protocol surfaces or external tool
  promises harden.

### Human Sugar Plus Agent-Clean Form

The human-sugar doctrine is one of the highest-value references.

Durable rule:

- sugar is valid only when it compiles to the same lower-level model as the
  clean form, remains inspectable, and can report its expansion clearly.

Igniter-Lang parallel:

- syntax pressure can improve human readability, but it must lower into the
  same typed SemanticIR and runtime/report semantics.

## Superseded Or Dangerous As Current Canon

- `architecture-index` and `architecture-reference` include old package names,
  old paths, and old “server as pillar” framing. Use them for rationale, not
  current package truth.
- `namespace-migration-plan` is partly historical because the target continues
  moving toward post-core contracts-first packages.
- `backlog` mixes implemented items, next ideas, and future cluster phases; it
  is not an active assignment list.
- `roadmap` explicitly says older roadmap sections preserve context and are not
  the current runtime package graph.
- `application-web-integration-tasks` contains track-style handoff material; use
  it as evidence, not current task routing.
- `human-sugar-dsl-doctrine` should not be used to add hidden magic; its own
  non-negotiable is inspectable expansion into clean form.
- `frontend-packages-idea` should not pull frontend rendering into core.
- `debug-pack-spec` should not justify exposing protocol/MCP surfaces before
  stable internal report APIs.
- `credential-distribution` should not be read as secret propagation approval;
  it is explicitly conservative and local-first.

## Values To Preserve

- **Small semantic core:** baseline should hold only primitives with real
  compile/runtime semantics.
- **Inspectable extension:** packs, profiles, manifests, and fingerprints make
  extension behavior visible.
- **Reports as product surface:** compile, validation, execution, diagnostics,
  provenance, audit, and compatibility reports are first-class outputs.
- **Sugar lowers to model:** human DSL is welcome only when equivalent to clean
  explicit form.
- **Authority is explicit:** capability metadata, content refs, and readiness
  reports are not execution permission by themselves.
- **Portable capsules:** app/capsule boundaries should be copyable, mountable,
  inspectable, and explicit about imports/exports.
- **Receipts before mutation:** transfer, activation, credential movement, and
  runtime actions need refusal-first plans and receipts.
- **Local-first secrets:** route to the capable credential-owning node before
  copying credentials.
- **Protocol after shape:** expose MCP/tooling only after debug/creator/report
  shapes are coherent.

## Research Still Alive

| Research line | Why it remains alive | Promotion rule |
| --- | --- | --- |
| Pack dependency graph | Current packs need deterministic install ordering separate from semantic capabilities. | Promote through package/tooling proof, not language syntax. |
| Human Sugar DSL | Human ergonomics matter, especially for host/embed configuration. | Must show clean expansion and identical runtime meaning. |
| Collection/compose as packs | User need is real, but baseline kernel should stay small. | Re-enter through extension packs and invocation seams. |
| Capsule activation | Transfer and ledger-backed activation proofs exist, but real host/web activation is closed. | Needs separate host/web-owned verification and receipts. |
| Credential leases | Shared app-level vocabulary exists, full propagation does not. | Requires trust/admission/audit proof before transport. |
| Debug/Creator/MCP stack | Implemented direction exists, but stable external tooling should follow internal report maturity. | Promote protocol only after schemas are stable. |
| Cluster observation/placement | Backlog retains Phase 2/3/OLAP/MeshQL ideas. | Re-enter through current observation envelope and OLAP/TBackend gates, not old MeshQL plans. |

## Rotation Recommendations

No files should be moved or deleted in this stage.

Recommended future cleanup, only after approval:

| Target | Recommendation | Reason |
| --- | --- | --- |
| `playgrounds/docs/dev/reference/` | Add or generate a small reference index if this tree stays in-place | There is no top-level read rule inside the folder itself. |
| `architecture-index` / `architecture-reference` / `namespace-migration-plan` | Mark as historical or compare with current public dev/package docs before reuse | They can mislead on current paths and package ownership. |
| `post-core-target-plan` / `canonical-runtime-shapes` / `igniter-contracts-spec` | Keep warm | These are high-value design memory for the contracts-first reset. |
| `application-*` reference docs | Keep warm/cold by topic | The capsule/web tracks preserve important receipts and stop-lines but are too detailed for default reading. |
| `backlog` / `roadmap` | Keep cold unless planning asks for pressure inventory | They are mixed planning memories, not canonical current status. |
| `human-sugar-dsl-doctrine` | Keep warm | This is durable authoring doctrine and likely useful for future Igniter-Lang syntax pressure. |
| `credential-distribution` | Keep warm for cluster/agent/security work | It prevents unsafe defaults around secret propagation. |

## Future Agent Read Rule

For current implementation:

1. Start from current public docs and assigned tracks.
2. Use `playgrounds/docs/dev/reference/` only when the task names a topic.
3. Before acting on a reference doc, classify it as current, historical,
   pressure-only, or research.
4. Do not copy package paths or APIs from reference docs without checking current
   code/docs.

For Igniter-Lang history or strategy:

1. Read archive history reports S6-S9 first.
2. Use reference docs to extract values and boundary rules.
3. Promote only compact claims, not full planning narratives.

## Stage-Close Handoff

Compact claim:

`playgrounds/docs/dev/reference/` preserves the post-core, contracts-first
transition of Ruby Igniter. Its most useful durable memory for Igniter-Lang is
not exact package layout, but the pattern: small semantic core, explicit packs,
structured reports, inspectable sugar, receipts before mutation, and conservative
authority boundaries.

Source set:

- `playgrounds/docs/dev/reference/`
- S6 dev process/tracks map
- S8 legacy V1 value extraction map

Categories applied:

- accepted_canon
- implemented
- superseded_history
- research_unrealized
- rejected / parked
- values

Values preserved:

- small semantic core
- inspectable extension
- reports as product surface
- human sugar lowering to clean model
- explicit authority
- portable capsules
- receipts before mutation
- local-first secrets
- protocol after shape

Accepted/implemented signals:

- contracts-first reset
- contracts/extensibility/profile model
- DebugPack/CreatorPack/McpPack ordering
- frontend/schema optional package split
- application capsule exports/imports
- file transfer and activation receipts
- app-level credential policy vocabulary

Superseded/rejected signals:

- server as primary runtime pillar
- core/legacy as future architecture
- old package paths as current truth
- frontend in core
- hidden sugar magic
- protocol-first MCP
- implicit secret copying
- activation without separate receipt

Research still alive:

- pack dependency graph
- human sugar DSL
- collection/compose packs
- capsule activation lanes
- credential leases
- debug/creator/MCP maturity
- cluster observation/placement

Duplicate/rotation recommendations:

- add a reference index later if approved
- keep architecture migration docs historical/current-check
- keep post-core/contracts docs warm
- keep application docs topic-scoped
- keep backlog/roadmap cold for planning only
- keep human sugar and credential docs warm

Unresolved questions:

- Which reference docs should become formal current public docs, if any?
- Should Igniter-Lang adopt a formal “sugar lowers to clean form” doctrine in
  its own syntax process?
- Which Ruby Igniter contracts-first values should be hoisted into
  `igniter-lang/docs/value-index.md` later?

Changed files:

- `igniter-lang/docs/archive/history/history-s9-dev-reference-truth-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

History-S10 should compress `playgrounds/docs/experts/igniter-lang/` or the
remaining expert/history lane that most directly feeds Igniter-Lang syntax,
temporal, OLAP, and human-agent comprehension pressure.
