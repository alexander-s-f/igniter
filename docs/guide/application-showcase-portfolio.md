# Application Showcase Portfolio

This guide is the current application showcase map for Igniter. Use it when you
want to evaluate the richer contracts-native examples as products, not only as
small API snippets.

The portfolio has four current applications:

- Lense: local codebase intelligence.
- Chronicle: architecture decision review.
- Scout: local-source research synthesis.
- Dispatch: incident command and handoff.

Each application is intentionally offline, one-process, and reproducible. They
exercise `igniter-application`, `igniter-contracts`, `igniter-extensions`, and
`igniter-web` through app-local structure. They do not define a public
interactive app API.

## What The Portfolio Proves

The four showcases demonstrate the same serious application loop:

- app-owned services load local inputs, own mutable session state, and emit
  deterministic evidence artifacts
- one contracts-native graph computes the core analysis, readiness, or payload
- command routes return app-local success/refusal results and record action
  facts
- one detached snapshot feeds the Web surface, `/events`, smoke output, and
  manual inspection
- `/report` or `/receipt` exposes an app-owned evidence artifact
- smoke runs prove success, refusal, endpoint parity, and mutation boundaries

This repetition is a copyable convention. It is not yet a framework contract,
shared command result class, snapshot API, route DSL, marker DSL, UI kit,
receipt/report API, or `Igniter.interactive_app` facade.

## Showcase Matrix

| Showcase | Purpose | Workflow | Packages exercised | Evidence artifact | Mutation boundary | Smoke | Manual server |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Lense | Codebase intelligence for a local Ruby project. | Scan project -> health findings -> guided issue session -> analysis report. | `igniter-application`, `igniter-contracts`, `igniter-extensions`, `igniter-web`. | `LenseAnalysisReceipt` through `/report`. | Reads an explicit sample project and proves no scanned-project mutation. | `ruby examples/application/lense_poc.rb` | `ruby examples/application/lense_poc.rb server` |
| Chronicle | Decision compass for architecture proposals. | Proposal scan -> decision conflicts -> sign-off/refusal -> decision receipt. | `igniter-application`, `igniter-contracts`, `igniter-extensions`, `igniter-web`. | `DecisionReceipt` through `/receipt`. | Reads proposal/decision fixtures and writes runtime sessions/actions/receipts only to workdir. | `ruby examples/application/chronicle_poc.rb` | `ruby examples/application/chronicle_poc.rb server` |
| Scout | Local-source research workspace. | Topic + local sources -> findings -> direction checkpoint -> research receipt. | `igniter-application`, `igniter-contracts`, `igniter-extensions`, `igniter-web`. | `ResearchReceipt` through `/receipt`. | Reads local source fixtures and writes runtime sessions/actions/receipts only to workdir. | `ruby examples/application/scout_poc.rb` | `ruby examples/application/scout_poc.rb server` |
| Dispatch | Incident command and handoff. | Seeded incident events -> triage/routing -> assignment checkpoint -> incident receipt. | `igniter-application`, `igniter-contracts`, `igniter-extensions`, `igniter-web`. | `IncidentReceipt` through `/receipt`. | Reads incident/event/runbook/team fixtures and writes runtime sessions/actions/receipts only to workdir. | `ruby examples/application/dispatch_poc.rb` | `ruby examples/application/dispatch_poc.rb server` |

## Package Capability Map

Each showcase keeps its domain logic local while exercising the same package
roles:

| Showcase | Application capability | Contracts capability | Web capability |
| --- | --- | --- | --- |
| Lense | App composition, scan service, issue-session commands, snapshot, report endpoint. | `CodebaseHealthContract` computes health score, findings, evidence refs, and report metadata. | Mounted dashboard/workbench with `/events`, `/report`, feedback, counters, findings, and activity markers. |
| Chronicle | Proposal/decision stores, conflict session commands, sign-off/refusal state, receipt endpoint. | `DecisionReviewContract` computes conflicts, required sign-offs, readiness, and receipt payload. | Mounted decision compass with `/events`, `/receipt`, feedback, conflict evidence, sign-off/refusal, and activity markers. |
| Scout | Source library, research session commands, checkpoint state, receipt endpoint. | `ResearchSynthesisContract` computes findings, contradictions, checkpoint readiness, citations, and synthesis payload. | Mounted research workspace with `/events`, `/receipt`, feedback, source/provenance, checkpoint, and activity markers. |
| Dispatch | Incident library, triage session commands, assignment/escalation state, receipt endpoint. | `IncidentTriageContract` computes severity, suspected cause, routing options, readiness, and receipt payload. | Mounted command center with `/events`, `/receipt`, feedback, event/citation, routing, assignment, and activity markers. |

## Web Review Map

Each richer showcase has one mounted Arbre surface. The surface reads one
app-owned snapshot through `MountContext`; `app.rb` owns command routes,
redirect feedback, `/events`, and the evidence endpoint.

| Showcase | Mounted surface | Surface marker | Evidence endpoint | Manual review focus |
| --- | --- | --- | --- | --- |
| Lense | `web/lense_dashboard.rb` as `:lense_dashboard`. | `data-ig-poc-surface="lense_dashboard"` | `/report` | Scan summary, findings, evidence refs, issue-session actions, report validity, and no scanned-project mutation. |
| Chronicle | `web/decision_compass.rb` as `:decision_compass`. | `data-ig-poc-surface="decision_compass"` | `/receipt` | Proposal context, conflict evidence, sign-off/refusal state, decision receipt validity, and fixture no-mutation. |
| Scout | `web/research_workspace.rb` as `:research_workspace`. | `data-ig-poc-surface="research_workspace"` | `/receipt` | Topic, sources, citations, provenance, findings, contradictions, checkpoint state, research receipt validity, and fixture no-mutation. |
| Dispatch | `web/command_center.rb` as `:command_center`. | `data-ig-poc-surface="command_center"` | `/receipt` | Incident events, severity, routing rationale, assignment/escalation checkpoint, handoff receipt validity, and fixture no-mutation. |

During manual review, inspect the browser page and these companion endpoints:

- `/events` should agree with the visible state because both render from the
  same detached app snapshot.
- `/report` or `/receipt` should expose the app-owned evidence artifact when
  the workflow reaches its checkpoint.
- feedback should appear through query-string redirect state and render with
  `data-ig-feedback` plus an app-local `data-feedback-code`.
- recent activity should render from the same snapshot and use
  `data-ig-activity` plus app-local action metadata.
- command controls should expose app-local `data-action` values.
- domain records and counters should expose explicit app-local `data-`
  attributes for smoke and browser inspection.

These markers are inspection seams, not a public marker DSL. Surface names,
feedback codes, action names, endpoint labels, CSS direction, and panel
grouping remain local to each showcase.

## Run The Portfolio

Run the full active examples catalog:

```bash
ruby examples/run.rb smoke
```

Run an individual showcase through the catalog:

```bash
ruby examples/run.rb run application/lense_poc
ruby examples/run.rb run application/chronicle_poc
ruby examples/run.rb run application/scout_poc
ruby examples/run.rb run application/dispatch_poc
```

Run an individual showcase directly:

```bash
ruby examples/application/lense_poc.rb
ruby examples/application/chronicle_poc.rb
ruby examples/application/scout_poc.rb
ruby examples/application/dispatch_poc.rb
```

Open a manual browser surface:

```bash
ruby examples/application/lense_poc.rb server
ruby examples/application/chronicle_poc.rb server
ruby examples/application/scout_poc.rb server
ruby examples/application/dispatch_poc.rb server
```

Each server command prints a local URL. Server mode is example scaffolding for
manual review, not production server behavior.

Use in-process smoke runs as the default proof. Manual browser review is useful
for evaluating the mounted screens, but the portfolio does not require browser
automation, live transport, a production server, auth, persistence, scheduler,
connectors, or LLM/provider integration.

## Evidence To Inspect

For each showcase, inspect three surfaces together:

- HTML surface: the mounted `igniter-web` screen with stable app-local
  `data-` markers.
- `/events`: the text read model that mirrors the same app-owned snapshot.
- `/report` or `/receipt`: the evidence artifact emitted by the app.

The smoke output should include markers for:

- the first successful command path
- at least one refusal path
- recent action facts
- `/events` parity with the Web surface snapshot
- receipt/report validity
- fixture or target no-mutation

## Application Structure Convention

Use the showcase layout as a convention for new application experiments:

- `app.rb` is the visible composition boundary.
- `contracts/` contains the deterministic contracts-native graph.
- `services/` owns loading, state, commands, and snapshots.
- `reports/` owns receipt/report rendering when the workflow has evidence to
  emit.
- `web/` owns the local mounted surface.
- the launcher script owns smoke and optional `server` mode.

Keep domain names and repeated shapes local until package extraction is
explicitly justified. In particular, keep command result classes, snapshot
fields, feedback codes, route names, marker names, receipt payload keys,
fixture schemas, thresholds, and readiness rules inside the app.

For the detailed copyable convention, see
[Interactive App Structure](./interactive-app-structure.md).

## Legacy Boundary

Legacy material is private/reference context, not the current onboarding path.
Start from the current packages, this portfolio guide, the interactive app
structure guide, and the four showcase READMEs:

- [`examples/application/lense/README.md`](../../examples/application/lense/README.md)
- [`examples/application/chronicle/README.md`](../../examples/application/chronicle/README.md)
- [`examples/application/scout/README.md`](../../examples/application/scout/README.md)
- [`examples/application/dispatch/README.md`](../../examples/application/dispatch/README.md)
