# Agent-Native Interaction Session Track

This is the working implementation track for the first accepted slice of
`docs/dev/agent-native-application-track-proposal.md`.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report handoffs with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Track Decision

[Architect Supervisor / Codex] Accepted direction:

Igniter should support agent-native applications where long-lived,
human-in-the-loop workflows are explicit, inspectable, portable, and resumable.

[Architect Supervisor / Codex] First implementation slice:

Build the smallest application-owned session/event snapshot model that lets web
describe pending asks/actions/streams/artifacts and lets future agents inspect
or resume workflows without requiring cluster, browser, or real agent runtime
ownership.

This is not a full flow engine yet.

## Scope

In scope:

- application-owned value objects for flow/session/interaction state
- metadata-first start/resume helpers over existing session durability
- web-owned extraction of pending interaction metadata from screen graphs
- serializable surface manifests that include interaction requirements
- one small plan-review example proving the loop without a real agent runtime

Out of scope:

- cluster routing or placement
- distributed sessions
- browser form submission transport
- real autonomous agent runtime
- durable artifact storage
- event sourcing/replay guarantees
- `build_profile do ... end` DSL
- `mount_web ... do` inside application

## Shared Vocabulary

[Architect Supervisor / Codex] Use these names unless a stronger code-local
reason appears:

- `FlowEvent`
- `FlowSessionSnapshot`
- `PendingInput`
- `PendingAction`
- `ArtifactReference`

These values must be immutable or effectively immutable, serializable with
`to_h`, and useful without loading `igniter-web`.

## Task 1: Application Value Objects

Owner: `[Agent Application / Codex]`

Status: Done in the current application slice.

[Architect Supervisor / Codex] Accepted. The landed values are small,
serializable, application-owned, and do not require `igniter-web`.

[Agent Application / Codex] changed: added `FlowEvent`,
`FlowSessionSnapshot`, `PendingInput`, `PendingAction`, and
`ArtifactReference` as application-owned serializable values.

[Agent Application / Codex] expects web to consume: these shapes as plain
snapshot/event/interaction metadata when web needs to render pending asks,
actions, streams, or artifacts.

[Agent Application / Codex] must not require web to: load these values for
static surface manifest extraction. Web can continue emitting plain hashes and
application can normalize them at session boundaries.

Files likely owned:

- `packages/igniter-application/lib/igniter/application/flow_event.rb`
- `packages/igniter-application/lib/igniter/application/flow_session_snapshot.rb`
- `packages/igniter-application/lib/igniter/application/pending_input.rb`
- `packages/igniter-application/lib/igniter/application/pending_action.rb`
- `packages/igniter-application/lib/igniter/application/artifact_reference.rb`
- `packages/igniter-application/lib/igniter/application.rb`
- `packages/igniter-application/spec/igniter/application/environment_spec.rb`

Acceptance:

- `FlowEvent#to_h` includes:
  `id`, `session_id`, `type`, `source`, `target`, `payload`, `timestamp`,
  `metadata`
- `FlowSessionSnapshot#to_h` includes:
  `session_id`, `flow_name`, `status`, `current_step`, `pending_inputs`,
  `pending_actions`, `events`, `artifacts`, `metadata`, `created_at`,
  `updated_at`
- `PendingInput#to_h` includes:
  `name`, `input_type`, `required`, `target`, `schema`, `metadata`
- `PendingAction#to_h` includes:
  `name`, `action_type`, `target`, `payload_schema`, `metadata`
- `ArtifactReference#to_h` includes:
  `name`, `artifact_type`, `uri`, `summary`, `metadata`
- values normalize names/kinds to symbols where appropriate
- values freeze internal arrays/hashes or defensively duplicate them
- application specs prove these values serialize without requiring
  `igniter-web`

## Task 2: Application Flow Session Facade

Owner: `[Agent Application / Codex]`

Status: First thin facade landed.

[Architect Supervisor / Codex] Accepted as a thin facade over existing session
durability. This is not accepted as a general flow engine.

[Agent Application / Codex] changed: `Environment#start_flow` writes a
`kind: :flow` `SessionEntry` through the existing application session store and
returns a `FlowSessionSnapshot`.

[Agent Application / Codex] changed: `Environment#resume_flow` appends a
`FlowEvent`, updates `updated_at`, and persists the updated snapshot through the
same session store.

[Agent Application / Codex] critique/constraint: this is intentionally not a
flow engine. It does not infer contract execution, transition state machines,
agent orchestration, browser transport, artifact persistence, or cluster
placement. Those should remain separate tracks until the snapshot/event shape
has proven stable.

Files likely owned:

- `packages/igniter-application/lib/igniter/application/environment.rb`
- `packages/igniter-application/lib/igniter/application/session_entry.rb`
- `packages/igniter-application/spec/igniter/application/environment_spec.rb`

Acceptance:

- `Environment#start_flow(flow_name, input: {}, pending_inputs: [],
  pending_actions: [], artifacts: [], metadata: {})` or equivalent exists
- `Environment#resume_flow(session_id, event:)` or equivalent exists
- implementation stores flow sessions through existing `session_store`
- stored session entries use `kind: :flow`
- start returns or writes a `FlowSessionSnapshot`
- resume appends a `FlowEvent`
- resume updates `updated_at`
- fetching the session still works through existing `fetch_session`
- no web package is loaded or referenced
- no real agent runtime is required

Constraints:

- Do not build a full state machine yet.
- Do not infer contract execution.
- Do not add cluster or transport semantics.
- Keep this as a small facade over existing session durability.

## Task 3: Web Interaction Metadata Extraction

Owner: `[Agent Web / Codex]`

Files likely owned:

- `packages/igniter-web/lib/igniter/web/surface_manifest.rb`
- `packages/igniter-web/lib/igniter/web/screen_spec.rb`
- `packages/igniter-web/spec/igniter/web/skeleton_spec.rb`
- `packages/igniter-web/spec/igniter/web/composer_spec.rb`

Acceptance:

- web can describe pending asks from screen elements as plain hashes
- ask metadata includes stable name, input type, required flag, resume target
  when present, and source screen metadata
- action metadata includes stable name, target, role/purpose when available,
  and source screen metadata
- stream/chat metadata remains serializable and does not imply web-owned
  session durability
- `SurfaceManifest#to_h` can include interaction metadata without application
  needing to inspect screen graphs
- no application code depends on web internals

Constraints:

- Do not add browser form transport yet.
- Do not make `ask` require a browser-specific route.
- Do not execute contracts from `SurfaceManifest`.

Status: Done for the web-owned metadata slice.

[Architect Supervisor / Codex] Accepted. `SurfaceManifest` may describe
candidate pending interaction metadata, but application flow snapshots remain
the source of active pending state.

[Agent Web / Codex] changed: `SurfaceManifest#to_h` now includes
`interactions` with `pending_inputs`, `pending_actions`, `streams`, and `chats`
derived from screen specs.

[Agent Web / Codex] changed: `ask` metadata reports stable `name`,
`input_type`, `required`, optional resume `target`, `schema`, source screen
metadata, and remaining metadata.

[Agent Web / Codex] changed: `action` metadata reports stable `name`,
`action_type`, `target`, `payload_schema`, `role`, `purpose`, source screen
metadata, and remaining metadata.

[Agent Web / Codex] expects application to expose: application-owned
`PendingInput` and `PendingAction` value objects later if it wants to promote
these hashes into concrete flow session snapshots.

[Agent Web / Codex] must not require application to: inspect screen graphs,
render components, execute contracts, or own browser submission routes to read
web interaction metadata.

## Task 4: Agent-Native Plan Review Example

Owner: shared.

Primary: `[Agent Web / Codex]`

Review/adapter: `[Agent Application / Codex]`

File:

- `examples/application/agent_native_plan_review.rb`

Acceptance:

- builds an application capsule blueprint
- defines at least one web surface
- defines a screen with:
  - `ask`
  - `action`
  - `stream`
  - `chat`
- starts an application-owned flow session
- prints a serialized session snapshot
- resumes the flow with one user event
- prints updated event count or updated status
- builds a web surface manifest
- proves surface manifest imports/exports remain serializable
- does not require a browser, cluster runtime, or real agent runtime

Suggested smoke output keys:

```text
agent_native_plan_review_session_kind=flow
agent_native_plan_review_pending_inputs=...
agent_native_plan_review_pending_actions=...
agent_native_plan_review_events_before=...
agent_native_plan_review_events_after=...
agent_native_plan_review_surface_imports=...
agent_native_plan_review_surface_exports=...
```

[Agent Application / Codex] interim application-only example:
`examples/application/flow_session.rb` verifies the application-owned session
half of this loop before the shared web surface example is assembled.

Status: Done for the first metadata-first smoke path.

[Architect Supervisor / Codex] Accepted as the first end-to-end proof. The
example's explicit mapping from web metadata into application pending values is
the right temporary adapter shape. Do not hide that mapping behind framework
magic until the snapshot model stabilizes.

[Agent Web / Codex] changed: added
`examples/application/agent_native_plan_review.rb`.

[Agent Web / Codex] changed: the example builds an application capsule
blueprint, defines a web surface screen with `ask`, `action`, `stream`, and
`chat`, lifts the web surface into capsule export metadata, starts an
application-owned flow session, resumes it with one user event, and prints
serialized smoke flags.

[Agent Web / Codex] expects application to expose: the landed
`Environment#start_flow`, `Environment#resume_flow`, `FlowSessionSnapshot`,
`FlowEvent`, `PendingInput`, `PendingAction`, and `ArtifactReference` public
shapes.

[Agent Web / Codex] must not require application to: load `igniter-web`,
execute web routes, render screens, or know how `SurfaceManifest` extracted
interaction metadata.

## Task 5: Documentation Update

Owner: `[Architect Supervisor / Codex]` after agent handoffs, or agents may
append handoff notes using their role labels.

Files:

- `docs/dev/agent-native-application-track-proposal.md`
- `docs/dev/application-web-integration-tasks.md`
- optionally package READMEs if public API appears

Acceptance:

- accepted/rejected/deferred status remains clear
- landed implementation notes are marked with agent labels
- verification commands are listed
- next unanswered architecture question is explicit

## Review Gates

[Architect Supervisor / Codex] The slice is accepted only when all pass:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

And:

```bash
ruby examples/application/agent_native_plan_review.rb
```

Architecture gates:

- `igniter-application` does not require `igniter-web`
- `igniter-web` consumes only public application APIs
- session durability remains application-owned
- rendering remains web-owned
- no cluster runtime is introduced
- no real agent runtime is required
- all new runtime-facing shapes have stable `to_h`

Status: Passed for the first slice.

Latest verified commands:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

Result: `43 examples, 0 failures`.

```bash
ruby examples/application/flow_session.rb
ruby examples/application/agent_native_plan_review.rb
```

Both examples completed and reported successful smoke flags.

## Landed Slice Summary

[Architect Supervisor / Codex] Landed and accepted:

- application-owned `FlowEvent`
- application-owned `FlowSessionSnapshot`
- application-owned `PendingInput`
- application-owned `PendingAction`
- application-owned `ArtifactReference`
- `Environment#start_flow`
- `Environment#resume_flow`
- web-owned `SurfaceManifest#interactions`
- application-only `examples/application/flow_session.rb`
- shared metadata-first `examples/application/agent_native_plan_review.rb`

[Architect Supervisor / Codex] Still intentionally absent:

- flow state machine
- contract execution from flow events
- browser submit/resume transport
- real agent runtime
- cluster coordination
- artifact persistence

## Landed Read Model And Adapter Slice

[Architect Supervisor / Codex] Accepted. The read model and adapter slice landed
in the intended ownership shape:

- application owns `FlowSessionSnapshot.from_entry`, `Environment#flow_session`,
  `Environment#flow_sessions`, and boundary normalization for string-keyed
  hashes
- web owns `Igniter::Web::FlowInteractionAdapter` and
  `Igniter::Web.flow_pending_state(...)`
- application still receives only plain pending input/action hashes through
  `Environment#start_flow`
- `SurfaceManifest#interactions` remain candidate declarations
- `FlowSessionSnapshot#pending_inputs` and `#pending_actions` remain active
  runtime state

[Architect Supervisor / Codex] Verified after the read model and adapter cycle:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

Result: `43 examples, 0 failures`.

```bash
ruby examples/application/flow_session.rb
ruby examples/application/agent_native_plan_review.rb
```

Both examples completed and reported successful smoke flags.

## Previous Slice Notes

[Architect Supervisor / Codex] Previous recommended slice:

```text
Flow Snapshot Read Model And Adapter Stabilization
```

Goal:

Make the boundary between web-declared interaction metadata and
application-owned active pending state explicit enough that future browser,
agent, and host adapters can consume it without inspecting screen graphs.

Candidate tasks:

1. Add a small adapter/helper that converts web interaction metadata into
   application `PendingInput` / `PendingAction` hashes for a specific flow.
2. Decide whether the adapter belongs in `igniter-web`, an example helper, or a
   future bridge package. Do not put web-specific logic in `igniter-application`.
3. Add `FlowSessionSnapshot#waiting?` or similar read helpers only if they make
   examples/tests materially clearer.
4. Add status transition policy as metadata or explicit arguments, not a state
   machine.
5. Document that `SurfaceManifest#interactions` are candidate declarations,
   while `FlowSessionSnapshot#pending_inputs` and `#pending_actions` are active
   runtime state.

Status: Web-owned adapter helper landed.

[Agent Web / Codex] changed: added `Igniter::Web::FlowInteractionAdapter` and
`Igniter::Web.flow_pending_state(source, current_step:, metadata:)`.

[Agent Web / Codex] changed: the adapter accepts a `SurfaceManifest` or
interactions hash and returns plain `pending_inputs` / `pending_actions` hashes
compatible with `Environment#start_flow`.

[Agent Web / Codex] changed: `examples/application/agent_native_plan_review.rb`
now uses `Igniter::Web.flow_pending_state(...)` instead of hand-written mapping.

[Agent Web / Codex] expects application to expose: `Environment#start_flow`
continuing to accept plain hashes and normalize them into application-owned
`PendingInput` / `PendingAction` values.

[Agent Web / Codex] must not require application to: load the adapter, inspect
screen graphs, or treat every `SurfaceManifest#interactions` entry as active
runtime state.

[Agent Application / Codex] changed: added `FlowSessionSnapshot.from_entry`,
`Environment#flow_session(id)`, and `Environment#flow_sessions` so hosts and
adapters can read typed application-owned flow snapshots directly from the
session store.

[Agent Application / Codex] changed: application pending values and flow events
now accept string-keyed hashes at the boundary, while still storing normalized
application-owned values in `FlowSessionSnapshot`.

[Agent Application / Codex] note: web-declared interactions remain candidate
metadata until an adapter explicitly passes the selected pending state into
`Environment#start_flow`.

## Next Slice

[Architect Supervisor / Codex] Recommended next slice:

```text
Flow Resume Semantics And Status Policy
```

Goal:

Define the smallest explicit policy for how host/user/agent events affect a
flow snapshot without introducing a hidden state machine, contract runner, or
browser transport.

Candidate tasks:

1. Decide whether `Environment#resume_flow` should accept explicit status
   updates, pending input/action updates, or both.
2. Prefer explicit arguments such as `status:`, `pending_inputs:`,
   `pending_actions:`, `artifacts:`, or narrow helper methods over implicit
   event-type inference.
3. Preserve append-only `FlowEvent` history even when pending state is replaced
   or cleared.
4. Add focused specs for one answered pending input and one completed pending
   action.
5. Update `examples/application/flow_session.rb` or
   `examples/application/agent_native_plan_review.rb` to show an explicit
   resume/status change.

Acceptance:

- no application code loads `igniter-web`
- no web code mutates application session internals
- resume behavior is visible in `FlowSessionSnapshot#to_h`
- pending state changes are explicit at the API boundary
- status changes do not imply contract execution
- browser form submission remains deferred
- no real agent runtime is introduced

## Next Questions After This Slice

[Architect Supervisor / Codex] Do not answer these in the first slice unless
the implementation forces the issue:

- Should `FlowSessionSnapshot` become the primary public session read model?
- Should `ask resume_with:` require a contract target, or can it target a host
  interface?
- Should host interfaces get policy metadata before agent runtime lands?
- Should feature slices own their own flow declarations?
- Should web render directly from snapshots or from a web-owned projection of
  snapshots?
