# Igniter-Lang Runtime Machine

Status: meta thesis
Date: 2026-05-05
Owner: `[Architect Supervisor / Codex]`

## Claim

[D] Igniter-Lang should not require Ledger as its language core.

Igniter-Lang needs a **Runtime Machine**: a semantic execution machine that
loads contracts, binds a runtime contract, evaluates under explicit temporal
context, emits observations, checkpoints state, and resumes across sessions.

Ledger may be a strong durable backend for this machine, but it is not the
machine itself and not a mandatory substrate.

```text
Igniter-Lang
  = semantic language

Runtime Machine
  = executes contracts under RuntimeContract + TemporalCtx

TBackend
  = temporal substrate for state, observations, replay, snapshots

Ledger
  = one possible durable TBackend
```

## Runtime Machine Shape

The runtime machine is the live embodiment of:

```text
LanguageContract + RuntimeContract + UserContract + TemporalCtx
  -> result | observations | failures | receipts
```

It owns the session lifecycle:

```text
boot
  -> emit AxiomDescriptor
  -> emit RuntimeContract
  -> bind TBackend
  -> bind ExecutionEnvironment

load contracts
  -> classify CORE / ESCAPE / OOF
  -> typecheck
  -> emit descriptors

evaluate
  -> resolve graph under Tt
  -> emit observations
  -> produce projections / slices / receipts

checkpoint
  -> snapshot semantic image
  -> persist descriptors, runtime evidence, cursors

resume
  -> load descriptors
  -> verify runtime compatibility
  -> replay observations or load snapshot
  -> continue from explicit Tt
```

## TBackend

[D] A `TBackend` is a temporal substrate contract. It stores and serves the
runtime machine's semantic time surface.

It is not "the language database." It is a pluggable backend for temporal
state and observation continuity.

```text
TBackend[T] = {
  read(as_of)
  append(observation)
  replay(cursor)
  snapshot(horizon)
  compact(policy)
  subscribe(slice)
}
```

Possible implementations:

- `memory` — tests, experiments, ephemeral sessions
- `redis_like` — live state, streams, fast subscriptions
- `file` — portable local runtime and developer replay
- `ledger` — durable audit/replay backend
- `remote` — multi-runtime / hosted backend

[D] Redis-like and Ledger-like backends are adapters behind `TBackend`, not
language primitives.

## Semantic Image

The runtime machine may have an image, but it is not a Smalltalk object-memory
image.

```text
Igniter-Lang Semantic Image =
  descriptors
  + typed observations
  + projections/slices
  + receipts
  + runtime evidence
  + replay cursors
  + checkpoints
```

Smalltalk image:

```text
objects + messages + object memory
```

Igniter-Lang image:

```text
contracts + temporal context + observations + projections + receipts
```

This gives a live machine without hiding semantic authority in process memory.

## Cross-Session Continuity

[D] The thing that crosses sessions is not the process. It is the evidence
chain.

Session A emits:

- AxiomDescriptor
- RuntimeContract
- ExecutionEnvironment
- Contract descriptors
- Observations
- Projections
- Receipts
- Checkpoints
- Replay cursors

Session B resumes from:

- same or superseding descriptors
- compatible runtime contract
- replay cursor or snapshot
- explicit temporal context
- conformance verification evidence

If runtime or axiom semantics change, the change is observable:

```text
RuntimeContract@1
  -> superseded_by
RuntimeContract@2
```

No session should silently claim the same reproducible meaning under changed
runtime or axiom contracts.

## Instance And Context Model

Multiple runtime machine instances are not hidden replicas. They are runtime
contract instances that may compose.

```text
RuntimeMachineInstance = {
  runtime_contract
  execution_environment
  t_backend_binding
  session_id
  checkpoint_ref
  observation_sink
}
```

Across instances:

- observations deduplicate by identity
- runtime promises link through `:executed_by`
- concrete instance links through `:produced_in`
- checkpoints and replay cursors define resume horizons
- distributed composition remains ESCAPE until proven

## Practical Guardrails

[X] Do not make Ledger mandatory for Igniter-Lang.

[X] Do not hide runtime continuity in process memory.

[X] Do not treat Redis-like streams as language semantics. They are backend
capabilities.

[X] Do not let a resumed session claim reproducibility without runtime and
axiom compatibility checks.

[X] Do not build distributed runtime composition before single-machine lifecycle
is clear.

## Next Research Pressure

[R] Research Agent should investigate `runtime-machine-lifecycle-v0`:

- boot/load/evaluate/checkpoint/resume lifecycle
- TBackend contract and adapter classes
- semantic image contents
- compatibility checks across restarts
- what is CORE vs ESCAPE in lifecycle

[R] Compiler/Grammar Expert should later connect Runtime Machine lifecycle to
`PROP-007 Conformance Verification`:

- which lifecycle steps must emit verification observations
- which backend capabilities are required for reproducible resume
- how runtime machine identity participates in observation identity
