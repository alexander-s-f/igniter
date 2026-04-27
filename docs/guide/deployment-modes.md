# Deployment Modes

Igniter has three current operating modes. The same contract can often move
between them while the surrounding runtime grows.

## 1. Embedded

Use this when Igniter runs inside an existing host such as Rails, a job, a CLI,
or a service.

```ruby
require "igniter"
```

Add optional packs explicitly through package entrypoints such as
`igniter-extensions` or host integration through `igniter-embed`.

Choose embedded mode when contracts are called directly and you do not need app
hosting, web mounting, or distributed execution.

## 2. Application

Use this when Igniter becomes the local runtime shape of an app.

Current package:

```ruby
require "igniter-application"
```

Use this mode for app profiles, providers, services, capsules, local lifecycle,
transfer review, activation review, and app-owned session state.

## 3. Cluster

Use this when the network becomes part of execution.

Current package:

```ruby
require "igniter-cluster"
```

Use this mode for capability routing, peer topology, placement, ownership,
health, failover, remediation, and distributed diagnostics.

## Web Is A Surface

`igniter-web` can be used with application mode, but web rendering is not the
same thing as app hosting. Keep screens, routes, components, and browser
surfaces web-owned.

## Pre-v1 Note

Older entrypoint language belongs to private historical context unless a package
README explicitly documents it as current.

## See Also

- [Getting Started](./getting-started.md)
- [Configuration](./configuration.md)
- [App](./app.md)
- [Cluster](./cluster.md)
