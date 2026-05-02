# Igniter Packages

Deprecated legacy material lives under private playgrounds and is reference-only.

Active runtime packages:

- `igniter-contracts`
- `igniter-extensions`
- `igniter-application`
- `igniter-ai`
- `igniter-agents`
- `igniter-hub`
- `igniter-web`
- `igniter-cluster`
- `igniter-mcp-adapter`

Experimental research packages:

- `igniter-store` - contract-native store POC for immutable facts,
  time-travel reads, reactive invalidation, WAL replay, and future sync-hub
  experiments.
- `igniter-companion` - typed Record/History facade over `igniter-store`,
  carrying Companion app-local persistence pressure toward package-level
  Store/History experiments.

Remaining recreation work:

- rebuild `igniter-server` only if an adapter surface is still needed

See [AI And Agents Target Plan](../docs/dev/ai-agents-target-plan.md) before
adding provider clients or agent runtime logic to an application example.
