# Proposal: Igniter vs Igniter-Lang Ecosystem Split

Status: proposal

## Thesis

`igniter` and `igniter-lang` should be developed as separate but communicating
ecosystems.

```text
igniter
  practical platform
  Ruby/packages/apps/ledger/agents
  production pressure
  compatibility and implementation constraints

igniter-lang
  contract-native language research
  semantics before syntax
  axioms, observability, synthesis, temporal models
  human + agent symbiosis pressure
```

## Shared Concepts

- contract graph
- typed descriptors
- persistence shapes
- history and `as_of`
- provenance and observability
- materialization as contracts
- command intent and app boundary
- agents as contract participants

## Separate Constraints

Igniter must answer:

- Can this build real applications?
- Can this run and be tested today?
- Does this preserve package boundaries?
- Does this avoid premature API promises?

Igniter-Lang must answer:

- What is the smallest coherent axiom layer?
- What does it mean that everything is observable?
- What does it mean that everything is a contract?
- What is agent-friendly syntax and semantics?
- Which fragments are decidable, sound, and useful?

## Non-Mixing Rules

- Igniter-Lang research does not edit Igniter packages directly.
- Igniter platform does not inherit language syntax until semantics are stable.
- Grammar does not lead the research.
- Runtime implementation does not lead the research.
- Bridge ideas must be explicit proposal documents.

## Bridge Mechanism

Ideas may flow back to Igniter through bridge notes:

```text
Igniter-Lang research signal
-> bridge proposal
-> Architect review
-> package track
-> implementation
```

## Initial Decision Candidates

[D] Keep `igniter-lang/` as a separate top-level workspace.

[R] Avoid `packages/igniter-lang` until there is an approved implementation
candidate.

[R] Treat `.il` syntax as a later artifact, not the starting point.
