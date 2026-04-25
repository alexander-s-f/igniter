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

The complete transfer path from declaration to final receipt is:

1. Declare a capsule with explicit imports/exports and optional supplied web
   surface metadata.
2. Review declared files with `transfer_inventory`.
3. Decide if transfer is ready with `transfer_readiness`.
4. Build a read-only `transfer_bundle_plan`.
5. Write an explicit bundle artifact with `write_transfer_bundle`.
6. Read the artifact back with `verify_transfer_bundle`.
7. Preview the receiving root with `transfer_intake_plan`.
8. Convert intake into reviewed operations with `transfer_apply_plan`.
9. Run `apply_transfer_plan` without `commit:` for dry-run review.
10. Run `apply_transfer_plan(..., commit: true)` only when filesystem mutation
    is intentionally accepted.
11. Verify the committed result with `verify_applied_transfer`.
12. Produce the final audit artifact with `transfer_receipt`.

Only step 10 mutates the destination filesystem, and it is limited to reviewed
directory creation and file copy operations. Host wiring remains manual review
data; web surface metadata remains supplied/opaque context and never implies
route activation, mount binding, browser traffic, or an `igniter-web`
dependency.

For the compact executable version of the full path, see
[`examples/application/capsule_transfer_end_to_end.rb`](../../examples/application/capsule_transfer_end_to_end.rb).

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

When a human or agent needs one decision surface before a future transfer tool,
build transfer readiness over the manifest and inventory:

```ruby
readiness = Igniter::Application.transfer_readiness(
  operator,
  subject: :operator_bundle,
  host_exports: [
    { name: :audit_log, kind: :service, target: "Host::AuditLog" }
  ],
  surface_metadata: [
    { name: :operator_console, kind: :web_surface, path: "web" }
  ]
)

readiness.to_h
```

`ApplicationTransferReadiness` reports one `ready` boolean, blocking findings,
warnings, summary counts, and the nested handoff manifest and transfer
inventory. Findings keep stable `source`, `code`, `message`, and `metadata`
fields. Required import failures, unresolved mount intents, unsafe skipped
paths, and missing expected paths are blockers by default. Optional imports and
deferred file enumeration are warnings. Supplied web surface metadata is counted
as opaque transfer context; if a declared web surface has no supplied metadata,
readiness reports a warning without inspecting screens, routes, or components.

When you want to see what a future bundle tool would intend to include, build a
bundle plan:

```ruby
bundle_plan = Igniter::Application.transfer_bundle_plan(
  operator,
  subject: :operator_bundle,
  surface_metadata: [
    { name: :operator_console, kind: :web_surface, path: "web" }
  ]
)

bundle_plan.to_h
```

`ApplicationTransferBundlePlan` summarizes the subject, capsule entries,
included files already enumerated by the transfer inventory, missing paths,
supplied surfaces, blockers, warnings, readiness payload, and bundle policy.
By default, `bundle_allowed` is false when readiness is false. Use
`policy: { allow_not_ready: true }` only for review-only planning; it still
does not copy files or write archives. Web surfaces remain supplied metadata in
the bundle plan; application counts and carries those hashes without loading
`igniter-web` or inspecting web-local screens, routes, mounts, or components.

When the plan is allowed, an explicit writer can create a small directory
artifact:

```ruby
result = Igniter::Application.write_transfer_bundle(
  bundle_plan,
  output: "tmp/operator_bundle",
  metadata: { requested_by: :release_review }
)

result.to_h
```

`ApplicationTransferBundleArtifact` writes only to the caller-provided output
path, refuses existing output by default, refuses not-allowed bundle plans
unless `allow_not_ready: true` is passed for an explicit review artifact, and
copies only the files already listed in `bundle_plan.to_h[:included_files]`.
The artifact also includes `igniter-transfer-bundle.json` with the serialized
plan and caller metadata. Supplied web surface metadata remains part of that
serialized plan for review, but the writer does not use it to discover
web-local files, load `igniter-web`, bind mounts, or activate routes.

Bundle verification reads the written artifact back without extracting it:

```ruby
verification = Igniter::Application.verify_transfer_bundle("tmp/operator_bundle")

verification.to_h
```

`ApplicationTransferBundleVerification` reads
`igniter-transfer-bundle.json`, compares the planned entries with actual files
under `files/`, reports missing, extra, or malformed entries, and counts
supplied surfaces from serialized metadata. It never installs a bundle, copies
bundle contents into a destination, loads constants, or interprets web surface
internals.

Destination intake planning previews a verified artifact against an explicit
receiving root:

```ruby
intake = Igniter::Application.transfer_intake_plan(
  verification,
  destination_root: "apps/incoming"
)

intake.to_h
```

`ApplicationTransferIntakePlan` reports planned destination paths, existing
destination conflicts, blockers, warnings, required host wiring, and supplied
surface counts. It reads bundle metadata and destination filesystem state only;
it does not create directories, copy files, modify host configuration, install
bundles, or interpret web internals.

Apply operation planning converts accepted intake data into explicit future
operations without executing them:

```ruby
apply_plan = Igniter::Application.transfer_apply_plan(intake)

apply_plan.to_h
```

`ApplicationTransferApplyPlan` reports whether the intake is executable,
ordered `ensure_directory`, `copy_file`, and `manual_host_wiring` operation
data, blockers, warnings, and supplied surface counts. Operation paths are
review data derived from the intake plan; the plan does not create
directories, copy files, apply host wiring, install bundles, or interpret web
internals.

Apply execution is explicit and dry-run-first:

```ruby
dry_run = Igniter::Application.apply_transfer_plan(apply_plan)
committed = Igniter::Application.apply_transfer_plan(apply_plan, commit: true)

dry_run.to_h
committed.to_h
```

`ApplicationTransferApplyResult` consumes reviewed apply-plan operations. By
default it reports what would be applied without writing. With `commit: true`,
it first preflights the reviewed operations, then creates only reviewed
directories and copies only reviewed files from the artifact into the explicit
destination root. Existing destination files, unsafe paths, missing artifact
sources, unsupported operation types, and non-executable plans are refusals.
`manual_host_wiring` operations remain skipped/review-only and are never
applied.

Post-apply verification reads back a committed transfer result without
repairing it:

```ruby
applied_verification = Igniter::Application.verify_applied_transfer(
  committed,
  apply_plan: apply_plan
)

applied_verification.to_h
```

`ApplicationTransferAppliedVerification` verifies reviewed directories and file
copies against the destination filesystem and artifact source files. It reports
missing directories/files, unsafe paths, byte-size mismatches, content
mismatches, skipped/refused operations, and unexpected applied operations from
explicit result/plan data only. It does not create directories, copy files,
repair mismatches, apply host wiring, activate web, load constants, boot apps,
or route traffic.

Transfer receipts summarize explicit transfer reports into one closure
artifact:

```ruby
receipt = Igniter::Application.transfer_receipt(
  applied_verification,
  apply_result: committed,
  apply_plan: apply_plan
)

receipt.to_h
```

`ApplicationTransferReceipt` reports complete/valid/committed status, artifact
and destination roots, planned/applied/verified/finding/refusal/skipped counts,
manual actions, and supplied surface count. It consumes already-built reports
or hashes only; it does not rerun apply execution, rerun applied verification,
discover missing artifacts, repair files, apply host wiring, activate web, load
constants, boot apps, or route traffic.

### After Transfer Receipt

A complete receipt means the reviewed files landed and verified. It does not
mean the receiving host has activated the capsule. Host integration remains a
separate human/agent decision boundary.

Use the existing transfer artifacts as the post-transfer checklist:

- `ApplicationHandoffManifest` carries required host exports, host
  capabilities, suggested host wiring, mount intents, and supplied surface
  metadata.
- `ApplicationAssemblyPlan` carries intended mount metadata and composition
  readiness for the moved capsule set.
- `ApplicationTransferReadiness` records which requirements were blockers or
  warnings before the bundle was written.
- `ApplicationTransferApplyPlan` records the reviewed file operations and any
  `manual_host_wiring` operation data.
- `ApplicationTransferAppliedVerification` proves the committed files match
  the reviewed operations.
- `ApplicationTransferReceipt` is the final audit/closure summary and highlights
  remaining manual actions.

Before making a transferred capsule live, the receiving host still owns these
decisions:

- provide required host exports and capabilities using host-local objects
- perform or reject manual host wiring actions
- decide load paths, provider registration, contract registration, and
  scheduler/transport lifecycle
- review optional mount intents before binding routes or interaction surfaces
- treat supplied web surface metadata as opaque context unless `igniter-web` or
  another web-owned layer explicitly activates it

Transfer completion never loads constants, boots providers, starts schedulers,
binds mounts, activates routes, sends browser traffic, executes contracts, or
places work on a cluster. Those steps belong to explicit host/runtime,
web-owned, or cluster-owned activation flows.

Activation readiness is the read-only preflight for those host decisions:

```ruby
activation = Igniter::Application.host_activation_readiness(
  receipt,
  handoff_manifest: manifest,
  host_exports: [
    { name: :incident_runtime, kind: :service, target: "Host::IncidentRuntime" }
  ],
  host_capabilities: [:audit],
  load_paths: ["operator"],
  providers: [:incident_runtime],
  contracts: ["Contracts::ResolveIncident"],
  lifecycle: { boot: :manual_review },
  mount_decisions: [
    { capsule: :operator, kind: :web, at: "/operator", status: :accepted }
  ],
  surface_metadata: [
    { name: :operator_console, kind: :web_surface, path: "web" }
  ]
)

activation.to_h
```

`ApplicationHostActivationReadiness` reports `ready`, blockers, warnings,
explicit host decisions, manual actions, mount intents, and supplied surface
count. It treats incomplete transfer receipts, missing required host exports,
missing required capabilities, and unresolved manual actions as blockers.
Missing load path, provider, contract, lifecycle, or optional mount decisions
are warnings. It does not inspect directories, load constants, boot providers,
bind mounts, activate routes, send browser traffic, execute contracts, or place
work on a cluster.

This transfer guide deliberately stops before project-wide discovery,
automatic destination selection, applying host wiring, loading constants,
booting apps, mounting web routes, executing contracts, or placing work on a
cluster.

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
- [`examples/application/capsule_transfer_readiness.rb`](../../examples/application/capsule_transfer_readiness.rb)
- [`examples/application/capsule_transfer_bundle_plan.rb`](../../examples/application/capsule_transfer_bundle_plan.rb)
- [`examples/application/capsule_transfer_bundle_artifact.rb`](../../examples/application/capsule_transfer_bundle_artifact.rb)
- [`examples/application/capsule_transfer_bundle_verification.rb`](../../examples/application/capsule_transfer_bundle_verification.rb)
- [`examples/application/capsule_transfer_intake_plan.rb`](../../examples/application/capsule_transfer_intake_plan.rb)
- [`examples/application/capsule_transfer_apply_plan.rb`](../../examples/application/capsule_transfer_apply_plan.rb)
- [`examples/application/capsule_transfer_apply_execution.rb`](../../examples/application/capsule_transfer_apply_execution.rb)
- [`examples/application/capsule_transfer_applied_verification.rb`](../../examples/application/capsule_transfer_applied_verification.rb)
- [`examples/application/capsule_transfer_receipt.rb`](../../examples/application/capsule_transfer_receipt.rb)
- [`examples/application/capsule_transfer_end_to_end.rb`](../../examples/application/capsule_transfer_end_to_end.rb)
- [`examples/application/capsule_host_activation_readiness.rb`](../../examples/application/capsule_host_activation_readiness.rb)

They are smoke-tested through the examples catalog and show the current
capsule vocabulary without browser transport, cluster placement, or workflow
execution.
