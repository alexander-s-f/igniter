# Dispatch Application POC

Dispatch is the fourth richer Igniter application showcase. It demonstrates a
replayable incident command loop:

```text
seeded incident event bundle -> deterministic triage/routing evidence ->
assignment checkpoint -> incident handoff receipt
```

The POC is intentionally offline and one-process. It uses
`igniter-application` for app composition, `igniter-contracts` for deterministic
triage and routing, and `igniter-web` for the mounted command center. It does
not use live monitoring, queues, schedulers, background workers, connectors,
LLM triage, remediation execution, database persistence, auth, production
server behavior, or cluster placement.

## Run

Run the full command/Web smoke:

```bash
ruby examples/application/dispatch_poc.rb
```

Run through the examples catalog:

```bash
ruby examples/run.rb run application/dispatch_poc
```

Open the manual browser surface:

```bash
ruby examples/application/dispatch_poc.rb server
```

The server prints the local URL, normally:

```text
dispatch_poc_url=http://127.0.0.1:9297/
```

You can override the port with `PORT=9300`.

## Workflow

The default incident is:

```text
INC-001: Checkout errors after payments deploy
```

The normal smoke path proves:

- unknown incident refusal
- incident command session open
- receipt-not-ready refusal before triage and checkpoint
- deterministic triage with critical severity and migration suspected cause
- routing options for `payments-platform` and `database-oncall`
- unknown team refusal
- invalid assignment refusal for a known-but-not-routable team
- blank escalation reason refusal
- owner assignment checkpoint
- incident handoff receipt emission
- `/events` parity with the same app-owned snapshot used by the Web surface
- `/receipt` inspection
- fixture no-mutation

Stable smoke markers include:

```text
dispatch_poc_receipt_valid=true
dispatch_poc_fixture_no_mutation=true
dispatch_poc_web_surface=true
dispatch_poc_web_events_parity=true
dispatch_poc_web_receipt_endpoint=true
dispatch_poc_web_fixture_no_mutation=true
```

## Manual Browser Review

After starting the server, open the printed local URL and review the same
workflow through the mounted Arbre surface:

1. Open incident `INC-001`.
2. Try receipt emission before triage/checkpoint to see a refusal.
3. Run deterministic triage.
4. Try an unknown team such as `frontend-oncall`.
5. Try invalid assignment to known observer team `support-ops`.
6. Try blank escalation to `database-oncall`.
7. Assign owner `payments-platform`.
8. Emit the incident handoff receipt.
9. Open `/events` and `/receipt` from the footer links.

The browser surface should keep these inspection seams visible:

- `data-ig-poc-surface="dispatch_command_center"` on the root surface.
- `data-feedback-code` after success and refusal redirects.
- event, citation, severity, cause, route, and provenance markers.
- `data-assigned-team="payments-platform"` after assignment.
- `data-handoff-ready="true"` before receipt emission.
- `data-ig-activity="recent"` for the same recent events used by `/events`.
- `data-receipt-valid="true"` after successful receipt emission.

## File Layout

```text
examples/application/dispatch/
  app.rb
  config.ru
  contracts/incident_triage_contract.rb
  data/events/*.json
  data/incidents/*.json
  data/runbooks/*.md
  data/teams.json
  reports/incident_receipt.rb
  services/dispatch_analyzer.rb
  services/incident_library.rb
  services/incident_session_store.rb
  services/runbook_parser.rb
  web/command_center.rb
```

Ownership boundaries:

- `app.rb` is the visible composition boundary and Rack route owner.
- `contracts/incident_triage_contract.rb` owns deterministic event facts,
  severity, suspected cause, routing options, readiness, and receipt payloads.
- `services/` owns fixture loading, triage orchestration, sessions, commands,
  command results, snapshots, runtime actions, and receipt writes.
- `reports/incident_receipt.rb` owns the app-local Markdown receipt shape.
- `web/command_center.rb` owns presentation, feedback copy, forms, and stable
  `data-` markers, but reads state through the app-owned snapshot.

## Mutation Boundary

Read-only fixtures:

```text
examples/application/dispatch/data/incidents/*.json
examples/application/dispatch/data/events/*.json
examples/application/dispatch/data/runbooks/*.md
examples/application/dispatch/data/teams.json
```

Runtime writes:

```text
$DISPATCH_WORKDIR/sessions/*.json
$DISPATCH_WORKDIR/actions/actions.jsonl
$DISPATCH_WORKDIR/receipts/*.md
```

If `DISPATCH_WORKDIR` is not set, `Dispatch.default_workdir` uses:

```text
/tmp/igniter_dispatch_poc
```

The smoke launcher uses a temporary workdir and asserts that source fixtures are
not mutated.

## Boundaries

Keep these shapes app-local for now:

- `CommandResult` and `DispatchSnapshot`
- feedback codes and action facts
- incident/event/runbook/team fixture schemas
- severity, suspected cause, routing, assignment, escalation, and receipt
  payload schemas
- Web marker names and route labels

Deferred on purpose:

- public `Igniter.interactive_app` facade
- generic incident, workflow, report, marker, or route DSL
- live monitoring, timers, queues, schedulers, and background workers
- Slack, PagerDuty, Opsgenie, log, metrics, deploy, or remediation connectors
- LLM triage, generated remediation, shell execution, or infrastructure writes
- graph/canvas evidence maps
- live transport, database persistence, auth, production server behavior, or
  cluster placement
