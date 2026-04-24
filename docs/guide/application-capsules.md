# Application Capsules

Application capsules are the user-facing shape for portable Igniter
applications. A capsule owns its app-local contracts, services, optional web
surfaces, portability metadata, and inspection reports.

Use capsules when you want an Igniter application to be understandable before it
is loaded, mounted, copied, or connected to a larger host.

## Mental Model

An application capsule is a portability boundary.

That means:

- app-owned code stays inside the capsule
- dependencies on a host or sibling app are declared as imports
- capabilities the capsule offers are declared as exports
- web is an optional surface, not a required app type
- feature slices are optional organization metadata for larger apps
- flow declarations describe candidate interaction state, but do not execute
  workflows
- capsule reports are read-only inspection output for humans and agents

The important difference from Rails-style global buckets is locality. A feature
does not have to be scattered across unrelated top-level directories owned by a
stack. Small capsules can stay flat; larger capsules can add feature-slice
metadata when locality becomes useful.

## Sparse First

The default shape is sparse: materialize only the paths the capsule actually
owns.

Clean form:

```ruby
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  env: :development,
  layout_profile: :capsule,
  groups: %i[contracts services],
  exports: [
    { name: :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident" }
  ],
  imports: [
    { name: :incident_runtime, kind: :service, from: :host, capabilities: [:incidents] }
  ]
)
```

Human authoring form:

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
end

blueprint = capsule.to_blueprint
```

Both forms produce the same `ApplicationBlueprint` semantics. Use the clean form
when generating or diffing explicit configuration; use the human form when you
want compact, readable capsule declarations.

With `layout_profile: :capsule`, logical groups map to compact paths such as
`contracts`, `services`, `web`, `support`, `spec`, and `igniter.rb`.

Sparse structure plans include only active groups:

```ruby
blueprint.structure_plan.to_h.fetch(:missing_groups)
```

Complete structure plans remain available for inspection or explicit
materialization:

```ruby
blueprint.structure_plan(mode: :complete)
```

## Web Is A Surface

A non-web capsule and a web-capable capsule use the same application vocabulary.
Adding web means declaring a surface group and allowing a web package to provide
surface metadata.

```ruby
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  layout_profile: :capsule,
  groups: %i[contracts services],
  web_surfaces: [:operator_console]
)
```

`igniter-application` does not inspect screens, routes, or browser forms.
Surface packages such as `igniter-web` can supply plain metadata to capsule
reports.

In `igniter-web`, this metadata starts from a `SurfaceManifest`. The manifest
describes what a web surface exports, which contracts/services/projections it
imports, and which candidate interactions a screen declares. It stays
web-owned; the application layer receives only serialized hashes.

```ruby
web = Igniter::Web.application do
  screen :incident_review, intent: :human_decision do
    ask :clarification, as: :textarea
    action :approve_plan,
           run: "Contracts::ResolveIncident",
           action_type: :contract
  end

  screen_route "/incident-review", :incident_review
end

surface = Igniter::Web.surface_manifest(
  web,
  name: :operator_console,
  path: "/operator"
)
```

For inspection, web can compare that surface with app-owned flow and feature
metadata:

```ruby
surface_metadata = Igniter::Web.flow_surface_metadata(
  surface,
  declaration: blueprint.flow_declarations.first,
  feature: blueprint.feature_slices.first
)

blueprint.capsule_report(surface_metadata: [surface_metadata])
```

This does not start a flow, submit a form, or execute a contract. It gives the
capsule report a plain surface envelope with summary status, related flows and
features, and nested projection details.

## Feature Slices

Feature slices are optional reporting metadata. They are useful when a capsule
grows large enough that feature-local ownership matters.

```ruby
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  layout_profile: :capsule,
  features: [
    {
      name: :incidents,
      groups: %i[contracts services web],
      contracts: ["Contracts::ResolveIncident"],
      services: [:incident_queue],
      exports: [:resolve_incident],
      imports: [:incident_runtime],
      flows: [:incident_review],
      surfaces: [:operator_console]
    }
  ]
)
```

This does not require a `features/` directory and does not create a runtime
boundary. It makes ownership inspectable.

## Flow Declarations

Flow declarations are app-owned metadata for agent-native and
human-in-the-loop workflows.

```ruby
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  layout_profile: :capsule,
  flows: [
    {
      name: :incident_review,
      purpose: "Review incident plan before execution",
      initial_status: :waiting_for_user,
      current_step: :review_plan,
      pending_inputs: [
        { name: :clarification, input_type: :textarea, target: :review_plan }
      ],
      pending_actions: [
        { name: :approve_plan, action_type: :contract, target: "Contracts::ResolveIncident" }
      ],
      contracts: ["Contracts::ResolveIncident"],
      services: [:incident_queue],
      surfaces: [:operator_console]
    }
  ]
)
```

A declaration does not start a flow, execute a contract, submit a browser form,
or run an agent. Runtime state is still explicit:

```ruby
declaration = blueprint.flow_declarations.first
environment = Igniter::Application::Environment.new(
  profile: blueprint.apply_to(Igniter::Application.build_kernel).finalize
)

environment.start_flow(
  declaration.name,
  status: declaration.initial_status,
  current_step: declaration.current_step,
  pending_inputs: declaration.pending_inputs.map(&:to_h),
  pending_actions: declaration.pending_actions.map(&:to_h)
)
```

## Capsule Reports

Capsule reports summarize a blueprint without loading code or materializing
files.

```ruby
report = blueprint.capsule_report(
  surface_metadata: [
    {
      name: :operator_console,
      kind: :web_surface,
      status: :aligned,
      flows: [:incident_review],
      features: [:incidents],
      projections: {
        flow_surface: {
          status: :aligned
        }
      }
    }
  ]
)

report.to_h
```

The report includes identity, layout profile, active and known groups,
sparse/complete planned paths, exports/imports, feature slices, flow
declarations, contracts/services, and supplied surface metadata.

## Transfer And Handoff Review

Capsule transfer is a review step, not an automatic packaging or activation
step. Before a capsule moves into a new host, build the read-only chain:

- `capsule_report` explains one capsule
- `compose_capsules` explains whether capsule imports are satisfied by sibling
  capsules or host exports
- `assemble_capsules` adds intended mount metadata over the same composition
  readiness
- `handoff_manifest` summarizes what is moving and what the receiving host must
  provide

```ruby
manifest = Igniter::Application.handoff_manifest(
  subject: :operator_bundle,
  capsules: [incident_core, operator],
  host_exports: [
    { name: :audit_log, kind: :service, target: "Host::AuditLog" }
  ],
  host_capabilities: [:audit],
  mount_intents: [
    {
      capsule: :operator,
      kind: :web,
      at: "/operator",
      capabilities: %i[screen stream],
      metadata: { surface: :operator_console }
    }
  ],
  surface_metadata: [
    {
      name: :operator_console,
      kind: :web_surface,
      status: :aligned
    }
  ]
)

manifest.to_h
```

`ApplicationHandoffManifest` answers four transfer questions:

- `ready` says whether required imports and mount intents are satisfied
- `unresolved_required_imports` lists required imports that still need a
  sibling capsule export or host export
- `missing_optional_imports` lists optional imports that are not wired yet, but
  do not block readiness
- `suggested_host_wiring` is the host-facing checklist for imports that should
  be provided by the receiving host

Web surface data remains supplied metadata. `igniter-application` does not
inspect screens, routes, components, Rack apps, or browser transports; a web
package may produce a plain metadata hash and pass it into the manifest. In
`igniter-web`, that hash can come from `Igniter::Web.surface_metadata(surface)`
or `Igniter::Web.flow_surface_metadata(...)`.

When you need to review physical capsule material before a future copy/package
tool, use a transfer inventory:

```ruby
inventory = Igniter::Application.transfer_inventory(
  operator,
  surface_metadata: [
    {
      name: :operator_console,
      kind: :web_surface,
      path: "web",
      screens_path: "web/screens"
    }
  ]
)

inventory.to_h
```

`ApplicationTransferInventory` reports declared capsule roots, active groups,
expected sparse layout paths, existing paths, missing expected paths, optional
file counts under declared paths, and supplied surface path metadata. A web
package may produce that metadata from its own path vocabulary, such as
`Igniter::Web.surface_structure(blueprint)`. The inventory only looks under
explicit capsule roots and declared application layout paths.

This transfer guide deliberately stops before copying files, creating archives,
discovering directories, loading constants, booting apps, mounting web routes,
executing contracts, or placing work on a cluster.

## Runnable Examples

Start with these examples:

- [`examples/application/capsule_manifest.rb`](../../examples/application/capsule_manifest.rb)
- [`examples/application/feature_flow_report.rb`](../../examples/application/feature_flow_report.rb)
- [`examples/application/capsule_inspection.rb`](../../examples/application/capsule_inspection.rb)
- [`examples/application/capsule_authoring_dsl.rb`](../../examples/application/capsule_authoring_dsl.rb)
- [`examples/application/capsule_composition.rb`](../../examples/application/capsule_composition.rb)
- [`examples/application/capsule_assembly_plan.rb`](../../examples/application/capsule_assembly_plan.rb)
- [`examples/application/capsule_handoff_manifest.rb`](../../examples/application/capsule_handoff_manifest.rb)
- [`examples/application/capsule_transfer_inventory.rb`](../../examples/application/capsule_transfer_inventory.rb)

They are smoke-tested through the examples catalog and show the current
capsule vocabulary without browser transport, cluster placement, or workflow
execution.
