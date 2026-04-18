# Frontend Components

This guide shows how we write custom `Igniter::Frontend::Arbre` components
today.

If [Frontend Authoring](./frontend-authoring.md)
explains how to build a page, this guide explains how to grow the component
vocabulary behind that page.

## Mental Model

A good component should make page templates read more like:

```ruby
panel title: "Devices" do
  resource_list do
    item "front_door_cam", detail: "online · route=edge"
  end
end
```

and less like raw HTML assembly.

The goal is not to hide all markup.
The goal is to hide repeated semantics and repeated structure.

## Base API

All custom Arbre components inherit from
[Igniter::Frontend::Arbre::Component](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/component.rb:1).

That base class currently gives us a few important helpers:

- `extract_options!(args)`
- `render_build_block(block)`
- `merge_classes(...)`
- `humanize_label(...)`
- `ui_theme(...)`

This keeps individual components small and avoids repeating the same plumbing.

## Smallest Useful Component

The basic pattern is:

1. define a class under `Igniter::Frontend::Arbre::Components`
2. register a `builder_method`
3. implement `build`
4. optionally override `tag_name`

```ruby
module Igniter
  module Frontend
    module Arbre
      module Components
        class Badge < Arbre::Component
          builder_method :badge

          def build(label, tone: :neutral, class_name: nil)
            super(class: merge_classes("badge", "badge-#{tone}", class_name))
            text_node(label)
          end

          private

          def tag_name
            "span"
          end
        end
      end
    end
  end
end
```

That lets page authors write:

```ruby
badge "online", tone: :ok
```

## Primitive vs Domain Component

This is the most important design choice.

### Primitive component

A primitive gives you reusable UI vocabulary.

Examples already in the repo:

- [panel.rb](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/components/panel.rb:1)
- [tabs.rb](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/components/tabs.rb:1)
- [resource_list.rb](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/components/resource_list.rb:1)

Use a primitive when:

- the shape is reusable across apps
- the names should become part of authoring vocabulary
- the block should still stay flexible

### Domain component

A domain component encodes product meaning, not just UI structure.

Examples already in the repo:

- [conversation_panel.rb](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/components/conversation_panel.rb:1)
- [topology_health_panel.rb](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/components/topology_health_panel.rb:1)
- [devices_panel.rb](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/components/devices_panel.rb:1)

Use a domain component when:

- the block has app-specific semantics
- the same mini-workflow appears repeatedly
- you want the template to talk in business terms

As a rule of thumb:

- if other apps should reuse it, make a component
- if only one page currently needs it, start with a page helper
- if the helper starts repeating across pages, promote it into a component

That promotion path is now visible in `home-lab`: the old page helpers for
topology health and devices have been replaced by app-local domain components
that the template can call directly.

## Example: `panel`

[panel.rb](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/components/panel.rb:1)
is a good reference for the “semantic primitive” style.

What it does well:

- accepts semantic options like `title`, `subtitle`, `span`
- creates internal structure once
- exposes header slots with `meta` and `actions`
- routes arbitrary children into `panel-body`

That last part matters a lot:
the component owns its internal layout, while the caller still writes normal
Arbre content into it.

## Example: `tabs`

[tabs.rb](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/components/tabs.rb:1)
shows a slightly more stateful pattern.

It keeps internal state in `@tabs`, collects calls like `tab(...)`, and renders
the final nav and panes after the block has finished.

That pattern is useful when a component needs a two-phase structure:

- collect declarative child definitions first
- render a coordinated shell afterward

Use this pattern for things like:

- tabs
- accordions
- step flows
- grouped dashboards with generated nav

## Example: `resource_list`

[resource_list.rb](/Users/alex/dev/projects/igniter/packages/igniter-frontend/lib/igniter/frontend/arbre/components/resource_list.rb:1)
is intentionally tiny.

That is a feature, not a weakness.

It gives pages a meaningful API:

```ruby
resource_list do
  item "front_door_cam", detail: "online", meta: "edge"
end
```

without trying to become a generic table engine.

Many of our best components should stay this small.

## Child Routing

Some components should send arbitrary child content into a specific internal
container.

`panel` does this by overriding `add_child`:

```ruby
def add_child(child)
  return super if @body.nil? || child.equal?(@body) || child.equal?(@header) || child.equal?(@heading)

  @body << child
end
```

This is the current pattern when:

- the component owns fixed chrome
- caller content should land in one designated body region

Use it carefully.
If a component does not need internal child routing, do not add this complexity.

## Recommended Shape For New Components

When adding a new component:

1. start with the smallest semantic API that improves page readability
2. prefer one meaningful `builder_method`
3. accept semantic options, not low-level styling knobs first
4. keep class internals simple until repetition proves otherwise
5. only add internal state if the component truly needs a collect-then-render flow

Good first components usually look more like `resource_list` than like `tabs`.

## What To Avoid

### Avoid premature genericity

Do not build a huge configurable abstraction when a tiny semantic helper would do.

Bad direction:

- dozens of optional arguments
- too many low-level class hooks
- generic layout engines with no domain meaning

### Avoid leaking HTML intent into pages

If every page keeps rebuilding the same `div/div/h2/span/button` cluster,
extract it.

### Avoid componentifying one-off business logic too early

If a block is still specific to one page, a page helper is usually enough.

## Practical Workflow

When you notice repetition:

1. extract a page helper first
2. check whether the shape is app-specific or generic
3. promote generic shapes into `Igniter::Frontend::Arbre::Components`
4. keep domain-heavy blocks in the app until reuse becomes real

That gives us a clean path from:

- raw markup
- page helper
- reusable primitive
- reusable domain component

without guessing too early.

## Related Docs

- [Frontend Authoring](./FRONTEND_AUTHORING.md)
- [igniter-frontend README](/Users/alex/dev/projects/igniter/packages/igniter-frontend/README.md)
- [Schema Rendering Authoring](./SCHEMA_RENDERING_AUTHORING.md)
