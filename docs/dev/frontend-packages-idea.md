# Frontend Packages Idea

Historical note:
this document started as the design sketch for what is now split into
`igniter-frontend` and `igniter-schema-rendering`.

This document captures an emerging pattern from an earlier dashboard prototype:
Igniter applications sometimes need lightweight HTML forms, internal dashboards, and
public-facing questionnaires, but those concerns should remain optional and outside the
core graph/runtime model.

## Why this started as a plugin idea

Igniter is graph-based and backend-first:

- contracts
- tools
- skills
- channels
- scheduling
- persistence
- stack apps

That is a strong foundation for workflows, but not a reason to make frontend rendering
part of the core library.

At the same time, these use cases are very compelling:

- an agent creates a daily training check-in form and asks the user to fill it every day
- an app exposes a small self-service admin panel
- a user asks for a public survey/poll link and shares it with an audience
- an internal stack app needs operational UI without introducing a JS stack

These scenarios are common enough that Igniter should probably have a story for them.

## Current outcome

The repo no longer keeps this as `plugins/view`.
The concept has been split into two optional monorepo packages:

- `igniter-frontend`
- `igniter-schema-rendering`

The developer-facing package exposes:

- base DSL: `igniter-frontend`
- Arbre bridge: `igniter-frontend`
- Tailwind helpers: `igniter-frontend`

Current decision:

- `igniter-frontend` should ship with Arbre as a standard dependency
- the default authoring promise is: `Igniter Frontend` should feel as simple
  and powerful as `ActiveAdmin`, but for assistant, operator, and app surfaces

The schema lane now lives separately in `igniter-schema-rendering`.

These packages sit above `Igniter::App`, `Igniter::Stack`, and `Igniter::Server`:

```text
Core
  -> Server
    -> App / Stack
      -> optional frontend/schema packages
```

## Experimental API now in the repo

The first implemented slice now exists:

- `require "igniter-frontend"`
- `Igniter::Frontend.render { |view| ... }`
- `Igniter::Frontend::Builder`
- `Igniter::Frontend::Component`
- `Igniter::Frontend::Page`
- `Igniter::Frontend::FormBuilder`
- `Igniter::Frontend::Response.html(...)`
- `Igniter::Frontend::Tailwind::UI::*` reusable dashboard primitives
- `Igniter::Frontend::Tailwind::UI::Theme.fetch(...)`
- `Igniter::Frontend::Tailwind.render_page(..., theme: ...)`
- `Igniter::Frontend::Tailwind.render_message_page(..., theme: ...)`

That Tailwind UI slice is now starting to look like a small server-rendered kit:

- `MetricCard`
- `Panel`
- `StatusBadge`
- `Banner`
- `ActionBar`
- `InlineActions`
- `KeyValueList`
- `PayloadDiff`
- `Field`
- `FormSection`
- `MessagePage`
- `Tokens`

And the page shell itself now has shared presets for recurring surfaces:

- `theme: :ops` for `playgrounds/home-lab`-style operational dashboards
- `theme: :companion` for `examples/companion`-style assistant/admin surfaces
- `theme: :schema` for schema-driven pages and form flows

Inside those shells, `Tailwind::UI::Theme` now gives a second layer of shared
styling for component-level surfaces such as:

- dashboard panels
- form sections
- message/error cards
- hero banners and small chrome fragments
- field/input shells, checkbox wrappers, code pills, muted copy, and empty states
- repeated list/card/heading/title/body text containers for dashboard sections

The next layer is now visible too: semantic dashboard components, not just theme
tokens. Current examples in the repo include:

- `PropertyCard`
- `ResourceList`
- `EndpointList`
- `TimelineList`
- `PayloadDiff`

And the same direction is now starting to show up for schema/runtime form flows:

- `SubmissionNotice`
- `FieldGroup`
- `ChoiceField`

That semantic layer now also includes schema layout composition itself:

- `SchemaHero`
- `SchemaIntro`
- `SchemaForm`
- `SchemaFieldset`
- `SchemaStack`
- `SchemaGrid`
- `SchemaSection`
- `SchemaCard`

And schema JSON can now point at some of those semantics directly with nodes such as:

- `notice`
- `fieldset`
- `actions`

This API is intentionally small.

Its current role is:

- stop hardcoding large HTML strings
- prove out Ruby-native rendering patterns in real apps
- give the early dashboard prototype a cleaner shape

It is still intentionally small, but it now has enough structure to explore:

- page objects
- reusable components
- basic server-rendered forms
- opt-in adapters for richer authoring/runtime choices without polluting core

It is **not** yet a full component system or form framework.

## Why Arbre is a good fit

Arbre is attractive here because it keeps the whole stack inside Ruby:

- no mandatory JS framework
- no ERB string soup
- no context switch out of the app/runtime language
- composable components and forms
- easy to keep close to app logic and persistence

That matches the “lego-style” philosophy well.

## Next Frontend Track

The next explicit frontend track should not be “replace Arbre”.
It should be:

- strengthen UX/UI on top of the Arbre lane
- make Arbre-authored pages feel richer, more semantic, and more intentional
- keep improving reusable page, panel, list, timeline, operator, and assistant
  components
- make the default Igniter frontend experience feel product-grade, not only
  technically convenient

## Two Authoring Lanes

The view plugin is now clearly pulling in two different directions, and that is a
good thing if the split stays explicit:

- `schema` authoring for persisted, portable, machine-friendly UI/runtime flows
- Arbre-style authoring for developer-written pages, dashboards, and app UI

The key design rule should be:

- do not make developers author normal app UI through schema-first JSON trees

That schema lane is still very valuable for:

- agent-created views
- persisted/public form definitions
- lightweight editors/catalogs
- generic renderers and submission runtimes

But the primary developer experience should stay Ruby-native and compact.

### Practical interpretation

- `Igniter::SchemaRendering::Renderer` remains the runtime for persisted view schemas
- `Igniter::Frontend::Arbre::*` becomes the developer-facing authoring layer
- `Igniter::Frontend::Tailwind::UI::*` remains the semantic styling/component layer shared by both lanes

This keeps the machine/runtime representation important without forcing it to be the
main hand-authored representation.

## Starter Arbre Slice

The first developer-facing Arbre slice should stay intentionally small:

- `Igniter::Frontend::Arbre::Page.render_page(...)`
- `Igniter::Frontend::Arbre::Components::Breadcrumbs`
- `Igniter::Frontend::Arbre::Components::Card`

That enables a much simpler authoring story for early app UI:

```ruby
Igniter::Frontend::Arbre::Page.render_page(title: "Order") do
  breadcrumbs do
    crumb :home, "/"
    crumb :orders, "/orders"
    crumb :"order_42", nil, current: true
  end

  card(title: "Metadata") do
    line :created_at, order.created_at
    line :updated_at, order.updated_at
  end
end
```

This is the kind of API that helps developers learn Igniter itself, because it
lowers the cost of sketching useful UI around contracts, stores, and stack apps.

## Practical pattern we are already learning

The early dashboard prototype originally used:

- HTTP routes declared at the app layer
- JSON handlers for machine access
- HTML rendering isolated into a dedicated view object
- `Igniter::Frontend` as the rendering primitive
- persisted app data from `Igniter::Data`
- app-local actions that mutate reminders and notification preferences

This is useful evidence because it suggests a good separation:

- handlers decide request/response behavior
- views render HTML
- stores hold application state
- contracts/skills/tools stay focused on workflow logic

## Proposed plugin responsibilities

An optional frontend surface package should probably provide:

- HTML response helpers
- a Ruby-native component/view DSL
- form builders
- CSRF/session helpers if needed
- route helpers for rendering and form posts
- simple asset story for low-JS pages
- optional public form/survey endpoints

It should **not** own:

- graph execution semantics
- persistence model semantics
- channels
- scheduler behavior
- AI orchestration

## Candidate use cases

### Internal operational UI

- dashboard for reminders, notifications, executions, health
- admin pages for stack apps

### User-facing assistant UI

- daily check-in forms
- coaching / habit tracking
- light CRM input forms

### Public forms

- surveys
- polls
- onboarding questionnaires
- lightweight lead capture

## Design constraints

The plugin should stay:

- optional
- server-rendered first
- friendly to no-JS or minimal-JS flows
- compatible with `apps/` workspaces
- able to use `Igniter::Data`, `Channels`, `AI`, and contracts without coupling them

## Recommended next step

Do not add a general-purpose view layer to core yet.

Instead:

1. keep evolving the dashboard prototype
2. keep views isolated under a clear namespace
3. keep growing `Igniter::Frontend` only where repetition becomes obvious
4. watch for repeated patterns in handlers, actions, forms, and rendering
5. when those patterns stabilize, extract or formalize the richer plugin surface

That gives Igniter a UI story without diluting the core architecture.
