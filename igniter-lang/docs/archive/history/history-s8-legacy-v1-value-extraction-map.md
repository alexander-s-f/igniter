# History-S8 Legacy V1 Value Extraction Map

Status: archived history report and legacy-value map  
Date: 2026-05-09  
Agent: [Igniter-Lang History Curator]  
Role: history-curator  
Stage: History-S8  
Source posture: classify `playgrounds/docs/dev/legacy/`; no files moved or deleted

## Compact Claim

`playgrounds/docs/dev/legacy/` is not current canon. It is a V1 seed bank.

The valuable material is not the old APIs themselves. The valuable material is
the set of durable pressures that survived into Igniter and Igniter-Lang:

- graph-visible control flow instead of hidden Ruby logic;
- explicit runtime capabilities instead of ambient authority;
- time, history, cache identity, and content addressing as correctness
  boundaries;
- observation envelopes, receipts, and diagnostics as first-class proof;
- layer separation between embedded kernel, app/server, cluster, SDK, and
  integrations;
- agent/AI/tool ideas as optional capability planes, not the base runtime.

Current Igniter-Lang already absorbed several of these signals through Stage 2
and Stage 3: `History[T]`, `BiHistory[T]`, `stream T`, `OLAPPoint[T,Dims]`,
typed SemanticIR, CompatibilityReport, executor approval, temporal cache-key
rules, content-addressed addendum evidence, and report-only descriptor metadata.

## Source Set

- `playgrounds/docs/dev/process/legacy-reference.md`
- `playgrounds/docs/dev/legacy/APP_V1.md`
- `playgrounds/docs/dev/legacy/BRANCHES_V1.md`
- `playgrounds/docs/dev/legacy/COLLECTIONS_V1.md`
- `playgrounds/docs/dev/legacy/DATAFLOW_V1.md`
- `playgrounds/docs/dev/legacy/NODE_CACHE_V1.md`
- `playgrounds/docs/dev/legacy/CONTENT_ADDRESSING_V1.md`
- `playgrounds/docs/dev/legacy/TEMPORAL_V1.md`
- `playgrounds/docs/dev/legacy/CAPABILITIES_V1.md`
- `playgrounds/docs/dev/legacy/MODULE_SYSTEM_V1.md`
- `playgrounds/docs/dev/legacy/LAYERS_V1.md`
- `playgrounds/docs/dev/legacy/SDK_V1.md`
- `playgrounds/docs/dev/legacy/STACKS_V1.md`
- `playgrounds/docs/dev/legacy/SERVER_V1.md`
- `playgrounds/docs/dev/legacy/DEPLOYMENT_V1.md`
- `playgrounds/docs/dev/legacy/DISTRIBUTED_CONTRACTS_V1.md`
- `playgrounds/docs/dev/legacy/PERSISTENCE_MODEL_V1.md`
- `playgrounds/docs/dev/legacy/CLUSTER_DEBUG_V1.md`
- `playgrounds/docs/dev/legacy/MESH_V1.md`
- `playgrounds/docs/dev/legacy/MESH_QL_V1.md`
- `playgrounds/docs/dev/legacy/OLAP_POINT_V1.md`
- `playgrounds/docs/dev/legacy/LLM_V1.md`
- `playgrounds/docs/dev/legacy/PROACTIVE_AGENTS_V1.md`
- `playgrounds/docs/dev/legacy/TOOLS_V1.md`
- `playgrounds/docs/dev/legacy/SKILLS_V1.md`
- `playgrounds/docs/dev/legacy/CHANNELS_V1.md`
- `playgrounds/docs/dev/legacy/INTEGRATIONS_V1.md`
- `playgrounds/docs/dev/legacy/TRANSCRIPTION_V1.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/proposals/PROP-024-olap-point-primitive-v0.md`

## Legacy Set Classification

| Legacy area | V1 documents | Current classification | What survived |
| --- | --- | --- | --- |
| Core graph primitives | `BRANCHES_V1`, `COLLECTIONS_V1` | implemented / accepted design lineage | Branch and collection should be explicit graph nodes, visible to compiler, runtime diagnostics, and introspection. |
| Runtime correctness | `DATAFLOW_V1`, `NODE_CACHE_V1`, `CONTENT_ADDRESSING_V1`, `TEMPORAL_V1` | implemented partly, superseded_history, values | Cache keys, diffs, temporal replay, and content identity are correctness boundaries, not optimization trivia. |
| Capabilities and authority | `CAPABILITIES_V1` | values, partially absorbed | Runtime/executor authority must be explicit, inspectable, and refusal-capable. |
| Layer/package shape | `MODULE_SYSTEM_V1`, `LAYERS_V1`, `SDK_V1`, `INTEGRATIONS_V1` | accepted_canon as principle, superseded as filesystem/API detail | Embed remains small; SDK/capabilities/integrations stay optional and downward-facing. |
| App/server/stack/deployment | `APP_V1`, `SERVER_V1`, `STACKS_V1`, `DEPLOYMENT_V1` | superseded_history, values | Embedded, single-node app, and cluster modes remain useful; old service/topology APIs are not canon. |
| Distributed workflows and state | `DISTRIBUTED_CONTRACTS_V1`, `PERSISTENCE_MODEL_V1`, `CLUSTER_DEBUG_V1` | research still alive, values | Correlation, explicit wait nodes, ownership, event logs, projections, read models, and repair surfaces remain important. |
| Mesh and cluster query | `MESH_V1`, `MESH_QL_V1`, `OLAP_POINT_V1`, `CONSENSUS_V1` | research_unrealized / partially absorbed | OLAP-point dimensional thinking survived into Igniter-Lang; mesh/consensus APIs remain non-canon unless revalidated. |
| AI/agents/tools/channels | `LLM_V1`, `PROACTIVE_AGENTS_V1`, `TOOLS_V1`, `SKILLS_V1`, `CHANNELS_V1`, `TRANSCRIPTION_V1` | research_unrealized, values | AI and agents fit as graph/capability surfaces, but should remain optional SDK/package planes. |

## Absorbed Into Current Igniter-Lang

| V1 signal | Igniter-Lang absorption |
| --- | --- |
| Temporal replay and `as_of` thinking | `History[T]`, `BiHistory[T]`, TEMPORAL fragment class, explicit `as_of`, Gate 3 restricted Phase 1 live-read scope. |
| Content-addressed correctness | Signed addendum reference now requires path plus `content_sha256`, `git_commit`, signed status/date, and authority ref. |
| Cache identity must include time | TEMPORAL cache key contract refuses CORE-shaped keys for TEMPORAL. |
| Capability-gated execution | `requirements.json`, CompatibilityReport, executor approval token, capability mismatch refusals. |
| OLAP Point as dimensional surface | `OLAPPoint[T,Dims]` closed in Stage 2 at parser/typechecker/SemanticIR level. |
| Stream/dataflow pressure | `stream T` closed in Stage 2; production stream executor remains unauthorized. |
| Observation envelope/diagnostics | `temporal_read_observation`, CompatibilityReport composition, audit-ready envelope proof-local shape. |
| Agent-readable lifecycle | Agent context capsule, value index, role/context read order, compact handoff discipline. |

Important boundary: absorption does not mean all V1 ambitions are live. Current
Igniter-Lang gates still explicitly block production cache, Ledger binding,
BiHistory/stream/OLAP execution, production authority registry, production
signing, and durable observation persistence unless separately approved.

## Values Preserved

### Graph Visibility

Branching, collection fan-out, waiting, remote routing, AI calls, and tool calls
should not disappear into opaque host-language callbacks when they affect
runtime behavior. If a concept matters for diagnostics, caching, replay, or
approval, it should become graph-visible or report-visible.

### Explicit Authority

V1 capability thinking survives as a stronger current value: metadata is not
authorization. A runtime may report capabilities, descriptors, tokens, or
readiness, but live execution still requires the correct gate and approval
surface.

### Time Is Part Of Identity

Temporal reads, replay, memoization, and content-addressed references all point
to the same rule: the time/version/evidence coordinate is part of the value, not
an external note.

### Local-First Ownership

The persistence and cluster docs preserve an important anti-goal: do not assume
one global shared database. Ownership, event logs, projection feeds, and derived
read models are the safer distributed mental model.

### Optional Capability Planes

AI, tools, skills, channels, SDK packs, integrations, and transcription should
not inflate the embedded kernel. They are optional surfaces that can compose
with the core graph/runtime shape.

### Receipts And Repair

Cluster debug and deployment docs keep a durable value: operational systems need
receipts, read-model comparison, owner fetches, replay/repair surfaces, and
human-readable explanations for why routing or execution refused.

## Superseded Or Rejected As Canon

- Old V1 root-layout and package paths are superseded by the current
  package-era structure.
- Old `Igniter::App` as a service/process boundary is superseded.
- `config/topology.yml`, `default_service`, `--service`, and role/service launch
  language are historical stack vocabulary.
- Direct `Igniter::Server.configure` and old REST endpoint surfaces are
  historical hosting vocabulary.
- Static mesh APIs, MeshQL syntax, consensus API, and cluster routing examples
  are not current Igniter-Lang canon.
- V1 AI executor/provider APIs are not current language/runtime canon.
- Proactive agents as a standard runtime base class remain research, not accepted
  runtime surface.
- Skills/channels/transcription as top-level conceptual entrypoints are
  superseded by optional package/SDK reading.
- Content addressing must not be treated as permission to execute; it is
  evidence identity, not authority.

## Research Still Alive

| Research line | Why it remains valuable | Promotion rule |
| --- | --- | --- |
| Distributed OLAP execution | Current Stage 2 has OLAP type/IR; distributed scatter/gather remains a deferred gap. | Requires post-TBackend/language lane proof and explicit approval. |
| Mesh/observation query | OLAP Point, MeshQL, and cluster debug share a query-over-observation idea. | Re-enter through current `OLAPPoint[T,Dims]` and observation envelope, not V1 MeshQL syntax. |
| Durable observation persistence | V1 debug/cluster docs anticipate persistent proof surfaces. | Must stay separate from proof-local audit envelopes until production persistence is approved. |
| Agent-native proactive workflows | Proactive agents and track lifecycle both describe autonomous scans and triggers. | Promote as track/task contract only after repeated product proof, not as generic agent base class. |
| SDK AI/tool capability plane | Tools, skills, channels, transcription, and LLM executors share discoverability/schema/capability pressures. | Re-enter as optional package proposals with explicit capability and approval semantics. |
| Local-first ownership model | Persistence V1 still fits distributed product pressure. | Promote through data ownership / TBackend / Ledger gates, not old cluster assumptions. |

## Rotation Recommendations

No files should be moved or deleted in this stage.

Recommended future cleanup, only after approval:

| Target | Recommendation | Reason |
| --- | --- | --- |
| `playgrounds/docs/dev/legacy/` | Keep as cold V1 seed bank | It is already compact enough to preserve and useful for archaeology. |
| Small 24-line legacy docs | Optionally combine into a single `legacy-runtime-features-v1.md` later | `CAPABILITIES`, `CHANNELS`, `CONTENT_ADDRESSING`, `PERSISTENCE_MODEL`, `SKILLS`, `TEMPORAL`, `TOOLS`, `TRANSCRIPTION` are concise wrappers. |
| Large cluster docs | Keep separate and cold | `MESH_V1`, `CONSENSUS_V1`, `CLUSTER_DEBUG_V1`, `OLAP_POINT_V1` are high-signal research seeds. |
| Link hygiene | Check legacy relative links if these docs become actively used | Some links appear to point through older folder assumptions; this is harmless while cold but risky if promoted. |
| Igniter-Lang value index | Consider hoisting only one archaeology pointer later | The whole V1 set should not flood active values; one pointer to this S8 report is enough if needed. |

## Future Agent Read Rule

Read legacy V1 docs only when one of these is true:

1. A current task names the exact V1 topic.
2. A current proposal needs archaeological rationale.
3. A current implementation resembles an old API and needs a superseded-canon
   warning.
4. A history/rotation stage asks for legacy compression.

Do not use V1 examples as current API templates. Convert them into one of:

- accepted current canon;
- implemented historical lineage;
- superseded history;
- parked/rejected API shape;
- research seed;
- preserved value.

## Stage-Close Handoff

Compact claim:

The V1 legacy set is valuable as pressure archaeology, not as API memory. Its
best ideas already shaped current Igniter-Lang around temporal identity,
OLAP/history typing, report-only compatibility, approval-gated execution, and
content-addressed evidence.

Source set:

- `playgrounds/docs/dev/legacy/`
- `playgrounds/docs/dev/process/legacy-reference.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/proposals/PROP-024-olap-point-primitive-v0.md`

Categories applied:

- accepted_canon
- implemented
- superseded_history
- research_unrealized
- rejected / parked
- values

Values preserved:

- graph visibility
- explicit authority
- time as identity
- local-first ownership
- optional capability planes
- receipts and repair

Accepted/implemented signals:

- branch/collection graph visibility
- temporal/history/OLAP type lineage
- content-addressed evidence
- capability/report-only boundaries
- layered runtime/package discipline
- observation and audit envelope pressure

Superseded/rejected signals:

- old app/server/stack service APIs
- old root/package layout assumptions
- static mesh/MeshQL/consensus APIs as canon
- V1 AI executor/provider APIs as language canon
- proactive agents as standard runtime surface
- content address as execution authority

Research still alive:

- distributed OLAP execution
- observation query / mesh diagnostics
- durable observation persistence
- proactive/agent-native workflows
- AI/tool/channel optional capability packages
- local-first ownership and projection models

Duplicate/rotation recommendations:

- keep the legacy folder cold and intact
- optionally combine tiny wrapper docs later
- keep large cluster docs separate
- run link hygiene only if these docs become active
- hoist at most one pointer into active value index later

Unresolved questions:

- Should Igniter-Lang eventually define an observation-query language, or should
  query stay in package/runtime space?
- Which V1 AI/tool ideas belong in Igniter-Lang syntax versus package bridge
  profiles?
- When TBackend/Ledger gates reopen, which persistence V1 values should be used
  as acceptance criteria?

Changed files:

- `igniter-lang/docs/archive/history/history-s8-legacy-v1-value-extraction-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

History-S9 should compress `playgrounds/docs/dev/reference/` into a reference
truth map: which reference docs are superseded by public docs, which remain
active pressure, and which are cold architecture archaeology.
