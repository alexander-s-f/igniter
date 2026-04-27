# Chronicle POC

Chronicle is a one-process decision compass showcase for Igniter. It compares a
local proposal against seed architectural decision records, evaluates
deterministic conflict evidence through a contracts-native analysis graph,
exposes an app-owned `ChronicleSnapshot`, records acknowledgement, sign-off, and
refusal actions, and emits a receipt-shaped `DecisionReceipt`.

This is a runnable example, not a package API. It deliberately does not add
`Igniter.interactive_app`, a generic workflow framework, an LLM provider,
semantic search, database persistence, background scheduling, SSE/WebSocket,
auth, production server behavior, or external repository mutation.

## Run

Smoke run:

```bash
ruby examples/application/chronicle_poc.rb
```

Manual browser inspection:

```bash
ruby examples/application/chronicle_poc.rb server
```

The server prints a local URL, usually:

```text
chronicle_poc_url=http://127.0.0.1:9295/
```

## What It Proves

- `DecisionStore` and `ProposalStore` read Markdown fixtures from
  `examples/application/chronicle/data/`.
- `DecisionReviewContract` turns proposal and decision facts into conflict
  evidence, required sign-offs, readiness, and receipt payload data.
- `DecisionSessionStore` owns runtime session state, action facts, sign-offs,
  refusals, and receipt emission.
- The Web workbench consumes an app-owned `ChronicleSnapshot` and keeps
  `/events` on the same read model.
- `/receipt` exposes the emitted Markdown receipt from the runtime workdir.
- Smoke runs prove that seed fixtures are not mutated.

## File Boundaries

Read-only fixtures:

- `data/decisions/*.md`
- `data/proposals/*.md`

Runtime writes:

- `ENV["CHRONICLE_WORKDIR"]`, when set
- `/tmp/igniter_chronicle_poc`, by default
- temporary smoke workdirs created by `chronicle_poc.rb`

Runtime files include `sessions/*.json`, `actions/actions.jsonl`, and
`receipts/*.md`.

## Stable Markers

The smoke entry checks markers such as:

- `chronicle_poc_scan=chronicle_scan_created`
- `chronicle_poc_receipt=chronicle_receipt_emitted`
- `chronicle_poc_fixture_no_mutation=true`
- `chronicle_poc_web_surface=true`
- `chronicle_poc_web_events_parity=true`
- `chronicle_poc_web_receipt_endpoint=true`
- `chronicle_poc_web_fixture_no_mutation=true`

Those markers are the intended inspection seam for this POC. Keep command
results, snapshots, parser rules, conflict thresholds, receipt shape, and Web
marker vocabulary app-local until another distinct application proves the same
shape again.
