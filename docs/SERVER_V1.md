# igniter-stack v1

Historical reference.

For the current canonical hosting reading, start with:

- [docs/app/README.md](./app/README.md)
- [docs/guide/deployment-modes.md](./guide/deployment-modes.md)
- [docs/guide/configuration.md](./guide/configuration.md)

## What This Old Document Was About

This V1 document described the earlier standalone HTTP hosting surface around
`Igniter::Server` and `igniter-stack`.

It covered:

- direct server configuration
- Rack / Puma setup
- REST endpoints
- HTTP client usage
- multi-node HTTP composition
- Kubernetes-oriented operational detail

## What Is Still Historically Useful

### Earlier REST surface

The old document is still useful if you are reading code or notes that refer to
older endpoints such as:

- `/v1/contracts/:name/execute`
- `/v1/contracts/:name/events`
- `/v1/executions/:id`
- `/v1/metrics`
- `/v1/manifest`

### Earlier hosting language

It also preserves older explanations for:

- direct `Igniter::Server.configure`
- `Igniter::Server.rack_app`
- Rack / Puma deployment
- graceful shutdown and structured logging

### Older single-node and K8s framing

The operational discussion around single-node HTTP hosting and Kubernetes is
still useful as historical context.

## What Changed Since V1

The current docs separate more cleanly between:

- app runtime/profile concerns
- stack/runtime shape
- distributed cluster concerns
- package ownership

So this document should no longer be read as the main entrypoint to hosting.

## If You Are Reading Old Server Notes

Use this file as historical API/operations context only. For current entrypoints
and runtime shape, always prefer:

- [docs/app/README.md](./app/README.md)
- [docs/guide/deployment-modes.md](./guide/deployment-modes.md)
- [docs/guide/configuration.md](./guide/configuration.md)
