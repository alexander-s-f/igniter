# Runtime Observatory Doctrine

Runtime observatory is a read-only view over explicit artifacts.

This doctrine gives agents and contributors shared language for describing
observability-shaped review surfaces across Igniter. It does not introduce a
runtime graph package, query language, graph database, global report object,
execution planner, runtime discovery, mutation, host activation, browser
transport, cluster routing, or autonomous agent execution.

## Why This Exists

Igniter now has many explicit artifacts:

- handoff notes and handoff manifests
- interaction/session snapshots
- web surface metadata
- capsule transfer reports and receipts
- activation readiness, plans, verification, and dry-run reports
- operator and orchestration read models
- cluster plans, observations, placement decisions, and mesh traces
- Research Horizon reports and supervisor reviews

Each artifact should remain owned by its package or track. Runtime observatory
language helps agents discuss how those artifacts relate in one review frame
without merging ownership.

## Relationship To Existing Doctrines

Handoff Doctrine explains ownership movement.

Interaction Doctrine explains affordances and pending state.

Runtime Observatory Doctrine explains how explicit artifacts can be observed
together in a bounded review frame.

It may contain handoff and interaction observations, but it must not redefine
handoff or interaction.

## Conceptual Vocabulary

These are conceptual terms, not proposed class names.

### Frame

A bounded review context.

Examples:

- one research handoff
- one operator execution overview
- one capsule transfer closure
- one activation readiness/plan review
- one cluster placement decision

### Node

An observed artifact or sub-artifact inside a frame.

Examples:

- flow session
- pending input
- operator item
- transfer receipt
- activation plan operation
- mesh attempt
- placement decision
- blocker

### Edge

A relationship between observed nodes.

Examples:

- owns
- blocks
- requires
- evidenced by
- derived from
- shown on
- handoff to
- resumes
- routes to
- forbids

### Facet

A dimension useful for slicing or summarizing a frame.

Examples:

- kind
- owner
- status
- lifecycle
- policy
- capability
- trust
- surface
- pending
- risk
- requires human
- executable
- review only

### Evidence

The source proof behind an observation.

Examples:

- source document
- serialized report hash
- event history
- action history
- verification command
- mesh trace
- receipt count

### Blocker

An observed reason that prevents a later operation or decision.

Examples:

- missing host export
- invalid receipt
- failed verification
- denied trust/admission decision
- incomplete required input
- policy refusal

### Warning

An observed issue that does not necessarily block the review frame but should
remain visible.

Examples:

- optional import missing
- degraded placement
- manual action still required
- stale observation
- incomplete supplied metadata

### Metadata

Opaque context carried forward without interpretation.

Examples:

- web surface metadata supplied to application reports
- track labels
- actor/origin/channel values
- host decision notes
- research classification

## Current Surface Mapping

### Research And Track Review

Frame:

- one research report or implementation track handoff

Nodes:

- track
- changed files
- verification result
- requested decision
- supervisor response

Edges:

- handoff to supervisor
- evidence from diff/checks
- accepted by review

### Capsule Transfer And Activation Review

Frame:

- one capsule transfer or host activation review chain

Nodes:

- handoff manifest
- transfer receipt
- activation readiness
- activation plan
- activation dry-run or verification report
- manual action
- blocker
- warning

Edges:

- plan derived from readiness
- blocker forbids execution
- receipt evidences transfer closure
- mount-intent operation shown on supplied web metadata

Important:

This is review only. It does not activate the host, bind mounts, load
constants, boot apps, execute contracts, or route work.

### Operator And Orchestration Review

Frame:

- one execution/operator overview

Nodes:

- session
- pending input
- pending action
- operator record
- lane
- queue
- assignee
- latest action

Edges:

- operator item resumes session
- handoff moves ownership to queue
- action history evidences state
- pending state shown on surface

Important:

This is observation only. Handling an operator item belongs to accepted app
operator surfaces, not to this doctrine.

### Cluster And Mesh Review

Frame:

- one route, placement, remediation, or mesh trace review

Nodes:

- peer observation
- capability query
- placement decision
- rejected candidate
- trust decision
- governance evidence
- mesh attempt

Edges:

- peer offers capability
- policy rejects candidate
- placement chooses peer
- governance evidence supports decision

Important:

Cluster-owned observation and query systems remain cluster-owned. Runtime
observatory language does not replace `NodeObservation`, `ObservationQuery`, or
MeshQL-like cluster concepts.

## Working Rules

- Observe explicit artifacts only.
- Preserve source ownership.
- Preserve evidence references.
- Keep frames bounded.
- Prefer docs-only or package-local read-only reports before broader models.
- Do not convert observation into execution.
- Do not use observatory language to justify hidden discovery.
- Do not flatten application, web, operator, cluster, and research ownership
  into one global graph.

## What Is Not Accepted

Not accepted:

- new observatory package
- shared runtime graph object
- graph database
- generalized query language
- global report object
- runtime discovery
- hidden project scanning
- mutation of source artifacts
- activation execution
- mount binding
- route activation
- browser transport
- contract execution
- cluster routing or placement
- AI provider calls
- autonomous agent execution

Future work may propose one of these only through a narrow accepted `docs/dev`
track with package ownership, acceptance criteria, and verification.

## Future Graduation Criteria

A future observatory-related idea may graduate only if it can be stated as one
of:

- docs-only doctrine
- read-only report over existing explicit artifacts
- narrow package-local value object or facade
- isolated example pressure test

Good first report candidates:

- activation review frame
- operator runtime frame
- research handoff frame

Bad first candidates:

- global runtime graph
- cross-project graph database
- new query language
- autonomous agent planner
- cluster-wide routing surface

