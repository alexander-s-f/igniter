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
- `ignite` as an agent-driven deployment/bootstrap surface

That line has already crossed from pure runtime semantics into:

- app inbox workflows
- mounted operator API and console
- audit history with operator identity
- query/facet/order support over latest audit dimensions
- ignition history, diagnostics, and operator lifecycle handling

So the next planning choice is no longer “make agents real” in the abstract.
The choice is now more like:

1. converging operator workflow semantics across orchestration and ignition
2. deepening runtime/session semantics
3. pushing the same model outward into remote/routed agents

At the moment, the safest shortest continuation is operator workflow convergence.
The strongest architectural continuation is still remote/routed agents.

In parallel, app structure is now an active design line too:

- make apps portable mounted modules
- stop normalizing app-local code in stack-level `lib/.../shared`
- move generated UI authoring toward `igniter-frontend` instead of raw HTML strings
- keep cross-app access explicit instead of implicit through shared helpers

Another active design line is emerging around cluster ignition:

- define `node` as a running stack umbrella, not as an app or static machine role
- define `cluster` as a dynamic set of stack nodes
- move cluster bring-up toward `ignite` intent executed by built-in deployment agents
- keep bootstrap, approval, trust, and join as one coherent workflow rather than scattered scripts

See [Current: Ignite](../current/ignite.md) for the current specification draft.

That draft is now specific enough to guide implementation:

- routed-agent delivery foundation is now also in place:
  - `AgentRoute`
  - `AgentRouteResolver`
  - `AgentTransport`
  - `ProxyAgentAdapter`
  - cluster `AgentRouteResolver`
  - cluster `RoutedAgentAdapter`
  - server `AgentTransport`
  - `/v1/agents/:via/messages/:message/call`
  - `/v1/agents/:via/messages/:message/cast`
  - `/v1/agent-sessions/:token/continue`
  - `/v1/agent-sessions/:token/resume`
  - explicit routed session ownership metadata plus opt-in continuation/resume hooks above the initial transport seam

- normalized `BootstrapTarget`
- normalized `DeploymentIntent`
- plan-level `IgnitionPlan`
- explicit ignition lifecycle and correlation model
- local-replica-first implementation ordering before remote SSH bootstrap

The first code slice has now landed:

- `Igniter::Ignite::*` normalized value objects
- `Igniter::Stack#ignition_plan`
- local `ignite.replicas` folded into stack runtime shaping
- minimal `Igniter::Stack#ignite` agent/report surface
- optional mesh-backed admission handshake for local ignition
- explicit `Igniter::Stack#confirm_ignite_join(...)` for real post-boot join confirmation
- remote `ssh_server` bootstrap through `Igniter::Ignite::BootstrapAgent`
- remote mesh-backed admission orchestration before bootstrap
- built-in server `after_start` hooks for runtime-owned ignite join signaling
- `Igniter::Stack#reconcile_ignite(...)` for closing remote join from real mesh discovery
- bounded automatic join watching in `Igniter::Stack#ignite(...)`
- ignition progress/timeline surface in `IgnitionReport` and diagnostics
- durable ignition trail/history under `var/ignite/` with stack-facing `ignition_history`
- ignition records folded into the app-wide operator surface for one-plane visibility
- operator action API now starts covering ignition lifecycle, not only orchestration inbox items

So the next cluster-ignite move is no longer config modeling.
It is hardening the agent-driven execution that now exists:

- deepen retry/approval/reconcile operator semantics
- strengthen deployment/package/runtime bootstrap strategy
- extend from bootstrap/join into fuller deployment lifecycle such as detach/re-ignite/teardown

## Reading Heuristic

- Read `Agents Roadmap` for the current `contracts & agents` execution direction.
- Read `Namespace Migration Plan` for large structural moves already underway.
- Read `Backlog` for open work that is broader than one package patch.
- Keep speculative design notes out of the main guide unless the user-facing surface already exists.
- Treat cluster query-language naming cleanup as separate low-priority work, not as the main driver for current agent/runtime planning.
