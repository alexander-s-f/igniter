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
The direction is:

- declare the relationship explicitly
- use a unified cross-app surface such as `access_to`
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
- handlers
- views
- components
- app-private support objects

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

These are current anti-patterns, even if some generators still produce them
today:

- app-local code in `lib/<project>/shared`
- app-local code in `lib/<project>/<app>/...` when it should live under `apps/<app>/`
- implicit sibling coupling through direct constant reach-in
- hardcoded HTML strings in Ruby source

For frontend authoring, the default recommended path is:

- `igniter-frontend`
- Arbre pages/templates/components
- Tailwind surfaces

We should not treat raw HTML string assembly in Ruby as the preferred style.
It is an anti-pattern and should be migrated away from over time.

## App Structure Options

There are three realistic structure directions.

### Option 1. Flat app buckets

```text
apps/<app>/
  app/
    contracts/
    executors/
    agents/
    tools/
    skills/
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
- easy to scaffold
- keeps all app-local code inside the app

Cons:

- can become broad for large apps
- feature boundaries are weaker than they could be

### Option 2. Feature slices

```text
apps/<app>/
  app/
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

### Option 3. Hybrid app buckets plus feature slices

```text
apps/<app>/
  app/
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

The current best target is a hybrid that stays simple by default.

Recommended shape:

```text
apps/<app>/
  app/
    contracts/
    executors/
    agents/
    tools/
    skills/
    handlers/
    views/
    components/
    support/
  spec/
  app.rb
  app.yml
```

Rules:

- start with flat app-owned buckets
- use `support/` for app-private shared code
- only introduce deeper feature slices when the app actually becomes large
- keep stack-level `lib/<project>/shared` for code that is truly stack-shared

This gives us a clean default without forcing early feature-architecture
ceremony.

## Frontend Direction

The recommended human UI path is:

- `require "igniter-frontend"`
- Arbre pages
- Arbre components
- Tailwind UI surfaces

Preferred structure inside an app:

```text
apps/<app>/app/
  handlers/
  views/
  components/
```

If we later want a more explicit web split, that can evolve into:

```text
apps/<app>/app/web/
  handlers/
  views/
  components/
```

But the important rule comes first:

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

`access_to` is the right direction for that principle.

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
