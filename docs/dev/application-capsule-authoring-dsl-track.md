# Application Capsule Authoring DSL Track

This track follows the accepted application capsule guide cycle.

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

The capsule model is now documented, but the public examples still require a
lot of low-level hash ceremony. Igniter already has a doctrine that clean agent
forms and human sugar DSL forms may both be valid when they compile to the same
lower-level model.

This track applies that doctrine to application capsule authoring.

## Goal

Design and land the smallest human-facing authoring DSL for application
capsules while keeping `ApplicationBlueprint` as the clean inspectable model.

The DSL should make common capsule declarations readable:

- identity and layout profile
- logical groups
- exports/imports
- optional feature slices
- flow declarations
- optional web surfaces by metadata

It must not add loading, discovery, execution, routing, browser transport, or
workflow semantics.

## Scope

In scope:

- a small application-owned builder/sugar surface that compiles to
  `ApplicationBlueprint`
- stable expansion/introspection, for example `to_blueprint`, `to_h`, or a
  sugar expansion report
- examples comparing clean blueprint form and human DSL form
- docs updates only where they clarify the accepted public authoring path
- web-owned docs/examples only if web surface metadata needs a compact
  companion shape

Out of scope:

- generators/scaffolders
- file loading/autoloading/discovery
- materializing directories by default
- contract execution
- flow execution or state-machine behavior
- browser route/form transport
- making `igniter-application` depend on `igniter-web`

## Accepted Constraints

- Clean form remains valid:

```ruby
Igniter::Application.blueprint(...)
```

- Human sugar may exist beside it, but must compile to the same
  `ApplicationBlueprint` semantics.
- Sugar should be inspectable before execution or materialization.
- Feature slices remain optional metadata.
- Flow declarations remain metadata; active runtime state still uses explicit
  `Environment#start_flow` / `resume_flow`.
- Web surfaces are names/metadata at the application layer; web still owns
  screen graphs and surface manifests.

## Candidate Shape

This is directional, not final API:

```ruby
capsule = Igniter::Application.capsule(:operator, root: "apps/operator") do
  layout :capsule

  groups :contracts, :services

  export :resolve_incident,
         kind: :contract,
         target: "Contracts::ResolveIncident"

  import :incident_runtime,
         kind: :service,
         from: :host,
         capabilities: [:incidents]

  web_surface :operator_console

  feature :incidents do
    groups :contracts, :services, :web
    contract "Contracts::ResolveIncident"
    service :incident_queue
    export :resolve_incident
    import :incident_runtime
    flow :incident_review
    surface :operator_console
  end

  flow :incident_review do
    purpose "Review incident plan before execution"
    initial_status :waiting_for_user
    current_step :review_plan
    pending_input :clarification, input_type: :textarea, target: :review_plan
    pending_action :approve_plan,
                   action_type: :contract,
                   target: "Contracts::ResolveIncident"
    contract "Contracts::ResolveIncident"
    service :incident_queue
    surface :operator_console
  end
end

blueprint = capsule.to_blueprint
```

Agents may propose a smaller or better local shape if it is more idiomatic with
the existing package style.

## Task 1: DSL Proposal And Minimal Builder

Owner: `[Agent Application / Codex]`

Acceptance:

- Propose the smallest public surface before implementing broad breadth.
- Add an application-owned builder or sugar object that returns or can produce
  an `ApplicationBlueprint`.
- Cover identity, layout profile, groups, exports/imports, feature slices, flow
  declarations, and web surface names.
- Expose inspectable output before any materialization, such as
  `to_blueprint.to_h` and/or sugar expansion metadata.
- The generated blueprint matches the clean hash form for equivalent input.
- No loader magic, contract execution, flow execution, or web dependency is
  introduced.

## Task 2: Examples And Guide Alignment

Owner: `[Agent Application / Codex]`

Acceptance:

- Add a smoke example, suggested:
  `examples/application/capsule_authoring_dsl.rb`.
- The example prints matching keys for DSL-built blueprint/report output.
- Update `docs/guide/application-capsules.md` only enough to show clean form
  and human sugar form as equal authoring options.
- Keep internal track language out of user-facing docs.

Suggested smoke keys:

```text
application_capsule_dsl_name=...
application_capsule_dsl_exports=...
application_capsule_dsl_imports=...
application_capsule_dsl_features=...
application_capsule_dsl_flows=...
application_capsule_dsl_report=...
```

## Task 3: Web Surface Compatibility Check

Owner: `[Agent Web / Codex]`

Acceptance:

- Review whether the DSL-created blueprint works unchanged with
  `Igniter::Web.surface_manifest(...)`,
  `Igniter::Web.flow_surface_metadata(...)`, and
  `ApplicationBlueprint#capsule_report(surface_metadata:)`.
- Add docs/example adjustments only if web surface metadata becomes awkward.
- Do not add web-specific DSL to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_authoring_dsl.rb
ruby examples/application/capsule_inspection.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web docs/examples change, include the relevant `packages/igniter-web/spec`
slice in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 with the narrowest builder that
   proves clean form and sugar form are equivalent.
2. `[Agent Web / Codex]` stays in compatibility-review mode until the
   application-owned DSL shape lands.
3. Keep the DSL small. This is authoring sugar over `ApplicationBlueprint`, not
   a new application runtime.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-authoring-dsl-track.md`
Status: landed.
Changed:
- Added `Igniter::Application.capsule(...)` and application-owned
  `CapsuleBuilder` as human authoring sugar over `ApplicationBlueprint`.
- The builder covers layout profile, groups, exports/imports, feature slices,
  flow declarations, web surface names, services/contracts/interfaces, config,
  and metadata.
- Added `examples/application/capsule_authoring_dsl.rb` comparing clean form and
  DSL form equivalence.
- Updated the application capsule guide with clean form and human form examples.
Accepted:
- `capsule.to_blueprint.to_h` matches the clean `ApplicationBlueprint` form for
  equivalent input.
- The DSL is inspectable through `to_blueprint` and `to_h`.
- No loading, discovery, execution, routing, browser transport, web dependency,
  or workflow semantics were introduced.
Needs:
- `[Agent Web / Codex]` can now run the compatibility check against
  `Igniter::Web.surface_manifest(...)`,
  `Igniter::Web.flow_surface_metadata(...)`, and
  `ApplicationBlueprint#capsule_report(surface_metadata:)`.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-authoring-dsl-track.md`
Status: landed.
Changed:
- Reviewed the application-owned capsule DSL against the web-owned surface
  metadata path.
- Updated `examples/application/capsule_authoring_dsl.rb` so a DSL-created
  blueprint feeds `Igniter::Web.surface_manifest(...)`,
  `Igniter::Web.flow_surface_metadata(...)`, and
  `ApplicationBlueprint#capsule_report(surface_metadata:)`.
- Updated the examples catalog with web surface/projection smoke flags.
Accepted:
- The DSL-created blueprint works unchanged with existing web helpers because
  web surfaces, feature surfaces, and flow surfaces remain plain metadata names.
- No web-specific DSL is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the authoring DSL cycle for
  acceptance.
