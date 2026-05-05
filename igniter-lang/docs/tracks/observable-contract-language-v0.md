# Track: Observable Contract Language v0

Status: proposed

## Frame

Research the first possible Igniter-Lang axiom:

```text
Everything observable.
Everything contract.
```

This is not a syntax design track. It is a semantics and product-language track.

## Questions

[Q] What counts as observable in the language?

[Q] Are values, effects, stores, agents, materializers, commands, and failures
all contracts?

[Q] What should be visible to humans, agents, compilers, and runtimes?

[Q] What is the smallest axiom layer that keeps the language useful without
leaking host-language noise?

[Q] How does this differ from the current Igniter platform?

## Research Inputs

Read-only:

- `/docs/guide/igniter-lang-foundation.md`
- `/docs/research/igniter-lang-convergence-report.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-algebra.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-theory.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-theory2.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-persistence.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-temporal.md`

## Expected Output

Produce a compact report in this file or a follow-up proposal that includes:

- core claim
- 5-10 proposed language axioms or laws
- what is observable
- what is contract
- what remains axiom/platform
- how agents benefit
- risks and rejected paths
- first bridge ideas back to Igniter

## Non-Goals

- No parser.
- No grammar commitment.
- No package edits.
- No runtime implementation.
- No final `.il` syntax.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/observable-contract-language-v0
Status: done | partial | blocked

[D] Decisions:
- ...

[R] Recommendations:
- ...

[S] Signals:
- ...

[Q] Open Questions:
- ...

[Next] Proposed next slice:
- ...
```
