# Application Capsule Guide Track

This track follows the accepted capsule inspection cycle.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as the next broad track.

The application/capsule model now exists in code and internal tracks:

- layout profiles and sparse/complete structure plans
- capsule exports/imports
- optional feature slices
- app-owned flow declarations
- application-owned capsule inspection reports
- web-owned surface manifests, flow projections, and surface metadata envelopes

The next step is not another runtime slice. It is to turn this into a compact,
user-facing explanation and example path so humans can understand how to build
portable Igniter applications with or without web.

## Goal

Create the first stable public narrative for application capsules:

- what an application capsule is
- how it differs from Rails-style global buckets
- how to start sparse and grow toward feature slices
- how web remains an optional surface
- how exports/imports, flow declarations, and capsule reports help portability
  and agent handoff

The guide should be practical, not exhaustive.

## Scope

In scope:

- user-facing guide updates in `docs/guide/`
- `docs/current/app-structure.md` alignment or supersession note
- package README alignment only if package-local docs are stale
- example references for `capsule_manifest`, `feature_flow_report`, and
  `capsule_inspection`
- small docs-only terminology cleanup in dev docs if needed

Out of scope:

- new runtime APIs unless a doc example exposes a real bug
- DSL sugar for capsule authoring
- generators/scaffolders
- web transport or browser forms
- cluster deployment semantics
- private SparkCRM-specific material

## Accepted Vocabulary

- `Application capsule`: the portability boundary for app-owned code and
  metadata.
- `Layout profile`: a named path vocabulary, not a required physical scaffold.
- `Sparse structure`: the default user-facing shape; materialize only paths
  with real ownership.
- `Feature slice`: optional organization/reporting metadata for scale.
- `Flow declaration`: app-owned metadata that describes candidate interaction
  state; it does not execute flows.
- `Capsule report`: read-only inspection output for humans and agents.
- `Surface metadata`: explicit plain metadata supplied by a surface package
  such as `igniter-web`.

## Task 1: User Guide Narrative

Owner: `[Agent Application / Codex]`

Acceptance:

- Add or update a user-facing guide page for application capsules.
- Explain sparse-first application structure with and without web.
- Show how exports/imports, feature slices, flow declarations, and capsule
  reports fit together.
- Include a compact code example or point to the smoke examples.
- Avoid internal agent-track language in user-facing prose.

Suggested files:

- `docs/guide/application-capsules.md`
- `docs/guide/README.md`

## Task 2: Current Structure Alignment

Owner: `[Agent Application / Codex]`

Support: `[Architect Supervisor / Codex]`

Acceptance:

- Update `docs/current/app-structure.md` so it no longer contradicts the
  accepted capsule model.
- If the current doc is too legacy-heavy, add a clear note that the guide page
  is the preferred user-facing reference.
- Keep detailed research history in `docs/dev/application-structure-research.md`.

## Task 3: Web Surface Guide Notes

Owner: `[Agent Web / Codex]`

Acceptance:

- Add a short guide or package README note explaining web as an optional
  surface inside an application capsule.
- Reference surface manifests, flow surface projections, and surface metadata
  envelopes as inspection aids, not runtime coupling.
- Do not make `igniter-application` depend on `igniter-web`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_manifest.rb
ruby examples/application/feature_flow_report.rb
ruby examples/application/capsule_inspection.rb
bundle exec rspec spec/current/example_scripts_spec.rb
```

If docs-only changes do not affect executable examples, this gate is still
useful as an examples catalog check.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 as a docs-first
   stabilization pass.
2. `[Agent Web / Codex]` handles Task 3 after or alongside the application
   guide wording.
3. Keep this cycle user-facing and explanatory. Do not add new runtime surface
   unless documentation exposes a concrete correctness bug.
