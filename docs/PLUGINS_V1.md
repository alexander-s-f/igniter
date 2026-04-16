# Igniter Plugins v1

This document defines the canonical model for framework and UI integration plugins.

`plugins/*` is a horizontal integration layer, separate from both the runtime
pyramid and `sdk/*` capability packs.

## What Plugins Mean

Plugins adapt external environments into Igniter.

Examples:

- Rails integration
- schema-driven view/UI runtime
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
require "igniter/plugins/view"
```

Top-level shortcuts such as `igniter/rails` and `igniter/view` are not part of
the public API.

## Built-in Plugins

| Plugin | Namespace | Require | Responsibility |
|--------|-----------|---------|----------------|
| `rails` | `Igniter::Rails` | `require "igniter/plugins/rails"` | Railtie, ActiveJob bridge, ActionCable adapter, webhook controller concern, generators |
| `view` | `Igniter::Plugins::View` | `require "igniter/plugins/view"` | schema-driven page/view runtime, form handling, schema rendering, schema storage helpers, plus optional adapter entrypoints such as Arbre and Tailwind |

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
  view.rb
  rails/
  view/
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

### `plugins/view`

Use for schema-driven rendering and submission handling:

- view builder
- page/component abstractions
- schema normalization/validation/rendering
- schema storage helpers

Do not treat it as a generic HTML helper bag outside the plugin boundary.

## Loading Examples

Rails:

```ruby
require "igniter"
require "igniter/plugins/rails"
```

View runtime:

```ruby
require "igniter/plugins/view"
require "igniter/sdk/data"
```

Optional adapter entrypoints:

```ruby
require "igniter/plugins/view/arbre"
require "igniter/plugins/view/tailwind"
```

Tailwind adapter primitives live under:

```ruby
Igniter::Plugins::View::Tailwind::UI::MetricCard
Igniter::Plugins::View::Tailwind::UI::Panel
Igniter::Plugins::View::Tailwind::UI::StatusBadge
Igniter::Plugins::View::Tailwind::UI::Banner
Igniter::Plugins::View::Tailwind::UI::ActionBar
Igniter::Plugins::View::Tailwind::UI::InlineActions
Igniter::Plugins::View::Tailwind::UI::KeyValueList
Igniter::Plugins::View::Tailwind::UI::PayloadDiff
Igniter::Plugins::View::Tailwind::UI::Field
Igniter::Plugins::View::Tailwind::UI::FormSection
Igniter::Plugins::View::Tailwind::UI::MessagePage
Igniter::Plugins::View::Tailwind::UI::SubmissionNotice
Igniter::Plugins::View::Tailwind::UI::FieldGroup
Igniter::Plugins::View::Tailwind::UI::ChoiceField
Igniter::Plugins::View::Tailwind::UI::SchemaHero
Igniter::Plugins::View::Tailwind::UI::SchemaIntro
Igniter::Plugins::View::Tailwind::UI::SchemaForm
Igniter::Plugins::View::Tailwind::UI::SchemaFieldset
Igniter::Plugins::View::Tailwind::UI::SchemaStack
Igniter::Plugins::View::Tailwind::UI::SchemaGrid
Igniter::Plugins::View::Tailwind::UI::SchemaSection
Igniter::Plugins::View::Tailwind::UI::SchemaCard
Igniter::Plugins::View::Tailwind::UI::PropertyCard
Igniter::Plugins::View::Tailwind::UI::ResourceList
Igniter::Plugins::View::Tailwind::UI::EndpointList
Igniter::Plugins::View::Tailwind::UI::TimelineList
Igniter::Plugins::View::Tailwind::UI::Theme
Igniter::Plugins::View::Tailwind::UI::Tokens
```

Tailwind page helpers also expose shared shell presets:

```ruby
Igniter::Plugins::View::Tailwind.render_page(title: "Home Lab", theme: :ops) { |main| ... }
Igniter::Plugins::View::Tailwind.render_page(title: "Companion", theme: :companion) { |main| ... }
Igniter::Plugins::View::Tailwind.render_page(title: "Schema", theme: :schema) { |main| ... }
```

These presets keep body classes, layout width, and Tailwind config aligned across
apps while still allowing local overrides such as a narrower `main_class` for a
detail page or message shell.

For component-level styling, `Igniter::Plugins::View::Tailwind::UI::Theme.fetch(...)`
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

- [View Schema Authoring](./VIEW_SCHEMA_AUTHORING.md)

## Mental Model

```text
core = kernel
sdk/* = optional capabilities
plugins/* = environment/framework integrations
```

Read next:

- [Module System v1](./MODULE_SYSTEM_V1.md)
- [SDK v1](./SDK_V1.md)
- [Layers v1](./LAYERS_V1.md)
- [Architecture Index](./ARCHITECTURE_INDEX.md)
