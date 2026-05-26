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

`igniter_lang 0.1.0.alpha.1` is available on RubyGems as an alpha prerelease
compiler package.

Install:

```bash
gem install igniter_lang -v 0.1.0.alpha.1
```

Scope: bounded `igc` compiler CLI for accepted local corpus and the accepted
`--compiler-profile-source PATH.json` transport. See
[RELEASE_NOTES.md](RELEASE_NOTES.md) for evidence, exclusions, and non-claims.

## Current Navigation

Internal context and release evidence:

- [docs/README.md](docs/README.md) — documentation index
- [docs/current-status.md](docs/current-status.md) — stage scoreboard and accepted local evidence
- [docs/ruby-api.md](docs/ruby-api.md) — caller-facing local proof compiler API

Accepted release evidence for `0.1.0.alpha.1`:

- Repo-local compiler RC evidence: PASS
- Combined post-prep package/profile-source smoke: PASS
- RubyGems publish verification: PASS
- Isolated install verification: PASS
- Tag `igniter-lang-v0.1.0.alpha.1`: present

Still excluded: stable/production/public-demo claims, all grammar support,
profile finalization/discovery/defaulting, branch/conditional `if_expr`, Spark
integration, runtime/Ledger/TBackend/BiHistory readiness, signing, and
deployment.

## Write Rule

Write only inside this `igniter-lang/` workspace.
