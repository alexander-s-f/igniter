# Agent-Native Application Track Proposal

Status: proposal for discussion.

Scope:

- `packages/igniter-application`
- `packages/igniter-web`

Audience:

- [Architect Supervisor / Codex]
- [Agent Application / Codex]
- [Agent Web / Codex]

## Architect Supervisor Evaluation

[Architect Supervisor / Codex] Status: accepted as a product direction, not
accepted as one implementation slice.

The proposal is directionally right: Igniter should support compact, portable,
agent-native applications where application owns lifecycle/session/manifest
semantics and web owns human interaction surfaces. It also fits the capsule
model already landed in `ApplicationLayout`, `ApplicationBlueprint`,
`ApplicationStructurePlan`, capsule exports/imports, `ApplicationWebMount`,
`SurfaceStructure`, and `SurfaceManifest`.

The main architectural correction is sequencing. We should not jump straight to
a large "agent application framework" API. The next track should introduce a
small inspectable interaction/session model that can support agents later
without smuggling cluster, browser, or agent-runtime ownership into
`igniter-application` or `igniter-web`.

### Accepted Into The Next Track

[Architect Supervisor / Codex] Accept:

- the product thesis: long-lived, interactive, proactive,
  human-in-the-loop agent applications are a first-class Igniter target
- the two-user framing: application developers and agents both need readable,
  inspectable app surfaces
- package responsibilities:
  - `igniter-application` owns lifecycle, services, interfaces, sessions,
    events, snapshots, manifest/capsule metadata, and transport-ready seams
  - `igniter-web` owns screens, interaction graphs, rendering, web surface
    manifests, and web transport bindings
  - future `igniter-cluster` owns routing, placement, remote coordination, and
    distributed delivery
- the strictness policy: high-level authoring can infer, but compiled/runtime
  shapes must be explicit, serializable, and testable
- the vocabulary direction: `flow`, `session`, `event`, `ask`, `action`,
  `artifact`, `interface`, `agent`, and `manifest`
- portable manifest metadata for flows, surfaces, required contracts,
  services, interfaces, agents, imports, and exports
- semantic `ask` and `action` as interaction metadata, not merely rendered HTML
- web surface manifest enhancements that describe imports/exports without
  forcing application to inspect web internals

### Accepted With Constraints

[Architect Supervisor / Codex] Accept with constraints:

- `flow`
  may become the developer-facing term, but the first implementation should be a
  facade over existing application session durability. Do not add a broad flow
  engine yet.
- `start_flow` / `resume_flow`
  should begin as thin, explicit APIs around a typed session snapshot and event
  envelope. They should not infer agent orchestration, cluster placement, or
  browser transport.
- `host interfaces`
  are accepted as application-owned capabilities, but initially they should be
  metadata over the existing interface/service registry. Policy hooks can come
  later.
- `event history`
  is accepted as append-only session metadata for inspection and resume. Full
  event sourcing/replay is deferred.
- `agent`
  references may appear in manifests and web surfaces as metadata now. A real
  autonomous agent runtime belongs to a later agent/cluster/runtime track.
- `approval`
  is accepted as sugar over `ask` plus `action`, but not as a separate runtime
  primitive until pending input/action shapes are stable.
- `handoff`
  is accepted as metadata and future workflow vocabulary. Do not implement
  ownership transfer in `igniter-web`; application or a future orchestration
  layer must own it.

### Deferred

[Architect Supervisor / Codex] Defer:

- the proposed block API:
  `Igniter::Application.build_profile(:operator_console) do ... end`
- `mount_web ... do` sugar inside application
- a complete `FlowSession` engine
- durable distributed sessions
- browser form submission/resume transport
- agent mesh/routing
- full artifact storage
- replay semantics
- a dedicated approval queue implementation
- full example applications such as `investigation_wizard` until the session
  value objects are small and stable

These may be good, but they are not the next slice.

### Rejected

[Architect Supervisor / Codex] Reject for the next track:

- making web request lifecycle own long-lived state
- making `igniter-application` depend on `igniter-web`
- making `igniter-web` define application capsule semantics
- putting cluster placement or remote coordination into `igniter-application`
- adding CRUD/resource/controller vocabulary as the primary model
- requiring every `ask` to have browser-specific behavior
- hiding runtime transitions behind high-level magic that cannot be serialized
  and tested
- treating chat as the core model; chat is one interaction node among several

### Accepted Next Track

[Architect Supervisor / Codex] New track name:

```text
Agent-Native Interaction Session Track
```

Goal:

Define the smallest application-owned session/event snapshot model that lets
web describe pending asks/actions/streams/artifacts and lets future agents
inspect or resume workflows without requiring cluster or browser ownership.

Initial application-owned shapes:

- `FlowEvent`
- `FlowSessionSnapshot`
- `PendingInput`
- `PendingAction`
- `ArtifactReference`

[Agent Application / Codex] status: these application-owned value objects have
landed, together with a thin `Environment#start_flow` / `#resume_flow` facade
over the existing application session store.

[Agent Application / Codex] critique/constraint: the landed facade should not
be treated as approval for a broad flow engine yet. It is a stable
snapshot/event envelope for inspection and resume. State machines, contract
execution, browser submission, real agent runtime, and cluster placement remain
deferred.

Initial web-owned responsibilities:

- map `ask`, `action`, `stream`, `chat`, `compare`, and future `artifact`
  screen nodes into serializable surface/session metadata
- extend `SurfaceManifest` only with plain imports/exports and pending
  interaction metadata
- keep rendering separate from session durability

Initial example target:

```text
examples/application/agent_native_plan_review.rb
```

It should prove:

- one capsule
- one web surface
- one screen with `ask`, `action`, `stream`, `chat`
- one application-owned session snapshot
- one event envelope
- one resume call that appends an event and updates pending state
- surface manifest remains serializable

This example should use metadata or simple callable placeholders for agents.
No real agent runtime, browser transport, or cluster coordination is required.

### First Acceptance Checklist

[Architect Supervisor / Codex] The next implementation slice is accepted only
when:

- `igniter-application` can create, fetch, and update an agent-native flow
  session without loading `igniter-web`
- session snapshots serialize with stable keys for pending inputs, pending
  actions, events, artifacts, status, and timestamps
- event envelopes serialize with stable `id`, `session_id`, `type`, `source`,
  `target`, `payload`, and `timestamp`
- `igniter-web` can describe asks/actions/streams/chats in metadata without
  owning session durability
- focused specs pass for application-only session values and web-only surface
  metadata
- no cluster, browser, or real agent runtime is required

This proposal is written from the point of view of an application developer who
wants to build compact, portable, high-quality distributed agent applications.
The target is not a chat wrapper around an agent. The target is a serious
application model for long-lived, interactive, proactive, human-in-the-loop
agent workflows.

## Product Thesis

Igniter should make it easy to build agent-native applications where agents can:

- collaborate with users over long-running flows
- ask for structured input
- expose intermediate artifacts
- request approval
- stream progress and events
- hand work between agents, users, services, and contracts
- resume after minutes, days, or process restarts
- remain portable across local app, server, capsule, and future cluster hosts

The current package split is promising:

- `igniter-application` is becoming the local application runtime, lifecycle,
  manifest, provider, service, interface, mount, and session layer.
- `igniter-web` is becoming the interaction surface layer for screens, chats,
  streams, actions, asks, composed view graphs, and web-owned surface metadata.

The next track should make that split explicit and product-shaped.

## Two Primary Users

This track has two first-class users:

1. Application developers.
2. Agents.

Application developers need an expressive, compact authoring experience. They
should be able to describe an agent application without hand-building glue code
for every input, event stream, approval button, and session transition.

Agents need a structured runtime and interaction protocol. They should not only
produce text. They should be able to inspect available surfaces, emit events,
request user input, expose artifacts, wait for approvals, trigger actions, and
resume flows through well-defined contracts.

This means the API can allow some convenient magic at the higher authoring
layers, as long as the lower layers remain strict:

- high-level application and web authoring may infer obvious routes, targets,
  form bindings, screen zones, and session wiring
- lower-level contract, session, event, manifest, and transport models must stay
  explicit, inspectable, serializable, and testable

Developer convenience is allowed. Runtime ambiguity is not.

## Desired Developer Experience

An application developer should be able to write something close to:

```ruby
app = Igniter::Application.build_profile(:operator_console) do
  manifest name: :research_ops, root: "apps/research_ops"

  provider :llm, with: Providers::OpenAI
  service :documents, with: Services::DocumentStore

  interface :notify_user, with: Interfaces::UserNotification
  interface :request_approval, with: Interfaces::ApprovalQueue

  mount_web :console, path: "/console" do
    screen :investigation, title: "Investigation" do
      zone :main do
        show :case_summary
        stream :agent_activity
        ask :clarification, as: :textarea
        compare :current_plan, :proposed_plan

        action :approve_plan, run: Contracts::ApprovePlan
        action :revise_plan, run: Contracts::RevisePlan

        chat with: Agents::Investigator
      end
    end
  end
end
```

The runtime should then expose a compact session API:

```ruby
env = app.boot

session = env.start_flow(:investigation, input: { case_id: "case_123" })
session.snapshot
session.pending_inputs
session.pending_actions
session.events

env.resume_flow(
  session.id,
  event: {
    type: :user_reply,
    target: :clarification,
    payload: { text: "Check source citations first." }
  }
)
```

The authoring layer may infer helpful details, but the runtime should always be
able to explain the resulting flow, imports, exports, events, pending inputs,
and transport shape.

## Core Scenarios

### Long-Lived Wizard

A multi-step process where an agent guides a user through decisions, gathers
structured input, renders intermediate artifacts, persists state, and resumes
cleanly.

Examples:

- onboarding a complex service
- incident resolution
- research workflow
- deployment review
- document preparation

### Agent Operator Console

A screen where the user observes agents at work, sees event streams, reviews
artifacts, approves or rejects actions, and intervenes through chat or
structured input.

### Proactive Agent Flow

An agent can initiate a user-facing event:

- "I need a decision."
- "I found a risk."
- "I need credentials."
- "The preview is ready."
- "This action requires approval."

This should not be modeled as a random side channel. It should be a structured
session event that can be rendered by web, audited by application, and
transported by future hosts.

### Distributed Agent Application

This proposal does not ask `igniter-application` or `igniter-web` to implement a
cluster runtime. It does ask both packages to avoid blocking that future.

Application and web surfaces should describe:

- contracts
- services
- interfaces
- agents
- session capabilities
- imports and exports
- transport-ready commands, streams, and pending interactions

Future `igniter-cluster` work can then decide routing, placement, distribution,
and coordination.

### Portable Capsule

An application should be portable as a capsule containing contracts, services,
providers, web surfaces, manifests, imports, exports, and interaction metadata.

Web is an optional surface inside an application capsule. It should not become
the application itself.

## Package Responsibilities

### `igniter-application`

`igniter-application` should answer:

> How does an agent application live?

It should own:

- application manifest
- layout profile
- boot and shutdown lifecycle
- provider lifecycle
- service registry
- host interfaces
- mount registration
- session durability
- flow/session APIs
- event envelopes
- snapshots
- local transport adapter seams

It should not own:

- web component rendering
- Arbre concepts
- screen layout internals
- cluster placement or distributed coordination

### `igniter-web`

`igniter-web` should answer:

> How does a human interact with long-lived agent processes?

It should own:

- screen DSL
- interaction graph composition
- web surface manifest metadata
- web-local surface structure
- rendering of asks, actions, streams, chats, comparisons, timelines, and
  artifacts
- web transport bindings for commands, streams, and form submissions

It should not own:

- session durability
- provider lifecycle
- service registry
- cluster routing
- application-level capsule semantics

### Future `igniter-cluster`

Future cluster work should answer:

> Where do flows, agents, contracts, and surfaces run?

It should eventually own:

- placement
- routing
- remote session coordination
- distributed event delivery
- agent mesh concerns
- durable distributed execution

This track should prepare clean metadata and adapter seams for that future
without implementing it prematurely.

## Runtime Vocabulary

The proposed shared vocabulary:

- `application`: the host-owned runtime unit
- `surface`: a user-facing interaction boundary, optionally web-backed
- `screen`: a composed interaction graph for one user-facing state or workflow
- `flow`: a long-lived process driven by contracts, agents, events, and user
  interactions
- `session`: a durable runtime instance of a flow or composition
- `event`: a structured fact emitted by a user, agent, contract, service, or
  system
- `ask`: a structured request for user input
- `action`: an invokable command or contract transition
- `artifact`: a produced object that can be shown, compared, downloaded, or
  passed into later steps
- `interface`: a host-owned capability exposed to flows and agents
- `agent`: an autonomous participant that can inspect state, emit events,
  request input, and trigger contract-backed work
- `manifest`: a portable description of available and required capabilities

## Application Track Requests

[Agent Application / Codex] should consider the following additions or
refinements.

### General Flow Session API

The existing compose and collection session seams should grow toward a more
general flow vocabulary:

```ruby
env.start_flow(:investigation, input: ...)
env.resume_flow(session_id, event: ...)
env.fetch_session(session_id)
env.list_sessions(scope: ...)
```

Compose and collection sessions can remain lower-level specializations, but
developer-facing app code should be able to talk about flows.

### Host Interfaces

Interfaces should be the explicit app-owned way to describe host capabilities:

```ruby
interface :notify_user
interface :request_approval
interface :open_url
interface :write_file
interface :schedule_followup
```

These are not web components. They are runtime capabilities that an agent or
flow may request through explicit contracts and host policy.

### Session Snapshot Shape

A session snapshot should be useful for UI rendering, resume, audit, transport,
and debugging.

Suggested minimal shape:

```ruby
{
  session_id: "...",
  flow_name: :investigation,
  status: :waiting_for_user,
  current_step: :review_plan,
  pending_inputs: [],
  pending_actions: [],
  events: [],
  artifacts: [],
  updated_at: Time.now
}
```

### Event Envelope

Suggested minimal event envelope:

```ruby
{
  id: "...",
  session_id: "...",
  type: :user_reply,
  source: :user,
  target: :clarification,
  payload: {},
  timestamp: Time.now
}
```

Recommended source values:

- `:user`
- `:agent`
- `:system`
- `:contract`
- `:service`
- `:interface`

### Portable Manifest Metadata

The application manifest should be able to explain:

- available flows
- exported surfaces
- required contracts
- required services
- required host interfaces
- required agents
- whether a dependency is local, imported, or transport-ready

## Web Track Requests

[Agent Web / Codex] should consider making `igniter-web` a language for agent
interaction, not just web pages.

Suggested screen DSL:

```ruby
screen :plan_review do
  title "Plan Review"

  zone :main do
    show :summary
    stream :activity
    ask :decision, as: :choice, options: [:approve, :revise, :reject]
    compare :current_plan, :proposed_plan
  end

  zone :actions do
    action :approve, run: Contracts::Approve
    action :request_changes, run: Contracts::RequestChanges
  end

  chat with: Agents::Planner
end
```

Suggested first-class primitives:

- `show` for artifacts and read models
- `ask` for structured user input
- `action` for command or contract invocation
- `stream` for session events and live projections
- `chat` for agent dialogue
- `compare` for diff and review workflows
- `timeline` for process history
- `status` for flow and session state
- `handoff` for transfer between agents, users, or roles
- `artifact` for generated outputs
- `approval` as a specialized ask/action pattern

### Semantic `ask`

`ask` should not only render an input field. It should describe a pending
session input.

Example:

```ruby
ask :deployment_window,
    as: :datetime,
    required: true,
    resume_with: Contracts::SetDeploymentWindow
```

This should imply:

- web can render the field
- session can report that it is waiting for this input
- transport can submit the answer
- audit can record who answered and when
- the flow can resume through a strict contract path

### Surface Manifest Enhancements

The web surface manifest should describe:

- routeable pages
- routeable screens
- command endpoints
- stream endpoints
- webhook endpoints
- required contracts
- required services
- required projections
- required agents
- required host interfaces
- whether a screen supports session resume

## Convenience And Magic Policy

Because this track serves both application developers and agents, ergonomics
matter.

Acceptable high-level conveniences:

- infer route names from screen names
- infer form target from `ask ... resume_with:`
- infer stream target from current session when a screen is session-bound
- infer default zones for common screen shapes
- provide `approval` as sugar over `ask` plus `action`
- provide default event rendering for known event types
- provide default artifact rendering based on metadata

Required lower-level strictness:

- every inferred binding must be inspectable
- every action must resolve to a contract or explicit callable target
- every pending input must have a stable name and payload shape
- every event must have a structured envelope
- every surface import/export must be serializable
- every session transition must be testable without a browser

The authoring layer may be friendly. The compiled/runtime model must be
precise.

## MVP Success Criteria

This track is successful when the repo can include a small example application
that demonstrates:

- one application capsule
- one web surface
- one long-lived flow
- one agent or chat node
- one event stream
- one pending `ask`
- one approve/reject action
- session snapshot and resume
- portable surface manifest
- tests that boot the app, mount web, start a session, render a screen, submit
  input, and resume the session

Possible example names:

- `examples/agent_operator_console`
- `examples/investigation_wizard`
- `examples/plan_review_console`

## Non-Goals

This track should not:

- implement a full cluster runtime inside `igniter-application`
- turn `igniter-web` into a CRUD-first MVC framework
- make web request lifecycle the owner of long-lived state
- require hand-written HTML strings as the primary authoring path
- couple interaction surfaces to only one frontend transport
- design only for chat
- hide runtime ambiguity behind developer-facing magic

## Suggested Implementation Sequence

1. Define shared session, event, pending input, pending action, and artifact
   shapes in `igniter-application`.
2. Add or refine a general flow session facade over existing compose and
   collection session capabilities.
3. Make `igniter-web` screen nodes carry enough semantic metadata to bind asks,
   actions, streams, chats, and artifacts to sessions.
4. Extend `SurfaceManifest` to describe agent interaction imports and exports.
5. Build a minimal example application that exercises the full loop.
6. Add smoke specs for boot, mount, screen render, session start, input submit,
   resume, and manifest export.

## Open Questions

- Should `FlowSession` be a new public abstraction, or a facade over existing
  compose and collection sessions until the shape stabilizes?
- Should `ask` always require an explicit `resume_with:` target, or can
  session-bound screens infer a default resume route?
- What is the smallest useful `Agent` reference shape for manifests before a
  dedicated agent package exists?
- Should host interfaces be callable services with stricter metadata, or a
  separate registry with policy hooks?
- Which parts of event history are mandatory for replay versus optional for
  audit/debug rendering?
- Should web rendering consume session snapshots directly, or should it consume
  a web-specific projection derived from snapshots?

## Short Formula

`igniter-application` should answer:

> How does an agent application live?

`igniter-web` should answer:

> How does a human interact with long-lived agent processes?

Together they should let developers and agents build serious agent applications
compactly, portably, and without bespoke glue code around every interaction.
