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
- workspace apps

That is a strong foundation for workflows, but not a reason to make frontend rendering
part of the core library.

At the same time, these use cases are very compelling:

- an agent creates a daily training check-in form and asks the user to fill it every day
- an app exposes a small self-service admin panel
- a user asks for a public survey/poll link and shares it with an audience
- an internal workspace app needs operational UI without introducing a JS stack

These scenarios are common enough that Igniter should probably have a story for them.

## Current hypothesis

The right direction is an **optional view plugin**, not a new core layer.

Possible future package names:

- `igniter-view`
- `igniter-arbre`
- `Igniter::Plugins::View`

The plugin would sit above `Igniter::Application` and `Igniter::Server`:

```text
Core
  -> Server
    -> Application / Workspace
      -> optional View plugin
```

## Experimental API now in the repo

The first small slice of that plugin now exists:

- `require "igniter/view"`
- `Igniter::Plugins::View.render { |view| ... }`
- `Igniter::Plugins::View::Builder`
- `Igniter::Plugins::View::Component`
- `Igniter::Plugins::View::Page`
- `Igniter::Plugins::View::FormBuilder`
- `Igniter::Plugins::View::Response.html(...)`

This API is intentionally small.

Its current role is:

- stop hardcoding large HTML strings
- prove out Ruby-native rendering patterns in real apps
- give `examples/companion/apps/dashboard` a cleaner shape

It is still intentionally small, but it now has enough structure to explore:

- page objects
- reusable components
- basic server-rendered forms

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
- admin pages for workspace apps

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
