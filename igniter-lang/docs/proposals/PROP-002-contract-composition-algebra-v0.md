# PROP-002: Contract Composition Algebra v0

Status: assigned
Date: 2026-05-05
Author: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`
Depends on: `PROP-001-semantic-domain-v0.md`

## Purpose

Define how contracts compose over the `PROP-001` semantic domain.

This proposal should make "everything contract" precise enough for future
compiler work. It should identify which composition operations preserve the
closed, typed, demand-driven, temporally-parameterized core and which ones
require explicit escape annotations.

## Starting Point

Read first:

- `igniter-lang/docs/proposals/PROP-001-semantic-domain-v0.md`
- `igniter-lang/docs/proposals/META-001-compiler-grammar-expert-entry.md`
- `igniter-lang/docs/tracks/observable-contract-language-v0.md`
- `igniter-lang/docs/agent-motion.md`

Optional read-only source horizon:

- `lib/igniter/model`
- `lib/igniter/compiler`
- `lib/igniter/dsl/contract_builder.rb`
- `docs/dev/architecture.md`
- `docs/dev/execution-model.md`

Do not edit packages. Use package sources only as evidence.

## Core Questions

Answer these directly:

- What is the unit object of contract composition, if one exists?
- Is sequential composition associative?
- Is parallel composition associative and/or commutative?
- How do branch and collection composition affect decidability?
- How do guards, constraints, effects, and observations compose?
- What is the difference between contract composition and dependency edges?
- What compositions preserve deterministic `eval(G, Tt, inputs)`?
- What compositions require out-of-fragment annotations?
- How do failures compose: first failure, accumulated failures, degraded
  service-level propagation, blocked branches?

## Candidate Operations

Investigate at least:

- sequential composition
- parallel composition
- projection / field extraction
- product composition
- sum / branch composition
- collection/map composition
- aggregation
- guard/refinement composition
- effect/receipt composition
- materializer composition
- agent proposal/receipt composition

Do not assume all are in v0 core.

## Desired Formal Shape

Keep notation light, but precise.

Suggested sections:

- compact claim
- semantic objects reused from PROP-001
- composition operations
- algebraic laws
- preservation rules
- failure composition
- temporal composition
- effect composition
- out-of-fragment cases
- implications for grammar/compiler
- next proposal recommendation

## Acceptance

Done means:

- Defines a minimal composition algebra for v0 contracts.
- States which operations are in the decidable core.
- States which laws hold, fail, or are conditional.
- Explains how composition interacts with `Tt`.
- Explains how observations and failures compose.
- Identifies grammar/compiler consequences for `PROP-003`.
- Does not introduce syntax as a commitment.
- Does not edit package docs/code.
- Ends with compact handoff.

## Non-Goals

- No `.il` grammar.
- No parser.
- No runtime code.
- No package edits.
- No category-theory-first presentation.
- No attempt to include recursion or higher-order contracts in v0 core.

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/proposals/PROP-002
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

