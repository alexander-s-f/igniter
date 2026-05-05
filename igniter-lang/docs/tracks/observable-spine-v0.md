# Track: Observable Spine v0

Status: research
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

Define the smallest observation packet model that can carry the first
Igniter-Lang axiom slice:

```text
Everything observable.
Everything contract.
```

This is not a grammar, parser, runtime, or storage implementation track. It is
a semantic spine track: identify the minimal packet shapes that let humans,
agents, compilers, runtimes, and bridge proposals talk about the same observed
meaning without leaking host-language noise.

## Starting Point

Read first:

- `igniter-lang/AGENTS.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/research-process.md`
- `igniter-lang/docs/tracks/observable-contract-language-v0.md`

Optional read-only source horizon:

- `docs/guide/igniter-lang-foundation.md`
- `docs/research/igniter-lang-convergence-report.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-algebra.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-theory.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-persistence.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-temporal.md`
- `packages/igniter-ledger/docs`
- `packages/igniter-ledger-client/docs`
- `packages/igniter-durable-model/docs`

Write only inside `igniter-lang/`.

## Core Questions

Answer these directly:

- What is the identity of an observation?
- What minimal fields must every observation packet carry?
- How do observations link to contract nodes, inputs, outputs, constraints,
  store facts, histories, commands, effects, agents, materializers, failures,
  and axiom/platform versions?
- How does the packet represent time: `as_of`, causal order, source clock,
  rule version, and replay horizon?
- Which fields are required for humans, agents, compilers, runtimes, and bridge
  consumers?
- What must stay out of the packet as platform noise: host stack traces, heap
  details, database query plans, retry mechanics, scheduler internals?
- Which packet shapes are stable enough to become bridge proposal candidates
  back to Igniter packages?

## Desired Shape

Prefer a compact semantic model over a long essay.

Suggested sections:

- compact claim
- packet vocabulary
- required vs optional fields
- packet kinds
- link model
- temporal model
- failure model
- agent/materializer model
- host-noise exclusions
- bridge candidates
- rejected paths
- next slice

Illustrative pseudo-structures are allowed, but each one must say whether it is
illustrative or proposed.

## Candidate Packet Kinds

Investigate whether the spine needs one generic packet with `kind`, or a small
closed family.

Candidate kinds:

- `value_observation`
- `contract_descriptor`
- `dependency_edge`
- `constraint_observation`
- `fact_observation`
- `history_observation`
- `command_intent`
- `effect_receipt`
- `materializer_receipt`
- `agent_evidence`
- `failure_observation`
- `axiom_observation`
- `platform_descriptor`

Do not assume this list is final. Compress it if one packet model is stronger;
split it if the semantics need separate shapes.

## Acceptance

The completed slice should:

- define the minimal observation identity
- define a compact packet model with required and optional fields
- explain how packets link without requiring global runtime state
- explain how temporal reads and replay are represented
- explain how failures become first-class observations
- explain how agent and materializer evidence fits without exposing unsafe raw
  prompt/user data
- list what remains outside the packet as host/platform noise
- identify 1-3 explicit bridge candidates, but not edit package docs or code
- end with a compact handoff

## Non-Goals

- No `.il` syntax proposal.
- No parser.
- No runtime.
- No package edits.
- No attempt to model every possible distributed-systems detail.
- No maximal logging design.
- No hidden agent privilege.

## Supervisor Notes

[R] Keep the packet model small enough that it could plausibly become a shared
semantic bridge later.

[R] Treat privacy and safety as semantic constraints. Agent evidence should be
auditable without requiring storage of raw prompts, secrets, or user data unless
an explicit contract says so.

[R] The result should help decide whether Igniter platform concepts like ledger
facts, durable model descriptors, receipts, lineage, diagnostics, `as_of`, and
materializers are converging toward a shared observation vocabulary.

## Expected Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/observable-spine-v0
Status: done | partial | blocked

[D] Decisions:
- ...

[R] Recommendations:
- ...

[S] Signals:
- ...

[Q] Open Questions:
- ...

[X] Rejected:
- ...

[Next] Proposed next slice:
- ...
```
