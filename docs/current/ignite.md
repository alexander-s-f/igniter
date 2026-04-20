# Igniter Ignite

This note captures the current direction for cluster ignition and deployment
bootstrap.

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
- whether local replicas should fully replace current node-profile-heavy dev boot
- how much remote bootstrap belongs in `igniter-cluster` vs a deployment package/layer
- whether deployment agents should live in `igniter-agents`, `igniter-cluster`, or a future deployment package
- what the stable `DeploymentIntent` value object should look like
- how much approval semantics should reuse the existing operator/orchestration surface

## Recommended Next Step

The next concrete design slice should define:

1. `DeploymentIntent`
2. `IgnitionAgent`
3. `BootstrapTarget` schema
4. `Admission / join` handshake contract
5. minimal local `ignite.replicas` flow before remote SSH automation
