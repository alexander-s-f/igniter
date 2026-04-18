# Igniter::Stack v1

Historical reference.

For the current canonical stack reading, start with:

- [docs/guide/app.md](../../guide/app.md)
- [docs/current/stacks.md](../../current/stacks.md)
- [docs/guide/configuration.md](../../guide/configuration.md)

## What This Old Document Was About

This V1 document described the earlier service/topology-oriented stack model.

It framed `Igniter::Stack` around:

- `apps/` as the unit of composition
- `config/topology.yml`
- `default_service`
- `--service` and role-oriented launch language

That is no longer the preferred stack-runtime model.

## What Is Still Historically Useful

### Standard generated shape

The older document is still useful as background for the original scaffold
layout around:

- `stack.rb`
- `stack.yml`
- `apps/<name>/app.rb`
- `apps/<name>/app.yml`
- shared code under `lib/<project>/shared`

### Earlier stack DSL language

It also preserves historical context for:

- `app(...)`
- `start_service`
- `rack_service`
- role/service launch language

### Why `apps/` became the default

The rationale for app-shaped bounded contexts inside one repo is still useful,
even though the deployment framing changed.

## What Changed Since V1

The current preferred reading is:

- stacks are stack-first, not service-first
- `stack.rb` + `stack.yml` are canonical
- mounted apps and optional node profiles are preferred
- `config/topology.yml`, `default_service`, and `--service` belong to older history

## If You Are Reading Old Stack Code

Use this file as a glossary for legacy stack/service/topology language only. For
new work, always prefer:

- [docs/current/stacks.md](../../current/stacks.md)
- [docs/guide/app.md](../../guide/app.md)
- [docs/guide/configuration.md](../../guide/configuration.md)
