# Application Capsules

Application capsules are the copyable unit for Igniter apps. A capsule keeps
contracts, services, optional web surfaces, imports, exports, and review
metadata local to one application boundary.

Use capsules when an app should be understandable before it is loaded, mounted,
copied, or connected to a larger host.

## Shape

Small capsules stay sparse: create only the folders the app owns.

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

The explicit data form is equally valid:

```ruby
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  layout_profile: :capsule,
  groups: %i[contracts services]
)
```

Use the data form for generators and diffs. Use the DSL form for human-edited
application code.

## Web Is Optional

A capsule can be web-capable without becoming a web framework object.
`igniter-application` accepts plain surface metadata; `igniter-web` owns
screens, routes, components, and rendering details.

```ruby
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  layout_profile: :capsule,
  groups: %i[contracts services],
  web_surfaces: [:operator_console]
)
```

This keeps non-web and web-capable apps in the same application vocabulary.

## Reports

Capsule reports are read-only inspection output. They summarize:

- identity and layout profile
- active and known groups
- planned sparse and complete paths
- imports and exports
- optional features, flows, and supplied surface metadata

Reports do not load constants, create files, execute contracts, mount web
surfaces, or boot an app.

```ruby
report = blueprint.capsule_report
report.to_h
```

## Transfer

Capsule transfer is review-first. The lifecycle is deliberately explicit:

1. inspect the capsule with `capsule_report`
2. review physical files with `transfer_inventory`
3. check readiness with `transfer_readiness`
4. build a `transfer_bundle_plan`
5. write and verify a transfer bundle
6. preview destination intake
7. dry-run apply operations
8. commit only reviewed file operations
9. verify the applied transfer
10. close with `transfer_receipt`

Only the explicit committed apply step mutates the destination filesystem.
Host wiring, load paths, provider registration, web route activation, contract
execution, and cluster placement remain outside transfer.

Runnable end-to-end example:

```bash
ruby examples/application/capsule_transfer_end_to_end.rb
```

## Activation Boundary

A complete transfer receipt means reviewed files landed and verified. It does
not mean the receiving host activated the app.

Host activation is a separate review lane:

- `host_activation_readiness`
- `host_activation_plan`
- `verify_host_activation_plan`
- optional ledger-backed acknowledgement receipts

The current ledger path records reviewed confirmations. It is not live host
mutation and does not boot providers, bind routes, execute contracts, or touch a
cluster.

## Examples

- [`examples/application/capsule_composition.rb`](../../examples/application/capsule_composition.rb)
- [`examples/application/capsule_assembly_plan.rb`](../../examples/application/capsule_assembly_plan.rb)
- [`examples/application/capsule_transfer_end_to_end.rb`](../../examples/application/capsule_transfer_end_to_end.rb)
- [`examples/application/capsule_host_activation_readiness.rb`](../../examples/application/capsule_host_activation_readiness.rb)

For app/web conventions, continue with
[Interactive App Structure](./interactive-app-structure.md).
