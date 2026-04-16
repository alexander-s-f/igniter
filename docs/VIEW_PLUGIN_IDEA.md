# View Plugin Idea

This document captures an emerging pattern from `examples/companion/apps/dashboard`:
Igniter applications sometimes need lightweight HTML forms, internal dashboards, and
public-facing questionnaires, but those concerns should remain optional and outside the
core graph/runtime model.

## Why this probably should be a plugin

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

## Current hypothesis

The right direction is an **optional view plugin**, not a new core layer.

Possible future package names:

- `igniter-view`
- `igniter-arbre`
- `Igniter::Plugins::View`

The repo can keep this inside `Igniter::Plugins::View`, but expose separate
opt-in adapter entrypoints:

- base DSL: `igniter/plugins/view`
- Arbre bridge: `igniter/plugins/view/arbre`
- Tailwind helpers: `igniter/plugins/view/tailwind`

The plugin would sit above `Igniter::App`, `Igniter::Stack`, and `Igniter::Server`:

```text
Core
  -> Server
    -> App / Stack
      -> optional View plugin
```

## Experimental API now in the repo

The first small slice of that plugin now exists:

- `require "igniter/plugins/view"`
- `require "igniter/plugins/view/arbre"`
- `require "igniter/plugins/view/tailwind"`
- `Igniter::Plugins::View.render { |view| ... }`
- `Igniter::Plugins::View::Builder`
- `Igniter::Plugins::View::Component`
- `Igniter::Plugins::View::Page`
- `Igniter::Plugins::View::FormBuilder`
- `Igniter::Plugins::View::Response.html(...)`
- `Igniter::Plugins::View::Tailwind::UI::*` reusable dashboard primitives
- `Igniter::Plugins::View::Tailwind::UI::Theme.fetch(...)`
- `Igniter::Plugins::View::Tailwind.render_page(..., theme: ...)`
- `Igniter::Plugins::View::Tailwind.render_message_page(..., theme: ...)`

That Tailwind UI slice is now starting to look like a small server-rendered kit:

- `MetricCard`
- `Panel`
- `StatusBadge`
- `Banner`
- `ActionBar`
- `InlineActions`
- `KeyValueList`
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
- give `examples/companion/apps/dashboard` a cleaner shape

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

## Practical pattern we are already learning

`examples/companion/apps/dashboard` currently uses:

- HTTP routes declared at the app layer
- JSON handlers for machine access
- HTML rendering isolated into a dedicated view object
- `Igniter::Plugins::View` as the rendering primitive
- persisted app data from `Igniter::Data`
- app-local actions that mutate reminders and notification preferences

This is useful evidence because it suggests a good separation:

- handlers decide request/response behavior
- views render HTML
- stores hold application state
- contracts/skills/tools stay focused on workflow logic

## Proposed plugin responsibilities

An optional view plugin should probably provide:

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

1. keep evolving `examples/companion/apps/dashboard`
2. keep views isolated under a clear namespace
3. keep growing `Igniter::Plugins::View` only where repetition becomes obvious
4. watch for repeated patterns in handlers, actions, forms, and rendering
5. when those patterns stabilize, extract or formalize the richer plugin surface

That gives Igniter a UI story without diluting the core architecture.
