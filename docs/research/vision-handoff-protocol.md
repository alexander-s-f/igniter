# Vision Handoff Protocol

Status: active research operating protocol. Not a package plan or public API.

Purpose: give agents a large horizon without making their task large. The frame
should widen judgment, then narrow action.

## Core Rule

Every agent brief should connect three scales:

- Horizon: the future option we must preserve.
- Boundary: the layer and ownership that make the work safe today.
- Slice: the smallest reversible move with evidence.

If any scale is missing, the brief is incomplete.

## Vision Handoff Shape

Use this compact form when assigning or reviewing agent work:

```text
[Vision Handoff / Codex]
North Star:
Current Terrain:
Non-Negotiables:
Allowed Move:
Forbidden Drift:
Evidence Required:
Return Shape:
```

Field meanings:

- `North Star`: year-scale future this work should keep possible.
- `Current Terrain`: accepted facts, active docs, and current implementation
  pressure.
- `Non-Negotiables`: invariants, package boundaries, privacy, and safety rules.
- `Allowed Move`: the narrow action the agent may take now.
- `Forbidden Drift`: tempting expansions that would close future options.
- `Evidence Required`: specs, smoke markers, manifests, reports, or review notes.
- `Return Shape`: the exact handoff format expected back.

## Return Shape

Agents should return compact handoffs:

```text
[Agent Role / Codex]
Aim:
Changed:
Evidence:
Lang impact: opens | preserves | narrows | closes
Boundary risk:
Next:
Block:
```

`Lang impact: closes` requires architect acceptance before merge or promotion.

## Architect Lens

Before giving the brief, compress the big frame through these lenses:

- Kernel: what enters contract semantics?
- Type: what can become descriptor, manifest, invariant, or capability?
- Time: record, history, bitemporal correction, forecast, or deadline?
- Agency: who acts, under what policy, with what receipt?
- Data: durable shape, query shape, projection, lineage, materialization.
- Distribution: local, routed, placed, replicated, merged, or deferred.
- Interface: human sugar, agent-clean object form, transport, or rendering.
- Constraint: the bottleneck or irreversible decision that dominates.

Do not send the whole analysis to the agent. Send the compressed handoff.

## Decision Tags

Use the documentation compression tags inside handoffs when useful:

- `[D]`: durable decision.
- `[R]`: active rule or constraint.
- `[S]`: current state.
- `[H]`: cold history pointer.

These tags are optional in small implementation handoffs and recommended in
architect/supervisor notes.

## Good Brief Pattern

```text
[Vision Handoff / Codex]
North Star: Igniter becomes a contract-native substrate where Ruby DSL,
future .il grammar, agents, persistence, and cluster placement lower to the
same explicit semantics.
Current Terrain: Companion has app-local proof; public API is not accepted.
Non-Negotiables: keep side effects at boundaries; metadata before enforcement;
human sugar must have an agent-clean form.
Allowed Move: add report-only manifest fields for one repeated pressure point.
Forbidden Drift: parser, runtime-wide API, hidden adapter behavior, package
split, or distributed placement.
Evidence Required: focused spec/smoke plus manifest output.
Return Shape: Aim / Changed / Evidence / Lang impact / Boundary risk / Next.
```

## Contract Persistence Frame

Use this current frame for persistence work:

```text
[Vision Handoff / Codex]
North Star: `persist` lowers to `Store[T]`; `history` lowers to `History[T]`;
future Igniter Lang can type, verify, and place durable capabilities.
Current Terrain: Companion proves records, histories, projections, commands,
operation intents, registry, readiness, and setup manifest app-locally.
Non-Negotiables: do not collapse records, histories, projections, receipts, and
adapter behavior into one Store object; side effects stay at the boundary.
Allowed Move: extend app-local metadata/manifest for index, scope, or command
shape only when Companion gives real pressure.
Forbidden Drift: stable public API, migration generator, grammar syntax,
automatic placement, or treating history as mutable CRUD.
Evidence Required: manifest/readiness proof plus success/refusal smoke.
Return Shape: include `Lang impact` and whether the move opens, preserves,
narrows, or closes the `Store[T]` / `History[T]` path.
```

## Handoff To Supervisor

```text
[Architect Supervisor / Codex]
Track: docs/research/vision-handoff-protocol.md
Status: proposed active protocol for briefing implementation/review agents.
[D] Big vision is carried as a compact frame, not as expanded task scope.
[R] Every serious agent brief names North Star, boundary, allowed move,
forbidden drift, required evidence, and return shape.
[R] Agent return handoffs must state Lang impact: opens | preserves | narrows |
closes.
[S] First concrete use case is contract persistence: keep `persist -> Store[T]`
and `history -> History[T]` while Companion pressure stays app-local.
Next: use this protocol in the next persistence or agent-review handoff and
tighten fields only after real friction.
```
