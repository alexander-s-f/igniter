# Igniter — Deployment Scenarios v1

Historical reference.

For the current canonical deployment reading, start with:

- [docs/guide/deployment-modes.md](./guide/deployment-modes.md)
- [docs/guide/configuration.md](./guide/configuration.md)
- [docs/app/README.md](./app/README.md)
- [docs/cluster/README.md](./cluster/README.md)

## What This Old Document Contributed

This V1 document framed Igniter as three deployment scenarios:

1. embedded library
2. single-machine app server
3. distributed app-server cluster

That progression is still useful as a mental model.

## What Is Still Historically Useful

### Embedded reading

The older document is still useful if you want examples of the original
“drop Igniter into an existing Rails/job/script app” framing.

### App-server reading

It also captures the earlier explanation of:

- stack/app scaffold shape
- built-in HTTP endpoints
- single-machine scaling ideas
- `config.ru` / Rack / Puma deployment language

### Cluster reading

It remains useful as historical context for:

- remote contracts
- distributed workflows
- older cluster topology examples
- Raft/gossip/replication motivation

## What Changed Since V1

The current docs now separate:

- deployment modes as a short guide concern
- configuration and runtime shape as a guide concern
- app runtime structure as an app-layer concern
- distributed coordination as a cluster-layer concern

Also, the monorepo is now package-oriented, so older single-gem roadmap language
should be read historically rather than literally.

## If You Are Reading Old Operational Notes

Use this file as a source of older examples and deployment language only. For
current entrypoints and package-era structure, always prefer:

- [docs/guide/deployment-modes.md](./guide/deployment-modes.md)
- [docs/guide/configuration.md](./guide/configuration.md)
- [docs/app/README.md](./app/README.md)
- [docs/cluster/README.md](./cluster/README.md)
