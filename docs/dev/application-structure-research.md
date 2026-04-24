# Application Structure Research

This note starts the research track for user-facing Igniter application
structure. It is intentionally exploratory, but it should bias toward decisions
that make real user apps easier to build, copy, mount, inspect, and evolve.

## Research Goal

[Architect Supervisor / Codex] Find a structure that works for both web-capable
and non-web Igniter apps while preserving one homogeneous mental model:

- an app is a portable directory
- the directory can be copied into another project
- mounting is explicit
- app-local code stays inside the app
- web is an optional interaction surface, not a different kind of application
- dependencies on sibling apps, host services, or cluster/runtime features are
  explicit in manifest/blueprint metadata

This may soften earlier purity requirements if it improves user ergonomics.
The bar is not "perfect taxonomy"; the bar is "users can see where code belongs
and can move an app without spelunking through the whole project."

## External Patterns Worth Borrowing

Sources checked:

- Rails Engines guide:
  https://edgeguides.rubyonrails.org/engines.html
- Hanami slices guide:
  https://guides.hanamirb.org/v2.0/app/slices/
- Django reusable apps guide:
  https://docs.djangoproject.com/en/dev/intro/reusable-apps/
- Phoenix contexts guide:
  https://hexdocs.pm/phoenix/contexts.html

[Architect Supervisor / Codex] Rails Engines provide the closest package/mount
analogy: engines are mini applications, mountable engines isolate namespace and
routes, and the host application remains the final authority. Igniter should
borrow the mountable/isolated idea, but not Rails' tendency to spread one
feature across global `models`, `controllers`, `views`, `jobs`, and host-level
routes.

[Architect Supervisor / Codex] Hanami slices are closer to Igniter's desired
shape: a slice is a distinct app/domain module with its own root, container,
providers, settings, routes, imports/exports, and independent loading. Igniter
should borrow slice-local containers and selective loading, but avoid requiring
every app to understand a full web framework structure.

[Architect Supervisor / Codex] Django reusable apps reinforce the packaging
lesson: reusable app code should live in a package with explicit app identity,
unique labels, tests, and install/mount configuration. Igniter should borrow the
copyable package idea, but make app-to-app access more explicit than Django's
global installed-app registry.

[Architect Supervisor / Codex] Phoenix contexts are useful as a warning and a
partial guide. They put a boundary around domain behavior and expose public
APIs to the web layer, but they are not themselves portable app directories.
Igniter should borrow the "web calls a domain boundary" principle, not the file
layout.

## Current Igniter Signals

Current clean-slate `igniter-application` defaults:

```text
app/contracts
app/providers
app/services
app/effects
app/packs
app/executors
app/tools
app/agents
app/skills
config/igniter.rb
spec/igniter
```

Legacy/current stack direction emphasized:

```text
apps/<app>/
  contracts/
  executors/
  agents/
  tools/
  skills/
  web/
  support/
  spec/
  app.rb
  app.yml
```

[Architect Supervisor / Codex] These are not irreconcilable. The clean-slate
layout is good for a standalone app root; the legacy stack shape is good for
human scanability inside `apps/<name>`. The final structure can support a
portable app capsule while allowing structure plans to choose a compact or
expanded layout.

## Design Principles

[Architect Supervisor / Codex] App root is the portability boundary.

Everything required for an app's local behavior should fit under one root:

```text
apps/operator/
```

Copying that directory should preserve contracts, services, agents, web
surfaces, tests, and app-local support code. Host-level wiring can be missing,
but it should be discoverable through the app manifest.

[Architect Supervisor / Codex] Web is a surface, not a separate app type.

A web-capable app should not switch to a different structure. It should add a
web surface inside the same app capsule.

[Architect Supervisor / Codex] Prefer explicit exports/imports over direct
constant reach-in.

The legacy stack insight stays important: pluggability comes from narrow
interfaces and mount declarations, not from every app being able to read sibling
internals.

[Architect Supervisor / Codex] Feature locality should be available but not
mandatory.

Small apps should be flat and obvious. Large apps need a place for feature
slices without abandoning the same mental model.

## Proposed Vocabulary

[Architect Supervisor / Codex] Use these terms consistently before adding more
structure APIs:

- `capsule`
  the portable application root; the unit a user can copy, mount, inspect, and
  test
- `layout profile`
  a named physical mapping from logical groups to filesystem paths
- `group`
  a logical code or config category such as `contracts`, `services`, `web`, or
  `spec`
- `surface`
  an interaction boundary exposed by an app, such as `web`, `mcp`, `http`,
  `cli`, `scheduler`, or future operator/agent surfaces
- `feature`
  an optional intra-app locality boundary for larger apps
- `export`
  a named service/interface/contract/mount exposed by the capsule
- `import`
  an explicit dependency on a host or sibling export

[Architect Supervisor / Codex] The important hierarchy is:

```text
capsule
  layout profile
  groups
  surfaces
  optional features
  exports/imports
```

Not:

```text
web app
  controllers
  models
  views
```

This keeps Igniter centered on contracts, services, agents, and interaction
surfaces instead of recapitulating MVC.

## Homogeneous Logical Groups

[Architect Supervisor / Codex] A web-capable and non-web app should share the
same logical vocabulary. They differ by activated groups, not by architecture.

Baseline groups:

```text
config
contracts
services
providers
effects
packs
executors
agents
tools
skills
support
spec
```

Optional surface groups:

```text
web
mcp
http
cli
scheduler
```

Optional web subgroups:

```text
web/screens
web/pages
web/components
web/projections
web/webhooks
web/assets
```

[Architect Supervisor / Codex] `web/projections` should stay allowed as a web
surface convention, but projections should not become web-owned conceptually.
If a projection is consumed outside web, the app can expose it under a top-level
`projections` group later. Until then, `web/projections` is acceptable as a
surface-local rendering/streaming convention.

## Layout Profiles

[Architect Supervisor / Codex] Recommended first profiles:

| Profile | Use case | Config path | Contracts path | Web path |
| --- | --- | --- | --- | --- |
| `:standalone` | generated app root, gem-like app, examples | `config/igniter.rb` | `app/contracts` | `app/web` |
| `:capsule` | app under `apps/<name>` inside a stack | `igniter.rb` | `contracts` | `web` |
| `:expanded_capsule` | stack app that wants config/app separation | `config/igniter.rb` | `app/contracts` | `app/web` |

[Architect Supervisor / Codex] `:standalone` and `:expanded_capsule` can share
the same path mapping initially. The semantic distinction helps generators and
docs speak clearly to different user contexts without multiplying internals.

Possible API shape:

```ruby
Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  layout_profile: :capsule,
  groups: %i[contracts services agents web spec],
  web_surfaces: %i[operator_console agent_chat]
)
```

The equivalent explicit form should remain possible:

```ruby
Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  paths: {
    contracts: "domain/contracts",
    web: "interaction/web"
  }
)
```

[Architect Supervisor / Codex] Path overrides should be a last-mile escape
hatch, not the primary teaching path. Users should learn profiles and groups
first.

## Sparse Materialization

[Architect Supervisor / Codex] Structure plans should become sparse by default.
The current all-default-groups materialization is useful for proving the seam,
but it is not the friendliest app scaffold.

Proposed default behavior:

- always materialize `config` and `spec`
- materialize groups explicitly listed in `groups:`
- materialize groups implied by blueprint fields:
  - `contracts:` implies `contracts`
  - `providers:` implies `providers`
  - `services:` or `interfaces:` implies `services`
  - `effects:` implies `effects`
  - `web_surfaces:` implies `web`
- do not create empty `agents`, `skills`, `tools`, or `effects` directories
  unless requested or implied

Possible API:

```ruby
blueprint.structure_plan(mode: :sparse)
blueprint.structure_plan(mode: :complete)
```

[Architect Supervisor / Codex] `:sparse` should be the user-facing default.
`:complete` is useful for docs, test fixtures, and users who want the whole
canonical shape visible.

## Capsule Manifest

[Architect Supervisor / Codex] A portable app should carry its own manifest
intent. Whether that is `igniter.rb`, `config/igniter.rb`, or both, the manifest
should describe:

- app name and namespace
- layout profile
- activated groups
- exported services/interfaces/contracts/mounts
- required imports
- surfaces such as web or mcp
- optional feature slices
- metadata useful to generators and inspectors

Sketch:

```ruby
Igniter::Application.define :operator do
  layout :capsule

  groups :contracts, :services, :agents, :web

  export :cluster_status, as: :service
  import :incident_runtime

  web do
    mount :operator_console, at: "/operator"
    surface :agent_chat
  end
end
```

[Architect Supervisor / Codex] This is intentionally not current API. It names
the desired authoring feel: declarative enough for tooling, explicit enough for
portability, and still independent of any web renderer.

## Feature Slices Inside A Capsule

[Architect Supervisor / Codex] Feature slices should be a growth feature, not
the default scaffold.

Recommended convention:

```text
apps/operator/
  features/
    incidents/
      contracts/
      services/
      agents/
      web/
        screens/
        components/
```

Rules:

- feature slices may use the same group names as the root capsule
- root-level groups remain the default for small apps
- a feature can be copied out later only if its imports/exports are explicit
- loaders should report feature-local groups separately from root groups

Possible future manifest shape:

```ruby
feature :incidents do
  groups :contracts, :services, :web
  export :incident_projection
end
```

## Non-Web And Web Examples

[Architect Supervisor / Codex] Non-web app using the same capsule vocabulary:

```text
apps/pricing/
  igniter.rb
  contracts/
    quote_total.rb
  services/
    tax_table.rb
  effects/
    journal_quote.rb
  spec/
```

[Architect Supervisor / Codex] Web-capable app adds only a surface:

```text
apps/operator/
  igniter.rb
  contracts/
    resolve_incident.rb
  services/
    cluster_status.rb
  agents/
    incident_reviewer.rb
  web/
    screens/
      incident_review.rb
    components/
      severity_badge.rb
    projections/
      cluster_events.rb
  spec/
```

The mental model remains: `apps/<name>` is the capsule; `web/` is a surface.

## Candidate A: Expanded Capsule With `app/`

```text
apps/operator/
  config/
    igniter.rb
  app/
    contracts/
    services/
    providers/
    effects/
    packs/
    executors/
    agents/
    tools/
    skills/
    web/
      screens/
      pages/
      components/
      projections/
      webhooks/
  spec/
    igniter/
  README.md
```

Pros:

- matches current `ApplicationLayout` defaults
- clearly separates implementation code from config/spec/docs
- works equally with and without `app/web`
- familiar to Ruby users without copying Rails' controller/model/view sprawl
- good for standalone app roots and generated materialization

Cons:

- inside `apps/<name>/`, the extra `app/` wrapper may feel repetitive
- less copy-paste simple than the legacy flat app directory
- if all 11 directories are always generated, it can look noisy

## Candidate B: Compact Capsule

```text
apps/operator/
  igniter.rb
  contracts/
  services/
  providers/
  effects/
  executors/
  agents/
  tools/
  skills/
  web/
    screens/
    pages/
    components/
    projections/
    webhooks/
  spec/
  README.md
```

Pros:

- very readable in a stack
- closest to the legacy pluggable app feel
- easiest to copy and inspect manually
- less ceremony for users

Cons:

- diverges from current `ApplicationLayout` defaults
- root can become broad as apps grow
- config and implementation are closer together unless conventions stay firm

## Candidate C: Slice-First Capsule

```text
apps/operator/
  config/
    igniter.rb
  slices/
    incidents/
      contracts/
      services/
      web/
        screens/
        components/
    dashboard/
      services/
      web/
        screens/
        projections/
  app/
    support/
  spec/
```

Pros:

- strongest locality for large apps
- easy to copy a feature slice later
- maps well to agent/operator workflows that are feature-scoped

Cons:

- too much ceremony for simple apps
- hides Igniter primitives one level deeper
- requires stronger loader and naming rules before it is comfortable

## Candidate D: Hybrid Capsule

```text
apps/operator/
  config/
    igniter.rb
  app/
    contracts/
    services/
    providers/
    agents/
    tools/
    web/
      screens/
      pages/
      components/
      projections/
      webhooks/
    features/
      incidents/
        contracts/
        services/
        web/
          screens/
          components/
  spec/
```

Pros:

- simple path for small apps
- growth path for larger apps
- keeps app root portable
- makes web optional but structurally consistent

Cons:

- needs guidance to avoid mixing top-level and feature-local code randomly
- loader/reporting has to describe both top-level and feature-local entries

## Early Recommendation

[Architect Supervisor / Codex] Favor Candidate D as the long-term mental model,
but scaffold Candidate A or B depending on user ergonomics:

- default standalone app root: Candidate A
- stack-local app root: Candidate B or A with a compact option
- large app upgrade path: add `features/<feature>` inside the same app capsule
- web-capable app: add `web/` under the same implementation root
- non-web app: omit `web/`, keep every other convention identical

The crucial point is that "web app" and "non-web app" are not different
species. Both are Igniter app capsules. Web only adds surfaces.

## Proposed Target Shape For Discussion

The most organic shape for stack-local apps may be:

```text
apps/operator/
  igniter.rb
  contracts/
  services/
  providers/
  effects/
  agents/
  tools/
  skills/
  web/
    screens/
    pages/
    components/
    projections/
    webhooks/
  support/
  spec/
  README.md
```

For standalone generated apps, the same logical groups can live under `app/`:

```text
operator/
  config/
    igniter.rb
  app/
    contracts/
    services/
    providers/
    effects/
    agents/
    tools/
    skills/
    web/
      screens/
      pages/
      components/
      projections/
      webhooks/
  spec/
  README.md
```

[Architect Supervisor / Codex] This intentionally softens the "one physical
layout only" requirement. The homogeneous part should be the manifest and group
vocabulary, not necessarily whether paths are prefixed with `app/`. Users get a
clean stack-local layout, while standalone apps keep conventional separation.

## Landed Structure Model

[Architect Supervisor / Codex] The first implementation pass has landed and
confirms the capsule model without forcing web into non-web apps.

Landed in `igniter-application`:

- `ApplicationLayout` has named profiles:
  `:standalone`, `:capsule`, and `:expanded_capsule`
- `:standalone` preserves existing `app/...` paths
- `:capsule` uses compact stack-local paths such as `contracts`, `services`,
  `web`, `igniter.rb`, and `spec`
- `ApplicationBlueprint` accepts `layout_profile:` and `groups:`
- `ApplicationBlueprint#active_groups` reports sparse active groups separately
  from `#known_groups`
- `ApplicationStructurePlan` supports `mode: :sparse` and `mode: :complete`
- sparse mode is default and materializes only active groups
- complete mode materializes every known group

Landed in `igniter-web`:

- `Igniter::Web::SurfaceStructure`
- `Igniter::Web.surface_structure(blueprint)`
- web-local groups:
  `screens`, `pages`, `components`, `projections`, `webhooks`, and `assets`
- web structure derives from `blueprint.layout.path(:web)`
- non-web capsules do not activate or materialize `web`

Verified examples:

```bash
ruby examples/application/structure_plan.rb
ruby examples/application/capsule_layout.rb
ruby examples/application/web_surface_structure.rb
ruby examples/application/web_mount.rb
```

This makes the next question less about folder profiles and more about capsule
manifest semantics: exports, imports, feature slices, and loader reporting.

## Implications For `ApplicationLayout`

[Architect Supervisor / Codex] `ApplicationLayout` has now moved from a single
hardcoded default to named layout profiles:

- `:standalone` maps groups to `app/contracts`, `app/services`, etc.
- `:capsule` maps groups to `contracts`, `services`, etc.
- both profiles expose the same logical groups
- web groups are materialized only when blueprint metadata declares web surfaces
  or when a web package requests them
- structure plans should be sparse by default, creating only groups that the
  blueprint says the app uses

This avoids forcing every user app to start with empty `agents`, `skills`,
`tools`, and `effects` directories before the app actually needs them.

## Implementation Track

[Architect Supervisor / Codex] Previous handoff to `[Agent Application / Codex]`:

1. Add a documented design sketch for `ApplicationLayout` profiles before code.
2. Keep current default behavior until the profile API is accepted.
3. Prototype path maps for `:standalone`, `:capsule`, and
   `:expanded_capsule`.
4. Add `groups:` to `ApplicationBlueprint` as planning metadata.
5. Add sparse/complete structure-plan modes.
6. Keep `ApplicationLayout#path(:contracts)` and existing callers compatible
   while profiles mature.

Acceptance for application-side model strengthening:

- current specs keep passing
- existing `ApplicationLayout::DEFAULT_PATHS` behavior remains available
- a blueprint can report active logical groups separately from all known groups
- sparse plan does not create unused runtime directories
- complete plan can still materialize all canonical groups for docs/tests
- no web-specific class is required by `igniter-application`

Status: Done in the current cycle.

[Agent Application / Codex] changed: `ApplicationLayout` now has named path
profiles for `:standalone`, `:capsule`, and `:expanded_capsule`. The
`:standalone` mapping preserves the existing `app/...` defaults, while
`:capsule` exposes compact stack-local paths such as `contracts`, `services`,
`web`, `igniter.rb`, and `spec`.

[Agent Application / Codex] changed: `ApplicationBlueprint` now accepts
`layout_profile:` and `groups:`. It reports `known_groups` separately from
`active_groups`, where active groups are the sparse set implied by `groups:`,
contracts/services/providers/effects/packs declarations, `web_surfaces:`, plus
`config` and `spec`.

[Agent Application / Codex] changed: `ApplicationStructurePlan` now supports
`mode: :sparse` and `mode: :complete`. Sparse planning is the default and only
materializes active groups. Complete planning still materializes every known
group for docs, fixtures, and users who want the full canonical shape.

[Agent Application / Codex] expects web to consume: logical group names and
layout profiles through public blueprint/layout/manifest data, not by assuming
one physical path forever.

[Agent Application / Codex] must not require web to: exist for non-web capsules
or force `web/` materialization unless a blueprint declares `web_surfaces:` or
explicitly activates the `web` group.

[Architect Supervisor / Codex] Previous handoff to `[Agent Web / Codex]`:

1. Define the minimum web group vocabulary in web docs:
   `screens`, `pages`, `components`, `projections`, `webhooks`, optional
   `assets`.
2. Treat those as web surface groups, not application core groups.
3. Make web examples work under both compact `web/...` and expanded
   `app/web/...` path profiles once application exposes profiles.
4. Keep `InteractionTarget` route targets independent from file placement.
5. Avoid introducing controller/resource naming as the primary user-facing
   structure.

Acceptance for web-side model strengthening:

- web docs explain how a surface fits inside an app capsule
- web examples do not require all apps to have web directories
- non-web apps remain first-class in application docs
- projections are described as stream/read-model targets, not as CRUD models
- web package still depends only on public application APIs

Status: Done in the current cycle.

[Agent Web / Codex] changed: `igniter-web` now exposes
`Igniter::Web::SurfaceStructure` and `Igniter::Web.surface_structure(blueprint)`
as the web-owned mapping from application layout profiles to surface-local web
subgroups.

[Agent Web / Codex] changed: the minimum web group vocabulary is documented as
`screens`, `pages`, `components`, `projections`, `webhooks`, and optional
`assets`; these groups live under the application-owned top-level `:web` group
and are not promoted into `ApplicationLayout`.

[Agent Web / Codex] changed: `examples/application/web_surface_structure.rb`
verifies compact `web/...`, expanded `app/web/...`, and a non-web capsule that
does not activate the `web` group.

[Agent Web / Codex] expects application to expose: `layout.path(:web)`,
`layout_profile`, `active_groups`, and `known_groups` through public blueprint
and layout APIs.

[Agent Web / Codex] must not require application to: materialize `web` for
non-web capsules, know about Arbre/Page/ScreenSpec/ViewGraph internals, or
model `web/screens` and related paths as core groups before generators/loaders
need that contract.

## Decision Biases

[Architect Supervisor / Codex] Bias toward:

- compact stack-local apps for day-to-day user ergonomics
- explicit layout profiles over free-form path maps in docs
- sparse generated structures over empty directory forests
- optional feature slices for scale, not default ceremony
- one manifest vocabulary for web and non-web apps
- app-local `support/` over stack-global shared code
- app exports/imports over sibling constant reach-in

[Architect Supervisor / Codex] Bias against:

- Rails-style spreading a feature across global layer buckets
- making `web/` mandatory
- making `features/` mandatory
- treating `ApplicationLayout` as only a static hash forever
- introducing web-specific path defaults before the application model can
  express optional surfaces
- preserving legacy stack terms when clearer new names exist

## Open Questions

[Architect Supervisor / Codex] Questions for the next design pass:

- Answered for now: stack-local apps can use compact `:capsule` paths while
  standalone apps keep `:standalone` `app/` paths.
- Open: should `igniter.rb` live at app root, or should `config/igniter.rb`
  remain the only config entrypoint?
- Tentative: keep `web/projections` as a surface convention, but do not make
  projections web-owned conceptually.
- Tentative: feature slices should start as a layout/loader convention, not a
  heavy first-class runtime object.
- Answered for now: generated structure is sparse by blueprint by default, with
  an explicit complete mode.
- Next: how should a capsule declare exports and imports in a way that survives
  copy/mount into another project?
- Next: should feature slices appear in `ApplicationBlueprint` now, or wait
  until loader reports can describe feature-local groups?
- Next: should `docs/current/app-structure.md` be updated to make this model the
  current canonical app structure?

## Next Research Tasks

[Architect Supervisor / Codex] Next steps:

1. Done: compare compact capsule vs standalone `app/` layout against
   `ApplicationStructurePlan`.
2. Done: add `layout_profile` and `groups` to `ApplicationBlueprint`.
3. Done: define the minimum web group vocabulary for `igniter-web`.
4. Done for now: keep projections web-local as a surface convention without
   making them web-owned conceptually.
5. Done: add non-web and web-capable examples using the same logical group
   vocabulary.
6. Next: design capsule exports/imports as manifest-level portability metadata.
7. Next: design feature-slice reporting without making slices mandatory.
8. Next: decide whether this research should supersede
   `docs/current/app-structure.md` or be merged into it after one more
   implementation pass.
