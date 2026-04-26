# Lense POC

Lense is a one-process codebase intelligence showcase for Igniter. It scans a
local Ruby project, evaluates deterministic health findings through a
contracts-native analysis graph, exposes an app-owned `CodebaseSnapshot`, lets
the user run guided issue-session actions, and emits a receipt-shaped
`LenseAnalysisReceipt`.

This is a runnable example, not a package API. It deliberately does not add
`Igniter.interactive_app`, an LLM provider, database persistence, background
scheduling, SSE/WebSocket, code editing, auth, or production server behavior.

## Run

Smoke run:

```bash
ruby examples/application/lense_poc.rb
```

Manual browser inspection:

```bash
ruby examples/application/lense_poc.rb server
```

The server prints a local URL, usually:

```text
lense_poc_url=http://127.0.0.1:9294/
```

## What It Proves

- `CodebaseAnalyzer` reads Ruby files only under an explicit target root and
  does not mutate the scanned project.
- `CodebaseHealthContract` turns scan facts into counts, prioritized findings,
  health score, and report metadata.
- `IssueSessionStore` owns guided actions: `done`, `skip`, and `note`, plus
  refusal feedback such as `finding_not_found`, `invalid_step_action`, and
  `blank_note`.
- The dashboard/workbench consumes an app-owned `CodebaseSnapshot` and keeps
  `/events` on the same read model.
- `LenseAnalysisReceipt` carries scan identity, counts, findings, evidence
  refs, actions, skipped/deferred work, validity, and generated timestamp.

## Stable Markers

The smoke entry checks markers such as:

- `lense_poc_scan_id=true`
- `lense_poc_web_surface=true`
- `lense_poc_web_start_feedback=true`
- `lense_poc_web_events_parity=true`
- `lense_poc_web_report_endpoint=true`
- `lense_poc_no_mutation=true`

Those markers are the intended inspection seam for this POC. Keep new behavior
app-local until another distinct application proves the same shape again.
