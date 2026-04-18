# Persistence Model v1

Historical reference.

For the current canonical reading, start with:

- [docs/dev/data-ownership.md](./dev/data-ownership.md)
- [docs/dev/package-map.md](./dev/package-map.md)

## What This Old Document Was About

The V1 write-up argued for local-first persistence, explicit ownership, small
replicated cluster state, and derived read models.

## What Is Still Historically Useful

- the distinction between node-local state, replicated metadata, and read models
- the ownership-first framing for routing/state placement
- the historical anti-goals around assuming one global shared database

## What Changed Since V1

This topic is now better read as an architecture/ownership question inside the
dev layer rather than as a stand-alone top-level doc.
