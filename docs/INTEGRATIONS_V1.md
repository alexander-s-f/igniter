# Igniter Integrations v1

This document defines the canonical model for framework and UI integration plugins.

`plugins/*` is a horizontal integration layer, separate from both the runtime
pyramid and `sdk/*` capability packs.

## What Plugins Mean

Plugins adapt external environments into Igniter.

Examples:

- Rails integration
- future adapters for other frameworks

Plugins are not part of the embedded kernel, and they are not generic shared
capabilities like `sdk/*`. They are integration surfaces.

## Canonical Rule

Plugins load only through:

```ruby
require "igniter/plugins/<plugin>"
```

Examples:

```ruby
require "igniter/plugins/rails"
```

Top-level shortcuts such as `igniter/rails` and `igniter/view` are not part of
the public API.

## Built-in Plugins

| Plugin | Namespace | Require | Responsibility |
|--------|-----------|---------|----------------|
| `rails` | `Igniter::Rails` | `require "igniter/plugins/rails"` | Railtie, ActiveJob bridge, ActionCable adapter, webhook controller concern, generators |

## Relationship To Other Layers

Think of Igniter as three orthogonal dimensions:

```text
runtime pyramid
  core -> server/app -> cluster

capability packs
  sdk/*

integration plugins
  plugins/*
```

Practical rules:

- plugins may depend on core and on the layer they integrate with
- plugins may depend on `sdk/*` when that is part of the integration contract
- plugins must not silently rewrite runtime-layer boot behavior on `require`
- plugins should expose framework-facing entrypoints, not generic reusable primitives

## Placement Rules

Put code in `plugins/*` when all of the following are true:

- it adapts Igniter to an external framework, host environment, or UI runtime
- it is not required for embedded core usage
- it is not just an optional shared capability pack

Do not put code in `plugins/*` when it belongs more naturally to:

- **core**: fundamental runtime/compiler/model behavior
- **sdk**: reusable optional capabilities
- **app/server/cluster**: runtime lifecycle, transport, topology, host wiring

## File Layout

Canonical layout:

```text
lib/igniter/plugins.rb
lib/igniter/plugins/
  rails.rb
  rails/
```

`lib/igniter/plugins.rb` should stay a neutral namespace entrypoint. It should
not auto-load concrete plugins.

## Pack Guidance

### `plugins/rails`

Use for Rails-specific integration:

- Railtie boot hooks
- ActiveJob wrappers
- ActionCable adapters
- controller concerns
- Rails generators

Do not put generic runtime or capability code here.

## Monorepo Packages

The former view plugin has been split into local monorepo packages:

- `require "igniter-frontend"`
  `Igniter::Frontend`
  human-authored web surfaces, Arbre pages, Tailwind shell, request/response helpers
- `require "igniter-schema-rendering"`
  `Igniter::SchemaRendering`
  schema runtime, storage, patching, and submission pipeline

## Loading Examples

Rails:

```ruby
require "igniter"
require "igniter/plugins/rails"
```

Frontend package:

```ruby
require "igniter-frontend"
```

Schema rendering package:

```ruby
require "igniter-schema-rendering"
require "igniter/sdk/data"
```

Tailwind adapter primitives live under:

```ruby
Igniter::Frontend::Tailwind::UI::MetricCard
Igniter::Frontend::Tailwind::UI::Panel
Igniter::Frontend::Tailwind::UI::StatusBadge
Igniter::Frontend::Tailwind::UI::Banner
Igniter::Frontend::Tailwind::UI::ActionBar
Igniter::Frontend::Tailwind::UI::InlineActions
Igniter::Frontend::Tailwind::UI::KeyValueList
Igniter::Frontend::Tailwind::UI::PayloadDiff
Igniter::Frontend::Tailwind::UI::Field
Igniter::Frontend::Tailwind::UI::FormSection
Igniter::Frontend::Tailwind::UI::MessagePage
Igniter::Frontend::Tailwind::UI::SubmissionNotice
Igniter::Frontend::Tailwind::UI::FieldGroup
Igniter::Frontend::Tailwind::UI::ChoiceField
Igniter::Frontend::Tailwind::UI::SchemaHero
Igniter::Frontend::Tailwind::UI::SchemaIntro
Igniter::Frontend::Tailwind::UI::SchemaForm
Igniter::Frontend::Tailwind::UI::SchemaFieldset
Igniter::Frontend::Tailwind::UI::SchemaStack
Igniter::Frontend::Tailwind::UI::SchemaGrid
Igniter::Frontend::Tailwind::UI::SchemaSection
Igniter::Frontend::Tailwind::UI::SchemaCard
Igniter::Frontend::Tailwind::UI::PropertyCard
Igniter::Frontend::Tailwind::UI::ResourceList
Igniter::Frontend::Tailwind::UI::EndpointList
Igniter::Frontend::Tailwind::UI::TimelineList
Igniter::Frontend::Tailwind::UI::Theme
Igniter::Frontend::Tailwind::UI::Tokens
```

Tailwind page helpers also expose shared shell presets:

```ruby
Igniter::Frontend::Tailwind.render_page(title: "Home Lab", theme: :ops) { |main| ... }
Igniter::Frontend::Tailwind.render_page(title: "Companion", theme: :companion) { |main| ... }
Igniter::Frontend::Tailwind.render_page(title: "Schema", theme: :schema) { |main| ... }
```

These presets keep body classes, layout width, and Tailwind config aligned across
apps while still allowing local overrides such as a narrower `main_class` for a
detail page or message shell.

For component-level styling, `Igniter::Frontend::Tailwind::UI::Theme.fetch(...)`
exposes shared presets for:

- panels
- form sections
- message pages
- hero and surface chrome used by dashboards and detail pages
- repeated field/input, checkbox, code-pill, muted-text, and empty-state styles
- repeated list/card/heading/text styles used across dashboard sections
- semantic server-rendered dashboard slices such as resource lists, endpoint lists, and timeline lists
- semantic runtime inspection slices such as payload diffs for raw vs normalized submission data
- semantic schema/runtime form blocks such as submission notices, grouped inputs, and choice fields
- semantic schema layout blocks such as schema heroes, stacks, grids, sections, and cards
- schema-aware composition blocks such as schema forms, fieldsets, and intro text blocks
- direct schema node support for semantic runtime blocks such as `notice`, `fieldset`, and `actions`

Authoring guide:

- [Schema Rendering Authoring](./SCHEMA_RENDERING_AUTHORING.md)

## Mental Model

```text
core = kernel
sdk/* = optional capabilities
plugins/* = environment/framework integrations
packages/* = higher-level optional product surfaces
```

Read next:

- [Module System v1](./MODULE_SYSTEM_V1.md)
- [SDK v1](./SDK_V1.md)
- [Layers v1](./LAYERS_V1.md)
- [Architecture Index](./ARCHITECTURE_INDEX.md)
