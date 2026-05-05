# igniter-lang

Status: separate research workspace
Owner: `[Architect Supervisor / Codex]`
Agent identity: `[Igniter-Lang Research Agent]`

`igniter-lang` is a contract-native language research ecosystem adjacent to,
but separate from, the Igniter platform.

## Working Hypothesis

```text
Igniter      = framework/platform for real systems.
Igniter-Lang = language research ecosystem for contract-native computation.
```

They share concepts, but they should not share release pressure, package
boundaries, or premature syntax/runtime commitments.

## Why Separate

- The platform must stay practical and shippable.
- The language needs room for theory, axioms, and new paradigms.
- Research docs should not pollute platform docs.
- Language experiments should influence Igniter through explicit bridge notes,
  not by silently changing packages.

## Start Here

1. Read [AGENTS.md](AGENTS.md).
2. Read [handoff/START_PROMPT.md](handoff/START_PROMPT.md).
3. Use [docs/README.md](docs/README.md) as the research index.
4. Start with [docs/tracks/observable-contract-language-v0.md](docs/tracks/observable-contract-language-v0.md).

## Current Source Horizon

Read-only context:

- `/docs/guide/igniter-lang-foundation.md`
- `/docs/research/igniter-lang-convergence-report.md`
- `/docs/research/project-status-horizon-report.md`
- `/playgrounds/docs/experts/igniter-lang`

## Write Rule

Write only inside this `igniter-lang/` workspace.
