# igniter-companion — Durable Model Docs

Status reports, manifest glossary, and performance signals for the Durable Model
layer. The physical package is still `igniter-companion` during v0 migration;
the canonical Ruby namespace is `Igniter::DurableModel`, with
`Igniter::Companion` kept as a compatibility alias.

| File | Description |
|------|-------------|
| [current-status.md](current-status.md) | Durable Model implementation current status summary |
| [app-status.md](app-status.md) | Durable Model persistence app status |
| [manifest-glossary.md](manifest-glossary.md) | Persistence manifest field glossary |
| [performance.md](performance.md) | Contract performance signal notes |
| [proposals/companion-package-identity.md](proposals/companion-package-identity.md) | Proposal to rename/reframe the package as Durable Model instead of Companion |
| [tracks/durable-model-namespace-adoption-v0.md](tracks/durable-model-namespace-adoption-v0.md) | Track for introducing `Igniter::DurableModel` before physical package rename |
| [tracks/companion-ledger-client-remote-boundary-v0.md](tracks/companion-ledger-client-remote-boundary-v0.md) | Track for accepting `LedgerClient` as Companion's preferred remote Ledger boundary |
| [tracks/companion-ledger-client-scope-query-boundary-v0.md](tracks/companion-ledger-client-scope-query-boundary-v0.md) | Proposed next track for remote Companion scopes over `LedgerClient#query` |
| [tracks/companion-ledger-client-scope-subscriptions-v0.md](tracks/companion-ledger-client-scope-subscriptions-v0.md) | Proposed next track for remote Companion `on_scope` over Ledger Client events |
