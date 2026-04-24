# Application Capsule Assembly Plan Track

This track follows the accepted capsule composition cycle.

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

Igniter now has portable capsules, human authoring sugar, inspection reports,
and composition readiness over explicit imports/exports. The next useful layer
is an inspectable assembly plan: a host-local description of which capsules are
present, which composition report applies, and which mount/surface intents the
host may later use.

This must remain a plan/read model. It must not boot, mount, route, execute, or
discover anything.

## Goal

Design and land the smallest host-local assembly plan for application capsules:

- list selected capsules
- carry host exports/capabilities
- include the composition readiness report
- include optional mount intents as metadata
- include optional surface metadata as explicit input
- expose stable `to_h`

The plan should help a human or agent answer: "If I copy these capsules into a
host, what still needs to be wired before runtime?"

## Scope

In scope:

- application-owned read-only assembly plan/report over explicit capsule inputs
- reuse `ApplicationCompositionReport` rather than duplicating matching logic
- optional mount intents such as `{ capsule: :operator, kind: :web, at: "/operator" }`
- optional supplied surface metadata, still opaque to application
- smoke example showing a ready assembly and a mount intent
- documentation touch only if needed to clarify the difference between
  composition and assembly

Out of scope:

- actually mounting apps
- Rack/browser routing
- booting application environments
- file discovery or autoloading
- contract/service execution
- cluster placement or distributed routing
- replacing existing stack runtime
- making `igniter-web` define application assembly semantics

## Accepted Constraints

- Assembly plan is host-local metadata, not a runtime container.
- Composition readiness remains the source of import/export truth.
- Mount intents are declarations only; they do not call mount APIs.
- Web surface metadata may be attached as explicit plain hashes, but
  application does not inspect screen graphs, routes, or components.
- The plan should accept clean blueprints and DSL capsules through
  `to_blueprint`.

## Task 1: Assembly Plan Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned plan shape, for example
  `ApplicationAssemblyPlan`.
- Accept capsules/blueprints, host exports, host capabilities, optional mount
  intents, optional surface metadata, and metadata.
- Reuse `ApplicationCompositionReport` internally or expose it as a nested
  report.
- Expose `ready?` from composition readiness.
- Expose stable `to_h`.
- Do not boot, mount, load, discover, materialize, route, or execute anything.

## Task 2: Mount Intent Metadata

Owner: `[Agent Application / Codex]`

Acceptance:

- Define a tiny mount-intent hash/value shape sufficient for inspection:
  `capsule`, `kind`, `at`, `capabilities`, and `metadata`.
- Validate/normalize only enough to keep `to_h` stable.
- Do not call `Environment#mount`, `Igniter::Web.mount`, Rack, or any runtime
  binding.
- Specs cover no mounts, one web mount intent, and a mount intent for an
  unresolved capsule name if the plan chooses to report it.

## Task 3: Smoke Example

Owner: `[Agent Application / Codex]`

Support: `[Agent Web / Codex]` if web surface metadata is shown.

Suggested file:

- `examples/application/capsule_assembly_plan.rb`

Acceptance:

- Build at least two capsules, one host export, and one mount intent.
- Include a composition report nested in the assembly plan.
- Print compact smoke keys.
- No runtime boot, mount, web transport, cluster behavior, or contract
  execution.

Suggested smoke keys:

```text
application_capsule_assembly_capsules=...
application_capsule_assembly_ready=...
application_capsule_assembly_mounts=...
application_capsule_assembly_composition_ready=...
application_capsule_assembly_unresolved=...
application_capsule_assembly_surfaces=...
```

## Task 4: Web Compatibility Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify a web mount intent can reference a capsule/surface without application
  inspecting web internals.
- Use existing web surface metadata helpers only as explicit input if needed.
- Do not introduce web-specific assembly behavior into `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_assembly_plan.rb
ruby examples/application/capsule_composition.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web examples/specs change, include the relevant `packages/igniter-web/spec`
slice in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 as a read-only
   assembly plan over explicit metadata.
2. `[Agent Web / Codex]` stays in compatibility-review mode unless surface
   metadata or web mount intents need a package-local note.
3. Keep this as planning/inspection. Do not turn it into boot, mount, route,
   discover, execute, or cluster placement.
