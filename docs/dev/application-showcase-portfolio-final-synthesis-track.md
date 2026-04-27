# Application Showcase Portfolio Final Synthesis Track

This track consolidates the current richer showcase portfolio after Dispatch
became showcase-ready.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

Constraints:

- `:interactive_poc_guardrails` from [Constraint Sets](./constraints.md)
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)
- [Application Showcase Evidence And Smoke Design Track](./application-showcase-evidence-smoke-design-track.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
- [Interactive App Structure](../guide/interactive-app-structure.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting Dispatch as
showcase-ready.

Lense, Chronicle, Scout, and Dispatch now form a coherent richer showcase
portfolio. The next step is synthesis and readiness framing, not another large
feature implementation.

## Goal

Turn the four showcase apps into a clear enterprise-facing portfolio story and
decide the next strategic track.

The result should answer:

- what each showcase proves for Igniter
- what repeated app/web structure is now reliable convention
- which repeated shapes are still app-local and should not be extracted yet
- whether any tiny support/API extraction is justified by evidence
- what enterprise-facing docs/discoverability need next
- whether the next active line should be support extraction, another product
  app, or packaging/distribution readiness

## Scope

In scope:

- portfolio synthesis across Lense, Chronicle, Scout, and Dispatch
- compact docs/guide updates if needed
- `tracks.md` compact state cleanup if needed
- evidence inventory for smoke, receipts, `/events`, `/receipt`, and manual
  browser review
- recommendation for the next active track

Out of scope:

- new product app implementation
- public `Igniter.interactive_app` facade
- generic command result, snapshot, marker, route, UI kit, receipt, or app DSL
  extraction without explicit evidence
- live transport, LLMs, connectors, scheduler, persistence, auth, production
  server behavior, or cluster placement
- reintroducing legacy material into the main discoverability path

## Task 1: Portfolio App Synthesis

Owner: `[Agent Application / Codex]`

Acceptance:

- Compare Lense, Chronicle, Scout, and Dispatch by workflow, contract graph,
  command/refusal model, snapshot, action facts, receipt/report artifact, and
  mutation boundary.
- Identify which conventions are now stable enough for guide-level doctrine.
- Identify which conventions remain app-local despite repetition.
- Recommend whether a narrow support extraction is justified now, and specify
  the smallest possible candidate if yes.
- Keep legacy material as reference-only context; the active onboarding path
  should point to current packages and showcase apps.

## Task 2: Portfolio Web Synthesis

Owner: `[Agent Web / Codex]`

Acceptance:

- Compare Web surfaces across Lense, Chronicle, Scout, and Dispatch by mounted
  surface shape, route ownership, feedback markers, `/events`, report/receipt
  endpoint, manual server mode, and smoke markers.
- Identify where Web repetition helps future package support and where it is
  still better left local for readability.
- Recommend whether to consolidate docs, defer extraction, or open a tiny
  helper experiment.
- Keep the recommendation grounded in the existing examples, not future
  imagined live/agent UI.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Prefer synthesis over expansion. Four showcase apps are enough evidence for a
  portfolio pass.
- Do not graduate an API just because names repeat. Graduate only if local
  duplication now hides domain intent.
- The enterprise story should emphasize reproducibility, receipts, mutation
  boundaries, deterministic contracts, and inspectable Web surfaces.
- The user's local legacy relocation to `playgrounds/legacy` is accepted as
  workspace hygiene. Treat legacy as private/reference context, not a public
  onboarding entrypoint.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code or examples change, also run the relevant example smoke and RuboCop
commands.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` synthesizes the app-side portfolio evidence
   across Lense, Chronicle, Scout, and Dispatch.
2. `[Agent Web / Codex]` synthesizes Web/read-model/manual-review evidence
   across the same portfolio.
3. `[Architect Supervisor / Codex]` decides the next strategic track.

## Portfolio App Synthesis

[Agent Application / Codex] App-side portfolio story:

| Showcase | Workflow | Contract graph | Command/refusal model | Snapshot | Evidence artifact | Mutation boundary |
| --- | --- | --- | --- | --- | --- | --- |
| Lense | Local Ruby project scan -> health findings -> guided issue session -> analysis receipt. | `CodebaseHealthContract` turns scan facts into health score, prioritized findings, and report metadata. | `IssueSessionStore::CommandResult` covers guided done/skip/note actions and refusal paths. | `CodebaseSnapshot` exposes scan, findings, session, actions, and report state. | `LenseAnalysisReceipt` proves scan identity, findings, evidence refs, actions, skipped scope, and validity. | Reads a sample project and proves no scanned-project mutation. |
| Chronicle | Proposal scan -> decision conflicts -> acknowledgement/sign-off/refusal -> decision receipt. | `DecisionReviewContract` computes conflict evidence, required sign-offs, readiness, and receipt payload. | `DecisionSessionStore::CommandResult` covers scan, acknowledgement, sign-off, refusal, receipt, and refusals. | `ChronicleSnapshot` exposes proposal, conflicts, sign-offs/refusals, actions, and receipt state. | `DecisionReceipt` proves conflict evidence, sign-off/refusal state, provenance, deferred scope, and validity. | Reads proposal/decision fixtures and writes sessions/actions/receipts only to workdir. |
| Scout | Topic + local sources -> findings -> direction checkpoint -> research receipt. | `ResearchSynthesisContract` computes claims, findings, contradictions, checkpoint readiness, and synthesis payload. | `ResearchSessionStore::CommandResult` covers session, extraction, local source add, checkpoint, receipt, and refusals. | `ScoutSnapshot` exposes topic, sources, findings, contradictions, checkpoint, actions, and receipt state. | `ResearchReceipt` proves citations, synthesis, checkpoint choice, deferred scope, provenance, and validity. | Reads local source fixtures and writes sessions/actions/receipts only to workdir. |
| Dispatch | Seeded incident event bundle -> triage/routing -> assignment checkpoint -> handoff receipt. | `IncidentTriageContract` computes event facts, severity, suspected cause, routing options, readiness, and receipt payload. | `IncidentSessionStore::CommandResult` covers open, triage, assignment, escalation, receipt, and refusals. | `DispatchSnapshot` exposes incident, severity/cause, route options, assignment/escalation, actions, and receipt state. | `IncidentReceipt` proves routing rationale, event citations, checkpoint, deferred no-remediation scope, provenance, and validity. | Reads incident/event/runbook/team fixtures and writes sessions/actions/receipts only to workdir. |

Stable enough for guide-level doctrine:

- `app.rb` as the visible composition boundary for services, mounted Web, and
  small command routes.
- App-owned services for fixture loading, deterministic analysis, mutable
  session state, receipt/report emission, and read snapshots.
- One deterministic contracts-native graph per showcase for the core
  analysis/readiness/payload computation.
- Local command result objects with success/refusal feedback codes and a
  recorded action fact.
- Detached snapshots as the read model for Web, `/events`, smoke output, and
  manual inspection.
- App-local receipts/reports as evidence artifacts with stable id, kind,
  validity, subject identity, provenance, evidence refs, action facts,
  deferred scope, metadata, and mutation-boundary proof.
- Deterministic catalog smoke that proves at least one success path, one
  refusal path, final state, receipt/report evidence, `/events` parity,
  runtime writes, and fixture/target no-mutation.
- README discoverability as part of showcase readiness, not a later docs chore.

Still app-local despite repetition:

- `CommandResult`, snapshot class names, fields, and payload shape.
- Feedback code strings, action fact vocabulary, entity ids, command names, and
  route labels.
- Fixture schemas, parsers, thresholds, readiness rules, routing/conflict/
  finding/checkpoint semantics, and validity rules.
- Receipt/report classes, payload keys, Markdown/hash rendering, evidence ref
  format, deferred-scope vocabulary, and workdir layout.
- Smoke output names, exact marker fragments, representative success/refusal
  path choices, and fixture signature strategy.

Support/API extraction assessment:

- A broad package API is still not justified. The four apps show a reliable
  convention, but local duplication is still preserving domain clarity rather
  than hiding it.
- The smallest justified extraction candidate is not runtime API; it is an
  examples/specs-scoped "showcase evidence helper" experiment for smoke
  scripts: file signature helpers, Rack env/form helpers, redirect following,
  stable fragment assertions, endpoint parity checks, and deterministic output
  helpers.
- A second safe candidate is docs-only enterprise packaging/discoverability:
  a portfolio page or guide index that explains Lense, Chronicle, Scout, and
  Dispatch as reference apps and points away from legacy as onboarding.
- Do not extract shared command result, snapshot, receipt/report class, marker
  DSL, route DSL, UI kit, workflow DSL, persistence, live runtime,
  `Igniter.interactive_app`, or cluster placement from this evidence.

Recommended next strategic track:

- Prefer an enterprise-facing documentation/discoverability pass next:
  "Application Showcase Portfolio Guide". The portfolio is now strong enough
  to present as a coherent story, and this will reduce future onboarding and
  agent-context load without creating premature APIs.
- If the team wants implementation instead of docs, prefer a tiny
  examples/specs-scoped showcase evidence helper experiment over another
  product app.
- If product pressure pauses or package work resumes, return to Embed/Contracts
  before Cluster/Mesh. The current portfolio is intentionally one-process and
  does not yet require distributed runtime machinery.
- Keep legacy material reference-only; active onboarding should point to
  current packages, `docs/guide/interactive-app-structure.md`, and the four
  showcase apps.

[Agent Application / Codex]
track: `docs/dev/application-showcase-portfolio-final-synthesis-track.md`
status: landed
delta: added app-side portfolio synthesis comparing Lense, Chronicle, Scout,
  and Dispatch by workflow, contract graph, command/refusal model, snapshot,
  action facts, receipt/report artifact, and mutation boundary.
delta: identified guide-level doctrine now stable across four apps and listed
  repeated shapes that still stay app-local despite repetition.
delta: recommended no broad API graduation; smallest support candidate is an
  examples/specs-scoped showcase evidence helper, while the preferred next
  strategic track is enterprise-facing portfolio docs/discoverability.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can add Web/read-model/manual-review synthesis;
  then `[Architect Supervisor / Codex]` can choose the next strategic track.
block: none
