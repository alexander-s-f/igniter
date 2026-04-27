# App

Use this section when Igniter becomes the runtime shape of an application, not
only an embedded contract kernel.

## Current Direction

The target application model is contracts-native:

- application capsules are the portability boundary
- app-local code stays inside the app that owns it
- optional web/UI surfaces live under the app, usually through `igniter-web`
- stack-level shared code is reserved for code that is truly shared
- hardcoded HTML strings in Ruby are not the recommended frontend path

For new work, start with [Application Capsules](./application-capsules.md).
For small interactive apps that combine `igniter-application` and
`igniter-web`, use [Interactive App Structure](./interactive-app-structure.md).

## Runtime Shape

The preferred app/runtime shape is:

- `stack.rb` defines apps and mounts
- `stack.yml` defines server defaults, persistence, and optional node profiles
- `bin/start`, `bin/dev`, and `bin/console` are the runtime entry points
- `Igniter::Stack` owns mounted coordination
- `Igniter::App` stays a portable mounted module

Graduate to cluster behavior only when distributed execution is actually
needed.

## First Reads

- [Application Capsules](./application-capsules.md)
- [Interactive App Structure](./interactive-app-structure.md)
- [Enterprise Verification](./enterprise-verification.md)
- [Application Showcase Portfolio](./application-showcase-portfolio.md)
- [Application Target Plan](../dev/application-target-plan.md)
- [Igniter Web Target Plan](../dev/igniter-web-target-plan.md)
- [CLI](./cli.md)
- [Configuration](./configuration.md)
- [Integrations](./integrations.md)

Legacy deep references and older app/stack notes are private working material
under `playgrounds/docs/`.
