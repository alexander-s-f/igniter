# Enterprise Verification

Use this page when you want one compact proof path for the current public
Igniter story.

The current enterprise proof is intentionally narrow:

- run deterministic in-process smoke commands
- run contracts package specs for the lower-layer kernel
- inspect flagship application receipts/reports and mutation boundaries
- inspect contracts/lang examples for class DSL, Embed pressure, optional
  packs, and report-only metadata
- review mounted Web surfaces manually when needed
- keep production server, auth, persistence, live transport, cluster placement,
  connectors, and LLM/provider behavior out of the verified claim

This receipt is not a certification, security audit, compliance review, SLA,
or release guarantee. It is a reproducible evidence path for the current public
Igniter surface.

## Canonical Command Matrix

| Layer | Command | What it proves |
| --- | --- | --- |
| Contracts package | `bundle exec rspec packages/igniter-contracts/spec spec/current` | The contracts kernel, packs, class DSL, Lang specs, and current root integration specs pass together. |
| Active examples | `ruby examples/run.rb smoke` | The active contracts-native examples and flagship applications emit expected deterministic smoke fragments. |
| Flagship apps | `ruby examples/run.rb run application/lense_poc` and the Chronicle, Scout, Dispatch equivalents below | The richer one-process application portfolio proves command/refusal loops, read-model parity, evidence artifacts, and mutation boundaries. |
| Lang foundation | `ruby examples/run.rb run contracts/lang_foundation` | The additive Lang wrapper compiles/executes through contracts and reports declared metadata without enforcement. |
| Changed-file lint | `bundle exec rubocop <changed files>` | Narrow changes respect current style. Full RuboCop currently includes pre-existing archived/research offenses, so changed-file lint is the practical gate for focused slices. |

## Flagship Application Verification

The flagship application proof is the four-app showcase portfolio: Lense,
Chronicle, Scout, and Dispatch. Together they prove that Igniter can compose
contracts-native, one-process applications with local services, deterministic
graphs, command/refusal loops, app-owned snapshots, evidence artifacts, and
explicit mutation boundaries.

Run the full active catalog first:

```bash
ruby examples/run.rb smoke
```

Then run focused flagship application smoke when reviewing the application
portfolio:

```bash
ruby examples/run.rb run application/lense_poc
ruby examples/run.rb run application/chronicle_poc
ruby examples/run.rb run application/scout_poc
ruby examples/run.rb run application/dispatch_poc
```

Those commands are the canonical application verification path. Direct launcher
commands remain valid for local debugging:

```bash
ruby examples/application/lense_poc.rb
ruby examples/application/chronicle_poc.rb
ruby examples/application/scout_poc.rb
ruby examples/application/dispatch_poc.rb
```

## Application Receipt Matrix

| Showcase | Command | Success/refusal proof | Read proof | Artifact proof | Mutation proof |
| --- | --- | --- | --- | --- | --- |
| Lense | `ruby examples/run.rb run application/lense_poc` | Issue-session success actions plus refusal markers such as blank or missing finding feedback. | Mounted dashboard and `/events` agree on scan, findings, session, and actions. | `/report` exposes a valid `LenseAnalysisReceipt`. | Smoke prints `lense_poc_no_mutation=true` for the scanned sample project. |
| Chronicle | `ruby examples/run.rb run application/chronicle_poc` | Scan, acknowledgement, sign-off, refusal, and receipt flow markers. | Mounted decision compass and `/events` agree on proposal, conflicts, sign-offs/refusals, and actions. | `/receipt` exposes a valid `DecisionReceipt`. | Smoke prints fixture no-mutation and runtime session/receipt write markers. |
| Scout | `ruby examples/run.rb run application/scout_poc` | Session, extraction, source-add, checkpoint, receipt, and refusal markers. | Mounted research workspace and `/events` agree on topic, sources, findings, contradictions, checkpoint, and actions. | `/receipt` exposes a valid `ResearchReceipt`. | Smoke prints fixture no-mutation and runtime session/receipt write markers. |
| Dispatch | `ruby examples/run.rb run application/dispatch_poc` | Open, triage, assignment, escalation/refusal, and receipt flow markers. | Mounted command center and `/events` agree on incident, events, severity, routing, checkpoint, and actions. | `/receipt` exposes a valid `IncidentReceipt`. | Smoke prints fixture no-mutation and runtime session/receipt write markers. |

## What The Application Receipt Proves

Treat the smoke output as an evaluator receipt. For each flagship app, the
receipt should show:

- at least one successful command path
- at least one refusal path
- command feedback that stays app-local
- recent action facts recorded at the command boundary
- one mounted surface marker for the app-local Web screen
- `/events` parity with the same detached snapshot used by the Web surface
- `/report` or `/receipt` validity for the app-owned evidence artifact
- no unexpected mutation of scanned targets or read-only fixtures

This is evidence for the current application pattern, not a public application
framework API. Command result classes, snapshot fields, feedback codes, route
names, marker names, receipt payload keys, fixture schemas, thresholds, and
readiness rules remain local to each showcase.

## Manual Review Boundary

Manual server mode is useful for review, but it is not production behavior.
Start a local browser surface only when you want to inspect the app by hand:

```bash
ruby examples/application/lense_poc.rb server
ruby examples/application/chronicle_poc.rb server
ruby examples/application/scout_poc.rb server
ruby examples/application/dispatch_poc.rb server
```

During manual review, inspect the printed local URL, run one success and one
refusal path, compare the visible state with `/events`, and open `/report` or
`/receipt`. Do not infer auth, persistence, scheduling, live updates,
production deployment, cluster behavior, connectors, or LLM integration from
manual server mode.

Use this matrix when you want a browser-facing receipt for the same proof:

| Showcase | Server command | Surface marker | Success/refusal evidence | Read/artifact evidence |
| --- | --- | --- | --- | --- |
| Lense | `ruby examples/application/lense_poc.rb server` | `data-ig-poc-surface="lense_dashboard"` | Refresh or guided-session actions render `data-ig-feedback` and app-local `data-feedback-code`; blank note or missing finding gives a refusal path. | `/events` agrees with scan/findings/session state; `/report` exposes the valid analysis receipt. |
| Chronicle | `ruby examples/application/chronicle_poc.rb server` | `data-ig-poc-surface="chronicle_decision_compass"` | Scan, acknowledgement, sign-off, refusal, and receipt actions render feedback markers with app-local codes. | `/events` agrees with proposal/conflict/sign-off state; `/receipt` exposes the valid decision receipt. |
| Scout | `ruby examples/application/scout_poc.rb server` | `data-ig-poc-surface="scout_research_workspace"` | Session, extraction, source-add, checkpoint, receipt, and invalid/blank paths render feedback markers with app-local codes. | `/events` agrees with topic/source/finding/checkpoint state; `/receipt` exposes the valid research receipt. |
| Dispatch | `ruby examples/application/dispatch_poc.rb server` | `data-ig-poc-surface="dispatch_command_center"` | Open, triage, assignment, escalation/refusal, and receipt actions render feedback markers with app-local codes. | `/events` agrees with incident/event/routing/checkpoint state; `/receipt` exposes the valid incident receipt. |

The browser receipt should confirm the same categories as the smoke receipt:
top-level surface marker, success feedback, refusal feedback, recent activity,
`/events` parity, evidence endpoint availability, and no unexpected fixture or
target mutation. These checks use app-local `data-` attributes as inspection
seams; they are not a marker DSL or component API.

## Contracts And Lang Verification

Contracts are the lower-layer proof under the application portfolio. Start with
the package/root spec command:

```bash
bundle exec rspec packages/igniter-contracts/spec spec/current
```

Then inspect the focused contracts examples:

```bash
ruby examples/run.rb run contracts/class_pricing
ruby examples/run.rb run contracts/class_callable
ruby examples/run.rb run contracts/embed_class_registration
ruby examples/run.rb run contracts/contractable_shadow
ruby examples/run.rb run contracts/step_result
ruby examples/run.rb run contracts/lang_foundation
```

| Proof | Command | Receipt evidence |
| --- | --- | --- |
| Block/kernel contracts | `bundle exec rspec packages/igniter-contracts/spec spec/current` and `ruby examples/run.rb smoke` | Baseline graph declaration, compilation, execution, diagnostics, packs, and current root integration specs pass. |
| Class DSL | `ruby examples/run.rb run contracts/class_pricing` and `contracts/class_callable` | Human-edited contract classes expose result readers, input updates, and callable service object steps while still executing through `igniter-contracts`. |
| Embed pressure | `ruby examples/run.rb run contracts/embed_class_registration` and `contracts/contractable_shadow` | Host registration and shadow comparison stay host-owned; contract classes expose graphs without taking over naming, reload, cache, rollout, or failure-envelope policy. |
| StepResultPack | `ruby examples/run.rb run contracts/step_result` | Optional `step` nodes produce fail-fast dependency short-circuiting and a serializable trace without changing the ordinary `compute` path. |
| Lang foundation | `ruby examples/run.rb run contracts/lang_foundation` | `require "igniter/lang"` loads the Ruby backend wrapper, descriptors survive as metadata, `VerificationReport` is inspectable, and `MetadataManifest` reports declared metadata as not enforced. |

The contracts receipt should support this decision path:

- Use the block API for low-level embedding, generated graphs, and package
  tests.
- Use `Igniter::Contract` class DSL for human-edited application contract
  files.
- Let Embed hosts own registration, discovery, reload, caching, rollout, and
  failure envelopes.
- Use optional packs, such as `StepResultPack`, for semantics that are useful
  but not baseline.
- Use `Igniter::Lang` as an additive reference/report surface, not as a
  separate runtime.

Lang wording is deliberately strict. Descriptors and metadata manifests are
declared/report-only unless a future runtime semantics track explicitly
accepts enforcement. In the current receipt, `type:`, `return_type:`,
`deadline:`, and `wcet:` are visible in reports; they do not create type
checks, warnings, findings, deadline monitoring, store behavior, or
`ExecutionResult` changes.

## Smoke Helper Boundary

The flagship apps repeat smoke mechanics such as Rack env construction, form
encoding, redirect following, response status checks, marker assertions,
endpoint parity, and file-signature checks. That repetition can justify an
examples/specs-scoped helper later.

Do not turn those mechanics into production runtime API in this verification
track. A future helper should remain examples/specs-only and should not know
domain command names, feedback codes, snapshot fields, receipt schemas, marker
DSLs, route DSLs, UI components, or browser automation.

## Non-Goals

This verification path does not graduate research/runtime phases into product
claims. Keep these out of scope until a later accepted track says otherwise:

- Lang grammar/parser/AST, `.il`, Rust backend, certified exports, store/OLAP,
  time-machine behavior, physical unit enforcement, or deadline enforcement
- live agents, Semantic Gateway, Line-Up runtime, LLM/provider behavior, or
  production connectors
- cluster placement, distributed runtime, scheduler/background jobs, auth,
  persistence, production server behavior, or deployment guarantees
- public package APIs for smoke mechanics, route declarations, marker
  conventions, generic receipt/report viewers, browser automation, or UI kit

## Related Guides

- [Application Showcase Portfolio](./application-showcase-portfolio.md)
- [Interactive App Structure](./interactive-app-structure.md)
- [Contract Class DSL](./contract-class-dsl.md)
- [Igniter Lang Foundation](./igniter-lang-foundation.md)
