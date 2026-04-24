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
