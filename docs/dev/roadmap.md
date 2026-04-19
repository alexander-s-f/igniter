# Roadmap And Change Work

Use this index for active internal change streams and planning material.

## Active References

- [Agents Roadmap](../current/agents-roadmap.md)
- [Namespace Migration Plan](./namespace-migration-plan.md)
- [Backlog](./backlog.md)
- [Frontend Packages Idea](./frontend-packages-idea.md)

## Current Planning Snapshot

Right now the most active Igniter line is:

- `contracts & agents`
- `agent node`
- `AgentSession` and stream/tool-loop semantics
- app orchestration policies and operator surfaces
- app/stack structure cleanup and pluggable app doctrine

That line has already crossed from pure runtime semantics into:

- app inbox workflows
- mounted operator API and console
- audit history with operator identity
- query/facet/order support over latest audit dimensions

So the next planning choice is no longer “make agents real” in the abstract.
The choice is between:

1. deepening the operator surface
2. deepening runtime/session semantics
3. pushing the same model outward into remote/routed agents

At the moment, the safest shortest continuation is operator timeline/drill-down.
The strongest architectural continuation is remote/routed agents.

In parallel, app structure is now an active design line too:

- make apps portable mounted modules
- stop normalizing app-local code in stack-level `lib/.../shared`
- move generated UI authoring toward `igniter-frontend` instead of raw HTML strings
- keep cross-app access explicit instead of implicit through shared helpers

## Reading Heuristic

- Read `Agents Roadmap` for the current `contracts & agents` execution direction.
- Read `Namespace Migration Plan` for large structural moves already underway.
- Read `Backlog` for open work that is broader than one package patch.
- Keep speculative design notes out of the main guide unless the user-facing surface already exists.
- Treat cluster query-language naming cleanup as separate low-priority work, not as the main driver for current agent/runtime planning.
