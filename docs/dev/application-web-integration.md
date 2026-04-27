# Application And Web Integration

This note defines the public integration boundary between
`igniter-application` and `igniter-web`.

## Boundary

`igniter-application` owns:

- application identity and environment finalization
- local services, providers, contracts, and runtime state
- app-owned snapshots and evidence artifacts
- mutation policy and lifecycle decisions

`igniter-web` owns:

- mounted web surfaces
- request/response handling for the mounted review surface
- `MountContext` and read-oriented service access
- app-local feedback rendering, forms, and screen structure
- web surface manifests and metadata exported into capsule/review artifacts

Neither package should make the other a hidden dependency. Applications can
exist without web surfaces, and web surfaces should mount over an explicit
finalized environment instead of discovering application internals.

## Integration Shape

The accepted shape is:

1. Application builds a finalized environment.
2. Web mount binds to that environment.
3. Web renders from an explicit app-owned snapshot.
4. Commands route back through app-owned services.
5. `/events` and `/report` or `/receipt` expose the same detached state used by
   the web surface.

This pattern is proven by the showcase apps and described for users in:

- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Interactive App Structure](../guide/interactive-app-structure.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)

## Non-Goals

The integration boundary does not imply:

- production server behavior
- auth, persistence, scheduler, connectors, or live transport
- browser automation by default
- a marker DSL, route DSL, or generic UI component API
- application-owned inspection of web page classes
- web-owned mutation of application state outside explicit command handlers

## Extraction Rule

Repeated shapes should stay app-local until at least two showcase apps prove the
same abstraction with low ceremony. Promote only the pieces that reduce real
duplication without hiding ownership.
