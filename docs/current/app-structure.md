# App Structure

This note fixes the current direction for `Igniter::App` structure while the
stack/app model is still evolving.

It is intentionally current-state and decision-oriented, not a legacy design
dump.

## Core Thesis

An app should be pluggable.

That means:

- an app can be copied into another Igniter stack
- mounted there
- and still work without depending on hidden stack-local glue

If an app needs another app, that dependency should be explicit.
The current contract is:

- provider app exposes a named interface with `expose`
- provider app can declare it more explicitly with `provide`
- stack registration declares that dependency with `access_to: [...]`
- consumers can resolve the interface through `App.interface(:name)` /
  `App.interfaces` once the app is mounted in a stack
- stack still exposes the lower-level `Stack.interface(:name)` and `Stack.interfaces`
- avoid hidden coupling through shared constants or shared helper files

## Placement Rules

### App code belongs in the app

Code that exists for one app should live under that app.

Examples:

- contracts
- executors
- agents
- tools
- skills
- optional `web/handlers`
- optional `web/views`
- optional `web/components`
- optional app-private `support/`

If the code only exists because one app needs it, it should not live in
stack-level `lib`.

### `lib` is only for truly shared code

`lib/<project>/shared` should mean genuinely shared stack-level code, not
"somewhere convenient to put app code".

Good candidates:

- stack-level deployment helpers
- cross-app shared domain primitives
- intentionally reused shared infrastructure owned by the stack

Bad candidates:

- a dashboard handler used only by the dashboard app
- app-local note stores
- app-local view helpers
- app-local capability profiles

## Current Anti-Patterns

These are current anti-patterns:

- app-local code in `lib/<project>/shared`
- app-local code in `lib/<project>/<app>/...` when it should live under `apps/<app>/`
- implicit sibling coupling through direct constant reach-in
- hardcoded HTML strings in Ruby source

For frontend authoring, the default recommended path is:

- `igniter-frontend`
- Arbre pages/templates/components
- Tailwind surfaces

`igniter-frontend` should now be treated as shipping with Arbre, not as an
optional Arbre adapter you wire in later.

We should not treat raw HTML string assembly in Ruby as the preferred style.
It is an anti-pattern and should be migrated away from over time.

The scaffold direction is now aligned with this rule:

- app-local handlers/views/support objects are generated inside the owning app
- stack-level `lib/<project>/shared` is reserved for genuinely shared stack code
- generated dashboard/operator pages should prefer `igniter-frontend` page classes
  over raw HTML string assembly
- generated `playground` and `cluster` stacks now show cross-app composition through
  `provide + access_to + App.interface(...)`, not through direct sibling reach-in

## App Structure Options

There are three realistic structure directions.

### Option 1. Minimal top-level runtime buckets

```text
apps/<app>/
  contracts/
  executors/
  agents/
  tools/
  skills/
  spec/
  app.rb
  app.yml
```

Pros:

- matches Igniter's first-class primitives directly
- very small and easy to scan
- no unnecessary nesting
- ideal as the default scaffold shape

Cons:

- web/UI surfaces need an extra convention
- larger apps may still want one more organizing layer

### Option 2. Top-level runtime buckets plus optional web

```text
apps/<app>/
  contracts/
  executors/
  agents/
  tools/
  skills/
  web/
    handlers/
    views/
    components/
  support/
  spec/
  app.rb
  app.yml
```

Pros:

- simple
- readable
- makes web an optional surface instead of a mandatory assumption
- keeps Igniter runtime primitives top-level and obvious

Cons:

- can become broad for large apps
- still leaves feature boundaries implicit unless the app introduces them

### Option 3. Feature slices

```text
apps/<app>/
  features/
    orders/
      contracts/
      handlers/
      views/
    dashboard/
      handlers/
      views/
      components/
  support/
  spec/
  app.rb
  app.yml
```

Pros:

- very good locality for large apps
- encourages bounded features

Cons:

- heavier to teach and scaffold
- too much ceremony for small/medium stacks

### Option 4. Hybrid runtime buckets plus feature slices

```text
apps/<app>/
  contracts/
  executors/
  agents/
  tools/
  skills/
  web/
    handlers/
    views/
    components/
  support/
  features/
  spec/
  app.rb
  app.yml
```

Pros:

- keeps the common path simple
- leaves room for larger feature slices later
- separates web/UI concerns clearly

Cons:

- slightly more abstract than the flat model
- can become inconsistent if not guided well

## Recommended Direction

The current best target is the minimal top-level runtime layout, with optional
`web/` when the app actually exposes a web surface.

Recommended shape:

```text
apps/<app>/
  contracts/
  executors/
  agents/
  tools/
  skills/
  spec/
  app.rb
  app.yml
```

If the app has a web surface, add:

```text
apps/<app>/
  contracts/
  executors/
  agents/
  tools/
  skills/
  web/
    handlers/
    views/
    components/
  spec/
  app.rb
  app.yml
```

Rules:

- keep `contracts`, `executors`, `agents`, `tools`, and `skills` top-level
- add `web/` only when the app really has a web/UI surface
- use optional top-level `support/` for app-private shared code
- only introduce deeper feature slices when the app actually becomes large
- keep stack-level `lib/<project>/shared` for code that is truly stack-shared

This gives us a clean default without forcing early architectural ceremony or a
mandatory `app/` wrapper directory.

## Frontend Direction

The recommended human UI path is:

- `require "igniter-frontend"`
- Arbre pages
- Arbre components
- Tailwind UI surfaces

Preferred structure for a web-capable app:

```text
apps/<app>/
  web/
    handlers/
    views/
    components/
```

The important rule comes first:

- no hardcoded HTML strings as the recommended style
- prefer frontend objects/templates/components

## Portability Rule

An app should not assume:

- it is the root app
- a specific sibling app exists
- direct access to sibling internals through stack `lib`

If an app needs another app:

- declare that dependency explicitly
- keep the access surface narrow
- prefer a stable app-to-app API over direct constant sharing

`access_to` is not just a future direction now. It already exists at the stack
registration layer and is validated against exposed interfaces.

Current example:

```ruby
class MainApp < Igniter::App
  provide :notes_api, NotesAPI
end

class Workspace < Igniter::Stack
  app :main, path: "apps/main", klass: MainApp, default: true
  app :dashboard, path: "apps/dashboard", klass: DashboardApp, access_to: [:notes_api]
end

Workspace.interface(:notes_api)
DashboardApp.interface(:notes_api)
```

That is the current canonical path for explicit cross-app access.

## Compatibility Policy Before v1

Igniter does not promise backward compatibility before `v1`.

That is not only a release note. It is a development rule:

- do not preserve weak structure just because it already exists
- do not add compatibility shims by default
- prefer replacing bad shapes with cleaner ones
- if a structure is wrong, we should feel free to remove it and implement the
  better shape

This is also the signal for development agents working on the codebase:

- optimize for the target architecture
- do not accumulate avoidable debt just to keep transitional layouts alive

## Current Migration Direction

The practical next app-structure moves are:

1. stop generating new app-local code into stack-level `lib/.../shared`
2. move generated dashboard/playground/cluster app code under the owning app
3. replace raw HTML-string generator output with `igniter-frontend` authoring
4. design an explicit cross-app access surface instead of hidden sharing

The important part is the order:

- first fix placement
- then fix authoring style
- then deepen cross-app composition
