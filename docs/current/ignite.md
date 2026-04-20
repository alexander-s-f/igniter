# Igniter Ignite

This note captures the current direction for cluster ignition and deployment
bootstrap.

Current implementation status:

- normalized `Igniter::Ignite::*` value objects are landed
- `Igniter::Stack#ignition_plan`, `#ignite`, `#confirm_ignite_join`, and `#reconcile_ignite` are landed
- local replicas already go through agent-owned ignition planning
- remote `ssh_server` targets can now go through admission-aware bootstrap
- built-in server startup now exposes `after_start` hooks, which Igniter uses to emit a runtime-owned ignite join signal after bind/listen
- remote join closure can now be reconciled from real mesh discovery instead of relying only on an external manual confirmation step
- `Stack#ignite(...)` can now run a bounded seed-side watcher and auto-close `bootstrapped -> joined` when the peer appears in mesh discovery during the ignition window
- `IgnitionReport` now exposes progress/timeline shape (`latest_event`, `by_event_type`, `recent_events`, `target_timelines`)
- app diagnostics now surface ignition progress, not only final summary
- stack runtime now also keeps a durable ignition trail under `var/ignite/`, so ignition history survives process boundaries and can be surfaced separately from the current in-memory report
- persisted ignition targets can now also appear in the unified app operator surface, so operator overview can show agent/orchestration state and ignition lifecycle in one plane
- mounted operator actions can now drive ignition lifecycle too (`approve`, `retry_bootstrap`, `reconcile_join`, `dismiss`) through the same operator action API used by orchestration records
- app-level generic operator verbs can now also dispatch to ignite records, so mounted operator workflows are starting to converge on one app-facing action surface instead of separate ignite-only and orchestration-only entrypoints
- ignite records now also expose richer policy-shaped metadata and latest operator identity dimensions, which makes audit filters and operator summaries more honest across both orchestration and ignition
- ignition policy/action language is now starting to separate:
  - operator-facing action language (`approve`, `retry`, `complete`, `dismiss`)
  - lifecycle meaning (`resolve`, `retry`, `dismiss`)
  - ignite execution operations (`approve`, `retry_bootstrap`, `reconcile_join`, `dismiss`)
- legacy ignite-specific action names are still accepted as aliases, but the mounted operator surface can now speak a more unified workflow language
- ignite handling now also goes through the shared `Igniter::App::Operator` layer (`Policy`, `HandlerResult`, `Handlers::Base`, `Handlers::IgniteHandler`) instead of a one-off branch in `App`, which makes convergence with orchestration more structural than cosmetic
- operator dispatch is now also explicit through `Igniter::App::Operator::Dispatcher` and `HandlerRegistry`, so ignite is chosen through the same canonical dispatch surface as orchestration records instead of special branching in `App.handle_operator_item`
- operator records now also carry explicit `record_kind` and a shared `lifecycle` contract (`status`, `combined_state`, `default_operation`, `allowed_operations`, `runtime_completion`, `actionable`, `terminal`, `history_count`), so mounted API/UI and handler dispatch can rely on one canonical schema instead of inferring lifecycle from scattered fields

This means the current `ignite` line has crossed an important boundary:

- `ignite` is no longer only a config/specification draft
- it is now also a real execution surface with lifecycle, persistence, diagnostics, and operator handling
- the remaining work is mostly about hardening and convergence, not about inventing the basic shape

It is a specification draft, not a frozen public API.

The goal is to make the next cluster boot model explicit before we implement
too many partial mechanisms around it.

## Core Thesis

Cluster ignition should be agent-driven.

Not:

- a shell script hidden outside Igniter
- a static topology map pretending to be the runtime
- cluster internals directly doing ad-hoc SSH orchestration

But:

- one live stack node receives an ignite intent
- an Igniter deployment agent executes the bootstrap workflow
- peer nodes are brought up as stack runtimes
- cluster admission and capability publication finish the join

The metaphor is:

- one lit candle
- lighting the next candles
- until the cluster becomes a live capability field

## Settled Direction

The following points feel directionally settled:

- `node` means a running stack umbrella
- a node may host several mounted apps
- `cluster` means a dynamic set of running stack nodes
- peers should start as equal stack nodes
- differentiation should come later from capabilities, trust, policy, and load
- static role-first machine classes are the wrong center

## One Connection Point Applied To Ignite

Ignition should also follow the one-connection-point rule.

That means:

- deployment intent is declared in one place
- execution responsibility is owned in one place
- teardown or detachment should be traceable to the same surface

The likely split is:

- base stack runtime config in `stack.yml`
- environment-specific ignite intent in `config/environments/<env>.yml`
- execution through a built-in deployment/ignition agent
- cluster join through one admission/trust path

That is also consistent with the broader stack doctrine:

- stack runtime has one connection point
- app composition has one connection point
- ignite intent should also have one connection point

We should not end up with deployment behavior scattered between ad-hoc shell
scripts, separate topology files, and runtime-only conventions.

## Why An Agent Should Execute Ignition

Ignition is not a single shell command.

It is a long-running, stateful, approval-sensitive workflow that may need:

- SSH connection setup
- environment inspection
- Ruby/bundler/system package installation
- code transfer or package installation
- process start
- retry / resume / partial failure handling
- trust / admission / join confirmation

That is exactly the kind of problem Igniter agents are good at.

So the current recommendation is:

- `IgnitionAgent` should orchestrate ignition
- specialized bootstrap agents should execute target-specific setup
- cluster admission should remain the authority for final join

## Agent Roles

### `IgnitionAgent`

Owns orchestration for one ignite request.

Responsibilities:

- read and normalize ignite intent
- decide which peers need to be brought up
- create deployment intents for each peer
- delegate execution to bootstrap agents
- wait for cluster join / capability publication
- surface progress, failures, and approval requirements

### `BootstrapAgent`

Owns one target machine or target environment.

Responsibilities:

- connect to the target
- verify prerequisites
- install Ruby / bundler / system packages if needed
- transfer stack/runtime or install a package artifact
- write target config
- start the node runtime
- return enough metadata for the joining node to identify itself

### `JoinAgent` or Admission Workflow

Owns the final cluster-side acceptance path.

Responsibilities:

- verify identity / trust
- process admission policy
- register the peer
- confirm capability publication
- mark the ignition workflow as complete

This may remain part of the existing admission workflow rather than becoming a
separate standalone agent, but conceptually it is a distinct stage.

## Current Runtime-Owned Join Model

The current remote join model is intentionally split into two honest phases:

1. bootstrap phase
2. runtime confirmation phase

Bootstrap phase:

- `IgnitionAgent` prepares or admits the target
- `BootstrapAgent` performs SSH bootstrap
- the ignition report moves the target to `bootstrapped`

Runtime confirmation phase:

- bootstrap seeds `IGNITER_IGNITE_*` env into the new node
- the built-in HTTP server runs `after_start` hooks after `TCPServer` is bound
- stack runtime derives its join URL and re-announces through `Mesh::Announcer`
- seed/operator side can call `Stack.reconcile_ignite(...)` to fold real mesh discovery back into the ignition report
- `Stack#ignite(...)` itself can also run a short bounded watcher that repeatedly reconciles against mesh and returns `joined` when discovery lands in time
- every explicit ignition lifecycle action can now also be persisted into a durable ignition trail, which is intentionally separate from the ephemeral `IgnitionReport`

This is an intentional compromise:

- the new node now signals join from its actual runtime boot path
- we avoid pretending that one process can mutate another process's in-memory ignition report directly
- report closure is now based on observable cluster state, not only imperative side-effects
- operator-facing history can survive process restarts without pretending that one in-memory report is the whole deployment record

At the moment, the landed ignition lifecycle already covers:

- normalized planning (`BootstrapTarget`, `DeploymentIntent`, `IgnitionPlan`)
- execution (`Stack#ignite`, `IgnitionAgent`, `BootstrapAgent`)
- admission-aware local and remote boot
- runtime-owned join signaling
- reconciliation and bounded auto-watch for join closure
- durable event/history trail under `var/ignite/`
- diagnostics and unified operator visibility
- mounted operator actions for common ignition lifecycle transitions
- app-facing generic operator verbs and audit dimensions that align more closely with orchestration records

## Two Main Scenarios

### 1. Cold Start / Static Ignite

A node is already running and receives a static ignite plan.

Example intent:

- bring up two sibling local replicas
- or bring up three remote peers from SSH config files

Typical flow:

1. start one seed node
2. load ignite intent from environment-specific config
3. `IgnitionAgent` creates deployment intents
4. `BootstrapAgent` provisions each target
5. new peers boot as stack nodes
6. admission/trust path confirms join
7. cluster differentiates dynamically through capabilities

### 2. Dynamic Expansion / Delegated Provision

An operator or LLM agent concludes that the cluster needs a new machine with
specific capabilities.

Typical flow:

1. conversation or analysis determines a new capability need
2. operator provides target access config
3. `IgnitionAgent` builds a deployment intent
4. `BootstrapAgent` provisions the target
5. the node joins the cluster
6. capability publication changes routing possibilities

This is especially important because it turns expansion into part of the
Igniter runtime model instead of keeping it as external ops glue.

## Approval Model

Dynamic ignition is powerful enough that it should usually cross an approval
boundary.

Recommended rule:

- planning can be automatic
- target inspection can be automatic
- remote provisioning should default to approval-required
- auto-ignite should be limited to trusted, explicitly configured scenarios

That means an LLM or orchestration agent may say:

- “we need a node with capabilities X”
- “here is the deployment plan”

But the actual remote bootstrap should usually require approval unless the
environment explicitly opts into automation.

That approval idea is now reflected in real runtime/operator shape too:

- ignition reports can surface awaiting approval/admission states honestly
- operator tooling can now approve or retry ignition through the same mounted action surface used for orchestration work
- approval is therefore no longer only a design note; it is becoming part of the actual runtime contract

## Proposed Config Direction

The current recommendation is to avoid putting environment roots like `dev:` and
`prod:` directly into `stack.yml`.

Instead:

- keep `stack.yml` for base stack runtime
- keep ignite intent in environment overlays

### Base Stack Config

```yaml
server:
  host: 0.0.0.0
  port: 4567

persistence:
  data:
    adapter: sqlite
    path: var/spark_crm_data.sqlite3
```

### Local Development Ignite

```yaml
ignite:
  replicas:
    - port: 4568
    - port: 4569
```

## Current Next

The next realistic `ignite` moves are now:

1. harden operator-facing ignition workflow semantics

- align ignition actions more closely with the operator model already used for orchestration items
- deepen retry/approval/reconcile/dismiss semantics and audit visibility

2. strengthen deployment packaging/runtime strategy

- decide how code/package transfer should stabilize beyond the current bootstrap seam
- make remote bootstrap less dependent on ad-hoc environmental assumptions

3. extend ignition beyond bootstrap into fuller deployment lifecycle

- detach / teardown / re-ignite flows
- richer failure classification and retry policy
- stronger relationship between ignition trail and long-lived cluster state

Meaning:

- start one node on the base server config
- ignite sibling local replicas
- let those replicas join the cluster normally

### Remote / Production Ignite

```yaml
ignite:
  servers:
    - config/ssh_rpi5_16gb_1.yml
    - config/ssh_rpi5_16gb_2.yml
    - config/ssh_hp.yml
```

Meaning:

- take one live stack node as the seed runtime
- use listed remote bootstrap targets
- let bootstrap agents provision peer stack nodes there

## Draft Intent Shape

This is not final, but it is a good working draft:

```yaml
ignite:
  mode: cold_start
  strategy: parallel
  approval: required

  replicas:
    - name: edge-1
      port: 4568
      capabilities:
        - audio_ingest
        - whisper_asr

  servers:
    - target: config/ssh_hp.yml
      capabilities:
        - call_analysis
        - local_llm
      bootstrap:
        ruby: "3.2"
        bundler: true
```

Potential meanings:

- `mode`
  - `cold_start`
  - `expand`
- `strategy`
  - `serial`
  - `parallel`
- `approval`
  - `required`
  - `auto`
- `replicas`
  - local sibling nodes
- `servers`
  - remote bootstrap targets
- `capabilities`
  - desired post-join capability intent, not static role identity

## Normalized Runtime Objects

The YAML shape is only the authoring surface.

Ignition should not execute directly from raw config hashes.

The next implementation step should normalize config into explicit runtime value
objects:

- `Igniter::Ignite::BootstrapTarget`
- `Igniter::Ignite::DeploymentIntent`
- `Igniter::Ignite::IgnitionPlan`

The rule should be:

- config is user-authored intent
- normalized objects are execution intent
- agents operate on normalized objects, not raw YAML

That keeps validation, approval, idempotency, and reporting in one place.

Current landed state:

- `Igniter::Ignite::BootstrapTarget` exists
- `Igniter::Ignite::DeploymentIntent` exists
- `Igniter::Ignite::IgnitionPlan` exists
- `Igniter::Ignite::IgnitionAgent` exists
- `Igniter::Ignite::IgnitionReport` exists
- `Igniter::Stack#ignition_plan` normalizes `ignite` config into these objects
- `Igniter::Stack#ignite` executes the minimal agent-owned ignition flow
- `IgnitionReport` now carries explicit admission/join semantics per target
- app diagnostics expose ignition through `app_ignite`
- local ignition can optionally use the real `Mesh` admission workflow
- local `ignite.replicas` already participate in stack `dev` / compose-style
  runtime shaping as synthetic local runtime units

This is still an early implementation slice.

It gives us normalized value objects, minimal agent-driven orchestration, and
local replica boot semantics, but not yet remote bootstrap execution or
admission-aware ignition lifecycle.

## `BootstrapTarget`

`BootstrapTarget` should represent one concrete place where a node may be
brought up.

It should not mean:

- a logical capability need
- a static cluster role
- a routing preference

It should mean:

- one local replica target
- or one remote machine / environment target

Recommended minimum fields:

- `id`
- `kind`
- `locator`
- `base_server`
- `capability_intent`
- `bootstrap_requirements`
- `metadata`

### Target Kinds

The first useful kinds are:

- `local_replica`
- `ssh_server`

Later we may add:

- `container_runtime`
- `vm_template`
- `kubernetes_target`

But the first slice should stay small and concrete.

### Example: Local Replica Target

```yaml
id: edge-1
kind: local_replica
locator:
  port: 4568
base_server:
  host: 0.0.0.0
  port: 4567
capability_intent:
  - audio_ingest
  - whisper_asr
bootstrap_requirements: {}
metadata: {}
```

### Example: Remote SSH Target

```yaml
id: hp-call-analysis
kind: ssh_server
locator:
  config_path: config/ssh_hp.yml
base_server:
  host: 0.0.0.0
  port: 4567
capability_intent:
  - call_analysis
  - local_llm
bootstrap_requirements:
  ruby: "3.2"
  bundler: true
metadata: {}
```

### Notes

- `locator` is transport-specific
- `capability_intent` describes what we want the node to be good at after join
- `bootstrap_requirements` describes what setup may be required before the node
  can run
- `base_server` lets replicas inherit the seed stack's runtime defaults without
  duplicating the whole stack config

## `DeploymentIntent`

`DeploymentIntent` should represent one ignition operation against one
`BootstrapTarget`.

It should be the unit that:

- gets approved
- gets delegated to a bootstrap agent
- emits progress
- becomes part of the final ignition report

Recommended minimum fields:

- `id`
- `ignite_mode`
- `strategy`
- `approval_mode`
- `target`
- `requested_capabilities`
- `requested_by`
- `requested_from`
- `seed_node`
- `join_policy`
- `correlation`
- `metadata`

### Semantics

- `id`
  - stable intent identifier
- `ignite_mode`
  - `cold_start` or `expand`
- `strategy`
  - `serial` or `parallel`
- `approval_mode`
  - `required` or `auto`
- `target`
  - one normalized `BootstrapTarget`
- `requested_capabilities`
  - final desired capability intent for the joining node
- `requested_by`
  - operator, agent, workflow, or system surface that created the intent
- `requested_from`
  - seed graph / stack / execution context
- `seed_node`
  - the live node that is coordinating ignition
- `join_policy`
  - trust / admission expectations
- `correlation`
  - ids that tie the lifecycle together across agents and reports

### Example Shape

```yaml
id: ignite-expand-hp-call-analysis
ignite_mode: expand
strategy: parallel
approval_mode: required
target: hp-call-analysis
requested_capabilities:
  - call_analysis
  - local_llm
requested_by:
  kind: operator
  actor: alex
requested_from:
  stack: spark_crm
  environment: prod
seed_node:
  host: crm-seed-1
  port: 4567
join_policy:
  admission: required
  trust: cluster_default
correlation:
  ignite_request_id: ignite-20260420-01
metadata: {}
```

## `IgnitionPlan`

`IgnitionPlan` should be the normalized collection of deployment intents plus
plan-level policy.

Recommended responsibilities:

- hold the seed-node ignition request
- hold ordered or parallelized `DeploymentIntent` entries
- expose approval summary
- expose dry-run / explain output
- provide final result grouping

The plan should be what `IgnitionAgent` receives first.

The agent should then fan out into per-target `DeploymentIntent` execution.

## Lifecycle Draft

The lifecycle should be explicit and auditable.

Recommended plan-level phases:

1. `planned`
2. `awaiting_approval`
3. `bootstrapping`
4. `awaiting_join`
5. `publishing_capabilities`
6. `completed`
7. `failed`
8. `cancelled`

Recommended per-intent phases:

1. `pending`
2. `approved`
3. `connecting`
4. `preparing_runtime`
5. `transferring_stack`
6. `starting_node`
7. `awaiting_admission`
8. `awaiting_capabilities`
9. `succeeded`
10. `failed`
11. `cancelled`

The exact labels may evolve, but the important part is that ignition becomes a
real long-running workflow with observable state, not an opaque side effect.

## Idempotency And Correlation

Ignition should assume retries and partial failure from day one.

So the design should include:

- stable `ignite_request_id`
- stable `DeploymentIntent#id`
- target identity separate from human display name
- final reports correlated back to the original seed request
- join/admission events tied to the intent that caused them

This matters for both:

- cold-start retries
- dynamic expansion initiated by operators or LLM-assisted workflows

Without this, approval, audit, and recovery will become fragile very quickly.

## Minimal First Implementation

The first implementation slice should stay intentionally narrow.

Recommended minimum:

1. local `ignite.replicas`
2. one live seed node
3. normalization into `BootstrapTarget` and `DeploymentIntent`
4. `IgnitionAgent` orchestrating local sibling boot
5. admission/join confirmation
6. ignition report

That gives us:

- real agent-driven ignition
- real lifecycle/state
- real join confirmation

without yet taking on full SSH automation.

Status:

- normalization is landed
- local replica runtime shaping is landed
- `PORT`-driven per-replica local boot is landed
- minimal `IgnitionAgent` orchestration is landed
- `IgnitionReport` status/event surface is landed
- ignition is visible in app diagnostics/operator-facing observability
- admission-aware ignition summary is partially landed
- optional admission handshake through `Mesh.request_admission` is landed
- explicit `Stack#confirm_ignite_join(...)` is landed
- join confirmation can now transition admitted/prepared targets into `joined`
- mesh-backed join confirmation now registers the peer in `peer_registry`
- local no-mesh join confirmation falls back to `admission: implicit_local`
- remote `ssh_server` bootstrap through `BootstrapAgent` is landed
- remote targets can now transition `deferred -> bootstrapped -> joined`
- remote targets can optionally use `Mesh.request_admission` before bootstrap
- no-mesh remote join confirmation falls back to `admission: implicit_remote`

## Remote Bootstrap After The First Slice

Remote bootstrap is now started, but still intentionally narrow.

What is landed:

- `ssh_server` `BootstrapTarget`
- `BootstrapAgent` SSH execution path
- remote admission-aware orchestration before bootstrap
- target config loading from `config_path`
- package/runtime installation via existing replication bootstrappers
- remote node start + verify
- `bootstrapped` ignition state before final join

What still comes next:

- deepen runtime-owned remote join closure beyond `after_start + reconcile + bounded watcher`
- richer progress/history surfaces for bootstrap phases
- stronger operator controls around approval / retry / detach

## Execution Contract Draft

The likely execution contract is:

1. normalize ignite config into `DeploymentIntent` objects
2. open orchestration items when approval is needed
3. execute bootstrap per target
4. wait for trust/admission
5. confirm capability publication
6. publish final ignition report

That report should eventually include:

- requested targets
- successful peers
- failed peers
- admission results
- published capabilities
- operator approvals involved

## What Should Not Happen

We should avoid these anti-patterns:

- cluster code doing raw SSH orchestration directly
- static role maps pretending to be the true runtime model
- duplicate deployment config spread across stack config, helper scripts, and agent prompts
- bypassing admission/trust just because bootstrap succeeded
- making remote provisioning an invisible side effect of normal routing

## Open Questions

The main questions still open are:

- exact `ignite` schema
- how much remote bootstrap belongs in `igniter-cluster` vs a deployment package/layer
- whether deployment agents should live in `igniter-agents`, `igniter-cluster`, or a future deployment package
- how much approval semantics should reuse the existing operator/orchestration surface
- whether local replicas should fully replace current node-profile-heavy dev boot
- whether `IgnitionPlan` should live as a separate value object or as part of agent execution state
- where the stable home of deployment value objects should be before `v1`

## Recommended Next Step

The next concrete design slice should define:

1. stable normalized value objects in code
2. `IgnitionAgent` minimal local replica orchestration
3. `Admission / join` handshake contract
4. ignition result/report shape
5. only then remote SSH bootstrap
