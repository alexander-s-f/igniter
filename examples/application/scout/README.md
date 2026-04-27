# Scout Application POC

Scout is the third richer Igniter application showcase. It demonstrates a
reproducible local-source research loop:

```text
topic + local source set -> deterministic findings -> direction checkpoint ->
source-backed research receipt
```

The POC is intentionally offline and one-process. It uses `igniter-application`
for app composition, `igniter-contracts` for deterministic synthesis, and
`igniter-web` for the mounted research workspace. It does not use network
search, LLM providers, embeddings, connectors, background jobs, database
persistence, auth, or a production server layer.

## Run

Run the full command/Web smoke:

```bash
ruby examples/application/scout_poc.rb
```

Run through the examples catalog:

```bash
ruby examples/run.rb run application/scout_poc
```

Open the manual browser surface:

```bash
ruby examples/application/scout_poc.rb server
```

The server prints the local URL, normally:

```text
scout_poc_url=http://127.0.0.1:9296/
```

You can override the port with `PORT=9300`.

## Workflow

The default topic is:

```text
How should engineering teams adopt AI coding assistants?
```

The normal smoke path proves:

- blank topic refusal
- no source refusal
- unknown source refusal
- session start with default local sources
- deterministic finding extraction
- receipt-not-ready refusal before checkpoint choice
- invalid checkpoint refusal
- adding optional local source `SRC-004`
- re-extraction after the added source
- `balanced` checkpoint selection
- research receipt emission
- `/events` parity with the same app-owned snapshot used by the Web surface
- `/receipt` inspection
- fixture no-mutation

Stable smoke markers include:

```text
scout_poc_receipt_valid=true
scout_poc_fixture_no_mutation=true
scout_poc_web_surface=true
scout_poc_web_events_parity=true
scout_poc_web_receipt_endpoint=true
scout_poc_web_fixture_no_mutation=true
```

## Manual Browser Review

After starting the server, open the printed local URL and review the same
workflow through the mounted Arbre surface:

1. Start the default session.
2. Extract findings.
3. Try receipt emission before choosing a checkpoint to see a refusal.
4. Add optional local source `SRC-004`.
5. Extract findings again.
6. Choose the `balanced` checkpoint.
7. Emit the receipt.
8. Open `/events` and `/receipt` from the footer links.

The browser surface should keep these inspection seams visible:

- `data-ig-poc-surface="scout_research_workspace"` on the root surface.
- `data-feedback-code` after success and refusal redirects.
- source, citation, and provenance markers on nested evidence lists.
- `data-ig-activity="recent"` for the same recent events used by `/events`.
- `data-receipt-valid="true"` after successful receipt emission.

## File Layout

```text
examples/application/scout/
  app.rb
  config.ru
  contracts/research_synthesis_contract.rb
  data/source_index.json
  data/sources/*.md
  reports/research_receipt.rb
  services/finding_extractor.rb
  services/research_session_store.rb
  services/source_library.rb
  services/source_parser.rb
  web/research_workspace.rb
```

Ownership boundaries:

- `app.rb` is the visible composition boundary and Rack route owner.
- `contracts/research_synthesis_contract.rb` owns deterministic source claims,
  findings, contradictions, checkpoint readiness, and synthesis payloads.
- `services/` owns source loading, finding extraction, sessions, commands,
  command results, snapshots, runtime actions, and receipt writes.
- `reports/research_receipt.rb` owns the app-local Markdown receipt shape.
- `web/research_workspace.rb` owns presentation, feedback copy, forms, and
  stable `data-` markers, but reads state through the app-owned snapshot.

## Mutation Boundary

Read-only fixtures:

```text
examples/application/scout/data/source_index.json
examples/application/scout/data/sources/*.md
```

Runtime writes:

```text
$SCOUT_WORKDIR/sessions/*.json
$SCOUT_WORKDIR/actions/actions.jsonl
$SCOUT_WORKDIR/receipts/*.md
```

If `SCOUT_WORKDIR` is not set, `Scout.default_workdir` uses:

```text
/tmp/igniter_scout_poc
```

The smoke launcher uses a temporary workdir and asserts that source fixtures are
not mutated.

## Boundaries

Keep these shapes app-local for now:

- `CommandResult` and `ScoutSnapshot`
- feedback codes and action facts
- source parser and local source fixture format
- finding, contradiction, checkpoint, and receipt payload schemas
- Web marker names and route labels

Deferred on purpose:

- public `Igniter.interactive_app` facade
- generic research, workflow, report, marker, or route DSL
- network search, file upload, external source connectors, RSS, PDF, or docs
  integrations
- LLM providers, embeddings, semantic search, or generated summaries
- graph/canvas evidence maps
- live transport, scheduler, file watcher, database persistence, auth, or
  production server behavior
