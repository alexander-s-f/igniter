# Rails Contracts Ledger Example

This app is a small Rails proof for adopting Igniter in a host application
without changing the host's primary business behavior.

It is supporting evidence for the Ruby Framework package line, not a production
Rails integration kit or a Spark production adoption recipe.

It demonstrates:

- `Igniter::Embed.contractable` in primary-only observed-service mode.
- Redacted observation receipts.
- `record_observation` / `record_event` store adapter wiring.
- Optional `Igniter::Ledger::ContractableReceiptSink` sidecar persistence.
- Admin/debug lookup by `observation_id`.

Run:

```bash
bundle install
bin/rails test
bin/rails server
```

Smoke endpoints:

```text
GET /availability
GET /observations/:observation_id
```

This example intentionally stays in `primary_observed_only` mode. It does not
run a shadow candidate and does not treat Ledger receipts as source of truth.
