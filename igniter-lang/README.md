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

## Package Status

`igniter_lang 0.1.0.alpha.1` — alpha prerelease candidate. Not yet published.
See [RELEASE_NOTES.md](RELEASE_NOTES.md) for scope, accepted local evidence,
required fresh smoke, and exclusions.

RubyGems publish, release execution, and tag/push/sign/deploy remain closed
pending fresh package/install smoke and profile-source installed smoke for
this version.

## Current Navigation

Internal read-only context (local evidence only — not a release, publish, or public demo claim):

- [docs/README.md](docs/README.md) — documentation index
- [docs/current-status.md](docs/current-status.md) — stage scoreboard and accepted local evidence
- [docs/ruby-api.md](docs/ruby-api.md) — caller-facing local proof compiler API

Accepted local evidence (for `0.1.0.pre.stage2`; repo-local; fresh smoke required for `0.1.0.alpha.1`; release execution and public release/demo claims remain closed):

- Repo-local compiler RC evidence: PASS
- Local package install smoke: PASS
- Bounded installed profile-source smoke: PASS

RubyGems publish, release execution, version/tag/push/sign/deploy, profile
finalization/discovery/defaulting, branch/conditional `if_expr`, Spark
integration, runtime, and production behavior remain out of scope.

## Write Rule

Write only inside this `igniter-lang/` workspace.
