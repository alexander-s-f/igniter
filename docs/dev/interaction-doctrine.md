# Interaction Doctrine

Interaction is an affordance plus pending state, interpreted through a surface,
session, policy, evidence, and outcome context.

This doctrine aligns current Igniter interaction language across application,
web, operator, capsule, and activation review surfaces. It is
documentation-only. It does not introduce a shared interaction package, runtime
object, browser transport, workflow engine, runtime agent execution, AI
provider integration, cluster routing/placement, route activation, host
activation, or application-side inspection of web screen graphs.

## Why This Exists

Igniter already has several interaction surfaces:

- application flow sessions with active pending inputs/actions
- web surface manifests with candidate asks/actions/streams/chats
- operator and orchestration surfaces with accountable follow-up
- capsule transfer reports with supplied surface metadata
- host activation readiness/plans with review-only operations

These surfaces should share language without merging ownership.

## Relationship To Handoff

Handoff is ownership transfer.

Interaction is a participant-facing affordance and its current pending state.

Some interactions produce handoffs. Some handoffs require interactions. They
should not collapse into one model.

Examples:

- an `ask` is an interaction
- assigning that pending item to another queue is a handoff
- an activation plan operation is an interaction affordance for review
- transferring responsibility for that plan to a host operator is a handoff

## Conceptual Vocabulary

These are conceptual terms, not proposed class names.

### Subject

The thing the interaction concerns.

Current examples:

- flow session
- screen
- capsule
- activation plan
- operator item
- future agent task

### Participant

A human, agent, host, service, queue, lane, or role involved in the
interaction.

Current examples:

- user
- operator
- application host
- web surface
- queue
- lane
- future AI agent

### Affordance

Something available to do, provide, inspect, or observe.

Current examples:

- ask
- action
- stream
- chat
- artifact
- approval
- manual action
- mount-intent review
- activation-plan operation

### Pending State

The active request for input, action, approval, reply, review, or completion.

Current examples:

- `PendingInput`
- `PendingAction`
- operator inbox item
- manual host wiring action
- activation readiness blocker
- activation plan operation awaiting review

### Surface Context

Where the interaction can be presented or inspected.

Current examples:

- `SurfaceManifest`
- web surface metadata
- mounted operator console
- application capsule report
- activation plan review output

### Session Context

The durable or restorable state that makes an interaction concrete.

Current examples:

- `FlowSessionSnapshot`
- `FlowEvent`
- future `AgentSession`
- execution id plus node/token identity

### Policy Context

The constraints that govern allowed next moves.

Current examples:

- required input
- allowed operator actions
- queue or lane policy
- host activation readiness blockers
- forbidden runtime behavior
- future credential locality policy

### Evidence

The proof, trace, or source behind current interaction state.

Current examples:

- event history
- action history
- transfer receipt counts
- activation plan operations
- surface projection reports
- diagnostics

### Outcome

The result after an interaction is answered, rejected, completed, delegated, or
recorded.

Current examples:

- appended `FlowEvent`
- updated flow snapshot
- operator action result
- transfer receipt
- readiness finding
- activation plan verification result

## Current Surface Mapping

### Application Flow Sessions

Application owns active local interaction state.

Current artifacts:

- `FlowSessionSnapshot`
- `FlowEvent`
- `PendingInput`
- `PendingAction`
- `ArtifactReference`
- `Environment#start_flow`
- `Environment#resume_flow`

Boundary:

- this is not a general flow engine
- application does not require `igniter-web`
- no browser transport, runtime agent execution, distributed session, or
  cluster placement is implied

### Web Surface Metadata

Web owns candidate interaction metadata.

Current artifacts:

- `SurfaceManifest#interactions`
- `ask`
- `action`
- `stream`
- `chat`
- `Igniter::Web.flow_pending_state(...)`
- `Igniter::Web.flow_surface_projection(...)`

Boundary:

- web screen graphs stay web-owned
- application may consume supplied plain hashes
- `SurfaceManifest` does not execute contracts
- candidate interactions are not active pending state until an application
  flow snapshot or another owner makes them active

### Operator And Orchestration Surfaces

Operator surfaces own accountability and action review around pending work.

Current concepts:

- queue
- channel
- lane
- assignee
- action history
- handoff history
- approved/replied/completed/dismissed states
- runtime/orchestration summaries

Boundary:

- operator state should remain explicit and auditable
- read-only query surfaces should precede broader workflow machinery
- action handling belongs to accepted package tracks, not this doctrine

### Capsule And Activation Review

Capsule and activation reports own transfer and host review state.

Current artifacts:

- handoff manifest
- transfer receipt
- host activation readiness
- host activation plan
- supplied web surface metadata
- mount intents
- manual actions
- blockers and warnings

Boundary:

- these are review/planning artifacts
- mount-intent review is not mount binding
- readiness and plans are not host activation
- no loading, booting, route activation, browser traffic, contract execution,
  discovery, or cluster placement is implied

## Working Rules

- Use interaction language when a participant can provide, choose, inspect, or
  observe something.
- Keep candidate interactions separate from active pending state.
- Keep web surface metadata separate from application session durability.
- Keep review operations separate from execution.
- Preserve evidence and policy context when compacting interaction state.
- Prefer read-only reports before broader runtime abstractions.

## What Is Not Accepted Yet

Not accepted:

- new `igniter-interactions` package
- shared runtime interaction object
- browser form submission or resume transport
- workflow engine behavior
- runtime agent execution
- autonomous AI interaction handling
- AI provider calls
- cluster routing or placement
- web screen graph inspection by application
- route activation
- mount binding
- host activation
- hidden project discovery
- mutation of sessions outside accepted APIs

Future work may propose one of these only through a narrow accepted `docs/dev`
track with package ownership, acceptance criteria, and verification.

## Graduation Criteria For Future Work

A future interaction-related idea may graduate only if it can be stated as one
of:

- docs-only doctrine
- read-only report over existing explicit artifacts
- narrow package-local value object or facade
- isolated example pressure test

Likely safe next step, if repeated pressure appears:

- a package-local read-only report that normalizes existing application flow
  snapshots, supplied web interaction metadata, capsule review artifacts, and
  operator read models without executing anything

Still deferred:

- shared cross-package interaction runtime
- generalized observation graph
- distributed interaction routing
- autonomous agent interaction execution

