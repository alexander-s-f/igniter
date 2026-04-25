# Igniter Current State Report

Audience: project owner and future research/architecture agents.

Date: 2026-04-25.

## Executive Read

Igniter is moving from a historical Ruby gem with a wide `core` runtime toward a
contracts-native system of small packages. The target shape is no longer
"business logic DSL plus runtime helpers"; it is closer to a programmable
application substrate where validated dependency graphs, app capsules,
operator workflows, and future distributed agents share explicit contracts.

The strongest signal in the repo is architectural reset, not incremental
compatibility. `igniter-core`, old agents, old app, old cluster, and old frontend
packages are archived/reference material. Active work is rebuilding the system
around `igniter-contracts`, `igniter-extensions`, `igniter-application`,
`igniter-web`, `igniter-cluster`, and `igniter-mcp-adapter`.

## Current Package Direction

Active package graph:

- `igniter-contracts`: canonical embedded kernel.
- `igniter-extensions`: optional vocabulary and packs over contracts.
- `igniter-application`: local app runtime, lifecycle, manifests, sessions,
  capsules, and transfer reports.
- `igniter-web`: web/interaction surface layer for dashboards, operator views,
  asks, actions, streams, chats, and surface manifests.
- `igniter-cluster`: distributed runtime substrate over contracts/application.
- `igniter-mcp-adapter`: contracts-native MCP tooling adapter.

Remaining rebuild work called out by the project:

- rebuild `igniter-server` only if an adapter surface is still needed
- rebuild `igniter-ai`
- rebuild `igniter-agents`

The important architectural implication: AI/agents are expected to return as
explicit packages, not as hidden behavior inside the contracts kernel.

## Kernel State

`igniter-contracts` is intentionally small. The baseline DSL is:

- `input`
- `const`
- `compute`
- `effect`
- `output`

The target kernel owns graph authoring, compilation, validation, profiles,
local execution, effect/executor registries, minimal diagnostics, and extension
seams. It should not know about app boot, web rendering, cluster routing, or AI
agents unless upper packages register those capabilities through explicit
profiles/packs.

Core insight: the project is converging on a compiler/runtime profile model.
Compilation and execution should happen against a frozen profile fingerprint,
not ambient process-global mutation. This is the right foundation for
distributed reproducibility later.

## Extension State

`igniter-extensions` is the place for useful language features that would make
the kernel too large:

- data access and aggregate DSL
- `project`, `lookup`, `branch`, `collection`, `compose`
- incremental/dataflow sessions
- audit, provenance, reports, diagnostics, debug tooling
- journal, saga, reactive, differential, content addressing, invariants
- MCP contract tooling
- domain examples

Key pattern: higher-level DSL should lower into explicit, testable graph/runtime
shapes. This gives Igniter a strong "sugar compiles to clean form" doctrine.

## Application State

`igniter-application` has become the local runtime host. It owns:

- app profiles and environments
- lifecycle planning/execution reports
- manifests and layouts
- mount registrations
- provider/service/interface seams
- session stores
- flow/session snapshots
- application capsules
- capsule inspection, composition, assembly, handoff, transfer, verification,
  apply, and receipt reports

Major insight: application capsules are not deployment magic. They are a
reviewable portability envelope. The docs repeatedly prevent hidden loading,
booting, routing, mounting, execution, or cluster placement. This is a strong
trust and explainability posture.

## Web State

`igniter-web` is not trying to become Rails. It is being shaped as an
interaction surface for Igniter-native workflows:

- dashboards
- chats
- streams
- automations
- webhooks
- operator surfaces
- agent-driven and environment-driven flows
- long-lived wizard/process UIs

The strongest current primitive is `SurfaceManifest`, which lets web describe
routes, imports/exports, and interaction metadata without requiring application
to inspect web screen graphs.

Current web/application contract:

- web describes candidate pending interactions
- application flow snapshots own active pending state
- browser transport and form submission are intentionally deferred

## Cluster State

`igniter-cluster` is a clean-slate distributed runtime, not "server plus more
coordination." Current cluster primitives already include:

- `PeerProfile`
- `PeerTopology`
- `CapabilityQuery`
- route/admission/placement policies
- topology/rebalance plans
- ownership plans
- lease plans
- health/failover plans
- remediation plans
- plan execution reports
- mesh execution request/response/attempt/trace values
- membership, discovery, retry/fallback, trust/admission
- cluster-owned compose/collection invokers

Important insight: cluster has wisely started with explainable planning and
trace values before real distributed side effects. This keeps mesh behavior
auditable and gives future AI operators something structured to reason over.

## Agents And Roles

The repo uses two meanings of "agent":

1. Runtime agents: actor/AI execution components that will live in rebuilt
   `igniter-agents` and `igniter-ai`.
2. Documentation/implementation agents: labeled Codex roles that own tracks.

Visible working roles:

- `[Architect Supervisor / Codex]`
- `[Agent Contracts / Codex]`
- `[Agent Extensions / Codex]`
- `[Agent Embed / Codex]`
- `[Agent Application / Codex]`
- `[Agent Web / Codex]`
- `[Agent Cluster / Codex]`
- `[Research Horizon / Codex]`

Handoff protocol exists in `docs/dev/tracks.md`: agents read active tracks,
change only their track, append a short labeled handoff note, and return compact
status with changed files, verification, and requested next decision.

`[Research Horizon / Codex]` is different from implementation agents. It works
in `docs/research-horizon/`, explores long-range possibilities, and depends on
`[Architect Supervisor / Codex]` to filter ideas before any proposal graduates
into `docs/dev/`.

This is a valuable pattern. The project is already behaving like a
multi-agent architecture lab, even before runtime agents are fully rebuilt.

## Product Direction

The current product pressure track is an operator-facing assistant product:

- public flagship: `examples/companion`
- private downstream adopter: `playgrounds/home-lab`

The intended progression:

1. prove useful single-stack assistant/operator workflows
2. exercise sessions, tools, skills, operator follow-up, and durable runtime
   truth
3. later add routed remote agents, ignite bring-up, and multi-node workers

This is the right sequence. It prevents distributed ambition from outrunning
product feedback.

## Current Strategic Diagnosis

Igniter is becoming a runtime for inspectable, portable, agent-facing business
processes. Its differentiator is not merely "graphs in Ruby"; it is the
combination of:

- contracts as executable truth
- profile-driven extensibility
- application capsules as portable review artifacts
- operator surfaces as first-class workflow control
- cluster plans/traces as explainable distributed intent
- future agents as participants in structured runtime protocols, not chat-only
  wrappers

The highest-risk area is vocabulary sprawl. The project has many strong pieces:
contracts, extensions, embed, app, web, capsules, flows, sessions, operators,
cluster plans, mesh traces, MCP, future AI/agents. The next architectural value
will come from naming a few cross-cutting contracts that let these pieces
interoperate without turning into one giant framework.
