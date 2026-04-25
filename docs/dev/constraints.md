# Constraint Sets

Named constraints are compact shorthand for active tracks. Use them to keep
handoffs short without losing architectural boundaries.

Rules:

- A constraint set applies only when a track or handoff names it explicitly.
- If a track has explicit local boundaries, the local text wins.
- Agents do not need to expand a set in every handoff; cite the set name and
  link here when the boundary matters.
- Prefer adding or tightening one set at a time. Do not turn this file into a
  complete policy system.

## Sets

### `:interactive_poc_guardrails`

For the current interactive operator POC line.

Do not add:

- full `interactive_app` facade
- broad UI kit or design system
- Plane/canvas runtime
- flow/chat/proactive agent DSL
- SSE/live update transport
- generator
- production server layer
- database persistence
- auth/session framework
- background jobs or websocket infrastructure
- cluster placement

Allowed:

- app-local Ruby services
- compact Rack surfaces
- small form/actions needed for live pressure testing
- query-string feedback for known result codes
- smoke scripts that prove the operator loop

### `:activation_safety`

For capsule or host activation planning.

Do not perform activation side effects unless a track explicitly promotes the
work to that phase:

- host mutation
- commit/write into a target host
- runtime loading or discovery
- registration or boot wiring
- route or mount binding
- Rack/browser traffic
- contract execution
- cluster placement

Allowed:

- inventory
- dry-run manifests
- static verification
- explicit readiness notes

### `:research_only`

For Research Horizon and expert proposal passes.

Do not add package/runtime code, tests, generators, or public APIs.

Allowed:

- proposals
- comparisons
- rejected/accepted option framing
- questions for implementation tracks

### `:embed_shadow_safety`

For Rails embed and Contractable migration pressure tests.

Do not change production request behavior unless a private target track
explicitly allows it.

Allowed:

- synchronous legacy-first execution
- optional asynchronous shadow execution
- lightweight persistence or report seams when scoped by the track
- mismatch reporting
- matcher vocabulary sketches such as exact, completion, structure, type,
  inclusion, one-of, and range

### `:human_sugar_parallel_form`

For DSL design that has both agent-clean and human-sugar forms.

Keep both forms valid and equivalent:

- clean object/configuration form for agents and generated code
- compact sugar DSL for humans
- no sugar that prevents explicit low-level construction
- no hidden behavior that cannot be represented in the clean form

## Supervisor Notes

[Architect Supervisor / Codex]

Accepted sets for immediate use:

- `:interactive_poc_guardrails`
- `:activation_safety`
- `:research_only`
- `:embed_shadow_safety`
- `:human_sugar_parallel_form`

Next active tracks should cite these sets instead of repeating long negative
lists. Existing historical tracks do not need mechanical rewrites.
